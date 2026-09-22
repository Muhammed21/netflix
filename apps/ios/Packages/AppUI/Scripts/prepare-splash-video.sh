#!/usr/bin/env bash
#
# Prépare l'animation du splash à partir de l'enregistrement source.
#
# La source est une capture d'écran d'iPhone : elle embarque une barre d'état
# « 9:41 » et un home indicator, qui produiraient un doublon à l'affichage. Son
# fond est par ailleurs #020002 et non du noir pur, ce qui laisserait une
# couture visible avec le token color.background.primary (#000000).
#
# Usage : ./prepare-splash-video.sh <source.mp4>
set -euo pipefail

SOURCE="${1:?usage: prepare-splash-video.sh <source.mp4>}"
DEST="$(dirname "$0")/../Sources/AppUI/Resources/splash-wordmark.mp4"

# crop   : bande centrée sur le logo (mesuré à y=698..841 sur 1560), le chrome
#          iOS tombe hors cadre. Une bande plutôt qu'un plein écran rend l'asset
#          indépendant du format de l'appareil.
# lutrgb : écrase les valeurs quasi noires vers 0 pour que le fond de la vidéo
#          coïncide exactement avec celui de l'écran.
ffmpeg -y -v error -i "$SOURCE" \
  -vf "crop=720:400:0:590,lutrgb=r='if(lte(val,6),0,val)':g='if(lte(val,6),0,val)':b='if(lte(val,6),0,val)'" \
  -an \
  -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 20 \
  -movflags +faststart \
  "$DEST"

echo "écrit : $DEST"
ffprobe -v error -show_entries stream=width,height,duration,nb_frames -of default=noprint_wrappers=1 "$DEST"
