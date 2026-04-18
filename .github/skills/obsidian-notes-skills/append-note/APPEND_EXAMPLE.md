Append example

This example shows how to use append_note.sh to read a note and append content safely.

Prerequisites:
- OBSIDIAN_API_TOKEN exported
- python3 available

Example:
  export OBSIDIAN_API_TOKEN="your_token_here"
  ./.github/skills/obsidian-notes-skills/append-note/append_note.sh "notes/meeting.md" "\n- Action: email Alice"

Notes:
- The script URL-encodes the path and will try to extract 'content' when the API returns JSON.
- If your Obsidian HTTP API uses different endpoints (e.g., /create-file or /update), adapt the helper or script accordingly.