--creating the order_status table
CREATE TABLE order_status(
	order_id INT,
	order_date DATE,
	order_status VARCHAR(50)
);

CREATE TABLE product_cost(
	product_id INT,
	unit_price NUMERIC(10,2),
	unit_cost NUMERIC(10,2)
);

-- add unit price column to products table
ALTER TABLE ex4_product
ADD COLUMN unit_price NUMERIC(10,2) DEFAULT 0.00;

-- add unit price column to products table
ALTER TABLE ex4_product
ADD COLUMN unit_cost NUMERIC(10,2) DEFAULT 0.00;

-- insert unit price data from product_cost table
UPDATE ex4_product
SET unit_price = product_cost.unit_price
FROM product_cost
WHERE ex4_product.product_id = product_cost.product_id

-- insert unit cost data from product_cost table
UPDATE ex4_product
SET unit_cost = product_cost.unit_cost
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

-- inserting the order_status from the order_status table
UPDATE ex4_orders
SET order_status = order_status.order_status
FROM order_status
WHERE ex4_orders.order_id = order_status.order_id;

-- Q1 how have the orders changed overtime monthly?
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
GROUP BY DATE_PART('MONTH', order_date)

-- Q2 are there any weekly fluctuations in the size of the orders?
SELECT DATE_PART('WEEK', order_date) AS order_week,
		COUNT(order_id) AS total_orders
FROM ex4_orders
GROUP BY DATE_PART('WEEK', order_date);

-- Q3 What is the average number of orders placed by day of the week

WITH 
	cte AS (
  SELECT 
  	CASE order_dow
     	WHEN 0 THEN 'Sunday'
      	WHEN 1 THEN 'Monday'
     	WHEN 2 THEN 'Tuesday'
     	WHEN 3 THEN 'Wednesday'
     	WHEN 4 THEN 'Thursday'
      	WHEN 5 THEN 'Friday'
      	WHEN 6 THEN 'Saturday'
    END AS day_of_week,
  COUNT(order_id) AS total_orders
  FROM ex4_orders
  GROUP BY day_of_week
)
SELECT day_of_week, ROUND(AVG(total_orders)) AS average_num_orders
FROM cte
GROUP BY day_of_week
ORDER BY 
     CASE
          WHEN day_of_week = 'Sunday' THEN 1
          WHEN day_of_week = 'Monday' THEN 2
          WHEN day_of_week = 'Tuesday' THEN 3
          WHEN day_of_week = 'Wednesday' THEN 4
          WHEN day_of_week = 'Thursday' THEN 5
          WHEN day_of_week = 'Friday' THEN 6
          WHEN day_of_week = 'Saturday' THEN 7
     END ASC;
	 
-- Q4 What is the hour of the day with the highest number of orders?


SELECT order_hour_of_day, COUNT(order_id) AS number_of_orders
FROM ex4_orders
GROUP BY order_hour_of_day
ORDER BY number_of_orders DESC
LIMIT 1;

-- Q5 Which department has the highest average spend per customer?

WITH cte AS (
	SELECT 
		department, 
		COUNT(user_id) AS total_customers, 
		SUM(unit_price) AS revenue
	FROM ex4_dept d
	INNER JOIN ex4_orders o
	ON d.department_id = o.department_id
	INNER JOIN ex4_product p
	ON o.product_id = p.product_id
	GROUP BY department)
SELECT department, ROUND((revenue/total_customers),2) AS average_spend
FROM cte
ORDER BY average_spend DESC
LIMIT 1;

-- Which product generate more profit?

SELECT *
FROM ex4_product

ALTER TABLE ex4_product
ADD COLUMN profit NUMERIC(10,2);

UPDATE ex4_product
SET profit = unit_price - unit_cost
WHERE profit IS NULL;

SELECT product_name, profit
FROM ex4_product
ORDER BY profit DESC
LIMIT 10;

-- Q7 What are the 3 aisles with the most orders, and which departments do those orders belong to?

SELECT aisle, COUNT(order_id) AS total_orders, department
FROM ex4_orders o
JOIN ex4_aisle a
ON o.aisle_id = a.aisle_id
JOIN ex4_dept d
ON o.department_id = d.department_id
GROUP BY aisle, department
ORDER BY total_orders DESC
LIMIT 4;

-- Q8 Which 3 users generated the highest revenue and how many aisles did they order from?

SELECT 
	o.user_id, 
	SUM(unit_price) AS total_revenue,
	COUNT(DISTINCT(o.aisle_id)) AS num_aisles
FROM ex4_orders o
JOIN ex4_aisle a
ON o.aisle_id = a.aisle_id
JOIN ex4_product p
ON o.product_id = p.product_id
GROUP BY user_id
ORDER BY total_revenue DESC
LIMIT 3;
