#!/bin/bash
# Based on an Microsoft Copilot Output and Windsurf IDE with AI/KI Technology!
# Used for reduce size of Images for easy transfer and file size for Media Team Mission of Volunteering Helporganizations
# based on macos with brew software manager, easy to adopt with *nix

# Arrays für Dateien die bereits existieren
declare -a existing_files
declare -a existing_sources
declare -a existing_targets

# Prüfen, ob ImageMagick installiert ist
if ! command -v convert &> /dev/null; then
    echo "ImageMagick ist nicht installiert. Bitte installiere es mit 'brew install imagemagick'."
    exit 1
fi

# Prüfen, ob exiftool installiert ist
if ! command -v exiftool &> /dev/null; then
    echo "exiftool ist nicht installiert. Bitte installiere es mit 'brew install exiftool'."
    exit 1
fi

# Einsatzname vom Benutzer abfragen
echo "Bitte geben Sie den Einsatznamen ein:"
read einsatzname

# Ersetze Leerzeichen durch Bindestriche im Einsatznamen
einsatzname=$(echo "$einsatzname" | tr ' ' '-')

# Alle .jpg und .jpeg Dateien im aktuellen Verzeichnis verarbeiten
for file in *.jpg *.jpeg; do
    # Prüfen, ob Dateien existieren (verhindert Fehler, falls keine .jpeg Dateien da sind)
    [ -e "$file" ] || continue
    
    # Extrahiere die 4-stellige Nummer aus dem Dateinamen
    # Suche nach einem Muster von 4 aufeinanderfolgenden Ziffern im Dateinamen
    nummer=$(echo "$file" | grep -o -E '[0-9]{4}' | head -1)
    
    # Falls keine 4-stellige Nummer gefunden wurde, verwende '0000'
    if [ -z "$nummer" ]; then
        nummer="0000"
    fi
    
    # Extrahiere das Aufnahmedatum aus den EXIF-Metadaten
    photo_date=$(exiftool -DateTimeOriginal -d "%Y-%m-%d" -S -s "$file")
    
    # Falls kein Datum in den EXIF-Daten gefunden wurde, versuche andere Felder
    if [ -z "$photo_date" ]; then
        photo_date=$(exiftool -CreateDate -d "%Y-%m-%d" -S -s "$file")
    fi
    
    # Falls immer noch kein Datum gefunden wurde, verwende das Dateiänderungsdatum
    if [ -z "$photo_date" ]; then
        photo_date=$(date -r "$file" +"%Y-%m-%d")
    fi
    
    # Neuen Dateinamen erstellen im Format: YYYY-MM-DD-XXXX-Einsatzname-THW-Fabian-Horst-50per90qual.jpg
    new_file="${photo_date}-${nummer}-${einsatzname}-THW-Fabian-Horst-50per90qual.jpg"

    # Prüfe, ob die Zieldatei bereits existiert
    if [ -e "$new_file" ]; then
        echo "Datei existiert bereits, wird in die Warteschlange gestellt: $file -> $new_file"
        # Speichere die Informationen für spätere Verarbeitung
        existing_files+=($file)
        existing_sources+=($file)
        existing_targets+=($new_file)
    else
        # Bildgröße um 50 % reduzieren und JPEG-Qualität auf 90 % setzen
        # Verwende 'magick' statt dem veralteten 'convert'
        magick "$file" -resize 50% -quality 90 "$new_file"
        
        # Falls 'magick' fehlschlägt, versuche als Fallback 'convert'
        if [ $? -ne 0 ]; then
            echo "Warnung: 'magick' fehlgeschlagen, versuche 'convert' als Fallback..."
            convert "$file" -resize 50% -quality 90 "$new_file"
        fi

        echo "Verarbeitet: $file -> $new_file"
    fi
done

# Prüfe, ob es Dateien gibt, die bereits existierten
if [ ${#existing_files[@]} -gt 0 ]; then
    echo ""
    echo "Es gibt ${#existing_files[@]} Dateien, die nicht verarbeitet wurden, weil die Zieldateien bereits existieren:"
    for i in "${!existing_files[@]}"; do
        echo "${i+1}. ${existing_sources[$i]} -> ${existing_targets[$i]}"
    done
    
    echo ""
    echo "Möchten Sie diese Dateien mit hochgezählten Dateinamen verarbeiten? (j/n)"
    read answer
    
    if [[ "$answer" =~ ^[jJ] ]]; then
        for i in "${!existing_files[@]}"; do
            source_file=${existing_sources[$i]}
            target_file=${existing_targets[$i]}
            base_name=$(basename "${target_file%.*}")
            extension="${target_file##*.}"
            
            # Suche nach einem verfügbaren Dateinamen mit Nummernzusatz
            counter=1
            while [ -e "${base_name}-${counter}.${extension}" ]; do
                counter=$((counter+1))
            done
            
            new_target="${base_name}-${counter}.${extension}"
            
            # Verarbeite die Datei mit dem neuen Dateinamen
            magick "$source_file" -resize 50% -quality 90 "$new_target"
            
            # Falls 'magick' fehlschlägt, versuche als Fallback 'convert'
            if [ $? -ne 0 ]; then
                echo "Warnung: 'magick' fehlgeschlagen, versuche 'convert' als Fallback..."
                convert "$source_file" -resize 50% -quality 90 "$new_target"
            fi
            
            echo "Verarbeitet (mit hochgezähltem Namen): $source_file -> $new_target"
        done
    else
        echo "Die Dateien wurden nicht verarbeitet."
    fi
fi

echo "Fertig!"
