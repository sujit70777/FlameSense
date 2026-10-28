/**
 * Rate limiting using Cloudflare KV (PLAN.md Phase 12 step 3).
 * 30 questions per hour per IP, 2000 per day overall.
 */

export const PER_IP_PER_HOUR = 30;
export const GLOBAL_PER_DAY = 2000;

export type RateResult = { ok: true } | { ok: false; retryAfterS: number };

function stamp(d: Date, withHour: boolean): string {
  const p = (n: number) => String(n).padStart(2, '0');
  const day = `${d.getUTCFullYear()}${p(d.getUTCMonth() + 1)}${p(d.getUTCDate())}`;
  return withHour ? `${day}${p(d.getUTCHours())}` : day;
}

/** Counts one request; returns 429 info when the IP or global budget is used up. KV missing → allowed. */
export async function checkRateLimit(kv: KVNamespace | undefined, ip: string, now = new Date()): Promise<RateResult> {
  if (!kv) {
    console.warn('RATE_KV binding missing; rate limiting skipped (local dev)');
    return { ok: true };
  }
  const ipKey = `rl:${ip}:${stamp(now, true)}`;
  const allKey = `rl:all:${stamp(now, false)}`;
  const [ipCount, allCount] = await Promise.all([kv.get(ipKey), kv.get(allKey)]);
  const ipN = Number(ipCount ?? 0);
  const allN = Number(allCount ?? 0);
  if (ipN >= PER_IP_PER_HOUR) {
    return { ok: false, retryAfterS: 3600 - (now.getUTCMinutes() * 60 + now.getUTCSeconds()) };
  }
  if (allN >= GLOBAL_PER_DAY) {
    const secondsToday = now.getUTCHours() * 3600 + now.getUTCMinutes() * 60 + now.getUTCSeconds();
    return { ok: false, retryAfterS: 86400 - secondsToday };
  }
  await Promise.all([
    kv.put(ipKey, String(ipN + 1), { expirationTtl: 3600 }),
    kv.put(allKey, String(allN + 1), { expirationTtl: 86400 }),
  ]);
  return { ok: true };
}
