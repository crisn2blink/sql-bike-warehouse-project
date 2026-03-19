/*
=====================================================================================
DDL for Bronze Layer Tables
=====================================================================================
Purpose of this script:
  This script creates the tables in the bronze schema, dropping the tables if
  these already exist.
Run this script to re-define the DDL structure of 'bronze' tables
=====================================================================================
IMPORTANT NOTE: T-SQL is used in order to easily refresh the table's DDL on a as-needed basis
by dropping the table if it exists and recreating it with the most up-to-date values
from the source document. (if you need to change the data types or column names)

*/

--Create table for raw_customers.csv
IF OBJECT_ID ('bronze.chat_raw_customers', 'U') IS NOT NULL
    DROP TABLE bronze.chat_raw_customers;
CREATE TABLE bronze.chat_raw_customers
(
    customer_id NVARCHAR(50),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email NVARCHAR(100),
    phone NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    signup_date NVARCHAR(50),
    customer_segment NVARCHAR(50)
);
--Create table for raw_products.csv
IF OBJECT_ID ('bronze.chat_raw_products', 'U') IS NOT NULL
    DROP TABLE bronze.chat_raw_products;
CREATE TABLE bronze.chat_raw_products
(
    product_id NVARCHAR(50),
    brand NVARCHAR(50),
    category NVARCHAR(50),
    model_name NVARCHAR(50),
    color NVARCHAR(50),
    material NVARCHAR(50),
    list_price NVARCHAR(50),
    standard_cost NVARCHAR(50),
    is_active NVARCHAR(50)
);
--Create table for raw_sales.csv
IF OBJECT_ID ('bronze.chat_raw_sales', 'U') IS NOT NULL
    DROP TABLE bronze.chat_raw_sales;
CREATE TABLE bronze.chat_raw_sales
(
    sale_id NVARCHAR(50),
    customer_id NVARCHAR(50),
    product_id NVARCHAR(50),
    order_date NVARCHAR(50),
    quantity NVARCHAR(50),
    unit_price NVARCHAR(50),
    sales_amount NVARCHAR(50),
    sales_channel NVARCHAR(50),
    store_name NVARCHAR(50),
    payment_method NVARCHAR(50)
);
