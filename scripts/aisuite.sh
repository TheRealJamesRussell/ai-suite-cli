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

detect_wt() {
    local win_path
    win_path=$(cmd.exe /c "where wt.exe" 2>/dev/null | tr -d '\r' || true)
    if [[ -z $win_path ]]; then
        return 1
    fi
    local first_win_path=${win_path%%$'\n'*}
    local wsl_path
    wsl_path=$(wslpath -a "$first_win_path" 2>/dev/null || true)
    if [[ -n $wsl_path ]]; then
        printf '%s\n' "$wsl_path"
        return 0
    fi
    return 1
}

wt_path=${AISUITE_WT_PATH:-/mnt/c/Windows/System32/wt.exe}
window_id=${AISUITE_WINDOW_ID:-0}
profile=${AISUITE_PROFILE:-Ubuntu}

gemini_cmd=${AISUITE_GEMINI_CMD:-"gemini"}
open_code_cmd=${AISUITE_OPEN_CODE_CMD:-"opencode"}
codex_cmd=${AISUITE_CODEX_CMD:-"codex"}

if [[ ! -x $wt_path ]]; then
    if detected_path=$(detect_wt); then
        wt_path=$detected_path
    fi
fi

if [[ ! -x $wt_path ]]; then
    printf 'Error: wt executable not found. Checked %s and Windows search results; set AISUITE_WT_PATH explicitly.\n' "$wt_path" >&2
    exit 1
fi

build_tab() {
    local title=$1
    local run_cmd=$2
    local payload

    # Construct the bash -lc payload to run inside the tab without wt command separators.
    printf -v payload 'cd "%s"\n%s\nexec bash' "$linux_dir" "$run_cmd"

    if [[ ${#tabs[@]} -ne 0 ]]; then
        tabs+=( ';' )
    fi
    tabs+=( new-tab --title "$title" --profile "$profile" -- bash -lic "$payload" )
}

declare -a tabs=()
build_tab "Gemini" "$gemini_cmd"
build_tab "Open Code" "$open_code_cmd"
build_tab "Codex" "$codex_cmd"

command=("$wt_path" -w "$window_id")
command+=("${tabs[@]}")

# shellcheck disable=SC2068 # pass through the array as separate arguments
"${command[@]}"
