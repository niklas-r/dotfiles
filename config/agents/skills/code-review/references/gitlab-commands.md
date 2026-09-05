# GitLab Commands (`glab`)

All GitLab interaction goes through `glab` or `glab api`.

`glab api` expands repo placeholders in the path: `:id`, `:fullpath`, `:namespace`, `:repo`, `:group`, `:branch`, `:user`, `:username`. Use `projects/:id/...`. Add `--paginate` for list endpoints.

## Inspect

```bash
glab mr view <iid> -F json --jq '{iid,title,author:.author.username,draft,source_branch,target_branch,web_url,diff_refs}'
glab mr diff <iid> --raw
glab api projects/:id/merge_requests/<iid>/changes
glab api projects/:id/merge_requests/<iid>/notes --paginate         # all notes
glab api projects/:id/merge_requests/<iid>/discussions --paginate   # threads incl. inline position
glab api projects/:id/merge_requests/<iid>/approvals
```

`glab mr view <iid> --comments` (or `--unresolved`) gives a readable conversation dump.

In `discussions`, each entry has `individual_note` and `notes[]` with `id`, `body`, `position`, `resolvable`, `resolved`. Ignore notes where `system` is `true`.

## Deduplicate

Treat a finding as already covered when an existing note:

- has a `position` on the same `new_path` and near the same `new_line` and describes the same risk, or
- describes the same underlying bug even if worded differently.

React instead of reposting (only if the user approved interaction):

```bash
# check first
glab api projects/:id/merge_requests/<iid>/notes/<note_id>/award_emoji
# then react
glab api projects/:id/merge_requests/<iid>/notes/<note_id>/award_emoji --method POST -f name=thumbsup
```

GitLab uses emoji names without colons: `thumbsup`, not `+1`.

## Inline comments

Inline notes require the `position` object built from the MR's `diff_refs`:

```bash
glab api projects/:id/merge_requests/<iid> --jq '.diff_refs'
# -> { "base_sha": "...", "start_sha": "...", "head_sha": "..." }
```

```bash
glab api projects/:id/merge_requests/<iid>/discussions --method POST \
  -f body='What is wrong, why it matters, and the suggested fix.' \
  -F position='{
    "position_type": "text",
    "base_sha": "<base_sha>",
    "start_sha": "<start_sha>",
    "head_sha": "<head_sha>",
    "old_path": "src/example.ts",
    "new_path": "src/example.ts",
    "new_line": 42
  }'
```

Rules for `position`:

- `position_type` is `text` for diff comments.
- Added line: set `new_line` only. Removed line: set `old_line` only. Unchanged context line: set both.
- `old_path` and `new_path` are both required; use the same value when the file was not renamed.
- Use `-F` (not `-f`) so the JSON object is sent as an object.

A failed position lookup returns HTTP 400. Do not retry with guessed line numbers; move the finding into the summary comment instead.

## Plain comment

```bash
glab mr note create <iid> -m 'High-level review summary.'
# or
glab api projects/:id/merge_requests/<iid>/notes --method POST -f body='...'
```

## Approve

```bash
glab mr approve <iid>
# optionally pin to the reviewed head commit
glab mr approve <iid> --sha <head_sha>
```

If approvals are not enabled on the project, `approve` fails; post the summary note instead and say so.

## Guardrails

- GitLab has no request-changes state. Never `glab mr unapprove`, never resolve or reopen someone else's thread, never merge or close.
- Never post `Minor` or `Nit` findings.
- Never duplicate an existing note.
- If the position payload is uncertain, use a plain MR note instead of a fragile inline discussion.
