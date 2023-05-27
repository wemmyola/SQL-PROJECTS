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