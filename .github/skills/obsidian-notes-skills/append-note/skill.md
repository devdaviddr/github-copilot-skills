---
name: obsidian-append-note
description: Append text to an existing note in your Obsidian vault via the local REST API.
---

When the user invokes this skill, follow this flow:

1. Collect required inputs — prompt for any that are missing:
   - **Note path** — relative path to the note inside the vault (e.g., `notes/meeting.md`)
   - **Text to append** — the content to add at the end of the note

2. Check that `OBSIDIAN_API_TOKEN` is set. If it is not, tell the user:
   > "OBSIDIAN_API_TOKEN is not set. Export it with: `export OBSIDIAN_API_TOKEN=<your_token>`"
   Then stop.

3. Run the append call using `obsidian_api.sh` from the skill directory:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh POST /files/update \
     --data '{"path":"<note-path>","append":"\n<text>"}'
   ```

4. On success, confirm to the user:
   > "Appended to `<note-path>` successfully."

5. On error (non-2xx response or curl failure), show the raw error output and suggest:
   - Verify the note path exists in the vault
   - Confirm the Obsidian app is running with the Local REST API plugin active
   - Check `OBSIDIAN_API_HOST` (default: `https://127.0.0.1:27124`)
