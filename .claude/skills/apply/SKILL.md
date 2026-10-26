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
Follow `.claude/skills/draft/SKILL.md` steps 1–5 (it picks up an existing draft instead of starting over). For several links, draft them all first, then fill them one at a time.

## 6. The user's edits
Show the drafts (question → answer + word count), the review summary (verdict, 3 edits) and the CV to upload. Apply the user's edits to `answers.md` in their words. If `[CHECK` or `ASK USER` is left, list them and stop. If the answers scored under 80 (verdict not `submit`), say so plainly.
Ask: "Are these the final answers for <Company> — <Role>?" On yes, set status `ready`.

## 7. Fill the form (Chrome)
1. Run `evaluator` mode `final <id>`. If it isn't `clear`, show the problems and stop.
2. Open the form (resume a saved draft if there is one). Fill routine fields and diversity/consent questions from `config/profile.md`, paste each approved answer **exactly as in answers.md**, upload the CV (`applications/jobs/<id>/cv.pdf` if the user saved a tailored one). Cover letter: only as a PDF, per the cover letter rule in `CLAUDE.md`. Leave anything marked "For the user".
3. If the form asks for something not in answers.md or profile.md, stop and ask.
4. **Stop before Submit.** Tell the user what's filled and what's blank, and ask them to check the tab. Then ask: **"Submit <Company> — <Role> now? (yes / no)"**
5. Only an explicit yes in reply to that question counts: click Submit once. Anything else leaves it unsubmitted.

## 8. After submission
Once the confirmation page or email is seen:
- Tracker: status `applied`, today's date in Notes; increase "Completed applications" in the tracker header by 1.
- `log.md`: one line.
- `applications/applied.xlsx`: append a row with openpyxl to the sheet named after the job's track (create it by copying the `Applications` sheet's header row if it doesn't exist). Status `Application submitted`; Rolling/CV/Cover Letter as Yes/No; Answers = the answers.md path; copy the row above's formatting and extend the auto-filter. If the save fails, ask the user to close Excel.
- `answer-bank/past-answers.md`: under "## Pipeline answers (tagged)" add `### <Company> — <Role> (<date>)`, then each final answer as `**[<type>]** <question>` + the answer. Types: motivation, why-company, teamwork, technical-project, failure, leadership, other.
- Update the tracker header's coverage line (count per type). When motivation, teamwork, technical-project, failure and why-company each have at least 2, tell the user: "The answer bank now covers the common question types, so /apply-lite is ready for mass-apply roles."

End: commit and push (`apply: <company> <role>`), then "Mode done. Run /clear before starting the next one."
