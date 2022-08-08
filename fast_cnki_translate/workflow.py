from collections import defaultdict
from typing import TypedDict, Dict, List

import requests

import os
from base import logging
from gen_num import gen_num, get_icon_path
from settings import TOKEN, UA

# Do not use SortedDict, since it's not Chinese sort support, and seems only can sort by keys
# from sortedcontainers import SortedDict

# suppress warning: https://stackoverflow.com/a/44850849/9422455
requests.packages.urllib3.disable_warnings()

s = requests.Session()
s.headers = {"Token": TOKEN, "User-Agent": UA}
s.verify = False


def fetch_query_trans(word: str):
    """
    输入一个中文，获得翻译的英文候选列表信息
    Args:
        word ():

    Returns:

    """
    url = 'https://dict.cnki.net/fyzs-front-api/translate/querytranslatedate'
    try:
        return s.post(url, json={'words': word}).json()
    except Exception as e:
        logging.warning(e)
        return None


def fetch_get_trans(word: str, topic_code: str = None):
    """
    TODO: 输入一个英文，获得关于这个英文的例句信息
    Args:
        word ():
        topic_code ():

    Returns:

    """
    url = 'https://dict.cnki.net/fyzs-front-api/translate/relatedliterature'
    params = {
        'words': word,
        'topicCode': topic_code,
        'pageNum': 1,
        'pageSize': 10,
    }
    try:
        return s.get(url, params=params).json()
    except Exception as e:
        logging.warning(e)
        return None


def transform(words, res):
    class InnerKeyInfo(TypedDict):
        topicCode: str  # 学科编码
        name: str  # 对应翻译
        wordFreq: int  # 该学科该词汇出现频率

    class OutKeyInfo(TypedDict):
        wordCnt: int  # 该学科（或全部）该搜索词对应的翻译条目数
        wordFreq: int  # 该学科（或全部）该搜索词对应翻译出现的总频率
        dicts: Dict[str, List[InnerKeyInfo]]  # 该学科下各个翻译词的具体信息

    def _safe_get(data, key, default):
        return data.get(key) or default

    def transform_item(key_info: InnerKeyInfo):
        return {
            "name": key_info['name'],
            "freq": key_info['wordFreq'],
            "details": data[key_info['name']]
        }

    def output_item(item, use_num=False):
        top1_topic_name = item['details'][0][0]
        details_info = " ".join([f"{i[0]}({i[1]})" for i in item["details"]])

        if use_num:
            gen_num(item['freq'])
            icon_path = get_icon_path(item['freq'])
        else:
            icon_path = os.path.join(
                os.environ["MKL"],   f'mark_scripts/fast_cnki_translate/scrape_covers/covers/{top1_topic_name}.png')
        logging.info({"icon_path": icon_path})
        return {
            "uid": item["name"],
            "autocomplete": item["name"],
            "title": item["name"],
            "subtitle": details_info,
            # ref: https://www.alfredforum.com/topic/14230-solved-show-correct-icons-in-script-filter/?do=findComment&comment=72851
            "icon": {
                "path": icon_path
            }
        }

    raw_data = res['data']['dictsVos']

    # 先提取汇总的数据
    top_trans_all = raw_data[0]['adictsVo']['dicts'][words][:10]
    logging.info({"top_trans_all": top_trans_all})

    # 再提取分学科数据
    data = defaultdict(dict)
    for item in raw_data[1:]:
        topic = item.get('topicName', None)
        for (k, d) in [('adictsVo', {}), ('dicts', {}), (words, [])]:
            item = _safe_get(item, k, d)
        for item2 in item:
            key = item2['name']
            freq = item2['wordFreq']
            data[key][topic] = freq
    for k, v in data.items():
        data[k] = sorted(v.items(), key=lambda x: -x[1])[:3]

    return [output_item(transform_item(key_info)) for key_info in top_trans_all]
