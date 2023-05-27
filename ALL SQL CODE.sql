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
----------------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--exercise 6

--creating the disaster table
CREATE TABLE disaster(
	Year INT,
	Disaster_Group VARCHAR(255),	
	Disaster_Subgroup VARCHAR(255),
	Disaster_Type VARCHAR(255),
	Disaster_Subtype VARCHAR(255),
	ISO VARCHAR(255),
	Region VARCHAR(255),
	Continent VARCHAR(255),
	Origin VARCHAR(255),
	Associated_Disaster VARCHAR(255),
	OFDA_Response VARCHAR(255),
	Disaster_Magnitude_Value INT,
	Latitude VARCHAR(255),
	Longitude VARCHAR(255),
	Start_Year VARCHAR(255),	
	End_Year VARCHAR(255),
	Total_Deaths	INT,
	No_Injured INT,
	No_Affected INT,
	No_Homeless INT,
	Total_Affected INT,
	Total_Damages_USD INT,
	Total_Damages_Adjusted_USD INT,
	Country VARCHAR(255),
	Location VARCHAR(255)
);


--Q1 what are the top 5 most common type of disaster?
SELECT disaster_type,
		COUNT(disaster_type) total_occurence
FROM disaster
GROUP BY disaster_type
ORDER BY total_occurence DESC
LIMIT 5;

--INSIGHT:::Flood is the most common type of disaster

--Q2 what are the top 5 types of disasters with the highest number of recorded deaths?
SELECT disaster_type,
		SUM(total_deaths) total_deaths
FROM disaster
GROUP BY disaster_type
ORDER BY total_deaths DESC
LIMIT 5;

--INSIGHT:::Earthquakes have the highest number of recorded deaths

--Q3 what country is affected by disasters the most?
WITH occurence AS(
	SELECT country,
		COUNT(disaster_type) total_occurence,
		SUM(total_deaths) total_deaths
	FROM disaster
	GROUP BY country, disaster_type
	ORDER BY total_occurence DESC
)
SELECT country,
		SUM(total_occurence) total_occurence,
		SUM(total_deaths) total_deaths
FROM occurence
GROUP BY country
ORDER BY total_deaths DESC
LIMIT 1;

--INSIGHT:::Indonesia is the country affected the most by disaster

--Q4 which year has the highest number of recorded disasters?
SELECT year,
		COUNT(*) total_occurence
FROM disaster
GROUP BY year
ORDER BY total_occurence DESC
LIMIT 1;
--INSIGHT:::2006 recorded the most amount of disasters

--Q5 which 5 disaster types cost more in total damages?
SELECT disaster_type,
		ROUND(AVG(total_damages_adjusted_usd),2) average_damages_amount
FROM disaster
WHERE total_damages_adjusted_usd IS NOT NULL
GROUP BY disaster_type
ORDER BY average_damages_amount DESC
LIMIT 5;
--INSIGHT:::Wildfire cost more in damages, I really thought it would be Earthquakes tho.

--Q6 what is the disaster type with the highest magnitude on average?
SELECT disaster_type,
		ROUND(AVG(disaster_magnitude_value),2) average_disaster_magnitude
FROM disaster
WHERE disaster_magnitude_value IS NOT NULL
GROUP BY disaster_type
ORDER BY average_disaster_magnitude DESC
LIMIT 5;
--INSIGHT:::Epidemic has the highest magnitude on average


--INSIGHTS
--Flood is the most common type of disaster
--Earthquakes have the highest number of recorded deaths
--Indonesia is the country affected the most by disaster
--2006 recorded the most amount of disasters
--Wildfire cost more in damages, I really thought it would be Earthquakes tho.
--Epidemic has the highest magnitude on average

--RECCOMENDATIONS
--Develop and implement disaster preparedness and response plans to reduce the impact of Earthquakes, Wildfires & Floods.
--Invest in infrastructures, medical facilities and technology that can help protect countries from Epidemics or other high magnitude disasters
--Increase financial and technical assistance to low-income countries like Indonesia to help them adapt to the impacts of disasters.


SELECT p.product_name, sum (p.unit_price * o.quantity) as total_sales
From ex1_orders o 
JOIN ex1_products p ON o.product_id=p.product_id
GROUP BY p.product_name
ORDER BY total_sales ASC
LIMIT 10


