# Every Nx workspace on this Mac shares the local remote cache served by the
# local.nx-cache launchd agent (~/.local/share/nx-cache/server.mjs).
# Claude Code sessions get the same variable from ~/.claude/settings.json,
# since agent shells do not source this file.
export NX_SELF_HOSTED_REMOTE_CACHE_SERVER="http://127.0.0.1:4380"
