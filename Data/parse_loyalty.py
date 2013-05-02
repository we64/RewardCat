import json
import dateutil.parser
from pprint import pprint
json_data = open('/Users/changliu/Downloads/parse_raw_source/Reward.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","description",' + \
      '"descriptionLong","scanPoint","target","redeemTimeLength",' + \
      '"vendorId","expireDate","latitude","longitude"'
for trans in transArray:
  objectId = trans["objectId"]
  createdAt = dateutil.parser.parse(trans["createdAt"])
  updatedAt = dateutil.parser.parse(trans["updatedAt"])
  latitude = trans["location"]["latitude"]
  longitude = trans["location"]["longitude"]
  vendorId = trans["vendor"]["objectId"]
  description = trans["description"]["description"]
  descriptionLong = trans["description"]["longDescription"]
  scanPoint = trans["scanPoint"]
  target = trans["target"]
  redeemTimeLength = trans["redeemTimeLength"]
  if trans.get("expireDate"):
    expireDate = dateutil.parser.parse(trans["expireDate"]["iso"])
  else:
    expireDate = dateutil.parser.parse("1999-01-01T15:59:00.000Z")

  if scanPoint > 0:
    print '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
          '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
          description + '","' + descriptionLong + '","' + \
          str(scanPoint) + '","' + str(target) + '","' + \
          str(redeemTimeLength) + '","' + vendorId + '","' + \
          expireDate.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
          str(latitude) + '","' + str(longitude) + '"'
