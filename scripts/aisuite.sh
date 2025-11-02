#!/usr/bin/env bash
set -euo pipefail

# Launches coordinated Windows Terminal tabs (Gemini, Open Code, Codex) from WSL.
# Each tab shares the same working directory inside WSL and runs its own command,
# then drops to an interactive shell so you can keep working. The script shells
# out to `wt.exe`, so it must be available via the configured path.

usage() {
    cat <<'USAGE'
Usage: aisuite.sh [directory]

Spawns three Windows Terminal tabs (Gemini, Open Code, Codex) rooted in the provided directory (defaults to current working directory).

Environment overrides:
  AISUITE_WT_PATH       Path to wt.exe (default /mnt/c/Windows/System32/wt.exe)
  AISUITE_WINDOW_ID     Window identifier for wt's -w flag (default 0)
  AISUITE_PROFILE       Windows Terminal profile name to use (default Ubuntu)
  AISUITE_GEMINI_CMD    Command to run in the Gemini tab (default gemini)
  AISUITE_OPEN_CODE_CMD Command to run in the Open Code tab (default opencode)
  AISUITE_CODEX_CMD     Command to run in the Codex tab (default codex)
USAGE
}

target_dir=${1:-$PWD}
shift || true

if [[ ! -d $target_dir ]]; then
    printf 'Error: directory "%s" not found\n' "$target_dir" >&2
    exit 1
fi

if ! command -v realpath >/dev/null 2>&1; then
    printf 'Error: realpath command not available in this environment.\n' >&2
    exit 1
fi

linux_dir=$(realpath "$target_dir")

wt_path=${AISUITE_WT_PATH:-/mnt/c/Windows/System32/wt.exe}
window_id=${AISUITE_WINDOW_ID:-0}
profile=${AISUITE_PROFILE:-Ubuntu}

gemini_cmd=${AISUITE_GEMINI_CMD:-"gemini"}
open_code_cmd=${AISUITE_OPEN_CODE_CMD:-"opencode"}
codex_cmd=${AISUITE_CODEX_CMD:-"codex"}

if [[ ! -x $wt_path ]]; then
    printf 'Error: wt executable not found at %s\n' "$wt_path" >&2
    exit 1
fi

build_tab() {
    local title=$1
    local run_cmd=$2
    local payload

    # Construct the bash -lc payload to run inside the tab.
    printf -v payload 'cd "%s" && %s; exec bash' "$linux_dir" "$run_cmd"

    tabs+=( new-tab --title "$title" --profile "$profile" -- bash -lc "$payload" )
}

declare -a tabs
build_tab "Gemini" "$gemini_cmd"
build_tab "Open Code" "$open_code_cmd"
build_tab "Codex" "$codex_cmd"

command=("$wt_path" -w "$window_id")
command+=("${tabs[@]}")

# shellcheck disable=SC2068 # pass through the array as separate arguments
"${command[@]}"
