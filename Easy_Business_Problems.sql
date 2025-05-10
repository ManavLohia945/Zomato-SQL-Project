-- Easy Business Problems

SELECT * FROM CUSTOMERS;
SELECT * FROM ORDERS;
SELECT * FROM RESTAURANTS;
SELECT * FROM RIDERS;
SELECT * FROM DELIVERIES;

-- 1. Find the total number of orders each restaurant has received.
SELECT r.restaurant_name,COUNT(o.order_id) AS total_orders
FROM RESTAURANTS AS r
LEFT JOIN ORDERS AS o
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_orders DESC;

--finding restaurants who haven't received any order
SELECT r.restaurant_name
FROM RESTAURANTS AS r
WHERE r.restaurant_id NOT IN 
(
	SELECT o.restaurant_id
	FROM ORDERS AS O
)


-- 2. Calculate the average amount spent by each customer.

SELECT c.customer_name,AVG(o.total_amount) AS avg_amt
FROM CUSTOMERS AS c
LEFT JOIN ORDERS AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
ORDER BY avg_amt ASC;


-- 3. Find the total sales amount for each restaurant.

SELECT r.restaurant_name,SUM(o.total_amount) AS total_rev
FROM RESTAURANTS AS r
LEFT JOIN ORDERS AS o
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
ORDER BY total_rev ASC;


-- 4. Identify the order with the highest number of items.
SELECT o.order_item,COUNT(o.order_item) as total_count
FROM ORDERS AS o
GROUP BY o.order_item
ORDER BY total_count DESC;


-- 5. Find the top 5 customers who have placed the most orders.

SELECT customer_name,most_orders
FROM 
(
SELECT c.customer_name, 
	   COUNT(o.order_id) AS most_orders, 
	   RANK() OVER(ORDER BY COUNT(o.order_id) DESC) AS RANK
FROM CUSTOMERS AS c
LEFT JOIN ORDERS AS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_name
) AS t1
WHERE RANK<=5;

-- 6. Retrieve orders placed in the last 30 days.

SELECT o.order_id,o.order_item,o.order_date,o.total_amount
FROM ORDERS AS o
WHERE o.order_date >= CURRENT_DATE - INTERVAL '500 Days';

-- 7. Calculate the average delivery time for each rider.

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

-- 8. List restaurants that are open 24 hours.

-- No restaurants are open 24hrs
SELECT * 
FROM RESTAURANTS
WHERE opening_hours = '12:00 AM - 12:00 AM';

-- 9. Get the count of each order status.

SELECT order_status, COUNT(order_status)
FROM ORDERS
GROUP BY order_status;

-- 10. Find out how many deliveries each rider has completed.

SELECT rider_id,COUNT(delivery_id) AS total_deliveries
FROM DELIVERIES
WHERE delivery_status = 'Delivered'
GROUP BY rider_id
ORDER BY total_deliveries DESC;

-- 11. Identify the top 5 restaurants with the highest total sales.

WITH highest_sales
AS
(
SELECT r.restaurant_name, 
	   SUM(o.total_amount) AS total_sales,
	   DENSE_RANK() OVER (ORDER BY SUM(o.total_amount) DESC) as RANK
FROM RESTAURANTS AS r
LEFT JOIN ORDERS AS o
ON o.restaurant_id = r.restaurant_id
GROUP BY r.restaurant_name
)
SELECT t.restaurant_name, t.total_sales
FROM highest_sales as t
WHERE RANK >= 2 AND RANK<= 6;

-- 12. Get the number of orders per city.

SELECT r.city,COUNT(o.order_id) AS total_orders
FROM RESTAURANTS AS r
LEFT JOIN ORDERS AS o
ON o.restaurant_id = r.restaurant_id
GROUP BY r.city
ORDER BY total_orders DESC;

-- 13. Find the most frequently ordered item.

SELECT order_item,COUNT(o.order_item) AS most_ordered
FROM ORDERS AS o
GROUP BY order_item
ORDER BY most_ordered DESC
LIMIT 1;

-- 14. List orders where the delivery was completed on time.
-- lets say the delivery is to be completed within 30mins, to be considered on time

WITH on_time
AS
(
SELECT o.order_id,
       o.order_time - d.delivery_time AS time_diff,
	   EXTRACT (EPOCH FROM (d.delivery_time-o.order_time + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 Day' ELSE INTERVAL '0 Day' END)) /60 AS time_diff_min
FROM DELIVERIES AS d
LEFT JOIN ORDERS AS o
ON d.order_id = o.order_id
)

SELECT order_id, time_diff_min
from on_time 
WHERE time_diff_min <= 30;

-- 15. Calculate the average order amount for each day of the week.

SELECT EXTRACT(DOW FROM order_date) AS dow,AVG(total_amount) as avg_order_amt
FROM ORDERS
GROUP BY dow
ORDER BY dow;

-- 16. List customers who have placed orders in the last 90 days.

SELECT c.customer_name
FROM CUSTOMERS AS c
INNER JOIN ORDERS AS o
ON c.customer_id = o.customer_id
WHERE o.order_date >= CURRENT_DATE - INTERVAL '590 Days';

-- 17. Get delivery times and statuses for completed deliveries.
-- 18. Find restaurants that have not received any orders.

SELECT r.restaurant_name
FROM RESTAURANTS AS r
WHERE r.restaurant_id NOT IN (
								SELECT o.restaurant_id
								FROM ORDERS AS o
							  );
	

-- 19. Calculate the total number of orders for each month.
-- SELECT EXTRACT(MONTH FROM order_date) AS monthly_data, COUNT(order_id)
SELECT TO_CHAR(order_date, 'YYYY-MM') AS year_month, COUNT(order_id)
FROM ORDERS 
GROUP BY year_month
ORDER BY year_month ASC;

-- 20. Find the order with the longest time from order placement to delivery.
WITH longest_time
AS
(
SELECT o.order_id,o.order_item,
	   EXTRACT (EPOCH FROM (d.delivery_time-o.order_time + CASE WHEN d.delivery_time < o.order_time THEN INTERVAL '1 Day' ELSE INTERVAL '0 Day' END)) /60 AS time_diff_min
FROM DELIVERIES AS d
LEFT JOIN ORDERS AS o
ON d.order_id = o.order_id
)

SELECT order_id, order_item, time_diff_min
from longest_time
WHERE time_diff_min IS NOT NULL
ORDER BY time_diff_min DESC
LIMIT 1;
*/