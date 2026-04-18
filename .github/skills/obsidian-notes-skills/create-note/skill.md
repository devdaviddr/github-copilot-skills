---
name: obsidian-create-note
---

Create a new note by POSTing JSON containing path and content. Example body: {"path":"notes/new.md","content":"# Title\nBody"}

Example (shell):
  ./obsidian_api.sh POST /files --data '{"path":"notes/new.md","content":"# New Note\nHello"}'

Adjust endpoint if your Obsidian plugin uses a different API (e.g., /create-file).