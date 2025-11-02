# AI Suite CLI
### Who, what, the benefit
Anyone who uses multiple different AI CLI in the Windows terminal can use this AI Suite CLI to speed up their process of opening multiple AI CLIS for a project because you can skip the tedium of manually opening a new tab and typing the AI CLI's command for every AI CLI you use.

## Prerequisites

- Windows 10/11 with Windows Subsystem for Linux (WSL) enabled and at least one Linux distribution installed (defaults assume the Windows Terminal profile is called `Ubuntu`; adjust if your profile name differs).
- Windows Terminal already installed (Microsoft Store or MSI; the installer locates `wt.exe` automatically).
- CLI entry points for your AI tools (`gemini`, `opencode`, `codex`) available on your WSL `PATH` or wrapped via environment overrides.

## Installation

1. Fetch the repository (choose a workspace directory of your preference):
```bash
mkdir -p ~/workspaces
cd ~/workspaces
git clone https://github.com/TheRealJamesRussell/ai-suite-cli.git
cd ai-suite-cli
```
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

1. Configure the tabs you need (stored in `~/.config/aisuite/tabs.conf`). It’s usually easiest to do this with the built‑in helpers:

   ```bash
   # Add entries for each AI CLI you want to launch. The profile argument is optional; omit it to use the default Ubuntu profile.
   ais config add "Gemini" "gemini"
   ais config add "Opencode" "opencode"
   ais config add "Codex" "codex"

   # Review or adjust the current setup
   ais config list
   ais config remove "Codex"    # removes the first matching entry
   ```

   Each line in the config file follows the pattern `Title|command|profile(optional)`. Leaving the profile blank keeps the launcher terminal‑agnostic by defaulting to the Ubuntu Windows Terminal profile.

2. Launch the tabs from any project directory. The working directory defaults to your current location but you can pass an explicit target:

   ```bash
   ais                      # launches tabs using the current directory
   ais ~/projects/my-app    # launches tabs rooted in the specified directory
   ```

   Each entry in the config opens its own Windows Terminal tab, runs the configured command, and then drops into an interactive shell.

## Customization

- `AISUITE_PROFILE`: Switch the default Windows Terminal profile to use when a tab does not specify one (default `Ubuntu`).
- `AISUITE_WINDOW_ID`: Target a specific window ID instead of the current one (`0`).
- `AISUITE_WT_PATH`: Point to a custom `wt.exe` location when auto-detection is insufficient.

## Scripts

- `scripts/aisuite.sh`: Bash launcher plus config helpers for opening the configured Windows Terminal tabs.
