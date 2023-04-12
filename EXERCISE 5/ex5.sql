--creating the order_status table
CREATE TABLE order_status(
	order_id INT,
	order_date DATE,
	order_status VARCHAR(50)
);

-- creating the product_cost table
CREATE TABLE product_cost(
	product_id INT,
	unit_price NUMERIC(10,2),
	unit_cost NUMERIC(10,2)
);

-- adding the unit_price & unit_cost column to the old products table
ALTER TABLE ex4_product
ADD COLUMN unit_price NUMERIC(10,2) DEFAULT 0.00,
ADD COLUMN unit_cost NUMERIC(10,2) DEFAULT 0.00;

--inserting the unit_price & unit_cost from the product_cost table
UPDATE ex4_product
SET unit_price = product_cost.unit_price, unit_cost = product_cost.unit_cost
FROM product_cost
WHERE ex4_product.product_id = product_cost.product_id

--adding the order_date column to the old orders table
ALTER TABLE ex4_orders
ADD COLUMN order_date DATE;

--adding the order_status column to the old orders table
ALTER TABLE ex4_orders
ADD COLUMN order_status VARCHAR(50);

--inserting the order_dates from the order_status table
UPDATE ex4_orders
SET order_date = order_status.order_date
FROM order_status
WHERE ex4_orders.order_id = order_status.order_id;

--inserting the order_status from the order_status table
UPDATE ex4_orders
SET order_status = order_status.order_status
FROM order_status
WHERE ex4_orders.order_id = order_status.order_id;


--Q1 how have the orders changed overtime monthly?
SELECT DATE_PART('YEAR', order_date) order_year,
		CASE DATE_PART('MONTH', order_date)
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			WHEN 12 THEN 'December'
		END AS order_month,
		COUNT(order_id) total_orders
FROM ex4_orders
GROUP BY DATE_PART('YEAR', order_date), DATE_PART('MONTH', order_date)
--OR
SELECT CASE DATE_PART('MONTH', order_date)
			WHEN 1 THEN 'January'
			WHEN 2 THEN 'February'
			WHEN 3 THEN 'March'
			WHEN 4 THEN 'April'
			WHEN 5 THEN 'May'
			WHEN 6 THEN 'June'
			WHEN 7 THEN 'July'
			WHEN 8 THEN 'August'
			WHEN 9 THEN 'September'
			WHEN 10 THEN 'October'
			WHEN 11 THEN 'November'
			WHEN 12 THEN 'December'
		END AS order_month,
		COUNT(order_id) total_orders
FROM ex4_orders
GROUP BY DATE_PART('MONTH', order_date);

--Q2 are there any weekly fluctuations in the size of the orders?
SELECT DATE_PART('YEAR', order_date) order_year,
		CONCAT('Week ', DATE_PART('WEEK', order_date)) order_week,
		COUNT(order_id) total_orders
FROM ex4_orders
GROUP BY DATE_PART('YEAR', order_date),DATE_PART('WEEK', order_date);

--Q3 what is the average number of orders placed by day of week?
SELECT CASE order_dow
        	WHEN 0 THEN 'Sunday'
        	WHEN 1 THEN 'Monday'
        	WHEN 2 THEN 'Tuesday'
        	WHEN 3 THEN 'Wednesday'
        	WHEN 4 THEN 'Thursday'
        	WHEN 5 THEN 'Friday'
        	WHEN 6 THEN 'Saturday'
    	END AS order_day_of_week,
		 (SELECT COUNT(*) FROM ex4_orders) / COUNT(*) avg_weekly_orders
FROM ex4_orders
GROUP BY order_day_of_week
ORDER BY avg_weekly_orders;

--Q4 what is the hour of the day with thee highest number of orders
SELECT order_hour_of_day,
		COUNT(order_id) total_orders
FROM ex4_orders
GROUP BY order_hour_of_day
ORDER BY total_orders DESC
LIMIT 1;

--Q5 which dept has the highest average spend per customer?
SELECT d.department,
		ROUND(AVG(p.unit_price), 2) avg_spend
FROM ex4_orders o
JOIN ex4_product p ON o.product_id = p.product_id
JOIN ex4_dept d ON o.department_id = d.department_id
GROUP BY d.department
ORDER BY avg_spend DESC
LIMIT 1;

--Q6 which product generated more profit?
SELECT p.product_name,
		SUM(p.unit_price - p.unit_cost) profit
FROM ex4_orders o
JOIN ex4_product p ON o.product_id = p.product_id
GROUP BY p.product_name
ORDER BY profit DESC
LIMIT 1;

--Q7 what are the 3 ailes with the most order, and which dept do they belong to?
SELECT a.aisle,
		d.department,
		COUNT(o.order_id) total_orders
FROM ex4_orders o
JOIN ex4_aisle a ON o.aisle_id = a.aisle_id
JOIN ex4_dept d ON o.department_id = d.department_id
GROUP BY a.aisle, d.department
ORDER BY total_orders DESC
LIMIT 3;

--Q8 which 3 users generated the highest revenue, and how many aisle did they order from?
SELECT o.user_id,
		COUNT(o.aisle_id) number_of_aisle,
		SUM(p.unit_price) total_revenue
FROM ex4_orders o
JOIN ex4_aisle a ON o.aisle_id = a.aisle_id
JOIN ex4_product p ON o.product_id = p.product_id
GROUP BY o.user_id
ORDER BY total_revenue DESC
LIMIT 3;
