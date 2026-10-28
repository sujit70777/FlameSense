/**
 * Ask request handling with injectable dependencies (tested without the Workers runtime).
 */

import { callClaude, type ClaudeEnv } from './anthropic';
import { buildResponse, notFound, parseModelJson } from './answer';
import { Bm25Index, type Corpus, type CorpusDoc } from './bm25';
import { systemPrompt, userMessage } from './prompt';
import { checkRateLimit } from './ratelimit';
import { validateAsk } from './validate';

export interface AskEnv extends ClaudeEnv {
  ALLOWED_ORIGINS: string;
  RATE_KV?: KVNamespace;
}

export interface Deps {
  loadCorpus: () => Promise<Corpus>;
  fetchImpl?: typeof fetch;
  now?: () => number;
  log?: (entry: Record<string, unknown>) => void;
}

let cache: { index: Bm25Index; docs: Map<string, CorpusDoc> } | null = null;

/** Clears the module-level index (tests). */
export function resetIndexCache(): void {
  cache = null;
}

/** CORS headers when [origin] is allowed (listed, or same origin as the request), else null. */
export function corsHeaders(origin: string | null, requestUrl: string, allowed: string): Record<string, string> | null {
  if (!origin) return null;
  const list = allowed.split(',').map((s) => s.trim()).filter(Boolean);
  if (!list.includes(origin) && origin !== new URL(requestUrl).origin) return null;
  return {
    'Access-Control-Allow-Origin': origin,
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'content-type',
    Vary: 'Origin',
  };
}

function json(status: number, body: unknown, headers: Record<string, string> = {}): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store', ...headers },
  });
}

/** Full POST /api/ask flow. Logs only status, latency and token usage (never question or IP). */
export async function handleAsk(request: Request, env: AskEnv, deps: Deps): Promise<Response> {
  const started = (deps.now ?? Date.now)();
  const log = deps.log ?? ((e) => console.log(JSON.stringify(e)));
  const done = (res: Response, tokens: Record<string, number> = {}) => {
    log({ status: res.status, latency_ms: (deps.now ?? Date.now)() - started, ...tokens });
    return res;
  };
  const cors = corsHeaders(request.headers.get('Origin'), request.url, env.ALLOWED_ORIGINS);
  if (!cors) return done(json(403, { error: 'forbidden_origin' }));
  if (request.method === 'OPTIONS') return done(new Response(null, { status: 204, headers: cors }));
  if (request.method !== 'POST') return done(json(405, { error: 'method_not_allowed' }, { ...cors, Allow: 'POST, OPTIONS' }));
  let body: unknown;
  try {
    body = await request.json();
  } catch {
    return done(json(400, { error: 'invalid_question' }, cors));
  }
  const q = validateAsk(body);
  if (!q.ok) return done(json(400, { error: 'invalid_question' }, cors));
  const rl = await checkRateLimit(env.RATE_KV, request.headers.get('CF-Connecting-IP') ?? 'unknown');
  if (!rl.ok) return done(json(429, { error: 'rate_limited', retry_after_s: rl.retryAfterS }, cors));
  try {
    if (!cache) {
      const corpus = await deps.loadCorpus();
      cache = { index: new Bm25Index(corpus.chunks), docs: new Map(corpus.docs.map((d) => [d.doc_id, d])) };
    }
    const chunks = cache.index.search(q.question);
    if (chunks.length === 0) return done(json(200, notFound(q.lang, env.ASK_MODEL), cors));
    const result = await callClaude(env, systemPrompt(q.lang), userMessage(chunks, cache.docs, q.question), deps.fetchImpl);
    const tokens = { input_tokens: result.inputTokens, output_tokens: result.outputTokens };
    if (!result.ok) return done(json(502, { error: 'upstream' }, cors), tokens);
    if (result.stopReason === 'refusal') return done(json(200, notFound(q.lang, result.model), cors), tokens);
    const parsed = parseModelJson(result.text);
    if (!parsed) return done(json(502, { error: 'upstream' }, cors), tokens);
    return done(json(200, buildResponse(parsed, chunks, cache.docs, result.model), cors), tokens);
  } catch {
    return done(json(500, { error: 'server' }, cors));
  }
}
