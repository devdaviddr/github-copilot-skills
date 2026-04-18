# obsidian-search-notes

Searches notes in your Obsidian vault by keyword using the local REST API.

## API call

```
GET /search?q=<term>
```

## Usage

```bash
./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /search --data-urlencode "q=your+term"
```

## Environment

```bash
export OBSIDIAN_API_TOKEN="<your_token_here>"
export OBSIDIAN_API_HOST="https://127.0.0.1:27124"  # optional, this is the default
```

## Example output

```json
[
  {
    "path": "notes/todo.md",
    "title": "Todo list",
    "excerpt": "- [ ] buy milk"
  }
]
```

## Notes

- The exact search endpoint path may vary depending on the installed Obsidian plugin version — check your plugin docs if `/search` returns 404.
- Ensure `OBSIDIAN_API_TOKEN` is exported before running.
