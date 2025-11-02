# Repository Guidelines

## Project Structure & Module Organization
- `README.md`: High-level overview, installation, and usage notes.
- `scripts/`: Houses executable helpers. `scripts/aisuite.sh` is the primary launcher for Windows Terminal tabs.
- Add new utilities under `scripts/` and document them in `README.md` with a short description and example invocation.

## Build, Test, and Development Commands
- `ais <path>`: Preferred entry point; opens three coordinated Windows Terminal tabs rooted at `<path>`, running the configured AI model commands.
- `bash scripts/aisuite.sh <path>`: Direct invocation for debugging when the alias/symlink is unavailable.
- No build pipeline or package manager is configured yet; keep tooling lightweight and script-driven.
- After modifying the launcher, manually dry-run it from WSL to confirm each tab opens and executes the expected command without errors.

## Coding Style & Naming Conventions
- Bash scripts should target POSIX paths where possible and guard Windows-specific logic behind variables (e.g., `AISUITE_WT_PATH`).
- Use `#!/usr/bin/env bash`, `set -euo pipefail`, and four-space indentation for functions and conditionals.
- Prefer descriptive function names such as `build_tab`, and align environment variable names with the `AISUITE_*` prefix pattern.

## Testing Guidelines
- No automated test framework exists yet; rely on manual verification by running the launcher against disposable directories.
- When feasible, run `shellcheck scripts/*.sh` to catch common Bash issues before committing.
- Capture edge cases (missing directories, absent `wt.exe`) in the script with clear error messages and verify them manually.

## Commit & Pull Request Guidelines
- Use concise, sentence-case commit messages that summarize intent (e.g., “Document aisuite installation and usage”).
- Each change should update relevant docs (README, AGENTS) alongside scripts to keep guidance in sync; document any new behavior before merging.
- Pull requests should include: purpose summary, manual test notes (commands run and results), and any configuration prerequisites for reviewers.
- Reference tracking issues when available and request review from teammates familiar with Windows Terminal + WSL workflows.
- Make commits immediately after each discrete change (code or docs) so the history stays granular and reviewers can track progress.
