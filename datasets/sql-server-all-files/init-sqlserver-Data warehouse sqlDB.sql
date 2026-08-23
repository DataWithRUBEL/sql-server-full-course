/* ============================================================
   DATA WAREHOUSE SQL PRACTICE DATABASE
   Company : TechMart Retail
   Purpose : Data Analyst + Data Engineer Practice

   Architecture:
   Source/OLTP
       ↓
   Staging
       ↓
   Bronze
       ↓
   Silver
       ↓
   Gold
       ↓
   Analytics
============================================================ */

---------------------------------------------------------------
-- 1. CREATE DATABASE
---------------------------------------------------------------

IF DB_ID(N'Data warehouse sqlDB') IS NULL
BEGIN
    CREATE DATABASE [Data warehouse sqlDB];
END;
GO

USE [Data warehouse sqlDB];
GO

---------------------------------------------------------------
-- 2. CREATE SCHEMAS
---------------------------------------------------------------

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'src')
    EXEC('CREATE SCHEMA src');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'stg')
    EXEC('CREATE SCHEMA stg');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
    EXEC('CREATE SCHEMA audit');

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')
    EXEC('CREATE SCHEMA etl');
GO


/* ============================================================
   OLTP / SOURCE TABLES
============================================================ */

---------------------------------------------------------------
-- Departments
---------------------------------------------------------------

CREATE TABLE src.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100),
    CreatedDate DATE
);
GO

---------------------------------------------------------------
-- Employees
---------------------------------------------------------------

CREATE TABLE src.Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,
    JobTitle VARCHAR(100),
    HireDate DATE,
    Salary DECIMAL(12,2),
    IsActive BIT
);
GO

---------------------------------------------------------------
-- Customers
---------------------------------------------------------------

CREATE TABLE src.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerNumber VARCHAR(20) UNIQUE,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(150),
    Gender VARCHAR(20),
    DateOfBirth DATE,
    City VARCHAR(100),
    Country VARCHAR(100),
    CustomerType VARCHAR(30),
    CreatedDate DATE,
    ModifiedDate DATETIME2
);
GO

---------------------------------------------------------------
-- Categories
---------------------------------------------------------------

CREATE TABLE src.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100),
    DepartmentID INT
);
GO

---------------------------------------------------------------
-- Products
---------------------------------------------------------------

CREATE TABLE src.Products
(
    ProductID INT PRIMARY KEY,
    ProductSKU VARCHAR(30) UNIQUE,
    ProductName VARCHAR(150),
    CategoryID INT,
    Supplier VARCHAR(100),
    UnitCost DECIMAL(12,2),
    UnitPrice DECIMAL(12,2),
    StockQuantity INT,
    ProductStatus VARCHAR(30),
    CreatedDate DATE,
    ModifiedDate DATETIME2
);
GO

---------------------------------------------------------------
-- Orders
---------------------------------------------------------------

CREATE TABLE src.Orders
(
    OrderID INT PRIMARY KEY,
    OrderNumber VARCHAR(30) UNIQUE,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    OrderStatus VARCHAR(30),
    PaymentMethod VARCHAR(30),
    ShippingCity VARCHAR(100),
    ShippingCountry VARCHAR(100),
    TotalAmount DECIMAL(14,2),
    ModifiedDate DATETIME2
);
GO

---------------------------------------------------------------
-- Order Items
---------------------------------------------------------------

CREATE TABLE src.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    DiscountPercent DECIMAL(5,2)
);
GO



/* Insert realistic company departments */

INSERT INTO src.Departments
(
    DepartmentID,
    DepartmentName,
    Location,
    CreatedDate
)
VALUES
(1,'Sales','Dubai','2020-01-01'),
(2,'Marketing','Dubai','2020-01-01'),
(3,'Finance','Kuwait','2020-01-01'),
(4,'IT','Kuwait','2020-01-01'),
(5,'HR','Kuwait','2020-01-01'),
(6,'Operations','Riyadh','2020-01-01'),
(7,'Procurement','Riyadh','2020-01-01'),
(8,'Customer Service','Kuwait','2020-01-01');
GO


