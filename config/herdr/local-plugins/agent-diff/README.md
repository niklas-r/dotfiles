# agent-diff

A local Herdr plugin (`niklas.agent-diff`) that opens a CodeDiff view of what
the focused agent changed, in nvim.

## How it works

- Action `pick` (pane context, bound to `prefix+d`) opens the `menu` popup pane
  with `AGENT_DIFF_PANE` set to the focused agent pane. One keypress picks the
  scope; `q`/Esc cancels.

| Key | Scope | CodeDiff args |
|---|---|---|
| 1 | Changes from this session | `<base>`: last commit before the session started |
| 2 | Changes vs base | `<default branch>...` |
| 3 | Uncommitted changes | `HEAD` |

- Repo is the pane's `foreground_cwd` (fallback `cwd`); passed as `--repo`.
- Snapshot: on `pane.agent_detected` (`[[events]]` hook, `bin/snapshot`) the
  tracked working tree (staged and unstaged edits) is committed with a temp
  index, so the real index and worktree stay untouched, and stored as
  `refs/agent-diff/<session id, else pane id_agent pid>`. An existing ref is kept. Refs
  older than 14 days are pruned when a new one is created. Scope 1 uses the
  ref, so edits that predate the session are excluded. Files untracked at session
  start still show as new.
- Fallback: sessions started before the plugin was installed have no ref and use
  the timestamp heuristic below.
- Session start (fallback): for Claude panes, the earliest `timestamp` in
  `~/.claude/projects/*/<session id>.jsonl`; otherwise the agent process start
  time (`ps -o lstart=`).
- Default branch: `origin/HEAD`, else the first of `test`, `main`, `master`.
- Target: if the tab has a live herdr-nvim sidebar (state file + socket + pane),
  `CodeDiff` runs there via `nvim --remote-expr 'execute(...)'`, then the
  sidebar is zoomed on and focused. Otherwise a new `diff` tab runs
  `exec nvim -c 'CodeDiff --exit-on-close ...'`, so the tab closes with nvim.
- Errors (no git repo, no base) show as a Herdr notification.

Pure logic is in `agent_diff.py`; herdr/git/nvim calls are in `runner.py`.
Tests: `python3 -m unittest discover -s tests`.

## Install

```bash
herdr plugin link ~/dotfiles/config/herdr/local-plugins/agent-diff
```

Requires `python3` (stdlib only; 3.9+), `git`, and nvim with codediff.nvim.
