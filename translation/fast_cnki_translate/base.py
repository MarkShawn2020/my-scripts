import os
import sys
import logging

DIR_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)))
LOG_PATH = os.path.join(DIR_PATH, "log.txt")
ICONS_PATH = os.path.join(DIR_PATH, "icons")
if not os.path.exists(ICONS_PATH):
    os.mkdir(ICONS_PATH)
sys.path.insert(0, DIR_PATH)

logging.basicConfig(filename=LOG_PATH, level=logging.INFO)
