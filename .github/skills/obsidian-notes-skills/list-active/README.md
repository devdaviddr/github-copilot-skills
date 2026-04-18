obsidian-list-active

Calls: GET /active/

Usage:
- Ensure OBSIDIAN_API_TOKEN is exported
- From repo root: ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /active/

Purpose: useful to confirm the API is running and which vault is active.

Environment & examples:

  # load .env.example from repo root
  export $(cat .github/skills/obsidian-notes-skills/.env.example | xargs)

  # or set individually
  export OBSIDIAN_API_TOKEN="<your_token_here>"
  export OBSIDIAN_API_HOST="https://127.0.0.1:27124"

Example command:
  ./.github/skills/obsidian-notes-skills/obsidian_api.sh GET /active/

Example output (JSON):
  {
    "vault": "MyVault",
    "path": "/Users/alice/Obsidian/MyVault",
    "active": true
  }