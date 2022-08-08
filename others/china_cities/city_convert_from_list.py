import json

# ref: https://blog.csdn.net/qq_33661044/article/details/78123764
data = json.load(open("city_data_raw.json"))

items = []
for province_item in data:
    item = []
    for city_item in province_item["child"]:
        province_name = province_item["name"]
        city_name = city_item["name"]
        item.append([province_name, city_name])
    items.extend(item)
            
json.dump(items, open("city_data_list.json", "w"), ensure_ascii=False)
