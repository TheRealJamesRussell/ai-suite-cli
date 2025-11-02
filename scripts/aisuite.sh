#!/usr/bin/env bash
set -euo pipefail

# Launches coordinated Windows Terminal tabs (Gemini, Open Code, Codex) from WSL.
# Each tab shares the same working directory inside WSL and runs its own command,
# then drops to an interactive shell so you can keep working. The script shells
# out to `wt.exe`, so it must be available via the configured path.

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
default_config="$script_dir/../config/tabs.conf"
config_path=${AISUITE_CONFIG_PATH:-$HOME/.config/aisuite/tabs.conf}

usage() {
    cat <<'USAGE'
Usage: aisuite.sh [directory]

Spawns configured Windows Terminal tabs rooted in the provided directory (defaults to current working directory).

Environment overrides:
  AISUITE_WT_PATH       Path to wt.exe (default /mnt/c/Windows/System32/wt.exe)
  AISUITE_WINDOW_ID     Window identifier for wt's -w flag (default 0)
  AISUITE_PROFILE       Default Windows Terminal profile when not provided per tab (default Ubuntu)
  AISUITE_CONFIG_PATH   Override the tab configuration path (default ~/.config/aisuite/tabs.conf)

Commands:
  aisuite.sh config <action> [options]
      Manage tab definitions (list, add, remove).
USAGE
}

trim() {
    local str=$1
    str="${str#"${str%%[![:space:]]*}"}"
    str="${str%"${str##*[![:space:]]}"}"
    printf '%s' "$str"
}

config_usage() {
    cat <<'USAGE'
Config commands:
  config list
      Show the tabs that will be launched (reads user config first, then default template).
  config add <title> <command> [profile]
      Append a new tab entry to the user config file.
  config remove <title>
      Remove the first tab entry matching <title> from the user config file.
USAGE
}

ensure_config_dir() {
    local config_dir
    config_dir=$(dirname "$config_path")
    mkdir -p "$config_dir"
}

bootstrap_user_config() {
    if [[ -f $config_path ]]; then
        return
    fi

    ensure_config_dir

    if [[ -f $default_config ]]; then
        cp "$default_config" "$config_path"
    else
        : >"$config_path"
    fi
}

config_list() {
    local source=""
    if [[ -f $config_path ]]; then
        source=$config_path
    elif [[ -f $default_config ]]; then
        source=$default_config
    else
        printf 'No configuration file found. Add tabs with "%s config add".\n' "$(basename "$0")" >&2
        return 1
    fi

    local index=1
    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        if [[ -z ${line//[[:space:]]/} || ${line:0:1} == '#' ]]; then
            continue
        fi

        IFS='|' read -r raw_title raw_cmd raw_profile <<<"$line"
        local title cmd tab_profile
        title=$(trim "${raw_title:-}")
        cmd=$(trim "${raw_cmd:-}")
        tab_profile=$(trim "${raw_profile:-}")

        printf '%2d. %-12s -> %s' "$index" "$title" "$cmd"
        if [[ -n $tab_profile ]]; then
            printf ' (profile: %s)' "$tab_profile"
        fi
        printf '\n'
        index=$((index + 1))
    done < "$source"
}

config_add() {
    if [[ $# -lt 2 ]]; then
        printf 'Usage: %s config add <title> <command> [profile]\n' "$(basename "$0")" >&2
        return 1
    fi

    local title=$1
    local command=$2
    local profile=${3:-}

    bootstrap_user_config

    if [[ -n $profile ]]; then
        printf '%s|%s|%s\n' "$title" "$command" "$profile" >> "$config_path"
    else
        printf '%s|%s\n' "$title" "$command" >> "$config_path"
    fi

    printf 'Added tab "%s" -> %s to %s\n' "$title" "$command" "$config_path"
}

config_remove() {
    if [[ $# -lt 1 ]]; then
        printf 'Usage: %s config remove <title>\n' "$(basename "$0")" >&2
        return 1
    fi

    local target_title=$1

    if [[ ! -f $config_path ]]; then
        printf 'No user configuration file at %s. Nothing to remove.\n' "$config_path" >&2
        return 1
    fi

    local tmp_file
    tmp_file=$(mktemp)
    local removed=0

    while IFS= read -r line || [[ -n $line ]]; do
        line=${line%$'\r'}
        if [[ -z ${line//[[:space:]]/} ]]; then
            printf '%s\n' "$line" >> "$tmp_file"
            continue
        fi
        if [[ ${line:0:1} == '#' ]]; then
            printf '%s\n' "$line" >> "$tmp_file"
            continue
        fi

        IFS='|' read -r raw_title raw_cmd raw_profile <<<"$line"
        local title
        title=$(trim "${raw_title:-}")

        if [[ $removed -eq 0 && $title == "$target_title" ]]; then
            removed=1
            continue
        fi

        printf '%s\n' "$line" >> "$tmp_file"
    done < "$config_path"

    mv "$tmp_file" "$config_path"

    if [[ $removed -eq 0 ]]; then
        printf 'No entry titled "%s" was found in %s.\n' "$target_title" "$config_path" >&2
        return 1
    fi

    printf 'Removed tab "%s" from %s\n' "$target_title" "$config_path"
}

handle_config_command() {
    if [[ $# -lt 1 ]]; then
        config_usage >&2
        return 1
    fi

    local action=$1
    shift

    case $action in
        list)
            config_list "$@"
            ;;
        add)
            config_add "$@"
            ;;
        remove)
            config_remove "$@"
            ;;
        *)
            config_usage >&2
            return 1
            ;;
    esac
}

if [[ $# -gt 0 ]]; then
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        config)
            shift
            if ! handle_config_command "$@"; then
                exit 1
            fi
            exit 0
            ;;
    esac
fi

target_dir=${1:-$PWD}

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
default_profile=${AISUITE_PROFILE:-Ubuntu}

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
