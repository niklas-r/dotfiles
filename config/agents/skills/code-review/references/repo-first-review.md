# Repo-First Review

Use when running from the checked-out repository, especially when the current branch is the PR/MR branch.

## Verify local context

Confirm before trusting local state:

- the current directory is a git repository
- the remote matches the PR/MR project
- the current branch matches the head branch, or at least contains the commits under review
- the working tree has no unrelated local edits that could be mistaken for the diff

If it does not match, fall back to a CLI-only review and state the mismatch.

## Workflow

1. Resolve the change and identify base and head.
2. Diff locally against the base: `git diff <base>...HEAD`.
3. Read the changed files in full, not just the patch.
4. Expand outward into imports, shared utilities, referenced hooks and components, exported types, call sites and consumers, and tests covering the changed paths.
5. Use symbol-aware navigation (definition, references, implementations, type declarations) rather than text search when tracing a type, hook, or utility.
6. Reconcile local understanding with the existing comments, reviews, and the description from the platform CLI.

## Division of labor

Local checkout is best for:

- verifying whether a suspected bug is already handled elsewhere
- understanding internal invariants and project-specific patterns
- spotting downstream breakage from type or API changes
- checking whether tests exist but were not updated
- judging consistency with neighboring code

Platform CLI is best for:

- metadata and author intent from title and description
- existing comments and duplicate detection
- approval, comments, and reactions

## Caveats

- Prefer file reads over diff-only reasoning for complex modules.
- Check tests before calling out missing coverage.
- If local and remote diffs disagree, say so explicitly and treat it as a review caveat.
