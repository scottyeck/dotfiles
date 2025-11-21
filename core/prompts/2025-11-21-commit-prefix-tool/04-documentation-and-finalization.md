# Task 4: Documentation and Finalization

## Overall Context

We are building a git commit message prefixing tool that automatically adds a prefix to every commit message. The prefix is stored in `~/.git-commit-prefix` as JSON with a timestamp. If the prefix is older than 3 hours, the system will prompt the user to renew or update it. This is part 4 of 4, focusing on documentation, testing, and finalization.

## Task

1. **Create Documentation:**
   - Add a README section or separate doc file explaining:
     - What the tool does
     - How to install it (`git-commit-prefix install`)
     - How to use it (set, show, clear commands)
     - How the expiration system works (3-hour threshold)
     - Examples of usage
   - Document the storage location (`~/.git-commit-prefix`)
   - Document that the prefix is global (works across all repos)

2. **Verify Integration:**
   - Ensure all three components work together:
     - `bin/git-commit-prefix-lib.sh` (from task 1)
     - `.git/hooks/commit-msg` (from task 2)
     - `bin/git-commit-prefix` (from task 3)
   - Test the full flow:
     - Install hook
     - Set a prefix
     - Make a commit (verify prefix is added)
     - Wait/simulate expiration
     - Make another commit (verify expiration prompt works)
     - Test renew and new prefix options

3. **Edge Case Handling:**
   - Verify graceful handling of:
     - Missing prefix file on first commit
     - Invalid JSON in prefix file
     - User cancellation during prompts
     - Non-existent git repository
     - Missing `.git/hooks` directory

4. **Final Checks:**
   - Ensure all scripts are executable
   - Ensure all scripts have proper shebangs (`#!/bin/bash` or `#!/bin/sh`)
   - Check that paths work correctly (relative vs absolute)
   - Verify cross-platform compatibility (macOS/Linux)

**File Locations:**
- Documentation: Add to existing README.md or create `docs/commit-prefix-tool.md` in the cloud repository
- Or add comments at the top of `bin/git-commit-prefix` with usage instructions

**Documentation Should Include:**
- Installation steps
- Basic usage examples
- Explanation of expiration system
- Troubleshooting common issues
- How to uninstall (remove hook, clear prefix file)

## Commit Instructions

- Do not commit changes immediately - await explicit instructions to do so
- When you do commit, prefix the commit with a consistent bracket-denoted prefix (e.g., "[commit-prefix-tool]") so that the group of commits related to this work can be easily identified.

