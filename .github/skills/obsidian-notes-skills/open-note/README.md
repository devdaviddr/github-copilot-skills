# obsidian-open-note

Fetches and displays a note from your Obsidian vault by file path.

## API call

```
GET /files/<note-path>
```

## Usage

```bash
./.github/skills/obsidian-notes-skills/obsidian_api.sh GET "/files/notes/meeting.md"
```

## Notes

- The path is relative to the vault root.
- If your local API plugin encodes paths differently, URL-encode special characters in the path.
- Ensure `OBSIDIAN_API_TOKEN` is exported before running.
