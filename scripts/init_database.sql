/* 
=======================================
Create database and schemas
=======================================
Script purpose:
  This script create a new database named 'BikeWarehouse' and additionally
  sets up the three schemas within the database: 'bronze', 'silver', and 'gold'.
*/
USE master;
GO

--Create the database 'BikeWarehouse'
CREATE DATABASE BikeWarehouse;

USE BikeWarehouse

--Create the three schemas for the database
CREATE SCHEMA bronze;
CREATE SCHEMA silver;
CREATE SCHEMA gold;
