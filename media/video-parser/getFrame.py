import os
import cv2


vidcap = cv2.VideoCapture('/Volumes/Disk1/南川骑行川藏线/素材/GoPro/0819-邓巴村-左贡/GX020592.MP4')

DIM = (640, 360)


def getFrame(mm):
    vidcap.set(cv2.CAP_PROP_POS_MSEC, mm)
    has_frame, image = vidcap.read()
    if has_frame:
        image = cv2.resize(image, DIM)
        img_out_fn = f"img-{mm}.jpg"
        print("writing to: ", img_out_fn)
        cv2.imwrite(img_out_fn, image)  # save frame as JPG file
    else:
        print("NO FRAME")
    return has_frame


for sec in range(0, 5):
    getFrame(sec * 5000)
