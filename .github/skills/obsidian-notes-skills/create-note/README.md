# obsidian-create-note

Creates a new note in your Obsidian vault with the specified path and content.

## API call

```
POST /files
Body: { "path": "<note-path>", "content": "<markdown-content>" }
```

## Usage

```bash
# Minimal note
./.github/skills/obsidian-notes-skills/obsidian_api.sh POST /files \
  --data '{"path":"notes/new.md","content":"# Title\nBody"}'

# Article note with YAML frontmatter
./.github/skills/obsidian-notes-skills/obsidian_api.sh POST /files \
  --data '{"path":"articles/2026-04-18-my-article.md","content":"---\ntitle: My Article\ndate: 2026-04-18\ntags: [article]\n---\n\n# My Article\n\nFirst paragraph."}'
```

## Notes

- If your Obsidian HTTP plugin uses a different route (e.g., `/create-file`), update the POST target accordingly.
- Ensure `OBSIDIAN_API_TOKEN` is exported before running.
