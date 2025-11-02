#!/usr/bin/env bash
set -euo pipefail

# Installer helper for the AI Suite CLI tooling.
# Creates/updates a symlink in ~/.local/bin pointing to scripts/aisuite.sh.

usage() {
    cat <<'USAGE'
Usage: install.sh [link-name]

Options:
  link-name   Optional command name for the launcher (default: ais)

The script ensures scripts/aisuite.sh is executable, creates ~/.local/bin if
missing, and then symlinks the launcher there using the chosen link-name.
USAGE
}

if [[ ${1:-} == "-h" || ${1:-} == "--help" ]]; then
    usage
    exit 0
fi

link_name=${1:-ais}

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
launcher="$script_dir/aisuite.sh"
target_bin="$HOME/.local/bin"
link_path="$target_bin/$link_name"

if [[ ! -f $launcher ]]; then
    printf 'Error: launcher not found at %s\n' "$launcher" >&2
    exit 1
fi

chmod +x "$launcher"

wt_path=${AISUITE_WT_PATH:-}
persisted_path=""

if [[ -z $wt_path && -x /usr/bin/wslpath ]]; then
    win_loc=$(cmd.exe /c "where wt.exe" 2>/dev/null | tr -d '\r' || true)
    if [[ -n $win_loc ]]; then
        first_win_path=${win_loc%%$'\n'*}
        detected_path=$(wslpath -a "$first_win_path" 2>/dev/null || true)
        if [[ -n $detected_path && -e $detected_path ]]; then
            wt_path=$detected_path
            need_persist=1
        fi
    fi
fi

if [[ -z ${wt_path:-} ]]; then
    wt_path=/mnt/c/Windows/System32/wt.exe
else
    need_persist=${need_persist:-0}
fi

marker='# AI Suite CLI wt.exe path'

if [[ ! -e $wt_path ]]; then
    printf 'Warning: wt.exe not found at %s\nSet AISUITE_WT_PATH before running the launcher.\n' "$wt_path" >&2
else
    existing_marker=$(grep -F "$marker" "$HOME/.bashrc" 2>/dev/null || true)

    if [[ ${need_persist:-0} -eq 1 ]]; then
        marker='# AI Suite CLI wt.exe path'
        if [[ -z $existing_marker ]]; then
            {
                printf '\n%s\n' "$marker"
                printf 'export AISUITE_WT_PATH=%q\n' "$wt_path"
            } >> "$HOME/.bashrc"
            persisted_path=$wt_path
        else
            already_persisted=1
        fi
    elif [[ -n $existing_marker ]]; then
        already_persisted=1
    fi
fi

mkdir -p "$target_bin"
ln -sfn "$launcher" "$link_path"

printf 'Installed launcher as %s\n' "$link_path"

if ! printf '%s' "$PATH" | tr ':' '\n' | grep -Fxq "$target_bin"; then
    printf 'Tip: add %s to PATH (e.g., export PATH="%s:$PATH").\n' "$target_bin" "$target_bin"
fi

if [[ -n ${persisted_path:-} ]]; then
    printf 'Detected wt.exe at %s and appended AISUITE_WT_PATH to ~/.bashrc. Run "source ~/.bashrc" in your current shell to load it now.\n' "$persisted_path"
elif [[ -n ${already_persisted:-} ]]; then
    printf 'wt.exe detected at %s (existing AISUITE_WT_PATH entry found in ~/.bashrc).\n' "$wt_path"
elif [[ -e $wt_path ]]; then
    printf 'wt.exe detected at %s. Consider exporting AISUITE_WT_PATH to persist it.\n' "$wt_path"
else
    printf 'Unable to locate wt.exe automatically; update AISUITE_WT_PATH manually.\n'
fi
