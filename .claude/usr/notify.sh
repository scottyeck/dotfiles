#!/bin/bash
LOG="$HOME/.claude/notify-debug.log"
INPUT=$(cat)
echo "--- notify at $(date) ---" >> "$LOG"
echo "INPUT: $INPUT" >> "$LOG"
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id')
CWD=$(echo "$INPUT" | jq -r '.cwd')

CACHE="$HOME/.claude/sessions-cache.json"

if [ -f "$CACHE" ]; then
  # Try matching by session_id first (exact match)
  SESSION=$(jq -r --arg sid "$SESSION_ID" \
    '.sessions[] | select(.sessionId == $sid)' "$CACHE" 2>/dev/null)

  # Fall back to cwd match
  if [ -z "$SESSION" ]; then
    SESSION=$(jq -r --arg cwd "$CWD" \
      '[.sessions[] | select(.cwd == $cwd)] | first' "$CACHE" 2>/dev/null)
    [ "$SESSION" = "null" ] && SESSION=""
  fi
fi

CLICK="$HOME/.claude/usr/notify-click.sh"

if [ -n "$SESSION" ]; then
  PROJECT=$(echo "$SESSION" | jq -r '.projectName')
  SID=$(echo "$SESSION" | jq -r '.sessionId')
  PROMPT=$(echo "$SESSION" | jq -r '.firstPrompt' | cut -c1-50)
  TITLE="⏳ $PROJECT"
  MESSAGE="🤖 $PROMPT"
  JUMP_CMD="CLAUDE_NOTIFY_DEBUG=false $CLICK --session-id $SID"
else
  PROJECT=$(basename "$CWD")
  TITLE="⏳ $PROJECT"
  MESSAGE="🤖 Claude Code needs your attention"
  JUMP_CMD="CLAUDE_NOTIFY_DEBUG=false $CLICK $PROJECT"
fi

echo "TITLE: $TITLE" >> "$LOG"
echo "MESSAGE: $MESSAGE" >> "$LOG"
echo "JUMP_CMD: $JUMP_CMD" >> "$LOG"

# Remove previous notification for this session before sending a new one
/opt/homebrew/bin/terminal-notifier -remove "$SESSION_ID" >/dev/null 2>&1

/opt/homebrew/bin/terminal-notifier \
  -title "$TITLE" \
  -message "$MESSAGE" \
  -sound "Funk" \
  -group "$SESSION_ID" \
  -execute "$JUMP_CMD"

echo "terminal-notifier EXIT: $?" >> "$LOG"
