#!/bin/bash
# Xcode Command Line Tools: required by Homebrew and by git itself.
set -euo pipefail

if xcode-select -p >/dev/null 2>&1; then
    echo "[clt] Command Line Tools already installed, skipping."
    exit 0
fi

echo "[clt] Installing Xcode Command Line Tools..."
xcode-select --install || true

# xcode-select --install returns immediately; wait for the GUI installer.
echo "[clt] Waiting for the installation to finish (accept the dialog if shown)..."
until xcode-select -p >/dev/null 2>&1; do
    sleep 10
done
echo "[clt] Command Line Tools installed."
