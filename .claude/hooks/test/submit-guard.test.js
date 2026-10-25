// Run: node .claude/hooks/test/submit-guard.test.js
const assert = require('assert');
const { execFileSync } = require('child_process');
const path = require('path');
const fs = require('fs');
const { check, isApproval, TOKEN } = require('../submit-guard');

const C = 'mcp__claude-in-chrome__computer';
const click = summary => ({ tool_name: C, tool_input: { action: 'left_click', ref: 'ref_3', action_summary: summary } });

// should prompt the user
assert(check(click('Submits the application form')));
assert(check(click('Clicks the Apply now button')));
assert(check(click('Sends the application')));
assert(check(click('Confirms and finishes the application')));
assert(check({ tool_name: C, tool_input: { action: 'left_click', coordinate: [10, 10] } })); // no summary
assert(check({ tool_name: C, tool_input: { action: 'key', text: 'Return', action_summary: 'Presses Return' } }));
assert(check({ tool_name: 'mcp__claude-in-chrome__javascript_tool', tool_input: { text: 'document.forms[0].requestSubmit()' } }));
assert(check({ tool_name: 'mcp__Claude_Browser__javascript_tool', tool_input: { text: "document.querySelector('#submit').click()" } }));
assert(check({ tool_name: 'mcp__claude-in-chrome__browser_batch', tool_input: { actions: [
  { name: 'computer', input: { action: 'type', text: 'Alex' } },
  { name: 'computer', input: { action: 'left_click', ref: 'ref_9', action_summary: 'Submits the form' } },
] } }));

// should pass silently
assert(!check(click('Opens the Education section')));
assert(!check(click('Focuses the first name field')));
assert(!check({ tool_name: C, tool_input: { action: 'type', text: 'I want to apply because…', action_summary: 'Types answer into Q1' } }));
assert(!check({ tool_name: C, tool_input: { action: 'screenshot' } }));
assert(!check({ tool_name: 'mcp__claude-in-chrome__javascript_tool', tool_input: { text: 'document.title' } }));
assert(!check({ tool_name: 'mcp__claude-in-chrome__read_page', tool_input: { tabId: 1 } }));

// approval phrase: only an explicit "submit" message counts
assert(isApproval('submit'));
assert(isApproval('Yes, submit it'));
assert(isApproval('yes submit now'));
assert(!isApproval('yes'));
assert(!isApproval('yes, these are the final answers'));
assert(!isApproval("don't submit yet"));

// end to end through stdin
const script = path.join(__dirname, '..', 'submit-guard.js');
const run = ev => execFileSync('node', [script], { input: JSON.stringify(ev) }).toString();
const submitClick = { hook_event_name: 'PreToolUse', ...click('Submits the application form') };
fs.rmSync(TOKEN, { force: true });

assert.strictEqual(JSON.parse(run(submitClick)).hookSpecificOutput.permissionDecision, 'deny');
assert.strictEqual(run({ hook_event_name: 'PreToolUse', ...click('Opens the menu') }), '');

run({ hook_event_name: 'UserPromptSubmit', prompt: 'yes' });
assert(!fs.existsSync(TOKEN), 'plain yes must not approve');
run({ hook_event_name: 'UserPromptSubmit', prompt: 'submit' });
assert.strictEqual(run(submitClick), '', 'approved submit goes through');
assert.strictEqual(JSON.parse(run(submitClick)).hookSpecificOutput.permissionDecision, 'deny', 'approval is one use');

fs.writeFileSync(TOKEN, 'old');
const old = new Date(Date.now() - 11 * 60 * 1000);
fs.utimesSync(TOKEN, old, old);
assert.strictEqual(JSON.parse(run(submitClick)).hookSpecificOutput.permissionDecision, 'deny', 'approval expires');
assert(!fs.existsSync(TOKEN));

console.log('submit-guard: all tests passed');
