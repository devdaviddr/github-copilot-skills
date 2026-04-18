Obsidian Notes Skills

Group of Copilot CLI skills for interacting with a local Obsidian HTTP API.

A .env.example file is provided in this directory to show required environment variables. You can load it with:

  # from the repo root
  export $(cat .github/skills/obsidian-notes-skills/.env.example | xargs)

Or set variables individually:

  export OBSIDIAN_API_TOKEN="<your_token_here>"
  export OBSIDIAN_API_HOST="https://127.0.0.1:27124"



Environment
- OBSIDIAN_API_TOKEN: Bearer token for the local Obsidian API
- OBSIDIAN_API_HOST: Optional. Default: https://127.0.0.1:27124

Files
- obsidian_api.sh — shared helper wrapper for HTTP requests (uses curl if available, falls back to python3)
- Subfolders (one skill each): list-active, search-notes, open-note, create-note, append-note

Usage
1. Preferred (temporary session): export OBSIDIAN_API_TOKEN="<token>"
   The helper script checks for this environment variable first and will use it for authenticated requests.

2. Alternative (recommended for local development): store your token in a .env file. If the OBSIDIAN_API_TOKEN environment variable is not set, the helper will look for a .env file in the repository root or the skill folder (.github/skills/obsidian-notes-skills/.env) and load simple KEY=VALUE lines from it.
   - Copy the .env.example file in the skill folder (for example: append-note/.env.example -> append-note/.env)
   - Fill in OBSIDIAN_API_TOKEN in the local .env
   - Ensure your .gitignore excludes .env so you do not accidentally commit secrets

3. Run a skill via the Copilot CLI (e.g., `obsidian-list-active`) or call the script directly:
   ./obsidian_api.sh GET /active/

Examples and expected outputs

- obsidian-list-active
  Command:
    ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /active/
  Example output (JSON):
    {
      "vault": "MyVault",
      "path": "/Users/alice/Obsidian/MyVault",
      "active": true
    }

- obsidian-search-notes
  Command:
    ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /search --data-urlencode "q=todo"
  Example output (JSON):
    [
      {
        "path": "notes/todo.md",
        "title": "Todo list",
        "excerpt": "- [ ] buy milk"
      },
      {
        "path": "projects/alpha.md",
        "title": "Project Alpha",
        "excerpt": "Tasks:\n- [ ] write proposal"
      }
    ]

- obsidian-create-article
  Command:
    ./.github/skills/obsidian-notes-skills/obsidian_api.sh POST /files --data '{"path":"articles/2026-04-18-my-article.md","content":"---\\ntitle: My Article\\ndate: 2026-04-18\\ntags: [article]\\n---\\n\\n# My Article\\n\\nThis is the first paragraph of the article.\\n"}'
  Expected created note (Markdown):

    ---
    title: My Article
    date: 2026-04-18
    tags: [article]
    ---

    # My Article

    This is the first paragraph of the article.


Notes and troubleshooting
- The helper script prefers curl. If curl is not installed, obsidian_api.sh will attempt a Python 3 fallback using urllib.request. Ensure python3 is installed.
- If you see "curl: command not found", install curl:
  - macOS (Homebrew): brew install curl
  - Debian/Ubuntu: sudo apt update && sudo apt install -y curl
- Examples (disable git pagers when showing files via git):
  - Run smoke tests: ./smoke_test_obsidian.sh
  - Run helper directly: ./obsidian_api.sh GET /active/
  - Search with URL-encoded query: ./obsidian_api.sh GET /search --data-urlencode "q=test"
  - View the .env.example using git without pager: git --no-pager show HEAD:.github/skills/obsidian-notes-skills/.env.example
- The scripts print raw JSON responses to stdout. Use jq for pretty printing: ./obsidian_api.sh GET /active/ | jq .