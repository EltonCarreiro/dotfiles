# Global instructions for Claude Code

## Environment
- macOS, zsh, Homebrew at `/opt/homebrew`.
- Node via nvm, Python via uv, Ruby via chruby, Go and Java via Homebrew.
- This machine's setup is reproducible from the `dotfiles` repo managed by chezmoi
  (source: `chezmoi source-path`, normally `~/.local/share/chezmoi`).

## Installing or changing tools: always through chezmoi
Never install a tool ad hoc (`brew install`, `npm install -g`, `nvm install`,
`uv tool install`) and leave it at that. Declare it in the chezmoi source first,
then apply, so a fresh machine ends up identical.

| What | Where it is declared |
| --- | --- |
| Homebrew formulae, casks, App Store apps, VS Code extensions | `.chezmoidata/packages.yaml`, under the fitting group |
| Node version | `runtimes.node` in `.chezmoidata/packages.yaml` |
| Global npm CLIs, such as `pnpm@11` and `go-ios` | `dot_nvm/default-packages`, one npm spec per line |
| Python version | `runtimes.python` in `.chezmoidata/packages.yaml` |
| Global Python CLIs | `dot_config/uv/tools.txt` |
| Ruby version | `runtimes.ruby` in `.chezmoidata/packages.yaml` |
| Shell configuration | `dot_config/zsh/*.zsh`, one concern per file |

- pnpm is pinned to major 11 and comes from npm, not Homebrew, which only
  ships the latest major.
- `default-packages` is only read when nvm installs a new Node version. After
  adding a line, also run `npm install -g <spec>` for the current version.
- Apply with `chezmoi apply <target>` for the files you changed, and
  `chezmoi apply --include=scripts` to re-run changed install scripts. Run
  `chezmoi diff` first: a plain `chezmoi apply` overwrites local drift, such as
  the lines Docker Desktop appends to `~/.zshrc` and `~/.zprofile`.
- Leave the dotfiles change uncommitted unless asked to commit, and say so.

## Preferences
- Prefer `uv` over `pip`/`venv`, `uv run` over activating a virtualenv.
- Use `rg` and `fd` style tools when available; fall back to grep and find.
- When editing dotfiles under `$HOME`, edit the chezmoi source and apply,
  rather than editing the file in place. `chezmoi edit --apply <file>`.
