# obsidian-append-note

Appends text to the end of an existing note in your Obsidian vault.

## API call

```
POST /files/update
Body: { "path": "<note-path>", "append": "\n<text>" }
```

## Usage

```bash
./.github/skills/obsidian-notes-skills/obsidian_api.sh POST /files/update \
  --data '{"path":"notes/foo.md","append":"\nAdditional text"}'
```

## Notes

- Many Obsidian HTTP plugins do not provide a dedicated append endpoint. If your plugin does not support `/files/update` with an `append` key, use the read-then-write pattern: `GET /files/<path>`, concatenate the new content, then `POST /files/<path>` with the full updated content.
- Ensure `OBSIDIAN_API_TOKEN` is exported before running.
