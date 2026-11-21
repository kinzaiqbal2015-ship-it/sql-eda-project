/*=====================================================================
  PROJECT: SQL DATA WAREHOUSE - DATA QUALITY CHECKS
  PLATFORM: Microsoft SQL Server

  PURPOSE:
  This script performs basic data-quality checks on the three tables
  used in the SQL Data Warehouse EDA project.

  TABLES:
    1. gold.[gold.dim_customers]
    2. gold.[gold.dim_products]
    3. gold.[gold.fact_sales]

  CHECKS INCLUDED:
    01. Table row counts
    02. NULL / missing-value checks
    03. Duplicate key checks
    04. Exact duplicate sales-row check
    05. Referential-integrity checks
    06. Invalid-value and date checks
    07. Basic data profiling

  IMPORTANT:
  - Review the results before deciding that a record is an error.
  - Multiple rows with the same order_number can be valid because one
    order may contain multiple products.
  - This script assumes customer_key and product_key are intended to
    identify one row in their respective dimension tables. Confirm this
    rule against your data model before treating duplicates as errors.
  - Source-to-target row-count reconciliation is not included because
    source table names were not provided.
  - Run this script in the database containing the stated tables.
=====================================================================*/


/*=====================================================================
  01. TABLE ROW COUNTS
  Purpose: Get a baseline count of records in each table.
=====================================================================*/

SELECT 'dim_customers' AS table_name, COUNT_BIG(*) AS total_rows
FROM gold.[gold.dim_customers]
UNION ALL
SELECT 'dim_products', COUNT_BIG(*)
FROM gold.[gold.dim_products]
UNION ALL
SELECT 'fact_sales', COUNT_BIG(*)
FROM gold.[gold.fact_sales];


/*=====================================================================
  02. NULL / MISSING-VALUE CHECKS
  Purpose: Find records where important columns are NULL.
=====================================================================*/

-- 2.1 Customer dimension: check important customer fields.
SELECT *
FROM gold.[gold.dim_customers]
WHERE customer_key IS NULL
   OR country IS NULL
   OR gender IS NULL
   OR birthdate IS NULL;

-- 2.2 Product dimension: check important product fields.
SELECT *
FROM gold.[gold.dim_products]
WHERE product_key IS NULL
   OR product_name IS NULL
   OR category IS NULL
   OR subcategory IS NULL
   OR cost IS NULL;

-- 2.3 Sales fact: check important transaction fields.
SELECT *
FROM gold.[gold.fact_sales]
WHERE order_number IS NULL
   OR order_date IS NULL
   OR customer_key IS NULL
   OR product_key IS NULL
   OR sales_amount IS NULL
   OR quantity IS NULL
   OR price IS NULL;

-- 2.4 Summary: count NULL values in selected customer columns.
SELECT
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer_key,
    SUM(CASE WHEN country IS NULL THEN 1 ELSE 0 END) AS null_country,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
    SUM(CASE WHEN birthdate IS NULL THEN 1 ELSE 0 END) AS null_birthdate
FROM gold.[gold.dim_customers];

-- 2.5 Summary: count NULL values in selected product columns.
SELECT
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS null_product_name,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) AS null_category,
    SUM(CASE WHEN subcategory IS NULL THEN 1 ELSE 0 END) AS null_subcategory,
    SUM(CASE WHEN cost IS NULL THEN 1 ELSE 0 END) AS null_cost
FROM gold.[gold.dim_products];

-- 2.6 Summary: count NULL values in selected sales columns.
SELECT
    SUM(CASE WHEN order_number IS NULL THEN 1 ELSE 0 END) AS null_order_number,
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS null_order_date,
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END) AS null_customer_key,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END) AS null_product_key,
    SUM(CASE WHEN sales_amount IS NULL THEN 1 ELSE 0 END) AS null_sales_amount,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS null_quantity,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price
FROM gold.[gold.fact_sales];


/*=====================================================================
  03. DUPLICATE CHECKS
  Purpose: Find repeated dimension keys and exact repeated sales rows.
=====================================================================*/

-- 3.1 Check whether customer_key appears more than once.
-- If customer_key is the dimension's unique key, these are key duplicates.
SELECT
    customer_key,
    COUNT(*) AS occurrence_count
FROM gold.[gold.dim_customers]
WHERE customer_key IS NOT NULL
GROUP BY customer_key
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- 3.2 Check whether product_key appears more than once.
-- If product_key is the dimension's unique key, these are key duplicates.
SELECT
    product_key,
    COUNT(*) AS occurrence_count
FROM gold.[gold.dim_products]
WHERE product_key IS NOT NULL
GROUP BY product_key
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- 3.3 Check exact repeated combinations across the available sales columns.
-- This is a screening check, not proof that a repeated order_number is wrong.
SELECT
    order_number,
    order_date,
    customer_key,
    product_key,
    sales_amount,
    quantity,
    price,
    COUNT(*) AS occurrence_count
