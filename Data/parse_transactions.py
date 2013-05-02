import json
import dateutil.parser
from pprint import pprint
json_data = open('/Users/changliu/Downloads/parse_raw_source/Transaction.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","userId",' + \
      '"activityType","coinChangeAmt","rewardId","pointRewardId",' + \
      '"rewardDescription","rewardLongDescription",' + \
      '"rewardTotalCountAfterAction","vendorId"'
for trans in transArray:
  objectId = trans["objectId"]
  activityType = trans["activityType"]
  createdAt = dateutil.parser.parse(trans["createdAt"])
  updatedAt = dateutil.parser.parse(trans["updatedAt"])
  
  # get userId
  if trans.get("user"):
    userId = trans["user"]["objectId"]
  else:
    userId = ""

  # get rewardcat coins change
  if trans.get("rewardcatPointsDelta"):
    rcCoinsDelta = trans["rewardcatPointsDelta"]
  else:
    rcCoinsDelta = ""
  
  # get reward program objectId 
  if trans.get("reward"):
    rewardId = trans["reward"]["objectId"]
  else:
    rewardId = ""

  # get pointReward program objectId
  if trans.get("pointReward"):
    pointRewardId = trans["pointReward"]["objectId"]
  else:
    pointRewardId = ""

  if trans.get("rewardDescription"):
    rewardDesc = trans["rewardDescription"]
  else:
    rewardDesc = ""

  if trans.get("rewardTotalCountAfterAction"):
    rewardTotalCountAfterAction = trans["rewardTotalCountAfterAction"]
  else:
    rewardTotalCountAfterAction = ""

  # get reward program long description
  if trans.get("rewardLongDescription"):
    rewardLongDesc = trans["rewardLongDescription"]
  else:
    rewardLongDesc = ""
  
  # get vendor objectId
  if trans.get("vendor"):
    vendorId = trans["vendor"]["objectId"]
  else:
    vendorId = ""

  print '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
        '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + userId + \
        '","' + activityType + '","' + str(rcCoinsDelta) + '","' + \
        rewardId + '","' + pointRewardId + '","' + \
        rewardDesc + '","' + rewardLongDesc + '","' + \
        str(rewardTotalCountAfterAction) + '","' + vendorId + '"'
