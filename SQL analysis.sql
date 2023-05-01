-- 1. Exploring the data structure across apps categories
--In terms of number of apps:
SELECT category, 
	COUNT(*) AS apps_number, --Count the number of apps in each category
	COUNT(*) * 100 / (SELECT COUNT(*) FROM apps) AS apps_percent --Calculate the percentage of each category with subquery
FROM apps
GROUP BY category --Group the data by category
ORDER BY COUNT(*) DESC; --Sort data by number of apps in descending order

--In terms of number of installs:
SELECT category, 
	COUNT(*) AS apps_number, --Count the number of apps in each category
	COUNT(*) * 100 / (SELECT COUNT(*) FROM apps) AS apps_percent, --Calculate the percentage of each category using subquery
	SUM(installs) AS installs_number, --Number of installs in each category
	round(SUM(installs) / COUNT(*)) AS installs_per_app --Installs per app in each category
FROM apps
GROUP BY category --Group the data by category
ORDER BY SUM(installs) DESC; --Sort data by number of installs in descending order


-- 2. Exploring the data structure across apps genres
--In terms of number of apps:
SELECT genres, 
	COUNT(*) AS apps_number, --Count the number of apps in each genre
	COUNT(*) * 100 / (SELECT COUNT(*) FROM apps) AS apps_percent --Calculate the percentage of each genre with subquery
FROM apps
GROUP BY genres --Group the data by genre
ORDER BY COUNT(*) DESC; --Sort data by number of apps in descending order

--In terms of number of installs:
SELECT genres, 
	COUNT(*) AS apps_number, --Count the number of apps in each genre
	COUNT(*) * 100 / (SELECT COUNT(*) FROM apps) AS apps_percent, --Calculate the percentage of each genre using subquery
	SUM(installs) AS installs_number --Number of installs for each genre
FROM apps
GROUP BY genres  --Group the data by genre
ORDER BY SUM(installs) DESC; --Sort data by number of installs in descending order

--3. Exploring apps prices
--Paid and free apps - numbers and percent
SELECT type,
	COUNT() AS apps_number,
	COUNT() * 100 / (SELECT COUNT() FROM apps) AS apps_percent
FROM apps
WHERE type is NOT NULL
GROUP BY type;

--For all apps across categories:
SELECT DISTINCT category, --Subset for unique rows for category
	round(AVG(price) OVER (PARTITION BY category),2) AS avg_price_cat, --Window function for calculating average price for each category
	(SELECT round(AVG(price),2) FROM apps) AS avg_price_total --Subquery for calculating sample average price
FROM apps
ORDER BY AVG(price) OVER (PARTITION BY category) DESC --Sort data by average category price in descending order
LIMIT 10; --Show top 10 results

--For paid apps only across categories:
SELECT DISTINCT category, --Subset for unique rows for category
	round(AVG(price) OVER (PARTITION BY category),2) AS avg_price_cat, --Window function for calculating average price for each category
	round(MAX(price) OVER (PARTITION BY category),2) AS max_price_cat, --Window function for calculating max price for each category
	(SELECT round(AVG(price),2) FROM apps WHERE type = 'Paid') AS avg_price_total --Subquery for calculating sample average price
FROM apps
WHERE type = 'Paid' --Subset for only Paid apps
ORDER BY AVG(price) OVER (PARTITION BY category) DESC --Sort data by average category price in descending order
LIMIT 10; --Show top 10 results

--4. Exploring app ratings, number of reviews and installs
--Average rating for each category compared to sample mean
SELECT DISTINCT category, --Subset for unique rows for category
	round(AVG(rating) OVER (PARTITION BY category),2) AS avg_rating_cat, --Window function for calculating average rating for each category
	(SELECT round(AVG(rating),2) FROM apps) AS avg_rating_total --Subquery for calculating sample average rating
FROM apps
ORDER BY round(AVG(rating) OVER (PARTITION BY category),2) DESC; --Sort data by average category rating in descending order

--Average rating for free and paid apps
SELECT type,
	round(AVG(rating),2) AS avg_rating_type
FROM apps
WHERE type IS NOT NULL
GROUP BY type;

