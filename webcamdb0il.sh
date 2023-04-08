#!/bin/bash
# Dieses Script fragt ein Webcam Bild ab und generiert daraus ein neues inklusive Zeistempel unter Wetter usw.
# Outputergebnis des Scriptes: https://db0ilwebcam.dl9fhx.de/webcam.jpg
# Script wurde mit Hilfe von ChatGPT v4 und etwas Try and Error erstellt
# ToDo: Alles via PHP und nur noch auf dem Webspace laufen lassen


# Funktion zum Überprüfen, ob ein Befehl verfügbar ist
check_command() {
    if ! command -v "$1" &> /dev/null; then
        echo "Fehler: '$1' ist nicht installiert. Bitte installiere '$1' und versuche es erneut."
        exit 1
    fi
}

# Überprüfe die Abhängigkeiten
check_command wget
check_command curl
check_command convert
check_command jq
check_command sftp
check_command sshpass

# Setze URL und Ausgabedateinamen
url="http://IPv4:Port/axis-cgi/jpg/image.cgi?camera=1&width=3840"
output_file="webcam.jpg"

# Lade das Bild herunter
wget -O temp.jpg "$url" || curl -o temp.jpg "$url"

# Setze OpenWeatherMap API-Schlüssel und Kiel-Koordinaten
api_key="APIKEY"
latitude="54.3233"
longitude="10.1228"

# Hole die aktuellen Wetterdaten von Kiel
weather_data=$(curl -s "https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$api_key&units=metric&lang=en")
temperature=$(echo "$weather_data" | jq -r '.main.temp')
humidity=$(echo "$weather_data" | jq -r '.main.humidity')
description=$(echo "$weather_data" | jq -r '.weather[0].description')
windspeed=$(echo "$weather_data" | jq -r '.wind.speed')
winddeg=$(echo "$weather_data" | jq -r '.wind.deg')

# Erstelle den Wettertext
weather_text="HAMRADIO-REPEATER DB0IL KIEL GERMANY: $temperature°C, $description, Humidity: $humidity%, Wind: $windspeed m/s $winddeg°"

# Füge Datum und Uhrzeit hinzu
kiel_time=$(TZ="Europe/Berlin" date "+%H:%M %Z")
utc_time=$(date -u "+%Y-%m-%d %H:%M %Z")
current_date_time="$utc_time | $kiel_time"

#current_date_time=$(date "+%Y-%m-%d %H:%M %Z (Local: %H:%M %Z)")
pointsize=55
textcolor="black"
bgcolor="rgba(128, 128, 128, 0.5)"
padding=10

# Ermittle die Größe des Textes und des Wettertexts
date_size=$(convert -font "Arial" -pointsize "$pointsize" label:"$current_date_time" -format "%wx%h" info:)
weather_size=$(convert -font "Arial" -pointsize "$pointsize" label:"$weather_text" -format "%wx%h" info:)

date_width=${date_size%x*}
date_height=${date_size#*x}
weather_width=${weather_size%x*}
weather_height=${weather_size#*x}

# Erstelle halbtransparente graue Hintergrundkästen
convert -size "${date_width}x${date_height}" xc:"$bgcolor" -gravity Center -extent "$(($date_width+2*$padding))x$(($date_height+2*$padding))" temp_date_background.png
convert -size "${weather_width}x${weather_height}" xc:"$bgcolor" -gravity Center -extent "$(($weather_width+2*$padding))x$(($weather_height+2*$padding))" temp_weather_background.png

# Kombiniere Bild, Hintergründe und Texte
convert temp.jpg temp_date_background.png -gravity SouthWest -geometry +20+20 -composite -pointsize "$pointsize" -fill "$textcolor" -annotate +$(($padding+20))+$(($padding+20)) "$current_date_time" temp_result.jpg
convert temp_result.jpg temp_weather_background.png -gravity SouthEast -geometry +20+20 -composite -pointsize "$pointsize" -fill "$textcolor" -annotate +$(($padding+20))+$(($padding+20)) "$weather_text" "$output_file"

# Entferne temporäre Dateien
rm temp.jpg
rm temp_date_background.png
rm temp_weather_background.png
rm temp_result.jpg

# Setze SFTP-Anmeldedaten und den entfernten Serverpfad
sftp_username="username"
sftp_password="password"
sftp_host="hostname"
remote_path="/"

# Hochladen der Datei mit SFTP
echo "Datei wird hochgeladen..."
sshpass -p "$sftp_password" sftp -oBatchMode=no -b - "$sftp_username@$sftp_host" <<EOF
put $output_file
bye
EOF

echo "Datei wurde erfolgreich hochgeladen."
echo "Bild erstellt und gespeichert als: $output_file"
