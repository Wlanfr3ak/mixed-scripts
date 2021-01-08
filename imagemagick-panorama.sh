# Cut one Images in 4 same size pieces
convert -crop 50%x50% IMG_3835_stitch4.jpg stitch4.jpg
# Source: https://dev.to/ko31/using-imagemagick-to-easily-split-an-image-file-13hb

stitch4-0.jpg = topleft
stitch4-1.jpg = topright
stitch4-2.jpg = bottomleft
stitch4-3.jpg = bottomright

# Edited with same Luminar4 Presets
# New Filenames:
stitch4-0.jpg -> stitch4-0-1.jpg
stitch4-1.jpg -> stitch4-1-1.jpg
stitch4-2.jpg -> stitch4-2-1.jpg
stitch4-3.jpg -> stitch4-3-1.jpg

cp stitch4-0-1.jpg h1.jpg
cp stitch4-1-1.jpg h2.jpg
cp stitch4-2-1.jpg v1.jpg
cp stitch4-3-1.jpg v2.jpg

# Stitch them Back to one Image
# Source: https://stackoverflow.com/questions/20737061/merge-images-side-by-sidehorizontally
convert +append *.png out.png # horizontally
convert -append *.png out.png # vertically

#so:
convert +append h*.jpg X1.jpg
convert +append v*.jpg X2.jpg
convert -append X*.jpg output.jpg

# Clean Picture a little bit under 100 m for wikimedia ;-)
convert -resize 90% output.jpg output90.jpg # 399,5mb to ---- it runs now more than 30 min....
# edit later again
