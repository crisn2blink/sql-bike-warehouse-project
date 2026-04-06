/*
=======================================================
Profiling queries
=======================================================
Purpose of this script:
  Script details the profiling queries to be applied to the silver layer data
  to validate that the data has been properly cleaned, validated and transformed.
*/

/*-------------------------------------------------------
Profiling queries for table: silver.chat_raw_customers
-------------------------------------------------------*/
/*Profiling Query 0: Checking all columns for leading/trailing spaces, tabs, line feeds, 
  carriage returns, and non-breaking spaces*/
SELECT
    customer_segment,
    CONCAT(
        CASE WHEN customer_segment != TRIM(customer_segment) THEN 'TRIM|' ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(9)  + '%' THEN 'TAB|'  ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(10) + '%' THEN 'LF|'   ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(13) + '%' THEN 'CR|'   ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(160)+ '%' THEN 'NBSP|' ELSE '' END
    ) AS reasons
FROM silver.chat_raw_customers
WHERE customer_segment != TRIM(customer_segment)
   OR customer_segment LIKE '%' + CHAR(9) + '%'
   OR customer_segment LIKE '%' + CHAR(10) + '%'
   OR customer_segment LIKE '%' + CHAR(13) + '%'
   OR customer_segment LIKE '%' + CHAR(160) + '%';

--Profiling Query 1: Verifying that the table key has only unique values & no NULLS
SELECT
customer_id,
COUNT(*)
FROM silver.chat_raw_customers
GROUP BY customer_id
HAVING COUNT(*)>1 OR customer_id IS NULL;

--Profiling Query 2: Checking for values that do not adhere to the PK pattern
SELECT
*
FROM silver.chat_raw_customers
WHERE customer_id NOT LIKE'CUST____';

--Profiling Query 3: Visualizing the distinct values for first_name
SELECT
DISTINCT first_name
FROM silver.chat_raw_customers;

--Profiling Query 4: Visualizing the duplicate full_name
SELECT*
FROM
(
  SELECT
    first_name,
    last_name,
    email,
    CONCAT(first_name, ' ', last_name) AS full_name,
    COUNT(*) OVER(PARTITION BY CONCAT(first_name, ' ', last_name)) AS name_count
  FROM silver.chat_raw_customers
) t
WHERE name_count > 1
ORDER BY full_name;

--Profiling Query 5: Visualizing the distinct values for last_name
SELECT
DISTINCT last_name
FROM silver.chat_raw_customers;

--Profiling Query 6: Checking for invalid emails
SELECT
  first_name,
  last_name,
  email
FROM 
(
  SELECT
    first_name,
    last_name,
    TRIM(email) AS email
  FROM silver.chat_raw_customers
)t
WHERE
email IS NULL
OR email = ''
OR email NOT LIKE '%_@_%._%'
OR email LIKE '% %'
OR LEN(email) - LEN(REPLACE(email, '@', '')) <> 1
OR email LIKE '%..%'
OR LEFT(email, 1) IN('@', '.')
OR RIGHT(email, 1) IN('@', '.');

