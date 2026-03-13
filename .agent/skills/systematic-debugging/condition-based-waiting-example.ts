/**
 * Condition-Based Waiting — TypeScript Reference Implementation
 *
 * Replaces arbitrary sleep/timeout patterns with condition-based alternatives.
 * See: systematic-debugging/condition-based-waiting.md
 */

// ────────────────────────────────────────
// 1. Polling Wait
// ────────────────────────────────────────

interface WaitOptions {
  timeout?: number;
  interval?: number;
  message?: string;
}

async function waitFor(
  condition: () => boolean | Promise<boolean>,
  options: WaitOptions = {}
): Promise<void> {
  const { timeout = 5000, interval = 100, message = "Condition not met" } =
    options;
  const start = Date.now();

  while (Date.now() - start < timeout) {
    if (await condition()) return;
    await new Promise((r) => setTimeout(r, interval));
  }

  throw new Error(`${message} within ${timeout}ms`);
}

// Usage:
// await waitFor(() => document.querySelector('.loaded') !== null, {
//   timeout: 10000,
//   message: 'Element .loaded did not appear'
// });

// ────────────────────────────────────────
// 2. Event-Based Wait
// ────────────────────────────────────────

import { EventEmitter } from "events";

async function waitForEvent(
  emitter: EventEmitter,
  event: string,
  timeout = 5000
): Promise<unknown> {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(
      () => reject(new Error(`Event '${event}' not received within ${timeout}ms`)),
      timeout
    );

    emitter.once(event, (data) => {
      clearTimeout(timer);
      resolve(data);
    });
  });
}

// Usage:
// const data = await waitForEvent(dbConnection, 'connected', 10000);

// ────────────────────────────────────────
// 3. State-Based Wait (for API/HTTP)
// ────────────────────────────────────────

interface PollApiOptions {
  url: string;
  checkFn: (response: unknown) => boolean;
  timeout?: number;
  interval?: number;
  headers?: Record<string, string>;
}

async function pollApi(options: PollApiOptions): Promise<unknown> {
  const { url, checkFn, timeout = 30000, interval = 1000, headers = {} } =
    options;
  const start = Date.now();

  while (Date.now() - start < timeout) {
    try {
      const response = await fetch(url, { headers });
      const data = await response.json();

      if (checkFn(data)) return data;
    } catch {
      // Request failed, retry
    }

    await new Promise((r) => setTimeout(r, interval));
  }

  throw new Error(`API condition not met at ${url} within ${timeout}ms`);
}

// Usage:
// const result = await pollApi({
//   url: '/api/jobs/123',
//   checkFn: (data: any) => data.status === 'completed',
//   timeout: 60000,
//   interval: 2000,
// });

// ────────────────────────────────────────
// 4. Database Ready Wait
// ────────────────────────────────────────

async function waitForDatabase(
  connectionFn: () => Promise<boolean>,
  options: WaitOptions = {}
): Promise<void> {
  const { timeout = 30000, interval = 1000 } = options;

  await waitFor(
    async () => {
      try {
        return await connectionFn();
      } catch {
        return false;
      }
    },
    {
      timeout,
      interval,
      message: "Database connection not ready",
    }
  );
}

// Usage:
// await waitForDatabase(async () => {
//   const result = await db.query('SELECT 1');
//   return result.rowCount > 0;
// });

export { waitFor, waitForEvent, pollApi, waitForDatabase };
export type { WaitOptions, PollApiOptions };
