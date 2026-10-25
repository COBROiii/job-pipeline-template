---
name: find
description: Search job boards for new roles in the user's tracks and add them to the tracker. No drafting.
argument-hint: "[track ID from config/criteria.md]"
disable-model-invocation: true
model: sonnet
---

Track (blank = all): `$ARGUMENTS`

Follow the rules in `CLAUDE.md`. Run `git pull --rebase` first; if it conflicts, stop and tell the user.

1. Run `job-seeker`: "Search per config/criteria.md (titles and sources there; track: <track or all>). Dedupe against applications/tracker.md by company + title + location. Add new rows with link, deadline, source, track and status `found`. No LinkedIn."
2. End with a short table of the new roles: company · role · location · deadline · one-line fit guess. Flag anything closing within 14 days. Don't draft anything. Suggest `/evaluate <link>` for a proper score or `/draft` / `/apply` for the ones they want.

End: commit and push (`find: <n> new roles`), then "Mode done. Run /clear before starting the next one."
