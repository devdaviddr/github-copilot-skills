#!/usr/bin/env python3
"""
List all videos from a YouTube channel (no API key) using yt-dlp and write CSV.

Usage:
  pip install yt-dlp
  python fetch_videos_yt_dlp.py --channel-url "https://www.youtube.com/channel/UC..." --out videos.csv

Options:
  --channel-url   Channel page (channel, user, or custom URL). Can also pass channel ID like "https://www.youtube.com/channel/UC..." or a full channel page URL.
  --out           CSV output (default: videos.csv)
  --full          Fetch full metadata per video (slower; gets upload date)
"""

import argparse
import csv
import sys
from yt_dlp import YoutubeDL


def get_entries(channel_url, full=False):
    ydl_opts = {'quiet': True, 'skip_download': True}
    # extract_flat speeds up listing; full=True will get full metadata per video
    if not full:
        ydl_opts.update({'extract_flat': 'in_playlist'})
    with YoutubeDL(ydl_opts) as ydl:
        # yt-dlp understands channel pages and their /videos listing
        url = channel_url.rstrip('/')
        if not url.endswith('/videos'):
            url = url + '/videos'
        info = ydl.extract_info(url, download=False)
        entries = info.get('entries') or []
        if not full:
            # entries have 'id' and 'title'
            for e in entries:
                vid = e.get('id') or e.get('url')
                if not vid:
                    continue
                yield {'id': vid, 'title': e.get('title', '') or '', 'url': f'https://www.youtube.com/watch?v={vid}'}
        else:
            # fetch full metadata for each video (slower)
            for e in entries:
                vid = e.get('id') or e.get('url')
                if not vid:
                    continue
                meta = ydl.extract_info(f'https://www.youtube.com/watch?v={vid}', download=False)
                yield {
                    'id': meta.get('id'),
                    'title': meta.get('title', '') or '',
                    'url': f'https://www.youtube.com/watch?v={meta.get('id')}',
                    'upload_date': meta.get('upload_date')
                }


def write_csv(path, rows):
    keys = ['position','video_id','title','published_at','url']
    with open(path, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(keys)
        for i,r in enumerate(rows, start=1):
            w.writerow([i, r.get('id'), r.get('title',''), r.get('upload_date',''), r.get('url')])


def main():
    p = argparse.ArgumentParser(description='List all videos from a YouTube channel using yt-dlp')
    p.add_argument('--channel-url', required=True, help='Channel page URL or channel id')
    p.add_argument('--out', default='videos.csv')
    p.add_argument('--full', action='store_true', help='Fetch full metadata for each video (slower)')
    args = p.parse_args()

    try:
        rows = list(get_entries(args.channel_url, full=args.full))
    except Exception as exc:
        print('Extraction failed:', exc, file=sys.stderr)
        sys.exit(2)
    if not rows:
        print('No videos found or extraction returned empty.', file=sys.stderr)
        sys.exit(1)
    write_csv(args.out, rows)
    print(f'Wrote {len(rows)} videos to {args.out}')


if __name__ == '__main__':
    main()
