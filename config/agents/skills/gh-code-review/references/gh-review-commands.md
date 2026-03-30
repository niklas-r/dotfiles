# GH Review Commands

Use `gh` for all GitHub interaction.

## Inspect the PR

Use these commands first:

```bash
gh pr view <pr> --json number,title,body,url,author,baseRefName,headRefName,isDraft,reviewDecision
gh pr diff <pr>
gh api repos/{owner}/{repo}/pulls/<pr>/files --paginate
gh api repos/{owner}/{repo}/issues/<pr>/comments --paginate
gh api repos/{owner}/{repo}/pulls/<pr>/comments --paginate
gh api repos/{owner}/{repo}/pulls/<pr>/reviews --paginate
```

Notes:

- PR conversation comments live under `issues/<pr>/comments`.
- Inline review comments live under `pulls/<pr>/comments`.
- Review summaries live under `pulls/<pr>/reviews`.

## Deduplicate findings

Before posting a comment, compare your finding against existing PR conversation and inline review comments.

Treat an issue as already covered when one of these is true:

- the existing comment points to the same path and line range and describes the same risk
- the existing comment describes the same underlying bug or regression even if the wording differs
- the review summary already calls out the same problem clearly enough that a new comment adds little value

If already covered and the user allows interaction:

```bash
gh api repos/{owner}/{repo}/issues/comments/<comment_id>/reactions -f content='+1'
gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/reactions -f content='+1'
```

Use the first endpoint for PR conversation comments and the second for inline review comments.

## Preferred submission flow

When you need inline comments and approval together, prefer a pending review:

1. Create a pending review with `gh api`.
2. Include only `Blocker` and `Major` inline comments.
3. Submit that review with `APPROVE` after the user confirms.

Pattern:

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews \
  --method POST \
  --input -
```

Example payload:

```json
{
  "body": "High-level review summary",
  "comments": [
    {
      "path": "src/example.tsx",
      "line": 42,
      "side": "RIGHT",
      "body": "Explain the issue, impact, and suggested fix."
    }
  ]
}
```

Then submit it:

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews/<review_id>/events \
  --method POST \
  -f event=APPROVE \
  -f body='Approving while leaving a few comments for the author to evaluate.'
```

## Approve without inline comments

Use `gh pr review` when you only need an approval summary:

```bash
gh pr review <pr> --approve --body 'Looks good overall. A few optional notes are in my write-up.'
```

## Guardrails

- Never use `REQUEST_CHANGES`.
- Never post `Minor` or `Nit` findings to GitHub.
- Never create duplicate comments for an issue that is already covered.
- If line mapping is uncertain, prefer the approval body or local report instead of a fragile inline comment.
