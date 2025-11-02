#!/usr/bin/env bash
set -euo pipefail

# Simple launcher for spawning Windows Terminal tabs from WSL.

usage() {
    cat <<'USAGE'
Usage: aisuite.sh <directory>

Spawns three Windows Terminal tabs (Gemini, Open Code, Codex) rooted in <directory>.

Environment overrides:
  AISUITE_WT_PATH       Path to wt.exe (default /mnt/c/Windows/System32/wt.exe)
  AISUITE_WINDOW_ID     Window identifier for wt's -w flag (default 0)
  AISUITE_PROFILE       Windows Terminal profile name to use (default Ubuntu)
  AISUITE_GEMINI_CMD    Command to run in the Gemini tab (default ./run-gemini)
  AISUITE_OPEN_CODE_CMD Command to run in the Open Code tab (default ./run-open-code)
  AISUITE_CODEX_CMD     Command to run in the Codex tab (default ./run-codex)
USAGE
}

if [[ $# -lt 1 ]]; then
    usage >&2
    exit 1
fi

target_dir=$1
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

gemini_cmd=${AISUITE_GEMINI_CMD:-"./run-gemini"}
open_code_cmd=${AISUITE_OPEN_CODE_CMD:-"./run-open-code"}
codex_cmd=${AISUITE_CODEX_CMD:-"./run-codex"}

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
