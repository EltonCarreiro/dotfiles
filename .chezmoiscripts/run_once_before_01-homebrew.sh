#!/bin/bash
# Homebrew itself. Everything else in this repo depends on it.
set -euo pipefail

if command -v brew >/dev/null 2>&1; then
    echo "[brew] Homebrew already installed, skipping."
    exit 0
fi

# The installer runs with NONINTERACTIVE=1 so it does not stop to ask "press
# RETURN to continue", but in that mode it also refuses to prompt for a
# password: it only checks whether sudo already works and aborts otherwise.
# Ask for the password here, on the real terminal, and keep the ticket fresh
# while the installer runs.
echo "[brew] Homebrew needs sudo to create /opt/homebrew."
sudo -v
while true; do
    sudo -n true
    sleep 50
    kill -0 "$$" 2>/dev/null || exit
done 2>/dev/null &
keepalive=$!
trap 'kill "$keepalive" 2>/dev/null' EXIT

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
