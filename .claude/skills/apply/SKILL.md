---
name: apply
description: Full application cycle for roles the user cares about. Draft and review (or pick up an existing draft), take their edits, fill the form in Chrome, and submit only on their explicit yes.
argument-hint: "<job link> [<job link> ...]"
disable-model-invocation: true
model: sonnet
---

Job links: `$ARGUMENTS`

Follow the rules in `CLAUDE.md`. For each link:

## 1–5. Draft and review
Follow `.claude/skills/draft/SKILL.md` steps 1–5 (it picks up an existing draft instead of starting over). If the saved draft is more than 7 days old, fetch the link once and run that file's "Still open?" check before anything else. For several links, draft them all first, then fill them one at a time.

## 6. The user's edits
Show the drafts (question → answer + word count), the review summary (verdict, 3 edits) and the CV to upload. Apply the user's edits to `answers.md` in their words. If `[CHECK` or `ASK USER` is left, list them and stop. If the answers scored under 80 (verdict not `submit`), say so plainly.
Ask: "Are these the final answers for <Company> — <Role>?" On yes, set status `ready`.

## 7. Fill the form (Chrome, via `form-filler`)
Browser work runs in the `form-filler` agent so screenshots and page text stay out of this session's context. Don't drive Chrome here yourself, except for a one-off check the user asks for.
1. Run `evaluator` mode `final <id>`. If it isn't `clear`, show the problems and stop.
2. Cover letter (CLAUDE.md rule 8): if one is needed and the user agrees for this job, run `form-filler` mode `pdf <id>`, then move the downloaded PDF to `applications/jobs/<id>/cover-letter.pdf`.
3. Run `form-filler` mode `fill <id> <link>` (say whether to upload the cover-letter PDF). It fills from answers.md and profile.md, uploads, and stops before Submit.
4. If it returns a question not covered by answers.md or profile.md, or a blocker (sign-in, CAPTCHA), ask the user, then rerun `fill` to continue; it resumes from `log.md`.
5. **Stop before Submit.** Tell the user what's filled and what's blank, and ask them to check the tab. Then ask: **"Submit <Company> — <Role> now? (yes / no)"**
6. Only an explicit yes in reply to that question counts: run `form-filler` mode `submit <id>` quoting their yes. Anything else leaves it unsubmitted.

## 8. After submission
Once the confirmation page or email is seen:
- Tracker: status `applied`, today's date in Notes; increase "Applications submitted" in the tracker header by 1 (it counts every `applied` + `rejected` row, however the job was applied to, and should match the rows in applied.xlsx).
- `log.md`: one line.
- `applications/applied.xlsx`: append a row with openpyxl to the sheet named after the job's track (create it by copying the `Applications` sheet's header row if it doesn't exist). Status `Application submitted`; Rolling/CV/Cover Letter as Yes/No; Answers = the answers.md path; copy the row above's formatting and extend the auto-filter. If the save fails, ask the user to close Excel.
- `answer-bank/past-answers.md`: under "## Pipeline answers (tagged)" add `### <Company> — <Role> (<date>)`, then each final answer as `**[<type>]** <question>` + the answer. Types: motivation, why-company, teamwork, technical-project, failure, leadership, other.
- Update the tracker header's coverage line (count per type). When motivation, teamwork, technical-project, failure and why-company each have at least 2, tell the user: "The answer bank now covers the common question types, so /apply-lite is ready for mass-apply roles."

End: commit and push (`apply: <company> <role>`), then "Mode done." (see CLAUDE.md rule 15 on /clear)
