# agent-names

A local Herdr plugin (`niklas.agent-names`) that gives every detected agent pane
(Claude, Codex, Copilot, ...) a unique human name from `names.json`, each with a
short personality: a speaking voice, never an attitude toward work. The name becomes the agent's Herdr name, so other
agents can reach it with `herdr agent prompt jerry "..."` or `herdr agent get jerry`.

## How it works

- `bin/daemon` is the plugin's `[[startup]]` process. It subscribes to the Herdr
  socket (`pane.agent_detected`, `pane.closed`, `pane.moved`), names every
  unnamed live agent on start, and names each newly detected agent after that.
  A failed event or reconcile is logged and followed by a full reconcile on the
  next 30-second tick. Malformed socket lines are logged and skipped.
- Names are picked at random from those not in use. When all are taken it
  falls back to `jerry-2`, `skye-3`, ...
- Assignments are kept in `$HERDR_PLUGIN_STATE_DIR/assignments.json`
  (`~/.local/state/herdr/plugins/niklas.agent-names/` here), keyed by pane id.
  An agent restarted in the same pane gets its old name back. Entries for
  closed panes are dropped, and a pane moved to another workspace keeps its
  entry under its new pane id. The daemon and the `reroll` action both hold
  `.assignments.lock` while they update the file, so neither loses an update.
  Panes whose sidebar tokens could not be reported are listed in
  `pending_metadata.json`; the daemon retries them on its tick with the name
  currently in state, and drops panes that have closed or moved.
- After renaming it reports the pane tokens `name` (display name, e.g. `Jerry`)
  and `flair` (the personality) with `--source niklas.agent-names`.
- Action `reroll` (pane context) gives the focused agent a new random name:
  `herdr plugin action invoke niklas.agent-names.reroll`.

Logs: `herdr plugin log list --plugin niklas.agent-names`.

## Install

```bash
herdr plugin link ~/dotfiles/config/herdr/local-plugins/agent-names
```

Startup hooks only run when the Herdr server starts, so the daemon starts at the
next server start. Requires `python3` (stdlib only; 3.9+).

To run it by hand instead (for example while testing):

```bash
cd ~/dotfiles/config/herdr/local-plugins/agent-names
HERDR_SOCKET_PATH=~/.config/herdr/herdr.sock HERDR_BIN_PATH=$(which herdr) \
  HERDR_PLUGIN_STATE_DIR=~/.local/state/herdr/plugins/niklas.agent-names \
  python3 bin/daemon
```

## Sidebar

Show the name in the Agent sidebar via `config.toml`:

```toml
[ui.sidebar.agents]
rows = [
  ["state_icon", { token = "$name", bold = true }, "machine", "workspace", "tab"],
  ["agent"],
]
```

Then `herdr server reload-config`. `$flair` is available as a token too.

## whoami

`bin/whoami`, run inside an agent pane (it reads `HERDR_PANE_ID`), prints the
agent's identity for it to adopt:

```
You are Jerry (herdr agent name: jerry). Personality: ... Other agents can reach you with: herdr agent prompt jerry "..."
Scope: your personality is a light running gag for your chat replies to the user only: ...
```

The second line is always printed. The personality may only colour the tone
of chat replies to the user. It must not change reasoning, accuracy,
thoroughness, decisions, code, commit messages, docs, or messages to other
agents, and is dropped whenever it would hurt clarity.

- `whoami --list` lists every live named agent with its personality, followed
  by the same scope note.
- `whoami --wait SECONDS` polls until the pane has a name, then prints as usual.
  Each `herdr` call is limited to the time left. On timeout, outside a Herdr
  pane, or when `herdr` cannot be run, it prints nothing and exits 0. This is
  meant for a Claude Code `SessionStart` hook, which fires before Herdr has
  detected and named the agent.
- Without `--wait`, it exits non-zero outside a named pane.

Nothing is wired into Claude or Codex config by this plugin. To have agents
adopt their personality, call `whoami --wait 10` from a session-start hook or
tell the agent to run it.

## Editing names

`names.json` is a list of `{ "name": "Jerry", "flair": "..." }`. A flair
describes a voice or way of speaking ("talks like a 1940s radio announcer"),
never an attitude toward work (no pessimists, reckless or lazy types, or
contrarians), and is at most 80 characters (Herdr's token limit). The agent name
is the lowercased `name`, so it must match `[a-z][a-z0-9_-]{0,31}` once
lowercased, must be unique, and must not contain `-` (reserved for the `-2`
suffix). Run the tests after editing:

```bash
python3 -m unittest discover -s tests -v
```

The daemon reads `names.json` at start; restart it to pick up changes.
