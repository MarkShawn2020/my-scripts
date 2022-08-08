"""
ref:
- [Create images with Python PIL and Pillow and write text on them](https://code-maven.com/create-images-with-python-pil-pillow)
- [Text anchors — Pillow (PIL Fork) 8.4.0 documentation](https://pillow.readthedocs.io/en/stable/handbook/text-anchors.html#text-anchors)
"""

import math
import os

from PIL import Image, ImageDraw, ImageFont

from base import ICONS_PATH, logging

# Icon size, 256  recommended officially
# ref: https://alfred-workflow.readthedocs.io/en/latest/xml_format.html#icon
SIZE = 256

# Max number show in the icon, better for a four-digit number
MAX_N = 9999


def exp_conversion(n: int) -> int:
    """
    shadow a number from 0-9999 to 0-255
    0 -> 0
    9999 -> 255
    log_10000(x+1) * 255

    """
    return int(math.log(n + 1, MAX_N + 1) * 255)


def int2str(n: int) -> str:
    n = min(n, MAX_N)
    return f'{n:04}'


def get_icon_path(n: int) -> str:
    return os.path.join(ICONS_PATH, int2str(n) + '.png')


def gen_num(n: int):
    s = int2str(n)

    img = Image.new('RGB', (SIZE, SIZE), color=(255, 255, 255))
    d = ImageDraw.Draw(img)
    fnt = ImageFont.truetype('/Library/Fonts/Arial.ttf', int(SIZE / 2))
    d.multiline_text(
        xy=(SIZE / 2, SIZE / 2),
        text=s[:2] + "\n" + s[2:],
        fill=(exp_conversion(n), 0, 0),
        font=fnt,
        align='center',
        anchor='mm'
    )

    s = get_icon_path(n)
    img.save(s)
    logging.info('generated icon: ' + s)
    # img.show()


if __name__ == '__main__':
    # for i in range(0, 10000):
    gen_num(520)
