--silver.chat_raw_customer
TRUNCATE  TABLE silver.chat_raw_customers;
WITH CTE_standardization_customers AS (
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
        customer_segment,
        phone AS phone_raw,
        REPLACE(
            REPLACE(
                REPLACE(
                    REPLACE(
                        REPLACE(phone, '(', ''),
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
customer_segment
)
SELECT
    UPPER(TRIM(customer_id)) AS customer_id,
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
        WHEN email LIKE '% %' THEN '0'
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
        ELSE TRY_CAST(CAST(signup_date AS NVARCHAR(50)) AS DATE
        )
    END AS signup_date,
    CASE
        WHEN customer_segment IS NULL OR TRIM(customer_segment) = '' THEN NULL
        ELSE UPPER(LEFT(TRIM(customer_segment), 1)) + LOWER(SUBSTRING(TRIM(customer_segment), 2, LEN(customer_segment))
        )
    END AS customer_segment
FROM CTE_standardization_customers

SELECT*
FROM silver.chat_raw_customers;
