"""Snapshot the working tree at agent start so scope 1 can exclude earlier dirt."""
import os
import re
import shutil
import subprocess
import tempfile
import time

PREFIX = "refs/agent-diff/"
MAX_AGE_DAYS = 14


def ref_name(session, pane_id, pid):
    """Session id, else pane id plus agent pid (pane ids are reused)."""
    return PREFIX + re.sub(r"[^A-Za-z0-9._-]", "_", session or f"{pane_id}_{pid}")


def git(repo, *args, env=None):
    proc = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True, env=env)
    return proc.stdout.strip() if proc.returncode == 0 else None


def snapshot(repo, ref):
    """Create `ref` as a commit of the tracked working tree. No-op if it exists or on failure."""
    if git(repo, "rev-parse", "--verify", "--quiet", ref) or not git(repo, "rev-parse", "HEAD"):
        return False
    index = git(repo, "rev-parse", "--path-format=absolute", "--git-path", "index")
    with tempfile.TemporaryDirectory() as tmp:
        tmp_index = os.path.join(tmp, "index")
        if index and os.path.exists(index):
            shutil.copy(index, tmp_index)
        env = {**os.environ, "GIT_INDEX_FILE": tmp_index}
        if git(repo, "add", "-u", env=env) is None:
            return False
        tree = git(repo, "write-tree", env=env)
        commit = tree and git(repo, "commit-tree", tree, "-p", "HEAD", "-m", "agent-diff snapshot")
    if not commit:
        return False
    prune(repo)
    return git(repo, "update-ref", ref, commit) is not None


def prune(repo, now=None):
    cutoff = (now or time.time()) - MAX_AGE_DAYS * 86400
    out = git(repo, "for-each-ref", "--format=%(refname) %(committerdate:unix)", PREFIX) or ""
    for line in out.splitlines():
        name, _, stamp = line.rpartition(" ")
        if int(stamp) < cutoff:
            git(repo, "update-ref", "-d", name)
