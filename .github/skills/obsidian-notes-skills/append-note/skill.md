---
name: obsidian-append-note
---

Append text to an existing note. The exact API for append may differ per plugin; this skill demonstrates POSTing an update payload.

Example (shell):
  ./obsidian_api.sh POST /files/update --data '{"path":"notes/foo.md","append":"\nMore text"}'

Adapt the endpoint and payload for your Obsidian setup.