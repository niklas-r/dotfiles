// Injects this pane's Herdr agent name into the assembled request before every
// model call ("context" hook), so the name is present already in the first
// prompt. The tui.js instructions entry is the fallback for sessions the
// server cannot resolve: an entry put while a step is in flight is only
// rendered from the next step boundary, so it can never cover the first
// model call. Where this hook resolves the pane it owns the channel instead:
// it pushes the intro into the outgoing request and removes any matching
// entry, so the model never sees the intro twice.
//
// The server process env cannot identify the calling pane: a shared server is
// spawned once by whichever pane started it first, so its HERDR_PANE_ID is
// stale. Instead, the session -> pane mapping reported to Herdr by the TUI is
// resolved through `herdr agent list`, and whoami runs with an explicit
// HERDR_PANE_ID override. Subagent sessions are never reported to Herdr, so
// they match nothing and stay unnamed.

import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const WHOAMI = `${process.env.HOME}/dotfiles/config/herdr/local-plugins/agent-names/bin/whoami`;
const HERDR = process.env.HERDR_BIN_PATH || "herdr";
const KEY = "herdr-agent-name";
const INTRO_TTL_MS = 30_000; // rerolled names are picked up within this window
const MISS_TTL_MS = 5_000; // a not-yet-reported session is retried after this
const POLL_MS = 3_000; // the TUI reports its session around admission; the first
const POLL_STEP_MS = 250; // model call can win that race, so poll briefly once

const metas = new Map(); // sessionID -> isRootSession
const intros = new Map(); // paneID -> { value: string | undefined, at: number }
const panes = new Map(); // sessionID -> { paneID: string | undefined, at: number }

// Subagent sessions are never reported to Herdr, so only root sessions resolve.
async function isRootSession(ctx, sessionID) {
  let root = metas.get(sessionID);
  if (root === undefined) {
    const session = await ctx.session.get({ sessionID }).catch(() => undefined);
    root = !session?.parentID;
    if (metas.size > 500) metas.clear();
    metas.set(sessionID, root);
  }
  return root;
}

async function lookupPane(sessionID) {
  try {
    const { stdout } = await execFileAsync(HERDR, ["agent", "list"], { timeout: 2_000 });
    const agents = JSON.parse(stdout)?.result?.agents ?? [];
    return agents.find((agent) => agent?.agent_session?.value === sessionID)?.pane_id;
  } catch {
    return undefined;
  }
}

async function paneForSession(sessionID) {
  const hit = panes.get(sessionID);
  if (hit?.paneID) return hit.paneID;
  if (hit && Date.now() - hit.at < MISS_TTL_MS) return undefined;
  const deadline = hit ? Date.now() : Date.now() + POLL_MS; // poll only on first miss
  let paneID;
  do {
    paneID = await lookupPane(sessionID);
    if (paneID || Date.now() >= deadline) break;
    await new Promise((resolve) => setTimeout(resolve, POLL_STEP_MS));
  } while (true);
  if (panes.size > 500) panes.clear();
  panes.set(sessionID, { paneID, at: Date.now() });
  return paneID;
}

async function introduction(paneID) {
  const hit = intros.get(paneID);
  if (hit && Date.now() - hit.at < INTRO_TTL_MS) return hit.value;
  let value;
  try {
    const { stdout } = await execFileAsync(WHOAMI, [], {
      timeout: 2_000,
      env: { ...process.env, HERDR_PANE_ID: paneID },
    });
    value = stdout.trim() || undefined;
  } catch {
    value = hit?.value; // keep the last good intro on transient failures
  }
  intros.set(paneID, { value, at: Date.now() });
  return value;
}

export default {
  id: "herdr.name-injector",
  async setup(ctx) {
    if (!process.env.HERDR_SOCKET_PATH && process.env.HERDR_ENV !== "1") return;
    const registration = await ctx.session.hook("context", async (event) => {
      if (!(await isRootSession(ctx, event.sessionID))) return;
      const paneID = await paneForSession(event.sessionID);
      const intro = paneID ? await introduction(paneID) : undefined;
      if (!intro) return;
      // An existing entry from the TUI fallback is not rendered for the
      // in-flight step anyway; remove it so later steps don't render it twice.
      const entries = await ctx.session.instructions.entry
        .list({ sessionID: event.sessionID })
        .catch(() => undefined);
      if (entries?.some?.((entry) => entry?.key === KEY)) {
        await ctx.session.instructions.entry
          .remove({ sessionID: event.sessionID, key: KEY })
          .catch(() => {});
      }
      event.system.push({ type: "text", text: intro });
    });
    return () => registration.dispose();
  },
  // V1 calls server() and ignores setup(); the hook this plugin needs is V2-only.
  async server() {
    return {};
  },
};
