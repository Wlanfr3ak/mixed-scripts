#!/bin/bash
#Based on https://medium.com/@sekhar.rahul/creating-a-time-lapse-video-on-the-command-line-with-ffmpeg-1a7566caf877
# Convert Files from folder to mkv Video like: https://www.youtube.com/watch?v=SkFG7Jx0svk
ffmpeg -framerate 60 -start_number 1 -i /home/user/2021-05-24/%d.jpg -s:v 3840x2160 -c:v libx265 -preset ultrafast 2021-05-24.mkv


#New Version: https://markushedlund.com/dev/gopro-ffmpeg-timelapse/

#ffmpeg -r 60 -f image2 -pattern_type glob -i '*.JPG' -s 4000x3000 -c:v mjpeg -q:v 10 ./the-timelapse-video1.mov
