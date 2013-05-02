import json
import datetime
import dateutil.parser
from pprint import pprint
json_data = open('/Users/changliu/Downloads/parse_raw_source/_User.json')

data = json.load(json_data)
json_data.close()

transArray = data["results"]
print '"objectId","createdAt","updatedAt","facebookId","username",' + \
      '"registeredUserFlag","facebookUserFlag","birthday","gender",' + \
      '"name","rewardcatPoints","numOfInvitedFriends","uuid"'
for trans in transArray:
  objectId = trans["objectId"]
  createdAt = dateutil.parser.parse(trans["createdAt"])
  updatedAt = dateutil.parser.parse(trans["updatedAt"])
  username = trans["username"]
  if trans.get("uuid"):
    uuid = trans["uuid"]
  else:
    uuid = ""

  if username == uuid:
    registeredUserFlag = 'no'
  else:
    registeredUserFlag = 'yes'

  if trans.get("authData"):
    facebookUserFlag = 'yes'
    facebookId = trans["authData"]["facebook"]["id"]
  else:
    facebookUserFlag = 'no'
    facebookId = ""

  if trans.get("birthday"):
    birthday = dateutil.parser.parse(trans["birthday"]["iso"]).strftime('%m/%d/%Y')
  elif trans.get("additional"):
    birthday = datetime.datetime.strptime(trans["additional"],"%B %d, %Y").date().strftime('%m/%d/%Y')
  else:
    birthday = ""

  if trans.get("gender"):
    gender = trans["gender"]
  else:
    gender = ""

  if trans.get("name"):
    name = trans["name"]
  else:
    name = ""

  if trans.get("rewardcatPoints"):
    rewardcatPoints = trans["rewardcatPoints"]
  else:
    rewardcatPoints = ""

  if trans.get("invitedFBFriends"):
    invitedFriends = trans["invitedFBFriends"]
    numOfInvitedFriends = len(invitedFriends)
  else:
    numOfInvitedFriends = 0
 
  output = '"' + objectId + '","' + createdAt.strftime('%m/%d/%Y %H:%M:%S') + \
        '","' + updatedAt.strftime('%m/%d/%Y %H:%M:%S') + '","' + \
        facebookId + '","' + username + '","' + registeredUserFlag + '","' + \
        facebookUserFlag + '","' + birthday + '","' + gender + \
        '","' + name + '","' + str(rewardcatPoints) + '","' + \
        str(numOfInvitedFriends) + '","' + uuid + '"'
  print output.encode('utf-8')
