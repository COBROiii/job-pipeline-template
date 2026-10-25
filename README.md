# Job application pipeline

A job application assistant for Claude Code. It finds roles, scores how well you fit, drafts answers in your own voice from your past applications, has an independent panel review them, and fills the form in Chrome. It never submits without your explicit `submit`.

**New here? Start with [USER_GUIDE.md](USER_GUIDE.md):** setup, making it yours, and what each command does.

> **Keep your copy private.** Once you fill it in, it holds your CV, contact details, diversity answers and every application you write.

## How it fits together

```
 /find [track]      job-seeker (job boards + company watchlist in config/criteria.md) ──► applications/tracker.md
 /evaluate <link>   evaluator: fit score /100 + one-line reason ──► jobs/<id>/fit.md
 /draft <link>      ad + fit ► CV pick + swap ► form-reader (Haiku) ► answer-optimiser ► review panel
                    review panel = ATS · hiring manager · technical interviewer (independent) ► chair:
                    submit / revise / skip + the 3 smallest edits (one revision round)
 /apply <link>      /draft (or picks up the saved draft) ► your edits ► fill form in Chrome ► stops before
                    Submit ► you reply "submit" in Claude Code ► tracker, applied.xlsx, answer bank
 /apply-lite <link> one-line fit, reuses tagged answer-bank answers, quick checklist, same fill/submit steps
 /evaluate          (blank) search-wide report + status
```

The evaluator never writes answers, only judges them. Agents hand work over through files, so you can stop at any point and pick up later.

**Submit guard:** `.claude/hooks/submit-guard.js` blocks any browser click, Enter key or script that looks like submit/apply/send/confirm/finish. To let one through, reply `submit` (or "yes, submit it") in Claude Code: that allows one submit within 10 minutes. A plain "yes" doesn't count. Test it with `node .claude/hooks/test/submit-guard.test.js`. It judges clicks by their description, so treat it as a safety net; the rule is still that nothing is submitted without your yes.

## Connect Chrome
1. Start Claude Code with Chrome: `claude --chrome`
2. Run `/chrome` and check it says Status: Enabled, Extension: Installed. (You can pick "Enabled by default" there, but it loads browser tools into every session and uses more of your allowance, so `--chrome` per session is better.)
3. In Chrome, sign in to job sites yourself. Claude uses your existing sign-ins and will stop and hand back to you on any login page or CAPTCHA.
4. When Claude asks to act on a site, you can allow that site for the session. Only allow job sites and ATS portals.

## Keeping it good
- **Answer bank:** `/apply` saves every submitted answer to `answer-bank/past-answers.md`. That's how the drafts get better over time.
- **Facts:** when something changes (new role, new numbers, new project), update `answer-bank/facts.md` first. It overrides older answers.
- **Notion (optional):** if your CV points live in Notion, add the connector so Claude can re-pull them: `claude mcp add --transport http notion https://mcp.notion.com/mcp`, then `/mcp` to sign in.
- **Project swaps:** the optimiser may suggest swapping a project on your CV and drafts the bullets from your CV points. Make the change in your CV yourself, export it, and save it as `applications/jobs/<id>/cv.pdf`; that job then uses it instead of the default.

## Which command, and keeping usage down
- Use `/apply` for your first ~20 applications to build up the answer bank. After that, `/apply` for roles you really want or unusual questions, and `/apply-lite` for mass-apply roles or when usage is short. The tracker header counts tagged answers per question type; `/apply` tells you when each has 2+, which means lite is ready.
- Start plain `claude` for `/find` and `/evaluate`, and for `/draft` when you paste the questions in. Start `claude --chrome` only when a form has to be read or filled, because browser tools add to every message while they're on.
- Run `/clear` between applications.
- Batch: draft several first, then fill them all in one Chrome session (`/apply <link1> <link2> …` picks up the drafts).
- LinkedIn is manual only: search and Easy Apply there yourself, then add the job with `/evaluate <link>` if you want it tracked.

## Troubleshooting
| Problem | Fix |
|---|---|
| "Browser extension is not connected" | Restart Chrome and Claude Code, then `/chrome` → Reconnect extension |
| Browser stops responding mid-form | A pop-up dialog may be blocking it; dismiss it and tell Claude to continue |
| Agent not found | Make sure you started `claude` inside the `job-pipeline` folder |
| A site asks you to create an account | Create it yourself, sign in, then tell Claude to continue |
| Answers sound generic | Check the tiers in `answer-bank/README.md`; add a strong recent answer for that question type |
| Commit fails with "Author identity unknown" | Run `git config --global user.name "<your name>"` and `git config --global user.email "<your email>"` |
| Hooks fail on Windows | Install Git for Windows (for Git Bash) and Node.js, then restart Claude Code |

## Credits
- `.claude/skills/humanizer/` is [Humanizer](https://github.com/blader/humanizer) by Siqi Chen (MIT licence; see its `LICENSE`).
- Ideas: hiring-panel CV review (https://www.instagram.com/reel/DeVIz_uS06F/) · LLM Council, independent reviewers plus a chair (https://www.instagram.com/reel/De1KdfXuIK3/)
- Claude Code docs: https://code.claude.com/docs/en/skills.md · https://code.claude.com/docs/en/sub-agents.md · https://code.claude.com/docs/en/hooks-guide.md · https://code.claude.com/docs/en/chrome.md
