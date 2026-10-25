---
name: evaluate
description: Fit score for a job link, the full review panel for an application folder, or (no argument) the search-wide report and status.
argument-hint: "<job link> | <applications/jobs/<id>> | (blank for report + status)"
disable-model-invocation: true
model: sonnet
---

Target: `$ARGUMENTS`

Follow the rules in `CLAUDE.md`. Run `git pull --rebase` first.

- **Job link** → find or add its tracker row, then `evaluator` mode `fit` for that ID. Show score, grade and the one-line reason.
- **Application folder with `answers.md`** → the full panel: three `evaluator` subagents at the same time (`review ats <id>`, `review hiring-manager <id>`, `review technical <id>`), then `chair <id>`, saved to `review.md`. Show verdict, score, hard fails and the 3 edits.
- **Blank** → `evaluator` mode `report`, then from the tracker: counts per status, completed applications, A/B jobs closing within 14 days that aren't applied, `blocked` items, and drafts whose verdict isn't `submit`.

End: commit and push (`evaluate: <summary>`), then "Mode done. Run /clear before starting the next one."
