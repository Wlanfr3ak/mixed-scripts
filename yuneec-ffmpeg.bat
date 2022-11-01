@ECHO OFF
Setlocal EnableDelayedExpansion

:: These Script is to convert Videofiles with two Videostreams from the Yuneec H520E to two separated Files for Thermal an Normal Stream.

:: This is the Path for the input Files
set INPUT=%userprofile%\Desktop\Umwandler\in

:: This is the Folder where the Script export the Files to
set OUTPUT=%userprofile%\Desktop\Umwandler\out

:: based on: https://superuser.com/questions/1714150/render-all-video-in-folder-with-ffmpeg
:: Thank You to the ASB Schönkirchen Drohnengruppe for your Service!
:: HowTo:
:: create folder with name "Umwandler" on Desktop, copy ffmpeg.exe in this folder
:: you get the ffmpeg.exe from the newest archive from https://www.gyan.dev/ffmpeg/builds/ 
:: create an file "umwandler.bat" and copy this script in the file an save (Notepadd++ is nice for this)
:: add to new folders: "in" and "out" at the same place
:: copy the Videofile you want to convert into the "in" Folder an start the Batch Script
:: encode video:

:: First run will export the Thermal Video Stream
for %%a in ("%INPUT%\*.*") DO ffmpeg -i "%%a" -y -vcodec libx264  -movflags faststart -map 0:v:1 -pix_fmt yuv420p "%output%\%%~na-thermal.mp4"

:: Second run will export the Normal Video Stream
for %%a in ("%INPUT%\*.*") DO ffmpeg -i "%%a" -y -vcodec libx264  -movflags faststart -map 0:v:0 -pix_fmt yuv420p "%output%\%%~na-normal.mp4"
