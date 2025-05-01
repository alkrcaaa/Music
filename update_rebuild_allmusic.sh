#!/usr/bin/env bash
set -euo pipefail

# Kullanıcıdan klasör ve playlist adı alın
read -rp "Müzik dosyalarının bulunduğu dizin (örn: /home/ali/Music/YouTube): " MUSIC_DIR
read -rp "Oluşturulacak playlist adı: " PLAYLIST

# Eğer sudo ile çalıştıysa asıl kullanıcının home dizinini al
if [[ -n "${SUDO_USER:-}" ]]; then
  USER_HOME=$(eval echo "~${SUDO_USER}")
else
  USER_HOME="$HOME"
fi

PLAYLIST_DIR="${USER_HOME}/.config/mpd/playlists"
PLAYLIST_FILE="${PLAYLIST_DIR}/${PLAYLIST}.m3u"

# 1) Klasörü (tekrar) oluştur
mkdir -p "${PLAYLIST_DIR}"

# 2) Var olan playlist dosyasını sil
rm -f "${PLAYLIST_FILE}"

# 3) Dosya listesini oluştur ve tekrar edenleri uzantıya bakarak tekilleştir
declare -A seen
while IFS= read -r -d '' song; do
  filename=$(basename "${song}")
  if [[ -n "${seen[$filename]:-}" ]]; then
    continue
  fi
  seen[$filename]=1
  # Playlist dosyasına göreli yol ekle (MPD root ile uyumlu)
  echo "${song}" >> "${PLAYLIST_FILE}"
done < <(find "${MUSIC_DIR}" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' \) -print0)

# 4) Bilgi mesajı
total=$(grep -c '' "${PLAYLIST_FILE}")
echo "✅ \"${PLAYLIST}\" playlist dosyası oluşturuldu: ${PLAYLIST_FILE} (${total} şarkı)"