----------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------
Exercise 7
-- KPIs
SELECT *
FROM products

SELECT *
FROM orders

SELECT *
FROM payment

SELECT *
FROM customers

-- Revenue by month
SELECT CASE DATE_PART('Month', py.payment_date)
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
END AS months, ROUND(AVG(p.unit_price * o.quantity),2) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id = o.product_id
JOIN payment py
ON o.order_id = py.order_id
GROUP BY DATE_PART('Month', py.payment_date)
ORDER BY DATE_PART('Month', py.payment_date);

/* INSIGHT: Sales revenue seems to be unchanging. 
   RECOMMENDATION: The marketing team can run promotions to create awareness about new features in new versions of products. 
*/

-- Top 5 best selling products
SELECT p.product_name, ROUND(AVG(p.unit_price * o.quantity),2) AS total_sales, p.unit_price - p.unit_cost AS profit
FROM products p
JOIN orders o
ON p.product_id = o.product_id
JOIN payment py
ON o.order_id = py.order_id
GROUP BY p.product_name, p.unit_price - p.unit_cost
ORDER BY total_sales DESC
LIMIT 5;

/* 	INSIGHTS Apple Macbook Pro M2 is the best selling and the most profitable product. 
	RECOMMENDATION The HP Gaming 15 is the least profitable among the 5 but comes 3rd. This would suggest that there is high demand 
	for it. We can focus on promoting it more. 
*/

-- Bottom 5 selling products
SELECT p.product_name, ROUND(AVG(p.unit_price * o.quantity),2) AS total_sales, p.unit_price - p.unit_cost AS profit
FROM products p
JOIN orders o
ON p.product_id = o.product_id
JOIN payment py
ON o.order_id = py.order_id
GROUP BY p.product_name, p.unit_price - p.unit_cost
ORDER BY total_sales ASC
LIMIT 5;

/* 	INSIGHT Chargers and cables are not making much revenue. It could be because people don't frequently replace these. 
	RECOMMENDATION Pair them with complementary products that generate high revenue e.g. Apple Macbook Pro M2 and lightning cable 
	at a discounted price.
*/


-- Top 5 customers generating the most revenue in March 2023

SELECT c.customer_name, ROUND(AVG(p.unit_price * o.quantity),2) AS total_sales
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payment py
ON o.order_id = py.order_id
JOIN products p
ON p.product_id = o.product_id
GROUP BY c.customer_name
ORDER BY total_sales DESC
LIMIT 5;

/* 	INSIGHT Kenneth Maize is the customer who brings in the most sales. 
	RECOMMENDATION There should be a reward system for top customers who generate more revenue. E.g special discounts and offers
*/

-- Customers who have not placed any orders
SELECT c.customer_name
FROM customers c
LEFT JOIN orders o
ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Total Revenue by 2022 Quarter

SELECT CASE DATE_PART('Quarter', py.payment_date)
	WHEN 1 THEN 'Q1'
	WHEN 2 THEN 'Q2'
	WHEN 3 THEN 'Q3'
	WHEN 4 THEN 'Q4'
END AS quarter, SUM(p.unit_price * o.quantity) AS total_revenue
FROM products p
JOIN orders o
ON p.product_id = o.product_id
JOIN payment py
ON o.order_id = py.order_id
WHERE py.payment_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY DATE_PART('Quarter', py.payment_date)
ORDER BY DATE_PART('Quarter', py.payment_date);

/* 	INSIGHT Q2 & Q3 is the best selling period. 
	RECOMMENDATION Observe and gather more data for 2023 quarters to have a better understanding of the sales trend per quarter.
*/

======================================================================================================================================================
Exercise 8
CREATE TABLE nps_data (
  id SERIAL PRIMARY KEY,
  product_id INTEGER,
  nps_score INTEGER,
FOREIGN KEY (product_id) references products(product_id)
);

select * from nps_data


select p.product_id, p.product_name, nps_score
from nps_data n
join products p using (product_id)



