/* 
==============================================================
Stored Procedure: Load Silver Layer (Bronze --> Silver)
==============================================================
Script Purpose:
  This stored procedure drops all of the current values via
  the TRUNC function and proceeds to upload the most up-to-date
  values from the bronze layer.
  -Truncates the silver tables before loading them
  -Loads from the bronze layer
  -Utilizes INSERT INTO to load the data from the bronze layer.

Parameters: none
This stored procedure does not accept any parameters or return any values.

Usage example:
  EXEC silver.load_silver;
==============================================================*/
--Start of stored procedure to load data into the silver layer tables.
CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    SET @batch_start_time = GETDATE();
        PRINT '======================================';
        PRINT 'Loading Silver Layer';
        PRINT '======================================';
        PRINT ' ';

    /*=============================================
    --silver.chat_raw_customers Loading
    =============================================*/
    SET @start_time = GETDATE();
    BEGIN TRY
        PRINT '>> Truncating table: silver.chat_raw_customers';
        TRUNCATE TABLE silver.chat_raw_customers;
        PRINT ' ';
        PRINT '>> Inserting data into table: silver.chat_raw_customers';
        ;WITH CTE_standardization_customers AS (
            SELECT
                customer_id,
                first_name,
                last_name,
                email AS email_raw,
                CASE
                    WHEN email IS NULL OR TRIM(email) = '' THEN NULL
                    ELSE LOWER(TRIM(email)
                    )
                END AS email,
                city,
                state,
                signup_date,
                TRY_CAST(TRIM(signup_date) AS DATE) AS signup_date_cast,
                customer_segment,
                phone AS phone_raw,
                REPLACE(
                    REPLACE(
                        REPLACE(
                            REPLACE(
                                REPLACE(TRIM(phone), '(', ''),
                            ')', ''),
                        '-', ''),
                    ' ', ''),
                '.', '') AS clean_phone
            FROM bronze.chat_raw_customers
        )
        INSERT INTO silver.chat_raw_customers (
        customer_id,
        first_name,
        last_name,
        email_raw,
        email,
        is_valid_email,
        phone_raw,
        phone,
        is_valid_phone,
        city,
        state,
        signup_date,
        signup_date_failed,
        customer_segment
        )
        SELECT
            CASE
                WHEN customer_id IS NULL OR customer_id = '' THEN NULL
                ELSE UPPER(TRIM(customer_id))
            END AS customer_id,
            CASE
                WHEN first_name IS NULL OR TRIM(first_name) = '' THEN NULL
                ELSE UPPER(TRIM(LEFT(first_name, 1))) + LOWER(TRIM(SUBSTRING(first_name, 2, LEN(first_name)))
                )
            END AS first_name,
            CASE
                WHEN last_name IS NULL OR TRIM(last_name) = '' THEN NULL
                ELSE UPPER(TRIM(LEFT(last_name, 1))) + LOWER(TRIM(SUBSTRING(last_name, 2, LEN(last_name)))
                )
            END AS last_name,
            email_raw,
            email,
            CASE
                WHEN email IS NULL OR email = '' THEN 0
                WHEN email LIKE '% %' THEN 0
                WHEN (LEN(email)) - LEN(REPLACE(email, '@', '')) <> 1 THEN 0
                WHEN email NOT LIKE '%_@_%._%' THEN 0
                WHEN TRIM(LEFT(email, 1)) IN ('@', '.') THEN 0
                WHEN TRIM(RIGHT(email, 1)) IN ('@', '.') THEN 0
                WHEN email LIKE '%@.%' THEN 0
                WHEN email LIKE '%..%' THEN 0
                ELSE 1
            END AS is_valid_email,
            phone_raw,
            CASE 
                WHEN clean_phone NOT LIKE '%[^0-9]%' AND LEN(clean_phone) = 10
                THEN '(' + SUBSTRING(clean_phone, 1, 3) + ') ' +
                    SUBSTRING(clean_phone, 4, 3) + '-' + SUBSTRING(clean_phone, 7, 4)
                WHEN clean_phone NOT LIKE '%[^0-9]%' AND LEN(clean_phone) = 11 AND LEFT(clean_phone,1) = '1'
                THEN '(' + SUBSTRING(clean_phone, 2, 3) + ') ' +
                    SUBSTRING(clean_phone, 5, 3) + '-' + SUBSTRING(clean_phone, 8, 4)
                ELSE NULL
            END AS phone,
            CASE
                WHEN clean_phone LIKE '%[^0-9]%' THEN 0 --if any non-numerical characters presents: invalid
                WHEN LEN(clean_phone) = 10 THEN 1
                WHEN LEN(clean_phone) = 11 AND LEFT(clean_phone, 1) = '1' THEN 1
            ELSE 0
            END AS is_valid_phone,
            CASE 
                WHEN city IS NULL OR TRIM(city) = '' THEN NULL
                ELSE TRIM(city)
            END AS city,
            CASE
                WHEN state IS NULL OR TRIM(state) = '' THEN NULL
                ELSE UPPER(TRIM(state)
                )
            END AS state,
            CASE
                WHEN signup_date IS NULL OR TRIM(signup_date) = '' THEN NULL
                ELSE signup_date_cast
            END AS signup_date,
            CASE
                WHEN signup_date IS NULL OR TRIM(signup_date) = '' THEN 0
                WHEN signup_date_cast IS NULL THEN 1
                ELSE 0
            END AS signup_date_failed,
            CASE
                WHEN customer_segment IS NULL OR TRIM(customer_segment) = '' THEN NULL
                ELSE UPPER(LEFT(TRIM(customer_segment), 1)) + LOWER(SUBSTRING(TRIM(customer_segment), 2, LEN(TRIM(customer_segment))
                ))
            END AS customer_segment
        FROM CTE_standardization_customers;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------';
        PRINT ' ';
        /*=============================================
        --silver.chat_raw_products Loading
        =============================================*/
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: silver.chat_raw_products';
        TRUNCATE TABLE silver.chat_raw_products;
        PRINT ' ';
        PRINT '>> Inserting data into table: silver.chat_raw_products';
        ;WITH CTE_standardization_products AS (
            SELECT
                product_id,
                TRIM(brand) AS brand,
                category,
                TRIM(model_name) AS model_name,
                TRIM(color) AS color,
                material,
                list_price,
                standard_cost,
                TRIM(is_active) AS is_active
        FROM bronze.chat_raw_products
        )
        INSERT INTO silver.chat_raw_products
        (
        product_id,
        brand,
        category,
        model_name,
        invalid_model,
        color,
        material,
        list_price,
        standard_cost,
        is_active
        )
        SELECT
            CASE
                WHEN product_id IS NULL OR product_id = '' THEN NULL
                ELSE UPPER(TRIM(product_id))
            END AS product_id,
            CASE
                WHEN brand is NULL OR brand = '' THEN NULL
                WHEN brand = 'peakmotion' THEN 'PeakMotion'
                WHEN brand = 'trailblaze' THEN 'TrailBlaze'
                WHEN brand = 'urbanwheel' THEN 'UrbanWheel'
                WHEN brand = 'velocraft' THEN 'VeloCraft'
                ELSE brand
            END AS brand,
            CASE
                WHEN category is NULL OR TRIM(category) = '' THEN NULL
                ELSE TRIM(category)
            END AS category,
            model_name,
            CASE
                WHEN model_name IS NULL or model_name = '' THEN 1
                --must contain exactly one dash
                WHEN LEN(model_name) - LEN(REPLACE(model_name, '-', '')) != 1 THEN 1
                --left side must be letters only
                WHEN LEFT(model_name, CHARINDEX('-', model_name) -1) LIKE '%[^A-Za-z]%' THEN 1
                --right side must be numbers only
                WHEN RIGHT(model_name, LEN(model_name) - CHARINDEX('-', model_name)) LIKE '%[^0-9]%' THEN 1
                --prevents empty left side
                WHEN CHARINDEX('-', model_name) = 1 THEN 1
                --prevents empty right side
                WHEN CHARINDEX('-', model_name) = LEN(model_name) THEN 1
                ELSE 0
            END AS invalid_model,
            CASE
                WHEN color IS NULL OR color = '' THEN NULL
                ELSE UPPER(LEFT(color, 1)) + LOWER(SUBSTRING(color, 2, LEN(color)))
            END AS color,
            UPPER(TRIM(material)) AS material,
            list_price,
            standard_cost,
            CASE
                WHEN is_active IS NULL OR is_active = '' THEN NULL
                WHEN is_active = 'Y' THEN 'Yes'
                WHEN is_active = 'N' THEN 'No'
                ELSE is_active
            END AS is_active
        FROM CTE_standardization_products;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------';
        PRINT ' ';
        /*=============================================
        --silver.chat_raw_sales Loading
        =============================================*/
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: silver.chat_raw_sales';
        TRUNCATE TABLE silver.chat_raw_sales;
        PRINT ' ';
        PRINT '>> Inserting data into table: silver.chat_raw_sales';
        ;WITH CTE_standardization_sales AS (
            SELECT
                sale_id,
                customer_id,
                product_id,
                order_date,
                TRY_CAST(TRIM(order_date) AS DATE) AS order_date_cast,
                quantity,
                TRY_CAST(TRIM(quantity) AS INT) AS quantity_cast,
                unit_price,
                TRY_CAST(TRIM(unit_price) AS DECIMAL(10,2)) AS unit_price_cast,
                sales_amount,
                TRY_CAST(TRIM(sales_amount) AS DECIMAL(10,2)) AS sales_amount_cast,
                TRIM(sales_channel) AS sales_channel,
                TRIM(store_name) AS store_name,
                TRIM(payment_method) AS payment_method
            FROM bronze.chat_raw_sales
        )
        INSERT INTO silver.chat_raw_sales (
        sale_id,
        customer_id,
        product_id,
        order_date,
        order_date_failed,
        quantity,
        quantity_failed,
        unit_price,
        unit_price_failed,
        sales_amount,
        sales_amount_failed,
        sales_channel,
        store_name,
        payment_method
        )
        SELECT
            CASE
                WHEN sale_id IS NULL OR sale_id = '' THEN NULL
                ELSE UPPER(TRIM(sale_id))
            END AS sale_id,
            CASE
                WHEN customer_id IS NULL OR customer_id = '' THEN NULL
                ELSE UPPER(TRIM(customer_id))
            END AS customer_id,
            CASE
                WHEN product_id IS NULL OR product_id = '' THEN NULL
                ELSE UPPER(TRIM(product_id))
            END AS product_id,
            CASE
                WHEN order_date IS NULL or TRIM(order_date) = '' THEN NULL
                ELSE order_date_cast
            END AS order_date, 
            CASE
                WHEN order_date IS NULL or TRIM(order_date) = '' THEN 0
                WHEN order_date_cast IS NULL THEN 1
                ELSE 0
            END AS order_date_failed,
            CASE
                WHEN quantity IS NULL or TRIM(quantity) = '' THEN NULL
                ELSE quantity_cast
            END AS quantity,
            CASE
                WHEN quantity IS NULL or TRIM(quantity) = '' THEN 0
                WHEN quantity_cast IS NULL THEN 1
                ELSE 0
            END AS quantity_failed,
            CASE
                WHEN unit_price IS NULL or TRIM(unit_price) = '' THEN NULL
                ELSE unit_price_cast
            END AS unit_price,
            CASE
                WHEN unit_price IS NULL or TRIM(unit_price) = '' THEN 0
                WHEN unit_price_cast IS NULL THEN 1
                ELSE 0
            END AS unit_price_failed,
            CASE
                WHEN sales_amount IS NULL or TRIM(sales_amount) = '' THEN NULL
                ELSE sales_amount_cast
            END AS sales_amount,
            CASE
                WHEN sales_amount IS NULL or TRIM(sales_amount) = '' THEN 0
                WHEN sales_amount_cast IS NULL THEN 1
                ELSE 0
            END AS sales_amount_failed,
            CASE
                WHEN sales_channel IS NULL or sales_channel = '' THEN NULL
                WHEN sales_channel NOT LIKE'% %' THEN UPPER(LEFT(sales_channel, 1)) 
                + LOWER(SUBSTRING(sales_channel, 2, LEN(sales_channel)))
                ELSE sales_channel
            END AS sales_channel,
            -- Logic ensures proper case for two-word store names, deals with NULL & blank values
            CASE
                WHEN store_name is NULL or store_name = '' THEN NULL
                WHEN store_name LIKE'_% %_' AND LEN(store_name) - LEN(REPLACE(store_name, ' ', '')) = 1 THEN
                UPPER(LEFT(store_name, 1)) + LOWER(SUBSTRING(store_name, 2, CHARINDEX(' ', store_name) - 1)) +
                UPPER(SUBSTRING(store_name, CHARINDEX(' ', store_name) + 1, 1)) +
                LOWER(SUBSTRING(store_name, CHARINDEX(' ', store_name) + 2, LEN(store_name)))
                ELSE store_name
            END AS store_name,
            CASE
                WHEN payment_method IS NULL OR payment_method = '' THEN NULL
                WHEN payment_method = 'mastercard' THEN 'Mastercard'
                WHEN payment_method = 'cash' THEN 'Cash'
                WHEN payment_method = 'visa' THEN 'Visa'
                WHEN payment_method = 'amex' THEN 'Amex'
                WHEN payment_method = 'ach' THEN 'ACH'
                WHEN payment_method = 'paypal' THEN 'PayPal'
                ELSE payment_method
            END AS payment_method
        FROM CTE_standardization_sales;
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '------------';
        PRINT ' ';
        SET @batch_end_time = GETDATE();
        PRINT '======================================';
        PRINT 'Loading of Silver Layer Complete';
        PRINT '-Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '======================================';
    END TRY
    BEGIN CATCH
        PRINT '=============================================';
        PRINT 'ERROR OCCURED DURING LOADING OF SILVER LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=============================================';
    END CATCH
END
