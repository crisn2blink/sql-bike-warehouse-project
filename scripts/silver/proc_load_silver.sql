/*=============================================
--silver.chat_raw_customer
=============================================*/
TRUNCATE TABLE silver.chat_raw_customers;
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
/*=======================================
silver.chat_raw_products
=======================================*/
TRUNCATE TABLE silver.chat_raw_products;
WITH CTE_standardization_products AS (
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
