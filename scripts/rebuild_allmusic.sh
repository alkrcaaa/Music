#!/usr/bin/env bash
set -euo pipefail

# Settings
PLAYLIST="AllMusic"
PLAYLIST_DIR="$HOME/.config/mpd/playlists"
PLAYLIST_FILE="$PLAYLIST_DIR/${PLAYLIST}.m3u"


mpc rm "$PLAYLIST" 2>/dev/null || true
rm -f "$PLAYLIST_FILE"


mkdir -p "$PLAYLIST_DIR"


mpc clear
mpc update


mpc listall | while read -r song; do
  mpc add "$song"
done


mpc save "$PLAYLIST"

COUNT=$(mpc playlist "$PLAYLIST" | wc -l)
echo "✅ \"$PLAYLIST\" playlisti yeniden oluşturuldu ($COUNT şarkı eklendi)."
