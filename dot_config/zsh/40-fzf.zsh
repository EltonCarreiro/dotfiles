if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --info=inline"
    # Key bindings need zle, which only exists in a real interactive terminal.
    if [[ -o interactive ]] && [ -t 0 ]; then
        source <(fzf --zsh)
    fi
fi
