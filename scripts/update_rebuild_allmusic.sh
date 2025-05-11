#!/usr/bin/env bash
set -euo pipefail


read -rp "Müzik dosyalarının bulunduğu dizin (örn: /home/ali/Music/YouTube): " MUSIC_DIR
read -rp "Oluşturulacak playlist adı: " PLAYLIST


if [[ -n "${SUDO_USER:-}" ]]; then
  USER_HOME=$(eval echo "~${SUDO_USER}")
else
  USER_HOME="$HOME"
fi

PLAYLIST_DIR="${USER_HOME}/.config/mpd/playlists"
PLAYLIST_FILE="${PLAYLIST_DIR}/${PLAYLIST}.m3u"


mkdir -p "${PLAYLIST_DIR}"

rm -f "${PLAYLIST_FILE}"


declare -A seen
while IFS= read -r -d '' song; do
  filename=$(basename "${song}")
  if [[ -n "${seen[$filename]:-}" ]]; then
    continue
  fi
  seen[$filename]=1

  echo "${song}" >> "${PLAYLIST_FILE}"
done < <(find "${MUSIC_DIR}" -type f \( -iname '*.mp3' -o -iname '*.wav' -o -iname '*.flac' \) -print0)


total=$(grep -c '' "${PLAYLIST_FILE}")
echo "✅ \"${PLAYLIST}\" playlist dosyası oluşturuldu: ${PLAYLIST_FILE} (${total} şarkı)"

