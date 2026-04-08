/*
=============================================================================
DDL Script: Gold Layer Views Creation
=============================================================================
Purpose of this script:
  Takes the clean, validated and transformed data from the silver layer
  and creates user-friendly business objects tailored to the business needs.
  -Creates three views as poart of the gold layer.
  -If the views already exist, the script will drop them and re-create these.

Usage: 
    - These views can be queried directly for analytics and reporting.
-----------------------------------------------------------------------------
*/

/*===========================================================================
--Creating view from silver.chat_raw_customers
===========================================================================*/
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY customer_id) AS customer_key,
        customer_id,
        first_name,
        last_name,
        email,
        phone,
        state,
        city,
        signup_date
    FROM silver.chat_raw_customers;
GO

/*===========================================================================
--Creating view from silver.chat_raw_products
===========================================================================*/
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
    SELECT
        ROW_NUMBER() OVER(ORDER BY product_id) AS product_key,
        product_id,
        brand,
        category,
        model_name,
        color,
        material,
        list_price AS selling_price,
        standard_cost AS cost,
        is_active
    FROM silver.chat_raw_products;
GO

/*===========================================================================
--Creating view from silver.chat_raw_sales
===========================================================================*/
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales AS
    SELECT
        s.sale_id,
        c.customer_key,
        p.product_key,
        s.order_date,
        s.quantity,
        s.unit_price AS sale_price,
        s.sales_amount AS sales_revenue,
        s.sales_channel,
        s.store_name,
        s.payment_method
    FROM silver.chat_raw_sales AS s
    LEFT JOIN gold.dim_customers AS c
    ON s.customer_id = c.customer_id
    LEFT JOIN gold.dim_products AS p
    ON s.product_id = p.product_id;
GO
