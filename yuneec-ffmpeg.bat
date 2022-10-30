@ECHO OFF
Setlocal EnableDelayedExpansion
set INPUT=%userprofile%\Desktop\in
set OUTPUT=%userprofile%\Desktop\out
:: based on: https://superuser.com/questions/1714150/render-all-video-in-folder-with-ffmpeg
:: encode video:

for %%a in ("%INPUT%\*.*") DO ffmpeg -i "%%a" -y -vcodec libx264  -movflags faststart -map 0:v:1 -pix_fmt yuv420p "%output%\%%~na_%%03d-thermal.mp4"
for %%a in ("%INPUT%\*.*") DO ffmpeg -i "%%a" -y -vcodec libx264  -movflags faststart -map 0:v:0 -pix_fmt yuv420p "%output%\%%~na_%%03d-normal.mp4"
