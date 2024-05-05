#!/bin/bash
# Created with ChatGPT4
# apt-get install wget curl xmlstarlet

# URL des RSS-Feeds
RSS_FEED="https://feg-kiel.de/feed/podcast"

# Verzeichnis, in dem die Dateien gespeichert werden sollen
BASE_DIR="/root/fegkiel-rss-podcast-backup"

# RSS-Feed herunterladen
curl -s "$RSS_FEED" > feed.xml

# Anzahl der Einträge im Feed herausfinden
ENTRIES=$(xmlstarlet sel -t -v "count(/rss/channel/item)" feed.xml)

# Jeden Eintrag durchgehen
for ((i=1; i<=ENTRIES; i++))
do
  # Veröffentlichungsdatum extrahieren und formatieren
  DATE=$(xmlstarlet sel -t -m "/rss/channel/item[$i]" -v "pubDate" -n feed.xml)
  FORMATTED_DATE=$(date -d "$DATE" +'%Y-%m-%d')

  # Ordner erstellen, wenn nicht vorhanden
  mkdir -p "$BASE_DIR/$FORMATTED_DATE"

  # Beschreibungstext speichern
  DESCRIPTION=$(xmlstarlet sel -t -m "/rss/channel/item[$i]" -v "description" -n feed.xml)
  echo "$DESCRIPTION" > "$BASE_DIR/$FORMATTED_DATE/description.txt"

  # Bilder und andere Medien aus dem content:encoded extrahieren und herunterladen
  CONTENT=$(xmlstarlet sel -t -m "/rss/channel/item[$i]/content:encoded" -v "." -n feed.xml)
  echo "$CONTENT" > "$BASE_DIR/$FORMATTED_DATE/content.html"

  # Extrahiere alle src-URLs aus content:encoded und lade sie herunter
  echo "$CONTENT" | grep -o 'src="[^"]*' | grep -o 'http[^"]*' | while read -r SRC_LINK
  do
    SRC_FILE=$(basename "$SRC_LINK")
    wget -P "$BASE_DIR/$FORMATTED_DATE" "$SRC_LINK"
  done

  # MP3-Dateien herunterladen
  xmlstarlet sel -t -m "/rss/channel/item[$i]/enclosure" -v "@url" -n feed.xml | while read -r LINK
  do
    FILE_NAME=$(basename "$LINK")
    if [ ! -f "$BASE_DIR/$FORMATTED_DATE/$FILE_NAME" ]; then
      wget -P "$BASE_DIR/$FORMATTED_DATE" "$LINK"
    fi
  done
done

# Aufräumen
rm feed.xml
