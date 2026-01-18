#!/bin/bash

# ============================================================================
# LLM INIT - Tool-Agnostic Agent Setup for Any Repository
# ============================================================================
#
# This script initializes a repository with agent workflow support that works
# with ANY LLM coding assistant (Gemini/Antigravity, Claude Code, Cursor, etc.)
#
# Skills and workflows are SYMLINKED from {ROOT}/llms_shared_context/ (your personal source of truth)
# so updates propagate automatically to all repos.
#
# Creates:
#   - .agent/           → Agent structure with symlinks to {ROOT}/llms_shared_context/
#   - .claude/          → Claude Code specific (commands mirror workflows)
#   - GEMINI.md         → Agent instructions (customizable per-project)
#   - CLAUDE.md         → Symlink to GEMINI.md
#   - .cursorrules      → Symlink to GEMINI.md (for Cursor)
#
# Usage:
#   {ROOT}/llms_shared_context/scripts/init.sh              # Initialize current directory
#   {ROOT}/llms_shared_context/scripts/init.sh /path/to/repo  # Initialize specific directory
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

# Verify repository directory exists
if [ ! -d "$LLMS_DIR" ]; then
    echo -e "${RED}❌ Error: $LLMS_DIR does not exist!${NC}"
    echo -e "${YELLOW}   Run the setup script first or create the directory manually.${NC}"
    exit 1
fi

# Check if .agent already exists
if [ -d "$TARGET_DIR/.agent" ]; then
    echo -e "${RED}❌ Error: .agent directory already exists at $TARGET_DIR/.agent${NC}"
    echo -e "${YELLOW}   This repo is already initialized. Use update.sh to refresh symlinks.${NC}"
    exit 1
fi

# ============================================================================
# Create directory structures
# ============================================================================
echo -e "${GREEN}📁 Creating .agent directory structure...${NC}"
mkdir -p "$TARGET_DIR/.agent"/{history,techdocs,future_features}

# ============================================================================
# Create symlinks to central {ROOT}/llms_shared_context/
# ============================================================================
echo -e "${GREEN}🔗 Symlinking skills and workflows from repository...${NC}"

# Symlink skills (shared across all repos)
if [ -d "$LLMS_DIR/skills" ]; then
    ln -sfn "$LLMS_DIR/skills" "$TARGET_DIR/.agent/skills"
    echo -e "   ✓ .agent/skills -> repository/skills"
fi

# Symlink workflows (shared across all repos)
if [ -d "$LLMS_DIR/workflows" ]; then
    ln -sfn "$LLMS_DIR/workflows" "$TARGET_DIR/.agent/workflows"
    echo -e "   ✓ .agent/workflows -> repository/workflows"
fi

# Set up rules (shared + local support)
# If .agent/rules is a symlink (legacy), remove it to make way for directory
if [ -L "$TARGET_DIR/.agent/rules" ]; then
    rm "$TARGET_DIR/.agent/rules"
fi

mkdir -p "$TARGET_DIR/.agent/rules"

# Symlink global rules to .agent/rules/shared
if [ -d "$LLMS_DIR/rules" ]; then
    ln -sfn "$LLMS_DIR/rules" "$TARGET_DIR/.agent/rules/shared"
    echo -e "   ✓ .agent/rules/shared -> repository/rules"
fi

# Create local README if missing
if [ ! -f "$TARGET_DIR/.agent/rules/README.md" ]; then
    echo "# Project Rules" > "$TARGET_DIR/.agent/rules/README.md"
    echo "" >> "$TARGET_DIR/.agent/rules/README.md"
    echo "This directory contains project-specific rules." >> "$TARGET_DIR/.agent/rules/README.md"
    echo "Global rules are available in the \`shared/\` subdirectory." >> "$TARGET_DIR/.agent/rules/README.md"
fi

# ============================================================================
# Create GEMINI.md (local, customizable per-project)
# ============================================================================
echo -e "${GREEN}📝 Creating GEMINI.md...${NC}"

if [ -f "$TARGET_DIR/GEMINI.md" ]; then
    echo -e "${YELLOW}⚠️  GEMINI.md already exists. Skipping overwrite.${NC}"
else
    # Check for template, otherwise use inline default
    TEMPLATE_FILE="$LLMS_DIR/templates/GEMINI.template.md"
    if [ -f "$TEMPLATE_FILE" ]; then
        cp "$TEMPLATE_FILE" "$TARGET_DIR/GEMINI.md"
        echo -e "${GREEN}✓ Created GEMINI.md from template${NC}"
    else
        echo -e "${RED}❌ Error: Template not found at $TEMPLATE_FILE${NC}"
        # Fallback to simple stub if template missing
        echo "# Project Rules" > "$TARGET_DIR/GEMINI.md"
    fi
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
echo -e "  ├── ${CYAN}skills${NC} -> {ROOT}/llms_shared_context/skills     ${YELLOW}(SYMLINK - shared)${NC}"
echo -e "  ├── ${CYAN}workflows${NC} -> {ROOT}/llms_shared_context/workflows ${YELLOW}(SYMLINK - shared)${NC}"
echo -e "  ├── history/                 ${YELLOW}(local - project-specific)${NC}"
echo -e "  ├── techdocs/                ${YELLOW}(local - project-specific)${NC}"
echo -e "  ├── rules/                   ${YELLOW}(SYMLINK - shared)${NC}"
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
