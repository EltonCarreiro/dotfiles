#!/bin/bash
# Bootstrap a blank Mac with a single command:
#
#   bash -c "$(curl -fsSL https://raw.githubusercontent.com/eltoncarreiro/dotfiles/main/bootstrap.sh)"
#
# chezmoi cannot run any of its own scripts until git has cloned this repo, and
# git on a fresh Mac is a stub that fails until the Xcode Command Line Tools are
# installed. This script exists only to break that cycle: it installs the
# Command Line Tools, installs chezmoi, and hands over to `chezmoi init --apply`.
# Everything else (Homebrew, packages, dotfiles, runtimes) lives in
# .chezmoiscripts/ and runs from there.
#
# Run it from a real terminal: chezmoi asks four questions and some casks
# prompt for sudo. Extra arguments are passed through to `chezmoi init`.
set -euo pipefail

GITHUB_USER="${GITHUB_USER:-eltoncarreiro}"
CHEZMOI_BIN_DIR="${CHEZMOI_BIN_DIR:-$HOME/.local/bin}"

log() { printf '[bootstrap] %s\n' "$*"; }

if [ "$(uname -s)" != "Darwin" ]; then
    log "This bootstrap only supports macOS."
    exit 1
fi

# 1. Xcode Command Line Tools, installed headlessly through softwareupdate so
#    no GUI dialog has to be clicked. Falls back to the dialog if the catalog
#    lookup fails.
if xcode-select -p >/dev/null 2>&1; then
    log "Command Line Tools already installed."
else
    log "Installing Xcode Command Line Tools (this downloads ~1 GB)..."
    placeholder=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    touch "$placeholder"
    label="$(softwareupdate -l 2>/dev/null \
        | grep -E '^\*.*Command Line Tools' \
        | sed -E 's/^\* Label: //' \
        | sort -V | tail -n 1)"
    if [ -n "$label" ]; then
        log "Found \"$label\"."
        softwareupdate -i "$label" --verbose
    else
        log "Could not find the package in the software update catalog."
        log "Falling back to the GUI installer; accept the dialog when it appears."
        xcode-select --install || true
    fi
    rm -f "$placeholder"
    until xcode-select -p >/dev/null 2>&1; do
        sleep 10
    done
    log "Command Line Tools installed."
fi

# 2. chezmoi. Homebrew will install the managed copy later; this one is just
#    enough to get the repo cloned.
if command -v chezmoi >/dev/null 2>&1; then
    log "chezmoi already installed."
else
    log "Installing chezmoi into $CHEZMOI_BIN_DIR..."
    mkdir -p "$CHEZMOI_BIN_DIR"
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$CHEZMOI_BIN_DIR"
    export PATH="$CHEZMOI_BIN_DIR:$PATH"
fi

# 3. Hand over to chezmoi for everything else.
log "Running chezmoi init --apply $GITHUB_USER"
exec chezmoi init --apply "$GITHUB_USER" "$@"
