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

## Configure Tabs

Tabs are defined in `~/.config/aisuite/tabs.conf`. Use the built-in helpers to create or adjust entries:

```bash
# Seed the common trio (each tab inherits the default Ubuntu profile unless specified)
ais config add "Gemini" "gemini"
ais config add "Opencode" "opencode"
ais config add "Codex" "codex"

# Inspect current entries
ais config list

# Remove an entry by title
ais config remove "Codex"
```

Each line in the config file uses `Title|command|profile(optional)`. Omitting the profile keeps the Ubuntu default, making the launcher terminal-agnostic out of the box.

## Usage

After configuring the tabs, launch them from any project directory (the working directory defaults to the current path):

```bash
ais
ais ~/projects/ai_suite_cli
```

The command opens one Windows Terminal tab per config entry. Each tab runs its configured command and then drops to an interactive shell.

## Customization

- `AISUITE_PROFILE`: Switch the default Windows Terminal profile to use when a tab does not specify one (default `Ubuntu`).
- `AISUITE_WINDOW_ID`: Target a specific window ID instead of the current one (`0`).
- `AISUITE_WT_PATH`: Point to a custom `wt.exe` location when auto-detection is insufficient.

## Scripts

- `scripts/aisuite.sh`: Bash launcher plus config helpers for opening the configured Windows Terminal tabs.
