# ai_suite

Scripts and helpers for launching coordinated Windows Terminal tabs from WSL.

## Structure

- `scripts/`: Bash helpers for Windows Terminal tab orchestration.

## Installation

1. Ensure Windows Terminal is installed and `wt.exe` is available at the default location (`/mnt/c/Windows/System32/wt.exe`) or export `AISUITE_WT_PATH` to point to it.
2. Run the installer to create the `ais` command (use `scripts/install.sh custom-name` to choose a different link):
   ```bash
   bash scripts/install.sh
   ```
3. Reload your shell configuration (`source ~/.bashrc`) or open a new WSL terminal to pick up PATH changes, if required.

## Usage

Run the script with the directory you want each tab to use as its working directory:

```bash
ais ~/projects/ai_suite
```

The script opens three tabs in the current Windows Terminal window (Gemini, Open Code, Codex). Each tab runs the corresponding command and leaves the shell open when finished.

## Customization

- `AISUITE_PROFILE`: Switch to a different Windows Terminal profile (default `Ubuntu`).
- `AISUITE_WINDOW_ID`: Target a specific window ID instead of the current one (`0`).
- `AISUITE_GEMINI_CMD`, `AISUITE_OPEN_CODE_CMD`, `AISUITE_CODEX_CMD`: Override the commands executed in each tab.
- `AISUITE_WT_PATH`: Use a non-default path for `wt.exe`.

Example of customizing commands:

```bash
AISUITE_GEMINI_CMD="poetry run gemini" \
AISUITE_OPEN_CODE_CMD="npm run open-code" \
AISUITE_CODEX_CMD="python codex.py" \
ais ~/projects/ai_suite
```

## Scripts

- `scripts/aisuite.sh`: Bash launcher for opening Gemini, Open Code, and Codex tabs within Windows Terminal.
