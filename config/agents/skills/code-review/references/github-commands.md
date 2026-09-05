# GitHub Commands (`gh`)

All GitHub interaction goes through `gh` or `gh api`.

## Inspect

```bash
gh pr view <pr> --json number,title,body,url,author,baseRefName,headRefName,isDraft,reviewDecision
gh pr diff <pr>
gh api repos/{owner}/{repo}/pulls/<pr>/files --paginate
gh api repos/{owner}/{repo}/issues/<pr>/comments --paginate   # conversation comments
gh api repos/{owner}/{repo}/pulls/<pr>/comments --paginate    # inline review comments
gh api repos/{owner}/{repo}/pulls/<pr>/reviews --paginate     # review summaries
```

`{owner}` and `{repo}` are auto-filled from the current repo.

## Deduplicate

Treat a finding as already covered when an existing comment:

- points at the same path and line range and describes the same risk, or
- describes the same underlying bug even if worded differently, or
- is a review summary that already calls out the problem clearly.

React instead of reposting (only if the user approved interaction):

```bash
gh api repos/{owner}/{repo}/issues/comments/<comment_id>/reactions -f content='+1'   # conversation comment
gh api repos/{owner}/{repo}/pulls/comments/<comment_id>/reactions -f content='+1'    # inline comment
```

Check existing reactions first to avoid a duplicate `+1`.

## Approve with inline comments

Create the review with comments and approve in one call:

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews --method POST --input - <<'JSON'
{
  "event": "APPROVE",
  "body": "High-level review summary.",
  "comments": [
    {
      "path": "src/example.ts",
      "line": 42,
      "side": "RIGHT",
      "body": "What is wrong, why it matters, and the suggested fix."
    }
  ]
}
JSON
```

For a multi-line anchor add `"start_line"` and `"start_side"`. Omit `event` to leave the review pending, then submit:

```bash
gh api repos/{owner}/{repo}/pulls/<pr>/reviews/<review_id>/events \
  --method POST -f event=APPROVE -f body='Approving with a few notes.'
```

## Approve only

```bash
gh pr review <pr> --approve --body 'Looks good. Optional notes are in my write-up.'
```

## Guardrails

- Never use `REQUEST_CHANGES` or `--request-changes`.
- Never post `Minor` or `Nit` findings.
- Never duplicate an existing comment.
- If line mapping is uncertain, put the finding in the review body instead.