/* Generate 40 employees */

;WITH E AS
(
    SELECT 1 AS EmployeeID

    UNION ALL

    SELECT EmployeeID + 1
    FROM E
    WHERE EmployeeID < 40
)
INSERT INTO src.Employees
(
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    JobTitle,
    HireDate,
    Salary,
    IsActive
)
SELECT
    EmployeeID,
    CONCAT('Employee',EmployeeID),
    CONCAT('Last',EmployeeID),
    ((EmployeeID - 1) % 8) + 1,
    CASE
        WHEN EmployeeID % 5 = 0 THEN 'Manager'
        WHEN EmployeeID % 3 = 0 THEN 'Senior Executive'
        ELSE 'Executive'
    END,
    DATEADD(DAY, -EmployeeID * 100, CAST(GETDATE() AS DATE)),
    3500 + (EmployeeID * 175),
    CASE
        WHEN EmployeeID % 10 = 0 THEN 0
        ELSE 1
    END
FROM E
OPTION (MAXRECURSION 100);
GO



/* Product categories */

INSERT INTO src.Categories
(
    CategoryID,
    CategoryName,
    DepartmentID
)
VALUES
(1,'Laptops',1),
(2,'Mobile Phones',1),
(3,'Accessories',1),
(4,'Monitors',1),
(5,'Networking',4),
(6,'Storage',4),
(7,'Office Equipment',6),
(8,'Gaming',1),
(9,'Software',4),
(10,'Smart Home',6);
GO



/* Generate 500 customers */

;WITH C AS
(
    SELECT 1 AS CustomerID

    UNION ALL

    SELECT CustomerID + 1
    FROM C
    WHERE CustomerID < 500
)
INSERT INTO src.Customers
(
    CustomerID,
    CustomerNumber,
    FirstName,
    LastName,
    Email,
    Gender,
    DateOfBirth,
    City,
    Country,
    CustomerType,
    CreatedDate,
    ModifiedDate
)
SELECT
    CustomerID,
    CONCAT('CUST-',FORMAT(CustomerID,'00000')),
    CONCAT('Customer',CustomerID),
    CONCAT('LastName',CustomerID),
    CONCAT('customer',CustomerID,'@techmart.com'),

    CASE
        WHEN CustomerID % 2 = 0 THEN 'Male'
        ELSE 'Female'
    END,

    DATEADD
    (
        YEAR,
        -(20 + CustomerID % 40),
        CAST(GETDATE() AS DATE)
    ),

    CASE CustomerID % 8
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Al Farwaniyah'
        WHEN 2 THEN 'Hawally'
        WHEN 3 THEN 'Salmiya'
        WHEN 4 THEN 'Dubai'
        WHEN 5 THEN 'Abu Dhabi'
        WHEN 6 THEN 'Riyadh'
        ELSE 'Jeddah'
    END,

    CASE
        WHEN CustomerID % 4 = 0 THEN 'UAE'
        WHEN CustomerID % 4 = 1 THEN 'Kuwait'
        WHEN CustomerID % 4 = 2 THEN 'Saudi Arabia'
        ELSE 'Qatar'
    END,

    CASE
        WHEN CustomerID % 10 = 0 THEN 'VIP'
        WHEN CustomerID % 3 = 0 THEN 'Premium'
        ELSE 'Regular'
    END,

    DATEADD(DAY,-CustomerID,CAST(GETDATE() AS DATE)),
    DATEADD(DAY,-CustomerID,CAST(GETDATE() AS DATETIME2))
FROM C
OPTION (MAXRECURSION 600);
GO




/* Generate 100 products */

