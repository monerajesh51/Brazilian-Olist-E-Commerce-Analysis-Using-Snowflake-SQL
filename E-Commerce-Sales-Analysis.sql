-- 1 What is the total reveneu generated?

select round(sum(payment_value),2) as total_revenue from payments;

-- 2 What is the monthly revenue trend?

select date_trunc('Month',o.order_purchase_timestamp) as month,
round(sum(p.payment_value),2) as revenue from orders o join payments p on  o.order_id=p.order_id
group by month
order by month;

-- 3 Who are the Top 10 customers by revenue?

select c.customer_unique_id,
round(sum(p.payment_value),2) as revenue
from customers c 
join orders o 
on c.customer_id=o.customer_id
join payments p 
on o.order_id=p.order_id 
group by c.customer_unique_id 
order by revenue desc
limit 10;

-- 4 Which product categories generate the highest revenue?

select t.product_category_name_english,
round(sum(i.price),2) as revenue
from order_items i
join products p
on i.product_id=p.product_id
join product_category t 
on p.product_category_name = t.product_category_name 
group by t.product_category_name_english
order by revenue desc
limit 10;


-- 5 What is the average customer rating?

select round(avg(review_score),2) as average_rating
from order_reviews;


-- 6 What percentage of orders are delivered?

select order_status, count(*) as total_orders,
round(count(*) *100.0 /sum(count(*)) over (),2) as percentage
from orders group by order_status;

-- 7 Which sellers contribute the most revenue?

select seller_id,round(sum(price),2) as revenue
from order_items
group by seller_id
order by revenue desc
limit 10;

-- 8 What is the average delivery time?

SELECT
ROUND(
AVG(
DATEDIFF(
'DAY',
order_purchase_timestamp,
order_delivered_customer_date)),2) AS avg_delivery_days
FROM ORDERS
WHERE order_status = 'delivered';


-- 9 Which states have the highest number of customers?

select customer_state, count(distinct customer_unique_id) as customers
from customers 
group by customer_state
order by customers desc;

-- 10 Identify repeat customers

SELECT
c.customer_unique_id,
COUNT(DISTINCT o.order_id) AS total_orders
FROM CUSTOMERS c
JOIN ORDERS o
ON c.customer_id = o.customer_id
GROUP BY c.customer_unique_id
HAVING COUNT(DISTINCT o.order_id) > 1
ORDER BY total_orders DESC;


-- 11 Top 5 Customers per state (Window Functions)

select * 
from (
select c.customer_state,
c.customer_unique_id,
sum(p.payment_value) as revenue,
rank() over(
partition by c.customer_state
order by sum(p.payment_value) desc
) as rank
from customers c 
join orders o 
on c.customer_id=o.customer_id 
join payments p
on o.order_id = p.order_id
group by 
c.customer_state,
c.customer_unique_id
)
where rank<=5;


-- 12 Running Monthly Revenue

SELECT
month,
revenue,
SUM(revenue) OVER (
ORDER BY month) AS cumulative_revenue
FROM (
SELECT
DATE_TRUNC('MONTH', o.order_purchase_timestamp) AS month,
SUM(p.payment_value) AS revenue
FROM ORDERS o
JOIN PAYMENTS p
ON o.order_id = p.order_id
GROUP BY month
);

-- 13 Best-Selling Products?

SELECT
product_id,
COUNT(*) AS quantity_sold
FROM ORDER_ITEMS
GROUP BY product_id
ORDER BY quantity_sold DESC
LIMIT 10;


-- 14 Revenue by payment type?

SELECT
payment_type,
ROUND(SUM(payment_value), 2) AS revenue
FROM PAYMENTS
GROUP BY payment_type
ORDER BY revenue DESC;


-- 15 Customer Lifetime Value(CLV)

SELECT
c.customer_unique_id,
ROUND(SUM(p.payment_value), 2) AS lifetime_value
FROM CUSTOMERS c
JOIN ORDERS o
ON c.customer_id = o.customer_id
JOIN PAYMENTS p
ON o.order_id = p.order_id
GROUP BY c.customer_unique_id
ORDER BY lifetime_value DESC;

-- 16 Top 5 States by Revenue

SELECT
c.customer_state,
ROUND(SUM(p.payment_value),2) AS revenue
FROM customers c
JOIN orders o
ON c.customer_id = o.customer_id
JOIN payments p
ON o.order_id = p.order_id
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 5;

-- 17 Revenue Contribution Percentage by Category

SELECT
t.product_category_name_english,
ROUND(SUM(i.price),2) AS revenue,
ROUND(
SUM(i.price) * 100 /
SUM(SUM(i.price)) OVER (),2) AS revenue_percentage
FROM order_items i
JOIN products p
ON i.product_id = p.product_id
JOIN product_category t
ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY revenue DESC;

-- 18 Monthly Order Count

SELECT
DATE_TRUNC('MONTH', order_purchase_timestamp) AS month,
COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY month
ORDER BY month;