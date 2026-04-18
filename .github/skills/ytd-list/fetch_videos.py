#!/usr/bin/env python3
"""Fetch all videos from a YouTube channel uploads playlist and write to CSV.

Usage examples:
  export YT_API_KEY=YOUR_KEY
  python fetch_videos.py --channel-id UC9Rrud-8CaHokDtK9FszvRg --out outputs/github-awesome-all.csv

Or pass --api-key directly.
"""
import argparse
import csv
import json
import os
import sys
import time
from urllib import request, parse

YT_API_BASE = 'https://www.googleapis.com/youtube/v3'


def http_get_json(url):
    req = request.Request(url, headers={'User-Agent': 'py-ytd-list/1.0'})
    with request.urlopen(req, timeout=30) as resp:
        return json.load(resp)


def get_uploads_playlist(api_key, channel_id=None, username=None, uploads_playlist=None):
    if uploads_playlist:
        return uploads_playlist
    if not api_key:
        raise SystemExit('API key is required (via --api-key or YT_API_KEY env var)')
    if channel_id:
        url = f"{YT_API_BASE}/channels?part=contentDetails&id={parse.quote(channel_id)}&key={api_key}"
    elif username:
        url = f"{YT_API_BASE}/channels?part=contentDetails&forUsername={parse.quote(username)}&key={api_key}"
    else:
        raise SystemExit('Either --channel-id, --username, or --uploads-playlist must be provided')
    j = http_get_json(url)
    items = j.get('items', [])
    if not items:
        raise SystemExit('Channel not found or no contentDetails available')
    return items[0]['contentDetails']['relatedPlaylists']['uploads']


def iterate_playlist_items(api_key, uploads_playlist):
    # pages of 50
    page_token = None
    while True:
        params = {
            'part': 'snippet,contentDetails',
            'playlistId': uploads_playlist,
            'maxResults': 50,
            'key': api_key
        }
        if page_token:
            params['pageToken'] = page_token
        url = f"{YT_API_BASE}/playlistItems?{parse.urlencode(params)}"
        j = http_get_json(url)
        for item in j.get('items', []):
            snip = item.get('snippet', {})
            content = item.get('contentDetails', {})
            video_id = content.get('videoId') or snip.get('resourceId', {}).get('videoId')
            title = (snip.get('title') or '').strip()
            published = snip.get('publishedAt') or ''
            yield {'id': video_id, 'title': title, 'published': published, 'url': f'https://www.youtube.com/watch?v={video_id}'}
        page_token = j.get('nextPageToken')
        if not page_token:
            break
        # be gentle
        time.sleep(0.1)


def write_csv(out_path, rows):
    with open(out_path, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(['position','video_id','title','published_at','url'])
        for i,row in enumerate(rows, start=1):
            w.writerow([i,row['id'],row['title'],row['published'],row['url']])


def main():
    p = argparse.ArgumentParser(description='Fetch all videos from a YouTube channel')
    p.add_argument('--channel-id', help='Channel ID (starts with UC...)')
    p.add_argument('--username', help='Legacy username (forUsername)')
    p.add_argument('--uploads-playlist', help='Direct uploads playlist id (optional)')
    p.add_argument('--api-key', help='YouTube Data API key (or set YT_API_KEY env var)')
    p.add_argument('--out', default='videos.csv', help='Output CSV path')
    args = p.parse_args()

    api_key = args.api_key or os.getenv('YT_API_KEY')
    if not api_key:
        print('Error: API key not provided. Use --api-key or set YT_API_KEY.', file=sys.stderr)
        sys.exit(2)

    uploads = get_uploads_playlist(api_key, channel_id=args.channel_id, username=args.username, uploads_playlist=args.uploads_playlist)
    print('Uploads playlist:', uploads)
    rows = list(iterate_playlist_items(api_key, uploads))
    print('Found', len(rows), 'videos')
    write_csv(args.out, rows)
    print('Wrote', args.out)


if __name__ == '__main__':
    main()