--Average installs for free and paid apps
SELECT type,
	round(AVG(installs)) AS avg_installs_type
FROM apps
WHERE type IS NOT NULL
GROUP BY type;

--Rating for Top 20 reviewed apps
SELECT app,
	category, 
	installs,
	rating,
	reviews
FROM apps
ORDER BY reviews DESC
LIMIT 20;

--Price for different rating groups
WITH rating AS ( --Using CTE to calculate rating groups for apps
	SELECT CASE
		WHEN rating>4.5
		THEN '4.5-5.0'
		WHEN rating>4 AND rating<=4.5
		THEN '4.0-4.5'
		WHEN rating>3.5 AND rating<=4
		THEN '3.5-4.0'
		WHEN rating>3 AND rating<=3.5
		THEN '3.0-3.5'
		WHEN rating>0 AND rating<=3.0
		THEN '1.0-3.0'
		ELSE 'no rating'
	END AS rating_group,
	price,
	type
	FROM apps
	)

--Calculate avg, min, max price for each rating group only for paid apps
SELECT rating_group,
	round(AVG(price),2) AS avg_price,
	round(MIN(price),2) AS min_price,
	round(MAX(price),2) AS max_price
FROM rating
WHERE type='Paid'
GROUP BY rating_group
ORDER BY rating_group DESC;

--Avg number of reviews and avg rating effect on installs
SELECT installs,
	round(AVG(reviews)) AS avg_reviews,
	round(AVG(rating),2) AS avg_rating
FROM apps
GROUP BY installs
ORDER BY installs DESC;

--5. Exploring reviews sentiment structure across categories
--Which categories have the highest share of positive reviews?
WITH reviews_sent AS ( --With CTE inner join apps and reviews tables
	SELECT *
	FROM apps AS a
	INNER JOIN reviews r 
	ON a.app = r.app
	),
	
 sent_share AS ( --Count number and calculate share of different reviews sentiments for each app
 	SELECT DISTINCT category,
		sentiment,
		COUNT() OVER (PARTITION BY app, sentiment) AS sentiment_count,
		COUNT() OVER (PARTITION BY app, sentiment) *100 / COUNT() OVER (PARTITION BY app) AS sentiment_share
	FROM reviews_sent
	)

--Rank categories by avg share of positive reviews for each category
SELECT category,
	sentiment,
	round(AVG(sentiment_count)) AS avg_sent_count,
	round(AVG(sentiment_share)) AS avg_sent_share
FROM sent_share
WHERE sentiment = 'Positive'
GROUP BY category
ORDER BY round(AVG(sentiment_share)) DESC;

--Which categories have the highest share of negative reviews?
--The same CTEs as above
WITH reviews_sent AS (
	SELECT *
	FROM apps AS a
	INNER JOIN reviews r 
	ON a.app = r.app
	),
	
 sent_share AS (
 	SELECT DISTINCT category,
		sentiment,
		COUNT() OVER (PARTITION BY app, sentiment) AS sentiment_count,
		COUNT() OVER (PARTITION BY app, sentiment) *100 / COUNT() OVER (PARTITION BY app) AS sentiment_share
	FROM reviews_sent
	)

--Rank categories by share of negative reviews
SELECT category,
	sentiment,
	round(AVG(sentiment_count)) AS avg_sent_count,
	round(AVG(sentiment_share)) AS avg_sent_share
FROM sent_share
WHERE sentiment = 'Negative'
GROUP BY category
ORDER BY round(AVG(sentiment_share)) DESC;

--Calculate average sentiment polarity for paid and free apps
 WITH reviews_sent AS ( --With CTE inner join apps and reviews tables
	SELECT *
	FROM apps AS a
	INNER JOIN reviews r 
	ON a.app = r.app
	)

--Calculate avg, min, max reviews sentiment polarity and avg rating for paid and free apps
SELECT type,
	round(AVG(sentiment_polarity),2) AS avg_sent_polar,
	round(MIN(sentiment_polarity),2) AS min_sent_polar,
	round(MAX(sentiment_polarity),2) AS max_sent_polar,
	round(AVG(rating),2) AS avg_rating_type
FROM reviews_sent
GROUP BY type;


