/*
=============================================================================
Stored Procedure: Load Bronze Layer (Source --> Bronze)
=============================================================================
Script Purpose:
  This stored procedure drops all the values currently in the table
  via the TRUNC function and uploads the most up-to-date values 
  from the source document.
  -Loads from external .csv file
  -Truncates the bronze table before loading it
  -Utilizes BULK INSERT in order to load the data from the .csv file

Parameters: none
  None.
  This stored procedure does not accept any parameters or return any values.

Usage example:
  EXEC bronze.load_bronze;
============================================================================
*/
--Start of stored procedure to load data into the bronze layer tables.
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME
    SET @batch_start_time = GETDATE();
    BEGIN TRY
        PRINT '=======================================';
        PRINT 'Loading Bronze Layer';
        PRINT '=======================================';
        PRINT '';
        PRINT '----------------------------------------';
        PRINT 'Loading ChatGPT tables'
        PRINT '----------------------------------------';
        PRINT '';
        --Bulk Insert for bronze.chat_raw_customers
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.chat_raw_customers';
        TRUNCATE TABLE bronze.chat_raw_customers;
        PRINT '>> Inserting data into: bronze.chat_raw_customers';
        BULK INSERT bronze.chat_raw_customers
        FROM '/var/opt/mssql/data/raw_customers.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0X0d0a'
        );
        SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-----------------------------------------';
        --Bulk Insert for bronze.chat_raw_products
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.chat_raw_products';
        TRUNCATE TABLE bronze.chat_raw_products;
        PRINT '>> Inserting data into: bronze.chat_raw_products';
        BULK INSERT bronze.chat_raw_products
        FROM '/var/opt/mssql/data/raw_products.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a'
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-----------------------------------------';
        --Bulk Insert for bronze.chat_raw_sales
        SET @start_time = GETDATE();
        PRINT '>> Truncating table: bronze.chat_raw_sales';
        TRUNCATE TABLE bronze.chat_raw_sales;
        PRINT '>> Inserting data into: bronze.chat_raw_sales';
        BULK INSERT bronze.chat_raw_sales
        FROM '/var/opt/mssql/data/raw_sales.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '0x0d0a'
        );
        SET @end_time = GETDATE();
        PRINT 'Load Duration: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR) + 'seconds';
        PRINT '-----------------------------------------';
        PRINT '';
        SET @batch_end_time = GETDATE();
        PRINT '=======================================';
        PRINT 'Loading of Bronze Layer is complete';
        PRINT '-Total Load Duration: ' + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR) + 'seconds';
        PRINT '=======================================';
    END TRY
    BEGIN CATCH
        PRINT '=======================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message' + ERROR_MESSAGE();
        PRINT 'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error State' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=======================================';
    END CATCH
END
