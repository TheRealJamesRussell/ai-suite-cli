#!/usr/bin/env bash
set -euo pipefail

# Launches coordinated Windows Terminal tabs (Gemini, Open Code, Codex) from WSL.
# Each tab shares the same working directory inside WSL and runs its own command,
# then drops to an interactive shell so you can keep working. The script shells
# out to `wt.exe`, so it must be available via the configured path.

usage() {
    cat <<'USAGE'
Usage: aisuite.sh [directory]

Spawns configured Windows Terminal tabs rooted in the provided directory (defaults to current working directory).

Environment overrides:
  AISUITE_WT_PATH       Path to wt.exe (default /mnt/c/Windows/System32/wt.exe)
  AISUITE_WINDOW_ID     Window identifier for wt's -w flag (default 0)
  AISUITE_PROFILE       Default Windows Terminal profile when not provided per tab (default Ubuntu)
  AISUITE_CONFIG_PATH   Override the tab configuration path (default ~/.config/aisuite/tabs.conf)
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
script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
default_config="$script_dir/../config/tabs.conf"

trim() {
    local str=$1
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "$str"
}

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
default_profile=${AISUITE_PROFILE:-Ubuntu}
config_path=${AISUITE_CONFIG_PATH:-$HOME/.config/aisuite/tabs.conf}

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
    local tab_profile=${3:-$default_profile}
    local payload

    # Construct the bash -lc payload to run inside the tab without wt command separators.
    printf -v payload 'cd "%s"\n%s\nexec bash' "$linux_dir" "$run_cmd"

    if [[ ${#tabs[@]} -ne 0 ]]; then
        tabs+=( ';' )
    fi
    tabs+=( new-tab --title "$title" --profile "$tab_profile" -- bash -lic "$payload" )
}

declare -a tabs=()
config_tab_count=0

load_tabs_from_file() {
    local file=$1
    local line

    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        if [[ -z ${line//[[:space:]]/} ]]; then
            continue
        fi
        if [[ ${line:0:1} == '#' ]]; then
            continue
        fi

        IFS='|' read -r raw_title raw_cmd raw_profile <<<"$line"
        local title
        local cmd
        local tab_profile
        title=$(trim "${raw_title:-}")
        cmd=$(trim "${raw_cmd:-}")
        tab_profile=$(trim "${raw_profile:-}")

        if [[ -z $title || -z $cmd ]]; then
            printf 'Warning: skipping malformed line in %s: %s\n' "$file" "$line" >&2
            continue
        fi

        build_tab "$title" "$cmd" "$tab_profile"
        config_tab_count=$((config_tab_count + 1))
    done < "$file"
}

if [[ -f $config_path ]]; then
    load_tabs_from_file "$config_path"
elif [[ -f $default_config ]]; then
    load_tabs_from_file "$default_config"
fi

if [[ $config_tab_count -eq 0 ]]; then
    build_tab "Gemini" "gemini"
    build_tab "Opencode" "opencode"
    build_tab "Codex" "codex"
fi

command=("$wt_path" -w "$window_id")
command+=("${tabs[@]}")

# shellcheck disable=SC2068 # pass through the array as separate arguments
"${command[@]}"