;WITH P AS
(
    SELECT 1 AS ProductID

    UNION ALL

    SELECT ProductID + 1
    FROM P
    WHERE ProductID < 100
)
INSERT INTO src.Products
(
    ProductID,
    ProductSKU,
    ProductName,
    CategoryID,
    Supplier,
    UnitCost,
    UnitPrice,
    StockQuantity,
    ProductStatus,
    CreatedDate,
    ModifiedDate
)
SELECT
    ProductID,
    CONCAT('SKU-',FORMAT(ProductID,'00000')),
    CONCAT('Product ',ProductID),
    ((ProductID - 1) % 10) + 1,
    CONCAT('Supplier ',((ProductID - 1) % 15) + 1),

    20 + ProductID * 7,

    40 + ProductID * 12,

    50 + (ProductID * 17) % 500,

    CASE
        WHEN ProductID % 15 = 0 THEN 'Discontinued'
        WHEN ProductID % 10 = 0 THEN 'Out of Stock'
        ELSE 'Active'
    END,

    DATEADD(DAY,-ProductID*5,CAST(GETDATE() AS DATE)),
    DATEADD(DAY,-ProductID,CAST(GETDATE() AS DATETIME2))
FROM P
OPTION (MAXRECURSION 200);
GO



/* Generate 5,000 sales orders */

;WITH O AS
(
    SELECT 1 AS OrderID

    UNION ALL

    SELECT OrderID + 1
    FROM O
    WHERE OrderID < 5000
)
INSERT INTO src.Orders
(
    OrderID,
    OrderNumber,
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus,
    PaymentMethod,
    ShippingCity,
    ShippingCountry,
    TotalAmount,
    ModifiedDate
)
SELECT
    OrderID,
    CONCAT('ORD-',FORMAT(OrderID,'000000')),
    ((OrderID - 1) % 500) + 1,
    ((OrderID - 1) % 40) + 1,

    DATEADD
    (
        DAY,
        -(OrderID % 730),
        CAST(GETDATE() AS DATE)
    ),

    CASE
        WHEN OrderID % 20 = 0 THEN 'Cancelled'
        WHEN OrderID % 10 = 0 THEN 'Pending'
        WHEN OrderID % 15 = 0 THEN 'Returned'
        ELSE 'Completed'
    END,

    CASE OrderID % 4
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Debit Card'
        WHEN 2 THEN 'Cash'
        ELSE 'Online'
    END,

    CASE OrderID % 5
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Dubai'
        WHEN 2 THEN 'Riyadh'
        WHEN 3 THEN 'Abu Dhabi'
        ELSE 'Hawally'
    END,

    CASE OrderID % 5
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'UAE'
        WHEN 2 THEN 'Saudi Arabia'
        WHEN 3 THEN 'UAE'
        ELSE 'Kuwait'
    END,

    0,

    DATEADD
    (
        DAY,
        -(OrderID % 30),
        CAST(GETDATE() AS DATETIME2)
    )
FROM O
OPTION (MAXRECURSION 6000);
GO


/* Generate approximately 15,000 order lines */

;WITH O AS
(
    SELECT 1 AS OrderItemID

    UNION ALL

    SELECT OrderItemID + 1
    FROM O
    WHERE OrderItemID < 15000
)
INSERT INTO src.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPercent
)
SELECT
    OrderItemID,

    ((OrderItemID - 1) % 5000) + 1,

    ((OrderItemID * 7) % 100) + 1,

    ((OrderItemID % 5) + 1),

    P.UnitPrice,

    CASE
        WHEN OrderItemID % 10 = 0 THEN 10
        WHEN OrderItemID % 5 = 0 THEN 5
        ELSE 0
    END
FROM O
JOIN src.Products P
    ON P.ProductID = ((O.OrderItemID * 7) % 100) + 1
OPTION (MAXRECURSION 16000);
GO

/* Update Order totals */

UPDATE O
SET TotalAmount =
(
    SELECT
        SUM
        (
            OI.Quantity *
            OI.UnitPrice *
            (1 - OI.DiscountPercent / 100.0)
        )
    FROM src.OrderItems OI
    WHERE OI.OrderID = O.OrderID
)
FROM src.Orders O;
GO

