# Homebrew (also set in .zprofile; repeated for non-login shells).
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# User binaries and uv-installed tools.
export PATH="$HOME/.local/bin:$PATH"

# Go
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$GOPATH/bin:$PATH"

# Java, for Android tooling
if [ -d "$(brew --prefix)/opt/openjdk" ]; then
    export JAVA_HOME="$(brew --prefix)/opt/openjdk"
    export PATH="$JAVA_HOME/bin:$PATH"
fi

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
[ -d "$ANDROID_HOME" ] && export PATH="$ANDROID_HOME/platform-tools:$PATH"

export EDITOR="nvim"
export VISUAL="nvim"
