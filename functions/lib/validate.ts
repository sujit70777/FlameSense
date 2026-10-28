/**
 * Request validation for the Ask API (PLAN.md Phase 12 step 2).
 */

export type Lang = 'en' | 'bn';

export type AskRequest = { ok: true; question: string; lang: Lang } | { ok: false };

/** Validates `{question, lang}`: question trimmed 3–500 chars, lang en|bn (default en). */
export function validateAsk(body: unknown): AskRequest {
  if (typeof body !== 'object' || body === null) return { ok: false };
  const { question, lang } = body as Record<string, unknown>;
  if (typeof question !== 'string') return { ok: false };
  const q = question.trim();
  if (q.length < 3 || q.length > 500) return { ok: false };
  if (lang !== undefined && lang !== 'en' && lang !== 'bn') return { ok: false };
  return { ok: true, question: q, lang: (lang as Lang | undefined) ?? 'en' };
}
