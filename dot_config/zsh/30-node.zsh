# nvm, loaded lazily: sourcing it eagerly adds ~200ms to every shell start.
export NVM_DIR="$HOME/.nvm"

# No leading underscore in the name, and no dependency on `brew` being on
# PATH: coding agents run commands in a shell rebuilt from a snapshot that
# drops underscore-prefixed functions and may not have Homebrew on PATH.
# With the old `_load_nvm`, `node` recursed forever in those shells.
nvm_lazy_load() {
    unset -f nvm node npm npx pnpm 2>/dev/null
    local nvm_home="${HOMEBREW_PREFIX:-/opt/homebrew}/opt/nvm"
    [ -s "$nvm_home/nvm.sh" ] && . "$nvm_home/nvm.sh"
    [ -n "${ZSH_VERSION:-}" ] && [ -s "$nvm_home/etc/bash_completion.d/nvm" ] \
        && . "$nvm_home/etc/bash_completion.d/nvm" 2>/dev/null
    return 0
}

nvm()  { nvm_lazy_load; nvm "$@"; }
node() { nvm_lazy_load; node "$@"; }
npm()  { nvm_lazy_load; npm "$@"; }
npx()  { nvm_lazy_load; npx "$@"; }
pnpm() { nvm_lazy_load; pnpm "$@"; }

# Use the .nvmrc of a directory when you cd into it.
autoload -U add-zsh-hook
nvmrc_hook() {
    [ -f .nvmrc ] || return
    nvm_lazy_load
    nvm use --silent 2>/dev/null
}
add-zsh-hook chpwd nvmrc_hook
