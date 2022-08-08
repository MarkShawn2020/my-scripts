"""
ref:
- [基础科学-杂志（期刊）-中国知网](https://mall.cnki.net/magazine/list.aspx?sort=3&cate=F1701)

"""

import json
import logging
import os
import os.path as path
import re
import time
import urllib.parse
from typing import TypedDict

import requests
from bs4 import BeautifulSoup as BS
from tqdm import tqdm

DIR_PATH = path.dirname(path.abspath(__file__))
LOG_PATH = path.join(DIR_PATH, "log.txt")
COVER_PATH = path.join(DIR_PATH, "covers")
if not path.exists(COVER_PATH):
    os.mkdir(COVER_PATH)

logging.basicConfig(filename=LOG_PATH, level=logging.INFO)


class SubjectCoverItem(TypedDict):
    subject_url: str  # 学科对应的网址
    subject_name: str  # 学科名
    journal_name: str  # 该学科下引用量最高的期刊名
    journal_cover_url: str  # 该期刊对应的封面链接


def scrape_subjects():
    def scrape_h5(h4_url):
        print('scraping h5 from h4: ' + h4_url)
        bs = BS(requests.get(h4_url).text, features="html.parser")
        for i in bs.select('.sidebar_c .side_menu:first-child h5 a'):
            yield {"url": i.get('href'), "title": i.get('title')}

    def scrape_h4(start_url):
        print('scraping h4: ' + start_url)
        bs = BS(requests.get(start_url).text, features='html.parser')
        for i in bs.select('.sidebar_c .side_menu:first-child h4 a'):
            yield from scrape_h5(i.get('href'))

    start_url = 'https://mall.cnki.net/magazine/list.aspx?cate=F1701'
    json.dump([i for i in scrape_h4(start_url)], open("subjects.json", 'w', encoding='utf-8'), ensure_ascii=False,
              indent=2)


def scrape_journals(subject_url) -> SubjectCoverItem:
    res = requests.get(subject_url)
    m = re.search(r"被引次数.*?出版时间.*?src='(.*?)'.*?<h2 title='(.*?)'", res.text, re.MULTILINE and re.DOTALL)
    journal_href, journal_name = m.groups()
    journal_cover_url = urllib.parse.urljoin(subject_url, journal_href)
    subject_name = re.search(r'<head><title>(.*?)</title>', res.text, re.M and re.S).group(1).strip().split('-')[0]
    with open(path.join(COVER_PATH, subject_name + ".png"), 'wb') as f:
        f.write(requests.get(journal_cover_url).content)
    item = SubjectCoverItem(subject_url=subject_url, subject_name=subject_name, journal_name=journal_name,
                            journal_cover_url=journal_cover_url)
    logging.info(item)
    return item


def check_journal_cover_existed(subject_name):
    s = subject_name[:-5]
    for cover_name in os.listdir(COVER_PATH):
        if cover_name.__contains__(s):
            return True
    else:
        return False


if __name__ == '__main__':
    # scrape_subjects()

    subjects = json.load(open("subjects.json", 'r'))
    bar = tqdm(range(len(subjects)))
    for i in bar:
        subject = subjects[i]
        if check_journal_cover_existed(subject['title']):
            bar.set_description(f'skipped {subject["title"]} @ {subject["url"]}')
        else:
            bar.set_description(f'scraping {subject["title"]} @ {subject["url"]}')
            # sort=3: 按被引次数排序
            scrape_journals(subject["url"] + "&sort=3")
            time.sleep(0.5)
