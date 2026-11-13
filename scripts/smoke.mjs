// Smoke test (PLAN.md Phase 15 step 2, Phase 16). Usage: node scripts/smoke.mjs <base-url> [--expect-citations]
// Checks every route's title and one semantics label, a keyboard step on the Lab oxygen slider,
// the first suggested Ask question, the 404 page, no console errors, and no third-party requests.
// Pages whose feature is not ready (app/lib/core/features.dart rules, computed here from the
// deployed assets) must be hidden: a deep link lands on Home and the nav has no entry for them.
// /api/* must always answer JSON (never the SPA's index.html), and Ask must never hang.
import { chromium } from 'playwright';

const base = (process.argv[2] ?? 'http://localhost:8788').replace(/\/$/, '');
const expectCitations = process.argv.includes('--expect-citations');
const origin = new URL(base).origin;

// [path, title, semantics text, feature (null = always on), nav label]
const routes = [
  ['/', /FlameSense: fire safety insights/, 'Fire has no', null],
  ['/missions', /Plan for a mission \| FlameSense/, 'Plan for a mission', 'missions', 'Missions'],
  ['/explore', /Explore the experiments \| FlameSense/, 'Explore the experiments', null],
  ['/lab', /Fire Lab \| FlameSense/, 'Conditions', null],
  ['/map', /Flammability map \| FlameSense/, 'Flammability map', null],
  ['/ask', /Ask the NASA papers \| FlameSense/, 'Suggested questions', 'ask', 'Ask'],
  ['/earth', /Lessons for Earth \| FlameSense/, 'Lessons for Earth', 'earth', 'Earth lessons'],
  ['/methods', /Methods \| FlameSense/, 'Where the data comes from', null],
  ['/about', /About \| FlameSense/, 'Not affiliated with or endorsed by NASA', null],
];

const failures = [];
const fail = (m) => { failures.push(m); console.error('FAIL', m); };

/** Deployed data file as JSON, or null when missing/invalid (the SPA answers HTML for missing files). */
async function asset(name) {
  try {
    const r = await fetch(`${base}/assets/assets/data/${name}`);
    return r.ok ? await r.json() : null;
  } catch {
    return null;
  }
}

// Same rules as FeatureRegistry.fromData for a release build.
const [missionsJson, lessonsJson, askCacheJson] = await Promise.all(
  ['missions.json', 'lessons.json', 'ask_cache.json'].map(asset),
);
const features = {
  missions: (missionsJson?.missions ?? []).some((m) => String(m.source ?? '').trim()),
  earth: (lessonsJson?.lessons ?? []).some(
    (l) => l.status === 'approved' && l.reviewed_by && (l.sources ?? []).some((s) => s.url),
  ),
  ask: Object.entries(askCacheJson ?? {}).some(([k, v]) => k.endsWith('_en') && v?.q_en),
};
console.log('features', JSON.stringify(features));

// /api/*: JSON for every outcome, never the SPA HTML. Node fetch, so nothing hits the page console.
async function api(path, init, expectStatus) {
  try {
    const r = await fetch(base + path, { ...init, headers: { Origin: origin, 'content-type': 'application/json', ...(init.headers ?? {}) } });
    const type = r.headers.get('content-type') ?? '';
    const body = await r.text();
    if (!type.includes('application/json')) fail(`api ${init.method ?? 'GET'} ${path}: ${r.status} ${type} (not JSON): ${body.slice(0, 60)}`);
    else if (expectStatus && !expectStatus.includes(r.status)) fail(`api ${path}: status ${r.status}, wanted ${expectStatus}`);
    else console.log('ok api', init.method ?? 'GET', path, r.status, body.slice(0, 80));
    return r.status;
  } catch (e) {
    fail(`api ${path}: ${e}`);
    return 0;
  }
}
const started = Date.now();
await api('/api/ask', { method: 'POST', body: JSON.stringify({ question: 'How is a candle flame in microgravity different from one on Earth?', lang: 'en' }) }, [200, 429, 502, 503]);
if (Date.now() - started > 35000) fail('api /api/ask took longer than 35 s');
await api('/api/ask', { method: 'GET' }, [405]);
await api('/api/ask', { method: 'POST', body: '{not json' }, [400]);
await api('/api/does-not-exist', { method: 'GET' }, [404]);

// Installed Google Chrome by default (FS_SMOKE_CHANNEL=chromium uses Playwright's own build).
const channel = process.env.FS_SMOKE_CHANNEL ?? 'chrome';
const browser = await chromium.launch(channel === 'chromium' ? {} : { channel });
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } });
const consoleErrors = [];
const foreign = new Set();
page.on('console', (m) => { if (m.type() === 'error') consoleErrors.push(m.text()); });
page.on('pageerror', (e) => consoleErrors.push(String(e)));
page.on('request', (r) => { const u = new URL(r.url()); if (!u.protocol.startsWith('data') && u.origin !== origin) foreign.add(u.origin); });

async function open(path) {
  await page.goto(base + path, { waitUntil: 'networkidle' });
  // Flutter renders semantics nodes into the DOM once the app (not the splash) is up.
  await page.waitForFunction(() => document.querySelectorAll('flt-semantics').length > 5, null, { timeout: 30000 });
  await page.waitForTimeout(800);
}

