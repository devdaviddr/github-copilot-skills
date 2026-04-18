# Obsidian Notes Skills

Five Copilot skills for interacting with a local Obsidian vault via the [Local REST API](https://github.com/coddingtonbear/obsidian-local-rest-api) plugin.

## Skills

| Command | What it does |
|---|---|
| `obsidian-list-active` | Confirms the API is reachable and shows the active vault name and path |
| `obsidian-search-notes` | Searches notes by keyword and lists matching results with excerpts |
| `obsidian-open-note` | Fetches and displays a note by file path |
| `obsidian-create-note` | Creates a new note with a given path and content (supports YAML frontmatter) |
| `obsidian-append-note` | Appends text to the end of an existing note |

## Setup

Set your API token before invoking any skill:

```bash
export OBSIDIAN_API_TOKEN="<your_token_here>"
```

Optionally override the host (default: `https://127.0.0.1:27124`):

```bash
export OBSIDIAN_API_HOST="https://127.0.0.1:27124"
```

A `.env.example` is provided — copy it to `.env` in this directory and fill in your token for persistent local use. Ensure `.env` is in your `.gitignore`.

## Shared helper

All skills use `obsidian_api.sh` — a thin wrapper that prefers `curl` and falls back to `python3` if curl is unavailable.
