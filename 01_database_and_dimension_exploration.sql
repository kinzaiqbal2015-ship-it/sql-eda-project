/*
Project: Exploratory Data Analysis using SQL Server
Section 1: Database, dimension, and date exploration

Note:
The source script uses objects such as gold.[gold.dim_customers].
These names are preserved as supplied. Confirm your database's actual
schema and table names before running the queries.
*/

-- 1.1 List all tables in the current database
SELECT *
FROM INFORMATION_SCHEMA.TABLES;

-- 1.2 List all columns in the current database
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS;

-- 1.3 Inspect columns for the customers table
-- TABLE_NAME contains the table name; TABLE_SCHEMA contains the schema.
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'gold.dim_customers';

-- 1.4 Explore the countries represented in the customer dimension
SELECT DISTINCT country
FROM gold.[gold.dim_customers]
ORDER BY country;

-- 1.5 Explore product categories, subcategories, and product names
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.[gold.dim_products]
ORDER BY
    category,
    subcategory,
    product_name;

-- 1.6 Find the first and latest order dates
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM gold.[gold.fact_sales];

-- 1.7 Calculate the order-date range in years and months
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(YEAR, MIN(order_date), MAX(order_date)) AS date_diff_in_years,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS date_diff_in_months
FROM gold.[gold.fact_sales];

-- 1.8 Find the earliest and latest customer birthdates
SELECT
    MIN(birthdate) AS oldest_birthdate,
    MAX(birthdate) AS youngest_birthdate
FROM gold.[gold.dim_customers];

-- 1.9 Calculate approximate ages of the oldest and youngest customers
-- DATEDIFF(YEAR, ...) counts year boundaries; it may differ by one
-- from completed age depending on whether the birthday has occurred.
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_approx_age,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_approx_age
FROM gold.[gold.dim_customers];
