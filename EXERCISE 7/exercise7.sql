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