#!/bin/bash
# Xcode Command Line Tools: required by Homebrew and by git itself.
#
# On a truly blank Mac this script never gets the chance to run, because
# chezmoi needs git to clone the repo first. bootstrap.sh at the repo root
# handles that case; this script covers a machine that already had git
# (for example via a full Xcode install) and is here for completeness.
set -euo pipefail

if xcode-select -p >/dev/null 2>&1; then
    echo "[clt] Command Line Tools already installed, skipping."
    exit 0
fi

echo "[clt] Installing Xcode Command Line Tools..."
placeholder=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
touch "$placeholder"
label="$(softwareupdate -l 2>/dev/null \
    | grep -E '^\*.*Command Line Tools' \
    | sed -E 's/^\* Label: //' \
    | sort -V | tail -n 1)"
if [ -n "$label" ]; then
    softwareupdate -i "$label" --verbose
else
    echo "[clt] Package not found in the update catalog; falling back to the GUI installer."
    xcode-select --install || true
    echo "[clt] Waiting for the installation to finish (accept the dialog if shown)..."
fi
rm -f "$placeholder"

until xcode-select -p >/dev/null 2>&1; do
    sleep 10
done
echo "[clt] Command Line Tools installed."
