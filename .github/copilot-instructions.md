# Copilot Instructions

## Commands

- There is no repo-wide build, lint, or automated test setup in this repository today. No `package.json`, `Makefile`, Python project manifest, CI workflow, or test suite is checked in.
- There is no single-test command because there are no automated tests.
- Manual smoke checks for the shipped helper scripts:

```bash
bash .github/skills/forecast/weather.sh "Melbourne"

. .github/skills/ytd-summarise/.venv/bin/activate && \
  .github/skills/ytd-summarise/transcribe.sh "https://www.youtube.com/watch?v=<id>"
```

- `yt-summarise` also depends on `yt-dlp`; `whisper` is used when available, otherwise `transcribe.sh` falls back to YouTube auto subtitles.

## High-level architecture

- This repository is a library of GitHub Copilot skills, not a conventional app or package. The authored source of truth lives under `.github/skills/`.
- Each skill is self-contained in its own directory and usually combines:
  - `skill.md` for the registered Copilot skill instructions
  - a local `README.md`/`Readme.md` with usage notes
  - optional helper scripts when the skill needs terminal execution
- Current authored skills:
  - `.github/skills/day-schedule/skill.md` is a prompt-only planner that writes markdown schedules under `schedules/YYYY-MM-DD/` with timestamped schedule, meal-plan, and revised schedule files.
  - `.github/skills/forecast/skill.md` delegates to `weather.sh`, which is a thin shell wrapper around `wttr.in`.
  - `.github/skills/ytd-summarise/skill.md` delegates to `transcribe.sh`, which downloads audio with `yt-dlp`, transcribes with Whisper or subtitle fallback, writes a markdown transcript, and expects Copilot to add a `## TL;DR` section before `## Transcript`.
- The root `README.md` is a catalog/onboarding document. Per-skill READMEs are where operational details for each skill live.

## Key conventions

- Follow the actual folder-based layout under `.github/skills/<skill-dir>/`. Put each new skill in its own directory named for the skill. A skill directory SHOULD include at minimum:
  - `skill.md` (required) — the skill definition; its YAML frontmatter `name:` registers the `/` command
  - `README.md` (required) — usage, prerequisites, example invocations, and expected outputs
  - any helper scripts, assets, or venvs (optional) — keep scripts executable and prefer relative paths; document runtime assumptions in the README

  Keep generated outputs under `outputs/` or a skill-specific output folder (document this in the skill README). The root `README.md` contains onboarding info but may show older examples; prefer the per-skill directory layout.
- The Copilot command name comes from the YAML frontmatter in `skill.md`, not from the folder name. For example, `day-schedule/skill.md` registers `day-schedule-planner`, and `forecast/skill.md` registers `get-weather`.
- Preserve output contracts when editing skills:
  - `day-schedule` expects exact markdown sections such as `## Overview`, `## Task List`, `## Hourly Plan`, optional `## Nutrition Plan`, and `## Notes`, plus timestamped files under `schedules/YYYY-MM-DD/`.
  - `yt-summarise` transcript files are named `${VIDEO_ID}_${SAFE_TITLE}.md`, include a metadata header (`# title`, `**Channel:**`, `**URL:**`, `---`), and then `## Transcript`. Existing repo-root files in `transcripts/` show the expected final shape after Copilot inserts `## TL;DR`.
- `transcribe.sh` writes transcripts to `$(pwd)/transcripts`, not relative to the script location. Be deliberate about the working directory when running or changing it.
- `.github/skills/ytd-summarise/.venv/` is a checked-in local virtualenv. Avoid reading or editing it unless the task is specifically about that environment; focus on the authored files instead.
