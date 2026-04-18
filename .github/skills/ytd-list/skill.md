---
name: ytd-list
description: Fetch all uploads from a YouTube channel and save to CSV. Accepts a channel ID or username. Requires a YouTube Data API v3 key via --api-key flag or YT_API_KEY environment variable.
---

When the user invokes this skill, follow this flow:

1. Collect required inputs — prompt for any that are missing:
   - **Channel identifier** — one of:
     - Channel ID (starts with `UC…`, e.g., `UC9Rrud-8CaHokDtK9FszvRg`)
     - Legacy username (e.g., `@GitHubEducation`)
   - **Output file** (optional) — path for the CSV file; default: `outputs/ytd-list/<channel-id>.csv`

2. Check for an API key — in this order:
   1. `YT_API_KEY` environment variable
   2. User-provided `--api-key` argument
   If neither is available, tell the user:
   > "A YouTube Data API v3 key is required. Set it with: `export YT_API_KEY=<your_key>` or provide it inline."
   Then stop.

3. Run the fetch script from the skill directory:
   - With a channel ID:
     ```
     python .github/skills/ytd-list/fetch_videos.py \
       --channel-id <channel-id> \
       --out <output-file>
     ```
   - With a username:
     ```
     python .github/skills/ytd-list/fetch_videos.py \
       --username <username> \
       --out <output-file>
     ```
   The script pages through all uploads (50 per request) until complete.

4. On success, confirm:
   > "Fetched <N> videos. CSV saved to `<output-file>`."
   Show the first 5 rows as a markdown table (title, video ID, URL, published date).

5. On error, show the error and suggest:
   - Verify the channel ID or username is correct
   - Check that the API key is valid and has the YouTube Data API v3 enabled in Google Cloud Console
   - If no API key is available, the `fetch_videos_yt_dlp.py` script can be used instead (requires `yt-dlp`, no API key needed):
     ```
     python .github/skills/ytd-list/fetch_videos_yt_dlp.py \
       --channel-url "https://www.youtube.com/channel/<channel-id>" \
       --out <output-file>
     ```

