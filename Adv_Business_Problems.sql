-- Zomato 20 Advaned Business Problems

-- Q. 1
-- Write a query to find the top 5 most frequently ordered dishes by customer called "Arjun Mehta" in the last 1 year.

SELECT customer_name, order_item, total_orders
FROM 
	(SELECT c.customer_id,
		   c.customer_name,
		   o.order_item,
		   COUNT (*) as total_orders,
		   DENSE_RANK() OVER(ORDER BY COUNT (*) DESC) AS RANK
	FROM ORDERS as o
	INNER JOIN CUSTOMERS as c
	ON o.customer_id = c.customer_id 
	WHERE c.customer_name = 'Arjun Mehta' AND o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
	GROUP BY c.customer_id,c.customer_name,o.order_item
	ORDER BY total_orders DESC) 
as t1
WHERE RANK <=5;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 2 Popular Time Slots
-- Question: Identify the time slots during which the most orders are placed. based on 2-hour intervals.

-- APPROACH ONE - LENGTHIER ONE
SELECT 
	CASE
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 0 AND 1 THEN '00:00 - 02:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 2 AND 3 THEN '02:00 - 04:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 4 AND 5 THEN '04:00 - 06:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 7 THEN '06:00 - 08:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 8 AND 9 THEN '08:00 - 10:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 10 AND 11 THEN '10:00 - 12:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 13 THEN '12:00 - 14:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 14 AND 15 THEN '14:00 - 16:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 16 AND 17 THEN '16:00 - 18:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 18 AND 19 THEN '18:00 - 20:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 20 AND 21 THEN '20:00 - 22:00'
		WHEN EXTRACT(HOUR FROM order_time) BETWEEN 22 AND 23 THEN '22:00 - 00:00'
	END AS time_slots,
COUNT(order_id) AS most_orders
FROM ORDERS
GROUP BY time_slots
ORDER BY most_orders DESC
LIMIT 5;

SELECT 00:59:59 -- 0 (Till 1am in the night it will be counted as 0)
SELECT 01:59:59 -- 1 (FROM 1am till 2 am count it as 1 so we have this 2 hr time slots and we would need 12 of these)


-- APPROACH 2 : Divding the order time into slots using logic
-- EG. an order of 23:15:16 should be counted in 10-12 slot , so it will go in the code like, first the Hour ‘23’ (this will be divided by 2) (23/2)=11.5, 
-- FLOOR division so we count is as 11, This will be multiplied by 2 so we get 22 ie. 10pm as start_time and then end_time is this plus 2
SELECT COUNT(order_id) as most_orders,
	   FLOOR(EXTRACT(HOUR FROM order_time)/2)*2 AS start_time,
	   FLOOR(EXTRACT(HOUR FROM order_time)/2)*2+2 AS end_time
FROM ORDERS
GROUP BY 2,3
ORDER BY most_orders DESC
LIMIT 5;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 3 Order Value Analysis
-- Question: Find the average order value per customer who has placed more than 750 orders.
-- Return customer_name, and aov(average order value)

SELECT * FROM ORDERS;
-- APPROACH
-- we need AOV whose count of order_id > 750
-- it should be a group by customer_id and we will use INNER JOIN since we need the name
-- once we have the count then we sum the total_amount 
SELECT c.customer_id,c.customer_name, COUNT(o.order_id) AS total_orders, AVG(o.total_amount)
FROM ORDERS AS o
INNER JOIN CUSTOMERS AS c
ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING COUNT(order_id) > 750
ORDER BY total_orders desc;

-- customer id who have placed more than 750 orders
SELECT COUNT(order_id) as total_orders, customer_id
FROM ORDERS
GROUP BY customer_id
HAVING COUNT(order_id) > 750
ORDER BY total_orders DESC;
-- limit 3;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 4 High-Value Customers
-- Question: List the customers who have spent more than 100K in total on food orders.
-- return customer_name, and customer_id!

SELECT c.customer_id, c.customer_name,SUM(o.total_amount) AS total_amount
FROM ORDERS AS o
INNER JOIN CUSTOMERS AS c
ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING SUM(o.total_amount) > 100000
ORDER BY total_amount desc;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 5 Orders Without Delivery
-- Question: Write a query to find orders that were placed but not delivered. 
-- Return each restuarant name, city and number of not delivered orders 

-- Approach - Here we know we would need 3 tables the deliveries, orders and retaurants and use joins between them 
-- Here we only join 'Orders' table becoz we directly won't be able to join the restaurants and deliveries table

