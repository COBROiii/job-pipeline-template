# User guide

This folder is a job application assistant that runs inside Claude Code. You give it a job link and it reads the ad, scores how well you fit, drafts your answers in your own voice, has a panel of reviewers check them, and fills the application form in Chrome. It never presses Submit until you say yes for that job.

You don't need to know how to code. You type commands into Claude Code and reply to its questions in plain English. This guide covers how to use the workflow from start to finish. How each part works inside is already written in the `.md` files, and you can ask Claude about any of them.

**On a Mac?** Follow [USER_GUIDE_MAC.md](USER_GUIDE_MAC.md) for setup, then come back here from "The workflow".

## What you need

- A paid Claude plan (Pro or Max) and **Claude Code**: https://code.claude.com/docs/en/setup
- **Google Chrome** with the **Claude in Chrome** extension (Chrome Web Store), for reading and filling forms
- A **GitHub** account and **git**. On Windows, installing Git for Windows also gives you Git Bash, which the hooks need.
- **Node.js** (https://nodejs.org), optional: only needed for the old submit-guard hook, which is off by default
- Python with `openpyxl` (`pip install -r requirements.txt`), for the applied-jobs spreadsheet

## 1. Get your own copy

1. On GitHub, fork this repo (or click **Use this template**). **Make your copy private.** It will hold your CV, transcript and every answer you write.
2. Clone it to your computer:
   ```bash
   git clone https://github.com/<your-username>/job-pipeline.git
   ```
3. Open the folder in a terminal and start Claude Code:
   ```bash
   cd job-pipeline
   claude
   ```
4. Type `/login` and sign in with your Claude account (not an API key, or the browser tools won't work).

If you use two computers, clone it on both. Each session pulls from GitHub when it starts and pushes when it ends, so both stay in step.

## 2. Make it yours

Every file you need to fill in has `TODO` markers. Fill them in before your first run. The quickest way is to ask Claude: *"Interview me and fill in every TODO in `CLAUDE.md`, `config/` and `answer-bank/facts.md`."* It asks you questions and writes the answers down. To check nothing is left, ask *"Which files still have TODOs?"*

| File | What goes in it |
|---|---|
| `CLAUDE.md` | Your name, a few lines about you, and your tracks in priority order. Claude reads this at the start of every session. |
| `config/criteria.md` | Your **tracks** (the kinds of job you want, e.g. engineering, consulting), job titles to search for, which job boards to use, locations, a company watchlist, and what to exclude. |
| `answer-bank/facts.md` | The source of truth: dates, grades, numbers, what you're doing now, and claims to avoid. If it's not here or on your CV, Claude won't claim it. |
| `config/profile.md` | Every routine form fact: contact, address, right to work, start date, dietary needs, declarations (convictions, disciplinary) and, if you want, your diversity answers. When a form asks something new, Claude asks you once and adds it here. |
| `cv/` | Your CV as a PDF, plus a `.md` copy (ask Claude to make the `.md` from the PDF). One technical and one general CV work well. `cv/SWAPS.md` says which CV goes with which kind of job. |
| `answer-bank/past-answers.md` | Paste in old application answers you're happy with. The more good ones, the more the drafts sound like you. |
| `answer-bank/stories.md` | Your best stories (a project, a failure, a team moment) and which questions they answer. |
| `answer-bank/cover-letters.md` | Past cover letters, if you have any. |
| `documents/` | Transcript and any other documents forms ask you to upload. |

`applications/tracker.md` and `applications/applied.xlsx` start empty and fill up as you go. You don't need to touch `.claude/`, which holds the commands, agents and hooks.

## 3. Check it works

- Type `/agents`. You should see `job-seeker`, `form-reader`, `form-filler`, `answer-optimiser`, `evaluator` and `outreach`.
- Type `/evaluate` with nothing after it. It should read your (empty) tracker and report.
- For anything that needs Chrome, start Claude Code with `claude --chrome`, then type `/chrome` and check it says Enabled. Sign in to job sites in Chrome yourself first.

## The workflow

```
  /find  ──►  tracker  ──►  /evaluate <link>  ──►  /draft <link>  ──►  you edit  ──►  /apply <link>  ──►  you say "yes"
 (search)     (list of      (is it worth it?)      (answers +          answers.md      (fills the form,      (sent, logged,
               jobs)                                review panel)                       stops before          answers saved
                                                                                        Submit)               for next time)
```

You can stop after any step and come back days later. Everything is saved in files, so the next command picks up where the last one stopped. If a job already has its ad, fit score, questions or answers saved, Claude reuses them instead of redoing the work, and tells you which steps it skipped.

## The commands

### `/find` — look for jobs
**Type:** `/find` or `/find <track>` (your track IDs from `config/criteria.md`)
**What happens:** searches the graduate job boards in `config/criteria.md` and adds new roles to `applications/tracker.md`. It skips jobs already on the list, starting with LinkedIn (read-only: it never clicks Easy Apply, Apply, Save or Message).
**You get:** a short table of new roles with deadlines and a rough fit guess. Anything closing within two weeks is flagged.
**Use it:** at the start of a week, or when the tracker is running low.

### `/evaluate` — is this job worth applying for?
**Type:** `/evaluate <job link>`
**What happens:** reads the ad and scores your fit out of 100 with a grade, a one-line reason and an effort call: `tailor` (worth a full `/apply`) or `mass-apply` (`/apply-lite` is fine).
**How to read the score:** **A** (75+) is a strong match, so use `/apply`. **B** (55–74) is a decent match, so `/apply-lite` is fine. **C** (40–54) and **Drop** (under 40, or you're not eligible) rarely reach interview. Anything under 60 gets a note in the tracker, but the job is never removed; whether to go ahead is your call.

Two other uses:
- `/evaluate` on its own gives a status report: how many jobs at each stage, strong jobs closing soon that you haven't applied for, and anything stuck.
- `/evaluate applications/jobs/<id>` reruns the review panel on answers you've already drafted.

### `/draft` — write the application, don't send it
**Type:** `/draft <job link>` (several links at once is fine). If you already have the questions, paste them after the link and it won't need to open the form.
**What happens:**
1. Saves the full job ad (postings disappear) and scores fit.
2. Picks which CV to use and may suggest a project to swap in. It never edits your CV; you make that change yourself.
3. Opens the form and records every question, word limit and upload. If it has to stop partway (a sign-in, or a question only you can answer), it saves what it has read and marks it partial. Next time it shows you what it's waiting on, then carries on from that page.
4. Drafts your answers from your answer bank, in your voice.
5. Writes a cover letter in `applications/jobs/<id>/cover-letter.md` for every job with fit 80+, and for any job that requires one.
6. Three reviewers check the answers separately (an ATS keyword scan, a hiring manager and a technical interviewer). A chair combines them into a verdict (submit 80+, revise 60–79, skip under 60) and the three smallest edits that would help most. If the verdict is revise, it rewrites once.

**You get:** `applications/jobs/<id>/answers.md` (and `cover-letter.md`), ready for you to read and edit. Anything it couldn't verify is marked `[CHECK: …]` for you to answer.
**Use it:** when you want to batch the writing now and fill the forms later.

### `/apply` — the full application
**Type:** `/apply <job link>` (start with `claude --chrome`)
**What happens:**
1. Runs `/draft`, or picks up the draft if you've already made one.
2. Shows you the answers and the review, and takes your edits. It asks "Are these the final answers?" and waits for your yes.
3. If a cover letter is needed (always for fit 80+), asks whether Claude should make the PDF from your cover letter template, then the `form-filler` agent opens the form in Chrome, fills your details, pastes the approved answers exactly and uploads your CV (and cover letter).
4. **Stops before Submit**, tells you what's filled and what's blank, and asks you to check the tab.
5. It asks "Submit <Company> — <Role> now? (yes / no)". Only a clear yes to that question presses Submit, once. Anything else leaves the form unsent.
6. Marks the job `applied`, adds a row to `applications/applied.xlsx`, and saves your final answers to the answer bank so later drafts can reuse them.

**If it gets stuck** (a sign-in, a CAPTCHA, a question only you can answer), it notes the blocker in the tracker and moves on to the next job that needs nothing from you. About every 5 minutes it stops and reports what's done, what's blocked and what it needs from you. Once you answer, it picks the stuck job up where it left off.

**Use it:** for jobs you really want, and for your first 20 or so applications while the answer bank fills up.

### `/apply-lite` — the quick version
**Type:** `/apply-lite <job link>`
**What happens:** the same fill-and-submit steps as `/apply`, but much cheaper. It reuses your closest saved answer for each question, changes only the company-specific parts, and runs a quick checklist instead of the review panel. If a question has no good match it offers to switch to `/apply`.
**Use it:** for high-volume roles, or when you're low on usage. It works best once your answer bank has two or more saved answers for each common question (the tracker header counts them for you).

### `/outcome` — record a rejection
**Type:** `/outcome <company or id> [reason or feedback]`
**What happens:** marks the job `rejected` in the tracker, adds a dated line to its `log.md` and fills Status and Rejection Reason in `applications/applied.xlsx`. The reason is saved word for word. Tests and interviews aren't tracked; those jobs stay `applied`.
**On its own:** `/outcome` checks your Gmail for rejections (if the Gmail connector is on) and lists them with the line that shows each. Nothing is written until you pick the numbers, and it never replies to, archives or labels an email.

### `/outreach` — talk to people at the company
**Type:** `/outreach <company or job id>` (several at once is fine). Start with `claude --chrome`.
**What happens:** the `outreach` agent finds 2–3 people at the company: your own network first, then people already doing the role (alumni of your university, recent grads), then people in the team and recruiters at about 2:1. Small companies get an email first, large ones LinkedIn. It uses LinkedIn (read-only), the company site and alumni pages, drafts a LinkedIn connection note, a full message and (where there's a work email) an email for each person, and logs them in `applications/contacts.md`.
**How the messages go** (templates in `answer-bank/outreach.md`):
- Who you are → the role you're **looking at** → why this person in particular (their path, their team, a shared university) → one question → a soft ask for a quick 5-minute call.
- The question suits the person: "what your work is like and what you enjoy about it" for someone with a path to talk about (a graduate scheme, intern to hire, just joined), or "what your work is like day to day" for specialists.
- Don't say "I've applied" in the first message: it sounds like asking for the job. Recruiters are the exception.
- Never ask for a referral in the first message. Only after a call, in the thank-you, and only if the call went well.
- One follow-up at most, about 7 days after they accept. About 10 new people a week.
- Work emails only, from a pattern on the company's own site; a guessed one is marked `guessed, unverified`.

**You send every message yourself.** Claude never clicks Connect, Message or Follow and never sends email.
**After you send:** tell it what happened and it updates `contacts.md` and drafts the next message:
- `/outreach sent <name>` or `/outreach accepted <name>` sets the follow-up date (7 days on). `accepted` also drafts the full message.
- `/outreach replied <name>` records the reply.
- `/outreach call <name> <notes>` records the call, drafts a thank-you using something specific from your notes (with the referral ask only if you say it went well) and saves what you learnt to the job's `posting.md` for answers and interviews.

**On its own:** `/outreach` lists follow-ups due today and suggests up to 4 companies for this week (ones you've applied to first, then highest fit, with no contacts yet).
**Use it:** for jobs you really want, ideally before you apply if the deadline is more than a week away.

## What stays with you

These are built in as rules:

- **Submitting.** Nothing is sent unless you say yes when Claude asks "Submit <Company> — <Role> now?" for that specific job. Approving one job never carries over to another.
- **Logins, new accounts and CAPTCHAs.** Claude stops and asks you to do them, then carries on.
- **LinkedIn.** Read-only: Claude searches and reads postings (source #1), follows external ones through to the employer's site, and reads people's profiles for `/outreach`. It never clicks Easy Apply, Apply, Save, Follow, Connect or Message. Easy Apply submissions are yours.
- **Messages to people.** Claude drafts; you send every connection request, message and email yourself.
- **Your CV file.** Claude suggests changes; you make them.
- **Your details.** Forms are filled only from `config/profile.md`. For routine gaps (title, a grade dropdown) Claude picks the obvious answer and lists its assumptions afterwards; anything else (eligibility, diversity, declarations, salary) it asks you, then saves your answer there.
- **Facts.** Claude never makes up a claim. If something isn't in `answer-bank/facts.md` or your CV, it writes `[CHECK: …]` and asks you.

## Everyday tips

- **Type `/clear` when Claude suggests it** (context over 200k after a job, or a hard stop at 300k). A fresh start keeps Claude focused and uses less of your allowance.
- **Only open Chrome when you need it.** Plain `claude` is enough for `/find`, `/evaluate` and `/draft` when you paste the questions. Use `claude --chrome` for reading or filling forms.
- **Batch.** Draft several jobs, then fill them all in one Chrome session: `/apply <link1> <link2> …`
- **Keep facts current.** New grade, new role, new project? Update `answer-bank/facts.md` first. It overrides older answers.
- **Near your usage limit?** Tell Claude. It saves and syncs everything to GitHub before you run out (see `.claude/skills/usage-stop/SKILL.md`).

## Where things live

| Where | What |
|---|---|
| `applications/tracker.md` | Every job, one row each, with its stage: `found` → `scouted` → `drafted` → `ready` → `applied` → `rejected` (or `skipped` / `blocked`) |
| `applications/jobs/<id>/` | One folder per job: the saved ad, questions, fit score, answers, review and a log |
| `applications/applied.xlsx` | Submitted applications only, one sheet per track |
| `applications/contacts.md` | Everyone you've reached out to, with status and follow-up dates |
| `answer-bank/` | Everything Claude writes from. Read `answer-bank/README.md` first. `outreach.md` holds the message templates. |

## Words you'll see

- **Fit score:** how well you match the job, out of 100.
- **Answer score / verdict:** how ready the answers are. 80+ means submit, below that means revise or skip.
- **Review panel:** the three independent reviewers and a chair who check each draft.
- **Answer bank:** your saved facts, stories and past answers. It grows every time you apply.
- **Agent:** a helper with one job (finding jobs, reading forms, filling forms, writing answers, reviewing, finding people). The commands run them for you.
- **Tailor / mass-apply:** the evaluator's call on how much effort a job deserves: a full `/apply` or a quick `/apply-lite`.

## Using Claude Code well

### Session habits

| Habit | Why |
|---|---|
| One mode per session (e.g. just `/draft`, or just `/outreach`) | Each message re-sends the whole conversation, so a focused session stays cheap |
| `/clear` between modes and between unrelated tasks | Starts fresh; nothing from the last task weighs on the next |
| Side tasks in a separate session | Keeps the main session on the job in hand |
| Main session on Sonnet (`/model`); a bigger model only for tailored answers | Sonnet handles most steps; Opus is worth it for fit 80+ answers and cover letters |
| Plain `claude` unless browsing; add `--chrome` only when needed | Browser tools add to every message while they're on |
| Save anything decided to a file before `/clear` | `/clear` forgets the conversation; files survive |

### Commands

| Command | What it does |
|---|---|
| `/clear [name]` | Fresh start (optionally name the old session so you can find it) |
| `/compact` | Summarises the conversation to free space, keeping the gist |
| `/context` | Shows how full the context is and what's using it |
| `/usage` | Shows how much of your plan's allowance is left |
| `/model` | Picks the model; left/right arrows set the effort level |
| `/resume` | Reopens an earlier session |
| `/btw <question>` | A quick side question that doesn't grow the session |
| `/rewind` | Goes back to an earlier point (conversation, files or both) |

### Shortcuts

| Key | What it does |
|---|---|
| `Esc` | Stop Claude mid-step so you can redirect it |
| `Esc` `Esc` (empty prompt) | Rewind to an earlier message |
| `Shift+Tab` | Cycle modes (normal, auto-accept edits, plan) |
| `@file` | Point Claude at a file, e.g. `@applications/tracker.md` |
| `!command` | Run a shell command yourself, e.g. `!git status` |
| `Ctrl+O` | See what Claude actually did (full tool output) |
| `Ctrl+S` | Park a draft prompt and come back to it |

### A typical run

```
claude                         /find                      → new jobs in the tracker
/clear
claude                         /evaluate <link>           → fit score, tailor or mass-apply
                               /draft <link1> <link2>     → answers.md + cover-letter.md; edit them
/clear
claude --chrome                /apply <link1> <link2>     → fills forms, stops before Submit; you say yes
/clear
claude --chrome                /outreach <company>        → drafts notes; you send them
/clear
claude                         /outcome                   → records rejections from Gmail
```

- Read each `answers.md` and `cover-letter.md` before `/apply`.
- After sending outreach, tell Claude: `/outreach sent <name>`.
- Run `/evaluate` on its own every week or so for the status report.

### One-time extras

- `/statusline`: show the model and context use at the bottom of the screen.
- `/fewer-permission-prompts`: allow the safe read-only commands Claude keeps asking about.
- `/insights`: a report on how you've been using Claude Code; worth a look weekly.
- `/schedule`: run something on a timer, e.g. a weekly `/find`.
- `/remote-control`: carry on a session from your phone or another device.

For setup details, Chrome problems and troubleshooting, see `README.md`.
