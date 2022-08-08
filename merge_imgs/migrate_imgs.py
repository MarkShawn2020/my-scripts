import os
import re

PROJECT_PATH = os.environ["MKL"]


def traverse_dir(dir_path: str, imgs_dir_name=".imgs"):
    print("")
    #######################
    # if has .imgs, then traverse each .md file, and re-replace
    #######################
    file_names = os.listdir(dir_path)

    for file_name in os.listdir(dir_path):
        file_path = os.path.join(dir_path, file_name)

        if os.path.isdir(file_path):
            if file_name == imgs_dir_name:
                # TODO: replace all files under cur dir_path
                pass
            else:
                traverse_dir(file_path, imgs_dir_name)
