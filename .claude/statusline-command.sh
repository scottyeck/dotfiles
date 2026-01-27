#!/bin/bash
# Make sure this file is executable: chmod +x ~/.claude/statusline-command.sh

# Claude Code statusline script - lightweight and optimized
# Reads JSON input from stdin and outputs a formatted status line to stdout
# Add to your ~/.claude/settings.json
#
# "statusLine": {
#   "type": "command",
#   "command": "bash ~/.claude/statusline-command.sh"
# }
#
# SYMBOL LEGEND:
# 🤖 Model indicator
# 📁 Current directory
# Git status icons:
#   ✓  Clean repository (green)
#   ⚡ Changes present (yellow)
#   ⚠  Merge conflicts (red)
#   ?N Untracked files count (gray)
#   ~N Modified files count (yellow)
#   +N Staged files count (green)
#   ↑N Commits ahead of remote (green)
#   ↓N Commits behind remote (yellow)
#   ↕N/M Diverged from remote (yellow)
#   PR#N Open pull request number (cyan)
# 🌳 Git worktree indicator
# 🐍 Python virtual environment
# Context window usage (scaled so 100% = auto-compaction threshold):
#   🟢 0-49% until compaction (green)
#   🟠 50-74% until compaction (yellow)
#   🟡 75-89% until compaction (yellow)
#   🔴 90-100% until compaction (red)
#   Format: 🟢 50K/25% (tokens/percentage to compaction)

# Debug mode - set STATUSLINE_DEBUG=1 to see raw values
DEBUG="${STATUSLINE_DEBUG:-0}"

# Configuration options
CHECK_GITHUB_PR="${STATUSLINE_CHECK_PR:-0}"  # Set to 1 to enable PR checks

# Constants
readonly MAX_PATH_LENGTH=50
readonly MAX_VENV_LENGTH=15
readonly COMPACTION_THRESHOLD=77.5  # Auto-compaction triggers when 22.5% buffer remains

# Helper function to parse git status efficiently
parse_git_status() {
    local status_output="$1"
    if [[ -z "$status_output" ]]; then
        echo "untracked=0 modified=0 staged=0 conflicts=0"
        return
    fi
    
    echo "$status_output" | awk '
        BEGIN { untracked=0; modified=0; staged=0; conflicts=0 }
        /^\?\?/ { untracked++ }
        /^.M|^ M/ { modified++ }
        /^[ADMR]/ { staged++ }
        /^UU|^AA|^DD/ { conflicts++ }
        END {
            print "untracked=" untracked " modified=" modified " staged=" staged " conflicts=" conflicts
        }
    '
}

# Color codes for better visual separation
readonly BLUE='\033[94m'      # Bright blue for model/main info
readonly GREEN='\033[92m'     # Bright green for clean git status
readonly YELLOW='\033[93m'    # Bright yellow for modified git status
readonly RED='\033[91m'       # Bright red for conflicts/errors
readonly PURPLE='\033[95m'    # Bright purple for directory
readonly CYAN='\033[96m'      # Bright cyan for python venv
readonly WHITE='\033[97m'     # Bright white for time
readonly GRAY='\033[37m'      # Gray for separators
readonly RESET='\033[0m'      # Reset colors
readonly BOLD='\033[1m'       # Bold text

# Dim color codes for context window (less distracting)
readonly DIM_GREEN='\033[32m'
readonly DIM_YELLOW='\033[33m'
readonly DIM_RED='\033[31m'

# Read JSON input from stdin
input=$(cat)

# Extract data from JSON input using jq
model_name=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // "."')

# Extract context window information
# Use pre-calculated used_percentage for accuracy (matches /context better)
# Manual token calculation kept for display purposes
context_window_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
used_percentage=$(echo "$input" | jq -r '.context_window.used_percentage // 0')
current_usage=$(echo "$input" | jq '.context_window.current_usage')

# Calculate tokens for display (even though we use pre-calculated percentage)
if [[ "$current_usage" != "null" ]]; then
    current_input=$(echo "$current_usage" | jq -r '.input_tokens // 0')
    cache_creation=$(echo "$current_usage" | jq -r '.cache_creation_input_tokens // 0')
    cache_read=$(echo "$current_usage" | jq -r '.cache_read_input_tokens // 0')
    current_context_tokens=$((current_input + cache_creation + cache_read))
else
    # Fallback: use total_input_tokens as approximation
    current_context_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
fi


# Get current directory relative to home directory with smart truncation
if [[ "$current_dir" == "$HOME"* ]]; then
    # Replace home path with ~ for display
    # Use sed for more reliable substitution
    dir_display=$(echo "$current_dir" | sed "s|^$HOME|~|")
else
    # Keep full path if not under home directory
    dir_display="$current_dir"
fi