-- MY LOGIC ASSUMING WE NEED TO FIND THE 'Not Delivered' Orders from the deliveries table, orders that were placed also fulfilled by restaurants but not delivered
SELECT r.restaurant_name,
	   r.city,
	   o.order_status,
	   COUNT(d.delivery_status) as not_delivered_orders
FROM DELIVERIES as d
LEFT JOIN ORDERS as o
ON d.order_id = o.order_id
LEFT JOIN RESTAURANTS as r
ON o.restaurant_id = r.restaurant_id
WHERE d.delivery_status = 'Not Delivered'
GROUP BY r.restaurant_name, r.city, o.order_status
ORDER BY not_delivered_orders DESC;

-- Actual LOGIC given we had to find the orders that were not fulfilled from the restaurant side 
SELECT r.restaurant_name, 
	   r.city, 
	   COUNT(o.order_id) AS not_completed_orders
FROM ORDERS AS o
INNER JOIN RESTAURANTS AS r
ON o.restaurant_id = r.restaurant_id
WHERE o.order_status = 'Not Fulfilled'
-- WHERE o.order_id NOT IN (SELECT order_id FROM DELIVERIES) [ALTERNATE WHERE CONDITION]
GROUP BY r.restaurant_name,r.city
ORDER BY not_completed_orders DESC; 

-- This is a subquery that will give us all the order_ids that are not in delivered, so if they are not present that means the order_status for them would be 'Not Fulfiiled'
SELECT o.order_id,o.order_status
FROM ORDERS AS o 
WHERE o.order_id NOT IN (SELECT order_id FROM DELIVERIES);


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 6
-- Restaurant Revenue Ranking: 
-- Rank restaurants by their total revenue from the last year, including their name, 
-- total revenue, and rank within their city.

-- APPROACH - We need to return the restaurant name, total revenue(sum of total_amt from orders table) and the rank within city (use partition by)
-- We will have to join restaurants and orders table and then group by the restaurant name and the city 
-- Where condition [Order date - current interval]

-- We have total 71 Restaurants in the Restaurants table, but only from 61 of them orders have actually been placed so to not include Restaurants that have
-- not been ordered from we use this 'WHERE o.restaurant_id IN (SELECT r.restaurant_id FROM RESTAURANTS AS r)'
-- And we do a left join because we need to include all the restaurants first not miss out anyone and then remove null ones.

WITH ranking_table -- Using a CTE here 
AS
(
	SELECT r.restaurant_name,
		   r.city,
		   SUM(o.total_amount) AS total_revenue,
		   RANK() OVER(PARTITION BY r.city ORDER BY SUM (o.total_amount) DESC) AS RANK
	FROM RESTAURANTS AS r
	LEFT JOIN ORDERS AS o
	ON o.restaurant_id = r.restaurant_id
	WHERE o.restaurant_id IN (SELECT r.restaurant_id FROM RESTAURANTS AS r) AND o.order_date >= CURRENT_DATE - INTERVAL '2 Year'
	GROUP BY r.restaurant_name,r.city
)
SELECT * 
FROM ranking_table 
WHERE rank = 1; --This will give us only one restaurant per city which has the highest revenue

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q. 7
-- Most Popular Dish by City: 
-- Identify the most popular dish in each city based on the number of orders.

-- APPROACH we have the city name in the RESTAURANTS table and the dish name in the ORDERS Table so we do a INNER JOIN between them
-- GROUP BY city 
-- WHERE COUNT(order_id) 

WITH ranking_table
AS 
(
	SELECT o.order_item,
	       r.city, 
		   COUNT(o.order_id) as total_orders,
		   DENSE_RANK() OVER (PARTITION BY r.city ORDER BY COUNT(o.order_id) DESC) AS RANK
	FROM ORDERS as o
	INNER JOIN RESTAURANTS as r
	ON o.restaurant_id = r.restaurant_id
	GROUP BY o.order_item, r.city
)
SELECT * 
FROM ranking_table 
WHERE RANK = 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.8 Customer Churn: 
-- Find customers who haven’t placed an order in 2024 but did in 2023.

-- APPROACH - find customers who have placed order in 2024 
			--return the customers that are not present in that list since these are people who have not ordered in 2024

