#!/usr/bin/env bash
set -euo pipefail

usage() {
    echo "Usage: $(basename "$0") <destination_directory>" >&2
    exit 1
}

# Resolve absolute path (prefer realpath/readlink if available)
abspath() {
    if command -v realpath >/dev/null 2>&1; then realpath -m -- "$1"
    elif command -v readlink >/dev/null 2>&1 && readlink -f / >/dev/null 2>&1; then readlink -f -- "$1"
    else
        # Fallback: best-effort
        case "$1" in
            /*) printf "%s\n" "$1" ;;
            *)  printf "%s/%s\n" "$(pwd -P)" "$1" ;;
        esac
    fi
}

[[ $# -eq 1 ]] || usage

script_path="$(abspath "${BASH_SOURCE[0]}")"
repo_root="$(abspath "$(dirname -- "$script_path")")"
dest_abs="$(abspath "$1")"

# Prevent copying into the repo itself
case "$dest_abs" in
    "$repo_root"|"$repo_root"/*)
        echo "Error: Destination must not be inside the repository: $repo_root" >&2
        exit 1
        ;;
esac

mkdir -p -- "$dest_abs"

# Iterate all files, preserving relative paths, excluding .git, this script, and top-level README.md
# Use -print0/IFS-safe loop to handle spaces/newlines in filenames.
find "$repo_root" \
    -path "$repo_root/.git" -prune -o \
    -path "$script_path" -prune -o \
    -path "$repo_root/README.md" -prune -o \
    -type f -print0 |
while IFS= read -r -d '' src; do
    rel="${src#$repo_root/}"
    dst="$dest_abs/$rel"

    mkdir -p -- "$(dirname -- "$dst")"

    if [[ -e "$dst" ]]; then
        echo "Warning: overwriting existing file: $dst" >&2
    fi

    # Copy file, preserving mode and timestamps
    cp -p -- "$src" "$dst"
done

echo "Copy complete to: $dest_abs"