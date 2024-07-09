ffmpeg -i summary_6.png -vf palettegen palette.png
ffmpeg -framerate 1 -i summary_%d.png -i palette.png -lavfi paletteuse summary_ffmpeg.gif