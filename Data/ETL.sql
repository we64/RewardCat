/*
-- optional stuff
scp *.csv tony@66.175.217.202:/home/tony/.

truncate table black_listed_users;
insert into black_listed_users
select objectid,username,facebookid,name from users where name like 'Garry%' or name like 'Grace%' or name like 'Sha Luo%' or name like 'Fancy Fan%' or name like 'Tony Zh%' or name like '%Han' or name like 'Hao%Chen' or name like 'Hao X%' or name like 'Victor N%' or username like 'test' or name like 'Momo%';
*/

truncate table s_coin;
truncate table coin;
COPY s_coin FROM '/home/tony/coin.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into coin
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
description,
descriptionlong,
target::integer,
redeemtimelength::integer,
vendorid,
to_date(expiredate, 'MM/DD/YYYY'),
latitude::float,
longitude::float
from s_coin
;

truncate table loyalty;
truncate table s_loyalty;
COPY s_loyalty FROM '/home/tony/loyalty.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into loyalty
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
description,
descriptionlong,
scanpoint::integer,
target::integer,
redeemtimelength::integer,
vendorid,
to_date(expiredate, 'MM/DD/YYYY'),
latitude::float,
longitude::float
from s_loyalty
;

truncate table s_discounts;
truncate table discounts;
COPY s_discounts FROM '/home/tony/discount.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into discounts
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
description,
descriptionlong,
discounttag,
discounttype,
vendorid,
to_date(expiredate, 'MM/DD/YYYY'),
latitude::float,
longitude::float
from s_discounts
;


truncate table s_vendors;
truncate table vendors;
COPY s_vendors FROM '/home/tony/vendors.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into vendors
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
address,
phone,
website,
categoryid,
name,
latitude::float,
longitude::float
from s_vendors
;

truncate table transactions;
truncate table s_transactions;
COPY s_transactions FROM '/home/tony/transactions.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into transactions
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
userid,
activitytype,
CASE WHEN length(coinchangeamt) > 0 THEN coinchangeamt::integer ELSE 0 END,
rewardid,
pointrewardid,
rewarddescription,
rewardlongdescription,
CASE WHEN length(rewardtotalcountafteraction) > 0 THEN rewardtotalcountafteraction::integer ELSE NULL END,
vendorid
from s_transactions;

truncate table users;
truncate table s_users;
COPY s_users FROM '/home/tony/users.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into users
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
CASE WHEN facebookid~E'^\\d+$' THEN facebookid::bigint ELSE 0 END,
username,
registereduserflag::boolean,
facebookuserflag::boolean,
CASE WHEN length(birthday) > 0 THEN to_date(birthday, 'MM/DD/YYYY') ELSE NULL END,
gender,
name,
CASE WHEN rewardcatpoints~E'^\\d+$' THEN rewardcatpoints::integer ELSE 0 END,
CASE WHEN numofinvitedfriends~E'^\\d+$' THEN numofinvitedfriends::integer ELSE 0 END,
uuid
from s_users;

truncate table s_logs;
truncate table logs;
COPY s_logs FROM '/home/tony/logs.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );

insert into logs
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
activitydescription,
case when loggedTime like '%1969 00%' then to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS') else to_timestamp(loggedTime, 'MM/DD/YYYY HH24:MI:SS') end,
discount,
pointreward,
redeemflag::boolean,
reward,
userid
from s_logs;