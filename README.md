# AI Suite CLI

Scripts and helpers for launching coordinated Windows Terminal tabs from WSL.

## Structure

- `scripts/`: Bash helpers for Windows Terminal tab orchestration.

## Installation

1. Install Windows Terminal (Microsoft Store or MSI). No manual path configuration is required for common setups.
2. Run the installer to create the `ais` command (use `scripts/install.sh custom-name` to choose a different link). The installer auto-detects `wt.exe` via Windows' `where` command and persists the path to `~/.bashrc` when found:
   ```bash
   bash scripts/install.sh
   ```
3. Reload your shell configuration (`source ~/.bashrc`) or open a new WSL terminal if prompted by the installer.

## Usage

Run the script with the directory you want each tab to use as its working directory:

```bash
ais ~/projects/ai_suite_cli
```

The script opens three tabs in the current Windows Terminal window (Gemini, Open Code, Codex). Each tab runs the corresponding command and leaves the shell open when finished.

## Customization

- Defaults: `Gemini` runs `gemini`, `Open Code` runs `opencode`, and `Codex` runs `codex`.
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
