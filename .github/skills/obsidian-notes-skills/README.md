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

Store your API token securely. Recommended options (in order):

1) macOS Keychain (recommended on macOS)

```bash
security add-generic-password -s obsidian-token -a "$USER" -w "<your_token>"
# Use in shell:
export OBSIDIAN_API_TOKEN="$(security find-generic-password -s obsidian-token -w)"
```

2) XDG config (~/.config/obsidian-api)

Create a file containing a single line:

```
OBSIDIAN_API_TOKEN=<your_token>
```

3) Project .env (least preferred — add .env to .gitignore)

Copy the provided template and fill it in:

```bash
cp .github/skills/obsidian-notes-skills/.env.example .env
# then edit .env and do not commit it
```

The included helper `obsidian_api_env.sh` will load the token from the Keychain, then ~/.config/obsidian-api, then .env (repo root), then the skill-local .env. Callers of the shared `obsidian_api.sh` will automatically pick up the token if available.

Summary of changes made to improve token handling:

- Added `obsidian_api_env.sh` to centralize token loading from multiple secure locations (Keychain → XDG config → .env files).
- Updated `obsidian_api.sh` to source the helper automatically so skills pick the token without manual export.
- Patched `obsidian_api.sh` to prefer `curl` and fail with a clear error if neither `curl` nor `python3` are available.
- Added README instructions for storing tokens securely and using the macOS Keychain or ~/.config/obsidian-api.

## Shared helper

All skills use `obsidian_api.sh` — a thin wrapper that prefers `curl` and will use a python fallback only if available.
