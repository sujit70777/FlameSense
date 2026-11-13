import { beforeEach, describe, expect, it, vi } from 'vitest';

import { onRequest as apiCatchAll } from '../../functions/api/[[path]]';
import { buildBody, DEFAULT_RETRY_S } from '../../functions/lib/gemini';
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
  GEMINI_API_KEY: 'test-key-not-real',
  ASK_MODEL: 'gemini-flash-latest',
  ASK_MAX_TOKENS: '2048',
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

function modelReply(text: string, status = 200, finish = 'STOP'): typeof fetch {
  return vi.fn(async () =>
    new Response(
      JSON.stringify({
        modelVersion: 'gemini-flash-latest',
        candidates: [{ content: { parts: [{ text: 'thinking...', thought: true }, { text }] }, finishReason: finish }],
        usageMetadata: { promptTokenCount: 100, candidatesTokenCount: 50 },
      }),
      { status },
    ),
  ) as unknown as typeof fetch;
}

/** Google's 429/503 shape, optionally with a RetryInfo delay. */
function busyReply(status: number, retryDelay?: string): typeof fetch {
  const details = retryDelay ? [{ '@type': 'type.googleapis.com/google.rpc.RetryInfo', retryDelay }] : [];
  return vi.fn(async () =>
    new Response(JSON.stringify({ error: { code: status, details } }), { status }),
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
    expect(filterMarkers('B[ S3] and [S 3 ].', new Set([3]))).toBe('B[S3] and [S3].');
    expect(parseModelJson('not json')).toBeNull();
  });
  it('request body asks Gemini for JSON with the system prompt separate', () => {
    const body = buildBody(env, 'sys', 'user') as {
      systemInstruction: { parts: { text: string }[] };
      contents: { role: string; parts: { text: string }[] }[];
      generationConfig: { maxOutputTokens: number; responseMimeType: string };
    };
    expect(body.systemInstruction.parts[0].text).toBe('sys');
    expect(body.contents[0]).toEqual({ role: 'user', parts: [{ text: 'user' }] });
    expect(body.generationConfig).toEqual({ maxOutputTokens: 2048, responseMimeType: 'application/json' });
  });
});

