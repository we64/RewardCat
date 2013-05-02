import json
import dateutil.parser
import datetime
from pprint import pprint
json_data = open('/Users/changliu/Downloads/parse_raw_source/Log.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","activityDescription",' + \
      '"loggedTime","discount","pointReward","redeemFlag","reward","user"'
for trans in transArray:
  objectId = trans["objectId"]
  createdAt = dateutil.parser.parse(trans["createdAt"])
  updatedAt = dateutil.parser.parse(trans["updatedAt"])
  if trans.get("activityDescription"):
    activityDescription = trans["activityDescription"]
  else:
    activityDescription = ""
  
  if trans.get("loggedTime"):
    loggedTime = trans["loggedTime"]
  else:
    loggedTime = 0
  loggedTimeToDate = datetime.date.fromtimestamp(float(loggedTime))

  if trans.get("discount"):
    discount = trans["discount"]["objectId"]
  else:
    discount = ""

  if trans.get("pointReward"):
    pointReward = trans["pointReward"]["objectId"]
  else:
    pointReward = ""

  if trans.get("reward"):
    reward = trans["reward"]["objectId"]
  else:
    reward = ""

  user = trans["user"]["objectId"]
  if trans.get("redeemFlag"):
    redeemFlag = trans["redeemFlag"]
  else:
    redeemFlag = "false"

  print '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
        '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
        activityDescription + '","' + \
        loggedTimeToDate.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
        discount + '","' + pointReward + '","' + str(redeemFlag) + '","' + \
        reward + '","' + user + '"';
