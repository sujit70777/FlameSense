/**
 * Raw-HTTP call to the Google Gemini API (generateContent), free tier.
 *
 * - One key (GEMINI_API_KEY, a Cloudflare secret). When Google answers 429 (free quota used
 *   up) or 503 (model overloaded), the result carries `retryAfterS` so the app can tell the
 *   user how long to wait. Keys are never rotated to get around quota.
 * - JSON output via `responseMimeType`; parts marked `thought` are skipped.
 * - A safety block (promptFeedback.blockReason or finishReason SAFETY) maps to `refusal`.
 */

export interface LlmEnv {
  GEMINI_API_KEY: string;
  ASK_MODEL: string;
  ASK_MAX_TOKENS: string;
}

export interface LlmResult {
  ok: boolean;
  status: number;
  text: string;
  stopReason: string | null;
  model: string;
  inputTokens: number;
  outputTokens: number;
  /** Seconds to wait before retrying, when the provider is rate limited or busy. */
  retryAfterS?: number;
}

interface GeminiPart {
  text?: string;
  thought?: boolean;
}

interface GeminiResponse {
  modelVersion?: string;
  candidates?: { content?: { parts?: GeminiPart[] }; finishReason?: string }[];
  promptFeedback?: { blockReason?: string };
  usageMetadata?: { promptTokenCount?: number; candidatesTokenCount?: number };
}

interface GeminiError {
  error?: { details?: { '@type'?: string; retryDelay?: string }[] };
}

const API_BASE = 'https://generativelanguage.googleapis.com/v1beta/models';
export const TIMEOUT_MS = 25_000;
/** Wait suggested when Google gives no retry hint. */
export const DEFAULT_RETRY_S = 60;
const BLOCKED = new Set(['SAFETY', 'PROHIBITED_CONTENT', 'BLOCKLIST', 'SPII', 'RECITATION']);

/** Request body for generateContent. */
export function buildBody(env: LlmEnv, system: string, user: string): Record<string, unknown> {
  return {
    systemInstruction: { parts: [{ text: system }] },
    contents: [{ role: 'user', parts: [{ text: user }] }],
    generationConfig: {
      // Thinking tokens count toward the output limit on Gemini models, so leave headroom.
      maxOutputTokens: Number(env.ASK_MAX_TOKENS) || 2048,
      responseMimeType: 'application/json',
    },
  };
}

/** Retry delay in seconds from a 429/503 reply (RetryInfo "37s" or Retry-After), else the default. */
export async function retryAfterSeconds(res: Response): Promise<number> {
  const header = Number(res.headers.get('retry-after'));
  if (Number.isFinite(header) && header > 0) return Math.ceil(header);
  try {
    const data = (await res.json()) as GeminiError;
    const info = data.error?.details?.find((d) => d['@type']?.endsWith('RetryInfo'));
    const s = parseFloat(info?.retryDelay ?? '');
    if (Number.isFinite(s) && s > 0) return Math.ceil(s);
  } catch {
    // No JSON body: fall through to the default.
  }
  return DEFAULT_RETRY_S;
}

/** Calls Gemini with a 25 s timeout; never throws (network errors → ok: false, status 0). */
export async function callModel(
  env: LlmEnv,
  system: string,
  user: string,
  fetchImpl: typeof fetch = fetch,
): Promise<LlmResult> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  const fail = (status: number, retryAfterS?: number): LlmResult => ({
    ok: false, status, text: '', stopReason: null, model: env.ASK_MODEL, inputTokens: 0, outputTokens: 0, retryAfterS,
  });
  try {
    const res = await fetchImpl(`${API_BASE}/${encodeURIComponent(env.ASK_MODEL)}:generateContent`, {
      method: 'POST',
      signal: controller.signal,
      headers: { 'x-goog-api-key': env.GEMINI_API_KEY, 'content-type': 'application/json' },
      body: JSON.stringify(buildBody(env, system, user)),
    });
    if (res.status === 429 || res.status === 503) return fail(res.status, await retryAfterSeconds(res));
    // Under heavy load Google sometimes answers 404 with an empty body; a real "model not
    // found" 404 always carries a JSON error. Treat the empty one as busy.
    if (res.status === 404 && !(await res.clone().text()).trim()) return fail(404, DEFAULT_RETRY_S);
    if (!res.ok) return fail(res.status);
    const data = (await res.json()) as GeminiResponse;
    const cand = data.candidates?.[0];
    const blocked = Boolean(data.promptFeedback?.blockReason) || BLOCKED.has(cand?.finishReason ?? '');
    const text = blocked
      ? ''
      : (cand?.content?.parts ?? []).filter((p) => !p.thought).map((p) => p.text ?? '').join('');
    return {
      ok: true,
      status: res.status,
      text,
      stopReason: blocked ? 'refusal' : (cand?.finishReason ?? null),
      model: data.modelVersion ?? env.ASK_MODEL,
      inputTokens: data.usageMetadata?.promptTokenCount ?? 0,
      outputTokens: data.usageMetadata?.candidatesTokenCount ?? 0,
    };
  } catch {
    return fail(0);
  } finally {
    clearTimeout(timer);
  }
}
