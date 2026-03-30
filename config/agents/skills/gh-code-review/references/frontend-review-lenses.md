# Frontend Review Lenses

Apply these lenses to React, TypeScript, and frontend framework pull requests.

## Correctness and regressions

- Check whether changed branches still handle empty, loading, error, and success states.
- Look for stale assumptions after prop, state, route, schema, or API changes.
- Verify that derived state stays in sync with source state.

## React and rendering

- Watch for stale closures in effects, callbacks, memoized values, and event handlers.
- Check dependency arrays for missing or unstable values.
- Look for unnecessary remounts from unstable keys or recreated component definitions.
- Watch for controlled versus uncontrolled input mismatches.
- Verify Suspense, transitions, and async rendering paths do not hide broken states.

## TypeScript

- Prefer type-safe narrowing over assertions.
- Flag widened types that hide invalid states.
- Watch for optional values used as if guaranteed.
- Check public API changes for downstream breakage.
- Treat `any`, unsafe casts, and non-null assertions as risk multipliers unless clearly justified.

## Async and data flow

- Check cancellation, race conditions, and out-of-order responses.
- Look for loading flags that can get stuck.
- Verify retries, optimistic updates, and cache invalidation match the intended behavior.
- Confirm error boundaries and fallback UI still make sense.

## Accessibility and UX

- Verify accessible names, roles, focus management, and keyboard access.
- Check ARIA relationships after structural refactors.
- Watch for duplicate announcements, hidden labels, or click-only interactions.
- Ensure disabled, read-only, validation, and empty states remain understandable.

## Performance

- Look for re-render cascades in large lists or shared providers.
- Watch for expensive work during render that should be memoized or moved.
- Check virtualization, pagination, and image loading when large collections are involved.
- Flag avoidable layout shift or hydration mismatch risk.

## Framework-specific prompts

- For Next.js or SSR frameworks, check server-client boundaries, hydration safety, and route data assumptions.
- For Vite or client-only apps, check environment access, code splitting, and startup error handling.
- For testing-library or Playwright changes, verify tests still assert behavior instead of implementation details.

## Severity guidance

- Prefer `Blocker` when the issue is likely user-visible and severe.
- Prefer `Major` when the issue is important but not clearly merge-stopping.
- Prefer `Minor` or `Nit` when the concern is real but low risk.
