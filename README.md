
# GitHub Copilot Skills

A library of GitHub Copilot skill definitions — composable, prompt-driven agents that run inside VS Code to automate repeatable workflows. Skills cover day planning, weather, server health, SRS generation, Next.js scaffolding, YouTube transcription, and Obsidian vault management.



---

## What Are Copilot Skills?

A Copilot skill is a Markdown file stored in `.github/skills/` that instructs GitHub Copilot how to handle a specific type of request. Each skill:

- Defines a clear intent (e.g., build a daily schedule, draft a release note, generate tests)
- Accepts natural language and structured inputs
- Produces concrete output (Markdown files, code, artifacts)
- Is invoked via the `/skill-name` command in Copilot Chat or the GitHub Copilot CLI

Skills are a way to encode repeatable expert workflows as plain text, then execute them through Copilot without writing custom tooling.

---

## How Skills Work

```
User types /skill-name in Copilot Chat
          │
          ▼
Skill file read from .github/skills/<skill-dir>/skill.md
          │
          ▼
Copilot follows the instructions:
  - prompts for any missing inputs
  - builds the output (schedule, plan, file, etc.)
  - runs terminal commands if in Agent Mode
          │
          ▼
Output written to disk and displayed in chat
```

1. The skill file (`.github/skills/<skill-dir>/skill.md`) describes the behavior and step-by-step instructions.
2. Copilot reads the skill at invocation time and uses it as a system-level prompt to guide its responses.
3. In **Agent Mode**, Copilot can also run scripts and terminal commands defined in the skill instructions.
4. Output is saved to the repo, shown in the editor, or both.

---

## Repository Layout

```
.github/
└── skills/
    ├── day-schedule/
    │   ├── skill.md
    │   └── README.md
    ├── forecast/
    │   ├── skill.md
    │   ├── README.md
    │   └── weather.sh
    ├── nextjs-app-builder/
    │   ├── skill.md
    │   └── README.md
    ├── obsidian-notes-skills/          ← group of 5 Obsidian API skills
    │   ├── README.md
    │   ├── obsidian_api.sh             ← shared curl/python helper
    │   ├── append-note/
    │   │   ├── skill.md
    │   │   └── README.md
    │   ├── create-note/
    │   │   ├── skill.md
    │   │   └── README.md
    │   ├── list-active/
    │   │   ├── skill.md
    │   │   └── README.md
    │   ├── open-note/
    │   │   ├── skill.md
    │   │   └── README.md
    │   └── search-notes/
    │       ├── skill.md
    │       └── README.md
    ├── server-checkup/
    │   ├── skill.md
    │   ├── README.md
    │   └── checkup.sh
    ├── srs-generator/
    │   ├── skill.md
    │   └── README.md
    ├── ytd-list/
    │   ├── skill.md
    │   └── README.md
    └── ytd-summarise/
        ├── skill.md
        └── transcribe.sh

outputs/
└── ...                             ← skill-specific generated artifacts

schedules/
└── YYYY-MM-DD/
    ├── schedule_HHMM-SS.md         ← generated daily plan
    ├── meal-plan_HHMM-SS.md        ← generated nutrition plan
    └── schedule_HHMM-SS-revised.md ← mid-day reschedule (if triggered)

transcripts/
└── <video-id>_<title>.md           ← ytd-summarise transcripts + TL;DR

spec/
└── revision-YYMMDD.md              ← audit and revision notes
```

---

## Available Skills

### Core Skills

| Command | File | Description |
|---------|------|-------------|
| `day-schedule-planner` | `.github/skills/day-schedule/skill.md` | Plan a full day with hourly blocks, priorities, nutrition, and mid-day check-ins |
| `get-weather` | `.github/skills/forecast/skill.md` | Get the current weather for a given location (defaults to Melbourne), via `weather.sh` |
| `nextjs-app-builder` | `.github/skills/nextjs-app-builder/skill.md` | Scaffold a full-stack Next.js 14 App Router app with pages, API routes, and an in-memory data layer |
| `server-checkup` | `.github/skills/server-checkup/skill.md` | SSH into a configured server, collect health metrics, and write a structured health report |
| `srs-generator` | `.github/skills/srs-generator/skill.md` | Collect project requirements interactively and write a Software Requirements Specification in Markdown |
| `yt-summarise` | `.github/skills/ytd-summarise/skill.md` | Download YouTube audio with yt-dlp, transcribe with Whisper, save transcript under `transcripts/`, and append a TL;DR summary |
| `ytd-list` | `.github/skills/ytd-list/skill.md` | Fetch all uploads from a YouTube channel and save to CSV using the YouTube Data API v3 |

### Obsidian Notes Skills

