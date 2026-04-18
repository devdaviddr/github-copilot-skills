obsidian-search-notes

Calls: GET /search?q=<term>

Usage:
  ./obsidian_api.sh GET /search --data-urlencode "q=your+term"

Notes: the exact endpoint path may vary depending on installed Obsidian plugins; adapt the request as needed.

Environment & examples:

  # load .env.example from repo root
  export $(cat .github/skills/obsidian-notes-skills/.env.example | xargs)

  # or set individually
  export OBSIDIAN_API_TOKEN="<your_token_here>"
  export OBSIDIAN_API_HOST="https://127.0.0.1:27124"

Example command:
  ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /search --data-urlencode "q=todo"

Example output (JSON):
  [
    {
      "path": "notes/todo.md",
      "title": "Todo list",
      "excerpt": "- [ ] buy milk"
    }
  ]