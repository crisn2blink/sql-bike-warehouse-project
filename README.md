# sql-bike-warehouse-project
Welcome to the **sql-bike-warehouse-project** repository!
This project demonstrates comprehensive data warehousing and analytics solutions; from building a data warehouse to generating actionable business insights. Designed as a portfolio project to highlight industry best practices in data engineering and analytics.
---
  ## 🏗️ Data Architecture
  
  The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
  ![Data Architecture](docs/data_architecture.png)

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.

---
  ## 📖 Project Overview
  
  This project involves:
  
  1. **Data Architecture**: Designing a Modern Data Warehouse Using Medallion Architecture **Bronze**, **Silver**, and **Gold** layers.
2. **ETL Pipelines**: Extracting, transforming, and loading data from source systems into the warehouse.
3. **Data Modeling**: Developing fact and dimension tables optimized for analytical queries.
4. **Analytics & Reporting**: Creating SQL-based reports and dashboards for actionable insights.

🎯 This repository is an excellent resource for professionals and students looking to showcase expertise in:
  - SQL Development
- Data Architect
- Data Engineering  
- ETL Pipeline Developer  
- Data Modeling  
- Data Analytics  

---
  
  ## 🛠️ Important Links & Tools:
  
  Everything is for Free!
  - **[Datasets](datasets/):** Access to the project dataset (csv files).
- **[DrawIO](https://www.drawio.com/):** Design data architecture, models, flows, and diagrams.
- **[Notion](https://www.notion.com/):** All-in-one tool for project management and organization.

---
  
  ## Project Requirements
  
  ### Building the Data Warehouse (Data Engineering)
  
  ### Objective
  Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

#### Specifications
- **Data Sources**: Import data from source systems (ChatGPT generated dataset) provided as CSV files.
- **Data Quality**: Cleanse and resolve data quality issues prior to analysis.
- **Integration**: Combine tables via user-friendly data model designed for analytical queries.
- **Scope**:  Focus on the latest dataset only; historization of data is not required.
- **Documentation**: Provide clear documentation of the data model to support both business stakeholders and analytics teams.


---
  
  ### BI: Analytics & Reporting (Data Analytics)
  
  #### Obejective
  Develop SQL-based analytics to deliver detailed insights into:
  - **Customer Behavior**
  - **Product Performance**
  - **Sales Trends**
  
  These insights empower stakeholders with key business metrics, enabling strategic decision-making.

## 📂 Repository Structure
```
data-warehouse-project/
  │
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
  │
├── docs/                               # Project documentation and architecture details
  │   ├── project_diagram.drawio          # Draw.io file shows the project's architecture
│   ├── data_catalog.md                 # Catalog of datasets, including field descriptions and metadata
│   ├── data_flow_diagram.drawio        # Draw.io file for the data flow diagram
│   ├── sales_data_mart.drawio          # Draw.io file for data models (star schema)
│   ├── naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
  │   ├── bronze/                         # Scripts for extracting and loading raw data
  │   ├── silver/                         # Scripts for cleaning and transforming data
  │   ├── gold/                           # Scripts for creating analytical models
  │
├── tests/                              # Test scripts and quality files
  │
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project
```
---
  
  ---
  
  ## License
  
  This project is licensed under the [MIT License] (LICENSE). You are free to use, modify and share this project with proper attribution.

## About Me

Hi! I'm **Cristian Cervantes**. I'm a developing business analyst and yoga practitioner on a mission to share knowledge while simultaneously learning.
