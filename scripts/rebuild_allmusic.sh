#!/usr/bin/env bash
set -euo pipefail

# Ayarlar
PLAYLIST="AllMusic"
PLAYLIST_DIR="$HOME/.config/mpd/playlists"
PLAYLIST_FILE="$PLAYLIST_DIR/${PLAYLIST}.m3u"

# 1) Eski playlist kaydını sil
mpc rm "$PLAYLIST" 2>/dev/null || true
rm -f "$PLAYLIST_FILE"

# 2) Klasörü (tekrar) oluştur
mkdir -p "$PLAYLIST_DIR"

# 3) Kuyruğu temizle ve veritabanını güncelle
mpc clear
mpc update

# 4) Tüm dosyaları sıraya ekle
mpc listall | while read -r song; do
  mpc add "$song"
done

# 5) Yeni playlist olarak kaydet
mpc save "$PLAYLIST"

# 6) Bilgi mesajı
COUNT=$(mpc playlist "$PLAYLIST" | wc -l)
echo "✅ \"$PLAYLIST\" playlisti yeniden oluşturuldu ($COUNT şarkı eklendi)."
