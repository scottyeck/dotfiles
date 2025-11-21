# Task 3: Create CLI Helper Tool

## Overall Context

We are building a git commit message prefixing tool that automatically adds a prefix to every commit message. The prefix is stored in `~/.git-commit-prefix` as JSON with a timestamp. If the prefix is older than 3 hours, the system will prompt the user to renew or update it. This is part 3 of 4, focusing on the CLI helper tool for managing the prefix.

## Task

Create a CLI tool `bin/git-commit-prefix` that provides commands for managing the commit prefix. The tool should:

1. Source the prefix storage library from `bin/git-commit-prefix-lib.sh`
2. Support the following commands:
   - `git-commit-prefix set <prefix>` - Set/update prefix and timestamp
   - `git-commit-prefix show` - Display current prefix, timestamp, and age (hours since update)
   - `git-commit-prefix clear` - Remove the prefix file (`~/.git-commit-prefix`)
   - `git-commit-prefix install` - Install the commit-msg hook to `.git/hooks/commit-msg` in the current repository

**Requirements:**
- Must be bash/sh compatible (works on macOS/Linux)
- Make it executable (`chmod +x`)
- For `set`: Update both prefix and timestamp to current time
- For `show`: Display in a readable format, show age in hours (e.g., "Prefix: [feature], Updated: 2.5 hours ago")
- For `clear`: Remove the file, confirm deletion
- For `install`: Copy the hook from the repo to `.git/hooks/commit-msg`, make it executable, handle case where hook already exists (prompt to overwrite)
- Handle invalid commands with helpful usage message
- Use `git rev-parse --show-toplevel` to find repo root for install command

**File Location:**
- Create: `bin/git-commit-prefix` in the cloud repository (`/Users/scottyeck/git/sl/cloud/bin/git-commit-prefix`)

**Usage Examples:**
```bash
git-commit-prefix set "[feature]"
git-commit-prefix show
git-commit-prefix clear
git-commit-prefix install
```

**Implementation Notes:**
- The script should find its own location to source the library file
- For `install`, the hook should be copied from the repository's `.git/hooks/commit-msg` (which will be created in task 2)
- If installing, check if `.git/hooks` exists, create if needed
- Provide clear error messages for invalid operations

## Commit Instructions

- Do not commit changes immediately - await explicit instructions to do so
- When you do commit, prefix the commit with a consistent bracket-denoted prefix (e.g., "[commit-prefix-tool]") so that the group of commits related to this work can be easily identified.

