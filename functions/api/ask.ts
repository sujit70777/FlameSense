/**
 * Ask FlameSense API endpoint: BM25 retrieval over NASA documents + the Anthropic Messages API.
 */

import type { Corpus } from '../lib/bm25';
import { handleAsk, type AskEnv } from '../lib/handler';

interface Env extends AskEnv {
  ASSETS: Fetcher;
}

/** Handles every method so OPTIONS gets CORS and others get 405. */
export const onRequest: PagesFunction<Env> = (context) =>
  handleAsk(context.request, context.env, {
    loadCorpus: async () => {
      const res = await context.env.ASSETS.fetch(new URL('/data/corpus_chunks.json', context.request.url));
      if (!res.ok) throw new Error(`corpus ${res.status}`);
      return (await res.json()) as Corpus;
    },
  });
