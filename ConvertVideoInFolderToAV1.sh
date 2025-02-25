#!/bin/bash
# Based on work with ChatGPT from OpenAI

# AV1-Encoder festlegen: libaom-av1, libsvtav1, librav1e, av1_nvenc, av1_qsv
AV1_ENCODER="libsvtav1"  # Ändere diesen Wert bei Bedarf

# Funktion zum Überprüfen, ob der Dateiname bereits 'AV1' enthält
contains_av1() {
    local filename="$1"
    if [[ "$filename" == *AV1* ]]; then
        return 0  # Enthält 'AV1'
    else
        return 1  # Enthält nicht 'AV1'
    fi
}

# Rekursiv durch alle .mp4- und .mkv-Dateien im aktuellen Verzeichnis suchen
find . -type f \( -iname "*.mp4" -o -iname "*.mkv" \) | while read -r file; do
    # Überprüfen, ob die Datei bereits 'AV1' im Namen hat
    if contains_av1 "$file"; then
        echo "Überspringe '$file', da es bereits 'AV1' enthält."
    else
        # Dateierweiterung und Basisnamen extrahieren
        extension="${file##*.}"
        basename="${file%.*}"

        # Neuer Dateiname mit 'AV1' am Ende (gleicher Ordner)
        output_file="${basename}_AV1.${extension}"

        echo "Konvertiere '$file' zu '$output_file' mit $AV1_ENCODER..."

        # FFmpeg-Befehl für die Konvertierung mit dem festgelegten Encoder
        ffmpeg -i "$file" -c:v $AV1_ENCODER -crf 30 -vsync vfr -c:a aac -b:a 160k -ac 2 -f mp4 -map_metadata 0 "$output_file"

        echo "'$file' erfolgreich zu '$output_file' konvertiert."
    fi
done