SELECT c.customer_name
FROM CUSTOMERS AS c
INNER JOIN ORDERS as o
ON c.customer_id = o.order_id
WHERE c.customer_name NOT IN 
( 
	SELECT c.customer_name
	FROM ORDERS AS o
	INNER JOIN CUSTOMERS AS c
	ON o.customer_id = c.customer_id
	WHERE o.order_date >= '2024-01-01'
	GROUP BY c.customer_name
)
GROUP BY c.customer_name
HAVING COUNT(o.order_id) >= 1
ORDER BY c.customer_name ASC;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.9 Cancellation Rate Comparison: 
-- Calculate and compare the order cancellation rate for each restaurant between the current year and the previous year.

-- First we find the cancelleation rate for 2023 and for that we need Total orders and cancelled orders for each restaurant for 2023
-- Whenever an order has not been delivered we have the delivery id as 'NULL' and that is why the CASE Statement
-- 	SELECT r.restaurant_name,COUNT(o.order_id) AS total_orders, COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS cancelled_orders 
-- 	FROM ORDERS AS o
-- 	LEFT JOIN DELIVERIES AS d
-- 	ON o.order_id = d.order_id
-- 	LEFT JOIN RESTAURANTS AS r
-- 	ON o.restaurant_id = r.restaurant_id 
-- 	WHERE o.order_date < '2024-01-01'
-- 	GROUP BY r.restaurant_name
	
-- Now to find the cancellation rate we need to divide the cancelled_orders/total_orders
-- 	SELECT restaurant_name,
-- 	total_orders,
-- 	cancelled_orders,
-- 	ROUND(cancelled_orders::numeric/total_orders::numeric * 100,2) AS cancelled_ratio
-- 	FROM previous_year_data_23
-- 	ORDER BY cancelled_ratio DESC


-- We implment the exact same logic for 2024 using multiple CTEs

WITH previous_year_data_23
AS 
(
	SELECT r.restaurant_name,COUNT(o.order_id) AS total_orders, COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS cancelled_orders 
	FROM ORDERS AS o
	LEFT JOIN DELIVERIES AS d
	ON o.order_id = d.order_id
	LEFT JOIN RESTAURANTS AS r
	ON o.restaurant_id = r.restaurant_id 
	WHERE o.order_date < '2024-01-01'
	GROUP BY r.restaurant_name
),
current_year_data_24
AS 
(
	SELECT r.restaurant_name,COUNT(o.order_id) AS total_orders, COUNT(CASE WHEN d.delivery_id IS NULL THEN 1 END) AS cancelled_orders 
	FROM ORDERS AS o
	LEFT JOIN DELIVERIES AS d
	ON o.order_id = d.order_id
	LEFT JOIN RESTAURANTS AS r
	ON o.restaurant_id = r.restaurant_id 
	WHERE o.order_date >= '2024-01-01'
	GROUP BY r.restaurant_name
),
cancellation_rate_23
AS
(
	SELECT restaurant_name,
    total_orders,
    cancelled_orders,
	ROUND(cancelled_orders::numeric/total_orders::numeric * 100,2) AS cancelled_ratio_23
	FROM previous_year_data_23
	ORDER BY cancelled_ratio_23 DESC
),
cancellation_rate_24
AS
( 
	SELECT restaurant_name,
    total_orders,
    cancelled_orders,
	ROUND(cancelled_orders::numeric/total_orders::numeric * 100,2) AS cancelled_ratio_24
	FROM current_year_data_24
	ORDER BY cancelled_ratio_24 DESC
)

-- Now to get the difference we need to use JOINS

SELECT c.restaurant_name,
	   l.cancelled_ratio_23,
	   c.cancelled_ratio_24
FROM cancellation_rate_24 AS c
JOIN cancellation_rate_23 AS l
ON c.restaurant_name = l.restaurant_name;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.10 Rider Average Delivery Time: 
-- Determine each rider's average delivery time.

-- we have the order time in the orders table and the delivery time in the deliveries table and we need to subtract the delivery_time from the order_time to get 
-- the actual delivered time for that order

