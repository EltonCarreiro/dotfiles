# uv manages Python versions, virtualenvs and global CLI tools.
# Common entry points:
#   uv python install 3.13     install an interpreter
#   uv venv                    create .venv in the current project
#   uv tool install ruff       install a global CLI tool
export UV_PYTHON_PREFERENCE="managed"

alias venv="uv venv"
alias pip="uv pip"
