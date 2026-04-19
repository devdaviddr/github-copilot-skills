---
name: obsidian-create-note
description: Create a new note in your Obsidian vault with a given path and content via the local REST API.
---

When the user invokes this skill, follow this flow:

1. Collect required inputs — prompt for any that are missing:
   - **Note path** — where to create the note inside the vault (e.g., `notes/new-idea.md`)
   - **Title** — used as the `# H1` heading if the user does not provide full content
   - **Content** — full markdown body of the note (optional — if not provided, create a minimal note with the title as an H1 heading)

   If the user wants a structured article note, also ask:
   - **Tags** (optional) — comma-separated list for YAML frontmatter
   - **Date** — defaults to today's date in `YYYY-MM-DD` format

2. Build the note content:
   - If tags or date were provided, prepend a YAML frontmatter block:
     ```markdown
     ---
     title: <title>
     date: <date>
     tags: [<tags>]
     ---
     ```
   - Follow with `# <title>` and the body content.

3. Check that `OBSIDIAN_API_TOKEN` is set. If it is not, tell the user:
   > "OBSIDIAN_API_TOKEN is not set. Export it with: `export OBSIDIAN_API_TOKEN=<your_token>`"
   Then stop.

4. Run the create call using `obsidian_api.sh`.
   `PUT /vault/{encoded-path}` creates or overwrites the note with the given markdown content:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh PUT "/vault/<url-encoded-note-path>" \
     -H "Content-Type: text/markdown" \
     --data "<note-content>"
   ```
   Example for `notes/new-idea.md`:
   ```
   ./.github/skills/obsidian-notes-skills/obsidian_api.sh PUT "/vault/notes/new-idea.md" \
     -H "Content-Type: text/markdown" \
     --data "# New Idea\n\nContent here."
   ```
   For multi-line content write it to a temp file and use `--data-binary @tmpfile`.

5. On success, confirm to the user:
   > "Note created at `<note-path>`."
   Show a preview of the first few lines.

6. On error, show the raw error and suggest:
   - The path may already exist — use `obsidian-open-note` to check
   - Confirm Obsidian is running with the Local REST API plugin active
