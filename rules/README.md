# Cross-Project Rules

This directory contains rules and learnings that apply across **all** projects.

## How It Works

Unlike project-specific rules in `.agent/rules/`, these rules are **shared** and should be read by the LLM at the start of any session.

## Contents

| Rule | Purpose |
|------|---------|
| `xcode.md` | iOS/macOS development with Xcode |
| [Add more as discovered] | |

## Adding Rules

When you discover something that applies across projects:
1. Create a new `.md` file here
2. Update this table
3. The LLM will read it via the symlinked `.agent/rules/`

**Note:** If you want project-specific rules, put them in the project's local `.agent/rules/` instead.