WITH nps_summary AS (
  SELECT 
    p.product_id, p.product_name, 
    COUNT(*) AS total_responses,
    SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) AS detractors,
    SUM(CASE WHEN nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) AS passives,
    SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) AS promoters
  FROM nps_data n
	JOIN products p on n.product_id = p.product_id
  GROUP BY 1, 2
)
SELECT 
  product_id,
  product_name,
  total_responses,
  detractors,
  passives,
  promoters,
  ROUND(100 * (promoters - detractors) / total_responses::numeric, 2) || '%' AS nps_score,
  ROUND(100 * passives / total_responses::numeric, 2) || '%' AS passive_respondents
FROM nps_summary;


======================================================================================================================================================
EXERCISE 9

--creating temp customers data
CREATE TEMPORARY TABLE temp_customers(
	customer_id	INT,
	customer_name VARCHAR(50),
	email VARCHAR(50),
	phone VARCHAR(50),
	dob DATE,
	gender VARCHAR(50),
	country VARCHAR(50),
	city VARCHAR(50)
);


--importing new customers data to the temp table
COPY temp_customers(customer_id, customer_name, email, phone,
					   dob, gender, country, city)
FROM 'C:/Users/Kola Ademola/Downloads/bootcamp/sql/ex1/ex1_customers_data.csv'
DELIMITER ','
CSV HEADER;

--update customer data
ALTER TABLE ex1_customers
ADD COLUMN dob DATE,
ADD COLUMN gender VARCHAR(5),
ADD COLUMN country VARCHAR(25),
ADD COLUMN city VARCHAR(50);

--populate customers data
UPDATE ex1_customers e
SET dob = t.dob, gender = t.gender, country = t.country, city = t.city
FROM temp_customers t
WHERE e.customer_id = t.customer_id;

-- insert the new customers
INSERT INTO ex1_customers
SELECT *
FROM temp_customers t
WHERE t.customer_id > 100;

--create temp card table
CREATE TEMPORARY TABLE temp_cards(
	credit_card_id TEXT,
	customer_id INT,
	card_number TEXT,
	card_expiry_date DATE,
	bank_name TEXT
);

--import new data to the temp table
COPY temp_cards(credit_card_id, customer_id, card_number, card_expiry_date, bank_name)
FROM 'C:/Users/Kola Ademola/Downloads/bootcamp/sql/ex1/ex1_credit_card_data.csv'
DELIMITER ','
CSV HEADER;

--populate existing table with temp data
INSERT INTO ex1_credit_card
SELECT *
FROM temp_cards
WHERE customer_id > 100


--create temp table
CREATE TEMPORARY TABLE temp_orders(
	order_id INT,
	customer_id INT,
	order_date DATE,
	product_id TEXT,
	quantity INT,
	delivery_status TEXT
)

--import new data to the temp table
COPY temp_orders(order_id, customer_id, order_date, product_id,
				quantity, delivery_status)
FROM 'C:/Users/Kola Ademola/Downloads/bootcamp/sql/ex1/ex1_order_data.csv'
DELIMITER ','
CSV HEADER;

--populate existing table with temp data
INSERT INTO ex1_orders
SELECT *
FROM temp_orders
WHERE order_id > 90600

--create temp table
CREATE TEMPORARY TABLE temp_payment(
	payment_id TEXT,
	order_id INT,
	payment_date DATE
)

--import new data to the temp table
COPY temp_payment(payment_id, order_id, payment_date)
FROM 'C:/Users/Kola Ademola/Downloads/bootcamp/sql/ex1/ex1_payment_data.csv'
DELIMITER ','
CSV HEADER;

--populate existing table with temp data
INSERT INTO ex1_payment
SELECT *
FROM temp_payment
WHERE order_id > 90600

----------------------------------------------------

--GENDER SEGMENTATION
SELECT CASE gender
			WHEN 'M' THEN 'Male Customers'
			ELSE 'Female Customers'
		END gender_segment,	
		COUNT(*) num_of_customers
FROM ex1_customers
GROUP BY gender_segment;

