import sys
import unittest
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
import agent_diff as ad
import snapshot


class ScopeArgs(unittest.TestCase):
    def test_scopes(self):
        self.assertEqual(ad.scope_args("1", "abc123"), ["abc123"])
        self.assertEqual(ad.scope_args("2", "origin/main"), ["origin/main..."])
        self.assertEqual(ad.scope_args("3", None), ["HEAD"])


class Timestamps(unittest.TestCase):
    def test_earliest_claude_timestamp_skips_junk(self):
        lines = [
            '{"type":"summary"}',
            "not json",
            '{"timestamp":"2026-11-06T10:05:00.000Z"}',
            '{"timestamp":"2026-11-06T09:30:00.123Z"}',
        ]
        self.assertEqual(
            ad.first_claude_timestamp(lines),
            datetime(2026, 11, 6, 9, 30, 0, 123000, tzinfo=timezone.utc),
        )

    def test_no_timestamps(self):
        self.assertIsNone(ad.first_claude_timestamp(['{"a":1}']))

    def test_parse_etime(self):
        self.assertEqual(ad.parse_etime("   05:03\n"), 303)
        self.assertEqual(ad.parse_etime("02:05:03"), 7503)
        self.assertEqual(ad.parse_etime("3-02:05:03"), 266703)

    def test_before_arg(self):
        self.assertEqual(ad.before_arg(datetime(2026, 11, 6, 10, 0, 1)), "2026-11-06 10:00:01")


class Paths(unittest.TestCase):
    def test_state_file_precedence(self):
        self.assertEqual(
            ad.state_file("w1:t2", {"HERDR_NVIM_STATE_DIR": "/s", "XDG_STATE_HOME": "/x"}),
            Path("/s/w1_t2.json"),
        )
        self.assertEqual(ad.state_file("w1:t2", {"XDG_STATE_HOME": "/x"}), Path("/x/herdr-nvim/w1_t2.json"))
        self.assertEqual(
            ad.state_file("w1:t2", {}), Path.home() / ".local/state/herdr-nvim/w1_t2.json"
        )

    def test_socket_precedence(self):
        self.assertEqual(ad.socket_path("w1:t2", {"HERDR_NVIM_RUNTIME_DIR": "/r"}), Path("/r/w1_t2.sock"))
        self.assertEqual(ad.socket_path("w1:t2", {"XDG_RUNTIME_DIR": "/u"}), Path("/u/herdr-nvim/w1_t2.sock"))
        self.assertEqual(ad.socket_path("w1:t2", {"TMPDIR": "/t/"}), Path("/t/herdr-nvim/w1_t2.sock"))

    def test_repo_dir_falls_back_to_cwd(self):
        self.assertEqual(ad.repo_dir({"foreground_cwd": "/a", "cwd": "/b"}), "/a")
        self.assertEqual(ad.repo_dir({"cwd": "/b"}), "/b")


class SnapshotRef(unittest.TestCase):
    def test_ref_name(self):
        self.assertEqual(snapshot.ref_name("abc-1", "w1:p2", 7), "refs/agent-diff/abc-1")
        self.assertEqual(snapshot.ref_name(None, "w1:p2", 7), "refs/agent-diff/w1_p2_7")


class Command(unittest.TestCase):
    def test_special_chars_kept_literal(self):
        for path in ("/a#b", '/a"b', "/a%b", "/a|b"):
            self.assertEqual(ad.vim_escape(path), path)
        self.assertEqual(ad.vim_escape("/a b\\c"), "/a\\ b\\\\c")

    def test_command(self):
        self.assertEqual(ad.codediff_command("/r", ["HEAD"]), "CodeDiff --repo /r HEAD")
        self.assertEqual(
            ad.codediff_command("/my repo", ["main..."], exit_on_close=True),
            "CodeDiff --exit-on-close --repo /my\\ repo main...",
        )


if __name__ == "__main__":
    unittest.main()
