CREATE TABLE CUSTOMERS 
	(
		customer_id INT PRIMARY KEY,
		customer_name VARCHAR(30),
		reg_date DATE
	);

CREATE TABLE RESTAURANTS 
	(
		restaurant_id INT PRIMARY KEY,
		restaurant_name VARCHAR(55),
		city VARCHAR(25),
		opening_hours VARCHAR(55)
	);

CREATE TABLE ORDERS
	(
		order_id INT PRIMARY KEY,
		customer_id INT,
		restaurant_id INT,
		order_item VARCHAR(25),
		order_date DATE,
		order_time TIME,
		order_status VARCHAR(20),
		total_amount FLOAT 
	);

ALTER TABLE ORDERS 
ADD CONSTRAINT fk_customers
FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id);

ALTER TABLE ORDERS 
ADD CONSTRAINT fk_restuarants
FOREIGN KEY (restaurant_id) REFERENCES RESTAURANTS(restaurant_id);


CREATE TABLE RIDERS
	(
		rider_id INT PRIMARY KEY,
		rider_name VARCHAR(25),
		sign_up DATE
	);

DROP TABLE IF EXISTS DELIVERIES;
CREATE TABLE DELIVERIES
	(
		delivery_id INT PRIMARY KEY,
		order_id INT,
		delivery_status VARCHAR(40),
		delivery_time TIME,
		rider_id INT,
		CONSTRAINT fk_orders FOREIGN KEY (order_id) REFERENCES ORDERS(order_id),
		CONSTRAINT fk_riders FOREIGN KEY (rider_id) REFERENCES RIDERS(rider_id)
	);

--END OF SCHEMAS





	