# Skills Audit — Revision 190426

**Date:** 2026-04-19  
**Scope:** All skills under `.github/skills/` + root `README.md`  
**Auditor:** GitHub Copilot

---

## Summary

12 skills exist across 8 directories. The repo is well-structured overall, with several high-quality skills (`day-schedule-planner`, `nextjs-app-builder`, `server-checkup`). However, a cluster of thinner skills require attention, and the root `README.md` is out of date — it lists only 6 of 12 skills.

---

## Skills Inventory

| Command | File | README | Quality |
|---|---|---|---|
| `day-schedule-planner` | `day-schedule/skill.md` | ✅ | ✅ High |
| `get-weather` | `forecast/skill.md` | ⚠️ Issues | ✅ Functional |
| `nextjs-app-builder` | `nextjs-app-builder/skill.md` | ✅ | ✅ High |
| `server-checkup` | `server-checkup/skill.md` | ✅ | ⚠️ Minor |
| `srs-generator` | `srs-generator/skill.md` | ⚠️ Minimal | ✅ Functional |
| `yt-summarise` | `ytd-summarise/skill.md` | ❌ Missing | ✅ Functional |
| `ytd-list` | `ytd-list/skill.md` | ⚠️ Issues | 🔴 Thin |
| `obsidian-append-note` | `obsidian-notes-skills/append-note/skill.md` | ⚠️ Plain text | 🔴 Thin |
| `obsidian-create-note` | `obsidian-notes-skills/create-note/skill.md` | ⚠️ Plain text | 🔴 Thin |
| `obsidian-list-active` | `obsidian-notes-skills/list-active/skill.md` | ⚠️ Plain text | ⚠️ Minimal |
| `obsidian-open-note` | `obsidian-notes-skills/open-note/skill.md` | ⚠️ Plain text | 🔴 Thin |
| `obsidian-search-notes` | `obsidian-notes-skills/search-notes/skill.md` | ⚠️ Plain text | ⚠️ Minimal |

---

## Recommendations

### R1 — Root README does not reflect all skills  
**Severity:** High  
**File:** `README.md`

The skills table lists only 6 skills. Missing from the table and repository layout section:
- `ytd-list`
- `obsidian-append-note`
- `obsidian-create-note`
- `obsidian-list-active`
- `obsidian-open-note`
- `obsidian-search-notes`

The repository layout diagram also shows only `day-schedule/` and `forecast/` as examples — it should reflect the full current structure including the `obsidian-notes-skills/` group and its sub-skill layout.

**Action:** Update the skills table and layout diagram in `README.md` to include all 12 skills. Add an `obsidian-notes-skills/` group entry with a description of the sub-skill pattern.

---

### R2 — All Obsidian skill.md files are missing the `description` frontmatter field  
**Severity:** High  
**Files:** All 5 `obsidian-notes-skills/*/skill.md`

The `description` field in the YAML frontmatter is how Copilot surfaces the skill in autocomplete and documentation. All five obsidian skills only have `name:` and lack `description:`.

**Before:**
```yaml
---
name: obsidian-append-note
---
```

**After:**
```yaml
---
name: obsidian-append-note
description: Append text to an existing note in your Obsidian vault via the local REST API.
---
```

**Action:** Add a concise `description:` to each of the five obsidian skill frontmatter blocks.

---

### R3 — Obsidian skill.md files contain no Copilot instruction flow  
**Severity:** High  
**Files:** All 5 `obsidian-notes-skills/*/skill.md`

Best practice for Copilot skills is to include a clear step-by-step instruction flow:
1. What inputs to collect (and prompt for if missing)
2. What command/script to run
3. What to display to the user on success and failure

Currently the obsidian skills contain only shell examples with no user-interaction guidance. Copilot has no instruction on what to say if the API token is missing, if the note path is not provided, or how to confirm success.

**Action:** Rewrite each obsidian skill to follow the standard pattern:
- Collect required arguments (e.g., note path, content)
- Check for `OBSIDIAN_API_TOKEN` and prompt the user if not set
- Run the API call via `obsidian_api.sh`
- Summarise the result to the user

---

### R4 — `ytd-list` skill.md uses non-standard frontmatter fields  
**Severity:** Medium  
**File:** `ytd-list/skill.md`

The file uses `title:` and `summary:` fields instead of the standard `description:` field used by all other skills and required by the Copilot skill spec.

**Before:**
```yaml
---
name: ytd-list
title: YouTube channel lister
summary: Fetch all videos from a YouTube channel and save to CSV using the YouTube Data API.
---
```

**After:**
```yaml
---
name: ytd-list
description: Fetch all uploads from a YouTube channel and save to CSV. Accepts a channel ID or username. Requires a YouTube Data API v3 key.
---
```

**Action:** Replace `title:` and `summary:` with a single `description:` field.

---

