/**
 * Ask FlameSense API endpoint — answers questions using BM25 retrieval + LLM.
 */

interface Env {
  ASK_MODEL: string;
  ASK_MAX_TOKENS: string;
  ALLOWED_ORIGINS: string;
  ANTHROPIC_API_KEY: string;
}

export const onRequestPost: PagesFunction<Env> = async (context) => {
  return new Response(
    JSON.stringify({ error: 'not_implemented' }),
    {
      status: 501,
      headers: { 'Content-Type': 'application/json' },
    }
  );
};
