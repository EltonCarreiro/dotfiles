# Homebrew's completion functions.
if type brew >/dev/null 2>&1; then
    FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
# Rebuild the completion cache at most once a day.
if [ -n "$(find "${ZDOTDIR:-$HOME}/.zcompdump" -mtime +1 2>/dev/null)" ] \
   || [ ! -f "${ZDOTDIR:-$HOME}/.zcompdump" ]; then
    compinit
else
    compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors ''

setopt AUTO_CD
setopt INTERACTIVE_COMMENTS
