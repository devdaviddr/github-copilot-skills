
# GitHub Copilot Skills

A learning repository of GitHub Copilot skill definitions — composable, prompt-driven agents that run inside VS Code to automate repeatable workflows like day planning, scheduling, and productivity tracking.

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
Skill file read from .github/skills/<skill-name>.md
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

1. The skill file (`.github/skills/<skill-name>.md`) describes the behavior and step-by-step instructions.
2. Copilot reads the skill at invocation time and uses it as a system-level prompt to guide its responses.
3. In **Agent Mode**, Copilot can also run scripts and terminal commands defined in the skill instructions.
4. Output is saved to the repo, shown in the editor, or both.

---

## Repository Layout

```
.github/
└── skills/
    ├── day-schedule-planner.md     ← skill definitions live here
    └── <your-next-skill>.md

schedules/
└── YYYY-MM-DD/
    ├── schedule_HHMM-SS.md         ← generated daily plan
    ├── meal-plan_HHMM-SS.md        ← generated nutrition plan
    └── schedule_HHMM-SS-revised.md ← mid-day reschedule (if triggered)
```

---

## Available Skills

| Skill | File | Description |
|-------|------|-------------|
| `day-schedule-planner` | `.github/skills/day-schedule-planner.md` | Plan a full day with hourly blocks, priorities, nutrition, and mid-day check-ins |
| `get-weather` | `.github/skills/forecast/skill.md` | Get the current weather for a given location (defaults to Melbourne), via `weather.sh` |
| `ytd-summarise` | `.github/skills/ytd-summarise/skill.md` | Download YouTube audio with yt-dlp, transcribe with Whisper, save transcript under `transcripts/`, and append summary |

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
***
name: day-schedule-planner
description: Plan a daily schedule and output tasks and hourly assignments in markdown.
***
```

---

## Creating a New Skill

```bash
touch .github/skills/my-new-skill.md
```

Paste this starter template:

```markdown
***
name: my-new-skill
description: One sentence describing what this skill does.
***

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

To use a skill outside this repository, copy the skill file into the target repo's `.github/skills/` folder, or add this repo as a Git submodule:

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

All generated files are saved under `schedules/` organised by date:

```
schedules/
└── 2026-03-21/
    ├── schedule_083000.md
    ├── meal-plan_083000.md
    └── schedule_150000-revised.md
```

Review your history by browsing date folders. Each file is timestamped to avoid overwrites across multiple runs on the same day.

