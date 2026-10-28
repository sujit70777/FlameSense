/**
 * Turns the model's JSON reply into an AskResponse (PLAN.md §3.9, Phase 12 step 6).
 */

import type { CorpusDoc, ScoredChunk } from './bm25';
import type { Lang } from './validate';

export interface Citation {
  n: number;
  chunk_id: string;
  title: string;
  url: string;
  page: number;
  snippet: string;
}

export interface AskResponse {
  answer: string;
  citations: Citation[];
  grounded: boolean;
  model: string;
  cached: boolean;
}

/** Strips ```json fences and parses the object; null when it isn't valid JSON. */
export function parseModelJson(text: string): { answer: string; used: number[]; grounded: boolean } | null {
  const cleaned = text.trim().replace(/^```(?:json)?\s*/i, '').replace(/\s*```$/, '');
  try {
    const o = JSON.parse(cleaned) as Record<string, unknown>;
    if (typeof o.answer !== 'string') return null;
    const used = Array.isArray(o.used_sources) ? o.used_sources.filter((v): v is number => Number.isInteger(v)) : [];
    return { answer: o.answer, used, grounded: o.grounded === true };
  } catch {
    return null;
  }
}

/** Keeps only `[Sn]` markers whose n is a used, existing source. */
export function filterMarkers(answer: string, valid: Set<number>): string {
  return answer
    .replace(/\[S(\d+)\]/g, (m, n: string) => (valid.has(Number(n)) ? m : ''))
    .replace(/ +([.,;:])/g, '$1')
    .replace(/[ \t]{2,}/g, ' ')
    .trim();
}

/** Builds the response: citations only for used sources that exist; invalid markers removed. */
export function buildResponse(
  parsed: { answer: string; used: number[]; grounded: boolean },
  chunks: ScoredChunk[],
  docs: Map<string, CorpusDoc>,
  model: string,
): AskResponse {
  const valid = new Set(parsed.used.filter((n) => n >= 1 && n <= chunks.length));
  const citations = [...valid]
    .sort((a, b) => a - b)
    .map((n) => {
      const c = chunks[n - 1].chunk;
      const d = docs.get(c.doc_id);
      return { n, chunk_id: c.id, title: d?.title ?? c.doc_id, url: d?.url ?? '', page: c.page, snippet: c.text.slice(0, 200) };
    });
  return {
    answer: filterMarkers(parsed.answer, valid),
    citations,
    grounded: parsed.grounded && citations.length > 0,
    model,
    cached: false,
  };
}

/** Fixed answer when retrieval finds nothing (no LLM call). */
export function notFound(lang: Lang, model: string): AskResponse {
  const answer =
    lang === 'bn'
      ? 'FlameSense-এর NASA নথিতে এই প্রশ্নের উত্তর পাওয়া যায়নি। মাইক্রোগ্র্যাভিটিতে শিখার আকার বা বায়ুপ্রবাহ নিয়ে প্রশ্ন করে দেখুন।'
      : "FlameSense's NASA documents don't cover this question. Try asking about flame shape or airflow in microgravity.";
  return { answer, citations: [], grounded: false, model, cached: false };
}