--Profiling Query 7: Checking phone_number for correct pattern (###) ###-####
SELECT
customer_id,
phone
FROM silver.chat_raw_customers
WHERE TRIM(phone) NOT LIKE '(___) ___-____';

--Profiling Query 8: Checking city for DISTINCT values
SELECT DISTINCT
TRIM(city) COLLATE SQL_Latin1_General_CP1_CS_AS AS city
FROM silver.chat_raw_customers;

--Profiling Query 9: Checking state for DISTINCT values
SELECT DISTINCT
TRIM(state) COLLATE SQL_Latin1_General_CP1_CS_AS AS state
FROM silver.chat_raw_customers;

--Profiling Query 10: Checking signup_date for invlaid date values
SELECT
  signup_date
FROM silver.chat_raw_customers
WHERE TRY_CAST(signup_date AS DATE) IS NULL
AND signup_date IS NOT NULL
AND signup_date !='';

--Profiling Query 11: Checking signup_date for impossible date values
SELECT
signup_date
FROM(
  SELECT
  TRY_CAST(signup_date AS DATE) AS signup_date
  FROM silver.chat_raw_customers
)t
WHERE signup_date > GETDATE()
OR signup_date < '1995-01-01';

--Profiling Query 12: Checking customer_segment for DISTINCT values
SELECT
DISTINCT customer_segment COLLATE SQL_Latin1_General_CP1_CS_AS AS customer_segment
FROM silver.chat_raw_customers;

/*-------------------------------------------------------
Profiling queries for table: silver.chat_raw_products
-------------------------------------------------------*/
/*Profiling Query 0: Checking all columns for leading/trailing spaces, tabs, line feeds, 
  carriage returns, and non-breaking spaces*/
SELECT
    customer_segment,
    CONCAT(
        CASE WHEN customer_segment != TRIM(customer_segment) THEN 'TRIM|' ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(9)  + '%' THEN 'TAB|'  ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(10) + '%' THEN 'LF|'   ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(13) + '%' THEN 'CR|'   ELSE '' END,
        CASE WHEN customer_segment LIKE '%' + CHAR(160)+ '%' THEN 'NBSP|' ELSE '' END
    ) AS reasons
FROM silver.chat_raw_customers
WHERE customer_segment != TRIM(customer_segment)
   OR customer_segment LIKE '%' + CHAR(9) + '%'
   OR customer_segment LIKE '%' + CHAR(10) + '%'
   OR customer_segment LIKE '%' + CHAR(13) + '%'
   OR customer_segment LIKE '%' + CHAR(160) + '%';

--Profiling Query 1: Verifying that the table key has only unique values
SELECT
product_id,
COUNT(*) AS copy_ids
FROM silver.chat_raw_products
GROUP BY product_id
HAVING COUNT(*) >1;

--Profiling Query 2: Verifying that PK has no NULLS or blanks
SELECT
product_id
FROM silver.chat_raw_products
WHERE product_id IS NULL
OR product_id = '';

--Profiling Query 3: Checking for values that do not adhere to the PK pattern
SELECT
product_id
FROM silver.chat_raw_products
WHERE product_id NOT LIKE'PROD___';

--Profiling Query 4: Checking for the DISTINCT values in brand (using case sensitivity)
SELECT DISTINCT
brand COLLATE SQL_Latin1_General_CP1_CS_AS AS brand
FROM silver.chat_raw_products;


--Profiling Query 5: Checking for the DISTINCT values in category (using case sensitivity)
SELECT DISTINCT
category COLLATE SQL_Latin1_General_CP1_CS_AS AS category
FROM silver.chat_raw_products;

--Profiling Query 6: Checking for the DISTINCT values in model_name (using case sensitivity)
SELECT DISTINCT
model_name COLLATE SQL_Latin1_General_CP1_CS_AS AS model_name
FROM silver.chat_raw_products
ORDER BY model_name;

--Profiling Query 7: Checking for the DISTINCT values in color (using case sensitivity)
SELECT DISTINCT
color COLLATE SQL_Latin1_General_CP1_CS_AS AS color
FROM silver.chat_raw_products;

--Profiling Query 8: Checking for the DISTINCT values in material (using case sensitivity)
SELECT DISTINCT
material COLLATE SQL_Latin1_General_CP1_CS_AS AS material
FROM silver.chat_raw_products;

--Profiling Query 9: Checking for the invalid values against data type DECIMAL(10,2) in list_price
SELECT*
FROM silver.chat_raw_products
WHERE
TRY_CAST(list_price AS DECIMAL(10,2)) IS NULL
AND list_price IS NOT NULL;

--Profiling Query 10: Checking for the invalid values against data type DECIMAL(10,2) in standard_cost
SELECT*
FROM silver.chat_raw_products
WHERE
TRY_CAST(standard_cost AS DECIMAL(10,2)) IS NULL
AND standard_cost IS NOT NULL;

--Profiling Query 11: Checking for the DISTINCT values in is_valid (using case sensitivity)
SELECT DISTINCT
is_active COLLATE SQL_Latin1_General_CP1_CS_AS AS is_active
FROM silver.chat_raw_products;

/*=======================================================
Profiling queries for table: silver.chat_raw_sales
=======================================================*/
/*Profiling Query 0: Checking all columns for leading/trailing spaces, tabs, line feeds, 
  carriage returns, and non-breaking spaces*/
SELECT
    sale_id,
    CONCAT(
        CASE WHEN sale_id != TRIM(sale_id) THEN 'TRIM|' ELSE '' END,
        CASE WHEN sale_id LIKE '%' + CHAR(9)  + '%' THEN 'TAB|'  ELSE '' END,
        CASE WHEN sale_id LIKE '%' + CHAR(10) + '%' THEN 'LF|'   ELSE '' END,
        CASE WHEN sale_id LIKE '%' + CHAR(13) + '%' THEN 'CR|'   ELSE '' END,
        CASE WHEN sale_id LIKE '%' + CHAR(160)+ '%' THEN 'NBSP|' ELSE '' END
    ) AS reasons
FROM silver.chat_raw_sales
WHERE sale_id != TRIM(sale_id)
   OR sale_id LIKE '%' + CHAR(9) + '%'
   OR sale_id LIKE '%' + CHAR(10) + '%'
   OR sale_id LIKE '%' + CHAR(13) + '%'
   OR sale_id LIKE '%' + CHAR(160) + '%';

--Profiling Query 1: Verifying that the table key has only unique values
SELECT
sale_id,
COUNT(*) AS repeated
FROM silver.chat_raw_sales
GROUP BY sale_id
HAVING COUNT(*) > 1;

--Profiling Query 2: Verifying that PK has no NULLS or blanks
SELECT
sale_id
FROM silver.chat_raw_sales
WHERE sale_id IS NULL or sale_id = ''

--Profiling Query 3: Checking for values that do not adhere to the PK pattern
SELECT
sale_id
FROM silver.chat_raw_sales
WHERE sale_id NOT LIKE 'SALE[0-9][0-9][0-9][0-9][0-9]'
OR LEN(sale_id) <> 9;

--Profiling Query 4: Verify that all foreign key values are found in the PK table
SELECT
customer_id
FROM silver.chat_raw_sales
WHERE customer_id NOT IN(SELECT customer_id FROM silver.chat_raw_customers)

--Profiling Query 5: Verify that all foreign key values are found in the PK table
SELECT
product_id
FROM silver.chat_raw_sales
WHERE product_id NOT IN(SELECT product_id FROM silver.chat_raw_products)

--Profiling Query 6: Verify that all values in order_date are DATE type compatible
SELECT
order_date
FROM silver.chat_raw_sales
WHERE TRY_CAST(order_date AS DATE) IS NULL
AND order_date IS NOT NULL
AND order_date != '';

--Profiling Query 7: Check all of the DISTINCT values (w/ casing sensitivity) for quantity
SELECT DISTINCT
quantity COLLATE SQL_Latin1_General_CP1_CS_AS AS quantity
FROM silver.chat_raw_sales;

--Profiling Query 8: Check all the values to see if these are INT type compatible
SELECT
quantity
FROM silver.chat_raw_sales
WHERE TRY_CAST(quantity AS INT) IS NULL
AND quantity IS NOT NULL
AND quantity != '';

--Profiling Query 9: Check to see if there are any values that fail TRY_CAST DECIMAL(10,2) in unit_price
SELECT
unit_price
FROM silver.chat_raw_sales
WHERE TRY_CAST(unit_price AS DECIMAL(10,2)) IS NULL
AND unit_price IS NOT NULL
AND unit_price != '';

--Profiling Query 10: Check to see if there are any values that fail TRY_CAST DECIMAL(10,2) in sales_amount
SELECT
sales_amount
FROM silver.chat_raw_sales
WHERE TRY_CAST(sales_amount AS DECIMAL(10,2)) IS NULL
AND sales_amount IS NOT NULL
AND sales_amount != '';

--Profiling Query 11: Check all of the DISTINCT values (w/ casing sensitivity) for sales_channel
SELECT DISTINCT
sales_channel COLLATE SQL_Latin1_General_CP1_CS_AS AS sales_channel
FROM silver.chat_raw_sales;

--Profiling Query 12: Check all of the DISTINCT values (w/ casing sensitivity) for store_name
SELECT DISTINCT
store_name COLLATE SQL_Latin1_General_CP1_CS_AS AS store_name
FROM silver.chat_raw_sales;

--Profiling Query 13: Check all of the DISTINCT values (w/ casing sensitivity) for payment_method
SELECT DISTINCT
payment_method COLLATE SQL_Latin1_General_CP1_CS_AS AS payment_method
FROM silver.chat_raw_sales;
