import os
import shutil

rootFrom = '/Users/mark/Pictures/微信精选'
rootTo = '/Users/mark/keeps-learning/static/gallery'
os.makedirs(rootTo, exist_ok=True)

for file_name in os.listdir(rootFrom):
    td = os.path.join(rootTo, file_name)
    os.makedirs(td, exist_ok=True)
    for root, dirs, files in os.walk(os.path.join(rootFrom, file_name)):
        if 'out' not in root:
            for file in files:
                if file not in ['.DS_Store']:
                    fp = os.path.join(root, file)
                    shutil.copy(fp, os.path.join(td, file))
