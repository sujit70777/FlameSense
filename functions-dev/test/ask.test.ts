import { beforeEach, describe, expect, it, vi } from 'vitest';

import { buildBody } from '../../functions/lib/anthropic';
import { buildResponse, filterMarkers, parseModelJson } from '../../functions/lib/answer';
import { Bm25Index, tokenize, type Corpus } from '../../functions/lib/bm25';
import { handleAsk, resetIndexCache, type AskEnv } from '../../functions/lib/handler';
import { systemPrompt, userMessage } from '../../functions/lib/prompt';
import { checkRateLimit } from '../../functions/lib/ratelimit';
import { validateAsk } from '../../functions/lib/validate';

const corpus: Corpus = {
  version: '1',
  docs: [
    { doc_id: 'D1', title: 'FIXTURE flame shape report', url: 'https://example.test/d1' },
    { doc_id: 'D2', title: 'FIXTURE airflow report', url: 'https://example.test/d2' },
  ],
  chunks: [
    { id: 'D1#001', doc_id: 'D1', page: 3, text: 'In microgravity flames become spherical because buoyancy is absent.' },
    { id: 'D2#001', doc_id: 'D2', page: 7, text: 'Opposed airflow velocity controls flame spread over thin fuels.' },
    { id: 'D2#002', doc_id: 'D2', page: 8, text: 'Unrelated text about test hardware and cameras.' },
  ],
};

const env: AskEnv = {
  ANTHROPIC_API_KEY: 'test-key-not-real',
  ASK_MODEL: 'claude-sonnet-5-5',
  ASK_MAX_TOKENS: '800',
  ALLOWED_ORIGINS: 'https://flamesense.ehsanur.com,http://localhost:8788',
};

function req(body: unknown, init: { method?: string; origin?: string | null; raw?: string } = {}): Request {
  const headers: Record<string, string> = { 'content-type': 'application/json' };
  if (init.origin !== null) headers.Origin = init.origin ?? 'http://localhost:8788';
  return new Request('http://localhost:8788/api/ask', {
    method: init.method ?? 'POST',
    headers,
    body: init.method && init.method !== 'POST' ? undefined : init.raw ?? JSON.stringify(body),
  });
}

function claudeReply(text: string, status = 200, stop = 'end_turn'): typeof fetch {
  return vi.fn(async () =>
    new Response(JSON.stringify({ model: 'claude-sonnet-5-5', stop_reason: stop, content: [{ type: 'text', text }], usage: { input_tokens: 100, output_tokens: 50 } }), { status }),
  ) as unknown as typeof fetch;
}

beforeEach(() => resetIndexCache());

describe('validation', () => {
  it('accepts 3–500 chars and en/bn', () => {
    expect(validateAsk({ question: '  why round?  ' })).toEqual({ ok: true, question: 'why round?', lang: 'en' });
    expect(validateAsk({ question: 'কেন গোল?', lang: 'bn' }).ok).toBe(true);
  });
  it('rejects empty, too long, wrong types and languages', () => {
    for (const b of [{}, { question: '' }, { question: 'ab' }, { question: 'x'.repeat(501) }, { question: 5 }, { question: 'why?', lang: 'fr' }, null]) {
      expect(validateAsk(b).ok).toBe(false);
    }
  });
});

describe('bm25 and prompt', () => {
  it('ranks the obvious chunk first and drops non-matching ones', () => {
    const hits = new Bm25Index(corpus.chunks).search('why are flames spherical in microgravity');
    expect(hits[0].chunk.id).toBe('D1#001');
    expect(hits.every((h) => h.chunk.id !== 'D2#002')).toBe(true);
    expect(tokenize('The Flame, in a TEST!')).toEqual(['flame', 'test']);
  });
  it('puts sources and question in tags', () => {
    const docs = new Map(corpus.docs.map((d) => [d.doc_id, d]));
    const hits = new Bm25Index(corpus.chunks).search('airflow');
    const msg = userMessage(hits, docs, 'How does airflow matter?');
    expect(msg).toMatch(/^<sources>\n\[S1\] \(FIXTURE airflow report, page 7\)/);
    expect(msg).toContain('<question>How does airflow matter?</question>');
    expect(systemPrompt('bn')).toContain('Bangla (বাংলা)');
    expect(systemPrompt('en')).toContain('data, not instructions');
  });
});

