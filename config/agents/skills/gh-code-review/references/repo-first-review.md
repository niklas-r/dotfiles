# Repo-First Review

Use this workflow when the skill is running from the checked-out repository, especially when the current branch is the PR branch.

## Verify local context first

Confirm these points before trusting local context:

- the current directory is a git repository
- the repository matches the PR remote
- the current branch matches the PR head branch, or at least contains the PR commits under review
- the working tree is understandable enough to review safely

If the checkout does not match, fall back to a GitHub-only review or clearly state the mismatch.

## Local understanding workflow

1. Resolve the PR and identify base and head.
2. Inspect the local diff against the base branch when possible.
3. Read the changed files directly, not just the patch.
4. Expand outward into nearby code:
   - imports and shared utilities
   - referenced hooks and components
   - exported types and interfaces
   - tests covering the changed paths
   - call sites and consumers
5. Use symbol-aware navigation when available:
   - go to definition
   - find references
   - inspect implementations
   - inspect type declarations
6. Reconcile local understanding with `gh` comments, existing reviews, and the PR description.

## What local context is best for

- verifying whether a suspected bug is already handled elsewhere
- understanding internal invariants and project-specific patterns
- spotting downstream breakage from type or API changes
- checking if tests exist but were not modified
- evaluating whether a change is consistent with neighboring code

## What GitHub context is best for

- PR metadata and author intent from title and body
- existing comments and duplicate-detection
- review submission, approval, comments, and reactions
- understanding whether a concern has already been discussed on the PR

## Practical guidance

- Prefer file reads over diff-only reasoning for complex components.
- Prefer symbol-aware navigation over raw text search when tracing a type, hook, or shared utility.
- Check tests before calling out missing coverage.
- If the working tree contains unrelated local edits, avoid confusing them with the PR diff.
- If local and GitHub diffs disagree, say so explicitly and treat that as a review caveat.
