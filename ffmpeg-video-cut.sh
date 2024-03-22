#!/bin/bash
# Parts are based of output from GPT4

# How to fin the Videolength (its easier with a player ;-) )
# ffmpeg -i Input.mov -f null -
# Example Output: 
# frame=19440 fps=1571 q=-1.0 Lsize= 8852121kB time=00:10:47.99 bitrate=111908.4kbits/s speed=52.4x

# This Code will cut from the beginn of the video
# ffmpeg -ss 00:00:10 -i Input.mov -c copy Output.mov

# All Code here cut from the end!
# Example: Set Videolength
length="00:10:57" # HH:MM:SS

# Convert Videolength into seconds
IFS=: read -r hours minutes seconds <<< "$length"
sum=$((10#$hours * 3600 + 10#$minutes * 60 + 10#$seconds))

# Set seconds value to cut from the END of the Video
new_length=$((sum - 9))

# Use now ffmpeg to cut 
ffmpeg -i Import.mov -t $new_length -c copy Export.mov
