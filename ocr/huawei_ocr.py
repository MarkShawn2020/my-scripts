 # coding: utf-8
 # pip install huaweicloudsdkocr

from huaweicloudsdkcore.auth.credentials import BasicCredentials
from huaweicloudsdkocr.v1.region.ocr_region import OcrRegion
from huaweicloudsdkcore.exceptions import exceptions
from huaweicloudsdkocr.v1 import *
import os
import base64
import sys
import pathlib
import json

if __name__ == "__main__":
    ak = os.getenv("HWCLOUD_AK")
    sk = os.getenv("HWCLOUD_SK")
    area = "cn-north-4"

    img_fp = sys.argv[1] # "/Users/mark/Pictures/商务-特殊物品发货记录.png"
    
    f = open(img_fp, "rb")
    img_base64 = base64.b64encode(f.read())
    f.close()

    credentials = BasicCredentials(ak, sk) \

    client = OcrClient.new_builder() \
        .with_credentials(credentials) \
        .with_region(OcrRegion.value_of(area)) \
        .build()

    try:
        request = RecognizeGeneralTextRequest()
        request.body = GeneralTextRequestBody(
            image=img_base64
        )
        response = client.recognize_general_text(request)
        print(response)
        fn = img_fp.rsplit(".", 1)[0] + "_ocr"
        # json.dump(response.to_json_object(), open(fn + ".json", "w"), ensure_ascii=False, indent=2)
        with open(fn + ".txt", "w") as f:
            f.write("\n".join([i.words for i in response.result.words_block_list]))
        
    except exceptions.ClientRequestException as e:
        print(e.status_code)
        print(e.request_id)
        print(e.error_code)
        print(e.error_msg)