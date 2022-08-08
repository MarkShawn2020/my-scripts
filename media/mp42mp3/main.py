import sys
import os
from moviepy.editor import *

fp = sys.argv[1]
print("input: " + fp)
assert fp.endswith(".mp4"), "should mp4"
out = fp.replace(".mp4", ".mp3")
video = VideoFileClip(fp)
video.audio.write_audiofile(out)
print("output: " + out)

