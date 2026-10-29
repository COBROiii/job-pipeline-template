#!/usr/bin/env bash
# SessionStart: bring this machine up to date with GitHub before any work starts.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
# Silence the "LF will be replaced by CRLF" warning on every commit (it only fills Claude's context).
git config core.safecrlf false

if out=$(git pull --rebase --autostash 2>&1); then
  msg="Sync: pulled latest from GitHub ($(echo "$out" | tail -1 | tr -cd '[:alnum:] .,-'))."
  printf '{"systemMessage":"%s"}\n' "$msg"
else
  git rebase --abort >/dev/null 2>&1
  msg="Sync: git pull --rebase FAILED (conflict or network). Nothing was discarded; local files are as they were before the pull. Tell the user before doing any work, per Syncing in CLAUDE.md."
  printf '{"systemMessage":"%s","hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"%s"}}\n' "$msg" "$msg"
fi
exit 0
