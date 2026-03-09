--1. Total Revenue
SELECT ROUND(
SUM(line_revenue)) AS total_revenue
FROM v_retail_clean
WHERE customer_id IS NOT NULL;

--2. Total Orders
SELECT
COUNT(DISTINCT invoice_no) AS total_orders
FROM v_retail_clean
WHERE customer_id IS NOT NULL;

--3. Active Customers
SELECT
COUNT(DISTINCT customer_id) AS active_customers
FROM v_retail_clean
WHERE customer_id IS NOT NULL;

--4. Average Order Value (AOV)
SELECT ROUND(
SUM(line_revenue) / NULLIF(COUNT(DISTINCT invoice_no),0)) AS avg_order_value
FROM v_retail_clean
WHERE customer_id IS NOT NULL;

--5. Revenue Per Customer
SELECT
ROUND(SUM(line_revenue) / COUNT(DISTINCT customer_id), 2) AS revenue_per_customer
FROM v_retail_clean
WHERE customer_id IS NOT NULL;

=======================================
--Monthly Trend Analysis
=======================================

--1. Monthly Revenue
SELECT 
DATE_TRUNC('month', invoice_timestamp)::date AS month, 
ROUND(SUM(line_revenue),2) AS monthly_revenue
FROM v_retail_clean
GROUP BY 1
ORDER BY 1;

--2. Order Count Per Month
SELECT DATE_TRUNC('month', invoice_timestamp)::date AS month, 
COUNT(DISTINCT invoice_no) AS orders,
ROUND(SUM(line_revenue),2) AS revenue,
ROUND(SUM(line_revenue) / COUNT(DISTINCT invoice_no), 2) AS aov
FROM v_retail_clean
GROUP BY 1
ORDER BY 1;

--3. month-over-month growth
SELECT month, revenue,
ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) / LAG(revenue) 
	  OVER (ORDER BY month) * 100, 2) AS mom_growth_pct
FROM (
    SELECT
        DATE_TRUNC('month', invoice_timestamp)::date AS month,
        SUM(line_revenue) AS revenue
    FROM v_retail_clean
    GROUP BY 1
) t
ORDER BY month;


=============================================
-- Analyse Customer Retention
=============================================

--1. Repeat VS One-time Customers.
SELECT
CASE WHEN order_count = 1 THEN 'One-time'
ELSE 'Repeat'
END AS customer_type,
COUNT(*) AS customers
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS order_count
    FROM v_retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) t
GROUP BY 1;

--2. Check Customer Order Distribution
SELECT order_count, COUNT(*) AS number_of_customers
FROM (
    SELECT customer_id, COUNT(DISTINCT invoice_no) AS order_count
    FROM v_retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
) t
GROUP BY order_count
ORDER BY order_count;

--3.
WITH customer_revenue AS (
    SELECT customer_id, SUM(line_revenue) AS total_revenue
    FROM v_retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
)

SELECT
    COUNT(*) FILTER (WHERE total_revenue > 50000) AS high_value_customers,
    ROUND(SUM(total_revenue) FILTER (WHERE total_revenue > 50000), 2) AS revenue_from_high_value,
    ROUND(SUM(total_revenue), 2) AS total_revenue_all
FROM customer_revenue;

--4.
WITH customer_revenue AS (
    SELECT customer_id, SUM(line_revenue) AS total_revenue
    FROM v_retail_clean
    WHERE customer_id IS NOT NULL
    GROUP BY customer_id
),
ranked AS (
    SELECT *, 
           SUM(total_revenue) OVER () AS total_all,
           SUM(total_revenue) OVER (ORDER BY total_revenue DESC) AS cumulative_revenue
    FROM customer_revenue
)
SELECT
    COUNT(*) FILTER (WHERE cumulative_revenue <= total_all * 0.8) 
    AS customers_generating_80_percent
FROM ranked;


	  

