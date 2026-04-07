import { spawnSync } from "node:child_process"
import { tool } from "@opencode-ai/plugin"

const WORKING_MARKER = "🤖"
const WAITING_MARKER = "💬"

/**
 * Local OpenCode port of the upstream Claude Worktrunk plugin.
 *
 * It mirrors the branch activity markers used by `wt list` and exposes
 * a small guidance tool as the OpenCode equivalent of the Claude skill.
 */
export const WorktrunkPlugin = async ({ $, directory, worktree }) => {
  const cwd = worktree || directory
  const sessionStates = new Map()
  let enabledPromise = null
  let appliedMarker = undefined

  const ensureEnabled = async () => {
    if (!enabledPromise) {
      enabledPromise = (async () => {
        const wtCheck = await $`which wt`.quiet().nothrow()
        if (wtCheck.exitCode !== 0) {
          return false
        }

        const gitCheck = await $`git rev-parse --is-inside-work-tree`.cwd(cwd).quiet().nothrow()
        return gitCheck.exitCode === 0
      })()
    }

    return enabledPromise
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

    const result = marker
      ? await $`wt config state marker set ${marker}`.cwd(cwd).quiet().nothrow()
      : await $`wt config state marker clear`.cwd(cwd).quiet().nothrow()

    if (result.exitCode === 0) {
      appliedMarker = marker
    }
  }

  const updateMarker = async () => {
    await applyMarker(desiredMarker())
  }

  const clearMarkerSync = () => {
    try {
      if (appliedMarker == null) {
        return
      }

      spawnSync("wt", ["config", "state", "marker", "clear"], {
        cwd,
        stdio: "ignore",
      })
    } catch {
      // Fail open on shutdown.
    }
  }

  process.once("beforeExit", clearMarkerSync)
  process.once("exit", clearMarkerSync)

  return {
    event: async ({ event }) => {
      switch (event.type) {
        case "session.status": {
          const { sessionID, status } = event.properties

          if (status.type === "busy" || status.type === "retry") {
            sessionStates.set(sessionID, WORKING_MARKER)
          }

          if (status.type === "idle") {
            sessionStates.set(sessionID, WAITING_MARKER)
          }

          await updateMarker()
          break
        }

        case "session.idle": {
          sessionStates.set(event.properties.sessionID, WAITING_MARKER)
          await updateMarker()
          break
        }

        case "session.deleted": {
          sessionStates.delete(event.properties.info.id)
          await updateMarker()
          break
        }
      }
    },

    tool: {
      worktrunk_guide: tool({
        description: "Quick Worktrunk guidance for config files, commit generation, and project hooks.",
        args: {
          topic: tool.schema
            .enum(["overview", "commit-generation", "project-hooks", "worktree-paths"])
            .optional(),
        },
        async execute(args) {
          const topic = args.topic || "overview"

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
        },
      }),
    },
  }
}

// Do not export default. OpenCode calls every named export as a plugin entrypoint.
