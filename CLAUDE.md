# Job application pipeline — <Your Name>

Job applications for <TODO: e.g. a 2027 graduate start>. Commands: `/find`, `/evaluate`, `/draft`, `/apply`, `/apply-lite` (see `USER_GUIDE.md`).

## Who
<TODO: two or three lines about yourself. e.g. "Alex Smith: final-year MEng Mechanical Engineering at the University of X, graduating 2027; previously a summer intern at Y. London-based, UK national.">

`answer-bank/facts.md` is the source of truth for every date, number and status.

**Tracks, in priority order:** <TODO: the track IDs from config/criteria.md, e.g. (1) engineering, (2) consulting, (3) fallback: ...>

## Layout
- `config/criteria.md` (tracks, search titles, sources, exclusions) · `config/profile.md` (form fields, diversity answers)
- `applications/tracker.md` (one row per job) · `applications/jobs/<id>/` (posting, questions, fit, answers, review, log) · `applications/applied.xlsx` (submitted only, one sheet per track)
- `answer-bank/` (read its README first) · `cv/SWAPS.md` · `documents/` (transcript and other uploads)
- Agents: job-seeker, form-reader (Haiku), answer-optimiser, evaluator

## Rules
1. **Nothing is submitted without the user's explicit yes** for that specific job, in this session. Ask "Submit <Company> — <Role> now? (yes / no)"; only an explicit yes to that question counts. Approval never carries to another job.
2. **Logins, account creation and CAPTCHAs are the user's.** Pause and ask.
3. **No LinkedIn automation:** no Easy Apply, no searching or mass actions. The user uses LinkedIn themselves.
4. **Never invent facts.** Every claim traces to `answer-bank/` or the CV; otherwise write `[CHECK: …]` and ask.
5. **Only the CVs listed in `cv/SWAPS.md`.** Suggest project swaps from `answer-bank/cv-points.md`; never edit or generate CV files.
6. CV edits: as few as possible, keep the user's phrasing, one line per bullet (~110 characters max). Spelling as set in `answer-bank/README.md`.
7. Don't type free-text answers into a form until the user has approved `answers.md`. Every personal/form fact (contact, address, eligibility, diversity, dietary, character declarations…) comes from `config/profile.md`. Check it before asking. If it isn't there, ask the user, then add their answer to `profile.md` straight away.
8. **Cover letters:** draft text in answers.md. Upload only as a PDF the user has formatted from their cover letter template (<TODO: e.g. a FlowCV or Google Docs template>). Never paste raw text into an upload slot.
9. **Story, not list:** every answer and cover letter follows `.claude/skills/story-flow/SKILL.md`.
10. Never make any claim listed under "Claims to avoid" in `answer-bank/facts.md`.
11. Default model Sonnet; form-reader runs on Haiku.
12. Keep `applications/tracker.md` current after every stage.
13. **Hard stop at 98% usage:** follow `.claude/skills/usage-stop/SKILL.md`.
14. When a command finishes, end with: "Mode done. Run /clear before starting the next one."

## Syncing (private GitHub repo, one or more computers)
- Start of every command: `git pull --rebase`. On conflict, stop and tell the user; never discard either side.
- End of every command: `git add -A`, `git commit -m "<command>: <summary>"`, `git push`.
- Never force-push, rewrite history or make the repo public. Hooks `sync-pull.sh` / `sync-push.sh` cover sessions; if the start-of-session pull fails, tell the user before doing any work.
