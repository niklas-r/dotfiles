// Local OpenCode V2 port of the upstream Claude Worktrunk plugin.
//
// Mirrors session activity in this worktree into the branch activity markers
// shown by `wt list`, and exposes a small guidance tool.

import { execFile, spawnSync } from "node:child_process"
import { promisify } from "node:util"
import { Plugin } from "@opencode/plugin"

const execFileAsync = promisify(execFile)

const WORKING_MARKER = "🤖"
const WAITING_MARKER = "💬"

function renderGuide(topic) {
  switch (topic) {
    case "commit-generation":
      return [
        "User config: `~/.config/worktrunk/config.toml`.",
        "Add `[commit.generation]` with the command Worktrunk should use to generate merge commit messages.",
        "Useful checks: `which claude codex llm aichat`, `wt config show`, `wt step commit --show-prompt`.",
        "Reference: https://worktrunk.dev/reference/llm-commits/",
      ].join("\n")

    case "project-hooks":
      return [
        "Project config: `.config/wt.toml` in the repository.",
        "Use `pre-start` for dependency install, `pre-commit` or `pre-merge` for validation, and `post-start` for long-running setup.",
        "Validate commands before adding them so hooks do not fail every worktree switch.",
        "Reference: https://worktrunk.dev/reference/hook/",
      ].join("\n")

    case "worktree-paths":
      return [
        "Worktree path customization lives in `~/.config/worktrunk/config.toml`.",
        "Inspect your current config with `wt config show` before changing templates.",
        "Reference: https://worktrunk.dev/reference/config/",
      ].join("\n")

    default:
      return [
        "Worktrunk uses two config locations:",
        "- User config: `~/.config/worktrunk/config.toml` for personal settings like commit generation and path templates.",
        "- Project config: `.config/wt.toml` for repo-level hooks shared by the team.",
        "This plugin also mirrors OpenCode activity into `wt list` using the same branch markers as the Claude plugin.",
        "Use `worktrunk_guide` with `commit-generation`, `project-hooks`, or `worktree-paths` for focused help.",
      ].join("\n")
  }
}

export default Plugin.define({
  id: "worktrunk",
  async setup(ctx) {
    const cwd = ctx.location.directory.replace(/\/+$/, "")
    // Only sessions in this location may move this worktree's branch marker:
    // the server is shared, so every location's plugin instance sees every session.
    const sessionScope = new Map() // sessionID -> belongs to this location
    const sessionStates = new Map() // sessionID -> marker
    let enabled = false
    let warnedDisabled = false
    let appliedMarker = undefined

    const ensureEnabled = async () => {
      if (enabled) {
        return true
      }

      let reason = "not a git work tree"
      try {
        await execFileAsync("which", ["wt"])
        const gitCheck = await execFileAsync("git", ["rev-parse", "--is-inside-work-tree"], { cwd })
        if (gitCheck.stdout.trim() === "true") {
          enabled = true
          return true
        }
      } catch {
        reason = "wt not found or git check failed"
      }

      if (!warnedDisabled) {
        warnedDisabled = true
        console.warn(`[worktrunk] disabled (${reason}) in ${cwd}`)
      }
      return false
    }

    const inScope = async (sessionID) => {
      let scoped = sessionScope.get(sessionID)
      if (scoped === undefined) {
        const session = await ctx.session.get({ sessionID }).catch(() => undefined)
        scoped = session?.location?.directory?.replace(/\/+$/, "") === cwd
        if (sessionScope.size > 500) sessionScope.clear()
        sessionScope.set(sessionID, scoped)
      }
      return scoped
    }

    const desiredMarker = () => {
      const states = [...sessionStates.values()]
      if (states.includes(WORKING_MARKER)) {
        return WORKING_MARKER
      }
      if (states.includes(WAITING_MARKER)) {
        return WAITING_MARKER
      }
      return null
    }

    const applyMarker = async (marker) => {
      if (!(await ensureEnabled())) {
        return
      }

      if (appliedMarker === marker) {
        return
      }

      try {
        if (marker) {
          await execFileAsync("wt", ["config", "state", "marker", "set", marker], { cwd })
        } else {
          await execFileAsync("wt", ["config", "state", "marker", "clear"], { cwd })
        }
        appliedMarker = marker
      } catch (error) {
        console.warn(`[worktrunk] marker update failed: ${error?.message ?? error}`)
      }
    }

    const controller = new AbortController()
    void (async () => {
      for await (const event of ctx.event.subscribe({
        types: [
          "session.execution.started",
          "session.execution.succeeded",
          "session.execution.failed",
          "session.execution.interrupted",
          "session.deleted",
        ],
        signal: controller.signal,
      })) {
        try {
          const sessionID = event.data?.sessionID
          if (!sessionID || !(await inScope(sessionID))) {
            continue
          }

          switch (event.type) {
            case "session.execution.started":
              sessionStates.set(sessionID, WORKING_MARKER)
              break
            case "session.execution.succeeded":
            case "session.execution.failed":
            case "session.execution.interrupted":
              sessionStates.set(sessionID, WAITING_MARKER)
              break
            case "session.deleted":
              sessionScope.delete(sessionID)
              sessionStates.delete(sessionID)
              break
          }

          await applyMarker(desiredMarker())
        } catch (error) {
          console.warn(`[worktrunk] event handling failed: ${error?.message ?? error}`)
        }
      }
    })()

    await ctx.tool.transform((editor) => {
      editor.add({
        name: "worktrunk_guide",
        description: "Quick Worktrunk guidance for config files, commit generation, and project hooks.",
        input: {
          type: "object",
          properties: {
            topic: {
              type: "string",
              enum: ["overview", "commit-generation", "project-hooks", "worktree-paths"],
            },
          },
          additionalProperties: false,
        },
        async execute(input) {
          return { content: renderGuide(input.topic || "overview") }
        },
      })
    })

    return () => {
      controller.abort()
      try {
        if (appliedMarker != null) {
          spawnSync("wt", ["config", "state", "marker", "clear"], { cwd, stdio: "ignore" })
        }
      } catch {
        // Fail open on unload.
      }
    }
  },
})
