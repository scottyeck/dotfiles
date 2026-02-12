#!/bin/bash
DEBUG="${CLAUDE_NOTIFY_DEBUG:-false}"
LOG="$HOME/.claude/notify-debug.log"

export PATH="/opt/homebrew/bin:$PATH"
export NVM_DIR="$HOME/.nvm"
. "$NVM_DIR/nvm.sh"

if [ "$DEBUG" = "true" ]; then
  echo "--- click at $(date) ---" >> "$LOG"
  echo "ARGS: $@" >> "$LOG"
  /usr/local/bin/claudes "$@" >> "$LOG" 2>&1
  echo "EXIT: $?" >> "$LOG"
else
  /usr/local/bin/claudes "$@" >/dev/null 2>&1
fi
