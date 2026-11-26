import { Plugin } from "@opencode/plugin/tui";
import { execFile } from "node:child_process";
import { promisify } from "node:util";

const execFileAsync = promisify(execFile);
const WHOAMI = `${process.env.HOME}/dotfiles/config/herdr/local-plugins/agent-names/bin/whoami`;
const KEY = "herdr-agent-name";
const injected = new Set();

async function resolveIntroduction() {
  try {
    const { stdout } = await execFileAsync(WHOAMI, ["--wait", "8"], { timeout: 12_000 });
    return stdout.trim() || undefined;
  } catch {
    return undefined;
  }
}

function currentSessionID(context) {
  const route = context.ui.router.current();
  if (!route) return undefined;
  if (route.params?.sessionID) return route.params.sessionID;
  if ((route.name === "session" || route.type === "session") && route.sessionID) return route.sessionID;
  return undefined;
}

function eventSessionID(details) {
  const properties = details?.properties ?? {};
  return properties.sessionID ?? properties.info?.id ?? properties.info?.sessionID;
}

export default Plugin.define({
  id: "herdr.name-injector",
  setup(context) {
    if (process.env.HERDR_ENV !== "1" || !process.env.HERDR_PANE_ID) return;

    async function inject(sessionID) {
      if (!sessionID) return;
      const value = await resolveIntroduction();
      if (!value) return;
      const name = value.match(/herdr agent name: ([^)]+)/)?.[1] ?? "";
      const marker = `${sessionID}\n${name}`;
      if (injected.has(marker)) return;
      await context.client.session.instructions.entry.put({ sessionID, key: KEY, value });
      injected.add(marker);
    }

    const stop = context.data.listen(({ details }) => {
      if (!details?.type?.startsWith("session.")) return;
      void inject(eventSessionID(details) ?? currentSessionID(context)).catch(() => {});
    });
    void inject(currentSessionID(context)).catch(() => {});
    return () => stop();
  },
});