FROM gold.[gold.fact_sales]
GROUP BY
    order_number,
    order_date,
    customer_key,
    product_key,
    sales_amount,
    quantity,
    price
HAVING COUNT(*) > 1
ORDER BY occurrence_count DESC;

-- 3.4 Count how many order numbers occur on multiple rows.
-- Multiple rows per order may be normal when an order contains multiple items.
SELECT
    order_number,
    COUNT(*) AS sales_rows
FROM gold.[gold.fact_sales]
WHERE order_number IS NOT NULL
GROUP BY order_number
HAVING COUNT(*) > 1
ORDER BY sales_rows DESC;


/*=====================================================================
  04. REFERENTIAL-INTEGRITY CHECKS
  Purpose: Find sales records whose customer or product key does not
           match a record in the corresponding dimension table.
=====================================================================*/

-- 4.1 Sales rows with a customer_key that has no matching customer.
SELECT f.*
FROM gold.[gold.fact_sales] AS f
LEFT JOIN gold.[gold.dim_customers] AS c
    ON c.customer_key = f.customer_key
WHERE f.customer_key IS NOT NULL
  AND c.customer_key IS NULL;

-- 4.2 Sales rows with a product_key that has no matching product.
SELECT f.*
FROM gold.[gold.fact_sales] AS f
LEFT JOIN gold.[gold.dim_products] AS p
    ON p.product_key = f.product_key
WHERE f.product_key IS NOT NULL
  AND p.product_key IS NULL;


/*=====================================================================
  05. INVALID-VALUE CHECKS
  Purpose: Flag values that may violate common business expectations.
  NOTE: Confirm the business rules before classifying these as errors.
=====================================================================*/

-- 5.1 Negative sales amount.
SELECT *
FROM gold.[gold.fact_sales]
WHERE sales_amount < 0;

-- 5.2 Zero or negative quantity.
-- This assumes a normal sales row should represent a positive quantity.
SELECT *
FROM gold.[gold.fact_sales]
WHERE quantity <= 0;

-- 5.3 Negative price.
SELECT *
FROM gold.[gold.fact_sales]
WHERE price < 0;

-- 5.4 Negative product cost.
SELECT *
FROM gold.[gold.dim_products]
WHERE cost < 0;

-- 5.5 Customer birth dates in the future.
SELECT *
FROM gold.[gold.dim_customers]
WHERE birthdate > CAST(GETDATE() AS DATE);


/*=====================================================================
  06. DATE-QUALITY CHECKS
  Purpose: Inspect unusual or missing date values.
=====================================================================*/

-- 6.1 Sales rows with a missing order date.
SELECT *
FROM gold.[gold.fact_sales]
WHERE order_date IS NULL;

-- 6.2 Find the earliest and latest order dates for date-range review.
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date
FROM gold.[gold.fact_sales];

-- 6.3 Customer birth dates later than the current date.
SELECT *
FROM gold.[gold.dim_customers]
WHERE birthdate > CAST(GETDATE() AS DATE);


/*=====================================================================
  07. BASIC DATA PROFILING
  Purpose: Review distinct values and numeric ranges for investigation.
=====================================================================*/

-- 7.1 Review distinct customer gender values.
SELECT
    gender,
    COUNT(*) AS record_count
FROM gold.[gold.dim_customers]
GROUP BY gender
ORDER BY record_count DESC;

-- 7.2 Review distinct customer countries.
SELECT
    country,
    COUNT(*) AS record_count
FROM gold.[gold.dim_customers]
GROUP BY country
ORDER BY record_count DESC;

-- 7.3 Review product categories and subcategories.
SELECT
    category,
    subcategory,
    COUNT(*) AS product_count
FROM gold.[gold.dim_products]
GROUP BY category, subcategory
ORDER BY category, subcategory;

-- 7.4 Review the ranges of sales measures.
SELECT
    MIN(sales_amount) AS minimum_sales_amount,
    MAX(sales_amount) AS maximum_sales_amount,
    MIN(quantity) AS minimum_quantity,
    MAX(quantity) AS maximum_quantity,
    MIN(price) AS minimum_price,
    MAX(price) AS maximum_price
FROM gold.[gold.fact_sales];


/*=====================================================================
  08. DATA-QUALITY CHECK SUMMARY - MANUAL REVIEW

  Review the result sets above and document:
    - Which checks returned records?
    - Are the returned records genuine errors or valid business cases?
    - What business rule defines a duplicate?
    - What action should be taken: correct, quarantine, investigate,
      or accept?

  This script identifies potential data-quality issues. It does not
  automatically delete or update records.

  NOT INCLUDED:
    - Source-to-target reconciliation (source tables were not supplied).
    - Automated pass/fail logging or pipeline alerts.
    - Data type validation against an external schema.
    - Business-specific rules that have not been defined.
=====================================================================*/
