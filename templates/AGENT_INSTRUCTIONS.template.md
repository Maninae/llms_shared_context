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
| 2 | `.agent/rules/README.md` | **Cross-project rules** |
| 3 | `README.md` | Project overview and setup |

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
