# Data Catalog for Gold Layer

## Overview
The Gold Layer is the business-level data representation, structured to support analytical and reporting use cases. It consists of **dimension tables** and **fact tables** for specific business metrics.

---

### 1. **gold.dim_customers**
- **Purpose:** Stores customer details enriched with demographic and geographic data.
- **Columns:**

| Column Name      | Data Type     | Description                                                                                   |
|------------------|---------------|-----------------------------------------------------------------------------------------------|
| customer_key     | BIGINT        | Surrogate key uniquely identifying each customer record in the dimension table.               |
| customer_id      | NVARCHAR(50)  | Unique numerical identifier assigned to each customer.                                        |
| first_name       | NVARCHAR(50)  | The customer's first name, as recorded in the system.                                         |
| last_name        | NVARCHAR(50)  | The customer's last name, as recorded in the system.                                          |
| email            | NVARCHAR(100) | The customer's email address, as recorded in the system.                                      |
| phone            | NVARCHAR(50)  | The customer's email address, as recorded in the system.                                      |
| state            | NVARCHAR(50)  | The customer's state of residence within the USA abbreviated, (e.g., 'TX', 'MN').             |
| city             | NVARCHAR(50)  | The customer's state of residence within the USA                                              |
| signup_date      | DATE          | The date the customer was registered in the system: YYYY-MM-DD (e.g., 1971-10-06).            |
---

### 2. **gold.dim_products**
- **Purpose:** Provides information about the products and their attributes.
- **Columns:**

| Column Name         | Data Type     | Description                                                                                   |
|---------------------|---------------|-----------------------------------------------------------------------------------------------|
| product_key         | BIGINT        | Surrogate key uniquely identifying each product record in the product dimension table.        |
| product_id          | NVARCHAR(50)  | A unique identifier assigned to the product for internal tracking and referencing.            |
| brand               | NVARCHAR(50)  | The brand name for each product.                                                              |
| category            | NVARCHAR(50)  | Descriptive of the broad category the product falls under.                                    |
| model_name          | NVARCHAR(50)  | A unique identifier for the product comprised of an alp[ha-numeric string (eg. GRIP-20).      |
| color               | NVARCHAR(50)  | The color of the product (eg. white, green).                                                  |
| material            | NVARCHAR(50)  | The material that the product is made from (eg. PLASTIC, SYNTHETIC, ALUMINUM).                |
| selling_price       | DECIMAL(10, 2)| The price at which the product is sold by the company. (measured in monetary units).          |
| cost                | DECIMAL(10, 2)| The cost or base price of the product to the company (measured in monetary units).            |
| is_active           | NVARCHAR(50)  | A binary field that indicates whether the product is currently being sold or not (eg. Yes, No)|

---

### 3. **gold.fact_sales**
- **Purpose:** Stores transactional sales data for analytical purposes.
- **Columns:**

| Column Name     | Data Type     | Description                                                                                   |
|-----------------|---------------|-----------------------------------------------------------------------------------------------|
| order_number    | NVARCHAR(50)  | A unique alphanumeric identifier for each sales order (e.g., 'SO54496').                      |
| product_key     | INT           | Surrogate key linking the order to the product dimension table.                               |
| customer_key    | INT           | Surrogate key linking the order to the customer dimension table.                              |
| order_date      | DATE          | The date when the order was placed.                                                           |
| shipping_date   | DATE          | The date when the order was shipped to the customer.                                          |
| due_date        | DATE          | The date when the order payment was due.                                                      |
| sales_amount    | INT           | The total monetary value of the sale for the line item, in whole currency units (e.g., 25).   |
| quantity        | INT           | The number of units of the product ordered for the line item (e.g., 1).                       |
| price           | INT           | The price per unit of the product for the line item, in whole currency units (e.g., 25).      |
