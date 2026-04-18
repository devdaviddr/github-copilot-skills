obsidian-append-note

Calls: POST /files/update (example)

Usage:
  ./obsidian_api.sh POST /files/update --data '{"path":"notes/foo.md","append":"\nAdditional text"}'

Important: Many Obsidian HTTP plugins do not provide a single append endpoint. If missing, read-file + write-file is an alternative: GET file, concatenate, then POST new content.