# Truncate long paths intelligently
if [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]]; then
    # For home paths, show ~/.../<parent>/<current>
    if [[ "$dir_display" == "~/"* ]]; then
        parent=$(basename "$(dirname "$current_dir")")
        current=$(basename "$current_dir")
        dir_display="~/.../${parent}/${current}"

        # If still too long, just show current directory
        [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]] && dir_display="~/.../${current}"
    else
        # For absolute paths, show .../<parent>/<current>
        parent=$(basename "$(dirname "$current_dir")")
        current=$(basename "$current_dir")
        dir_display=".../${parent}/${current}"

        # If still too long, just show current directory
        [[ ${#dir_display} -gt $MAX_PATH_LENGTH ]] && dir_display=".../${current}"
    fi
fi
# Get git status and worktree information with enhanced detection
git_info=""
if git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git -C "$current_dir" branch --show-current 2>/dev/null)

    # If no branch (detached HEAD), show short commit hash
    if [[ -z "$branch" ]]; then
        branch=$(git -C "$current_dir" rev-parse --short HEAD 2>/dev/null)
        branch="detached:${branch}"
    fi

    # Enhanced worktree detection
    worktree_info=""
    git_dir=$(git -C "$current_dir" rev-parse --git-dir 2>/dev/null)

    # Check if we're in a worktree
    if [[ "$git_dir" == *".git/worktrees/"* ]] || [[ -f "$git_dir/gitdir" ]]; then
        worktree_info=" ${CYAN}🌳${RESET}"
    fi

    if [[ -n "$branch" ]]; then
        # Comprehensive git status check
        # Git status format: XY filename
        # X = status of staging area, Y = status of working tree
        git_status=$(git -C "$current_dir" status --porcelain 2>/dev/null)

        # Parse git status using helper function
        read -r untracked modified staged conflicts < <(parse_git_status "$git_status" | awk '{
            for (i=1; i<=NF; i++) {
                split($i, kv, "=")
                if (kv[1] == "untracked") untracked=kv[2]
                else if (kv[1] == "modified") modified=kv[2]
                else if (kv[1] == "staged") staged=kv[2]
                else if (kv[1] == "conflicts") conflicts=kv[2]
            }
            print untracked, modified, staged, conflicts
        }')

        # Debug output
        if [[ "$DEBUG" == "1" ]]; then
            echo "DEBUG: Git Status Raw:" >&2
            echo "$git_status" >&2
            echo "DEBUG: Counts - Staged:$staged Modified:$modified Untracked:$untracked Conflicts:$conflicts" >&2
        fi

        # Check for ahead/behind status
        ahead_behind=""
        upstream=$(git -C "$current_dir" rev-parse --abbrev-ref '@{u}' 2>/dev/null)
        if [[ -n "$upstream" ]]; then
            ahead=$(git -C "$current_dir" rev-list --count '@{u}..HEAD' 2>/dev/null)
            behind=$(git -C "$current_dir" rev-list --count 'HEAD..@{u}' 2>/dev/null)

            if [[ "$ahead" -gt 0 ]] && [[ "$behind" -gt 0 ]]; then
                ahead_behind=" ${YELLOW}↕${ahead}/${behind}${RESET}"
            elif [[ "$ahead" -gt 0 ]]; then
                ahead_behind=" ${GREEN}↑${ahead}${RESET}"
            elif [[ "$behind" -gt 0 ]]; then
                ahead_behind=" ${YELLOW}↓${behind}${RESET}"
            fi
        fi
        
        # Check for rebase/merge status
        rebase_merge_info=""
        if [[ -d "$current_dir/.git/rebase-merge" ]] || [[ -d "$current_dir/.git/rebase-apply" ]]; then
            rebase_merge_info=" ${RED}🔀REBASE${RESET}"
        elif [[ -f "$current_dir/.git/MERGE_HEAD" ]]; then
            rebase_merge_info=" ${RED}🔀MERGE${RESET}"
        elif [[ -f "$current_dir/.git/CHERRY_PICK_HEAD" ]]; then
            rebase_merge_info=" ${RED}🍒CHERRY${RESET}"
        elif [[ -f "$current_dir/.git/BISECT_LOG" ]]; then
            rebase_merge_info=" ${YELLOW}🔍BISECT${RESET}"
        fi

        # Check for open PRs using GitHub CLI if available and enabled
        pr_info=""
        if [[ "$CHECK_GITHUB_PR" == "1" ]] && command -v gh >/dev/null 2>&1; then
            # Only check for PRs if we're in a GitHub repo
            remote_url=$(git -C "$current_dir" config --get remote.origin.url 2>/dev/null)
            if [[ "$remote_url" == *"github.com"* ]]; then
                # Quick PR check with timeout (gh caches this, so it's usually fast after first run)
                pr_number=$(timeout 0.5 gh pr view --json number -q .number 2>/dev/null)
                if [[ -n "$pr_number" ]]; then
                    pr_info=" ${CYAN}PR#${pr_number}${RESET}"
                fi
            fi
        fi

        # Build status indicators in compact format
        status_indicators=""
        if [[ "$conflicts" -gt 0 ]]; then
            git_color="${RED}"
            git_icon="⚠"
            status_indicators="${RED}⚠${conflicts}${RESET}"
        elif [[ -n "$git_status" ]]; then
            git_color="${YELLOW}"
            git_icon="⚡"

            # Build compact status string: ?N ~N +N
            status_parts=()
            [[ "$untracked" -gt 0 ]] && status_parts+=("${GRAY}?${untracked}${RESET}")
            [[ "$modified" -gt 0 ]] && status_parts+=("${YELLOW}~${modified}${RESET}")
            [[ "$staged" -gt 0 ]] && status_parts+=("${GREEN}+${staged}${RESET}")

            # Join status parts with spaces
            if [[ ${#status_parts[@]} -gt 0 ]]; then
                status_indicators=$(IFS=" "; echo "${status_parts[*]}")
            fi
        else
            git_color="${GREEN}"
            git_icon="✓"
        fi

        # Build git info components
        git_branch_section="${git_color}${git_icon} ${branch}${RESET}${worktree_info}${rebase_merge_info}${pr_info}"
        
        # Collect additional git info sections that have content
        git_extra_sections=()
        
        # Only add status section if there are changes
        if [[ -n "$status_indicators" ]]; then
            git_extra_sections+=("${status_indicators}")
        fi

        # Only add sync section if there's sync info
        if [[ -n "$ahead_behind" ]]; then
            git_extra_sections+=("${ahead_behind# }")  # Remove leading space
        fi

        # Build git info starting with branch
        git_info=" ${GRAY}│${RESET} ${git_branch_section}"
        
        # Add additional sections with separators only if they exist
        for section in "${git_extra_sections[@]}"; do
            git_info="${git_info} ${GRAY}│${RESET} ${section}"
        done
    fi
fi

# Get Python virtual environment info
venv_info=""
if [[ -n "$VIRTUAL_ENV" ]]; then
    venv_name=$(basename "$VIRTUAL_ENV")
    # Smart truncation for long venv names
    if [[ ${#venv_name} -gt $MAX_VENV_LENGTH ]]; then
        venv_name="${venv_name:0:$((MAX_VENV_LENGTH-3))}..."
    fi
    venv_info=" ${GRAY}│${RESET} ${CYAN}🐍${venv_name}${RESET}"
fi

# Build context window display using pre-calculated percentage
# Scale percentage so 100% = compaction threshold (more useful than raw context %)
context_info=""
# Scale percentage relative to compaction threshold, then round to integer
scaled_percentage=$(awk "BEGIN {printf \"%.0f\", ($used_percentage / $COMPACTION_THRESHOLD) * 100}")
usage_percent="$scaled_percentage"
if [[ "$usage_percent" -gt 0 ]]; then
    # Format tokens for display (e.g., 50K, 1.2M)
    if [[ "$current_context_tokens" -ge 1000000 ]]; then
        tokens_display=$(awk "BEGIN {printf \"%.1fM\", $current_context_tokens/1000000}")
    elif [[ "$current_context_tokens" -ge 1000 ]]; then
        tokens_display=$(awk "BEGIN {printf \"%.0fK\", $current_context_tokens/1000}")
    else
        tokens_display="${current_context_tokens}"
    fi

    # Choose color based on usage percentage (using dim colors)
    if [[ "$usage_percent" -ge 90 ]]; then
        context_color="${DIM_RED}"
        context_icon="🔴"
    elif [[ "$usage_percent" -ge 75 ]]; then
        context_color="${DIM_YELLOW}"
        context_icon="🟡"
    elif [[ "$usage_percent" -ge 50 ]]; then
        context_color="${DIM_YELLOW}"
        context_icon="🟠"
    else
        context_color="${DIM_GREEN}"
        context_icon="🟢"
    fi

    context_info=" ${GRAY}│${RESET} ${context_color}${context_icon} ${tokens_display}/${usage_percent}%${RESET}"
fi





# Build output string with smart separators
output_string=" ${BLUE}🤖${RESET} ${BOLD}${BLUE}${model_name}${RESET} ${GRAY}│${RESET} ${PURPLE}📁 ${dir_display}${RESET}"

# Add git info if present
[[ -n "$git_info" ]] && output_string="${output_string}${git_info}"

# Add venv info if present (already includes separator)
[[ -n "$venv_info" ]] && output_string="${output_string}${venv_info}"

# Add context window info if present
[[ -n "$context_info" ]] && output_string="${output_string}${context_info}"

# Output ends with trailing space for visual comfort
output_string="${output_string} "

# Output the complete string
echo -e "$output_string"
