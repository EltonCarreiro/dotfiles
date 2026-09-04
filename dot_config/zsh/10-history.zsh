HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # timestamp each entry
setopt INC_APPEND_HISTORY        # write as you go, not at exit
setopt SHARE_HISTORY             # share across open shells
setopt HIST_IGNORE_ALL_DUPS      # keep only the most recent duplicate
setopt HIST_IGNORE_SPACE         # a leading space hides the command
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY               # expand !! before running it
