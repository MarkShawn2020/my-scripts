import requests
import os
import re
from urllib.parse import urljoin


def download_file_raw(url: str, dir_path: str):
    """[summary]

    test:
        url:  'https://raw.githubusercontent.com/GoogleChrome/chrome-extensions-samples/e716678b67fd30a5876a552b9665e9f847d6d84b/mv2-archive/extensions/speak_selection/background.js'

    Args:
        url (str): [description]
        dir_path (str): [description]
    """
    filename = os.path.basename(url)
    filepath_to_save = os.path.join(dir_path, filename)
    with requests.get(url) as s:
        with open(filepath_to_save, "wb") as f:
            f.write(s.content)
    print("downloaded file: " + filename)


def url_view2raw(url_view: str):
    """
    convert the url we see in the github to the raw mode
    """
    url_raw = re.sub(
        r"^(https://github.com)(.*?)(/tree|/blob)(.*?)$", r"https://raw.githubusercontent.com\2\4", url_view)
    return url_raw


def download_files_view(url: str, dir_path: str):
    # TODO: 暂不考虑子文件夹的爬取
    """[summary]
    test:
        url: https://github.com/GoogleChrome/chrome-extensions-samples/tree/e716678b67fd30a5876a552b9665e9f847d6d84b/mv2-archive/extensions/speak_selection

    Args:
        url (str): [description]
        dir_pat (str): [description]
    """

    if not os.path.exists(dir_path):
        os.mkdir(dir_path)

    s = '''<a class="js-navigation-open Link--primary" title="(?P<title>.*?)".*?href="(?P<url>.*?)">(?P<text>.*?)</a>'''
    t = requests.get(url).text
    for item in re.findall(s, t):
        assert item[0] == item[2], f"item: {item}"
        sub_url = urljoin(url, item[1])
        sub_url_raw = url_view2raw(sub_url)

        yield download_file_raw(sub_url_raw, dir_path)


if __name__ == '__main__':
    url = "https://github.com/GoogleChrome/chrome-extensions-samples/tree/e716678b67fd30a5876a552b9665e9f847d6d84b/mv2-archive/extensions/speak_selection"
    dir_path = os.path.join(os.path.dirname(__file__), url.split("/")[-1])
    list(download_files_view(url, dir_path))
