import json
import dateutil.parser
from pprint import pprint
json_data = open('/Users/changliu/Downloads/backup_mar_30_2013/Vendor.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","address",' + \
      '"phone","website","categoryId","name",' + \
      '"latitude","longitude"'
for trans in transArray:
  objectId = trans["objectId"]
  createdAt = dateutil.parser.parse(trans["createdAt"])
  updatedAt = dateutil.parser.parse(trans["updatedAt"])
  latitude = trans["location"]["latitude"]
  longitude = trans["location"]["longitude"]
  name = trans["name"]
  contactInfo = trans["contactInfo"]
  address = contactInfo[0]["info"]
  phone = contactInfo[1]["info"]
  
  if len(contactInfo) > 2:
    website = contactInfo[2]["info"]
  else:
    website = ""

  # get category objectId 
  if trans.get("category"):
    categoryId = trans["category"]["objectId"]
  else:
    categoryId = ""

  print '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
        '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + address + \
        '","' + phone + '","' + website + '","' + \
        categoryId + '","' + name + '","' + \
        str(latitude) + '","' + str(longitude) + '"'
