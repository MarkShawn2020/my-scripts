import json

# ref: https://blog.csdn.net/qq_33661044/article/details/78123764
data = json.load(open("city_data_raw.json"))["province"]

items = []
for province_item in data:
    province_name = province_item["value"]
    item = []
    for city_item in province_item["cities"]:
        city_name = city_item["value"]
        item.append({})
    items.extend(item)
            
json.dump(items, open("city_data_list.json", "w"), ensure_ascii=False)
