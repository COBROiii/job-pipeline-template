---
name: usage-stop
description: Hard stop at 98% usage. Use whenever a usage-limit warning appears, the user says usage is near or at 98%, or a long run (many jobs, many subagents) is under way. Pause everything, sync to GitHub, report, and stop.
---

# Hard stop at 98% usage

**At 98% usage, pause everything and stop.** The last 2% is kept for syncing to GitHub, so nothing is lost if the limit cuts the session off.

## When it triggers
If a usage tool is available (in the Claude desktop app: `mcp__ccd_session_mgmt__get_usage`, loaded with ToolSearch if it's deferred), check the meter before each job, before launching subagents, and after every few browser steps when usage is above 90%. Stop if **either** the 5-hour limit or the weekly limit shows `percentUsed` ≥ 98. Also treat any of these as hitting 98%:
- a system or usage-limit message that warns the limit is close, or reached with a grace allowance;
- the user says usage is at or near 98% (or tells you to stop for usage);
- a subagent fails with a rate-limit or session-limit error.

## What to do, in this order
1. **Stop starting work.** No new subagents, scouts, drafts or browser steps. Don't send follow-up messages to running agents.
2. **Never submit anything** while stopping, even if a yes is pending. Leave forms open and unsubmitted.
3. **Sync:** `git add -A`, `git commit -m "session: hard stop at 98% usage (<what was in progress>)"`, `git push`. If the push fails, say so.
4. **Report in a few lines:** what's done, what was in progress (including agents that may still be running, whose edits will be uncommitted), and the next step for each open job.
5. **End the turn.** Don't resume until the user says to continue.

## Staying under it
Work in batches of about 4 jobs, and commit and push between batches.
