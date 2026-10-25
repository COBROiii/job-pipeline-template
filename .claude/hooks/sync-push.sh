#!/usr/bin/env bash
# SessionEnd: commit anything left uncommitted (e.g. hand edits) and push it.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0

git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "session: auto-sync $(date '+%Y-%m-%d %H:%M') from $(hostname)"
fi

# Push only if there are local commits GitHub doesn't have yet.
if [ -n "$(git log --oneline @{u}..HEAD 2>/dev/null)" ]; then
  if ! git push -q 2>/dev/null; then
    # Remote moved on: rebase onto it and retry; on conflict, back out and leave
    # the commit local for the next session's pull to surface.
    if git pull --rebase -q 2>/dev/null; then
      git push -q 2>/dev/null
    else
      git rebase --abort >/dev/null 2>&1
    fi
  fi
fi
exit 0
