#!/bin/bash
# converted streaming mkv without index etc. to a stable mp4 with apple h264-hw-encoder
ffmpeg -i input.mkv -c:v h264_videotoolbox -b:v 5000k -c:a copy output.mp4
