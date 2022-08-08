import logging
import os

#  ref: https://docs.python.org/3/library/logging.html#logging.Logger.debug
logging.basicConfig(filename=os.path.join(os.environ["MKL"], ".logs/md_upload_imgs.log"), level=logging.INFO,
                    format='%(asctime)s %(message)s')
