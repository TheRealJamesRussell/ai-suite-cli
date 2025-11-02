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

mkdir -p "$target_bin"

ln -sfn "$launcher" "$link_path"

printf 'Installed launcher:\n  source: %s\n  link:   %s\n' "$launcher" "$link_path"
printf 'Ensure %s is on your PATH and reopen the shell if needed.\n' "$target_bin"
