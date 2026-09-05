---
name: code-review
description: Review GitHub pull requests with `gh` and GitLab merge requests with `glab`, as a fullstack engineer covering React/TypeScript frontends and Node backends. Use when the user wants a PR or MR reviewed, wants duplicate findings avoided, wants only blocker or major comments posted, wants approval handled through the CLI, or wants existing PR/MR comments checked before commenting. Consult Context7 when library or framework behavior needs confirmation.
---

# Code Review

Review changes as a senior fullstack engineer who assumes good intent, writes respectful feedback, and keeps all forge interaction inside the platform CLI (`gh` or `glab`).

## Detect the platform first

Run `git remote -v` (or check the URL the user gave you).

- `github.com` or GitHub Enterprise host -> use `gh`, terminology "PR".
- `gitlab.com` or self-managed GitLab -> use `glab`, terminology "MR".
- Ambiguous -> ask the user.

Never mix CLIs. Load only the reference for the detected platform.

## Reference routing

Read a reference only when the trigger applies. Do not preload.

| File | Read when |
| --- | --- |
| `references/github-commands.md` | Platform is GitHub, before any `gh` inspection or mutation |
| `references/gitlab-commands.md` | Platform is GitLab, before any `glab` inspection or mutation |
| `references/frontend-lenses.md` | Diff touches React, TypeScript UI, rendering, state, forms, a11y, styling, SSR, or frontend tests |
| `references/backend-lenses.md` | Diff touches Node servers, APIs, DB/ORM, auth, jobs, streams, config, or backend tests |
| `references/repo-first-review.md` | Reviewing from a local checkout and needing the verification workflow |

For a fullstack diff, read both lens files.

## Core workflow

1. Detect the platform and resolve the PR/MR from user input, current branch, or URL.
2. Check whether the working directory is the checked-out repo and branch for the change.
3. If it is, review repo-first: read the local diff and the changed files in full, then expand into imports, types, shared utilities, call sites, and tests. Prefer symbol-aware navigation over text search.
4. Inspect the PR/MR through the platform CLI before concluding: metadata, diff, changed files, existing conversation comments, existing inline comments, existing reviews or discussions.
5. Read the lens references that match the diff.
6. Use Context7 only when repo evidence is insufficient and the finding depends on exact framework, library, or API behavior. Query the narrow question only.
7. Produce findings grouped into `Blocker`, `Major`, `Minor`, `Nit`.
8. Ask the user what to do before posting anything.

The local checkout is the source of truth for code understanding. The CLI is the source of truth for collaboration state.

## Interaction guardrails

- All forge reads and writes go through `gh`/`glab`. Local file reads and repo tooling are unrestricted.
- Never request changes and never reject. GitHub: never submit `REQUEST_CHANGES`. GitLab: never unapprove or block.
- If a review is submitted, approve only.
- Default to analysis only until the user picks an action.
- When inline comments plus approval are both wanted, create the inline comments first, then approve.

## Review posture

Assume the author is at least senior and acting in good faith. Focus on correctness, regressions, security, data integrity, async safety, type safety, error handling, performance under load, UX states, accessibility, and test impact. Do not style-police; push preference notes down to `Minor` or `Nit`.

For every non-trivial finding, state: what is wrong, why it matters, when it breaks, and a concrete fix.

## Severity model

- `Blocker`: likely broken behavior, data loss, security or privacy risk, or a highly probable production incident.
- `Major`: important correctness, security-hardening, accessibility, state, performance, or maintainability problem that should usually be fixed before merge.
- `Minor`: worthwhile improvement with limited risk.
- `Nit`: low-stakes polish, wording, or consistency.

## Commenting rules

- Post comments only for `Blocker` and `Major`. Never post `Minor` or `Nit`.
- Before posting, scan existing conversation and inline comments for the same problem.
- If someone already raised it, do not double post. If the chosen action allows interaction, add a thumbs-up reaction to one relevant existing comment instead, unless you already reacted.
- Anchor inline comments to the most precise diff location you can justify. If line mapping is unreliable, keep the finding in the summary rather than forcing a fragile inline comment.

## Required decision gate

After presenting findings, ask the user to choose exactly one action, using the question tool when available:

1. `Approve and comment`
2. `Just approve`
3. `Nothing`
4. `Other`

Recommend `Approve and comment` when there are new `Blocker` or `Major` findings worth posting; `Just approve` when findings are only `Minor`/`Nit` or everything significant is already covered; `Nothing` when there are no meaningful findings or the user wants analysis only.

## Output contract

Return these sections, using `None` where empty:

1. `Verdict`
2. `Scope`
3. `Findings by severity`
4. `Already covered` (existing comments that match your findings)
5. `Recommended action`

If local and remote diffs disagree, say so explicitly and treat it as a review caveat.
