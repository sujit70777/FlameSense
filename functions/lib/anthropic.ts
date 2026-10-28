/**
 * Raw-HTTP call to the Anthropic Messages API (PLAN.md Phase 12 step 6).
 *
 * Notes for the current models (see docs/QUESTIONS.md Q-9):
 * - No `temperature`: Claude Sonnet 5.5 rejects non-default sampling values with a 400.
 * - Claude Sonnet 5.5 thinks by default; `thinking: {type: "between_tools"}` turns it off so
 *   the 800-token budget goes to the answer.
 * - Server-side refusal fallback (`fallbacks: "default"`) re-runs a declined request on a
 *   fallback model inside the same call.
 */

export interface ClaudeEnv {
  ANTHROPIC_API_KEY: string;
  ASK_MODEL: string;
  ASK_MAX_TOKENS: string;
}

export interface ClaudeResult {
  ok: boolean;
  status: number;
  text: string;
  stopReason: string | null;
  model: string;
  inputTokens: number;
  outputTokens: number;
}

interface MessagesResponse {
  model?: string;
  stop_reason?: string | null;
  content?: { type: string; text?: string }[];
  usage?: { input_tokens?: number; output_tokens?: number };
}

const API_URL = 'https://api.anthropic.com/v1/messages';
export const TIMEOUT_MS = 25_000;

/** Request body for the Messages API. */
export function buildBody(env: ClaudeEnv, system: string, user: string): Record<string, unknown> {
  const body: Record<string, unknown> = {
    model: env.ASK_MODEL,
    max_tokens: Number(env.ASK_MAX_TOKENS) || 800,
    system,
    messages: [{ role: 'user', content: user }],
    fallbacks: 'default',
  };
  if (env.ASK_MODEL === 'claude-sonnet-5-5') body.thinking = { type: 'between_tools' };
  return body;
}

/** Calls Claude with a 25 s timeout; never throws (network errors → ok: false, status 0). */
export async function callClaude(
  env: ClaudeEnv,
  system: string,
  user: string,
  fetchImpl: typeof fetch = fetch,
): Promise<ClaudeResult> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), TIMEOUT_MS);
  const fail = (status: number): ClaudeResult => ({
    ok: false, status, text: '', stopReason: null, model: env.ASK_MODEL, inputTokens: 0, outputTokens: 0,
  });
  try {
    const res = await fetchImpl(API_URL, {
      method: 'POST',
      signal: controller.signal,
      headers: {
        'x-api-key': env.ANTHROPIC_API_KEY,
        'anthropic-version': '2023-06-01',
        'anthropic-beta': 'server-side-fallback-2026-07-01',
        'content-type': 'application/json',
      },
      body: JSON.stringify(buildBody(env, system, user)),
    });
    if (!res.ok) return fail(res.status);
    const data = (await res.json()) as MessagesResponse;
    // Check stop_reason before reading content: a refusal carries no usable answer.
    const text =
      data.stop_reason === 'refusal'
        ? ''
        : (data.content ?? []).filter((b) => b.type === 'text').map((b) => b.text ?? '').join('');
    return {
      ok: true,
      status: res.status,
      text,
      stopReason: data.stop_reason ?? null,
      model: data.model ?? env.ASK_MODEL,
      inputTokens: data.usage?.input_tokens ?? 0,
      outputTokens: data.usage?.output_tokens ?? 0,
    };
  } catch {
    return fail(0);
  } finally {
    clearTimeout(timer);
  }
}
