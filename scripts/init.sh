#!/bin/bash

# ============================================================================
# LLM INIT - Tool-Agnostic Agent Setup for Any Repository
# ============================================================================
#
# This script initializes a repository with agent workflow support that works
# with ANY LLM coding assistant (Gemini/Antigravity, Claude Code, Cursor, etc.)
#
# Skills and workflows are SYMLINKED from ~/.llms/ (your personal source of truth)
# so updates propagate automatically to all repos.
#
# Creates:
#   - .agent/           → Agent structure with symlinks to ~/.llms/
#   - .claude/          → Claude Code specific (commands mirror workflows)
#   - GEMINI.md         → Agent instructions (customizable per-project)
#   - CLAUDE.md         → Symlink to GEMINI.md
#   - .cursorrules      → Symlink to GEMINI.md (for Cursor)
#
# Usage:
#   ~/.llms/scripts/init.sh              # Initialize current directory
#   ~/.llms/scripts/init.sh /path/to/repo  # Initialize specific directory
#
# ============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Source of truth - dynamically determined from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLMS_DIR="$(dirname "$SCRIPT_DIR")"  # Go up one level from scripts/

# Directory to initialize (current dir or provided path)
TARGET_DIR="${1:-.}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo -e "${BLUE}🚀 LLM INIT - Tool-Agnostic Agent Setup${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""
echo -e "Initializing: ${GREEN}$TARGET_DIR${NC}"
echo -e "Source: ${CYAN}$LLMS_DIR${NC}"
echo ""

# Verify ~/.llms exists
if [ ! -d "$LLMS_DIR" ]; then
    echo -e "${RED}❌ Error: $LLMS_DIR does not exist!${NC}"
    echo -e "${YELLOW}   Run the setup script first or create the directory manually.${NC}"
    exit 1
fi

# Check if .agent already exists
if [ -d "$TARGET_DIR/.agent" ]; then
    echo -e "${YELLOW}⚠️  .agent directory already exists.${NC}"
    read -p "   Overwrite? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted.${NC}"
        exit 1
    fi
    rm -rf "$TARGET_DIR/.agent"
fi

# ============================================================================
# Create directory structures
# ============================================================================
echo -e "${GREEN}📁 Creating .agent directory structure...${NC}"
mkdir -p "$TARGET_DIR/.agent"/{history,rules,techdocs,future_features}

# ============================================================================
# Create symlinks to central ~/.llms/
# ============================================================================
echo -e "${GREEN}🔗 Symlinking skills and workflows from ~/.llms/...${NC}"

# Symlink skills (shared across all repos)
if [ -d "$LLMS_DIR/skills" ]; then
    ln -sfn "$LLMS_DIR/skills" "$TARGET_DIR/.agent/skills"
    echo -e "   ✓ .agent/skills -> ~/.llms/skills"
fi

# Symlink workflows (shared across all repos)
if [ -d "$LLMS_DIR/workflows" ]; then
    ln -sfn "$LLMS_DIR/workflows" "$TARGET_DIR/.agent/workflows"
    echo -e "   ✓ .agent/workflows -> ~/.llms/workflows"
fi

# ============================================================================
# Create GEMINI.md (local, customizable per-project)
# ============================================================================
echo -e "${GREEN}📝 Creating GEMINI.md...${NC}"

# Check for template, otherwise use inline default
if [ -f "$LLMS_DIR/templates/AGENT_INSTRUCTIONS.template.md" ]; then
    cp "$LLMS_DIR/templates/AGENT_INSTRUCTIONS.template.md" "$TARGET_DIR/GEMINI.md"
else
    cat > "$TARGET_DIR/GEMINI.md" << 'GEMINI_EOF'
# Project Rules

**Last Updated:** <!-- Update this date -->

## Step 0: Collaboration Guidelines

[CUSTOMIZE: Add your working style preferences here. Example:]
- Act as a highly experienced developer that mentors and guides architectural decisions
- Be healthily skeptical of my suggestions and double-check my work
- Explain your reasoning for non-trivial decisions

---

## Step 1: Understand the Codebase (REQUIRED)

Before doing anything else, **understand the codebase**.

### Required Reading

| Order | File | Purpose |
|-------|------|---------|
| 1 | `.agent/techdocs/README.md` | **Project architecture and orientation** |
| 2 | `README.md` | Project overview and setup |

### Situational Reading (as needed)

Use `/resume` workflow to search for relevant context, then read these on-demand:

| Topic | Doc |
|-------|-----|
| [Topic 1] | `.agent/techdocs/[doc].md` |
| [Topic 2] | `.agent/rules/[rule].md` |

---

## Step 2: Review Recent Session History (REQUIRED)

Use the `/resume` workflow to intelligently find relevant context:

```
/resume
```

This will:
1. Scan ALL session `BRIEF.md` files for keywords related to your task
2. Help you select 2-5 most relevant sessions to read in full
3. Always include the most recent session for current state

Each session directory contains:
- `BRIEF.md` - 1-2 sentence summary + keywords
- `session.md` - Full details (What We Built, Known Issues, Next Steps, How to Resume)

---

## Step 3: Create Session History (REQUIRED)

When beginning a new session, **create a session directory**:

```bash
mkdir -p .agent/history/$(date +%Y%m%d-%H%M%S)_adhoc
```

- Use current datetime for folder name
- Use "adhoc" as description to begin; update to a theme if one emerges
- Create a `session.md` file to track what we do
- At the end, use `/wrapup` to create `BRIEF.md` and finalize

---

## Step 4: Check for Relevant Skills/Docs (AS NEEDED)

| Need | Check |
|------|-------|
| Reusable patterns | `.agent/skills/` |
| Technical how-tos | `.agent/techdocs/` |
| Past decisions | `.agent/history/` |
| Feature roadmap | `.agent/future_features/` |
| Workflows | `.agent/workflows/` |

---

## Step 5: Follow Project Constraints

**Always:**
- [CUSTOMIZE: Add project-specific setup, e.g., "Activate venv: source venv/bin/activate"]
- Document takeaways in session history
- Use `/wrapup` at the end of sessions

**Never:**
- ❌ Lose insights—write them down
- [CUSTOMIZE: Add project-specific anti-patterns]

---

## Current Status

| Area | Status | Notes |
|------|--------|-------|
| [Component 1] | 🚧 In Progress | [Notes] |
| [Component 2] | ⏳ Not Started | [Notes] |

---

## Quick Reference

| What | Where |
|------|-------|
| **Start here** | `.agent/techdocs/README.md` |
| Workflows | `.agent/workflows/` (`/resume`, `/wrapup`, `/commit`, etc.) |
| Session history | `.agent/history/` |
| Technical docs | `.agent/techdocs/` |
| Feature roadmap | `.agent/future_features/` |
GEMINI_EOF
fi

# ============================================================================
# Create symlinks for other tools
# ============================================================================
echo -e "${GREEN}🔗 Creating tool-specific symlinks...${NC}"

# CLAUDE.md -> GEMINI.md
ln -sf GEMINI.md "$TARGET_DIR/CLAUDE.md"
echo -e "   ✓ CLAUDE.md -> GEMINI.md"

# .cursorrules -> GEMINI.md (for Cursor)
ln -sf GEMINI.md "$TARGET_DIR/.cursorrules"
echo -e "   ✓ .cursorrules -> GEMINI.md"

# ============================================================================
# Create .claude/commands/ (mirrors workflows for Claude Code)
# ============================================================================
echo -e "${GREEN}📁 Creating .claude directory for Claude Code...${NC}"
mkdir -p "$TARGET_DIR/.claude/commands"

# Generate Claude commands that reference the shared workflows
for workflow in "$LLMS_DIR/workflows"/*.md; do
    if [ -f "$workflow" ]; then
        name=$(basename "$workflow")
        # Copy workflow content to Claude command (Claude Code needs local files)
        cp "$workflow" "$TARGET_DIR/.claude/commands/$name"
    fi
done
echo -e "   ✓ Copied workflows to .claude/commands/"

# Create Claude settings
cat > "$TARGET_DIR/.claude/settings.local.json" << 'SETTINGS_EOF'
{
  "permissions": {
    "allow": [
      "Bash(cat:*)",
      "Bash(ls:*)",
      "Bash(mkdir:*)",
      "Bash(echo:*)"
    ]
  }
}
SETTINGS_EOF
echo -e "   ✓ Created .claude/settings.local.json"

# ============================================================================
# Create local techdocs and rules READMEs
# ============================================================================
echo -e "${GREEN}📝 Creating local documentation stubs...${NC}"

cat > "$TARGET_DIR/.agent/techdocs/README.md" << 'TECHDOCS_EOF'
# Technical Documentation

This directory contains must-read documentation for working on this project.

## Contents

| Doc | Purpose |
|-----|---------|
| `README.md` | This file - documentation overview |

## How to Add Docs

When you learn something important about the codebase:
1. Create a new `.md` file in this directory
2. Update the table above
3. If it's a must-read, add it to `GEMINI.md` Required Reading
TECHDOCS_EOF

cat > "$TARGET_DIR/.agent/rules/README.md" << 'RULES_EOF'
# Project Rules

This directory contains architectural rules and constraints that must be followed.

## Contents

| Rule | Purpose |
|------|---------|
| `README.md` | This file - rules overview |

## How to Add Rules

When you establish an important constraint or pattern:
1. Create a new `.md` file in this directory
2. Update the table above
3. If it's critical, add it to `GEMINI.md` Required Reading
RULES_EOF

cat > "$TARGET_DIR/.agent/history/README.md" << 'HISTORY_EOF'
# Session History

This directory contains a record of all development sessions.

## Directory Structure

Each session is a folder named `YYYYMMDD-HHMMSS_description/` containing:
- `session.md` - Full session details
- `BRIEF.md` - 1-2 sentence summary with keywords

## How to Create a Session

```bash
mkdir -p .agent/history/$(date +%Y%m%d-%H%M%S)_adhoc
```

Then create `session.md` inside using the wrapup workflow template.
HISTORY_EOF

cat > "$TARGET_DIR/.agent/future_features/README.md" << 'FUTURE_EOF'
# Future Features

This directory contains planned features and improvement ideas.

## How to Add

Create a `.md` file for each feature with:
- Description of the feature
- Motivation / use cases
- Rough implementation ideas
- Priority level (if known)

These serve as a roadmap and context for future development sessions.
FUTURE_EOF

# ============================================================================
# Update .gitignore
# ============================================================================
echo -e "${GREEN}📝 Updating .gitignore...${NC}"
if [ ! -f "$TARGET_DIR/.gitignore" ]; then
    touch "$TARGET_DIR/.gitignore"
fi

if ! grep -q "# LLM Agent files" "$TARGET_DIR/.gitignore" 2>/dev/null; then
    cat >> "$TARGET_DIR/.gitignore" << 'GITIGNORE_EOF'

# LLM Agent files
.claude/settings.local.json

# Optional - uncomment to ignore session history
# .agent/history/
GITIGNORE_EOF
fi

# ============================================================================
# Done!
# ============================================================================
echo ""
echo -e "${GREEN}✅ LLM INIT Complete!${NC}"
echo ""
echo -e "Directory structure:"
echo ""
echo -e "  ${BLUE}.agent/${NC}"
echo -e "  ├── ${CYAN}skills${NC} -> ~/.llms/skills     ${YELLOW}(SYMLINK - shared)${NC}"
echo -e "  ├── ${CYAN}workflows${NC} -> ~/.llms/workflows ${YELLOW}(SYMLINK - shared)${NC}"
echo -e "  ├── history/                 ${YELLOW}(local - project-specific)${NC}"
echo -e "  ├── techdocs/                ${YELLOW}(local - project-specific)${NC}"
echo -e "  ├── rules/                   ${YELLOW}(local - project-specific)${NC}"
echo -e "  └── future_features/         ${YELLOW}(local - project-specific)${NC}"
echo ""
echo -e "  ${BLUE}.claude/${NC}                        ${YELLOW}(Claude Code specific)${NC}"
echo -e "  └── commands/                ${YELLOW}(copies of workflows)${NC}"
echo ""
echo -e "  ${BLUE}GEMINI.md${NC}                       ${YELLOW}(local - customize this!)${NC}"
echo -e "  ${CYAN}CLAUDE.md${NC} -> GEMINI.md          ${YELLOW}(symlink)${NC}"
echo -e "  ${CYAN}.cursorrules${NC} -> GEMINI.md       ${YELLOW}(symlink for Cursor)${NC}"
echo ""
echo -e "${YELLOW}Tool support:${NC}"
echo -e "  ✓ Gemini/Antigravity (reads GEMINI.md + .agent/)"
echo -e "  ✓ Claude Code (reads CLAUDE.md + .claude/)"
echo -e "  ✓ Cursor (reads .cursorrules)"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "  1. Customize ${CYAN}GEMINI.md${NC} with project-specific rules"
echo -e "  2. Add your first techdoc in ${CYAN}.agent/techdocs/${NC}"
echo -e "  3. Start your first session:"
echo -e "     ${CYAN}mkdir -p .agent/history/\$(date +%Y%m%d-%H%M%S)_initial${NC}"
echo ""
