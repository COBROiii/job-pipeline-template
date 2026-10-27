# User guide for Mac

This page gets the pipeline running on a Mac. Once it's set up, everything you do inside Claude Code (the `/find`, `/draft`, `/apply` commands, the review panel, submitting) works the same as on Windows, so for that part read [USER_GUIDE.md](USER_GUIDE.md) from "The workflow" onwards.

All the commands below go in the **Terminal** app (Applications › Utilities › Terminal, or press Cmd+Space and type "Terminal"). Paste one line at a time and press Return.

## What you need

- A Mac on a recent version of macOS
- A paid Claude plan (Pro or Max)
- **Google Chrome**, installed in your Applications folder
- A **GitHub** account

## 1. Install the tools

1. **Apple's command line tools** (gives you git and Python):
   ```bash
   xcode-select --install
   ```
   A window pops up; click Install and wait for it to finish. If it says they're already installed, that's fine.

2. **Homebrew**, the usual way to install developer tools on a Mac (skip if `brew --version` already works):
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
   At the end it prints two or three "Next steps" lines starting with `echo` and `eval`. Run them, or `brew` won't be found.

3. **The GitHub CLI and Chrome** (leave `google-chrome` off if you already have Chrome):
   ```bash
   brew install gh
   ```
   ```bash
   brew install --cask google-chrome
   ```
   Node.js is optional: it's only needed for the old submit-guard hook, which is off by default (`brew install node` if you want it).

4. **Claude Code**:
   ```bash
   curl -fsSL https://claude.ai/install.sh | bash
   ```
   (`brew install --cask claude-code` works too. Use one or the other.) Setup docs: https://code.claude.com/docs/en/setup

5. **Claude in Chrome**: in Chrome, install the **Claude in Chrome** extension from the Chrome Web Store and sign in to it with the same Claude account.

6. **Sign in to GitHub** so pulls and pushes work without asking for a password:
   ```bash
   gh auth login
   ```
   Pick GitHub.com, HTTPS, and "Login with a web browser".

7. **Tell git who you are**, if you haven't before:
   ```bash
   git config --global user.name "Your Name"
   ```
   ```bash
   git config --global user.email "you@example.com"
   ```

## 2. Get your own copy

1. On GitHub, open this repo and click **Use this template** › **Create a new repository**. **Make it private.** It will hold your CV, transcript and every answer you write.
2. Clone it into your Documents folder:
   ```bash
   cd ~/Documents
   ```
   ```bash
   gh repo clone <your-username>/job-pipeline
   ```
3. Install the spreadsheet library:
   ```bash
   cd ~/Documents/job-pipeline
   ```
   ```bash
   python3 -m pip install --user -r requirements.txt
   ```
   If it says **externally-managed-environment**, run this instead (it only adds one small library):
   ```bash
   python3 -m pip install --user --break-system-packages -r requirements.txt
   ```
4. Start Claude Code in that folder:
   ```bash
   claude
   ```
5. Type `/login` and sign in with your Claude account (not an API key, or the browser tools won't work).
6. Claude Code asks whether you trust the folder: say yes, so the commands, agents and hooks load.

From now on, to start a session: open Terminal, run `cd ~/Documents/job-pipeline`, then `claude` (or `claude --chrome` when a form has to be read or filled).

## 3. Check it works

- `/agents` should list `job-seeker`, `form-reader`, `answer-optimiser` and `evaluator`.
- `/evaluate` with nothing after it should read your empty tracker and report.
- Quit with `/exit`, start again with `claude --chrome`, then type `/chrome`: it should say Status: Enabled, Extension: Installed. Sign in to job sites in Chrome yourself. Claude uses your existing sign-ins.

The hooks (pull at start, push at end, the `/clear` reminder) run with the `bash` that comes with macOS, so there's nothing extra to install for them.

Then fill in your details: see "Make it yours" in [USER_GUIDE.md](USER_GUIDE.md#2-make-it-yours).

## Mac tips

- **Hidden folders.** `.claude/` starts with a dot, so Finder hides it. Press **Cmd+Shift+.** in Finder to show it (press it again to hide it).
- **Opening files.** To open the folder in Finder: `open ~/Documents/job-pipeline`. The `.md` files open in any text editor (TextEdit works; VS Code is nicer).
- **The spreadsheet.** `applications/applied.xlsx` opens in Excel or Numbers. If you open it in Numbers, close it without saving, so it stays an `.xlsx`. Close it before running `/apply`, or the row can't be added.
- **Uploads.** CVs and documents are uploaded from the folder, so keep them where `cv/SWAPS.md` and `documents/README.md` say. iCloud "Optimise Mac Storage" can offload files from Documents; if an upload fails with "file not found", open the file once in Finder to download it again.
- **Mac and Windows together.** You can clone the same private repo on a Mac and a Windows PC. Each session pulls when it starts and pushes when it ends, and the hooks work on both.
- **Keeping Claude Code up to date:** it updates itself. If you installed it with Homebrew, run `brew upgrade --cask claude-code` instead.

## Troubleshooting on a Mac

| Problem | Fix |
|---|---|
| `brew: command not found` | Run the "Next steps" lines Homebrew printed, or close and reopen Terminal |
| `claude: command not found` after installing | Close and reopen Terminal. If it still fails, use `brew install --cask claude-code` instead |
| `xcrun: error: invalid active developer path` | Run `xcode-select --install` again (it's often needed after a macOS update) |
| Commands or agents missing | Make sure you started `claude` inside `~/Documents/job-pipeline` and said yes to trusting the folder |
| "Browser extension is not connected" | Quit Chrome fully (Cmd+Q), quit Claude Code, start `claude --chrome` again, then `/chrome` › Reconnect extension |
| macOS blocks Chrome or Claude from something | System Settings › Privacy & Security: allow it there, then try again |
| `git push` asks for a username or password | Run `gh auth login` and `gh auth setup-git` |
| Saving to `applied.xlsx` fails | Close the file in Excel or Numbers, then tell Claude to try again |

For everything else, see the troubleshooting table in [README.md](README.md#troubleshooting).
