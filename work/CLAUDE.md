# ~/work

Every work repository is cloned into `~/work/repos/<name>`. Nothing else lives
in `~/work`.

## The collaboration framework

`repos/collaboration-framework` is the planning workspace for all of this work:
teams, projects, briefs, designs, technical plans (TIPs), milestones and
tickets, kept as markdown. Each project's plan and open questions live there,
not in the code repository.

- **Change it only through its skills** (`project-new`, `brief-update`,
  `tip-new`, `ticket-move`, `doc-signoff`, …). `~/work/.claude/skills` links
  to them, so they are available in any session under `~/work`. Its
  operating guide, imported below, says which skill does what.
- **Run every skill step from the repository root.** Skill commands such as
  `uv run scripts/workspace.py check` and paths such as `projects/<slug>/` or
  `.agents/skills/...` are relative to `~/work/repos/collaboration-framework`,
  so run them with that as the working directory.
- **Never run a command that writes to find out whether it would refuse.**
  Use the read-only commands (`check`, `board`, `trace`, `questions`) or a
  `--dry-run` flag where a command has one.
- `repos/collaboration-framework/engineering/` holds the conventions every
  codebase follows.

@repos/collaboration-framework/AGENTS.md
