-- DELETE FROM  fashion 
-- SET SEARCH PATH TO fashion_analysis

-----                                      FASHION ANALYSIS

-----                                    Data cleaning steps/ Process 
-- 1 checked if the customer_name,shop_outlet are standardized ie capitalized 
-- using the INITCAP

-- 2. to check for datatype in postgresql 
select* 
from information_schema.columns
where table_schema='fashion_analysis'
  and table_name = 'fashion'
  
-- 3.To check for null values in the columns 
SELECT *
FROM fashion
WHERE 
  category IS NULL OR TRIM(category) = '' OR
  price IS NULL OR TRIM(price) = '' OR
  clothing_type IS NULL OR TRIM(clothing_type) = '' OR
  discount IS NULL OR TRIM(discount) = '' OR
  shop_outlet IS NULL OR TRIM(shop_outlet) = '' OR
  delivery_date IS NULL OR TRIM(delivery_date) = '' OR
  order_date IS NULL OR TRIM(order_date) = '' OR
  revenue IS NULL OR TRIM(revenue) = '' OR
  customer_name IS NULL OR TRIM(customer_name) = '' OR
  customer_email IS NULL OR TRIM(customer_email) = '';
    
----4 check the number of rows 
select count(*) as total_rows
from fashion


--- 5 checking for duplicates in customer_email / so the unique values our dataset.
 select count(customer_email),customer_email
 from fashion 
 group by customer_email
 having count(customer_email)>=1

---- 6 ---1st rename category to clothingtype1
alter table fashion rename category to clothingtype1
--- then rename clothing type to category 
alter table fashion rename clothing_type to category 
---renaming it to the initial column name 
alter table fashion rename clothingtype1 to clothing_type
 
---                                     QUESTION TO CONSIDER TO 
 --- the shop_outlet with the highest revenue
 --- the average discount.
--- total sales per category
--- How many deliveries are  made  between the earliest and latest day.
---select sum (revenue) as total_sales from fashion sum of the revenue.
--7 What is the most common hour of the day for orders to be created?
select date_part('hour',order_date) as hour,count(*)
from fashion
group by  hour 
order by count desc 
limit 1;
--- the difference between the order date and delivery date
select shop_outlet,customer_name,clothing_type,(delivery_date - order_date) AS duration
 FROM fashion
 group by 1,2,3,4
 order by duration desc
 limit 10 ;


set search_path to fashion_analysis
---checking for the earliest minimum date and latest order day 
select min(order_date) as earliest_order_date,
       max(order_date) as latest_order_date
from fashion ;   

 
  ---                                          Analysis

SET search_path TO fashion_analysis
select * from fashion
   

-- Step 2: Perform the Following Analysis

--Question 2a) Sales Analysis
--i) Identify the top 5 selling products.
select category,sum(revenue) as total_sales
from fashion
group by 1
order by total_sales desc
--limit 5;

--i) Identify the top to selling products.
select category,clothing_type, count(*) as total_orders
from fashion
group by 1,2
order by total_orders desc 
--limit 6;


--investigating_date  delivery date and order date
--- datediff WHERE DATESUB(order_date, delivery_date) < 0
select *
from fashion 
where order_date > delivery_date


update fashion 
set order_date=delivery_date,
    delivery_date = order_date 
where order_date> delivery_date;

select *
from fashion 
where delivery_date > order_date 


--ii) Determine the monthly trend of total sales.
select extract (month from order_date)as month_order,sum(revenue) as total_sales 
from fashion
group by month_order
order by total_sales desc;

-- option (b)
select to_char(order_date,'month') as order_month, extract(year from order_date)as order_year,sum(revenue) as total_sales,
from fashion
group by order_month,order_year
order by total_sales desc;


---- total/discount per year 
select to_char(order_date,'month') as order_month, extract(year from order_date)as order_year,sum(discount) as total_discount
from fashion
group by order_month,order_year
order by total_discount desc;

select  extract(year from order_date)as order_year,sum(revenue) as total_sales
from fashion
group by order_year
order by total_sales desc;


select min(order_date) from fashion
select max(order_date) from fashion


-- Question  Analyze sales distribution by day of the week.
select extract(dow from order_date) as day_of_week,sum(revenue) as total_sales
from fashion
group  by day_of_week
order by total_sales desc;

select to_char(order_date,'day') as day_of_week,sum(revenue) as total_sales
from fashion 
group by day_of_week 
order by total_sales desc;

select* from fashion

--- Step B. Customer Insights
--- B(i)List the top 10 customers by revenue.
select customer_name,customer_email,category,sum(revenue) as total_revenue
from fashion
group by 1,2,3
order by total_revenue desc
limit 10;


-- ii).Compare the number of repeat vs new customers.

select customer_category,count(*) as no_of_customers
from 
(select count(*) as no_of_customers, customer_name,
case 
	 when count(*)=1 then 'new'
	 when count(*)>1 then 'repeat'
end as customer_category
from fashion
group by customer_name)
group by customer_category;


--- to get the number of distinct shop_outlet 
select count(distinct shop_outlet) from fashion
-- iii) Identify locations with most active buyers (if applicable).
select shop_outlet,count(order_date) as no_of_visits
from fashion
group by shop_outlet
order by no_of_visits desc
limit 10;
---when we add category when retrieving data from our table.
select distinct(shop_outlet),count(order_date) as no_of_visits,category as active_category
from fashion
order by no_of_visits desc;



select * from fashion
-- step 2C.Time-Based Analysis

--- 2c i) Question.Compare sales between weekdays and weekends.
--1,2,3,4,5 - weekdays  (6 & 0 weekends)
-- using extract 
select revenue as total_sales,order_date,
case
	when extract(dow from order_date) in (1,2,3,4,5) then 'Weekday'
	when extract(dow from order_date) in (0,6) then 'Weekend'
