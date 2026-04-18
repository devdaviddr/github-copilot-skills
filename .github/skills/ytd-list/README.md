ytd-list
=======

A small skill that fetches every video uploaded by a YouTube channel and writes a CSV with title, id, URL and published date.

Prerequisites
- Python 3.8+
- A YouTube Data API v3 key (get one from Google Cloud Console)

Usage

1. Via API key argument:

    python fetch_videos.py --channel-id UC9Rrud-8CaHokDtK9FszvRg --api-key YOUR_API_KEY --out github-awesome-videos.csv

2. Via environment variable:

    export YT_API_KEY=YOUR_API_KEY
    python fetch_videos.py --channel-id UC9Rrud-8CaHokDtK9FszvRg --out github-awesome-videos.csv

Options
- --channel-id: full channel ID (starts with "UC...")
- --username: legacy username (optional)
- --uploads-playlist: direct uploads playlist id (optional)
- --out: output CSV path (default: ./videos.csv)

Notes
- The script pages through playlistItems (50 per request) until all videos are retrieved.
- If you prefer, call the script from the skill folder as a standalone helper.

No-key alternative (yt-dlp)
- If you don't have a YouTube API key, use the included yt-dlp-based script which does not require the API.
- Install: pip install yt-dlp
- Example:

    python fetch_videos_yt_dlp.py --channel-url "https://www.youtube.com/channel/UC..." --out videos.csv

- Use --full to fetch per-video metadata (upload date) but note this is slower.
