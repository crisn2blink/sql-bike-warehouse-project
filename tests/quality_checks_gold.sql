/*
======================================================================
--Quality Checks Gold Layer
======================================================================
Script Purpose:
  This script performs quality checks on the gold layer views
  to ensure key uniqueness and proper table connectivity.
  -Uniqueness of surrogate keys
  -Validation of relationships in the data model

Usage Note:
    -Investigate and resolve any discrepancies found during the check.
----------------------------------------------------------------------


======================================================================
--Checking gold.dim_customers
======================================================================
--Check for uniqueness of customer_key
--Expectation: No results */
SELECt
  customer_key,
  COUNT(*) AS repeats
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) >1

/*======================================================================
--Checking gold.dim_products
======================================================================*/
--Check for uniqueness of product_key
--Expectation: No results */
SELECt
  product_key,
  COUNT(*) AS repeats
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) >1

/*======================================================================
--Checking gold.fact_sales
======================================================================*/
--Check data model connectivity between fact and dimensions views
SELECT*
FROM gold.fact_sales AS s
LEFT JOIN gold.dim_customers AS c
ON s.customer_key = c.customer_key
LEFT JOIN gold.dim_products AS p
ON s.product_key = p.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL;
