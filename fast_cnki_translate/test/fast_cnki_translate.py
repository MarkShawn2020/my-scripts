from pprint import pprint
import requests

# suppress warning: https://stackoverflow.com/a/44850849/9422455
requests.packages.urllib3.disable_warnings()

COOKIE = 'Cookie: SESSION=MDlmZjZhZTgtYjJhYy00MzBiLTgxNjctODQzMGQxM2IxNzc2; SID=066083; token=09ff6ae8-b2ac-430b-8167-8430d13b1776; Ecp_ClientId=2211228160403205403; Ecp_IpLoginFail=21122849.80.63.68; Ecp_lout=1'
headers_str = '''Accept: application/json, text/plain, */*
Accept-Encoding: gzip, deflate, br
Accept-Language: zh-CN,zh;q=0.9
Connection: keep-alive
DNT: 1
Host: dict.cnki.net
Referer: https://dict.cnki.net/index
sec-ch-ua: " Not A;Brand";v="99", "Chromium";v="96", "Google Chrome";v="96"
sec-ch-ua-mobile: ?0
sec-ch-ua-platform: "macOS"
Sec-Fetch-Dest: empty
Sec-Fetch-Mode: cors
Sec-Fetch-Site: same-origin
Token: 09ff6ae8-b2ac-430b-8167-8430d13b1776
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36'''

headers_dict = dict(i.split(': ', 1) for i in headers_str.splitlines())

url = 'https://dict.cnki.net/fyzs-front-api/translate/relatedliterature'

s = requests.Session()
s.headers = headers_dict

def get_translation(word: str, topic_code: str = None):
    params = {
        'words': word,
        'topicCode': topic_code,
        'pageNum': 1,
        'pageSize': 10,
    }
    try:
        res = requests.get(url, params, headers=headers_dict, verify=False)
        s = res.json()['data']
        pprint(s)
        return s
    except Exception as e:
        print(e)
        return None


def query_translate(word: str):
    url = 'https://dict.cnki.net/fyzs-front-api/translate/querytranslatedate'
    try:
        res = s.post(url, json={'words': word}, verify=False)
        pprint(res.json())
        return res.json()
    except Exception as e:
        print(e)
        return None