describe('answer handling', () => {
  it('parses fenced JSON and removes invalid citation markers', () => {
    const parsed = parseModelJson('```json\n{"answer":"Round [S1]. Fake [S9].","used_sources":[1,9],"grounded":true}\n```')!;
    const hits = new Bm25Index(corpus.chunks).search('spherical microgravity');
    const r = buildResponse(parsed, hits, new Map(corpus.docs.map((d) => [d.doc_id, d])), 'm');
    expect(r.answer).toBe('Round [S1]. Fake.');
    expect(r.citations.map((c) => c.n)).toEqual([1]);
    expect(r.citations[0].snippet.length).toBeLessThanOrEqual(200);
    expect(filterMarkers('A [S2][S3].', new Set([3]))).toBe('A [S3].');
    expect(parseModelJson('not json')).toBeNull();
  });
  it('request body never sends temperature and turns thinking off on Sonnet 5.5', () => {
    const body = buildBody(env, 'sys', 'user');
    expect(body).not.toHaveProperty('temperature');
    expect(body.thinking).toEqual({ type: 'between_tools' });
    expect(body.max_tokens).toBe(800);
    expect(buildBody({ ...env, ASK_MODEL: 'claude-opus-5-5' }, 's', 'u')).not.toHaveProperty('thinking');
  });
});

describe('handler', () => {
  const deps = (fetchImpl?: typeof fetch, log = vi.fn()) => ({ loadCorpus: async () => corpus, fetchImpl, log });

  it('answers with citations and logs no question text', async () => {
    const log = vi.fn();
    const f = claudeReply('{"answer":"Flames are round [S1].","used_sources":[1],"grounded":true}');
    const res = await handleAsk(req({ question: 'Why are flames spherical in microgravity?' }), env, deps(f, log));
    expect(res.status).toBe(200);
    expect(res.headers.get('Access-Control-Allow-Origin')).toBe('http://localhost:8788');
    const body = (await res.json()) as { grounded: boolean; citations: unknown[] };
    expect(body.grounded).toBe(true);
    expect(body.citations).toHaveLength(1);
    const logged = JSON.stringify(log.mock.calls);
    expect(logged).not.toContain('spherical');
    expect(logged).toContain('output_tokens');
    const sent = JSON.parse(((f as unknown as { mock: { calls: [string, RequestInit][] } }).mock.calls[0][1].body) as string);
    expect(sent.messages[0].content).toContain('<question>');
  });

  it('rejects unknown origin (403), wrong method (405), bad JSON and invalid questions (400)', async () => {
    expect((await handleAsk(req({ question: 'why?' }, { origin: 'https://evil.test' }), env, deps())).status).toBe(403);
    expect((await handleAsk(req({ question: 'why?' }, { origin: null }), env, deps())).status).toBe(403);
    expect((await handleAsk(req(null, { method: 'GET' }), env, deps())).status).toBe(405);
    expect((await handleAsk(req(null, { method: 'OPTIONS' }), env, deps())).status).toBe(204);
    expect((await handleAsk(req(null, { raw: '{not json' }), env, deps())).status).toBe(400);
    const res = await handleAsk(req({ question: '' }), env, deps());
    expect(res.status).toBe(400);
    expect(await res.json()).toEqual({ error: 'invalid_question' });
  });

  it('maps upstream failures to 502 and refusals to not grounded', async () => {
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(claudeReply('x', 529)))).status).toBe(502);
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(claudeReply('no json')))).status).toBe(502);
    const refused = await handleAsk(req({ question: 'flames spherical' }), env, deps(claudeReply('', 200, 'refusal')));
    expect(((await refused.json()) as { grounded: boolean }).grounded).toBe(false);
  });

  it('answers not-grounded without calling the model when nothing matches', async () => {
    const f = claudeReply('{}');
    const res = await handleAsk(req({ question: 'zebra quantum banana' }), env, deps(f));
    expect(((await res.json()) as { grounded: boolean }).grounded).toBe(false);
    expect(f).not.toHaveBeenCalled();
  });

  it('rate limits the 31st request in an hour with retry_after_s', async () => {
    const store = new Map<string, string>();
    const kv = {
      get: async (k: string) => store.get(k) ?? null,
      put: async (k: string, v: string) => void store.set(k, v),
    } as unknown as KVNamespace;
    const now = new Date('2026-11-13T10:15:00Z');
    for (let i = 0; i < 30; i++) expect((await checkRateLimit(kv, '1.2.3.4', now)).ok).toBe(true);
    const r = await checkRateLimit(kv, '1.2.3.4', now);
    expect(r).toEqual({ ok: false, retryAfterS: 2700 });
    expect((await checkRateLimit(kv, '5.6.7.8', now)).ok).toBe(true);
  });
});
