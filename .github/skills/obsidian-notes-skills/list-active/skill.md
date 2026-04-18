---
name: obsidian-list-active
description: Show the currently active Obsidian vault and confirm the local REST API is reachable.
---

When the user invokes this skill, follow this flow:

1. Check that `OBSIDIAN_API_TOKEN` is set. If it is not, tell the user:
   > "OBSIDIAN_API_TOKEN is not set. Export it with: `export OBSIDIAN_API_TOKEN=<your_token>`"
   Then stop.

2. Run the active vault check using `obsidian_api.sh`:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /active/
   ```

3. Parse the JSON response and report:
   - **Vault name** — the `vault` field
   - **Vault path** — the `path` field
   - **Status** — confirm the API is reachable with "✅ Obsidian API is active."

4. On error (connection refused, non-2xx), tell the user:
   > "Could not reach the Obsidian API. Make sure Obsidian is open and the Local REST API plugin is enabled."
   Suggest checking `OBSIDIAN_API_HOST` (default: `https://127.0.0.1:27124`).
