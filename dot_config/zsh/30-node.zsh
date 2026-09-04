# nvm, loaded lazily: sourcing it eagerly adds ~200ms to every shell start.
export NVM_DIR="$HOME/.nvm"

_load_nvm() {
    unset -f nvm node npm npx 2>/dev/null
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && . "$(brew --prefix)/opt/nvm/nvm.sh"
    [ -s "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm" ] \
        && . "$(brew --prefix)/opt/nvm/etc/bash_completion.d/nvm"
}

nvm()  { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm "$@"; }
npx()  { _load_nvm; npx "$@"; }

# Use the .nvmrc of a directory when you cd into it.
autoload -U add-zsh-hook
_nvmrc_hook() {
    [ -f .nvmrc ] || return
    _load_nvm
    nvm use --silent 2>/dev/null
}
add-zsh-hook chpwd _nvmrc_hook
