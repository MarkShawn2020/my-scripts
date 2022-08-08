import json
import sys
from datetime import datetime

from base import logging, LOG_PATH
from workflow import fetch_query_trans, transform

if __name__ == '__main__':
    with open(LOG_PATH, 'a') as f:
        logging.info(f"datetime: {datetime.now()}, query: {sys.argv[1:]}")
        if sys.argv.__len__() != 2:
            logging.warning("query invalid")
            exit(0)

        words = sys.argv[-1].strip()
        res = fetch_query_trans(words)
        if not res:
            logging.warning('response invalid')
            logging.warning(res)
            exit(0)

        rank_a_transformed = transform(words, res)
        logging.info(rank_a_transformed)
        # output for alfred
        print(json.dumps({"items": rank_a_transformed}, ensure_ascii=False, indent=2))
