# ai_suite

This repository will hold scripts for launching Windows Terminal tabs for different AI models.

## Structure

- `scripts/`: Bash helpers for Windows Terminal tab orchestration.


## Scripts

- `scripts/aisuite.sh`: Bash launcher for opening Gemini, Open Code, and Codex tabs within Windows Terminal. Pass the target project directory (e.g. `./scripts/aisuite.sh ~/projects/ai_suite`), and optionally override commands via `AISUITE_*` environment variables.
