#!/usr/bin/env python3
import os
import yaml
import logging
import argparse
from yt_dlp import YoutubeDL

def load_config(path='config.yaml'):
    """Load YAML configuration from the given path."""
    with open(path, 'r') as f:
        return yaml.safe_load(f)

def setup_logging(log_file='ytdownloader.log'):
    """Configure logging to file and stdout."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s [%(levelname)s] %(message)s',
        handlers=[
            logging.FileHandler(log_file),
            logging.StreamHandler()
        ]
    )

def progress_hook(d):
    """Hook to report download progress."""
    if d['status'] == 'downloading':
        downloaded = d.get('downloaded_bytes', 0)
        total = d.get('total_bytes') or d.get('total_bytes_estimate', 0)
        if total:
            percent = downloaded / total * 100
            print(f"Progress: {percent:.1f}% - {d.get('filename', '')}", end='\r')
    elif d['status'] == 'finished':
        print(f"\nDownloaded: {d.get('filename', '')}")

def get_ydl_opts(music_dir, archive_file):
    """Return yt-dlp options dict with ffmpeg postprocessor, archive support, and progress hook."""
    return {
        'format': 'bestaudio/best',
        'outtmpl': os.path.join(music_dir, '%(upload_date)s - %(title)s.%(ext)s'),
        'postprocessors': [{
            'key': 'FFmpegExtractAudio',
            'preferredcodec': 'mp3',
            'preferredquality': '192',
        }],
        'download_archive': archive_file,
        'ignoreerrors': True,
        'no_warnings': True,
        'progress_hooks': [progress_hook],
        'default_search': 'ytsearch',  # treat plain text as search
    }

def download_url(url, ydl_opts):
    """Download and convert the given URL using yt-dlp."""
    logging.info(f'Starting download: {url}')
    with YoutubeDL(ydl_opts) as ydl:
        ydl.download([url])

def process_target(item, ydl_opts):
    """Determine URL based on target type and delegate to download."""
    t = item.get('type')
    if t == 'channel':
        url = f"https://www.youtube.com/channel/{item['id']}/videos"
    elif t == 'playlist':
        url = f"https://www.youtube.com/playlist?list={item['id']}"
    elif t == 'search':
        count = item.get('amount', 5)
        query = item.get('query', '')
        url = f"ytsearch{count}:{query}"
    else:
        logging.warning(f"Unknown target type: {t}")
        return
    download_url(url, ydl_opts)

def main():
    parser = argparse.ArgumentParser(description='YouTube to MP3 downloader')
    parser.add_argument('--config', help='Path to config.yaml', default='config.yaml')
    args = parser.parse_args()

    
    custom_dir = input('Kaydedileceği dizin (boş bırakırsan config kullanılır): ').strip()
    cfg = load_config(args.config)
    storage = cfg.get('storage', {})
    default_dir = storage.get('music_dir', './Music')
    music_dir = custom_dir if custom_dir else default_dir
    archive_file = cfg.get('archive_file', os.path.join(music_dir, 'archive.txt'))

    os.makedirs(music_dir, exist_ok=True)
    setup_logging(cfg.get('log_file', 'ytdownloader.log'))
    ydl_opts = get_ydl_opts(music_dir, archive_file)

   
    link = input('YouTube video/playlist/search link veya arama terimi (boş bırakmak için Enter): ').strip()

    if link:
        download_url(link, ydl_opts)# If input is plain text (no URL or prefix), yt-dlp default_search handles search
    else:
        for item in cfg.get('targets', []):
            try:
                process_target(item, ydl_opts)
            except Exception as e:
                logging.error(f'Error processing {item}: {e}')

if __name__ == '__main__':
    main()

