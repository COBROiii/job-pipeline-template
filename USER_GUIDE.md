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

- Type `/agents`. You should see `job-seeker`, `form-reader`, `answer-optimiser` and `evaluator`.
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
**What happens:** searches the graduate job boards in `config/criteria.md` and adds new roles to `applications/tracker.md`. It skips jobs already on the list and never touches LinkedIn.
**You get:** a short table of new roles with deadlines and a rough fit guess. Anything closing within two weeks is flagged.
**Use it:** at the start of a week, or when the tracker is running low.

### `/evaluate` — is this job worth applying for?
**Type:** `/evaluate <job link>`
**What happens:** reads the ad and scores your fit out of 100, with a one-line reason.
**How to read the score:** 75+ is a strong match, so use `/apply`. 60–74 is a decent match, so `/apply-lite` is fine. Under 60 you'll get a warning; you can still go ahead, but these rarely reach interview.

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
5. Three reviewers check the answers separately (an ATS keyword scan, a hiring manager and a technical interviewer). A chair combines them into a verdict (submit, revise or skip) and the three smallest edits that would help most. If the verdict is revise, it rewrites once.

**You get:** `applications/jobs/<id>/answers.md`, ready for you to read and edit. Anything it couldn't verify is marked `[CHECK: …]` for you to answer.
**Use it:** when you want to batch the writing now and fill the forms later.

### `/apply` — the full application
**Type:** `/apply <job link>` (start with `claude --chrome`)
**What happens:**
1. Runs `/draft`, or picks up the draft if you've already made one.
2. Shows you the answers and the review, and takes your edits. It asks "Are these the final answers?" and waits for your yes.
3. Opens the form in Chrome, fills your details, pastes the approved answers exactly and uploads your CV.
4. **Stops before Submit**, tells you what's filled and what's blank, and asks you to check the tab.
5. It asks "Submit <Company> — <Role> now? (yes / no)". Only a clear yes to that question presses Submit, once. Anything else leaves the form unsent.
6. Marks the job `applied`, adds a row to `applications/applied.xlsx`, and saves your final answers to the answer bank so later drafts can reuse them.

**Use it:** for jobs you really want, and for your first 20 or so applications while the answer bank fills up.

### `/apply-lite` — the quick version
**Type:** `/apply-lite <job link>`
**What happens:** the same fill-and-submit steps as `/apply`, but much cheaper. It reuses your closest saved answer for each question, changes only the company-specific parts, and runs a quick checklist instead of the review panel. If a question has no good match it offers to switch to `/apply`.
**Use it:** for high-volume roles, or when you're low on usage. It works best once your answer bank has two or more saved answers for each common question (the tracker header counts them for you).

## What stays with you

These are built in as rules:

- **Submitting.** Nothing is sent unless you say yes when Claude asks "Submit <Company> — <Role> now?" for that specific job. Approving one job never carries over to another.
- **Logins, new accounts and CAPTCHAs.** Claude stops and asks you to do them, then carries on.
- **LinkedIn.** No automation at all. Search and use Easy Apply there yourself. To track a LinkedIn job, run `/evaluate <link>`.
- **Your CV file.** Claude suggests changes; you make them.
- **Your details.** Forms are filled only from `config/profile.md`. Anything it doesn't cover, Claude asks you, then saves your answer there.
- **Facts.** Claude never makes up a claim. If something isn't in `answer-bank/facts.md` or your CV, it writes `[CHECK: …]` and asks you.

## Everyday tips

- **Type `/clear` between commands.** Each command ends with a reminder. A fresh start keeps Claude focused and uses less of your allowance.
- **Only open Chrome when you need it.** Plain `claude` is enough for `/find`, `/evaluate` and `/draft` when you paste the questions. Use `claude --chrome` for reading or filling forms.
- **Batch.** Draft several jobs, then fill them all in one Chrome session: `/apply <link1> <link2> …`
- **Keep facts current.** New grade, new role, new project? Update `answer-bank/facts.md` first. It overrides older answers.
- **Near your usage limit?** Tell Claude. It saves and syncs everything to GitHub before you run out (see `.claude/skills/usage-stop/SKILL.md`).

## Where things live

| Where | What |
|---|---|
| `applications/tracker.md` | Every job, one row each, with its stage: `found` → `scouted` → `drafted` → `ready` → `applied` (or `skipped` / `blocked`) |
| `applications/jobs/<id>/` | One folder per job: the saved ad, questions, fit score, answers, review and a log |
| `applications/applied.xlsx` | Submitted applications only, one sheet per track |
| `answer-bank/` | Everything Claude writes from. Read `answer-bank/README.md` first. |

## Words you'll see

- **Fit score:** how well you match the job, out of 100.
- **Answer score / verdict:** how ready the answers are. 80+ means submit, below that means revise or skip.
- **Review panel:** the three independent reviewers and a chair who check each draft.
- **Answer bank:** your saved facts, stories and past answers. It grows every time you apply.
- **Agent:** a helper with one job (finding jobs, reading forms, writing answers, reviewing). The commands run them for you.

For setup details, Chrome problems and troubleshooting, see `README.md`.
