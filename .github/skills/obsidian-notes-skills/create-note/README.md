obsidian-create-note

Calls: POST /files (JSON body: path, content)

Usage:
  ./obsidian_api.sh POST /files --data '{"path":"notes/new.md","content":"# Title\nBody"}'

If your Obsidian HTTP plugin uses a different route, update the POST target.