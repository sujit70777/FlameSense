/**
 * BM25 retrieval over corpus chunks (PLAN.md Phase 12 step 4): k1 = 1.2, b = 0.75.
 */

export interface CorpusDoc {
  doc_id: string;
  title: string;
  url: string;
  year?: number;
  license_note?: string;
}

export interface CorpusChunk {
  id: string;
  doc_id: string;
  page: number;
  text: string;
}

export interface Corpus {
  version: string;
  docs: CorpusDoc[];
  chunks: CorpusChunk[];
}

const STOPWORDS = new Set(
  ('a about above after again against all am an and any are as at be because been before being below ' +
    'between both but by can could did do does doing down during each few for from further had has have ' +
    'having he her here hers herself him himself his how i if in into is it its itself just me more most ' +
    'my myself no nor not now of off on once only or other our ours ourselves out over own same she should ' +
    'so some such than that the their theirs them themselves then there these they this those through to ' +
    'too under until up very was we were what when where which while who whom why will with would you your ' +
    'yours yourself yourselves').split(' '),
);

/** Lowercase, split on non-letters/digits, drop tokens < 2 chars and stopwords. */
export function tokenize(text: string): string[] {
  return text
    .toLowerCase()
    .split(/[^\p{L}\p{N}]+/u)
    .filter((t) => t.length >= 2 && !STOPWORDS.has(t));
}

export interface ScoredChunk {
  chunk: CorpusChunk;
  score: number;
}

/** In-memory BM25 index. */
export class Bm25Index {
  private readonly tf: Map<string, number>[];
  private readonly lengths: number[];
  private readonly df = new Map<string, number>();
  private readonly avgLen: number;

  /** Builds the index over [chunks]. */
  constructor(readonly chunks: CorpusChunk[], private readonly k1 = 1.2, private readonly b = 0.75) {
    this.tf = chunks.map((c) => {
      const m = new Map<string, number>();
      for (const t of tokenize(c.text)) m.set(t, (m.get(t) ?? 0) + 1);
      for (const t of m.keys()) this.df.set(t, (this.df.get(t) ?? 0) + 1);
      return m;
    });
    this.lengths = this.tf.map((m) => [...m.values()].reduce((a, v) => a + v, 0));
    this.avgLen = this.lengths.reduce((a, v) => a + v, 0) / Math.max(1, chunks.length);
  }

  /** Top [k] chunks for [query], dropping chunks scoring below [minRatio] × the top score. */
  search(query: string, k = 6, minRatio = 0.15): ScoredChunk[] {
    const terms = [...new Set(tokenize(query))];
    const n = this.chunks.length;
    const scored: ScoredChunk[] = [];
    for (let i = 0; i < n; i++) {
      let s = 0;
      for (const t of terms) {
        const f = this.tf[i].get(t);
        if (!f) continue;
        const df = this.df.get(t) ?? 0;
        const idf = Math.log(1 + (n - df + 0.5) / (df + 0.5));
        s += (idf * f * (this.k1 + 1)) / (f + this.k1 * (1 - this.b + (this.b * this.lengths[i]) / this.avgLen));
      }
      if (s > 0) scored.push({ chunk: this.chunks[i], score: s });
    }
    scored.sort((a, b) => b.score - a.score || a.chunk.id.localeCompare(b.chunk.id));
    const top = scored[0]?.score ?? 0;
    return scored.slice(0, k).filter((c) => c.score >= minRatio * top);
  }
}
