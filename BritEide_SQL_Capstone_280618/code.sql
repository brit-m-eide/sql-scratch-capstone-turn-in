/* Q1 */

-- 1a
/* Campaigns */
SELECT count(distinct utm_campaign) AS Campaign
FROM page_visits; -- 8 campaigns

/* Sources */
SELECT count(distinct utm_source) AS Source
FROM page_visits; -- 6 sources

-- 1b
/* Source by Campaign */
SELECT distinct(utm_campaign) AS Campaign,
	utm_source AS Source
FROM page_visits
GROUP BY 1;

-- 1c
/* Distinct page */
SELECT DISTINCT page_name AS 'Page Name'
FROM page_visits;

/* Q2 */

-- 2a
/* First Touches */
WITH first_touch_at AS (
	SELECT user_id,min(timestamp) AS ‘first_touch_at’
 	FROM page_visits
 	GROUP BY user_id),
ft_attr AS (
	SELECT ft.user_id, 
	ft.first_touch_at, 
	pv.utm_source,
	pv.utm_campaign
	FROM first_touch_at ft 
	JOIN page_visits pv 
		ON ft.user_id = pv.user_id 
		AND ft.first_touch_at = pv.timestamp)
SELECT ft_attr.utm_source AS Source, 
	ft_attr.utm_campaign AS Campaign, 
	COUNT(*) AS 'First Touch'
FROM ft_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 2b
/* Last Touches */
WITH last_touch_at AS (
	SELECT user_id,max(timestamp) AS ‘last_touch_at’
 	FROM page_visits
 	GROUP BY user_id),
lt_attr AS (
	SELECT lt.user_id, 
	lt.last_touch_at, 
	pv.utm_source, 
	pv.utm_campaign
	FROM last_touch_at lt 
	JOIN page_visits pv 
		ON lt.user_id = pv.user_id 
		AND lt.last_touch_at = pv.timestamp)
SELECT lt_attr.utm_source as Source, 
	lt_attr.utm_campaign AS Campaign, 
	COUNT(*) AS 'Last Touch'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;

-- 2c
/* Visitors making a purchase */
SELECT COUNT(DISTINCT user_id) AS Purchases,
	ROUND(100.0 *
		COUNT(DISTINCT user_id)/
		(SELECT COUNT(DISTINCT user_id) 
		FROM page_visits)
		,2) AS Percentage
FROM page_visits
WHERE page_name LIKE '%purchase';

-- 2d
/* Last touch on the purchase page */
WITH last_touch_at AS (
	SELECT user_id,
	MAX(timestamp) AS ‘last_touch_at’
 	FROM page_visits
 	WHERE page_name LIKE '%purchase'
	GROUP BY user_id),
lt_attr AS (
	SELECT lt.user_id, 
	lt.last_touch_at, 
	pv.utm_source, 
	pv.utm_campaign
	FROM last_touch_at lt
	JOIN page_visits pv 
		ON lt.user_id = pv.user_id 
		AND lt.last_touch_at = pv.timestamp)
SELECT lt_attr.utm_source AS Source, 
	lt_attr.utm_campaign AS Campaign, 
	COUNT(*) AS 'Last Touch'
FROM lt_attr
GROUP BY 1, 2
ORDER BY 3 DESC;


-- 2e
/* Customer journey */
SELECT utm_campaign AS Campaign, 
	page_name AS 'Page name', 
	COUNT(timestamp) AS 'Visitors'
FROM page_visits
GROUP BY 1,2 ORDER BY 1,2 ASC;
-- percentages shown in next query


/* Q3 */
/* Purchases as % of total timestamps */
WITH count_campaigns AS (
	SELECT DISTINCT utm_campaign
	FROM page_visits),
percentage AS (
	SELECT DISTINCT utm_campaign,
	COUNT(timestamp) AS timestamp
	FROM page_visits
	WHERE page_name LIKE '%purchase'
 	GROUP BY 1)
SELECT co.utm_campaign AS Campaign,
	COUNT(pv.timestamp) AS 'Overall',
	p.timestamp AS 'Purchases',
	ROUND(100.0* 
		p.timestamp/
		(COUNT(pv.timestamp))
		,2) AS 'Percentage'
FROM page_visits pv 
	JOIN count_campaigns co 
	ON pv.utm_campaign=co.utm_campaign 
	JOIN percentage p 
	ON pv.utm_campaign=p.utm_campaign
GROUP BY 1 
ORDER BY 4 DESC
LIMIT 5;




