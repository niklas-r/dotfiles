# Backend Review Lenses (Node)

Apply to Node services, APIs, jobs, and shared server code.

## Correctness and control flow

- Every `await` sits inside a path that handles rejection. No floating promises, no `async` callbacks passed where the caller ignores the returned promise.
- `Promise.all` vs `allSettled`: one rejection must not silently drop the other results when partial success matters.
- Loops with `await` inside: intentional serialization, or an accidental N+1?
- Early returns after `res.send`/`reply` — no double-send, no continued execution after responding.
- Unhandled `EventEmitter` `error` events, and stream errors that bypass `try/catch`.

## Errors and resilience

- Errors are typed or wrapped, not swallowed by bare `catch {}` or `catch (e) { console.log(e) }`.
- Client errors (4xx) vs server errors (5xx) are distinguished; internal messages and stack traces do not leak to the client.
- Timeouts, retries, and backoff on outbound calls. Retries must be safe (idempotent) or guarded by an idempotency key.
- Graceful shutdown: in-flight requests drained, intervals and DB pools closed on `SIGTERM`.

## Security

- Input validated and parsed at the boundary (zod/valibot/joi) before use, including query params, headers, and webhooks.
- AuthN separate from AuthZ: presence of a session is not permission. Check ownership/tenant on every resource lookup, not just the route.
- Injection: parameterized SQL, no string-built queries, no unsanitized `$where`/`$expr`, no shell interpolation in `exec`.
- Secrets from env/secret manager, never committed or logged. No secrets, tokens, PII, or full request bodies in logs.
- Mass assignment: request bodies are allow-listed before hitting an ORM create/update.
- Path traversal on any user-controlled filename; SSRF on any user-supplied URL.
- Rate limiting and body size limits on public endpoints.

## Data and persistence

- Multi-write operations run in a transaction with the correct isolation; no partial-write windows.
- N+1 queries from ORM lazy loading in loops or resolvers.
- Indexes exist for new query predicates and sorts.
- Migrations are backward compatible with the currently deployed code (expand/contract), reversible, and safe on large tables (no blocking rewrite, no unguarded `NOT NULL` add).
- Pagination is bounded; no unbounded `findMany` on user-facing endpoints.
- Race conditions on read-modify-write; prefer atomic updates, optimistic locking, or unique constraints over check-then-act.

## API contracts

- Breaking response or request changes for existing clients; versioning or a deprecation path.
- Status codes, error shapes, and nullability match the documented contract and generated types.
- Serialization boundary: internal fields (password hashes, internal ids, soft-delete flags) are not exposed.

## Async work and concurrency

- Background jobs are idempotent and survive redelivery; failures are retried and eventually dead-lettered.
- Nothing important is fired-and-forgotten after the response returns in a serverless or autoscaled context.
- No shared mutable module-level state that breaks under concurrency or across warm invocations.
- Cache keys include every input that changes the result, including tenant and locale; invalidation matches write paths; TTL is justified.

## Performance and resources

- Blocking the event loop: sync fs calls, large `JSON.parse`, crypto, or heavy loops on the request path.
- Unbounded memory: full-table reads, buffering large uploads, growing maps without eviction.
- Streams used for large payloads, with backpressure respected.
- Connection pools sized and reused rather than created per request.

## Observability

- New failure modes are logged with enough context to debug, using structured logging and a correlation id.
- Log levels are appropriate; no high-cardinality or per-item logging on hot paths.

## Testing

- New branches, error paths, and authorization checks are covered — not just the happy path.
- Tests assert behavior, not implementation. No unforced real network, real clock, or real sleep.
