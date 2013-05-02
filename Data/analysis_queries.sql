-- user by date
select
date_trunc('day', createdat - interval '7 hour') as user_date,
count(*) total_users,
sum(case when NOT facebookuserflag and registereduserflag then 1 else 0 end) non_fb_users,
sum(case when facebookuserflag then 1 else 0 end) fb_users
from users a
where not exists
(
select 1 from black_listed_users b
where a.objectid = b.objectid
)
group by date_trunc('day', createdat - interval '7 hour')
order by user_date
;

-- scans by date
select
date_trunc('day', createdat - interval '7 hour') as user_date,
count(*) total_scans,
count(distinct userid) total_scanners,
count(distinct vendorid) total_stores
from transactions a
where not exists
(
select 1 from black_listed_users b
where a.userid = b.objectid
)
and activitytype like 'Scanned Reward'
group by date_trunc('day', createdat - interval '7 hour')
order by user_date
;

-- invite by date
select
date_trunc('day', createdat - interval '7 hour') as user_date,
sum(coinchangeamt) total_friends_invited,
count(distinct userid) total_users_sent_invites
from transactions a
where not exists
(
select 1 from black_listed_users b
where a.userid = b.objectid
)
and activitytype like 'Facebook Invite Friends'
group by date_trunc('day', createdat - interval '7 hour')
order by user_date
;

-- users per vendor
create table users_per_vendor_snapshot
as
select
date 'now' - 1 as snapshot_date,
c.name,
count(distinct userid) distinct_engaged_users
from transactions a, vendors c
where not exists
(
select 1 from black_listed_users b
where a.userid = b.objectid
)
and activitytype in ('Scanned Reward', 'Redeemed Reward', 'Redeemed PointReward')
and a.vendorid = c.objectid
group by date 'now' - 1, c.name
order by c.name
;

select * from users_per_vendor_snapshot order by name;

-- impression per day
select
date_trunc('day', loggedtime - interval '7 hour') as user_date,
sum(case when activitydescription in ('Scan impression', 'Loyalty impression', 'Coin impression', 'Discount impression', 'Account impression') then 1 else 0 end) as total_impression,
sum(case when activitydescription like 'Scan impression' then 1 else 0 end) as total_scan_impression,
sum(case when activitydescription like 'Loyalty impression' then 1 else 0 end) as total_loyalty_impression,
sum(case when activitydescription like 'Coin impression' then 1 else 0 end) as total_coin_impression,
sum(case when activitydescription like 'Discount impression' then 1 else 0 end) as total_discount_impression,
sum(case when activitydescription like 'Detail page impression' then 1 else 0 end) as total_detail_impression,
sum(case when activitydescription like 'Account impression' then 1 else 0 end) as total_account_impression,
sum(case when activitydescription like 'Category impression' then 1 else 0 end) as total_category_impression,
sum(case when activitydescription like 'History impression' then 1 else 0 end) as total_history_impression
from logs a
where not exists
(
select 1 from black_listed_users b
where a.userid = b.objectid
)
and activitydescription like '%impression%'
group by date_trunc('day', loggedtime - interval '7 hour')
order by user_date
;

-- daily active users
select
date_trunc('day', createdat - interval '7 hour') as user_date,
count(distinct userid) total_active_users
from transactions a
where not exists
(
select 1 from black_listed_users b
where a.userid = b.objectid
)
and activitytype in ('Scanned Reward', 'Redeemed Reward', 'Redeemed PointReward')
group by date_trunc('day', createdat - interval '7 hour')
order by user_date
;

