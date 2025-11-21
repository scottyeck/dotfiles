# Task 1: Create Core Prefix Storage Utilities

## Overall Context

We are building a git commit message prefixing tool that automatically adds a prefix to every commit message. The prefix is stored in `~/.git-commit-prefix` as JSON with a timestamp. If the prefix is older than 3 hours, the system will prompt the user to renew or update it. This is part 1 of 4, focusing on the core storage utilities.

## Task

Create a reusable shell script library (`bin/git-commit-prefix-lib.sh`) that provides functions for managing the prefix storage file at `~/.git-commit-prefix`.

**Storage Format:**
The file should store JSON in this format:
```json
{
  "prefix": "[feature]",
  "updated_at": "2024-01-15T10:30:00Z"
}
```

**Required Functions:**
1. `read_prefix_file()` - Reads and parses the JSON file, returns prefix and timestamp (or empty if file doesn't exist)
2. `write_prefix_file(prefix, timestamp)` - Writes the prefix and timestamp to the file
3. `get_current_timestamp()` - Returns current timestamp in ISO 8601 format
4. `calculate_hours_since(timestamp)` - Calculates hours elapsed since the given timestamp
5. `is_prefix_expired(timestamp)` - Returns true if timestamp is older than 3 hours

**Requirements:**
- Must be bash/sh compatible (works on macOS/Linux)
- Handle missing file gracefully (return empty values)
- Handle invalid JSON gracefully (return empty values or error)
- Use ISO 8601 timestamps for cross-platform compatibility
- Functions should be sourced by other scripts, not executed directly

**File Location:**
- Create: `bin/git-commit-prefix-lib.sh` in the cloud repository (`/Users/scottyeck/git/sl/cloud/bin/git-commit-prefix-lib.sh`)

**Testing:**
- Test that functions work correctly with valid JSON
- Test that functions handle missing file
- Test that functions handle invalid JSON
- Test timestamp calculations are accurate

## Commit Instructions

- Do not commit changes immediately - await explicit instructions to do so
- When you do commit, prefix the commit with a consistent bracket-denoted prefix (e.g., "[commit-prefix-tool]") so that the group of commits related to this work can be easily identified.

