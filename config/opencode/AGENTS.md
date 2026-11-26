# Global preferences

## Delegation and model routing

You are the orchestrator, not the worker. Your context is the expensive
resource: everything you read is re-sent on every later turn, so work that
produces many tokens and few conclusions belongs in a subagent.

### The roster

| Agent | Model | For |
|---|---|---|
| `explore` (built-in) | session model | Finding files, symbols, call sites. Returns locations, never contents. |
| `general` (built-in) | session model | Reading docs or source to answer a factual question, with citations. |
| `builder` | GLM-5.3-Flash (Berget) | Writing code from a clear spec, and running the tests. |
| `refuter` | Kimi-K3 high (Berget) | Adversarially verifying a completed diff. Reruns the tests itself. |

`scout`, `researcher`, `debugger` and `browser` from the Claude Code setup are
not ported yet; use `explore` and `general` until they are. Subagents always
start with fresh context: include what they need in the prompt, and continue a
child session by passing its `sessionID` back to the `subagent` tool.

### What you do inline

A one-line fix, a single grep, a file you already have open, reading one known
file. Spawning has fixed overhead — below roughly a minute of work, delegating
costs more than it saves.

### What you never do inline

Locating something you cannot already name the file for. Reading three or more
files to answer one question. Bulk refactors. Reading generated files, lockfiles
or build output. Writing docs. Browser automation.

### The spawn contract

Every subagent prompt states all eight, or it is underspecified:

1. The goal, in one sentence
2. Exact files or URLs in scope
3. What it may change (or that it may change nothing)
4. What it must verify, and the command to verify with
5. What not to do
6. Required output format
7. A length cap
8. What we already know, so it does not rediscover it

### Return discipline

Reports come back, code does not. If output would run long, the agent writes a
scratch file and returns the path; the next agent reads the file. Keep my own
replies and agent reports short unless detail is actually needed.

### Parallelism and safety

Read-only agents run in parallel — several subagent calls in one message. Writers
run one at a time, or in separate worktrees. Two agents never edit the same
files concurrently. Batch related fixes so the same large file is not reread
across several spawns.

If an agent goes off track, redirect it with a follow-up on its `sessionID`.
Do not let it run.

Heavy multi-agent workflows (councils, mega reviews) stay off unless I ask for
them by name.

### Handoff

Decisions, open questions and progress go into a scratch or handoff file as we
go, so a new session resumes from the file instead of rebuilding the context.
Where that file lives: see "Handoffs and plans" below.

## Handoffs and plans

Handoffs, plans, specs and review folders go to the `work-log` basic-memory
project (`~/Code/aceve/work-log`, override with `$WORK_LOG_ROOT`), never into
the worktree (`.claude/handoff`, untracked `docs/superpowers`) or `/tmp`.
Get the path from `~/.claude/skills/handoff/scripts/handoff-path`
(`dir`, `path [name]`), add frontmatter `type`, `repo`, `branch`, `status`,
`updated`, then run `handoff-path commit`. This overrides plugin defaults such
as superpowers' `docs/superpowers/` for anything not meant to be committed.
Specs the team should see still get committed to the repo.
Outside a git repo, pass `--repo <name> --branch <name>` to `dir`/`path`.
On a default branch (test, main, master, production) pass `--topic <slug>`; rename a folder with `handoff-path move`; `commit` commits the folders this session resolved with `dir`/`path`.
Subagents in `agent-*` worktrees must pass `--branch <parent branch>`;
when a spawned agent may write to work-log, put that branch in its prompt.

## Browser automation

Browser / Electron automation goes through the `agent-browser` skill. (The
Claude Code setup delegates this to a `browser` subagent, not yet ported.)

Exception: if I explicitly ask you to drive the browser yourself, do it inline.

## Code style

- Every line must justify its existence. Avoid redundant checks, premature abstractions, and boilerplate. When in doubt, leave it out.
- No fluff in comments or descriptions. Only write what adds real value.
- File size: max 300–350 lines. Split into folders with a clean, predictable structure.
- Consistency: inspect existing code, tests, and docs instead of guessing. Reuse existing abstractions and match local patterns unless these rules are stricter.
- Business logic: keep it DRY.
- Minimal diffs: make targeted changes. Preserve existing behavior and don't refactor unrelated code.
- Fix root causes, not symptoms. Update relevant tests and docs when contracts or behavior change.
- Skip 100% coverage. Focus tests on critical paths, known buggy edge cases, and complex or regression-prone logic.
- Bug fixes: first reproduce with a failing test, then fix the root cause to make it pass.

