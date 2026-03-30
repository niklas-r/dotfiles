---
name: gh-code-review
description: Review GitHub pull requests with `gh` and `gh api`, with strong React, TypeScript, and frontend framework judgment. Use when the user wants a PR reviewed, wants duplicate findings avoided, wants only blocker or major comments posted, wants approval handled through `gh`, or wants existing PR comments checked before commenting. Consult Context7 when library or framework behavior needs confirmation.
---

# Gh Code Review

Review pull requests as a senior frontend engineer who assumes good intent, writes respectful feedback, and keeps GitHub interaction inside the `gh` CLI.

## Core workflow

1. Verify whether the current working directory is the checked-out repository and branch for the PR.
2. If it is, prefer a repo-first review:
   - inspect the local diff and changed files
   - read the affected source files directly
   - use local search, symbol lookup, and LSP-style navigation when available
   - inspect nearby code, types, tests, and shared utilities to understand intent and blast radius
3. Resolve the pull request from the user input, current branch, or PR URL.
4. Inspect the PR with `gh` before forming conclusions:
   - metadata and summary
   - raw diff and changed files
   - existing issue comments
   - existing review comments
   - existing reviews
5. Read `references/frontend-review-lenses.md` when the PR touches React, TypeScript, rendering, state, forms, accessibility, styling, SSR, tests, or frontend architecture.
6. Read `references/repo-first-review.md` when reviewing from a local checkout.
7. Use Context7 only when repository evidence is not enough and the review depends on exact framework, library, or API behavior.
8. Produce a review report grouped into `Blocker`, `Major`, `Minor`, and `Nit`.
9. Ask the user what to do before creating comments, reactions, or a review submission.

## Repo-first default

- Assume the review is usually being run from the checked-out PR repo and branch.
- Verify that assumption before relying on local context.
- When the local checkout matches the PR, use local code understanding as the primary source of truth and `gh` as the collaboration source of truth.
- Read enough surrounding code to understand whether a change is intentional, incomplete, or inconsistent with project patterns.
- Check related types, hooks, utilities, tests, feature flags, routing, and adjacent call sites when they affect the review.
- Use local LSP or symbol-aware tooling when available to follow references, definitions, implementations, and usages more accurately than text search alone.
- Fall back to `gh`-only review when the working tree is not the PR checkout or local context is unavailable.

## GitHub interaction rules

- Use `gh` or `gh api` for all GitHub operations.
- Read `references/gh-review-commands.md` before posting comments, reactions, or review submissions.
- Read local files and use repo-local tooling freely for understanding the codebase; only GitHub mutations must stay inside `gh`.
- Never submit `REQUEST_CHANGES`.
- Never reject a PR.
- If a review is submitted, submit `APPROVE` only.
- Default to analysis only until the user chooses an action.
- If you need inline review comments plus approval, prefer a pending review via `gh api` and then submit it with `APPROVE`.

## Review posture

- Assume the PR author is acting in good faith and is at least senior level.
- Focus on correctness, regressions, UX states, accessibility, async safety, type safety, performance-sensitive rendering, and test impact.
- Do not turn the review into a style-policing exercise.
- Use `Minor` and `Nit` for lower-value polish and preference comments.
- For every non-trivial finding, include:
  - what is wrong
  - why it matters
  - when it breaks or regresses
  - a concrete suggested fix
- Explain complex findings clearly enough that the author can evaluate the tradeoff without guessing.

## Severity model

- `Blocker`: likely broken behavior, data loss, security/privacy risk, merge-stopping regression, or a highly probable production incident.
- `Major`: important correctness, accessibility, state, performance, or maintainability problem that should usually be fixed before merge.
- `Minor`: worthwhile improvement with limited risk.
- `Nit`: low-stakes polish, wording, or consistency note.

## Commenting rules

- Post comments only for `Blocker` and `Major` findings.
- Never post comments for `Minor` or `Nit` findings.
- Before posting, check existing issue comments and review comments for the same problem.
- If somebody already identified the same issue, do not double post.
- If the user chose an action that allows GitHub interaction, react with `+1` to one relevant existing comment instead of repeating it.
- If you already reacted to that comment, skip the reaction and mention that the issue is already covered.
- Keep comments peer-to-peer, specific, and solution-oriented.

## Required decision gate

After presenting findings, always ask the user to choose exactly one action:

1. `Approve and comment`
2. `Just approve`
3. `Nothing`
4. `Other`

Use the question tool when available. Recommend one option based on the findings:

- Recommend `Approve and comment` when there are new `Blocker` or `Major` findings worth posting.
- Recommend `Just approve` when findings are only `Minor` or `Nit`, or when all `Blocker` and `Major` issues are already covered by existing comments.
- Recommend `Nothing` when there are no meaningful findings or the user appears to want analysis only.

## Output contract

Always return these sections:

1. `Verdict`
2. `Scope`
3. `Findings by severity`
4. `Already covered on the PR`
5. `Recommended action`

When there are no findings in a section, say `None`.

## Notes on execution

- Start by confirming the local repo context with git metadata and PR metadata when possible.
- If the local branch appears to match the PR head, inspect the local diff against the PR base as well as the GitHub diff.
- Use local file reads to verify whether a suspicious change is actually safe because of surrounding code, existing abstractions, or tests.
- Use local symbol navigation and project search to confirm downstream usage before escalating a type or API concern.
- If a line-specific comment is needed, anchor it to the most precise diff location you can justify.
- If a finding is real but line placement is unreliable, keep it in the review summary instead of forcing a fragile inline comment.
- If documentation for React, TypeScript, Next.js, Vite, testing libraries, or other frontend dependencies is needed, resolve the library with Context7 first and query only the narrow question you need answered.
