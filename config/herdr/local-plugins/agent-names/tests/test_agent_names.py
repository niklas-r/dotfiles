import json
import os
import random
import subprocess
import sys
import tempfile
import threading
import time
import unittest
import importlib.util
from importlib.machinery import SourceFileLoader
from pathlib import Path
from unittest import mock

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(ROOT))

import agent_names as an


def load_daemon():
    loader = SourceFileLoader("agent_names_daemon", str(ROOT / "bin" / "daemon"))
    daemon = importlib.util.module_from_spec(importlib.util.spec_from_loader(loader.name, loader))
    loader.exec_module(daemon)
    return daemon


FAKE_HERDR = """#!{python}
import json, os, sys
args = sys.argv[1:]
if args[:2] == ["pane", "report-metadata"] and os.environ.get("FAIL_METADATA"):
    print(json.dumps({{"error": {{"message": "metadata rejected"}}}}))
    sys.exit(1)
if args[:2] == ["agent", "list"]:
    print(json.dumps({{"result": {{"agents": [{{"pane_id": "w1:p1", "name": "jerry", "agent": "claude"}}]}}}}))
elif args[:2] == ["agent", "rename"]:
    print(json.dumps({{"result": {{}}}}))
"""


class NamesFileTest(unittest.TestCase):
    def test_names_are_valid_and_unique(self):
        entries = json.loads(an.NAMES_PATH.read_text())
        self.assertGreaterEqual(len(entries), 24)
        lowered = [e["name"].lower() for e in entries]
        self.assertEqual(len(lowered), len(set(lowered)))
        for e in entries:
            self.assertRegex(e["name"].lower(), an.NAME_RE)
            self.assertNotIn("-", e["name"])  # `-` is reserved for the exhaustion suffix
            self.assertTrue(e["flair"].strip())

    def test_flairs_fit_herdr_token_limit(self):
        for e in json.loads(an.NAMES_PATH.read_text()):
            self.assertLessEqual(len(e["flair"]), 80, e["name"])


class PickNameTest(unittest.TestCase):
    names = {"jerry": {}, "skye": {}, "rex": {}}

    def test_never_returns_in_use_name(self):
        for seed in range(200):
            rng = random.Random(seed)
            in_use = set(rng.sample(sorted(self.names), 2))
            self.assertNotIn(an.pick_name(self.names, in_use, rng), in_use)

    def test_exhaustion_adds_suffix(self):
        in_use = {"jerry", "skye", "rex"}
        name = an.pick_name(self.names, in_use, random.Random(1))
        self.assertIn(name, {"jerry-2", "skye-2", "rex-2"})
        self.assertRegex(name, an.NAME_RE)

    def test_exhaustion_skips_taken_suffixes(self):
        in_use = {"jerry", "skye", "rex", "jerry-2", "skye-2", "rex-2"}
        self.assertTrue(an.pick_name(self.names, in_use).endswith("-3"))

    def test_display_for_suffix(self):
        names = {"jerry": {"name": "Jerry", "flair": "gloomy"}}
        self.assertEqual(an.display_for("jerry", names), ("Jerry", "gloomy"))
        self.assertEqual(an.display_for("jerry-2", names), ("Jerry-2", "gloomy"))
        self.assertEqual(an.display_for("custom", names), ("custom", ""))


