/* Q1 */

-- 1a
/* Campaigns */
select count(distinct utm_campaign) as Campaign
from page_visits; -- 8 campaigns

/* Sources */
select count(distinct utm_source) as Source
from page_visits; -- 6 sources

-- 1b
/* Source by Campaign */
select distinct(utm_campaign) as Campaign,utm_source as Source
from page_visits
group by 1;

-- 1c
/* Distinct page */
select distinct(page_name) as 'Page Name'
from page_visits;

/* Q2 */

-- 2a
/* First Touches */
with first_touch_at as 
(select user_id,min(timestamp) as ‘first_touch_at’
 from page_visits
 Group by user_id),
ft_attr as (
select ft.user_id, ft.first_touch_at, pv.utm_source,
pv.utm_campaign
from first_touch_at ft join page_visits pv 
on ft.user_id = pv.user_id and ft.first_touch_at = pv.timestamp
)
select ft_attr.utm_source as Source, 
ft_attr.utm_campaign as Campaign, count(*) as 'First Touch'
from ft_attr
group by 1, 2
order by 3 desc;

-- 2b
/* Last Touches */
with last_touch_at as 
(select user_id,max(timestamp) as ‘last_touch_at’
 from page_visits
 Group by user_id),
lt_attr as (
select lt.user_id, lt.last_touch_at, pv.utm_source, 
pv.utm_campaign
from last_touch_at lt join page_visits pv on lt.user_id = pv.user_id and lt.last_touch_at = pv.timestamp
)
select lt_attr.utm_source as Source, 
lt_attr.utm_campaign as Campaign, count(*) as 'Last Touch'
from lt_attr
group by 1, 2
order by 3 desc;

-- 2c
/* Visitors making a purchase */
select count(distinct user_id) as Purchases,
round(100.0*count(distinct user_id)/(select count(distinct(user_id)) from page_visits),2) as Percentage
from page_visits
where page_name like '%purchase';

-- 2d
/* Last touch on the purchase page */
with last_touch_at as 
(select user_id,max(timestamp) as ‘last_touch_at’
 from page_visits
 where page_name like '%purchase'
 Group by user_id),
lt_attr as 
(select lt.user_id, lt.last_touch_at, pv.utm_source, 
pv.utm_campaign
from last_touch_at lt
join page_visits pv on lt.user_id = pv.user_id 
and lt.last_touch_at = pv.timestamp
)
select lt_attr.utm_source as Source, 
lt_attr.utm_campaign as Campaign, count(*) as 'Last Touch'
from lt_attr
group by 1, 2
order by 3 desc;


-- 2e
/* Customer journey */
with percentage as
(select utm_campaign,page_name,count(timestamp)
 from page_visits)
select utm_campaign as Campaign, page_name as 'Page name', count(timestamp) as 'Visitors'
from page_visits
group by 1,2 order by 1,2 asc; 
-- percentages shown in next query


/* Q3 */
/* Purchases as % of total timestamps */
with count_campaigns as
(select distinct (utm_campaign)
from page_visits),
percentage as
(select distinct(utm_campaign),count(timestamp) as timestamp
 from page_visits where page_name like '%purchase'
 group by 1)
select co.utm_campaign as Campaign,count(pv.timestamp) as 'Overall',
p.timestamp as 'Purchases',
round(100.0* p.timestamp/(count(pv.timestamp)),2) as 'Percentage'
from page_visits pv join count_campaigns co on pv.utm_campaign=co.utm_campaign join percentage p on 
pv.utm_campaign=p.utm_campaign
group by 1 order by 4 desc limit 5;




