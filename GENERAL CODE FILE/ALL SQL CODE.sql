CREATE TABLE ex1_customers ( 
	customer_id int PRIMARY KEY NOT NULL,
	customer_name VARCHAR (50) NOT NULL,
	email VARCHAR (50) NOT NULL,
	phone VARCHAR (50) NOT NULL);

CREATE TABLE ex1_products (
	product_id VARCHAR (5) PRIMARY KEY,
	product_name VARCHAR (50) NOT NULL,
	description VARCHAR (255) NOT NULL,
	product_category VARCHAR (50) NOT NULL,
	unit_price NUMERIC (10,2) NOT NULL
);

CREATE TABLE ex1_orders (
	order_id int PRIMARY KEY,
	customer_id int NOT NULL,
	order_date DATE NOT NULL,
	product_id VARCHAR (5) NOT NULL,
	quantity INT NOT NULL,
	delivery_status VARCHAR (15) NOT NULL,
	FOREIGN KEY (customer_id) references ex1_customers (customer_id),
	FOREIGN KEY (product_id) references ex1_products (product_id));


CREATE TABLE ex1_payment (
	payment_id VARCHAR (5) PRIMARY KEY NOT NULL,
	order_id INT NOT NULL,
	payment_date DATE NOT NULL,
	FOREIGN KEY (order_id) references ex1_orders (order_id)
);

-- create unit_cost column and set default value to 0 because of the nut null constraint
ALTER TABLE ex1_products
ADD COLUMN unit_cost NUMERIC(10, 2) NOT NULL DEFAULT 0;

-- fill the unit_cost with the calculated values
UPDATE ex1_products
SET unit_cost = unit_price * 0.95;

-- creating the credit_card table
CREATE TABLE ex1_credit_card(
    credit_card_id VARCHAR(10) NOT NULL PRIMARY KEY,
    customer_id INT NOT NULL,
    card_number VARCHAR(20) NOT NULL,
    card_expiry_date DATE NOT NULL,
    bank_name VARCHAR(50) NOT NULL,
    FOREIGN KEY(customer_id) REFERENCES ex1_customers(customer_id)
);

-- exercise 2 DB queries

------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- creating the customer table
CREATE TABLE ex2_customers ( 
	customer_id INT PRIMARY KEY NOT NULL,
	customer_name VARCHAR (50) NOT NULL,
	customer_address VARCHAR (50) NOT NULL,
	customer_email VARCHAR (50) NOT NULL);
	
-- creating the items table
CREATE TABLE ex2_items(
	item_id INT PRIMARY KEY NOT NULL,
	item_name VARCHAR(50) NOT NULL,
	item_description VARCHAR(250) NOT NULL,
	price NUMERIC(10, 2) NOT NULL
);

-- creating the state table
CREATE TABLE ex2_states(
	state_id INT PRIMARY KEY NOT NULL,
	restaurant_state VARCHAR(50) NOT NULL,
	restaurant_city VARCHAR(50) NOT NULL,
	restaurant_zip_code INT NOT NUll,
	restaurant_address_line1 VARCHAR(250) NOT NULL,
	restaurant_address_line2 VARCHAR(250) NOT NULL
);

-- creating the location table
CREATE TABLE ex2_locations(
	location_id INT PRIMARY KEY NOT NULL,
	state_id INT NOT NULL,
	FOREIGN KEY(state_id) REFERENCES ex2_states(state_id)
);

-- creating the restaturants table
CREATE TABLE ex2_restaurants(
	restaurant_id INT PRIMARY KEY NOT NULL,
	restaurant_name VARCHAR(50) NOT NULL,
	location_id INT NOT NULL,
	state_id INT NOT NULL,
	FOREIGN KEY(location_id) REFERENCES ex2_locations(location_id),
	FOREIGN KEY(state_id) REFERENCES ex2_states(state_id)
);

-- creating the orders table
CREATE TABLE ex2_orders(
	order_id INT PRIMARY KEY NOT NULL,
	restaurant_id INT NOT NULL,
	customer_id INT NOT NULL,
	item_id INT NOT NULL,
	order_quantity INT NOT NULL,
	order_date TIMESTAMP NOT NULL,
	FOREIGN KEY(restaurant_id) REFERENCES ex2_restaurants(restaurant_id),
	FOREIGN KEY(customer_id) REFERENCES ex2_customers(customer_id),
	FOREIGN KEY(item_id) REFERENCES ex2_items(item_id)
);





-- exercise 3 DB queries

------------------------------------------------------------------------------
------------------------------------------------------------------------------

-- Find the highest and lowest priced products along with their prices
SELECT product_name,
		unit_price
FROM ex1_products
where unit_price = (SELECT MAX(unit_price) from ex1_products)
or unit_price = (select MIN(unit_price) from ex1_products);

-- find the total number of orders in each month in the year 2022
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
COUNT(order_id) AS count_of_orders
FROM ex1_orders
where order_date < '2023-01-01'
GROUP BY DATE_PART('MONTH', order_date)
order by count_of_orders DESC;


