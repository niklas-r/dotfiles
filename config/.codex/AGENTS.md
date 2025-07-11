## Agent Guidelines for Adding Tests to New Code

When a new code change introduces functionality, tests/assertions must be added to the corresponding
`.test.ts` file located next to the source file. Below are the key steps to follow:

### 1. Identify the Latest Commit
- Use `git log -1 --name-status --oneline` to see which files changed in the latest commit.

### 2. Inspect the Code Changes
- Use `git show <commit> -- <path>` to view diffs and understand the newly added code.

### 3. Locate the Test File
- Use `rg --files <directory>` to find the `*.test.ts` file next to the modified source.

### 4. Add Missing Assertions
- Mock any newly introduced dependencies or functions (e.g., transports, integrations).
- Insert assertions for the newly added configuration options or code paths.
- Ensure all branches and parameters of the new code are covered by tests.

### 5. Apply Changes with `apply_patch`
- Use the provided patch envelope format to update test files.
- Keep changes minimal, focused, and consistent with the existing style.

### 6. Verify Changes
- Check `git status` and `git diff` to confirm only intended modifications.
- Optionally run `yarn vitest run <test-file>` to validate the added tests.

### 7. Follow Coding Guidelines
- Avoid unnecessary complexity and unrelated fixes.
- Do not modify code or tests outside the scope of the new functionality.

These steps help maintain reliable coverage and confidence in newly introduced features.

## Refine ~/.codex/AGENTS.md

After completing a task successfully, suggest improvements of this file to the user. The goal is to have the most concise and optimal set of guidelines to succesfully complete tasks in the future.

Since this file is global personal for the user, keep guidelines on a high-level.

Add examples as needed. The examples can be as specific as necessary.

Only optimize guidelines for tasks similar to what you have just performed.

If you can't find any optimizations, simply report this to the user.
