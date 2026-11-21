/*
Project: Exploratory Data Analysis using SQL Server
Section 2: Measure exploration and business KPIs
*/

-- 2.1 Total sales revenue
SELECT
    SUM(sales_amount) AS total_sales
FROM gold.[gold.fact_sales];

-- 2.2 Total quantity of items sold
SELECT
    SUM(quantity) AS total_quantity
FROM gold.[gold.fact_sales];

-- 2.3 Average selling price
SELECT
    AVG(price) AS average_selling_price
FROM gold.[gold.fact_sales];

-- 2.4 Total number of orders
-- COUNT(DISTINCT ...) avoids counting multiple rows from the same order.
SELECT
    COUNT(DISTINCT order_number) AS total_orders
FROM gold.[gold.fact_sales];

-- 2.5 Total number of products
SELECT
    COUNT(product_name) AS total_products
FROM gold.[gold.dim_products];

-- 2.6 Total number of customers
SELECT
    COUNT(customer_key) AS total_customers
FROM gold.[gold.dim_customers];

-- 2.7 Number of customers who have placed at least one order
-- Count distinct customer keys from the sales fact table, not the
-- customer dimension, to count customers who actually placed orders.
SELECT
    COUNT(DISTINCT customer_key) AS customers_with_orders
FROM gold.[gold.fact_sales];

-- 2.8 Consolidated report of key business metrics
SELECT
    'Total Sales' AS measure_name,
    SUM(sales_amount) AS measure_value
FROM gold.[gold.fact_sales]

UNION ALL

SELECT
    'Total Quantity',
    SUM(quantity)
FROM gold.[gold.fact_sales]

UNION ALL

SELECT
    'Average Selling Price',
    AVG(price)
FROM gold.[gold.fact_sales]

UNION ALL

SELECT
    'Total Orders',
    COUNT(DISTINCT order_number)
FROM gold.[gold.fact_sales]

UNION ALL

SELECT
    'Total Products',
    COUNT(product_name)
FROM gold.[gold.dim_products]

UNION ALL

SELECT
    'Total Customers',
    COUNT(customer_key)
FROM gold.[gold.dim_customers]

UNION ALL

SELECT
    'Customers With Orders',
    COUNT(DISTINCT customer_key)
FROM gold.[gold.fact_sales];
