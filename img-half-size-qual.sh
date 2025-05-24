#!/bin/bash
# Based on an Microsoft Copilot Output!
# Used for reduce size of Images for easy transfer and file size

# Prüfen, ob ImageMagick installiert ist
if ! command -v convert &> /dev/null; then
    echo "ImageMagick ist nicht installiert. Bitte installiere es mit 'brew install imagemagick'."
    exit 1
fi

# Alle .jpg und .jpeg Dateien im aktuellen Verzeichnis verarbeiten
for file in *.jpg *.jpeg; do
    # Prüfen, ob Dateien existieren (verhindert Fehler, falls keine .jpeg Dateien da sind)
    [ -e "$file" ] || continue

    # Neuen Dateinamen erstellen
    new_file="${file%.*}_50p90per.jpg"

    # Bildgröße um 50 % reduzieren und JPEG-Qualität auf 90 % setzen
    convert "$file" -resize 50% -quality 90 "$new_file"

    echo "Verarbeitet: $file -> $new_file"
done

echo "Fertig!"