### R5 — `ytd-list` skill.md has no input gathering or output specification  
**Severity:** Medium  
**File:** `ytd-list/skill.md`

The skill body is a single sentence directing Copilot to "run the included Python script". There is no:
- Input collection step (channel ID, API key, output path)
- Prompt flow for missing inputs
- Output path or filename specification
- User-facing result summary

**Action:** Expand `ytd-list/skill.md` to include an input gathering phase (channel ID or username, API key check via `YT_API_KEY` env var, output filename), then run the script and confirm the saved CSV path.

---

### R6 — `ytd-summarise` skill directory is missing a README  
**Severity:** Medium  
**File:** `.github/skills/ytd-summarise/` (no `README.md`)

Every other skill directory includes a `README.md` documenting prerequisites, invocation examples, and output contracts. `ytd-summarise` has none. Users need to know:
- Dependencies (`yt-dlp`, `whisper` or subtitle fallback)
- Virtualenv setup (`.venv/`)
- Output path (`transcripts/`)
- Transcript file format

**Action:** Create `.github/skills/ytd-summarise/README.md` documenting prerequisites, setup steps, example invocations, and expected output format.

---

### R7 — `forecast` README references the wrong command name  
**Severity:** Medium  
**File:** `forecast/README.md`

The README refers to invoking the skill with `/forecast`, but the registered command name (from `skill.md` frontmatter) is `/get-weather`.

> "Invoke the skill from Copilot Chat: `/forecast` or any command set by `skill.md` name."

**Action:** Replace all references to `/forecast` in `forecast/README.md` with `/get-weather`.

---

### R8 — `day-schedule` README contains incorrect file path and bad YAML delimiters  
**Severity:** Medium  
**File:** `day-schedule/README.md`

The Setup section (line ~20) instructs users to place the skill at:
```
.github/skills/day-schedule-planner.md
```
The correct path is `.github/skills/day-schedule/skill.md`.

Additionally, the YAML frontmatter example in the README uses `***` as delimiters instead of the correct `---`.

**Action:**
1. Update the file path reference to `.github/skills/day-schedule/skill.md`.
2. Replace `***` delimiters with `---` in the frontmatter code block.

---

### R9 — `server-checkup` skill.md hardcodes an IP address  
**Severity:** Low  
**File:** `server-checkup/skill.md`

The report format examples hardcode `192.168.4.90` as the host value in the markdown template. This is a local IP that won't apply to other users and could be confusing.

**Before:**
```markdown
**Host:** 192.168.4.90
```

**After:**
```markdown
**Host:** <SERVER_HOST>
```

**Action:** Replace the hardcoded IP with a placeholder that reflects the `SERVER_HOST` environment variable actually used by `checkup.sh`.

---

### R10 — Obsidian sub-skill READMEs are unformatted plain text  
**Severity:** Low  
**Files:** `obsidian-notes-skills/append-note/README.md`, `create-note/README.md`, `open-note/README.md`, `search-notes/README.md`

These files contain no markdown formatting — no headings, no code fences, no bold labels. While functional as plain text, they are inconsistent with the rest of the repo and harder to read.

**Action:** Apply standard markdown formatting (headings with `##`, code blocks with triple backticks) to each sub-skill README. A minimal template:
```markdown
# obsidian-<skill>

## What it does
One sentence.

## Usage
```bash
./obsidian_api.sh <VERB> <endpoint>
```

## Notes
Any plugin-specific caveats.
```

---

### R11 — `srs-generator` README lacks prerequisites section  
**Severity:** Low  
**File:** `srs-generator/README.md`

The README describes usage and output but does not mention that there are no external dependencies (pure prompt-driven, no scripts). A brief prerequisites note ("No external dependencies — pure Copilot prompt") avoids user confusion.

**Action:** Add a short prerequisites section noting there are no scripts or API keys required.

---

## Checklist

| # | Recommendation | Priority | Status |
|---|---|---|---|
| R1 | Update root README skills table + layout | High | ✅ |
| R2 | Add `description` to obsidian skill.md frontmatter | High | ✅ |
| R3 | Add instruction flow to obsidian skill.md files | High | ✅ |
| R4 | Fix `ytd-list` frontmatter field names | Medium | ✅ |
| R5 | Expand `ytd-list` skill.md with input/output flow | Medium | ✅ |
| R6 | Create `ytd-summarise/README.md` | Medium | ✅ |
| R7 | Fix `/forecast` → `/get-weather` in forecast README | Medium | ✅ |
| R8 | Fix path + YAML delimiters in day-schedule README | Medium | ✅ |
| R9 | Replace hardcoded IP in server-checkup skill.md | Low | ✅ |
| R10 | Format obsidian sub-skill READMEs as markdown | Low | ✅ |
| R11 | Add prerequisites note to srs-generator README | Low | ✅ |
