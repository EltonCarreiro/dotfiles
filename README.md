# dotfiles

My macOS development environment, reproducible on a new machine with one command.
Managed by [chezmoi](https://chezmoi.io); packages come from a Brewfile that chezmoi
renders from `.chezmoidata/packages.yaml`.

## Bootstrap a new Mac

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply eltoon
```

Replace `eltoon` with your GitHub username. chezmoi asks four questions (name, email,
personal machine, git signing key), then runs, in order:

1. Xcode Command Line Tools
2. Homebrew
3. `brew bundle` for every package group
4. Dotfiles into `$HOME`
5. Language runtimes (Node LTS, Python 3.13, Ruby 3.4)
6. Xcode via `xcodes` (needs an Apple ID sign-in)
7. macOS system preferences

Budget an hour, mostly downloads. Ruby compiles from source and Xcode is a large download.

Run it from a real terminal, not from a script or an SSH session without a TTY.
Several casks (Docker Desktop, 1Password, Slack) need `sudo` to place privileged
helpers, and Xcode needs an Apple ID. Those steps prompt and will fail silently
if nothing can answer them.

If the package step reports failures, fix the cause and re-run just that step:

```bash
chezmoi state delete-bucket --bucket=scriptState
chezmoi apply
```

That clears the record of which scripts have run, so the next apply re-runs them.
It is safe: every script is idempotent.

## What is installed

Package groups live in `.chezmoidata/packages.yaml`:

| Group | Contents |
|---|---|
| `cli-core` | git, gh, gnupg, fzf, yq, neovim, chezmoi, 1Password CLI |
| `runtimes` | nvm, uv, chruby, ruby-install, go, openjdk |
| `engineering-apps` | VS Code, Claude Code, Claude, Ghostty, iTerm2, DBeaver, Docker, ngrok, 1Password, Raycast, Rectangle, Chrome |
| `cloud-infra` | kubectl, helm, k9s, minikube, skaffold, terraform, terragrunt, pulumi, gcloud, doppler, act, postgres |
| `apple-mobile` | xcodes, ideviceinstaller, Android Studio, Apple Configurator |
| `collaboration` | Slack, Loom, Obsidian, Rippling, Logi Tune |
| `personal` | Spotify, Discord, Clocker. Only on machines answered "personal = yes" |
| `optional-ides` | Cursor, GoLand, WebStorm. Commented out; uncomment to install |

## Daily use

```bash
chezmoi edit --apply ~/.zshrc   # edit a managed file and apply it
chezmoi re-add ~/.zshrc         # pull in a change you made directly
chezmoi update                  # git pull + apply, on any machine
chezmoi diff                    # what would change
```

To add or remove software, edit `.chezmoidata/packages.yaml` and run `chezmoi apply`.
`brew bundle` re-runs automatically because the rendered script's hash changed.

To change a runtime version, edit the `runtimes:` block at the bottom of the same file.

## Manual steps after bootstrap

These need a human because they involve signing in or accepting a licence.

- [ ] 1Password: sign in, then Settings → Developer → enable **Use the SSH agent**
      and **Integrate with 1Password CLI**
- [ ] Add your SSH public key to GitHub, and paste it into
      `~/.config/chezmoi/chezmoi.toml` as `signingKey` to turn on commit signing
- [ ] `gh auth login`
- [ ] `gcloud auth login && gcloud auth application-default login`
- [ ] `doppler login`
- [ ] Docker Desktop: open once and accept the licence
- [ ] Slack, Obsidian, Rippling, Loom: sign in
- [ ] Xcode: open once to install additional components, then
      `sudo xcodebuild -license accept`
- [ ] Android Studio: run the first-launch wizard to fetch the SDK
- [ ] Raycast: restore settings from its own backup file
- [ ] `git config --global user.name` if you left the name prompt blank

## Not managed here

No Homebrew cask exists for these, so install them by hand if you want them:

- Keychron Engine (keyboard firmware)
- Dia (browser)
- Habbo Launcher

## Layout

```
.chezmoi.toml.tmpl          prompts asked once per machine
.chezmoidata/packages.yaml  every package, grouped by purpose
.chezmoiscripts/            ordered lifecycle scripts
dot_*                       files that land in $HOME
private_*                   files written with 0600 permissions
```

Scripts named `run_once_*` run a single time per machine. Scripts named
`run_onchange_*` re-run whenever their contents change, which is how a package
list edit triggers exactly one `brew bundle`.
