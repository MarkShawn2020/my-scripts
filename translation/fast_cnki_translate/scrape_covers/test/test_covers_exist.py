import re
import os

COVER_PATH = os.path.join(
    os.environ["MKL"], "mark_scripts/fast_cnki_translate/scrape_covers/covers")

s = "全部(40)无线电电子学(18)计算机软件及计算机应用(14)自动化技术(12)电力工业(10)互联网技术(9)电信技术(8)金属学及金属工艺(8)机械工业(7)物理学(6)无机化工(6)有机化工(5)计算机硬件技术(5)工业经济(4)工业通用技术及设备(4)化学(4)武器工业与军事技术(4)核科学技术(3)企业经济(3)档案及博物馆(3)数学(3)动力工程(3)环境科学与资源利用(3)建筑科学与工程(3)汽车工业(3)公路与水路运输(3)材料科学(3)航空航天科学与工程(3)仪器仪表工业(3)科学研究管理(2)石油天然气工业(2)自然地理学和测绘学(2)宏观经济管理与可持续发展(2)自然科学理论与方法(2)铁路运输(2)管理学(1)肿瘤学(1)药学(1)新闻与传媒(1)临床医学(1)高等教育(1)图书情报与数字图书馆(1)外科学(1)气象学(1)燃料化工(1)一般化学工业(1)力学(1)教育理论与教育管理(1)生物医学工程(1)轻工业手工业(1)地球物理学(1)船舶工业(1)海洋学(1)冶金工业(1)外国语言文字(0)畜牧与动物医学(0)"

subjects = re.sub(r'[0-9()]+', ' ', s).split(" ")[1:-1]


def check_journal_cover_existed(subject_name):
    s = subject_name
    for cover_name in os.listdir(COVER_PATH):
        if cover_name.__contains__(s):
            return True
    else:
        return False


for subject in subjects:
    assert check_journal_cover_existed(subject)
