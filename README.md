# llms_shared_context — Personal LLM Knowledge Hub

Your centralized, tool-agnostic repository for skills, workflows, and agent configuration that works across **any** LLM coding assistant.

## Philosophy

- **One source of truth** — Update skills/workflows once, propagate everywhere
- **Tool-agnostic** — Works with Gemini, Claude Code, Cursor, and any future tools
- **Owner-specific** — Your personal patterns and preferences, not tied to any tool

## Directory Structure

```
{ROOT}/llms_shared_context/
├── skills/              # Reusable skills (SKILL.md format)
│   ├── systematic-debugging/
│   ├── playwright-skill/
│   └── ...
│
├── workflows/           # Core workflows (resume, wrapup, etc.)
│   ├── resume.md
│   ├── wrapup.md
│   └── ...
│
├── templates/           # Templates for init script
│   └── AGENT_INSTRUCTIONS.template.md
│
├── scripts/             # Management scripts
│   ├── init.sh          # Initialize new repos
│   └── update.sh        # Update existing repos
│
└── README.md            # This file
```

## Quick Start

### Initialize a New Repo

```bash
{ROOT}/llms_shared_context/scripts/init.sh /path/to/repo
```

This creates:
- `.agent/skills` → symlink to `~/llms/skills`
- `.agent/workflows` → symlink to `~/llms/workflows`
- `.agent/history/`, `techdocs/`, `rules/` → local (project-specific)
- `GEMINI.md` → local agent instructions (customize per project)
- `CLAUDE.md` → symlink to GEMINI.md
- `.cursorrules` → symlink to GEMINI.md

### Update an Existing Repo

```bash
{ROOT}/llms_shared_context/scripts/update.sh /path/to/repo
```

Converts existing local skills/workflows to symlinks.

## Adding Skills

Drop a new folder into `{ROOT}/llms_shared_context/skills/`:

```
skills/
└── my-new-skill/
    └── SKILL.md       # Required: main instruction file
    └── scripts/       # Optional: helper scripts
    └── examples/      # Optional: reference implementations
```

### SKILL.md Format

```markdown
---
name: my-skill-name
description: What this skill does and when to use it
---

# Skill Name

[Detailed instructions the LLM will follow...]
```

**All repos automatically get the new skill** via symlink.

## Adding Workflows

Create a new `.md` file in `{ROOT}/llms_shared_context/workflows/`:

```markdown
---
description: Short description for workflow list
---

# /workflow-name - Title

[Instructions for this workflow...]

## Steps

1. First step
2. Second step
```

### Workflow Annotations

- `// turbo` — Auto-run the next command without confirmation
- `// turbo-all` — Auto-run ALL commands in the workflow

## Tool Compatibility

| Tool | Reads | Skills | Workflows |
|------|-------|--------|-----------|
| **Gemini/Antigravity** | `GEMINI.md` + `.agent/` | ✅ Via symlink | ✅ Via symlink |
| **Claude Code** | `CLAUDE.md` + `.claude/` | ✅ Via `.agent/skills` | ✅ Copies in `.claude/commands/` |
| **Cursor** | `.cursorrules` | ✅ Via `.agent/skills` | ✅ Via `.agent/workflows` |

## Current Inventory

### Skills (23)

| Category | Skills |
|----------|--------|
| **Planning** | writing-plans, executing-plans, planning-with-files |
| **Development** | senior-fullstack, senior-architect, frontend-dev-guidelines |
| **Debugging** | systematic-debugging, verification-before-completion |
| **UI/UX** | ui-ux-pro-max, canvas-design, core-components |
| **Testing** | playwright-skill, webapp-testing |
| **Agents** | autonomous-agent-patterns, dispatching-parallel-agents, subagent-driven-development |
| **Frameworks** | bun-development, react-best-practices, javascript-mastery |
| **Infrastructure** | mcp-builder, llm-app-patterns |
| **Utilities** | file-organizer, app-store-optimization |

### Workflows (8)

| Command | Purpose |
|---------|---------|
| `/resume` | Get up to speed on recent sessions |
| `/wrapup` | Document session before ending |
| `/commit` | Create git commit with conventional message |
| `/push` | Push to origin/main |
| `/gmp` | Commit and push in one go |
| `/cc` | Check context/token usage |
| `/trawl` | Deep codebase exploration |
| `/grill` | Rigorous requirements interview |

## Syncing Across Machines

Initialize as a git repo for backup and multi-machine sync:

```bash
cd {ROOT}/llms_shared_context
git init
git add .
git commit -m "Initial commit: personal LLM knowledge hub"

# Push to your private repo
git remote add origin git@github.com:yourusername/llms_shared_context.git
git push -u origin main
```

On a new machine:
```bash
git clone git@github.com:yourusername/llms_shared_context.git {ROOT}/llms_shared_context
```

## Maintenance

### Update All Repos After Adding Skills/Workflows

Skills update automatically via symlinks.

For workflows on Claude Code (which uses copies):
```bash
for repo in {ROOT}/*/; do
  if [ -d "$repo/.claude/commands" ]; then
    {ROOT}/llms_shared_context/scripts/update.sh "$repo"
  fi
done
```

### Clean Up Old Backups

After updating repos, clean up backups:
```bash
rm -rf {ROOT}/*/.agent/*.backup
```

## Version History

- **2025-01-18**: Initial creation with 23 skills, 8 workflows
- Migrated from `~/.gemini/antigravity/`
