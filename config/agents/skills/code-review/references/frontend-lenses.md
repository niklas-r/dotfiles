# Frontend Review Lenses (React / TypeScript)

Apply to UI, rendering, state, and client-side data code.

## Correctness and regressions

- Changed branches still handle empty, loading, error, and success states.
- No stale assumptions left behind after prop, state, route, schema, or API changes.
- Derived state stays in sync with its source; no duplicated state that can diverge.

## React and rendering

- Stale closures in effects, callbacks, memoized values, and event handlers.
- Dependency arrays with missing or unstable values.
- Unnecessary remounts from unstable keys, index keys on reorderable lists, or component definitions created during render.
- Controlled vs uncontrolled input mismatches.
- Effects used for work that belongs in an event handler or during render.
- Suspense, transitions, and async rendering paths that hide broken states.

## TypeScript

- Type-safe narrowing over assertions. `any`, unsafe casts, and non-null assertions are risk multipliers unless justified.
- Widened types that hide invalid states; optional values used as if guaranteed.
- Public API and exported type changes checked for downstream breakage.

## Async and data flow

- Cancellation, race conditions, and out-of-order responses.
- Loading flags that can get stuck; error states that cannot be retried.
- Retries, optimistic updates, and cache invalidation match the intended behavior and roll back on failure.
- Error boundaries and fallback UI still make sense for the new failure modes.

## Security

- No `dangerouslySetInnerHTML` with unsanitized content; no user-controlled URLs in `href`/`src` without scheme checks.
- Secrets and server-only config are not bundled into client code.
- Tokens are not persisted anywhere the app does not control.

## Accessibility and UX

- Accessible names, roles, focus management, and keyboard access.
- ARIA relationships still correct after structural refactors.
- No duplicate announcements, hidden labels, or click-only interactions.
- Disabled, read-only, validation, and empty states remain understandable.

## Performance

- Re-render cascades from large lists or shared providers; context values recreated every render.
- Expensive work during render that should be memoized or moved.
- Virtualization, pagination, and image loading for large collections.
- Avoidable layout shift, bundle growth from a new heavy dependency, or hydration mismatch risk.

## Framework specifics

- Next.js / SSR: server-client boundaries, `use client` placement, hydration safety, route data and caching assumptions, server actions treated as untrusted public endpoints.
- Vite / client-only: environment variable exposure, code splitting, startup error handling.
- Tests: Testing Library and Playwright changes assert behavior, not implementation details.
