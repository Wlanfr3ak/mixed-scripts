#!/bin/bash
# Written with help from OpenAI GPT4
# Needed ffmpeg installed!
# Script captures Livestream and write it to .mkv in Folder, if disconnect etc. it will start again with new file name.

# systemd daemon for autorecording
# nano /etc/systemd/system/oksh-ripper.service
#
#[Unit]
#Description=Oksh Ripper Service
#After=network.target
#
#[Service]
#Type=simple
#Restart=always
#RestartSec=3
#User=root
#ExecStart=/path/to/script.sh
#
#[Install]
#WantedBy=multi-user.target
#
#systemctl daemon-reload
#systemctl start oksh-ripper.service
#systemctl status oksh-ripper.service
#systemctl enable oksh-ripper.service
# then the service should run for you

# Offener Kanal Kiel
STREAM_URL="http://live.oksh.de:8888/play/hls/kieltv/index.m3u8"
# Offener Kanal Flensburg
# STREAM_URL="http://live.oksh.de:8888/play/hls/flensburgtv/index.m3u8"
OUTPUT_DIR="/path/to/output/dir"

while true; do
  DATE=$(date +"%Y-%m-%d_%H-%M-%S")
  OUTPUT_FILE="${OUTPUT_DIR}/stream_${DATE}.mkv"

  ffmpeg -i "${STREAM_URL}" -c copy -f matroska "${OUTPUT_FILE}"

  # Check if FFmpeg exited with a non-zero status, indicating an error
  if [ $? -ne 0 ]; then
    echo "Stream was interrupted. Restarting..."
  else
    echo "Stream has ended."
    break
  fi
done
