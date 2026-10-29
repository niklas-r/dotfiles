"""Shared logic for the agent-names plugin: names, state, and Herdr calls."""

import contextlib
import fcntl
import json
import os
import random
import re
import subprocess
import sys
import tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent
NAMES_PATH = ROOT / "names.json"
SOURCE = "niklas.agent-names"
NAME_RE = re.compile(r"^[a-z][a-z0-9_-]{0,31}$")


class HerdrError(Exception):
    pass


def log(msg):
    print(f"agent-names: {msg}", file=sys.stderr, flush=True)


# --- names -----------------------------------------------------------------

def load_names(path=NAMES_PATH):
    """Return {agent_name: {"name": Display, "flair": text}} in file order."""
    entries = json.loads(Path(path).read_text())
    return {e["name"].lower(): e for e in entries}


def display_for(name, names):
    """Display name and flair for an agent name, including `jerry-2` forms."""
    base, _, suffix = name.partition("-")
    entry = names.get(name) or names.get(base)
    if entry is None:
        return name, ""
    display = entry["name"] if name in names else f"{entry['name']}-{suffix}"
    return display, entry["flair"]


def pick_name(names, in_use, rng=random):
    """Random name not in `in_use`; `<name>-2`, `-3`, ... once all are taken."""
    free = [n for n in names if n not in in_use]
    k = 2
    while not free:
        free = [f"{n}-{k}" for n in names if f"{n}-{k}" not in in_use]
        k += 1
    return rng.choice(free)


# --- state -----------------------------------------------------------------

def state_path():
    return Path(os.environ["HERDR_PLUGIN_STATE_DIR"]) / "assignments.json"


def pending_path(path):
    """Pane ids whose sidebar tokens still need reporting; next to the state file."""
    return Path(path).parent / "pending_metadata.json"


@contextlib.contextmanager
def state_lock(path):
    """Exclusive lock around a load-modify-save of the state file.

    The daemon and the reroll action both take it, so neither loses the
    other's update.
    """
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path.parent / ".assignments.lock", "w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        yield


def load_json(path, default):
    try:
        return json.loads(Path(path).read_text())
    except FileNotFoundError:
        return default
    except ValueError:
        log(f"ignoring unreadable file {path}")
        return default


def save_json(path, data):
    """Write atomically: temp file in the same directory, then rename."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(dir=path.parent, prefix=f".{path.stem}.")
    try:
        with os.fdopen(fd, "w") as f:
            json.dump(data, f, indent=2, sort_keys=True)
            f.flush()
            os.fsync(f.fileno())
        os.replace(tmp, path)
    except BaseException:
        os.unlink(tmp)
        raise


def load_state(path):
    return load_json(path, {})


def save_state(path, state):
    save_json(path, state)


def load_pending(path):
    return set(load_json(pending_path(path), []))


def save_pending(path, pending):
    save_json(pending_path(path), sorted(pending))


def prune(state, live_pane_ids):
    return {p: n for p, n in state.items() if p in live_pane_ids}


def rekey(state, pending, old_pane_id, new_pane_id):
    """A cross-workspace move gives the pane a new id; carry its name and any
    pending metadata report along. Returns True if anything moved."""
    moved = False
    if old_pane_id in state:
        state[new_pane_id] = state.pop(old_pane_id)
        moved = True
    if old_pane_id in pending:
        pending.discard(old_pane_id)
        pending.add(new_pane_id)
        moved = True
    return moved


def in_use_names(agents, state, exclude_pane=None):
    """Names held by live agents plus names reserved for other panes."""
    used = {a["name"] for a in agents if a.get("name")}
    used |= {n for p, n in state.items() if p != exclude_pane}
    return used


# --- herdr -----------------------------------------------------------------

def herdr(*args, timeout=None):
    cmd = [os.environ.get("HERDR_BIN_PATH") or "herdr", *args]
    try:
        proc = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    except subprocess.TimeoutExpired:
        raise HerdrError(f"{' '.join(args)}: timed out after {timeout}s")
    if proc.returncode == 0 and not proc.stdout.strip():
        return {}  # e.g. report-metadata prints nothing on success
    try:
        reply = json.loads(proc.stdout)
    except ValueError:
        raise HerdrError(f"{' '.join(args)}: {proc.stderr.strip() or proc.stdout.strip()}")
    if "error" in reply:
        raise HerdrError(f"{' '.join(args)}: {reply['error'].get('message')}")
    return reply["result"]


def list_agents():
    return herdr("agent", "list")["agents"]


def live_pane_ids():
    return {p["pane_id"] for p in herdr("pane", "list")["panes"]}


def report_display(pane_id, name, names):
    display, flair = display_for(name, names)
    args = ["pane", "report-metadata", pane_id, "--source", SOURCE, "--token", f"name={display}"]
    args += ["--token", f"flair={flair}"] if flair else ["--clear-token", "flair"]
    herdr(*args)


def try_report(pane_id, name, names, pending):
    """Report the sidebar tokens. On failure log it and add the pane to `pending`."""
    try:
        report_display(pane_id, name, names)
    except HerdrError as e:
        log(f"metadata for {pane_id} failed, will retry: {e}")
        pending.add(pane_id)
        return False
    pending.discard(pane_id)
    return True


def retry_metadata(names):
    """Re-report pending panes with the name currently in state.

    Panes no longer in state (closed or moved) are dropped.
    """
    path = state_path()
    if not load_pending(path):
        return
    with state_lock(path):
        pending = load_pending(path)
        state = load_state(path)
        for pane_id in sorted(pending):
            if pane_id in state:
                try_report(pane_id, state[pane_id], names, pending)
            else:
                pending.discard(pane_id)
        save_pending(path, pending)


def give_name(pane_id, agents, state, names, pending):
    """Rename the pane's agent: its sticky name if free, else a random free one.

    Mutates `state` and `pending`; the caller saves both, also when only the
    metadata report failed. Returns the name given.
    """
    used = in_use_names(agents, state, exclude_pane=pane_id)
    sticky = state.get(pane_id)
    name = sticky if sticky and sticky not in used else pick_name(names, used)
    for _ in range(5):
        try:
            herdr("agent", "rename", pane_id, name)
            break
        except HerdrError as e:
            # Someone took the name between our list and the rename.
            log(f"rename {pane_id} -> {name} failed: {e}")
            used.add(name)
            name = pick_name(names, used)
    else:
        raise HerdrError(f"could not name {pane_id}")
    state[pane_id] = name
    try_report(pane_id, name, names, pending)
    return name


def ensure_named(pane_id, agents, state, names, pending):
    """Name the agent in `pane_id` if it has none. Returns True if state changed."""
    agent = next((a for a in agents if a["pane_id"] == pane_id), None)
    if agent is None:
        return False
    if agent.get("name"):
        try_report(pane_id, agent["name"], names, pending)
        if state.get(pane_id) == agent["name"]:
            return False
        state[pane_id] = agent["name"]
        return True
    name = give_name(pane_id, agents, state, names, pending)
    agent["name"] = name
    log(f"named {pane_id} {name}")
    return True


def reconcile(names):
    """Drop state for closed panes and name every unnamed live agent.

    Returns how many agents could not be named.
    """
    path = state_path()
    with state_lock(path):
        state = prune(load_state(path), live_pane_ids())
        pending = load_pending(path) & set(state)
        agents = list_agents()
        failures = 0
        try:
            for agent in agents:
                try:
                    ensure_named(agent["pane_id"], agents, state, names, pending)
                except HerdrError as e:
                    log(str(e))
                    failures += 1
        finally:
            save_state(path, state)
            save_pending(path, pending)
    return failures
