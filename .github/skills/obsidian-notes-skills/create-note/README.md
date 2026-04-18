obsidian-create-note

Calls: POST /files (JSON body: path, content)

Usage:
  ./obsidian_api.sh POST /files --data '{"path":"notes/new.md","content":"# Title\nBody"}'

Example: create an article note with YAML frontmatter
  ./obsidian_api.sh POST /files --data '{"path":"articles/2026-04-18-my-article.md","content":"---\\ntitle: My Article\\ndate: 2026-04-18\\ntags: [article]\\n---\\n\\n# My Article\\n\\nThis is the first paragraph of the article.\\n"}'

If your Obsidian HTTP plugin uses a different route, update the POST target.