end as day_category
from fashion;
-- be observant while using to_char :
         --the spaces while writing the date down use Trim
         --the else statement may not output the required statement
         --the way month appear  in ur dataset short form or 
              
--- using to_char 
select 
case
	when Trim (to_char(order_date,'day')) in ('monday','tuesday','wednesday','thursday','friday') then 'Weekday'
	when Trim (to_char(order_date,'day')) in ('saturday','sunday') then 'Weekend'
end as day_categories,
revenue, order_date
from fashion
group by day_categories,revenue,order_date
order by revenue desc 

--- the above code listed all the sales and day_category(weekend or weekday)
--  now we have to compare the sales between weekend and weekday.    
select min(revenue) as minimum_revenue , max(revenue) as max_revenue from fashion



---- ii) Find peak shopping hours (if timestamp is available).
 select order_date,pg_typeof(order_date) from fashion  -- to check if there is time in the order_date column
 
 select to_char(order_date,'HH24')as shopping_hour, count(to_char(order_date,'HH24')) as frequency
 from fashion
 group by shopping_hour 
 order by frequency 
 limit 2;
 
select to_char(order_date, 'HH24:MI:SS') as shopping_time
from fashion;

select to_char(order_date,'HH24') as shopping_hour
from fashion;

select order_date::timestamp as full_timestamp from fashion;

--step 2D. Inventory Insights
--- id)Identify low stock items.
--- It is based on the assumption that low stock items are the ones that are less ordered
select clothing_type, category, count(order_date) as number_of_orders from fashion
group by clothing_type,category 
order by number_of_orders asc

--- category and clothing_type average pricing.
select category,clothing_type , avg(price) as average_price
from fashion
group by 1,2
order by average_price desc;

--- category , clothing_type , avg discount
select category,clothing_type , avg(discount) as average_discount
from fashion
group by 1,2
order by average_discount desc;

----ii) Find items that are frequently restocked.
select clothing_type, category, count(order_date) as number_of_orders from fashion
group by clothing_type,category 
order by number_of_orders desc
--limit 3;

 

E. Custom Question
SELECT 
    CASE
        WHEN TRIM(TO_CHAR(order_date, 'day')) IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday') THEN 'Weekday'
        WHEN TRIM(TO_CHAR(order_date, 'day')) IN ('saturday', 'sunday') THEN 'Weekend'
    END AS day_categories,
    SUM(revenue) AS total_sales
FROM fashion
GROUP BY 
    CASE
        WHEN TRIM(TO_CHAR(order_date, 'day')) IN ('monday', 'tuesday', 'wednesday', 'thursday', 'friday') THEN 'Weekday'
        WHEN TRIM(TO_CHAR(order_date, 'day')) IN ('saturday', 'sunday') THEN 'Weekend'
    END
ORDER BY 
    total_sales DESC;
--option b 

select day_of_week,total_sales,sales_category,
case
	when day_of_week in ('Monday','Tuesday','Wednesday','Thursday','Friday') then 'weekday'
	when day_of_week in ('Saturday','Sunday') then 'weekend'
end as day_category
from 
(select Trim(to_char(order_date,'Day')) as day_of_week,sum(revenue) as total_sales,
 case
	when sum(revenue)<= 40000.00 then 'low'
	when sum(revenue)> 40000.00 and sum(revenue)<=80000.00 then 'medium'
	when sum(revenue)> 80000.00 then 'high'
end as sales_category
from fashion
group by day_of_week)
order by total_sales desc;






SELECT 
    (SELECT COUNT(*)  FROM (
         SELECT customer_email
         FROM fashion
         GROUP BY customer_email
         HAVING COUNT(*) = 1
     ) AS new_customers) AS new_customers,
    (SELECT COUNT(*) 
     FROM (
         SELECT customer_email
         FROM fashion
         GROUP BY customer_email
         HAVING COUNT(*) > 1
     ) AS repeat_customers) AS repeat_customers;


--E. Custom Question

--                           Formulate one additional interesting question and answer it using SQL.
--shop with the highest revenue
select shop_outlet,sum(revenue) as total_sales from fashion group by shop_outlet order by total_sales desc limit 1;

-- Highest discounted product.
select category,clothing_type,max(discount) as highest_discount_product from fashion group by 1,2 order by highest_discount_product desc limit 5;

--- calculate the number of days before delivery
select age(delivery_date,order_date) as delivery_days ,category,clothing_type,shop_outlet  from fashion group by 1,2,3,4 order by delivery_days desc limit 10;

---calculate the total revenue per clothing_type 
select category,clothing_type,sum(revenue) as total_sales from fashion  group by 1,2 order by total_sales desc  limit 5;

--- calculate the average delivery time
select avg(delivery_date-order_date) as avg_delivery_time from fashion ;

--- orders with highest discount%
select category,clothing_type,sum(discount) as total_discount  from fashion group by 1,2 order by total_discount desc limit 10;


select customer_category,count(*) as no_of customers
from (select customer_name,
case
	when 
end
)


select shop_outlet, avg(Age(delivery_date,order_date)) as avg_waiting_period
from fashion
group by shop_outlet
order by avg_waiting_period ;

select clothing_type,sum(discount) as total_discount
from fashion
group by 1
order by total_discount desc;

select shop_outlet, sum(revenue) as total_revenue
from fashion
group by shop_outlet 
order by total_revenue desc
limit 10;

select shop_outlet, sum(discount) as total_discount
from fashion
group by 1
order by total_discount desc
limit 10;

