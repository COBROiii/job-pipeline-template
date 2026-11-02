---
name: outreach
description: Find 2–3 people at a company and draft messages asking for a quick chat, for the user to send themselves. Also logs replies and calls, and drafts follow-ups and the post-call thank-you.
argument-hint: "<company or job id> [...] | sent|replied|call <name> [notes] | (blank: suggest companies and list follow-ups due)"
disable-model-invocation: true
model: sonnet
---

Input: `$ARGUMENTS`

Follow the rules in `CLAUDE.md` (rule 23). Run `git pull --rebase` first. Read `answer-bank/outreach.md` and `applications/contacts.md`.

## Blank: what's next
- **Follow-ups due:** rows `accepted` or `sent` (email) with "Follow-up due" today or earlier → draft the one follow-up (template 5) in the job's `outreach.md`.
- **Suggest companies:** outreach order is not the job queue (rule 14 is for applying). Rank companies with no contacts yet: (1) already applied (status `applied`), (2) highest fit. Deadlines don't set the order. Skip `rejected` rows. Show company · role · deadline · fit · applied or not, and suggest up to 4 for this week (about 10 people). Ask which to run.

## Company or job ID: find people and draft
1. Check the weekly budget: count rows in `contacts.md` with status `drafted` or `sent` dated in the last 7 days. Over 10, say so and ask before carrying on.
2. Run `outreach` agents (model sonnet), **one at a time** (one Chrome window, LinkedIn at a human pace): "Find 2–3 people at <company> for <job id / role> and draft messages per answer-bank/outreach.md."
3. Show the user each person (name · title · why) with the connection note and its character count, linking the drafts file. Point out any `guessed, unverified` email.
4. The user sends them. Never click Connect or Message, and never send email for them. If they ask for Gmail drafts, turn the Gmail connector on for that step, create drafts only (never send), then turn it off (rule 11).

## sent / accepted / replied / call <name> [notes]
Update that person's row: status, date in "Sent", and "Follow-up due" = sent + 7 days (for `accepted`, accepted + 7 days). Drafts on demand:
- `accepted` → the full message (template 2), if not already drafted.
- `call <name> <notes>` → status `call done`, notes in the row, and the thank-you (template 6), using one specific thing from their notes. Include the referral ask only if the user says the call went well. Add anything learned about the company to the job's `posting.md` under "## From <name> (call, <date>)" so drafts and interviews can use it.
- `referred` → note it in the tracker row's Notes for that job as well.

End: commit and push (`outreach: <summary>`), then "Mode done."
