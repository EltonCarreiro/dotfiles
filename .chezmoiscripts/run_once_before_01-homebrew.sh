#!/bin/bash
# Homebrew itself. Everything else in this repo depends on it.
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
    echo "[brew] Homebrew already installed, skipping."
    exit 0
fi

echo "[brew] Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Make brew available to the scripts that run after this one.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
echo "[brew] Homebrew installed."
