# dotfiles

My macOS development environment, reproducible on a new machine with one command.
Managed by [chezmoi](https://chezmoi.io); packages come from a Brewfile that chezmoi
renders from `.chezmoidata/packages.yaml`.

## Bootstrap a new Mac

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/eltoncarreiro/dotfiles/main/bootstrap.sh)"
```

That works on a factory-fresh Mac with nothing installed. `bootstrap.sh` installs
the Xcode Command Line Tools headlessly (git on a new Mac is only a stub until
they exist, and chezmoi needs git to clone this repo), installs chezmoi, and then
runs `chezmoi init --apply eltoncarreiro`. Set `GITHUB_USER` to point it at a fork.

If the Command Line Tools are already present you can skip the wrapper:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply eltoncarreiro
```

chezmoi asks four questions (name, email, personal machine, git signing key),
then runs, in order:

1. Xcode Command Line Tools (no-op after bootstrap.sh)
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
chezmoi state delete --bucket=entryState --key="$HOME/.chezmoiscripts/10-packages.sh"
chezmoi apply
```

`run_onchange_` scripts record their content hash in the `entryState` bucket, so
deleting that one key makes the next apply re-run that one script. The
`scriptState` bucket is a different thing: it belongs to `run_once_` scripts, and
clearing it will not re-run the package step.

To re-run every script, delete each key under `.chezmoiscripts/`. All of them are
idempotent, so this is safe. List them with:

```bash
chezmoi state dump | grep chezmoiscripts
```

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

**Apple Configurator** is a free Mac App Store app, but `mas` can only download
it if the Apple Account signed in to the App Store has acquired it before.
If you see "Redownload Unavailable with This Apple Account", open the App Store,
search for Apple Configurator and click **Get** once. After that it belongs to
your account, and you can uncomment the `mas:` block in the `apple-mobile` group
of `.chezmoidata/packages.yaml` so future machines install it automatically.

## Layout

```
bootstrap.sh                one-command entry point for a blank Mac
.chezmoi.toml.tmpl          prompts asked once per machine
.chezmoidata/packages.yaml  every package, grouped by purpose
.chezmoiscripts/            ordered lifecycle scripts
dot_*                       files that land in $HOME
private_*                   files written with 0600 permissions
```

Scripts named `run_once_*` run a single time per machine. Scripts named
`run_onchange_*` re-run whenever their contents change, which is how a package
list edit triggers exactly one `brew bundle`.