const label = (text) => page.locator(`[aria-label*="${text}" i], flt-semantics:has-text("${text}")`).first();

// Rail items are role=button semantics nodes whose name is their text (or aria-label).
const navLabel = (text) =>
  page.locator(`[role="button"][aria-label="${text}"], flt-semantics[role="button"]`).filter({ hasText: new RegExp(`^${text}$`) })
    .or(page.locator(`[role="button"][aria-label="${text}"]`));

for (const [path, title, text, feature, nav] of routes) {
  await open(path);
  if (feature && !features[feature]) {
    // Hidden feature: the deep link goes Home and nothing in the nav points at it.
    await page.waitForTimeout(500);
    const at = new URL(page.url()).pathname;
    if (at !== '/') fail(`${path}: feature "${feature}" is not ready but the page opened (${at})`);
    // Guard against a selector that matches nothing: an always-on rail item must be found.
    else if (!(await navLabel('Fire Lab').count())) fail(`${path}: nav check can't see the rail ("Fire Lab")`);
    else if (await navLabel(nav).count()) fail(`${path}: hidden feature still in nav ("${nav}")`);
    else console.log('ok hidden', path);
    continue;
  }
  const t = await page.title();
  if (!title.test(t)) fail(`${path}: title "${t}"`);
  if (!(await label(text).count())) fail(`${path}: no semantics label containing "${text}"`);
  else console.log('ok', path);
}

// Lab: move oxygen with the keyboard; the probability text (or the slider value when there's no model) changes.
await open('/lab');
// Flutter web puts the slider's name on its semantics node and the value on the inner range input.
const slider = page.locator('[aria-label="Oxygen"] [role="slider"], [role="slider"][aria-label*="Oxygen" i]').first();
if (!(await slider.count())) fail('lab: oxygen slider not found');
else {
  const before = (await slider.getAttribute('aria-valuetext')) ?? (await slider.getAttribute('aria-valuenow'));
  const gaugeBefore = await page.locator('[aria-label*="keeps burning" i]').first().getAttribute('aria-label').catch(() => null);
  await slider.focus();
  await page.keyboard.press('ArrowRight');
  await page.waitForTimeout(400);
  const after = (await slider.getAttribute('aria-valuetext')) ?? (await slider.getAttribute('aria-valuenow'));
  const gaugeAfter = await page.locator('[aria-label*="keeps burning" i]').first().getAttribute('aria-label').catch(() => null);
  if (before === after && gaugeBefore === gaugeAfter) fail('lab: keyboard step changed nothing');
  else console.log('ok lab keyboard', before, '→', after);
}

// Ask (only when the feature is ready): the first suggested question has a saved answer;
// a free-form question ends in an answer or a clear notice, never an endless spinner.
if (features.ask) {
  await open('/ask');
  await label('How is a candle flame in microgravity different from one on Earth?').click();
  await page.waitForTimeout(1500);
  const saved = await label('Saved answer').count();
  const grounded = await label('Answered from NASA sources').count();
  if (!saved) fail('ask: suggested question shows no saved answer');
  if (expectCitations && !(grounded && (await label('Source 1').count()))) fail('ask: no grounded answer with a citation');
  else console.log('ok ask saved', grounded ? 'grounded' : 'not grounded');
  const askStatuses = [];
  page.on('response', (r) => { if (r.url().includes('/api/ask')) askStatuses.push(r.status()); });
  // Flutter creates the real editable element only on focus: click the field, then type.
  await label('Your question').click({ force: true });
  await page.waitForTimeout(300);
  await page.keyboard.type('What happens to a candle flame in orbit?');
  await page.locator('flt-semantics[role="button"]').filter({ hasText: /^Ask$/ }).last().click();
  const settled = await page
    .waitForFunction(
      () => /Answered from NASA sources|Not found in FlameSense|Free-form questions aren't available|didn't respond|went wrong|Too many questions|busy or has reached|offline/i
        .test([...document.querySelectorAll('flt-semantics, [aria-label]')].map((n) => (n.getAttribute('aria-label') || n.textContent || '')).join(' ')),
      null,
      { timeout: 40000 },
    )
    .then(() => true, () => false);
  if (!settled) {
    const shot = `${process.env.TMPDIR ?? '/tmp'}/smoke_ask_fail.png`;
    await page.screenshot({ path: shot });
    fail(`ask: free-form question still waiting after 40 s (screenshot ${shot}, api ${askStatuses.join(',') || 'none'})`);
  }
  else console.log('ok ask free-form settled');
} else {
  console.log('skip ask UI (feature hidden: no saved answers shipped)');
}

await open('/nope');
if (!(await label('This page drifted off').count())) fail('/nope: not-found page missing');
else console.log('ok 404');

await browser.close();
if (consoleErrors.length) fail(`console errors:\n  ${consoleErrors.join('\n  ')}`);
if (foreign.size) fail(`third-party requests: ${[...foreign].join(', ')}`);
console.log(failures.length ? `\n${failures.length} failure(s)` : '\nSmoke test passed');
process.exit(failures.length ? 1 : 0);
