// Smoke test (PLAN.md Phase 15 step 2). Usage: node scripts/smoke.mjs <base-url> [--expect-citations]
// Checks every route's title and one semantics label, a keyboard step on the Lab oxygen slider,
// the first suggested Ask question, the 404 page, no console errors, and no third-party requests.
import { chromium } from 'playwright';

const base = (process.argv[2] ?? 'http://localhost:8788').replace(/\/$/, '');
const expectCitations = process.argv.includes('--expect-citations');
const origin = new URL(base).origin;

const routes = [
  ['/', /FlameSense: fire safety insights/, 'Fire has no'],
  ['/missions', /Plan for a mission \| FlameSense/, 'Plan for a mission'],
  ['/explore', /Explore the experiments \| FlameSense/, 'Explore the experiments'],
  ['/lab', /Fire Lab \| FlameSense/, 'Conditions'],
  ['/map', /Flammability map \| FlameSense/, 'Flammability map'],
  ['/ask', /Ask the NASA papers \| FlameSense/, 'Suggested questions'],
  ['/earth', /Lessons for Earth \| FlameSense/, 'Lessons for Earth'],
  ['/methods', /Methods \| FlameSense/, 'Where the data comes from'],
  ['/about', /About \| FlameSense/, 'Not affiliated with or endorsed by NASA'],
];

const failures = [];
const fail = (m) => { failures.push(m); console.error('FAIL', m); };

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

for (const [path, title, text] of routes) {
  await open(path);
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

// Ask: first suggested question returns an answer (with a citation once the corpus exists).
await open('/ask');
await label('Why are flames round in microgravity?').click();
await page.waitForTimeout(expectCitations ? 15000 : 4000);
const grounded = await label('Answered from NASA sources').count();
const notGrounded = await label("Not found in FlameSense's NASA sources").count();
if (expectCitations && !(grounded && (await label('Source 1').count()))) fail('ask: no grounded answer with a citation');
if (!expectCitations && !(grounded || notGrounded)) fail('ask: no answer status shown');
else console.log('ok ask', grounded ? 'grounded' : 'not grounded');

await open('/nope');
if (!(await label('This page drifted off').count())) fail('/nope: not-found page missing');
else console.log('ok 404');

await browser.close();
if (consoleErrors.length) fail(`console errors:\n  ${consoleErrors.join('\n  ')}`);
if (foreign.size) fail(`third-party requests: ${[...foreign].join(', ')}`);
console.log(failures.length ? `\n${failures.length} failure(s)` : '\nSmoke test passed');
process.exit(failures.length ? 1 : 0);
