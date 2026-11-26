"""Pure logic for agent-diff: scope -> CodeDiff args, timestamps, nvim paths."""
import json
import os
import shutil
from datetime import datetime
from pathlib import Path

SCOPES = {
    "1": "Changes from this session",
    "2": "Changes vs base",
    "3": "Uncommitted changes",
}
BRANCH_FALLBACKS = ("test", "main", "master")
EXTRA_PATH = ("/opt/homebrew/bin", "/usr/local/bin")


def tool(name, env=os.environ, extra=EXTRA_PATH):
    """Executable for `name`. A launchd-started herdr gives plugins a PATH without Homebrew."""
    if name == "herdr" and env.get("HERDR_BIN_PATH"):
        return env["HERDR_BIN_PATH"]
    return shutil.which(name, path=os.pathsep.join([env.get("PATH", ""), *extra])) or name


def scope_args(key, base):
    """CodeDiff revision args. `base` is a commit (key 1) or a branch (key 2)."""
    if key == "1":
        return [base]
    if key == "2":
        return [base + "..."]
    return ["HEAD"]


def first_claude_timestamp(lines):
    """Earliest `timestamp` in a Claude session jsonl, as an aware datetime."""
    stamps = []
    for line in lines:
        try:
            ts = json.loads(line).get("timestamp")
        except (ValueError, AttributeError):
            continue
        if isinstance(ts, str):
            stamps.append(datetime.fromisoformat(ts.replace("Z", "+00:00")))
    return min(stamps) if stamps else None


def parse_etime(text):
    """`ps -o etime=` output ([[dd-]hh:]mm:ss) -> elapsed seconds."""
    days, _, clock = text.strip().rpartition("-")
    secs = 0
    for part in clock.split(":"):
        secs = secs * 60 + int(part)
    return secs + int(days or 0) * 86400


def before_arg(ts):
    return ts.isoformat(sep=" ")


def repo_dir(pane):
    return pane.get("foreground_cwd") or pane.get("cwd")


def tab_key(tab_id):
    return tab_id.replace(":", "_")


def state_file(tab_id, env=os.environ):
    base = env.get("HERDR_NVIM_STATE_DIR")
    if base:
        root = Path(base)
    elif env.get("XDG_STATE_HOME"):
        root = Path(env["XDG_STATE_HOME"]) / "herdr-nvim"
    else:
        root = Path.home() / ".local/state/herdr-nvim"
    return root / (tab_key(tab_id) + ".json")


def socket_path(tab_id, env=os.environ):
    if env.get("HERDR_NVIM_RUNTIME_DIR"):
        root = Path(env["HERDR_NVIM_RUNTIME_DIR"])
    elif env.get("XDG_RUNTIME_DIR"):
        root = Path(env["XDG_RUNTIME_DIR"]) / "herdr-nvim"
    else:
        root = Path(env.get("TMPDIR") or "/tmp") / "herdr-nvim"
    return root / (tab_key(tab_id) + ".sock")


def codediff_command(repo, args, exit_on_close=False):
    flags = ["--exit-on-close"] if exit_on_close else []
    return " ".join(["CodeDiff", *flags, "--repo", vim_escape(repo), *args])


def vim_escape(path):
    """Escape a path for an Ex command line."""
    return "".join("\\" + c if c in " \\" else c for c in path)
