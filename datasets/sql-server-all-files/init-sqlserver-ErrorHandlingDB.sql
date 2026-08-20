/*ErrorHandlingDB
│
├── Sales
│   ├── Customers
│   ├── Products
│   ├── Orders
│   └── OrderItems
│
├── HR
│   ├── Employees
│   └── Departments
│
├── Staging
│   └── SalesImport
│
├── ETL
│   └── BatchControl
│
└── Audit
    └── ErrorLog */


-- =========================================================
-- Create Database
-- =========================================================

CREATE DATABASE ErrorHandlingDB;
GO

USE ErrorHandlingDB;
GO

-- =========================================================
-- Create schemas
-- =========================================================

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Staging;
GO

CREATE SCHEMA ETL;
GO

CREATE SCHEMA Audit;
GO




















