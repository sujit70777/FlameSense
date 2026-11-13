/**
 * Raw-HTTP call to Groq (OpenAI-compatible chat completions), free tier.
 *
 * Fallback provider: used only when Gemini is busy or out of free quota. One key
 * (GROQ_API_KEY, a Cloudflare secret). 429/503 carry `retryAfterS` like gemini.ts.
 */

import { DEFAULT_RETRY_S, TIMEOUT_MS, type LlmResult } from './gemini';

export interface GroqEnv {
  GROQ_API_KEY?: string;
  GROQ_MODEL?: string;
  ASK_MAX_TOKENS: string;
}

interface GroqResponse {
  model?: string;
  choices?: { message?: { content?: string | null }; finish_reason?: string }[];
  usage?: { prompt_tokens?: number; completion_tokens?: number };
}

const API_URL = 'https://api.groq.com/openai/v1/chat/completions';
export const DEFAULT_GROQ_MODEL = 'openai/gpt-oss-120b';

/** Model name in use. */
export function groqModel(env: GroqEnv): string {
  return env.GROQ_MODEL || DEFAULT_GROQ_MODEL;
}

/** Request body for chat completions (JSON mode). */
export function buildGroqBody(env: GroqEnv, system: string, user: string): Record<string, unknown> {
  return {
    model: groqModel(env),
    messages: [
      { role: 'system', content: system },
      { role: 'user', content: user },
    ],
    max_tokens: Number(env.ASK_MAX_TOKENS) || 2048,
    response_format: { type: 'json_object' },
    reasoning_effort: 'low',
  };
}

/** Retry delay in seconds from Groq's Retry-After header, else the default. */
function retryAfter(res: Response): number {
  const s = Number(res.headers.get('retry-after'));
  return Number.isFinite(s) && s > 0 ? Math.ceil(s) : DEFAULT_RETRY_S;
}

/** Calls Groq with a 25 s timeout; never throws (network errors → ok: false, status 0). */
export async function callGroq(
  env: GroqEnv,
  system: string,
  user: string,
  fetchImpl: typeof fetch = fetch,
): Promise<LlmResult> {
  const model = groqModel(env);
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  const fail = (status: number, retryAfterS?: number): LlmResult => ({
    ok: false, status, text: '', stopReason: null, model, inputTokens: 0, outputTokens: 0, retryAfterS,
  });
  try {
    const res = await fetchImpl(API_URL, {
      method: 'POST',
      signal: controller.signal,
      headers: { authorization: `Bearer ${env.GROQ_API_KEY ?? ''}`, 'content-type': 'application/json' },
      body: JSON.stringify(buildGroqBody(env, system, user)),
    });
    if (res.status === 429 || res.status === 503) return fail(res.status, retryAfter(res));
    if (!res.ok) return fail(res.status);
    const data = (await res.json()) as GroqResponse;
    const choice = data.choices?.[0];
    return {
      ok: true,
      status: res.status,
      text: choice?.message?.content ?? '',
      stopReason: choice?.finish_reason === 'content_filter' ? 'refusal' : (choice?.finish_reason ?? null),
      model: data.model ?? model,
      inputTokens: data.usage?.prompt_tokens ?? 0,
      outputTokens: data.usage?.completion_tokens ?? 0,
    };
  } catch {
    return fail(0);
  } finally {
    clearTimeout(timer);
  }
}
