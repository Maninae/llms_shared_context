#!/bin/bash

# ============================================================================
# LLM UPDATE - Convert Existing Repos to Use Symlinks
# ============================================================================
#
# This script updates an existing repo to use symlinks from ~/.llms/
# instead of local copies of skills and workflows.
#
# What it does:
#   - Backs up existing .agent/skills and .agent/workflows
#   - Replaces them with symlinks to ~/.llms/
#   - Updates .claude/commands/ with latest workflows
#   - Creates missing symlinks (CLAUDE.md, .cursorrules)
#
# Usage:
#   ~/.llms/scripts/update.sh              # Update current directory
#   ~/.llms/scripts/update.sh /path/to/repo  # Update specific directory
#
# ============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Source of truth - dynamically determined from script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLMS_DIR="$(dirname "$SCRIPT_DIR")"  # Go up one level from scripts/
TARGET_DIR="${1:-.}"
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo -e "${BLUE}🔄 LLM UPDATE - Symlink Conversion${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""
echo -e "Updating: ${GREEN}$TARGET_DIR${NC}"
echo ""

# Verify prerequisites
if [ ! -d "$LLMS_DIR" ]; then
    echo -e "${RED}❌ Error: $LLMS_DIR does not exist!${NC}"
    exit 1
fi

if [ ! -d "$TARGET_DIR/.agent" ]; then
    echo -e "${RED}❌ Error: No .agent directory found. Run init.sh first.${NC}"
    exit 1
fi

# ============================================================================
# Backup and replace skills
# ============================================================================
if [ -d "$TARGET_DIR/.agent/skills" ] && [ ! -L "$TARGET_DIR/.agent/skills" ]; then
    echo -e "${YELLOW}📦 Backing up .agent/skills to .agent/skills.backup${NC}"
    mv "$TARGET_DIR/.agent/skills" "$TARGET_DIR/.agent/skills.backup"
fi

if [ -d "$LLMS_DIR/skills" ]; then
    ln -sfn "$LLMS_DIR/skills" "$TARGET_DIR/.agent/skills"
    echo -e "${GREEN}✓ .agent/skills -> ~/.llms/skills${NC}"
fi

# ============================================================================
# Backup and replace workflows
# ============================================================================
if [ -d "$TARGET_DIR/.agent/workflows" ] && [ ! -L "$TARGET_DIR/.agent/workflows" ]; then
    echo -e "${YELLOW}📦 Backing up .agent/workflows to .agent/workflows.backup${NC}"
    mv "$TARGET_DIR/.agent/workflows" "$TARGET_DIR/.agent/workflows.backup"
fi

if [ -d "$LLMS_DIR/workflows" ]; then
    ln -sfn "$LLMS_DIR/workflows" "$TARGET_DIR/.agent/workflows"
    echo -e "${GREEN}✓ .agent/workflows -> ~/.llms/workflows${NC}"
fi

# ============================================================================
# Backup and replace rules - HYBRID Structure (shared/ + local)
# ============================================================================
echo -e "${GREEN}🔗 Updating rules structure...${NC}"

# 1. If .agent/rules is a symlink (legacy), we MUST remove it to create a directory
if [ -L "$TARGET_DIR/.agent/rules" ]; then
    echo -e "${YELLOW}📦 Converting .agent/rules symlink to directory...${NC}"
    rm "$TARGET_DIR/.agent/rules"
fi

# 2. Ensure directory exists
mkdir -p "$TARGET_DIR/.agent/rules"

# 3. Create shared symlink inside
if [ -d "$LLMS_DIR/rules" ]; then
    ln -sfn "$LLMS_DIR/rules" "$TARGET_DIR/.agent/rules/shared"
    echo -e "${GREEN}✓ .agent/rules/shared -> ~/.llms/rules${NC}"
fi

# 4. Ensure local README exists
if [ ! -f "$TARGET_DIR/.agent/rules/README.md" ]; then
     echo "# Project Rules" > "$TARGET_DIR/.agent/rules/README.md"
     echo "" >> "$TARGET_DIR/.agent/rules/README.md"
     echo "This directory contains project-specific rules." >> "$TARGET_DIR/.agent/rules/README.md"
     echo "Global rules are available in the \`shared/\` subdirectory." >> "$TARGET_DIR/.agent/rules/README.md"
fi

# ============================================================================
# Update .claude/commands/ (Sync: delete stale, copies new)
# ============================================================================
if [ -d "$TARGET_DIR/.claude/commands" ]; then
    echo -e "${GREEN}📝 Syncing .claude/commands/ with workflows...${NC}"

    # 1. Remove stale commands (file exists in target, but NOT in source)
    # Note: We iterate over target files
    for cmd in "$TARGET_DIR/.claude/commands"/*.md; do
        if [ -f "$cmd" ]; then
            name=$(basename "$cmd")
            if [ ! -f "$LLMS_DIR/workflows/$name" ]; then
                echo -e "${YELLOW}   🗑️  Removing stale command: $name${NC}"
                rm "$cmd"
            fi
        fi
    done

    # 2. Add/Update commands from source
    for workflow in "$LLMS_DIR/workflows"/*.md; do
        if [ -f "$workflow" ]; then
            name=$(basename "$workflow")
            cp "$workflow" "$TARGET_DIR/.claude/commands/$name"
        fi
    done
    echo -e "${GREEN}✓ Synced Claude commands${NC}"
fi

# ============================================================================
# Ensure symlinks exist
# ============================================================================
echo -e "${GREEN}🔗 Ensuring tool symlinks...${NC}"

# CLAUDE.md -> GEMINI.md
if [ -f "$TARGET_DIR/GEMINI.md" ] && [ ! -L "$TARGET_DIR/CLAUDE.md" ]; then
    rm -f "$TARGET_DIR/CLAUDE.md"
    ln -sf GEMINI.md "$TARGET_DIR/CLAUDE.md"
    echo -e "   ✓ CLAUDE.md -> GEMINI.md"
fi

# .cursorrules -> GEMINI.md
if [ -f "$TARGET_DIR/GEMINI.md" ] && [ ! -L "$TARGET_DIR/.cursorrules" ]; then
    rm -f "$TARGET_DIR/.cursorrules"
    ln -sf GEMINI.md "$TARGET_DIR/.cursorrules"
    echo -e "   ✓ .cursorrules -> GEMINI.md"
fi

# ============================================================================
# Done
# ============================================================================
echo ""
echo -e "${GREEN}✅ Update complete!${NC}"
echo ""
echo -e "Skills and workflows now symlinked from ${CYAN}~/.llms/${NC}"
echo -e "Updates to ~/.llms/ will automatically propagate to this repo."
echo ""

# Show any backups
if [ -d "$TARGET_DIR/.agent/skills.backup" ] || [ -d "$TARGET_DIR/.agent/workflows.backup" ]; then
    echo -e "${YELLOW}Backups created:${NC}"
    [ -d "$TARGET_DIR/.agent/skills.backup" ] && echo -e "  - .agent/skills.backup"
    [ -d "$TARGET_DIR/.agent/workflows.backup" ] && echo -e "  - .agent/workflows.backup"
    echo -e "${YELLOW}Delete these after verifying everything works.${NC}"
fi
