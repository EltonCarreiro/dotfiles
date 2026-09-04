# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ll="ls -lahG"

# Git
alias gs="git status --short --branch"
alias gd="git diff"
alias gl="git log --oneline --graph --decorate -20"
alias gp="git push"
alias gco="git checkout"

# Kubernetes
alias k="kubectl"
alias kx="kubectx"
alias kn="kubens"

# Terraform
alias tf="terraform"

# chezmoi: the two commands used most
alias cm="chezmoi"
alias cme="chezmoi edit --apply"

# Reload the shell
alias reload="exec zsh"
