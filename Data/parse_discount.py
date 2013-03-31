import json
import dateutil.parser
from pprint import pprint
json_data = open('/Users/changliu/Downloads/backup_mar_30_2013/Discount.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","description",' + \
      '"descriptionLong","discountTag","discountType",' + \
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
  discountTag = trans["description"]["discountTag"]
  discountType = trans["discountType"]
  expireDate = dateutil.parser.parse(trans["expireDate"]["iso"])

  print '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
        '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
        description + '","' + descriptionLong + '","' + \
        discountTag + '","' + str(discountType) + '","' + \
        vendorId + '","' + \
        expireDate.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
        str(latitude) + '","' + str(longitude) + '"'
