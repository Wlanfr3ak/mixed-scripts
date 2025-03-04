#!/bin/bash
# nano script.sh
# chmod +x script.sh
# ./script.sh
# Written with ChatGPT

# Funktion, um Dateinamen zu ersetzen
replace_in_filenames() {
  for entry in "$1"/*; do
    if [ -d "$entry" ]; then
      replace_in_filenames "$entry"
    elif [ -f "$entry" ]; then
      if [[ "$(basename "$entry")" == *1993* ]]; then
        new_entry=$(basename "$entry" | sed 's/1993/1994/g')
        mv "$entry" "$(dirname "$entry")/$new_entry"
        echo "Renamed: $entry to $(dirname "$entry")/$new_entry"
      fi
    fi
  done
}

# Verzeichnis festlegen (aktueller Pfad)
directory=$(pwd)

# Funktion aufrufen
replace_in_filenames "$directory"
