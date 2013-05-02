/*
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
*/

/*
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
*/
/*
drop table black_listed_users;
create table black_listed_users
(
objectid text,
username text,
facebookid bigint,
name text
);
*/

insert into black_listed_users
select objectid,username,facebookid,name from users where name like 'Garry%' or name like 'Grace%' or name like 'Sha Luo%' or name like 'Fancy Fan%' or name like 'Tony Zh%' or name like '%Han' or name like 'Hao%Chen' or name like 'Hao X%' or name like 'Victor N%' or username like 'test';

select * from black_listed_users;
select * from users order by name nulls last;

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

COPY s_users FROM '/home/tony/users.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );
 
drop table s_logs;
create table s_logs
(
objectid text,
createdat text,
updatedat text,
activitydescription text,
discount text,
pointreward text,
redeemflag text,
reward text,
userid text
);

create table logs
(
objectid text,
createdat timestamp,
updatedat timestamp,
activitydescription text,
discount text,
pointreward text,
redeemflag boolean,
reward text,
userid text
);

truncate table logs;
insert into logs
select
objectid,
to_timestamp(createdat, 'MM/DD/YYYY HH24:MI:SS'),
to_timestamp(updatedat, 'MM/DD/YYYY HH24:MI:SS'),
activitydescription,
discount,
pointreward,
redeemflag::boolean,
reward,
userid
from s_logs;

COPY s_logs FROM '/home/tony/logs.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
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


truncate table transactions;
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


COPY s_transactions FROM '/home/tony/transactions.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );
 
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

COPY s_vendors FROM '/home/tony/vendors.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
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

truncate table s_discounts;
COPY s_discounts FROM '/home/tony/discount.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
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

truncate table s_loyalty;
COPY s_loyalty FROM '/home/tony/loyalty.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );



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

select count(*) from coin;
truncate table s_coin;
COPY s_coin FROM '/home/tony/coin.csv'
WITH (
 FORMAT CSV,
 DELIMITER ',',
 NULL '',
 HEADER TRUE,
 QUOTE '"' 
 );




select count(distinct userid) from logs a where a.userid not in (select objectid from black_listed_users);

select userid, count(distinct reward) from logs a where a.userid not in (select objectid from black_listed_users) group by userid having count(distinct reward) > 3
;

select * from logs;
select * from transactions a, users b
where a.userid not in (select objectid from black_listed_users)
and a.activitytype in ('Redeemed PointReward')
and a.userid = b.objectid
order by a.vendorid, a.createdat
;

select a.vendorid, count(distinct userid) from transactions a, users b
where a.userid not in (select objectid from black_listed_users)
and a.activitytype in ('Scanned Reward')
and a.userid = b.objectid
group by a.vendorid
--order by a.vendorid, a.createdat
;

select a.userid, count(*) from transactions a, users b
where a.userid not in (select objectid from black_listed_users)
and a.activitytype in ('Scanned Reward')
and a.userid = b.objectid
group by a.userid
having count(*) > 3
;

select count(distinct userid) from transactions a, users b
where a.userid not in (select objectid from black_listed_users)
and a.activitytype in ('Redeemed PointReward','Scanned Reward')
and a.userid = b.objectid
;

select count(*) from users where registereduserflag;

select * from transactions a where a.userid not in (select objectid from black_listed_users) and vendorid = 'IqH3s4MaBS';

select distinct activitytype from transactions;
select count(*) from users;

select * from logs;

