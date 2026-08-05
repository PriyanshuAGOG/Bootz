#!/usr/bin/env bash
set -euo pipefail
OUT=dayara-stock-pack
mkdir -p "$OUT/clips" "$OUT/previews"
raw="$OUT/yoga_raw.mp4"
out="$OUT/clips/09_yoga_mountain.mp4"
curl --fail --location --retry 3 --retry-delay 2 --user-agent 'Mozilla/5.0' \
  "https://www.pexels.com/download/video/6298127/" -o "$raw"
duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$raw")
start=$(awk -v d="$duration" 'BEGIN{s=(d-10)/2;if(s<0)s=0;printf "%.3f",s}')
ffmpeg -nostdin -y -ss "$start" -stream_loop -1 -i "$raw" -t 10 \
  -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30,eq=contrast=1.035:saturation=1.08:brightness=0.015,format=yuv420p" \
  -an -c:v libx264 -preset veryfast -crf 24 -movflags +faststart "$out"
ffmpeg -nostdin -y -ss 2 -i "$out" -frames:v 1 -update 1 -q:v 3 "$OUT/previews/09_yoga_mountain.jpg"
rm -f "$raw"
printf '%s\n' '09_yoga_mountain.mp4' > "$OUT/downloaded.txt"
printf '%s\n' '09_yoga_mountain.mp4|6298127' > "$OUT/manifest.txt"
