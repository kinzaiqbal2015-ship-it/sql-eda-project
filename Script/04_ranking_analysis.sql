/*
Project: Exploratory Data Analysis using SQL Server
Section 4: Ranking analysis
*/

-- 4.1 Top 5 products by revenue
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.[gold.fact_sales] AS f
LEFT JOIN gold.[gold.dim_products] AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC;

-- 4.2 Top 5 customers by number of orders
-- This reflects what the original final query calculates.
SELECT TOP 5
    c.customer_key,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.[gold.fact_sales] AS f
LEFT JOIN gold.[gold.dim_customers] AS c
    ON c.customer_key = f.customer_key
GROUP BY c.customer_key
ORDER BY total_orders DESC;

-- 4.3 Bottom 5 products by revenue (additional query to match
-- the original comment about the lowest-selling products).
SELECT TOP 5
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.[gold.fact_sales] AS f
LEFT JOIN gold.[gold.dim_products] AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC;
