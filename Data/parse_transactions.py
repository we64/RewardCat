import json
from pprint import pprint
json_data = open('/Users/changliu/Downloads/march052013_backup/Transaction.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"userId","activityType","rcCoinsDelta","rewardId","rewardLongDesc","vendorId"'
for trans in transArray:
  if trans.get("user"):
    userId = trans["user"]["objectId"]
  else:
    userId = ""
    print trans
  activityType = trans["activityType"]
  if trans.get("rewardcatPointsDelta"):
    rcCoinsDelta = trans["rewardcatPointsDelta"]
  else:
    rcCoinsDelta = "" 
  if trans.get("reward"):
    rewardId = trans["reward"]["objectId"]
  else:
    rewardId = ""
  if trans.get("rewardLongDesc"):
    rewardLongDesc = trans["rewardLongDescription"]
  else:
    rewardLongDesc = ""
  if trans.get("vendor"):
    vendorId = trans["vendor"]["objectId"]
  else:
    vendorId = ""

  print '"' + userId + '","' + activityType + '","' + str(rcCoinsDelta) + '","' + rewardId + '","' + rewardLongDesc + '","' + vendorId+ '"'
