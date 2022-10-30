#/bin/bash
#Split Yuneec UAV Videofiles in Normal and Thermal Videos
#based on: https://stackoverflow.com/questions/5784661/how-do-you-convert-an-entire-directory-with-ffmpeg
#based on: https://emamonline.smartertrack.com/kb/a153/extract-specific-video-and-audio-tracks-using-ffmpeg.aspx
for i in *.mp4;
  do name=`echo "$i" | cut -d'.' -f1`
  echo "$name"
  ffmpeg -i "$i" -y -vcodec libx264  -movflags faststart -map 0:v:0 -pix_fmt yuv420p "${name}-normal.mp4"
  ffmpeg -i "$i" -y -vcodec libx264  -movflags faststart -map 0:v:1 -pix_fmt yuv420p "${name}-thermal.mp4"
done
