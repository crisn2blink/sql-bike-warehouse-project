/*
=====================================================================================
DDL for Silver Layer Tables
=====================================================================================
Purpose of this script:
  This script creates the tables in the silver schema, dropping the tables if
  these already exist.
Run this script to re-define the DDL structure of 'silver' tables
=====================================================================================
IMPORTANT NOTE: T-SQL is used in order to easily refresh the table's DDL on a as-needed basis
by dropping the table if it exists and recreating it with the most up-to-date values
from the source document. (if you need to change the data types or column names)

*/

--Create table for raw_customers.csv
IF OBJECT_ID ('silver.chat_raw_customers', 'U') IS NOT NULL
    DROP TABLE silver.chat_raw_customers;
CREATE TABLE silver.chat_raw_customers
(
    customer_id NVARCHAR(50),
    first_name NVARCHAR(50),
    last_name NVARCHAR(50),
    email_raw NVARCHAR(100),
    email NVARCHAR(100),
    is_valid_email NVARCHAR(50),
    phone_raw NVARCHAR(50),
    phone NVARCHAR(50),
    is_valid_phone NVARCHAR(50),
    city NVARCHAR(50),
    state NVARCHAR(50),
    signup_date DATE,
    signup_date_failed NVARCHAR(50),
    customer_segment NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

  CONSTRAINT PK_bike_customers PRIMARY KEY (customer_id)
);
--Create table for raw_products.csv
IF OBJECT_ID ('silver.chat_raw_products', 'U') IS NOT NULL
    DROP TABLE silver.chat_raw_products;
CREATE TABLE silver.chat_raw_products
(
    product_id NVARCHAR(50),
    brand NVARCHAR(50),
    category NVARCHAR(50),
    model_name NVARCHAR(50),
    invalid_model INT,
    color NVARCHAR(50),
    material NVARCHAR(50),
    list_price DECIMAL(10,2),
    standard_cost DECIMAL(10,2),
    is_active NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()

  CONSTRAINT PK_bike_products PRIMARY KEY (product_id)
);
--Create table for raw_sales.csv
IF OBJECT_ID ('silver.chat_raw_sales', 'U') IS NOT NULL
    DROP TABLE silver.chat_raw_sales;
CREATE TABLE silver.chat_raw_sales
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
    payment_method NVARCHAR(50),
    dwh_create_date DATETIME2 DEFAULT GETDATE()
);
