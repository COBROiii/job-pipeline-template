#!/usr/bin/env bash
# UserPromptSubmit + PostToolUse: make the main session check in with the user at least every 5 minutes. Answering an AskUserQuestion also restarts the clock.
#   UserPromptSubmit: The user has just spoken, so restart the clock.
#   PostToolUse: once 5 minutes have passed, tell Claude to finish the current step and stop with a check-in
#   (repeats every minute until the turn ends). Subagent tool calls are ignored; their parent turn is timed.
LIMIT=300

dir="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/.counts"
input=$(cat)

# No jq on Windows Git Bash, so pull fields out with sed.
field() { printf '%s' "$input" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"; }
[ -n "$(field agent_id)" ] && exit 0
session=$(field session_id | tr -cd 'A-Za-z0-9_-')
event=$(field hook_event_name | tr -cd 'A-Za-z')
[ -n "$session" ] || exit 0

mkdir -p "$dir" || exit 0
state="$dir/checkin-$session"
now=$(date +%s)

# State file holds "<turn start> <last warning>".
# Answering an AskUserQuestion is the user checking in too.
if [ "$event" = "UserPromptSubmit" ] || [ "$(field tool_name)" = "AskUserQuestion" ] || [ ! -f "$state" ]; then
  echo "$now 0" > "$state"
  exit 0
fi
read -r start warned < "$state"
case "$start$warned" in *[!0-9]*|'') echo "$now 0" > "$state"; exit 0 ;; esac

elapsed=$(( now - start ))
[ "$elapsed" -ge "$LIMIT" ] || exit 0
[ $(( now - warned )) -ge 60 ] || exit 0
echo "$start $now" > "$state"

msg="Check-in due: this turn has run $((elapsed / 60)) min without the user (limit $((LIMIT / 60)) min, CLAUDE.md rule 22). Finish only the step in progress (never leave a form half-filled or a file half-written), save state to the tracker and the job's log.md, then stop and check in: what got done, what is blocked and why, and what needs the user (logins, CAPTCHAs, approvals, ASK USER items), then what you'll do next. Don't start anything new."
printf '{"hookSpecificOutput":{"hookEventName":"%s","additionalContext":"%s"}}\n' "${event:-PostToolUse}" "$msg"
exit 0
