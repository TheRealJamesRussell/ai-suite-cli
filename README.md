# AI Suite CLI

Scripts and helpers for launching coordinated Windows Terminal tabs from WSL.

## Structure

- `scripts/`: Bash helpers for Windows Terminal tab orchestration.

## Prerequisites

- Windows 10/11 with Windows Subsystem for Linux (WSL) enabled and an Ubuntu distribution installed.
- Windows Terminal installed from Microsoft Store or MSI (the installer will locate `wt.exe` automatically).
- CLI entry points for your AI tools (`gemini`, `opencode`, `codex`) available on your WSL `PATH` or wrapped via environment overrides.

## Installation

1. Install Windows Terminal (Microsoft Store or MSI). No manual path configuration is required for common setups.
2. Run the installer to create the `ais` command (use `scripts/install.sh custom-name` to choose a different link). The installer auto-detects `wt.exe` via Windows' `where` command and persists the path to `~/.bashrc` when found:
```bash
bash scripts/install.sh
```
3. Reload your shell configuration (`source ~/.bashrc`) or open a new WSL terminal if prompted by the installer.

### Uninstall

Remove the symlink (adjust if you chose a custom link-name):
```bash
rm -f ~/.local/bin/ais
```
Delete the exported path marker from `~/.bashrc` (look for the `# AI Suite CLI wt.exe path` section) if you no longer need it.

### Updating

1. Pull changes from GitHub:
   ```bash
   git pull origin master
   ```
2. Re-run the installer to refresh the symlink and ensure any new detection logic applies:
   ```bash
   bash scripts/install.sh
   ```

## Usage

Run the script with the directory you want each tab to use as its working directory (defaults to the current directory when omitted):

```bash
ais
ais ~/projects/ai_suite_cli
```

The script opens three tabs in the current Windows Terminal window (Gemini, Open Code, Codex). Each tab runs the corresponding command and leaves the shell open when finished.

## Customization

- Defaults: `Gemini` runs `gemini`, `Opencode` runs `opencode`, and `Codex` runs `codex`.
- `AISUITE_PROFILE`: Switch to a different Windows Terminal profile (default `Ubuntu`).
- `AISUITE_WINDOW_ID`: Target a specific window ID instead of the current one (`0`).
- `AISUITE_GEMINI_CMD`, `AISUITE_OPEN_CODE_CMD`, `AISUITE_CODEX_CMD`: Override the commands executed in each tab.
- `AISUITE_WT_PATH`: Use a non-default path for `wt.exe`.

Example of customizing commands:

```bash
AISUITE_GEMINI_CMD="poetry run gemini" \
AISUITE_OPEN_CODE_CMD="npm run open-code" \
AISUITE_CODEX_CMD="python codex.py" \
ais ~/projects/ai_suite_cli
```

## Scripts

- `scripts/aisuite.sh`: Bash launcher for opening Gemini, Open Code, and Codex tabs within Windows Terminal.
