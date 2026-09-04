# Global instructions for Claude Code

## Environment
- macOS, zsh, Homebrew at `/opt/homebrew`.
- Node via nvm, Python via uv, Ruby via chruby, Go and Java via Homebrew.
- This machine's setup is reproducible from the `dotfiles` repo managed by chezmoi.
  Package changes belong in `.chezmoidata/packages.yaml`, not in ad-hoc `brew install`.

## Preferences
- Prefer `uv` over `pip`/`venv`, `uv run` over activating a virtualenv.
- Use `rg` and `fd` style tools when available; fall back to grep and find.
- When editing dotfiles under `$HOME`, edit the chezmoi source and apply,
  rather than editing the file in place. `chezmoi edit --apply <file>`.
