-- Q1 on what days of the week are condoms mostly sold?
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
where p.product_name like '%Condom%'
group by order_dow
order by total_orders desc;


-- Q2 at what time of the day is it mostly sold?
select o.order_hour_of_day,
		count(o.order_id) total_orders
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
where p.product_name like '%Condom%'
group by order_hour_of_day
order by total_orders desc
limit 1;


-- Q3 what type of condom do the customers prefer?
select p.product_name,
		count(o.order_id) total_orders
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
where p.product_name like '%Condom%'
group by p.product_name
order by total_orders desc
limit 1;

-- Q4 which aisle contains most of the organic products?
select a.aisle,
		count(distinct(o.product_id)) total_products
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
join ex4_aisle a on o.aisle_id = a.aisle_id
where p.product_name like '%Organic%'
group by a.aisle
order by total_products desc
limit 1;

-- Q5 which aisle/s can I find all of the non-alcoholic drinks?
select a.aisle,
		count(distinct(o.product_id)) total_products
from ex4_orders o
join ex4_product p on o.product_id = p.product_id
join ex4_aisle a on o.aisle_id = a.aisle_id
where p.product_name like '%Non Alcoholic%'
group by a.aisle
order by total_products desc