-- HIS APPROACH 
WITH time_diff_all_orders
AS 
(
SELECT o.order_id,
	   o.order_time,
	   d.delivery_time,
	   d.rider_id,
	   d.delivery_time-o.order_time AS time_diff,
	   EXTRACT (EPOCH FROM ( d.delivery_time-o.order_time + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 Day' ELSE INTERVAL '0 Day' END)) /60 AS time_diff_min
FROM ORDERS AS o
INNER JOIN DELIVERIES AS d 
ON o.order_id = d.order_id
WHERE d.delivery_status = 'Delivered'
)

SELECT t.rider_id,r.rider_name ,AVG(t.time_diff_min)
FROM time_diff_all_orders AS t
INNER JOIN RIDERS AS r
ON t.rider_id = r.rider_id
GROUP BY t.rider_id, r.rider_name;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.11 Monthly Restaurant Growth Ratio: 
-- Calculate each restaurant's growth ratio based on the total number of delivered orders since its joining

SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;
SELECT * FROM RESTAURANTS;
SELECT * FROM RIDERS;
SELECT * FROM DELIVERIES;

-- approach: orders and restaurants table join, count(order_id) to get total orders since joining, TO_CHAR(order_date,'YYYY-MM'), group by restaurant name
WITH current_and_prev_month_orders
AS
(
SELECT r.restaurant_name,
	   TO_CHAR(o.order_date,'YYYY-MM') AS YEARLY_DATE, 
	   COUNT(o.order_id) as total_orders_in_that_month,
	   LAG(COUNT(o.order_id),1) OVER (PARTITION BY r.restaurant_name ORDER BY TO_CHAR(o.order_date,'YYYY-MM')) AS PREV_MONTH_ORDERS
FROM RESTAURANTS AS r
INNER JOIN ORDERS AS o
ON r.restaurant_id = o.restaurant_id
INNER JOIN DELIVERIES AS d
ON d.order_id  = o.order_id
WHERE d.delivery_status = 'Delivered'
GROUP BY r.restaurant_name,YEARLY_DATE
ORDER BY r.restaurant_name
)
SELECT g.restaurant_name,
       g.YEARLY_DATE,
	   g.total_orders_in_that_month,
	   g.PREV_MONTH_ORDERS,
	   ROUND((g.total_orders_in_that_month::numeric-g.PREV_MONTH_ORDERS::numeric)/g.PREV_MONTH_ORDERS::numeric *100,2)  AS growth_ratio
FROM current_and_prev_month_orders AS g
GROUP BY g.restaurant_name,g.YEARLY_DATE,g.total_orders_in_that_month,g.PREV_MONTH_ORDERS
ORDER BY g.restaurant_name,g.YEARLY_DATE;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.12 Customer Segmentation: 
-- Customer Segmentation: Segment customers into 'Gold' or 'Silver' groups based on their total spending 
-- compared to the average order value (AOV). If a customer's total spending exceeds the AOV, 
-- label them as 'Gold'; otherwise, label them as 'Silver'. Write an SQL query to determine each segment's 
-- total number of orders and total revenue

SELECT * FROM ORDERS;


SELECT Category,
 	   SUM(total_spending),
	   SUM(total_orders)
FROM 
(
SELECT c.customer_name, 
	   SUM(o.total_amount) AS total_spending,
	   COUNT(o.order_id) AS total_orders,
	    CASE 
	       WHEN SUM(o.total_amount) > (SELECT AVG(total_amount) FROM ORDERS) THEN 'GOLD' ELSE 'SILVER' 
	   END AS Category
FROM CUSTOMERS AS c
INNER JOIN ORDERS AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
) AS T1
GROUP BY Category;


----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.13 Rider Monthly Earnings: 
-- Calculate each rider's total monthly earnings, assuming they earn 8% of the order amount.

SELECT r.rider_id
FROM RIDERS AS r
WHERE r.rider_id NOT IN 
						(
							SELECT DISTINCT(d.rider_id)
							FROM DELIVERIES AS d
							INNER JOIN ORDERS AS o
							ON d.order_id = o.order_id 
							WHERE d.delivery_status = 'Delivered'
						);



SELECT r.rider_name, 
	   TO_CHAR(o.order_date,'YYYY-MM') AS YEARLY_DATE, 
	   SUM(o.total_amount) AS total_order_amount,
	   SUM(o.total_amount)*0.08 AS monthly_rider_earnings
FROM ORDERS AS o
INNER JOIN DELIVERIES AS d
ON o.order_id = d.order_id
LEFT JOIN RIDERS AS r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered'
GROUP BY 1,2
ORDER BY 1;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.14 Rider Ratings Analysis: 
-- Find the number of 5-star, 4-star, and 3-star ratings each rider has.
-- riders receive this rating based on delivery time.
-- If orders are delivered less than 15 minutes of order received time the rider get 5 star rating,
-- if they deliver 15 and 20 minute they get 4 star rating 
-- if they deliver after 20 minute they get 3 star rating.

WITH rating_category
AS
(
SELECT r.rider_id,
	   EXTRACT (EPOCH FROM ( d.delivery_time-o.order_time + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 Day' ELSE INTERVAL '0 Day' END)) /60 AS time_diff_min
FROM ORDERS AS o
INNER JOIN DELIVERIES AS d
ON o.order_id = d.order_id
LEFT JOIN RIDERS AS r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered'
ORDER BY 1
), each_rider_order_rating
AS 
(
SELECT rider_id,
       time_diff_min,
       CASE 
	   	   WHEN time_diff_min::numeric < 15 THEN '5 Star'
		   WHEN time_diff_min::numeric BETWEEN 15 AND 20 THEN '4 Star'
		   ELSE '3 Star'
	   END AS rider_ratings
FROM rating_category
)
SELECT rider_id, rider_ratings, COUNT(rider_ratings)
FROM each_rider_order_rating
GROUP BY 1,2
ORDER BY 1,2;



----------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Q.15 Order Frequency by Day: 
-- Analyze order frequency per day of the week and identify the peak day for each restaurant.

SELECT * FROM ORDERS;
select * from restaurants;

WITH per_day_rank
AS
(
SELECT r.restaurant_name,
	   EXTRACT(DOW FROM o.order_date) as dow,
	   COUNT(o.order_id),
	   RANK() OVER (PARTITION BY r.restaurant_name ORDER BY COUNT(o.order_id) DESC) AS RANK
FROM ORDERS AS o
INNER JOIN RESTAURANTS AS r
ON o.restaurant_id = r.restaurant_id
GROUP BY 1,2
ORDER BY 1,3 DESC
)
SELECT *
FROM per_day_rank
WHERE RANK = 1;

-- Q.16 Customer Lifetime Value (CLV): 
-- Calculate the total revenue generated by each customer over all their orders.

SELECT c.customer_name, SUM(o.total_amount) AS CLV
FROM CUSTOMERS AS c
LEFT JOIN ORDERS AS o
ON c.customer_id = o.customer_id
GROUP BY 1
ORDER BY 2 ASC;


-- Q.17 Monthly Sales Trends: 
-- Identify sales trends by comparing each month's total sales to the previous month.

WITH prev_month_sales_comparison
AS
(
SELECT TO_CHAR(o.order_date, 'YYYY-MM') AS order_month, 
       SUM(o.total_amount) AS total_sales,
	   LAG(SUM(o.total_amount),1) OVER (ORDER BY TO_CHAR(o.order_date, 'YYYY-MM')) AS prev_month_sales
FROM ORDERS AS o
GROUP BY 1
ORDER BY 1
)
SELECT order_month,
       total_sales,
	   prev_month_sales,
       ROUND((total_sales::numeric-prev_month_sales::numeric)/prev_month_sales::numeric *100,2) AS growth_ratio
FROM prev_month_sales_comparison


-- Q.18 Rider Efficiency: 
-- Evaluate rider efficiency by determining average delivery times and identifying those with the lowest and highest averages.


SELECT r.rider_name, AVG(EXTRACT (EPOCH FROM (d.delivery_time - o.order_time + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 Day' ELSE INTERVAL '0 Day' END)) / 60) AS each_rider_delivery_time
FROM ORDERS AS o
INNER JOIN DELIVERIES AS d
ON o.order_id = d.order_id
LEFT JOIN RIDERS AS r
ON d.rider_id = r.rider_id
WHERE d.delivery_status = 'Delivered'
GROUP BY r.rider_name
ORDER BY 2;

-- Q.19 Order Item Popularity: 
-- Track the popularity of specific order items over time and identify seasonal demand spikes.

SELECT * FROM ORDERS;

SELECT TO_CHAR(o.order_date,'YYYY-MM'),o.order_item,COUNT(o.order_item)
FROM ORDERS AS o
GROUP BY 1,2
ORDER BY 3 DESC;



-- Q.20 Rank each city based on the total revenue for last year 2023
SELECT r.city,SUM(o.total_amount),
       RANK() OVER (ORDER BY SUM(o.total_amount) DESC) AS RANK
FROM ORDERS AS o
INNER JOIN RESTAURANTS AS r
ON o.restaurant_id = r.restaurant_id
WHERE o.order_date <= CURRENT_DATE - INTERVAL '2 Year'
GROUP BY 1;