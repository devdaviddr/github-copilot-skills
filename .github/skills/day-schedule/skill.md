---
name: day-schedule-planner
description: Plan a daily schedule and output tasks and hourly assignments in markdown. Prompt for missing details as needed.
---

When a user asks to plan their day, follow this flow:

1. Confirm user intent and collect the minimum required information:
   - date (or "today" / "tomorrow")
   - start time (wake-up time or first available hour)
   - end time (bedtime or last working hour)
   - list of tasks with rough duration estimates (minutes/hours), priorities, and deadlines
   - task categories (work, personal, exercise, breaks, etc.) if the user provides them
   - preferred scheduling style (back-to-back, time-buffered, block scheduling, Pomodoro, etc.)
2. If any required info is missing, ask concise follow-up questions until complete.

3. Build a structured schedule:
   - use hourly or half-hour slots depending on task lengths
   - include a brief summary for each slot (task name + estimated duration + priority)
   - allocate breaks and transitions automatically (typically 5~15 minutes per 2 hours of focused work)
   - keep high-priority tasks early if the user has a most important task (MIT)
   - include a daily theme or focus block if the user has one

4. Output the full schedule in Markdown only (no extra prose or non-markdown data structures):

   - heading: `# Daily Schedule for YYYY-MM-DD`
   - section: `## Overview` with time range and top 3 priorities
   - section: `## Task List` with a bullet list of tasks and details
   - section: `## Hourly Plan` with either a markdown table or list:

     | Time | Task | Duration | Notes |
     |------|------|----------|-------|
     | 08:00 - 09:00 | [Task name] | 1h | [priority/track] |

   - section: `## Notes` containing any adjustment suggestions (e.g., move low-priority to afternoon)

5. Save the schedule to disk automatically in `schedules/`:
   - filename format: `schedules/YYYY-MM-DD_HHMM-SS.md` with current local date/time stamp
   - ensure the folder exists or create it
   - include all markdown content generated above

6. Include a mid-day reschedule workflow:
   - after creating the schedule, ask: "Would you like to check in mid-day for a reschedule or updates?"
   - create a check-in point at a time (default 12:00 or before any fixed afternoon commitment)
   - at check-in, ask user:
     * "How is your day going so far?"
     * "Do you want to keep this plan, shift tasks, or swap priorities for the afternoon/evening?"
   - if user requests changes, regenerate a revised hourly plan from current time onward, keeping completed items locked and adjusting remaining slots.
   - save revisions as `schedules/YYYY-MM-DD_HHMM-SS-revised.md`.

7. After output and save, ask the user:
   - "Would you like me to adjust this schedule for focus mode, bigger breaks, or to include a weekly context?"
   - "Do you want a plain text copy, a GitHub markdown file template, or a calendar import format?"

8. If the user asks for a follow-up after planning, make the requested revision.

7. Always keep responses short, readable, and actionable.

Example task solicitation prompt:

- "Please list your tasks in priority order with estimated durations. Include any fixed appointments or deadlines."
- "What time do you want to start and finish the day?"

