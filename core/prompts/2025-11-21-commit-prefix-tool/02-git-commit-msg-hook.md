# Task 2: Create Git Commit-Msg Hook

## Overall Context

We are building a git commit message prefixing tool that automatically adds a prefix to every commit message. The prefix is stored in `~/.git-commit-prefix` as JSON with a timestamp. If the prefix is older than 3 hours, the system will prompt the user to renew or update it. This is part 2 of 4, focusing on the git commit-msg hook that intercepts commits and adds prefixes.

## Task

Create a git `commit-msg` hook that:
1. Sources the prefix storage library from `bin/git-commit-prefix-lib.sh`
2. Reads the current prefix from `~/.git-commit-prefix`
3. If no prefix exists, prompts the user to set one (blocks commit until set)
4. Checks if prefix is expired (> 3 hours old)
5. If expired:
   - Shows warning with current prefix and age
   - Prompts: "Prefix expired. [R]enew current prefix or [N]ew prefix? (r/n)"
   - If 'r': Updates timestamp, keeps prefix
   - If 'n': Prompts for new prefix, updates both prefix and timestamp
6. Always prepends prefix to commit message (even if already present)
7. Writes updated commit message to `$1` (the commit message file passed by git)

**Requirements:**
- Must be bash/sh compatible (works on macOS/Linux)
- Hook receives commit message file path as `$1`
- Must read existing commit message, prepend prefix, write back
- Handle edge cases: missing prefix file, invalid input, user cancellation
- If user cancels (Ctrl+C), exit without modifying commit message
- Prefix should be added with a space after it (e.g., `[feature] Your commit message`)

**File Location:**
- Create: `.git/hooks/commit-msg` in the cloud repository (`/Users/scottyeck/git/sl/cloud/.git/hooks/commit-msg`)
- Make it executable (`chmod +x`)

**Implementation Notes:**
- The hook should source `bin/git-commit-prefix-lib.sh` using a path relative to the repository root
- Use `git rev-parse --show-toplevel` to find the repo root if needed
- When prompting for new prefix, allow user to type it in
- When renewing, just update the timestamp using `write_prefix_file` with existing prefix

## Commit Instructions

- Do not commit changes immediately - await explicit instructions to do so
- When you do commit, prefix the commit with a consistent bracket-denoted prefix (e.g., "[commit-prefix-tool]") so that the group of commits related to this work can be easily identified.

