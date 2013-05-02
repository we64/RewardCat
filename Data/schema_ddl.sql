drop table s_coin;
create table s_coin
(
objectid text,
createdat text,
updatedat text,
description text,
descriptionlong text,
target text,
redeemtimelength text,
vendorid text,
expiredate text,
latitude text,
longitude text
);

drop table coin;
create table coin
(
objectid text,
createdat timestamp,
updatedat timestamp,
description text,
descriptionlong text,
target integer,
redeemtimelength integer,
vendorid text,
expiredate date,
latitude float,
longitude float
);

drop table s_loyalty;
create table s_loyalty
(
objectid text,
createdat text,
updatedat text,
description text,
descriptionlong text,
scanpoint text,
target text,
redeemtimelength text,
vendorid text,
expiredate text,
latitude text,
longitude text
);

drop table loyalty;
create table loyalty
(
objectid text,
createdat timestamp,
updatedat timestamp,
description text,
descriptionlong text,
scanpoint integer,
target integer,
redeemtimelength integer,
vendorid text,
expiredate date,
latitude float,
longitude float
);

drop table s_discounts;
create table s_discounts
(
objectid text,
createdat text,
updatedat text,
description text,
descriptionlong text,
discounttag text,
discounttype text,
vendorid text,
expiredate text,
latitude text,
longitude text
);

drop table discounts;
create table discounts
(
objectid text,
createdat timestamp,
updatedat timestamp,
description text,
descriptionlong text,
discounttag text,
discounttype text,
vendorid text,
expiredate date,
latitude float,
longitude float
);

drop table s_vendors;
create table s_vendors
(
objectid text,
createdat text,
updatedat text,
address text,
phone text,
website text,
categoryid text,
name text,
latitude text,
longitude text
);

drop table vendors;
create table vendors
(
objectid text,
createdat timestamp,
updatedat timestamp,
address text,
phone text,
website text,
categoryid text,
name text,
latitude float,
longitude float
);

drop table s_transactions;
create table s_transactions
(
objectid text,
createdat text,
updatedat text,
userid text,
activitytype text,
coinchangeamt text,
rewardid text,
pointrewardid text,
rewarddescription text,
rewardlongdescription text,
rewardtotalcountafteraction text,
vendorid text
);

drop table transactions;
create table transactions
(
objectid text,
createdat timestamp,
updatedat timestamp,
userid text,
activitytype text,
coinchangeamt integer,
rewardid text,
pointrewardid text,
rewarddescription text,
rewardlongdescription text,
rewardtotalcountafteraction integer,
vendorid text
);

drop table black_listed_users;
create table black_listed_users
(
objectid text,
username text,
facebookid bigint,
name text
);

drop table users;
create table users
(
objectid text,
createdat timestamp,
updatedat timestamp,
facebookid bigint,
username text,
registereduserflag boolean,
facebookuserflag boolean,
birthday date,
gender text,
name text,
rewardcatpoints integer,
numofinvitedfriends integer,
uuid text
);

drop table s_users;
create table s_users
(
objectid text,
createdat text,
updatedat text,
facebookid text,
username text,
registereduserflag text,
facebookuserflag text,
birthday text,
gender text,
name text,
rewardcatpoints text,
numofinvitedfriends text,
uuid text
);

drop table s_logs;
create table s_logs
(
objectid text,
createdat text,
updatedat text,
activitydescription text,
loggedTime text,
discount text,
pointreward text,
redeemflag text,
reward text,
userid text
);

drop table logs;
create table logs
(
objectid text,
createdat timestamp,
updatedat timestamp,
activitydescription text,
loggedTime timestamp,
discount text,
pointreward text,
redeemflag boolean,
reward text,
userid text
);