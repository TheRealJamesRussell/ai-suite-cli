# Repository Guidelines

## Project Structure & Module Organization
- `README.md`: High-level overview, installation, and usage notes for AI Suite CLI.
- `scripts/`: Houses executable helpers. `scripts/aisuite.sh` is the primary launcher for Windows Terminal tabs.
- Add new utilities under `scripts/` and document them in `README.md` with a short description and example invocation.

## Environment Prerequisites
- Contributors should work from Windows 10/11 with WSL enabled and Ubuntu installed (the launcher assumes a Bash-compatible WSL distro).
- Windows Terminal must be installed; the tooling relies on `wt.exe` and auto-detects its location.
- Ensure AI model CLIs (`gemini`, `opencode`, `codex`) are installed or aliased in the WSL environment before validating changes.

## Build, Test, and Development Commands
- `bash scripts/install.sh [link-name]`: Sets up or refreshes the `ais` command by symlinking the launcher into `~/.local/bin` and auto-detecting `wt.exe` (persisting `AISUITE_WT_PATH` when successful).
- `ais config add <title> <command> [profile]`: Append a tab definition (stored in `~/.config/aisuite/tabs.conf`; omit the profile to use the default Ubuntu profile).
- `ais config list`: Inspect the current tab definitions.
- `ais config remove <title>`: Delete a tab entry by title.
- `ais [path]`: Launches one Windows Terminal tab per config entry, rooted at `<path>` (defaults to current directory).
- `bash scripts/aisuite.sh <path>`: Direct invocation for debugging when the alias/symlink is unavailable.
- No build pipeline or package manager is configured yet; keep tooling lightweight and script-driven.
- After modifying the launcher, dry-run the config helpers and `ais` itself to confirm tabs open and commands execute without errors.

## Coding Style & Naming Conventions
- Bash scripts should target POSIX paths where possible and guard Windows-specific logic behind variables (e.g., `AISUITE_WT_PATH`).
- Use `#!/usr/bin/env bash`, `set -euo pipefail`, and four-space indentation for functions and conditionals.
- Prefer descriptive function names such as `build_tab`, and align environment variable names with the `AISUITE_*` prefix pattern.

## Testing Guidelines
- No automated test framework exists yet; rely on manual verification by running the launcher against disposable directories.
- Exercise the config helpers (`ais config add/list/remove`) to ensure they update `~/.config/aisuite/tabs.conf` as expected before testing launches.
- When feasible, run `shellcheck scripts/*.sh` to catch common Bash issues before committing.
- Capture edge cases (missing directories, absent `wt.exe`, empty configs) in the script with clear error messages and verify them manually.

## Commit & Pull Request Guidelines
- Use concise, sentence-case commit messages that summarize intent (e.g., “Document aisuite installation and usage”).
- Each change should update relevant docs (README, AGENTS) alongside scripts to keep guidance in sync; document any new behavior before merging.
- Pull requests should include: purpose summary, manual test notes (commands run and results), and any configuration prerequisites for reviewers.
- Reference tracking issues when available and request review from teammates familiar with Windows Terminal + WSL workflows.
- Make commits immediately after each discrete change (code or docs) so the history stays granular and reviewers can track progress.
