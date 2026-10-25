#!/usr/bin/env bash
# UserPromptSubmit: if the context is over 100k tokens, nudge Claude to suggest
# /clear once the current task is done, then stay quiet for 5 prompts. Prints nothing otherwise.
dir="${CLAUDE_PROJECT_DIR:-.}/.claude/hooks/.counts"
input=$(cat)

# No jq on Windows Git Bash, so pull the two fields out with sed.
field() { printf '%s' "$input" | tr -d '\n' | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p"; }
session=$(field session_id | tr -cd 'A-Za-z0-9_-')
transcript=$(field transcript_path | sed 's/\\\\/\\/g')
[ -n "$session" ] || exit 0

# Count file holds "<prompt count> <count at last nudge>".
mkdir -p "$dir" || exit 0
read -r count last 2>/dev/null < "$dir/$session"
count=$(( ${count:-0} + 1 )); last=${last:-0}
case "$count$last" in *[!0-9]*) count=1; last=0 ;; esac
echo "$count $last" > "$dir/$session"

command -v cygpath >/dev/null 2>&1 && [ -n "$transcript" ] && transcript=$(cygpath -u "$transcript")
[ -f "$transcript" ] || exit 0

# Context = input + cache read + cache creation tokens of the last assistant turn.
usage=$(tail -n 300 "$transcript" | grep '"type":"assistant"' | grep '"usage"' | tail -n 1 | sed 's/.*"usage"[[:space:]]*:/ /')
num() { v=$(printf '%s' "$usage" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*[0-9][0-9]*" | head -n 1 | grep -o '[0-9]*$'); echo "${v:-0}"; }
tokens=$(( $(num input_tokens) + $(num cache_read_input_tokens) + $(num cache_creation_input_tokens) ))

if [ "$tokens" -gt 100000 ] && { [ "$last" -eq 0 ] || [ $((count - last)) -ge 5 ]; }; then
  echo "$count $count" > "$dir/$session"
  echo "Note for Claude: this session is getting long (~$((tokens / 1000))k tokens of context). Once the current task is finished, suggest that the user saves anything unsaved and runs /clear."
fi
exit 0
