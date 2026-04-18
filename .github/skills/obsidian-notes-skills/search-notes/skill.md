---
name: obsidian-search-notes
description: Search notes in your Obsidian vault by keyword using the local REST API.
---

When the user invokes this skill, follow this flow:

1. Collect required inputs — prompt for any that are missing:
   - **Search query** — the keyword or phrase to search for (e.g., `meeting`, `project alpha`)

2. Check that `OBSIDIAN_API_TOKEN` is set. If it is not, tell the user:
   > "OBSIDIAN_API_TOKEN is not set. Export it with: `export OBSIDIAN_API_TOKEN=<your_token>`"
   Then stop.

3. Run the search using `obsidian_api.sh`:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /search --data-urlencode "q=<query>"
   ```

4. Parse the JSON array response and present results as a list:
   - For each result show: **path**, **title** (if present), and the matching **excerpt**
   - If no results are returned, say: "No notes found matching `<query>`."

5. After listing results, ask:
   > "Would you like to open any of these notes?"
   If the user says yes, run `obsidian-open-note` with the chosen path.

6. On error, show the raw response and suggest:
   - Confirm Obsidian is running with the Local REST API plugin active
   - The search endpoint path may differ by plugin version — check your plugin docs
