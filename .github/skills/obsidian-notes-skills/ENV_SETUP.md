Setting up your OBSIDIAN_API_TOKEN (recommended)

Options:

1) Quick (manual)
- Copy .env.example to .env and edit:
  cp .github/skills/obsidian-notes-skills/.env.example .github/skills/obsidian-notes-skills/.env
  Edit .github/skills/obsidian-notes-skills/.env and set OBSIDIAN_API_TOKEN to your token.
- Add .env to your .gitignore so it isn't committed.

2) Interactive helper (safer)
- Run the included setup script which writes a .env in the skills folder and can optionally save the token to macOS Keychain:
  ./.github/skills/obsidian-notes-skills/setup_env.sh

3) Store token in macOS Keychain (recommended for macOS users)
- Save token once:
  security add-generic-password -s obsidian-token -a "$USER" -w "<your_token>"
- Use it in a shell without writing a file:
  export OBSIDIAN_API_TOKEN="$(security find-generic-password -s obsidian-token -w)"

Security notes:
- Never commit secrets to git. Prefer Keychain or an OS secret store.
- If you must use a .env file, ensure it is listed in .gitignore.