--GENDER PREFRENCE
WITH gender_prefrence AS(
    SELECT CASE gender
                WHEN 'M' THEN 'Male Customers'
                ELSE 'Female Customers'
            END gender_segment,
            p.product_name,
			COUNT(*) num_of_orders,
            ROW_NUMBER() OVER (PARTITION BY CASE gender
                								WHEN 'M' THEN 'Male Customers'
                								ELSE 'Female Customers' END 
							   ORDER BY COUNT(*) DESC) AS level_of_prefrence
    FROM ex1_customers c
    JOIN ex1_orders o ON c.customer_id = o.customer_id
    JOIN ex1_products p ON o.product_id = p.product_id
    GROUP BY gender_segment, p.product_name
)
SELECT gender_segment, product_name, num_of_orders
FROM gender_prefrence
WHERE level_of_prefrence <= 3
GROUP BY gender_segment, product_name, num_of_orders
ORDER BY gender_segment, num_of_orders DESC;
/* MARKETING CAMPAIGN STRATEGY
Both Male & Female Customers: Focus on promoting new and prefered products such as; iPhone's & Laptops or similar products
and complimentary products like; Lightning Cable & Chargers, Implement loyalty programs to encourage long-term engagement and repeat purchases.
*/

--LOCATION SEGMENTATION
SELECT CONCAT(city, ' Customers') location_segment,
		COUNT(*) num_of_customers
FROM ex1_customers
GROUP BY city
ORDER BY num_of_customers DESC;

--LOCATION PREFERENCE
WITH location_prefrence AS(
    SELECT CONCAT(city, ' Customers') location_segment,
            p.product_category,
			COUNT(*) num_of_orders,
            ROW_NUMBER() OVER (PARTITION BY CONCAT(city, ' Customers') ORDER BY COUNT(*) DESC) AS level_of_prefrence
    FROM ex1_customers c
    JOIN ex1_orders o ON c.customer_id = o.customer_id
    JOIN ex1_products p ON o.product_id = p.product_id
    GROUP BY location_segment, p.product_category
)
SELECT location_segment, product_category, num_of_orders
FROM location_prefrence
WHERE level_of_prefrence = 1
GROUP BY location_segment, product_category, num_of_orders;

/* MARKETING CAMPAIGN STRATEGY
Target customers in specific cities with localized marketing campaigns,
highlighting products or services tailored to their needs or local events eg Promote Mobile Phones in Aba, Abeokuta etc,
Promote Laptops in Bauchi, Benin City etc. Offer location-based promotions, discounts to enhance customer engagement.
*/

--AGE GROUP SEGMENTATION
SELECT CONCAT(CASE
		WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 20 AND 30 THEN 'Young Adult'
		WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 31 AND 40 THEN 'Adult'
		ELSE 'Senior'
	   END, ' Customers') age_group_segment,
	   COUNT(*) num_of_customers
FROM ex1_customers
GROUP BY age_group_segment;

--AGE GROUP PREFRENCE
WITH age_prefrence AS(
	SELECT CONCAT(CASE
			WHEN EXTRACT(YEAR FROM AGE(c.dob)) BETWEEN 20 AND 30 THEN 'Young Adult'
			WHEN EXTRACT(YEAR FROM AGE(c.dob)) BETWEEN 31 AND 40 THEN 'Adult'
			ELSE 'Senior'
		   END, ' Customers') age_group_segment,	  
		   p.product_name,
		   COUNT(*) num_of_orders,
		   ROW_NUMBER() OVER (PARTITION BY CONCAT(CASE
	          WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 20 AND 30 THEN 'Young Adult'
	          WHEN EXTRACT(YEAR FROM AGE(dob)) BETWEEN 31 AND 40 THEN 'Adult'
	          ELSE 'Senior'
	        END, ' Customers') ORDER BY COUNT(*) DESC) AS level_of_prefrence
	FROM ex1_customers c
	JOIN ex1_orders o ON c.customer_id = o.customer_id
	JOIN ex1_products p ON o.product_id = p.product_id
	GROUP BY age_group_segment, p.product_name
	ORDER BY level_of_prefrence
)
SELECT age_group_segment, product_name, num_of_orders
FROM age_prefrence
WHERE level_of_prefrence <= 3
GROUP BY age_group_segment, product_name, num_of_orders
ORDER BY age_group_segment, num_of_orders DESC;

