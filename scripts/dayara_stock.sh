#!/usr/bin/env bash
set -u
OUT=dayara-stock-pack
mkdir -p "$OUT/clips" "$OUT/previews" "$OUT/raw"

cat > "$OUT/manifest.txt" <<'EOF'
01_himalaya_sunrise.mp4|30778285
02_green_himalayan_valley.mp4|4218249
03_green_mountains.mp4|12180236
04_misty_himalayas.mp4|30152886
05_green_hills.mp4|9873613
06_mountain_valley.mp4|9783700
07_forest_hikers.mp4|5027202
08_forest_trail.mp4|4580897
09_yoga_mountain.mp4|7424317
10_snow_climb.mp4|9972089
11_summit_climbers.mp4|2040076
12_group_mountain_trek.mp4|5895501
13_blood_pressure.mp4|4352135
14_healthy_nutrition.mp4|6740370
15_hiker_peak.mp4|11114585
16_rock_climber_drone.mp4|5013967
17_hiking_mountains.mp4|11335198
18_forest_mountain_hiker.mp4|36694070
EOF

while IFS='|' read -r filename id; do
  [ -n "$filename" ] || continue
  raw="$OUT/raw/$filename"
  out="$OUT/clips/$filename"
  echo "Downloading Pexels video $id as $filename"
  curl --fail --location --retry 3 --retry-delay 2 --user-agent 'Mozilla/5.0' \
    "https://www.pexels.com/download/video/$id/" -o "$raw" || { echo "DOWNLOAD_FAILED,$id"; continue; }
  ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$raw" >/dev/null 2>&1 || { echo "INVALID_VIDEO,$id"; rm -f "$raw"; continue; }
  duration=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$raw")
  start=$(awk -v d="$duration" 'BEGIN{s=(d-12)/2;if(s<0)s=0;printf "%.3f",s}')
  ffmpeg -nostdin -y -ss "$start" -i "$raw" -t 12 \
    -vf "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,fps=30,eq=contrast=1.035:saturation=1.08:brightness=0.015,format=yuv420p" \
    -an -c:v libx264 -preset veryfast -crf 23 -movflags +faststart "$out"
  ffmpeg -nostdin -y -ss 2 -i "$out" -frames:v 1 -update 1 -q:v 2 "$OUT/previews/${filename%.mp4}.jpg"
done < "$OUT/manifest.txt"

find "$OUT/clips" -type f -name '*.mp4' -printf '%f\n' | sort > "$OUT/downloaded.txt"
count=$(find "$OUT/clips" -type f -name '*.mp4' | wc -l)
echo "Downloaded $count usable clips"
test "$count" -ge 10
