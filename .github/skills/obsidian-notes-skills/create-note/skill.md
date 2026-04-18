---
name: obsidian-create-note
---

Create a new note by POSTing JSON containing path and content. Example body: {"path":"notes/new.md","content":"# Title\nBody"}

Example (shell):
  ./obsidian_api.sh POST /files --data '{"path":"notes/new.md","content":"# New Note\nHello"}'

Article example (shell):
  ./obsidian_api.sh POST /files --data '{"path":"articles/2026-04-18-my-article.md","content":"---\\ntitle: My Article\\ndate: 2026-04-18\\ntags: [article]\\n---\\n\\n# My Article\\n\\nThis is the first paragraph of the article.\\n"}'

Adjust endpoint if your Obsidian plugin uses a different API (e.g., /create-file).