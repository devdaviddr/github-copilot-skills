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
     * flag any task as **fixed** (cannot be moved) by marking it `[fixed]`
   - task categories (work, personal, exercise, breaks, etc.) — ask proactively if the user has more than 5 tasks and hasn't provided them
   - preferred scheduling style (back-to-back, time-buffered, block scheduling, Pomodoro, etc.)

2. If any required info is missing, ask concise follow-up questions until complete.

3. Before building the schedule, check for conflicts:
   - if the total estimated task duration exceeds the available time window, flag this to the user and ask which tasks to defer, shorten, or drop before proceeding.

4. Build a structured schedule:
   - use hourly or half-hour slots depending on task lengths
   - include a brief summary for each slot (task name + estimated duration + priority)
   - allocate breaks and transitions automatically (typically 5–15 minutes per 2 hours of focused work)
   - warn if any block of focused work exceeds 3 consecutive hours
   - keep high-priority tasks early if the user has a most important task (MIT)
   - never move `[fixed]` tasks — schedule all other tasks around them
   - include a daily theme or focus block if the user has one
   - include meal planning when user requests it (or for health/fitness-focused users):
     * breakfast, lunch, dinner, and two snack occasions
     * emphasize protein + complex carbs + vegetables for gym recovery and sustained energy
     * include portion guidance and timing aligned with workout blocks (e.g., "30 min pre-workout", "within 45 min post-lift")
     * allow substitutes for dietary restrictions or preferences

5. Output the full schedule in Markdown only (no extra prose or non-markdown data structures):

   - heading: `# Daily Schedule for YYYY-MM-DD`
   - section: `## Overview` with time range, timezone, and top 3 priorities
   - section: `## Task List` with a bullet list of tasks and details
   - section: `## Hourly Plan` with a markdown table.
     * include `Meal` and `Meal detail` columns only when nutrition tracking is active:

     | Time | Task | Duration | Notes |
     |------|------|----------|-------|
     | 08:00 - 09:00 | [Task name] | 1h | [priority / notes] |

     With nutrition tracking active:

     | Time | Task | Duration | Notes | Meal | Meal Detail |
     |------|------|----------|-------|------|-------------|
     | 08:00 - 09:00 | [Task name] | 1h | [priority] | Breakfast | [protein, carbs, notes] |

   - section: `## Nutrition Plan` (only when nutrition tracking is active):

     | Meal | Time | Menu | Protein | Carbs | Fiber | Notes |
     |------|------|------|---------|-------|-------|-------|
     | Breakfast | 08:15 | omelet + oats | 35g | 45g | 10g | 30 min pre-workout |

   - section: `## Notes` — use this section for:
     * scheduling conflicts or deferred tasks
     * energy-management warnings (e.g., back-to-back deep work exceeding 3 hours)
     * suggested adjustments (e.g., move low-priority tasks to afternoon)

6. Save the schedule and meal plan to disk automatically in a date folder:
   - folder path: `schedules/YYYY-MM-DD/`
   - target files:
     * `schedules/YYYY-MM-DD/schedule_HHMM-SS.md`
     * `schedules/YYYY-MM-DD/meal-plan_HHMM-SS.md` (only when nutrition tracking is active)
   - ensure the directory exists or create it
   - include all markdown content generated above in the schedule file and detailed meal plan in the meal-plan file

7. Include a mid-day reschedule workflow:
   - after creating the schedule, ask: "Would you like to check in mid-day for a reschedule or updates?"
   - set the default check-in time to the **midpoint between start time and end time** (e.g., start 07:00, end 23:00 → check-in at 15:00)
   - at check-in, ask the user:
     * "How is your day going so far?"
     * "Do you want to keep this plan, shift tasks, or swap priorities for the afternoon/evening?"
   - if the user requests changes, regenerate a revised hourly plan from current time onward, keeping completed items locked and adjusting remaining slots
   - save revisions into the same date folder: `schedules/YYYY-MM-DD/schedule_HHMM-SS-revised.md`

8. After output and save, ask the user a single combined prompt:
   - "Would you like to: **[A]** adjust for focus mode or bigger breaks, **[B]** add weekly context, or **[C]** export as plain text, GitHub markdown template, or calendar import format?"

9. If the user asks for a follow-up after planning, make the requested revision.

10. Always keep responses short, readable, and actionable.

---

Example task solicitation prompt:

- "Please list your tasks in priority order with estimated durations. Mark any fixed appointments with `[fixed]`."
- "What time do you want to start and finish the day?"
- "Are you tracking nutrition or planning meals today?"