-- find the average unit price and unit cost for each product category
select product_category,
		round(avg(unit_price), 2) avg_unit_price,
		round(avg(unit_cost), 2) avg_unit_cost
from ex1_products
group by product_category

-- find all orders that were placed on or after august 1, 2022
select *
from ex1_orders
where order_date >= '2022-08-01'
order by order_date;

-- count the number payments made on april 14, 2023
select count(*)
from ex1_payment
where payment_date = '2022-04-14';

-- which customer_id has the highest orders placed in the orders table
select customer_id,
		count(quantity)
from ex1_orders
group by customer_id
order by count(quantity) DESC
limit 1;

-- what is the total number of orders made by each customer_id
select customer_id,
		count(quantity)
from ex1_orders
group by customer_id
order by count(quantity) DESC;

-- how many orders were delivered between jan & feb 2023
select count(*)
from ex1_orders
where order_date between '2023-01-01' and '2023-02-28'
and delivery_status = 'Delivered';

-- retrieve all information associated with the credit cards  that are next to
-- expire from the "credit_card" table
select *
from ex1_credit_card
where card_expiry_date = (select card_expiry_date
                            from ex1_credit_card 
                            where card_expiry_date > current_date 
                            order by card_expiry_date 
                            limit 1);
							
--how many cards have expired
select count(*)
from ex1_credit_card
where card_expiry_date = (select card_expiry_date
                            from ex1_credit_card 
                            where card_expiry_date < current_date 
                            order by card_expiry_date );




----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------
--exercise 4

-- creating the aisle table
CREATE TABLE ex4_aisle(
	aisle_id INT NOT NULL PRIMARY KEY,
	aisle VARCHAR(250) NOT NULL
);

-- creating the dept table
CREATE TABLE ex4_dept(
	department_id INT NOT NULL PRIMARY KEY,
	department VARCHAR(250) NOT NULL
);

-- creating the product table
CREATE TABLE ex4_product(
	product_id INT NOT NULL PRIMARY KEY,
	product_name VARCHAR(250) NOT NULL
);

ALTER TABLE ex4_product
ADD COLUMN aisle_id INT REFERENCES ex4_aisle(aisle_id),
ADD COLUMN department_id INT REFERENCES ex4_dept(department_id);

--inserting the unit_price & unit_cost from the product_cost table
UPDATE ex4_product
SET aisle_id = ex4_orders.aisle_id, department_id = ex4_orders.department_id
FROM ex4_orders
WHERE ex4_product.product_id = ex4_orders.product_id


-- creating the orders table
CREATE TABLE ex4_orders(
	order_id INT NOT NULL PRIMARY KEY,
	user_id INT NOT NULL,
	product_id INT NOT NULL,
	aisle_id INT NOT NULL,
	department_id INT NOT NULL,
	order_dow INT,
	order_hour_of_day INT,
	days_since_prior_order INT,
	FOREIGN KEY(product_id) REFERENCES ex4_product(product_id),
	FOREIGN KEY(aisle_id) REFERENCES ex4_aisle(aisle_id),
	FOREIGN KEY(department_id) REFERENCES ex4_dept(department_id)
);

--- Q1 on what days of the week are condoms mostly sold?
select 
    case order_dow 
        when 0 then 'Sunday'
        when 1 then 'Monday'
        when 2 then 'Tuesday'
        when 3 then 'Wednesday'
        when 4 then 'Thursday'
        when 5 then 'Friday'
        when 6 then 'Saturday'
    end as day_of_week,
    count(order_id) as total_orders
from    ex4_orders o
join ex4_product p on o.product_id = p.product_id
where p.product_name ilike '%Condom%'
group by order_dow
order by total_orders desc
limit 3;


-- Q2 at what time of the day is it mostly sold?
select o.order_hour_of_day,
		count(o.order_id) total_orders
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
where p.product_name ilike '%Condom%'
group by order_hour_of_day
order by total_orders desc
limit 1;


-- Q3 what type of condom do the customers prefer?
select p.product_name,
		count(o.order_id) total_orders
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
where p.product_name ilike '%Condom%'
group by p.product_name
order by total_orders desc
limit 1;

-- Q4 which aisle contains most of the organic products?
select a.aisle,
		count(distinct(o.product_id)) total_products
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
join ex4_aisle a on o.aisle_id = a.aisle_id
where p.product_name ilike '%Organic%'
group by a.aisle
order by total_products desc
limit 1;

-- Q5 which aisle/s can I find all of the non-alcoholic drinks?
select a.aisle,
		count(distinct(o.product_id)) total_products
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
join ex4_aisle a on o.aisle_id = a.aisle_id
where p.product_name ilike '%Non-Alcoholic%' or p.product_name ilike '%Non Alcoholic%'
group by a.aisle
order by total_products desc;


--Exercise 5

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

--Q4 what is the hour of the day with the highest number of orders
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
