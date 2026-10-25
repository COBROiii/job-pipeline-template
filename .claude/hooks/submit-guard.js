// Submit guard, two hook events:
// - UserPromptSubmit: when the user's own message is "submit" (or "yes submit"), write a
//   one-use approval valid for 10 minutes.
// - PreToolUse (browser tools): deny any click/keypress/script that looks like a submit,
//   unless that approval exists; it is used up by the first submit it lets through.
// "ask" is not used: auto mode approved it without prompting (tested 2026-10-24).
// shortcut: judges clicks by their action_summary, since a coordinate or ref says
// nothing about the button; a mislabelled click can slip through. Rule 1 stays the real rule.

const fs = require('fs');
const path = require('path');

const TOKEN = path.join(__dirname, '.submit-approved');
const TOKEN_MS = 10 * 60 * 1000;
const SUBMIT = /\b(submit|apply|send|confirm|finish|complete|finalise|finalize)\w*/i;
const CLICKS = new Set(['left_click', 'right_click', 'double_click', 'triple_click']);

function risky(name, input = {}) {
  name = String(name).split('__').pop();
  if (name === 'computer') {
    const summary = input.action_summary || '';
    if (CLICKS.has(input.action)) return !summary || SUBMIT.test(summary);
    if (input.action === 'key') return /\b(enter|return)\b/i.test(input.text || '') || SUBMIT.test(summary);
    return false;
  }
  if (name === 'javascript_tool' || name === 'javascript_exec') {
    const code = input.text || '';
    return /requestSubmit|\.submit\s*\(|dispatchEvent/i.test(code) || (/\.click\s*\(/.test(code) && SUBMIT.test(code));
  }
  return false;
}

function check(event) {
  const input = event.tool_input || {};
  const steps = Array.isArray(input.actions) ? input.actions : [{ name: event.tool_name, input }];
  return steps.some(s => risky(s.name, s.input));
}

const isApproval = prompt => /^\s*(yes[\s,.!]*)?submit( it| now)?[\s.!]*$/i.test(prompt || '');

function useApproval() {
  try {
    const fresh = Date.now() - fs.statSync(TOKEN).mtimeMs < TOKEN_MS;
    fs.unlinkSync(TOKEN);
    return fresh;
  } catch { return false; }
}

function handle(event) {
  if (event.hook_event_name === 'UserPromptSubmit') {
    if (isApproval(event.prompt)) fs.writeFileSync(TOKEN, String(Date.now()));
    return '';
  }
  if (!check(event) || useApproval()) return '';
  return JSON.stringify({
    hookSpecificOutput: {
      hookEventName: 'PreToolUse',
      permissionDecision: 'deny',
      permissionDecisionReason: 'Looks like a submit: stop and ask the user. They approve by replying "submit" in Claude Code.',
    },
  });
}

if (require.main === module) {
  let raw = '';
  process.stdin.on('data', d => (raw += d));
  process.stdin.on('end', () => {
    let event;
    try { event = JSON.parse(raw); } catch { event = {}; }
    process.stdout.write(handle(event));
  });
}

module.exports = { check, isApproval, handle, TOKEN };
