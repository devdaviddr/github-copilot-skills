---
name: obsidian-open-note
description: Fetch and display a note from your Obsidian vault by file path via the local REST API.
---

When the user invokes this skill, follow this flow:

1. Collect required inputs — prompt for any that are missing:
   - **Note path** — relative path to the note inside the vault (e.g., `notes/meeting.md`)

2. Check that `OBSIDIAN_API_TOKEN` is set. If it is not, tell the user:
   > "OBSIDIAN_API_TOKEN is not set. Export it with: `export OBSIDIAN_API_TOKEN=<your_token>`"
   Then stop.

3. Run the fetch call using `obsidian_api.sh`:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET "/files/<note-path>"
   ```

4. On success, display the note content in your response — render it as markdown if the content is markdown, or show it as a code block if it is raw text.

5. On a 404 or error, tell the user:
   > "Note not found at `<note-path>`. Check the path is correct and relative to your vault root."