class StateTest(unittest.TestCase):
    def test_prune_drops_dead_panes(self):
        state = {"w1:p1": "jerry", "w1:p2": "skye"}
        self.assertEqual(an.prune(state, {"w1:p1", "w2:p9"}), {"w1:p1": "jerry"})

    def test_rekey_moves_name_to_new_pane_id(self):
        state = {"w1:p3": "jerry", "w1:p4": "skye"}
        pending = {"w1:p3", "w1:p4"}
        self.assertTrue(an.rekey(state, pending, "w1:p3", "w2:p5"))
        self.assertEqual(state, {"w2:p5": "jerry", "w1:p4": "skye"})
        self.assertEqual(pending, {"w2:p5", "w1:p4"})
        self.assertFalse(an.rekey(state, pending, "w9:p1", "w9:p2"))

    def test_in_use_includes_agents_and_other_reservations(self):
        agents = [{"pane_id": "a", "name": "jerry"}, {"pane_id": "b", "name": None}]
        state = {"b": "skye", "c": "rex"}
        self.assertEqual(an.in_use_names(agents, state, exclude_pane="b"), {"jerry", "rex"})

    def test_atomic_write_roundtrip_leaves_no_temp_files(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "sub" / "assignments.json"
            an.save_state(path, {"w1:p1": "jerry"})
            an.save_state(path, {"w1:p1": "skye"})
            self.assertEqual(an.load_state(path), {"w1:p1": "skye"})
            self.assertEqual(os.listdir(path.parent), ["assignments.json"])

    def test_atomic_write_keeps_old_file_on_failure(self):
        with tempfile.TemporaryDirectory() as d:
            path = Path(d) / "assignments.json"
            an.save_state(path, {"w1:p1": "jerry"})
            with self.assertRaises(TypeError):
                an.save_state(path, {"w1:p1": object()})
            self.assertEqual(an.load_state(path), {"w1:p1": "jerry"})
            self.assertEqual(os.listdir(d), ["assignments.json"])

    def test_missing_state_is_empty(self):
        self.assertEqual(an.load_state("/nonexistent/assignments.json"), {})


class GiveNameTest(unittest.TestCase):
    names = {"jerry": {"name": "Jerry", "flair": "f"}, "skye": {"name": "Skye", "flair": "g"}}

    def test_sticky_name_is_restored(self):
        agents = [{"pane_id": "a", "name": None}]
        state = {"a": "skye"}
        with mock.patch.object(an, "herdr") as herdr:
            self.assertTrue(an.ensure_named("a", agents, state, self.names, set()))
        herdr.assert_any_call("agent", "rename", "a", "skye")
        self.assertEqual(state, {"a": "skye"})

    def test_sticky_name_taken_gets_another(self):
        agents = [{"pane_id": "a", "name": None}, {"pane_id": "b", "name": "skye"}]
        state = {"a": "skye"}
        with mock.patch.object(an, "herdr"):
            an.ensure_named("a", agents, state, self.names, set())
        self.assertEqual(state["a"], "jerry")

    def test_named_agent_is_not_renamed(self):
        agents = [{"pane_id": "a", "name": "jerry"}]
        state = {"a": "jerry"}
        with mock.patch.object(an, "herdr") as herdr:
            self.assertFalse(an.ensure_named("a", agents, state, self.names, set()))
        for call in herdr.call_args_list:
            self.assertNotEqual(call.args[:2], ("agent", "rename"))

    def test_rename_conflict_retries_with_other_name(self):
        agents = [{"pane_id": "a", "name": None}]
        state = {"a": "skye"}

        def herdr(*args):
            if args[:2] == ("agent", "rename") and args[3] == "skye":
                raise an.HerdrError("name taken")
            return {}

        with mock.patch.object(an, "herdr", side_effect=herdr):
            an.ensure_named("a", agents, state, self.names, set())
        self.assertEqual(state["a"], "jerry")


class DaemonMoveTest(unittest.TestCase):
    def test_pane_moved_event_rekeys_state(self):
        daemon = load_daemon()
        self.assertIn({"type": "pane.moved"}, daemon.SUBSCRIPTIONS)
        with tempfile.TemporaryDirectory() as d, \
                mock.patch.dict(os.environ, {"HERDR_PLUGIN_STATE_DIR": d}):
            an.save_state(an.state_path(), {"w1:p3": "jerry"})
            event = {"event": "pane_moved", "data": {
                "type": "pane_moved", "previous_pane_id": "w1:p3",
                "previous_workspace_id": "w1", "previous_tab_id": "w1:t1",
                "pane": {"pane_id": "w2:p5", "workspace_id": "w2"}}}
            daemon.handle(event, {})
            self.assertEqual(an.load_state(an.state_path()), {"w2:p5": "jerry"})


class DaemonResilienceTest(unittest.TestCase):
    def setUp(self):
        self.daemon = load_daemon()
        self.dir = tempfile.TemporaryDirectory()
        env = mock.patch.dict(os.environ, {"HERDR_PLUGIN_STATE_DIR": self.dir.name})
        env.start()
        self.addCleanup(env.stop)
        self.addCleanup(self.dir.cleanup)

    def test_malformed_lines_are_skipped(self):
        for line in [b"not json", b"[1, 2]", b'"text"', b"42", b'{"result": 5}',
                     b'{"result": "x"}', b'{"event": "pane_closed", "data": [1]}',
                     b'{"event": "pane_moved", "data": {"pane": "w2:p5"}}']:
            self.assertTrue(self.daemon.process_line(line, {}), line)

    def test_subscription_error_ends_subscription(self):
        self.assertFalse(self.daemon.process_line(b'{"id": "x", "error": {"code": "events_lost"}}', {}))

    def test_failed_event_schedules_reconcile(self):
        line = b'{"event": "pane_agent_detected", "data": {"pane_id": "w1:p1", "agent": "claude"}}'
        with mock.patch.object(an, "herdr", side_effect=an.HerdrError("agent list failed")):
            self.assertTrue(self.daemon.process_line(line, {}))
        self.assertTrue(self.daemon.needs_reconcile)

    def test_tick_never_raises(self):
        self.daemon.needs_reconcile = True
        with mock.patch.object(an, "reconcile", side_effect=KeyError("result")), \
                mock.patch.object(an, "retry_metadata", side_effect=KeyError("result")):
            self.daemon.tick({})
        self.assertTrue(self.daemon.needs_reconcile)

    def test_handle_waits_for_state_lock(self):
        path = an.state_path()
        an.save_state(path, {"w1:p1": "jerry", "w1:p2": "skye"})
        event = {"event": "pane_closed", "data": {"pane_id": "w1:p1"}}
        with an.state_lock(path):
            worker = threading.Thread(target=self.daemon.handle, args=(event, {}))
            worker.start()
            worker.join(0.5)
            self.assertTrue(worker.is_alive(), "handle did not wait for the lock")
            an.save_state(path, dict(an.load_state(path), **{"w3:p3": "rex"}))
        worker.join(10)
        self.assertEqual(an.load_state(path), {"w1:p2": "skye", "w3:p3": "rex"})

    def test_failed_rename_is_retried_after_throttle_until_it_works(self):
        names = {"jerry": {"name": "Jerry", "flair": "f"}}
        now = [1000.0]
        self.daemon.clock = lambda: now[0]
        renames = []

        def herdr(*args, **kw):
            if args[:2] == ("pane", "list"):
                return {"panes": [{"pane_id": "w1:p1"}]}
            if args[:2] == ("agent", "list"):
                return {"agents": [{"pane_id": "w1:p1", "name": None, "agent": "claude"}]}
            if args[:2] == ("agent", "rename"):
                renames.append(now[0])
                if now[0] < 1060:
                    raise an.HerdrError("server busy")
            return {}

        line = b'{"event": "pane_agent_detected", "data": {"pane_id": "w1:p1", "agent": "claude"}}'
        with mock.patch.object(an, "herdr", side_effect=herdr):
            self.daemon.process_line(line, names)
            self.assertTrue(self.daemon.needs_reconcile)
            tried = len(renames)
            self.daemon.tick(names)  # right after the event: throttled
            self.assertEqual(len(renames), tried, "retried before 30s")
            now[0] = 1030
            self.daemon.tick(names)  # first retry, rename still fails
            self.assertGreater(len(renames), tried)
            self.assertTrue(self.daemon.needs_reconcile, "flag cleared although naming failed")
            tried = len(renames)
            now[0] = 1045
            self.daemon.tick(names)  # 15s after the last attempt: throttled
            self.assertEqual(len(renames), tried, "retried before 30s")
            now[0] = 1060
            self.daemon.tick(names)  # rename works now
        self.assertFalse(self.daemon.needs_reconcile)
        self.assertEqual(an.load_state(an.state_path()), {"w1:p1": "jerry"})

    def test_pane_moved_moves_pending_metadata(self):
        path = an.state_path()
        an.save_state(path, {"w1:p3": "jerry"})
        an.save_pending(path, {"w1:p3"})
        event = {"event": "pane_moved", "data": {
            "previous_pane_id": "w1:p3", "pane": {"pane_id": "w2:p5"}}}
        self.daemon.handle(event, {})
        self.assertEqual(an.load_state(path), {"w2:p5": "jerry"})
        self.assertEqual(an.load_pending(path), {"w2:p5"})

    def test_failed_reconcile_is_retried_on_tick(self):
        now = [0.0]
        self.daemon.clock = lambda: now[0]
        with mock.patch.object(an, "herdr", side_effect=an.HerdrError("server busy")):
            self.daemon.process_line(b'{"result": {"type": "subscription_started"}}', {})
        self.assertTrue(self.daemon.needs_reconcile)

        def herdr(*args):
            if args[:2] == ("pane", "list"):
                return {"panes": [{"pane_id": "w1:p1"}]}
            if args[:2] == ("agent", "list"):
                return {"agents": [{"pane_id": "w1:p1", "name": None}]}
            return {}

        now[0] = self.daemon.RETRY_SECONDS
        with mock.patch.object(an, "herdr", side_effect=herdr):
            self.daemon.tick({"jerry": {"name": "Jerry", "flair": "f"}})
        self.assertFalse(self.daemon.needs_reconcile)
        self.assertEqual(an.load_state(an.state_path()), {"w1:p1": "jerry"})


class MetadataFailureTest(unittest.TestCase):
    names = {"jerry": {"name": "Jerry", "flair": "f"}, "skye": {"name": "Skye", "flair": "g"}}

    def setUp(self):
        self.dir = tempfile.TemporaryDirectory()
        env = mock.patch.dict(os.environ, {"HERDR_PLUGIN_STATE_DIR": self.dir.name})
        env.start()
        self.addCleanup(env.stop)
        self.addCleanup(self.dir.cleanup)
        self.path = an.state_path()

    def test_failed_report_is_persisted_and_retried_with_current_name(self):
        agents = [{"pane_id": "a", "name": None}]
        state, pending = {"a": "jerry"}, set()  # sticky name, so the pick is fixed

        def herdr(*args, **kw):
            if args[:2] == ("pane", "report-metadata"):
                raise an.HerdrError("metadata rejected")
            return {}

        with mock.patch.object(an, "herdr", side_effect=herdr):
            self.assertTrue(an.ensure_named("a", agents, state, self.names, pending))
        self.assertEqual((state, pending), ({"a": "jerry"}, {"a"}))
        an.save_state(self.path, state)
        an.save_pending(self.path, pending)

        # The pane was rerolled since; the retry must report the new name.
        an.save_state(self.path, {"a": "skye"})
        with mock.patch.object(an, "herdr", return_value={}) as ok:
            an.retry_metadata(self.names)
        ok.assert_called_once()
        self.assertIn("name=Skye", ok.call_args.args)
        self.assertEqual(an.load_pending(self.path), set())

    def test_pending_for_gone_pane_is_dropped(self):
        an.save_state(self.path, {"a": "jerry"})
        an.save_pending(self.path, {"gone"})
        with mock.patch.object(an, "herdr") as herdr:
            an.retry_metadata(self.names)
        herdr.assert_not_called()
        self.assertEqual(an.load_pending(self.path), set())

    def test_reroll_metadata_failure_is_retried_by_daemon(self):
        fake = Path(self.dir.name) / "herdr"
        fake.write_text(FAKE_HERDR.format(python=sys.executable))
        fake.chmod(0o755)
        an.save_state(self.path, {"w1:p1": "jerry"})
        env = dict(os.environ, HERDR_BIN_PATH=str(fake), HERDR_PANE_ID="w1:p1", FAIL_METADATA="1")
        proc = subprocess.run([sys.executable, str(ROOT / "bin" / "reroll")],
                              env=env, capture_output=True, text=True, timeout=30)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertEqual(an.load_pending(self.path), {"w1:p1"})

        new_name = an.load_state(self.path)["w1:p1"]
        with mock.patch.object(an, "herdr", return_value={}) as ok:
            load_daemon().tick(an.load_names())
        display, _ = an.display_for(new_name, an.load_names())
        self.assertIn(f"name={display}", ok.call_args.args)
        self.assertEqual(an.load_pending(self.path), set())

    def test_unknown_name_clears_stale_flair(self):
        with mock.patch.object(an, "herdr") as herdr:
            an.report_display("a", "custom", self.names)
        args = herdr.call_args.args
        self.assertIn("name=custom", args)
        self.assertEqual(args[args.index("--clear-token") + 1], "flair")


class LockTest(unittest.TestCase):
    def test_concurrent_writers_lose_no_updates(self):
        script = (
            "import sys; sys.path.insert(0, sys.argv[1]); import agent_names as an\n"
            "for i in range(40):\n"
            "    with an.state_lock(sys.argv[2]):\n"
            "        s = an.load_state(sys.argv[2]); s[f'{sys.argv[3]}:{i}'] = 'x'\n"
            "        an.save_state(sys.argv[2], s)\n"
        )
        with tempfile.TemporaryDirectory() as d:
            path = str(Path(d) / "assignments.json")
            procs = [subprocess.Popen([sys.executable, "-c", script, str(ROOT), path, tag])
                     for tag in ("a", "b", "c")]
            for p in procs:
                self.assertEqual(p.wait(timeout=60), 0)
            self.assertEqual(len(an.load_state(path)), 120)

    def test_reroll_waits_for_lock_and_keeps_concurrent_update(self):
        with tempfile.TemporaryDirectory() as d:
            fake = Path(d) / "herdr"
            fake.write_text(FAKE_HERDR.format(python=sys.executable))
            fake.chmod(0o755)
            state_dir = Path(d) / "state"
            path = state_dir / "assignments.json"
            an.save_state(path, {"w1:p1": "jerry"})
            env = dict(os.environ, HERDR_BIN_PATH=str(fake), HERDR_PANE_ID="w1:p1",
                       HERDR_PLUGIN_STATE_DIR=str(state_dir))
            with an.state_lock(path):
                proc = subprocess.Popen([sys.executable, str(ROOT / "bin" / "reroll")],
                                        env=env, stderr=subprocess.PIPE, text=True)
                time.sleep(1)
                self.assertIsNone(proc.poll(), "reroll did not wait for the lock")
                an.save_state(path, dict(an.load_state(path), **{"w2:p2": "skye"}))
            _, err = proc.communicate(timeout=30)
            self.assertEqual(proc.returncode, 0, err)
            state = an.load_state(path)
            self.assertEqual(state["w2:p2"], "skye")
            self.assertNotIn(state["w1:p1"], {"jerry", "skye"})


class WhoamiTest(unittest.TestCase):
    def run_whoami(self, args, pane_id, reply):
        with tempfile.TemporaryDirectory() as d:
            fake = Path(d) / "herdr"
            fake.write_text(f"#!/bin/sh\necho '{json.dumps(reply)}'\n")
            fake.chmod(0o755)
            env = dict(os.environ, HERDR_BIN_PATH=str(fake))
            env.pop("HERDR_PANE_ID", None)
            if pane_id:
                env["HERDR_PANE_ID"] = pane_id
            return subprocess.run([sys.executable, str(ROOT / "bin" / "whoami"), *args],
                                  capture_output=True, text=True, env=env, timeout=30)

    unnamed = {"result": {"agent": {"pane_id": "w1:p1", "name": None}}}

    def run_with_hanging_herdr(self, args):
        with tempfile.TemporaryDirectory() as d:
            fake = Path(d) / "herdr"
            fake.write_text(f"#!{sys.executable}\nimport time\ntime.sleep(60)\n")
            fake.chmod(0o755)
            env = dict(os.environ, HERDR_BIN_PATH=str(fake), HERDR_PANE_ID="w1:p1")
            start = time.monotonic()
            proc = subprocess.run([sys.executable, str(ROOT / "bin" / "whoami"), *args],
                                  capture_output=True, text=True, env=env, timeout=30)
            return proc, time.monotonic() - start

    def test_wait_bounds_hanging_herdr_by_wait_time(self):
        proc, elapsed = self.run_with_hanging_herdr(["--wait", "1"])
        self.assertLess(elapsed, 4)
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_hanging_herdr_without_wait_times_out(self):
        proc, elapsed = self.run_with_hanging_herdr([])
        self.assertLess(elapsed, 10)
        self.assertNotEqual(proc.returncode, 0)

    def test_list_with_wait_bounds_hanging_herdr(self):
        proc, elapsed = self.run_with_hanging_herdr(["--list", "--wait", "1"])
        self.assertLess(elapsed, 4)
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_list_with_wait_is_silent_on_error(self):
        proc = self.run_whoami(["--list", "--wait", "1"], None, {"error": {"message": "boom"}})
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_list_includes_scope_note(self):
        reply = {"result": {"agents": [{"pane_id": "w1:p1", "name": "jerry", "agent": "claude"}]}}
        proc = self.run_whoami(["--list"], None, reply)
        self.assertEqual(proc.returncode, 0)
        self.assertIn("jerry\tJerry", proc.stdout)
        self.assertIn("chat replies to the user only", proc.stdout)

    def test_wait_with_missing_herdr_is_silent(self):
        env = dict(os.environ, HERDR_BIN_PATH="/nonexistent/herdr", HERDR_PANE_ID="w1:p1")
        proc = subprocess.run([sys.executable, str(ROOT / "bin" / "whoami"), "--wait", "1"],
                              capture_output=True, text=True, env=env, timeout=30)
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_wait_times_out_silently(self):
        start = time.monotonic()
        proc = self.run_whoami(["--wait", "1"], "w1:p1", self.unnamed)
        self.assertGreaterEqual(time.monotonic() - start, 1)
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_wait_outside_pane_is_silent(self):
        proc = self.run_whoami(["--wait", "1"], None, self.unnamed)
        self.assertEqual((proc.returncode, proc.stdout, proc.stderr), (0, "", ""))

    def test_outside_pane_fails(self):
        proc = self.run_whoami([], None, self.unnamed)
        self.assertNotEqual(proc.returncode, 0)
        self.assertIn("HERDR_PANE_ID", proc.stderr)

    def test_unnamed_pane_fails(self):
        proc = self.run_whoami([], "w1:p1", self.unnamed)
        self.assertNotEqual(proc.returncode, 0)

    def test_named_pane_prints_identity(self):
        reply = {"result": {"agent": {"pane_id": "w1:p1", "name": "jerry"}}}
        proc = self.run_whoami(["--wait", "5"], "w1:p1", reply)
        self.assertEqual(proc.returncode, 0)
        self.assertIn("You are Jerry (herdr agent name: jerry).", proc.stdout)
        self.assertIn('herdr agent prompt jerry "..."', proc.stdout)

    def test_identity_always_includes_scope_note(self):
        for name in ("jerry", "jerry-2", "custom"):
            reply = {"result": {"agent": {"pane_id": "w1:p1", "name": name}}}
            proc = self.run_whoami([], "w1:p1", reply)
            self.assertEqual(proc.returncode, 0)
            lines = proc.stdout.splitlines()
            self.assertTrue(lines[0].startswith("You are "), name)
            self.assertIn("chat replies to the user only", lines[1])
            self.assertIn("must not change your reasoning, accuracy", lines[1])
            self.assertIn("messages to other agents", lines[1])


if __name__ == "__main__":
    unittest.main()
