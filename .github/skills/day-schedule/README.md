Here is the improved README:

# Day Schedule Planner — GitHub Copilot Skill

## Overview

The Day Schedule skill provides a structured, daily itinerary generator focused on productivity, energy management, and wellbeing. It creates a detailed schedule and optional meal plan for a given date, saving output under `schedules/<YYYY-MM-DD>/`.

---

## Setup

### 1. Create the Skill File

Place the skill definition in your repository at the exact path below:

```
.github/
└── skills/
    └── day-schedule-planner.md
```

**Steps:**

```bash
mkdir -p .github/skills
touch .github/skills/day-schedule-planner.md
```

Then paste the full skill content (frontmatter + instructions) into `day-schedule-planner.md`. The file must begin with a YAML frontmatter block:

```yaml
***
name: day-schedule-planner
description: Plan a daily schedule and output tasks and hourly assignments in markdown. Prompt for missing details as needed.
***
```

> The `name` field is what Copilot uses to match the `/` command. Keep it lowercase and hyphenated.

### 2. Confirm VS Code Recognises the Skill

Open VS Code in the repo root. In the Copilot Chat panel, type `/` — you should see `day-schedule-planner` appear in the autocomplete list. If it doesn't appear:
- Confirm the file is inside `.github/skills/` (not `.github/` directly)
- Confirm the frontmatter is valid YAML with no trailing spaces
- Reload the VS Code window: `Cmd+Shift+P` → `Developer: Reload Window`

---

## Invoking the Skill

### From VS Code Copilot Chat (/ command)

Type `/` in the Copilot Chat input to trigger the skill picker, then select `day-schedule-planner`:

```
/day-schedule-planner
```

Copilot will prompt you for missing details interactively. You can also pass context inline to skip the prompts:

```
/day-schedule-planner Plan today. Start 07:00, end 22:00, style: block scheduling.
Tasks: LangGraph refactor 3h high, code review 1h medium, gym [fixed] 12:00–13:30, emails 30min low.
Include meal plan.
```

### Minimal Invocation (Let Copilot Prompt You)

```
/day-schedule-planner Plan my day
```

Copilot will ask follow-up questions for date, time window, tasks, and scheduling style.

### Full One-Shot Invocation

```
/day-schedule-planner Date: 2026-03-21. Start: 07:00. End: 22:00. Style: Pomodoro.
MIT: finish copilot skill PR.
Tasks: PR review and push 2h high, standup [fixed] 09:30 15min, write tests 1.5h medium,
documentation 1h low, walk 30min personal.
Nutrition tracking: yes.
```

### From the CLI

If you use the GitHub Copilot CLI (`gh copilot`):

```bash
gh copilot suggest "Plan my day using day-schedule-planner. Start: 07:30. End: 22:00.
Style: time-buffered. Tasks: deep work 3h high, gym [fixed] 12:00-13:30, emails 30min low."
```

For daily convenience, add a shell function to your `.zshrc`:

```bash
planday() {
  gh copilot suggest "Plan my day using day-schedule-planner. ${*}"
}

# Usage:
planday "Start 07:00, end 21:00, tasks: LangGraph PR 3h high, gym [fixed] 12:00, emails 30min low"
```

---

## What It Does

- Reads user context and constraints (energy level, key appointment times, focus areas)
- Builds a time-blocked plan with:
  - Morning ritual and wind-down
  - Deep work and focus sessions
  - Breaks, movement, and transitions
  - Fixed appointments that cannot be moved
- Creates a co-located nutrition plan matched to energy needs:
  - Meals, snacks, macronutrients, and timing
  - Recovery and focus support aligned with workout blocks
- Provides mid-day check-in prompts and reschedule workflows

---

## Output Files

All output is saved under `schedules/<YYYY-MM-DD>/`:

| File | Contents |
|------|----------|
| `schedule_<HHMM-SS>.md` | Full daily plan — overview, task list, hourly table, notes |
| `meal-plan_<HHMM-SS>.md` | Nutrition breakdown — meals, macros, hydration (when active) |
| `schedule_<HHMM-SS>-revised.md` | Mid-day reschedule revision (if requested) |

Example:
```
schedules/
└── 2026-03-21/
    ├── schedule_083000.md
    ├── meal-plan_083000.md
    └── schedule_150000-revised.md
```

---

## Key Sections in Schedule Output

1. **Overview** — date, time window, timezone, top 3 priorities
2. **Task List** — prioritised action steps with durations and deadlines
3. **Hourly Plan** — time-blocked table with task, duration, and notes
4. **Nutrition Plan** — meal table with macros and workout timing (when active)
5. **Notes** — conflicts, deferred tasks, energy warnings
6. **Mid-day Reschedule Check-in** — built-in decision prompt at day midpoint

---

## Task Input Format

When listing tasks, use this format for best results:

```
[task name] [duration] [priority] [fixed?]

Examples:
- LangGraph refactor 3h high
- Team standup [fixed] 09:30 15min
- Gym [fixed] 12:00–13:30
- Email catchup 30min low
```

> Mark immovable events with `[fixed]` — the skill will never reschedule these.

---

## Scheduling Styles

| Style | Description |
|-------|-------------|
| `back-to-back` | Tasks stacked with minimal gaps |
| `time-buffered` | 10–15 min buffers between tasks |
| `block scheduling` | Large themed blocks (e.g., morning = deep work) |
| `Pomodoro` | 25 min work / 5 min break cycles |

---

## Maintenance Notes

- Keep the skill file updated with best practices for work/rest cycles (e.g., 90-minute focus blocks, 15-minute walking breaks)
- Ensure the meal plan has safe dietary defaults and substitution options for allergies
- If appointments change mid-day, use the reschedule check-in to regenerate from current time while preserving completed tasks