/* MARKETING CAMPAIGN STRATEGY
Young Adult Customers: Focus on promoting new and prefered products such as; iPhones & Acer Nitro 5/ other laptops and complimentary products like; Chargers & Gamepads,
offer exclusive discounts or limited-time offers for this segment, and provide incentives for continous patronage.
Adult Customers: Focus on promoting new and prefered products such as; iPhones or similar and complimentary products like; Lightning Cable,
Implement loyalty programs to encourage long-term engagement and repeat purchases.
Senior Customers: Focus on promoting new and prefered products such as; iPhone X or similar product and complimentary products like; Lightning Cable,
tailored recommendations, or loyalty rewards to foster a sense of care and appreciation.
*/


--PRODUCT CATEGORY SEGMENTATION
SELECT CONCAT(p.product_category, ' Buyers') product_category_segment,
		COUNT(DISTINCT o.customer_id) num_of_customers
FROM ex1_products p
JOIN ex1_orders o ON p.product_id = o.product_id
GROUP BY p.product_category;
/* MARKETING CAMPAIGN STRATEGY
Create targeted ads for each product category based on customer preferences. For example,
if a particular product category has a high number of buyers, focus on promoting related products or offering discounts on those items.
Highlight new arrivals or product updates, offer bundle deals or package discounts, and showcase customer testimonials or reviews to build trust and confidence.
*/

--CUSTOMER SPENDING SEGMENTATION
WITH segment AS(
	SELECT c.customer_name,
			CONCAT('$', SUM(p.unit_price * o.quantity)) total_spending,
			CASE
			 WHEN SUM(p.unit_price * o.quantity) >= 15000 THEN 'Big Spender'
			 WHEN SUM(p.unit_price * o.quantity) BETWEEN (SELECT AVG(p.unit_price * o.quantity)
														  FROM ex1_orders o
														  JOIN ex1_products p ON o.product_id = p.product_id)
												AND 15000 THEN 'Average Spender'
			 ELSE 'Low Spender'
			END spending_segment
	FROM ex1_orders o
	JOIN ex1_customers c ON o.customer_id = c.customer_id
	JOIN ex1_products p ON o.product_id = p.product_id
	GROUP BY c.customer_name
	ORDER BY SUM(p.unit_price * o.quantity) DESC
)
SELECT spending_segment,
		COUNT(*) num_of_customers
FROM segment
GROUP BY spending_segment;
/* MARKETING CAMPAIGN STRATEGY
Big Spenders: Provide exclusive access to new products or services, offer personalized recommendations based on their preferences,
and create VIP loyalty programs with exclusive benefits or rewards.
Average Spenders: Implement tiered loyalty programs with incremental rewards, offer limited-time promotions or flash sales,
and provide personalized recommendations based on their purchase history.
Low Spenders: Develop targeted promotions or discounts to encourage higher spending, introduce referral programs to incentivize customer acquisition,
and focus on upselling or cross-selling strategies.
*/

--CUSTOMER ACTIVITY SEGMENTATION
WITH segment AS(
	SELECT c.customer_name,
			CASE 
			 WHEN ('2024-01-01'::DATE - MAX(order_date)) <= 1 THEN CONCAT(('2024-01-01'::DATE - MAX(order_date)), ' day ago')
			 ELSE CONCAT(('2024-01-01'::DATE - MAX(order_date)), ' days ago')
			END days_since_last_purchase, 
			CASE
			 WHEN ('2024-01-01'::DATE - MAX(order_date)) BETWEEN 0 AND 90 THEN 'Active Customers'
			 WHEN ('2024-01-01'::DATE - MAX(order_date)) BETWEEN 91 AND 365 THEN 'Dormant Customers'
			 ELSE 'Inactive Customers'
			END activity_segment
	FROM ex1_orders o
	JOIN ex1_customers c ON o.customer_id = c.customer_id
	GROUP BY c.customer_name
	ORDER BY ('2024-01-01'::DATE - MAX(order_date))
)
SELECT activity_segment,
		COUNT(*) num_of_customers
FROM segment
GROUP BY activity_segment;

/* MARKETING CAMPAIGN STRATEGY
Active Customers: Keep them engaged by sharing new products/sneak peeks with them, exlusive rewards for their loyalty, early access to any upcoming sales / promotion.
Dormant Customers: Re-engage dormant customers by offering personalized promotions, reminding them of their previous purchases, or providing incentives to return.
Inactive Customers: Develop win-back campaigns with compelling offers, discounts, or limited-time promotions to reactivate inactive customers.
*/