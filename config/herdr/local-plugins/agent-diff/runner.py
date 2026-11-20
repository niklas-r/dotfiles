"""Thin herdr/git/nvim calls for agent-diff. Logic lives in agent_diff.py."""
import glob
import json
import os
import shlex
import subprocess
from datetime import datetime, timedelta
from pathlib import Path

import agent_diff as ad
import snapshot


class DiffError(Exception):
    pass


def run(cmd, cwd=None, check=True):
    proc = subprocess.run(cmd, cwd=cwd, capture_output=True, text=True)
    if check and proc.returncode != 0:
        raise DiffError(f"{cmd[0]} {cmd[1]}: {proc.stderr.strip() or proc.stdout.strip()}")
    return proc


def herdr_json(*args):
    return json.loads(run(["herdr", *args]).stdout)["result"]


def git(repo, *args):
    return run(["git", "-C", repo, *args], check=False)


def agent_pid(pane_id):
    info = herdr_json("pane", "process-info", "--pane", pane_id)["process_info"]
    return info.get("foreground_process_group_id")


def session_start(pane):
    session = pane.get("agent_session") or {}
    if session.get("agent") == "claude" and session.get("value"):
        pattern = os.path.expanduser(f"~/.claude/projects/*/{session['value']}.jsonl")
        for path in glob.glob(pattern):
            ts = ad.first_claude_timestamp(Path(path).read_text().splitlines())
            if ts:
                return ts
    pid = agent_pid(pane["pane_id"])
    if not pid:
        raise DiffError("cannot find the agent process")
    elapsed = ad.parse_etime(run(["ps", "-o", "etime=", "-p", str(pid)]).stdout)
    return datetime.now() - timedelta(seconds=elapsed)


def default_branch(repo):
    head = git(repo, "symbolic-ref", "--short", "refs/remotes/origin/HEAD")
    if head.returncode == 0 and head.stdout.strip():
        return head.stdout.strip()
    for name in ad.BRANCH_FALLBACKS:
        if git(repo, "rev-parse", "--verify", "--quiet", name).returncode == 0:
            return name
    raise DiffError("no default branch found (origin/HEAD, test, main, master)")


def resolve_args(key, pane, repo):
    if git(repo, "rev-parse", "--git-dir").returncode != 0:
        raise DiffError(f"{repo} is not a git repository")
    if key == "1":
        session = (pane.get("agent_session") or {}).get("value")
        pid = agent_pid(pane["pane_id"])
        for ref in (snapshot.ref_name(session, pane["pane_id"], pid), snapshot.ref_name(None, pane["pane_id"], pid)):
            if git(repo, "rev-parse", "--verify", "--quiet", ref).returncode == 0:
                return ad.scope_args(key, ref)
        before = ad.before_arg(session_start(pane))
        base = git(repo, "rev-list", "-1", f"--before={before}", "HEAD").stdout.strip()
        if not base:
            raise DiffError(f"no commit before session start ({before})")
        return ad.scope_args(key, base)
    return ad.scope_args(key, default_branch(repo) if key == "2" else None)


def live_sidebar(tab_id):
    """(socket, sidebar pane) if the tab's herdr-nvim sidebar is up, else None."""
    sock = ad.socket_path(tab_id)
    try:
        sidebar = json.loads(ad.state_file(tab_id).read_text()).get("sidebar_pane")
    except (OSError, ValueError):
        return None
    if not sidebar or not sock.exists():
        return None
    if run(["nvim", "--server", str(sock), "--remote-expr", "1"], check=False).returncode != 0:
        return None
    panes = herdr_json("pane", "list")["panes"]
    return (str(sock), sidebar) if any(p["pane_id"] == sidebar for p in panes) else None


def nvim_execute(sock, ex_command):
    expr = 'execute("' + ex_command.replace("\\", "\\\\").replace('"', '\\"') + '")'
    run(["nvim", "--server", sock, "--remote-expr", expr])


def open_diff(pane, args):
    repo = ad.repo_dir(pane)
    sidebar = live_sidebar(pane["tab_id"])
    if sidebar:
        sock, sidebar_pane = sidebar
        nvim_execute(sock, ad.codediff_command(repo, args))
        run(["herdr", "pane", "zoom", sidebar_pane, "--on"])
        run(["herdr", "agent", "focus", sidebar_pane], check=False)  # fails for non-agent panes
        return
    tab = herdr_json("tab", "create", "--workspace", pane["workspace_id"], "--cwd", repo,
                     "--label", "diff", "--focus")
    new_pane = tab["root_pane"]["pane_id"]
    cmd = ad.codediff_command(repo, args, exit_on_close=True)
    run(["herdr", "pane", "run", new_pane, "nvim", "-c", shlex.quote(cmd)])


def notify(title, body=""):
    run(["herdr", "notification", "show", title, "--body", body], check=False)
