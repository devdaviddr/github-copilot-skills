---
name: obsidian-search-notes
---

Search notes using the Obsidian local API search endpoint. Provide a query argument.

Example (shell):
  ./obsidian_api.sh GET /search --data-urlencode "q=meeting"

When used as a Copilot skill, pass the search term as the single argument.