describe('handler', () => {
  const deps = (fetchImpl?: typeof fetch, log = vi.fn()) => ({ loadCorpus: async () => corpus, fetchImpl, log });

  it('answers with citations and logs no question text', async () => {
    const log = vi.fn();
    const f = modelReply('{"answer":"Flames are round [S1].","used_sources":[1],"grounded":true}');
    const res = await handleAsk(req({ question: 'Why are flames spherical in microgravity?' }), env, deps(f, log));
    expect(res.status).toBe(200);
    expect(res.headers.get('Access-Control-Allow-Origin')).toBe('http://localhost:8788');
    const body = (await res.json()) as { grounded: boolean; citations: unknown[] };
    expect(body.grounded).toBe(true);
    expect(body.citations).toHaveLength(1);
    const logged = JSON.stringify(log.mock.calls);
    expect(logged).not.toContain('spherical');
    expect(logged).toContain('output_tokens');
    const call = (f as unknown as { mock: { calls: [string, RequestInit][] } }).mock.calls[0];
    expect(call[0]).toContain('/models/gemini-flash-latest:generateContent');
    expect((call[1].headers as Record<string, string>)['x-goog-api-key']).toBe('test-key-not-real');
    const sent = JSON.parse(call[1].body as string);
    expect(sent.contents[0].parts[0].text).toContain('<question>');
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

  it('maps upstream failures to 502 and safety blocks to not grounded', async () => {
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(modelReply('x', 500)))).status).toBe(502);
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(modelReply('no json')))).status).toBe(502);
    const refused = await handleAsk(req({ question: 'flames spherical' }), env, deps(modelReply('', 200, 'SAFETY')));
    expect(((await refused.json()) as { grounded: boolean }).grounded).toBe(false);
  });

  it('free quota used up (429) or model busy (503) → 429 with how long to wait', async () => {
    const quota = await handleAsk(req({ question: 'flames spherical' }), env, deps(busyReply(429, '37.2s')));
    expect(quota.status).toBe(429);
    expect(await quota.json()).toEqual({ error: 'upstream_busy', retry_after_s: 38 });
    const busy = await handleAsk(req({ question: 'flames spherical' }), env, deps(busyReply(503)));
    expect(busy.status).toBe(429);
    expect(await busy.json()).toEqual({ error: 'upstream_busy', retry_after_s: DEFAULT_RETRY_S });
    const empty404 = vi.fn(async () => new Response('', { status: 404 })) as unknown as typeof fetch;
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(empty404))).status).toBe(429);
    const real404 = vi.fn(async () => new Response('{"error":{"code":404}}', { status: 404 })) as unknown as typeof fetch;
    expect((await handleAsk(req({ question: 'flames spherical' }), env, deps(real404))).status).toBe(502);
  });

  it('falls back to Groq when Gemini is out of quota, and reports the shorter wait when both are', async () => {
    const both = { ...env, GROQ_API_KEY: 'groq-test-not-real' };
    const groqOk = JSON.stringify({
      model: 'openai/gpt-oss-120b',
      choices: [{ message: { content: '{"answer":"Round [S1].","used_sources":[1],"grounded":true}' }, finish_reason: 'stop' }],
      usage: { prompt_tokens: 10, completion_tokens: 5 },
    });
    const f = vi.fn(async (url: string) =>
      url.includes('groq.com')
        ? new Response(groqOk, { status: 200 })
        : new Response(JSON.stringify({ error: { code: 429 } }), { status: 429 }),
    ) as unknown as typeof fetch;
    const res = await handleAsk(req({ question: 'flames spherical' }), both, deps(f));
    expect(res.status).toBe(200);
    expect(((await res.json()) as { model: string }).model).toBe('openai/gpt-oss-120b');
    const calls = (f as unknown as { mock: { calls: [string, RequestInit][] } }).mock.calls;
    expect(calls[1][0]).toContain('api.groq.com');
    expect((calls[1][1].headers as Record<string, string>).authorization).toBe('Bearer groq-test-not-real');
    expect(JSON.parse(calls[1][1].body as string).response_format).toEqual({ type: 'json_object' });
    const busy = vi.fn(async (url: string) =>
      url.includes('groq.com')
        ? new Response('{}', { status: 429, headers: { 'retry-after': '7' } })
        : new Response(JSON.stringify({ error: { details: [{ '@type': 'x.RetryInfo', retryDelay: '40s' }] } }), { status: 429 }),
    ) as unknown as typeof fetch;
    const r2 = await handleAsk(req({ question: 'flames spherical' }), both, deps(busy));
    expect(await r2.json()).toEqual({ error: 'upstream_busy', retry_after_s: 7 });
    const onlyGroq = await handleAsk(req({ question: 'flames spherical' }), { ...both, GEMINI_API_KEY: '' }, deps(f));
    expect(onlyGroq.status).toBe(200);
  });

  it('returns JSON 503 without calling the model when the API key is not configured', async () => {
    const f = modelReply('{}');
    const res = await handleAsk(req({ question: 'flames spherical' }), { ...env, GEMINI_API_KEY: '' }, deps(f));
    expect(res.status).toBe(503);
    expect(res.headers.get('content-type')).toContain('application/json');
    expect(await res.json()).toEqual({ error: 'unavailable' });
    expect(f).not.toHaveBeenCalled();
  });

  it('every handler response is JSON (never the SPA HTML), including errors', async () => {
    const cases = [
      handleAsk(req({ question: 'why?' }, { origin: 'https://evil.test' }), env, deps()),
      handleAsk(req(null, { method: 'GET' }), env, deps()),
      handleAsk(req({ question: '' }), env, deps()),
      handleAsk(req({ question: 'flames spherical' }), env, deps(modelReply('x', 500))),
      handleAsk(req({ question: 'flames spherical' }), env, { loadCorpus: async () => { throw new Error('boom'); }, log: vi.fn() }),
    ];
    for (const res of await Promise.all(cases)) {
      expect(res.headers.get('content-type')).toContain('application/json');
    }
  });

  it('unknown /api/* paths answer JSON 404', async () => {
    const ctx = { request: new Request('http://localhost:8788/api/nope') } as unknown as Parameters<typeof apiCatchAll>[0];
    const res = await apiCatchAll(ctx);
    expect(res.status).toBe(404);
    expect(res.headers.get('content-type')).toContain('application/json');
    expect(await res.json()).toEqual({ error: 'not_found' });
  });

  it('answers not-grounded without calling the model when nothing matches', async () => {
    const f = modelReply('{}');
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