A group of five skills for interacting with a local [Obsidian](https://obsidian.md/) vault via the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin. They share a common helper script (`obsidian_api.sh`) and require `OBSIDIAN_API_TOKEN` to be set. See `.github/skills/obsidian-notes-skills/README.md` for setup.

| Command | File | Description |
|---------|------|-------------|
| `obsidian-list-active` | `obsidian-notes-skills/list-active/skill.md` | List the currently active Obsidian vault and confirm the API is reachable |
| `obsidian-search-notes` | `obsidian-notes-skills/search-notes/skill.md` | Search notes in the vault by keyword using the local REST API |
| `obsidian-open-note` | `obsidian-notes-skills/open-note/skill.md` | Fetch and display a note by file path |
| `obsidian-create-note` | `obsidian-notes-skills/create-note/skill.md` | Create a new note in the vault with a given path and content |
| `obsidian-append-note` | `obsidian-notes-skills/append-note/skill.md` | Append text to an existing note in the vault |

---

## Setup

### Prerequisites

- [VS Code](https://code.visualstudio.com/)
- [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot)
- [GitHub Copilot Chat extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot-chat)
- A GitHub account with an active Copilot subscription

### 1. Clone the Repository

```bash
git clone https://github.com/<your-user>/github-copilot-skills.git
cd github-copilot-skills
```

### 2. Open in VS Code

```bash
code .
```

### 3. Confirm Skills Are Detected

Open Copilot Chat (`Ctrl+Alt+I` / `Cmd+Alt+I`) and type `/` — you should see the available skills in the autocomplete list.

If a skill doesn't appear:
- Confirm the file is inside `.github/skills/` (not `.github/` directly)
- Confirm the file starts with valid YAML frontmatter (see below)
- Reload VS Code: `Cmd+Shift+P` → `Developer: Reload Window`

### 4. Skill File Frontmatter

Every skill file must begin with this YAML block — the `name` field is what Copilot registers as the `/` command:

```yaml
---
name: day-schedule-planner
description: Plan a daily schedule and output tasks and hourly assignments in markdown.
---
```

---

## Creating a New Skill

```bash
mkdir -p .github/skills/my-new-skill
touch .github/skills/my-new-skill/skill.md .github/skills/my-new-skill/README.md
```

Paste this starter template:

```markdown
---
name: my-new-skill
description: One sentence describing what this skill does.
---

When a user invokes this skill, follow this flow:

1. Collect required inputs:
   - [input 1]
   - [input 2]

2. If any inputs are missing, ask concise follow-up questions.

3. Perform the task:
   - [step-by-step instructions for Copilot]

4. Output the result in Markdown.
```

---

## Invoking Skills

### VS Code Copilot Chat (`/` command)

Open the Copilot Chat panel and type `/` followed by the skill name:

```
/day-schedule-planner
```

Copilot will ask follow-up questions for any missing details. To skip prompts, pass context inline:

```
/day-schedule-planner Plan today. Start 07:00, end 22:00, style: block scheduling.
Tasks: LangGraph refactor 3h high, code review 1h medium, gym [fixed] 12:00–13:30, emails 30min low.
Include meal plan.
```

### GitHub Copilot CLI

```bash
gh copilot suggest "Plan my day using day-schedule-planner. Start: 07:30. End: 22:00. \
Style: time-buffered. Tasks: deep work 3h high, gym [fixed] 12:00-13:30, emails 30min low."
```

Add a shell alias for daily use in your `.zshrc`:

```bash
planday() {
  gh copilot suggest "Plan my day using day-schedule-planner. ${*}"
}

# Usage:
planday "Start 07:00, end 21:00. Tasks: LangGraph PR 3h high, gym [fixed] 12:00, emails 30min low."
```

### Agent Mode (Autonomous Execution)

Enable Agent Mode in VS Code for Copilot to automatically save files and run terminal commands defined in the skill:

1. Open Copilot Chat
2. Switch to **Agent** mode in the chat panel dropdown
3. Invoke the skill as normal — Copilot will execute file writes and scripts without manual confirmation (subject to your auto-approve settings)

---

## Adding Skills Globally (Any Repo)

To use a skill outside this repository, copy the skill directory into the target repo's `.github/skills/` folder, or add this repo as a Git submodule:

```bash
cd your-other-project
git submodule add https://github.com/<your-user>/github-copilot-skills.git .github/skills
```

Alternatively, symlink the skills folder:

```bash
ln -s ~/projects/github-copilot-skills/.github/skills /path/to/other-repo/.github/skills
```

---

## Skill Output

Generated files are written to skill-specific locations. Common examples in this repo:

```text
schedules/YYYY-MM-DD/                  # day-schedule planner
outputs/srs/YYYY-MM-DD/                # srs-generator
outputs/server-checkup/                # server-checkup
transcripts/                           # ytd-summarise
outputs/nextjs-apps/<app-slug>/        # nextjs-app-builder
```

Review the README inside each skill directory for its exact output contract and any helper-script details.
