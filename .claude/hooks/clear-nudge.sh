#!/usr/bin/env bash
# UserPromptSubmit + PostToolUse: measure the main session's context after every prompt and tool call.
#   SOFT: suggest /clear at the next job/command boundary (once, until context drops back).
#   HARD: finish the current step, save state, commit, then stop and ask the user to /clear (repeats every 10 calls).
# Prints nothing below SOFT. Subagent tool calls are ignored (they have their own context).
SOFT=200000
HARD=300000

dir="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/.counts"
input=$(cat)

# No jq on Windows Git Bash, so pull fields out with sed.
field() { printf '%s' "$input" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"; }
[ -n "$(field agent_id)" ] && exit 0
session=$(field session_id | tr -cd 'A-Za-z0-9_-')
event=$(field hook_event_name | tr -cd 'A-Za-z')
transcript=$(field transcript_path | sed 's/\\\\/\\/g')
[ -n "$session" ] || exit 0

command -v cygpath >/dev/null 2>&1 && [ -n "$transcript" ] && transcript=$(cygpath -u "$transcript")
[ -f "$transcript" ] || exit 0

# Context = input + cache read + cache creation tokens of the last assistant turn.
usage=$(tail -n 300 "$transcript" | grep '"type":"assistant"' | grep '"usage"' | tail -n 1 | sed 's/.*"usage"[[:space:]]*:/ /')
num() { v=$(printf '%s' "$usage" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9][0-9]*" | head -n 1 | grep -o '[0-9]*$'); echo "${v:-0}"; }
tokens=$(( $(num input_tokens) + $(num cache_read_input_tokens) + $(num cache_creation_input_tokens) ))

# State file holds "<tier fired: 0/1/2> <calls since last hard warning>".
mkdir -p "$dir" || exit 0
read -r tier since 2>/dev/null < "$dir/$session"
tier=${tier:-0}; since=$(( ${since:-0} + 1 ))
case "$tier$since" in *[!0-9]*) tier=0; since=0 ;; esac

msg=""
if [ "$tokens" -lt "$SOFT" ]; then
  tier=0
elif [ "$tokens" -lt "$HARD" ]; then
  if [ "$tier" -lt 1 ]; then
    tier=1
    msg="Context check: ~$((tokens / 1000))k tokens of context (soft limit $((SOFT / 1000))k). Carry on with the current job. When it is finished (or the command ends), stop before starting the next job, make sure tracker/log.md are saved, and suggest the user runs /clear, then the same command for the remaining jobs."
  fi
elif [ "$tier" -lt 2 ] || [ "$since" -ge 10 ]; then
  tier=2; since=0
  msg="Context check: ~$((tokens / 1000))k tokens of context, over the hard limit ($((HARD / 1000))k). Finish only the step in progress (never leave a form half-submitted), write where you are and what is left to the job's log.md, update the tracker, commit and push. Then stop and ask the user to /clear and rerun the command; the job files carry the state."
fi
echo "$tier $since" > "$dir/$session"

[ -n "$msg" ] || exit 0
# Total tokens sent this session (sum over every call), for the user to see the cost.
# One call spans several transcript lines with the same message id, so count each id once.
total=$(grep '"type":"assistant"' "$transcript" | awk '
  match($0, /"id":"msg_[^"]*"/) { id = substr($0, RSTART, RLENGTH); if (id in seen) next; seen[id] = 1
    split("input_tokens cache_read_input_tokens cache_creation_input_tokens", k, " ")
    for (i = 1; i <= 3; i++) if (match($0, "\"" k[i] "\":[0-9]+")) { t = substr($0, RSTART, RLENGTH); sub(/.*:/, "", t); tot += t } }
  END { printf "%.1f", tot / 1e6 }')
msg="$msg Tell the user: ~$((tokens / 1000))k context, ~${total}M tokens used this session."
msg=$(printf '%s' "$msg" | sed 's/\\/\\\\/g; s/"/\\"/g')
printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "${event:-PostToolUse}" "$msg"
exit 0
