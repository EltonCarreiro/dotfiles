# chruby switches between rubies built by ruby-install into ~/.rubies.
_chruby_dir="$(brew --prefix 2>/dev/null)/opt/chruby/share/chruby"
if [ -d "$_chruby_dir" ]; then
    source "$_chruby_dir/chruby.sh"
    source "$_chruby_dir/auto.sh"   # honours .ruby-version per project
fi
unset _chruby_dir
