/**
 * Catch-all for /api/* paths that have no function: answers JSON 404 so an API caller
 * never receives the SPA's index.html (PLAN.md §1.0 Hosting).
 */

/** Any method on an unknown /api/* path → JSON 404. */
export const onRequest: PagesFunction = () =>
  new Response(JSON.stringify({ error: 'not_found' }), {
    status: 404,
    headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' },
  });
