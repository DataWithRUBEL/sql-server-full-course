/* =========================================================
   EXECUTION PLANS TRAINING DATABASE
   Database: Execution plansDB
   Purpose:
       SQL Server Execution Plan
       Query Performance Tuning
       Data Analyst + Data Engineer Practice
   ========================================================= */

USE master;
GO

/* ---------------------------------------------------------
   1. Create Database
   --------------------------------------------------------- */

IF DB_ID(N'Execution plansDB') IS NOT NULL
BEGIN
    ALTER DATABASE [Execution plansDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [Execution plansDB];
END;
GO

CREATE DATABASE [Execution plansDB];
GO

USE [Execution plansDB];
GO

/* ---------------------------------------------------------
   2. Create Schemas
   --------------------------------------------------------- */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Warehouse;
GO

/* =========================================================
   3. HR TABLES
   ========================================================= */

CREATE TABLE HR.Departments
(
    DepartmentID INT IDENTITY(1,1)
        CONSTRAINT PK_Departments PRIMARY KEY,

    DepartmentName VARCHAR(100) NOT NULL,

    Location VARCHAR(100) NOT NULL
);
GO


CREATE TABLE HR.Employees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_Employees PRIMARY KEY,

    EmployeeName VARCHAR(150) NOT NULL,

    DepartmentID INT NOT NULL,

    JobTitle VARCHAR(100) NOT NULL,

    HireDate DATE NOT NULL,

    Salary DECIMAL(12,2) NOT NULL,

    ManagerID INT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Employees_IsActive DEFAULT 1,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO


/* =========================================================
   4. SALES TABLES
   ========================================================= */

CREATE TABLE Sales.Customers
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_Customers PRIMARY KEY,

    CustomerName VARCHAR(150) NOT NULL,

    Email VARCHAR(200) NOT NULL,

    City VARCHAR(100) NOT NULL,

    Country VARCHAR(100) NOT NULL,

    CustomerSegment VARCHAR(30) NOT NULL,

    RegistrationDate DATE NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Customers_IsActive DEFAULT 1
);
GO


CREATE TABLE Sales.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_Products PRIMARY KEY,

    ProductName VARCHAR(200) NOT NULL,

    Category VARCHAR(100) NOT NULL,

    Brand VARCHAR(100) NOT NULL,

    UnitCost DECIMAL(12,2) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    StockQuantity INT NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Products_IsActive DEFAULT 1
);
GO


CREATE TABLE Sales.Orders
(
    OrderID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_Orders PRIMARY KEY,

    CustomerID INT NOT NULL,

    EmployeeID INT NOT NULL,

    OrderDate DATETIME2(0) NOT NULL,

    OrderStatus VARCHAR(30) NOT NULL,

    PaymentMethod VARCHAR(30) NOT NULL,

    ShippingCity VARCHAR(100) NOT NULL,

    TotalAmount DECIMAL(14,2) NOT NULL,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES HR.Employees(EmployeeID)
);
GO


CREATE TABLE Sales.OrderItems
(
    OrderItemID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_OrderItems PRIMARY KEY,

    OrderID BIGINT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    DiscountAmount DECIMAL(12,2) NOT NULL,

    LineTotal AS
        ((Quantity * UnitPrice) - DiscountAmount) PERSISTED,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Sales.Products(ProductID)
);
GO


/* =========================================================
   5. DATA WAREHOUSE TABLES
   ========================================================= */

CREATE TABLE Warehouse.DimDate
(
    DateKey INT
        CONSTRAINT PK_DimDate PRIMARY KEY,

    FullDate DATE NOT NULL,

    CalendarYear INT NOT NULL,

    CalendarQuarter INT NOT NULL,

    CalendarMonth INT NOT NULL,

    MonthName VARCHAR(20) NOT NULL,

    DayName VARCHAR(20) NOT NULL
);
GO


CREATE TABLE Warehouse.FactSales
(
    SalesKey BIGINT IDENTITY(1,1)
        CONSTRAINT PK_FactSales PRIMARY KEY,

    OrderID BIGINT NOT NULL,

    CustomerID INT NOT NULL,

    ProductID INT NOT NULL,

    EmployeeID INT NOT NULL,

    DateKey INT NOT NULL,

    Quantity INT NOT NULL,

    SalesAmount DECIMAL(14,2) NOT NULL,

    CostAmount DECIMAL(14,2) NOT NULL,

    DiscountAmount DECIMAL(14,2) NOT NULL
);
GO


/* =========================================================
   6. DEPARTMENT DATA
   ========================================================= */

INSERT INTO HR.Departments
(
    DepartmentName,
    Location
)
VALUES
('Sales', 'Kuwait City'),
('Finance', 'Kuwait City'),
('IT', 'Farwaniyah'),
('HR', 'Hawally'),
('Marketing', 'Salmiya'),
('Operations', 'Shuwaikh'),
('Supply Chain', 'Shuwaikh'),
('Customer Service', 'Kuwait City'),
('Data & Analytics', 'Farwaniyah'),
('Management', 'Kuwait City');
GO


/* =========================================================
   7. EMPLOYEE DATA
   100 Employees
   ========================================================= */

;WITH N AS
(
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO HR.Employees
(
    EmployeeName,
    DepartmentID,
    JobTitle,
    HireDate,
    Salary,
    ManagerID,
    IsActive
)
SELECT
    CONCAT('Employee ', n),

    ((n - 1) % 10) + 1,

    CASE
        WHEN n % 5 = 0 THEN 'Manager'
        WHEN n % 3 = 0 THEN 'Senior Analyst'
        ELSE 'Analyst'
    END,

    DATEADD
    (
        DAY,
        -(n * 30),
        CAST(GETDATE() AS DATE)
    ),

    2500 + ((n % 15) * 350),

    CASE
        WHEN n <= 10 THEN NULL
        ELSE ((n - 1) % 10) + 1
    END,

    CASE
        WHEN n % 17 = 0 THEN 0
        ELSE 1
    END
FROM N;
GO


/* =========================================================
   8. CUSTOMER DATA
   1,000 Customers
   ========================================================= */

;WITH N AS
(
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Customers
(
    CustomerName,
    Email,
    City,
    Country,
    CustomerSegment,
    RegistrationDate,
    IsActive
)
SELECT
    CONCAT('Customer ', n),

    CONCAT
    (
        'customer',
        n,
        '@company.com'
    ),

    CASE n % 8
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Farwaniyah'
        WHEN 2 THEN 'Hawally'
        WHEN 3 THEN 'Salmiya'
        WHEN 4 THEN 'Jahra'
        WHEN 5 THEN 'Ahmadi'
        WHEN 6 THEN 'Mubarak Al-Kabeer'
        ELSE 'Fahaheel'
    END,

    CASE n % 5
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'Saudi Arabia'
        WHEN 2 THEN 'UAE'
        WHEN 3 THEN 'Qatar'
        ELSE 'Bahrain'
    END,

    CASE n % 4
        WHEN 0 THEN 'VIP'
        WHEN 1 THEN 'Premium'
        WHEN 2 THEN 'Regular'
        ELSE 'New'
    END,

    DATEADD
    (
        DAY,
        -(n * 3),
        CAST(GETDATE() AS DATE)
    ),

    CASE
        WHEN n % 19 = 0 THEN 0
        ELSE 1
    END
FROM N;
GO


/* =========================================================
   9. PRODUCT DATA
   500 Products
   ========================================================= */

;WITH N AS
(
    SELECT TOP (500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Products
(
    ProductName,
    Category,
    Brand,
    UnitCost,
    UnitPrice,
    StockQuantity,
    IsActive
)
SELECT
    CONCAT('Product ', n),

    CASE n % 8
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Clothing'
        WHEN 2 THEN 'Accessories'
        WHEN 3 THEN 'Home'
        WHEN 4 THEN 'Sports'
        WHEN 5 THEN 'Beauty'
        WHEN 6 THEN 'Grocery'
        ELSE 'Office'
    END,

    CASE n % 6
        WHEN 0 THEN 'Brand A'
        WHEN 1 THEN 'Brand B'
        WHEN 2 THEN 'Brand C'
        WHEN 3 THEN 'Brand D'
        WHEN 4 THEN 'Brand E'
        ELSE 'Brand F'
    END,

    5 + ((n % 50) * 2),

    10 + ((n % 50) * 4),

    20 + ((n * 7) % 500),

    CASE
        WHEN n % 23 = 0 THEN 0
        ELSE 1
    END
FROM N;
GO


/* =========================================================
   10. ORDERS
   20,000 Orders
   ========================================================= */

;WITH N AS
(
    SELECT TOP (20000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Orders
(
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus,
    PaymentMethod,
    ShippingCity,
    TotalAmount
)
SELECT
    ((n - 1) % 1000) + 1,

    ((n - 1) % 100) + 1,

    DATEADD
    (
        DAY,
        -(n % 1000),
        CAST(GETDATE() AS DATETIME2)
    ),

    CASE n % 5
        WHEN 0 THEN 'Completed'
        WHEN 1 THEN 'Completed'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Shipped'
        ELSE 'Cancelled'
    END,

    CASE n % 4
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'KNET'
        WHEN 2 THEN 'Cash'
        ELSE 'Bank Transfer'
    END,

    CASE n % 5
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Farwaniyah'
        WHEN 2 THEN 'Hawally'
        WHEN 3 THEN 'Salmiya'
        ELSE 'Ahmadi'
    END,

    100 + ((n * 17) % 5000)
FROM N;
GO


/* =========================================================
   11. ORDER ITEMS
   Approximately 60,000 rows
   ========================================================= */

INSERT INTO Sales.OrderItems
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountAmount
)
SELECT
    o.OrderID,

    ((o.OrderID * v.ItemNo) % 500) + 1,

    ((o.OrderID + v.ItemNo) % 5) + 1,

    p.UnitPrice,

    CASE
        WHEN o.OrderID % 10 = 0
            THEN p.UnitPrice * 0.10
        ELSE 0
    END
FROM Sales.Orders o
CROSS JOIN
(
    VALUES (1),(2),(3)
) v(ItemNo)
JOIN Sales.Products p
    ON p.ProductID =
       ((o.OrderID * v.ItemNo) % 500) + 1;
GO


/* =========================================================
   12. DATE DIMENSION
   5 Years
   ========================================================= */

;WITH D AS
(
    SELECT CAST('2022-01-01' AS DATE) AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM D
    WHERE FullDate < '2026-12-31'
)
INSERT INTO Warehouse.DimDate
(
    DateKey,
    FullDate,
    CalendarYear,
    CalendarQuarter,
    CalendarMonth,
    MonthName,
    DayName
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)),

    FullDate,

    YEAR(FullDate),

    DATEPART(QUARTER, FullDate),

    MONTH(FullDate),

    DATENAME(MONTH, FullDate),

    DATENAME(WEEKDAY, FullDate)
FROM D
OPTION (MAXRECURSION 0);
GO


/* =========================================================
   13. FACT SALES
   ========================================================= */

INSERT INTO Warehouse.FactSales
(
    OrderID,
    CustomerID,
    ProductID,
    EmployeeID,
    DateKey,
    Quantity,
    SalesAmount,
    CostAmount,
    DiscountAmount
)
SELECT
    oi.OrderID,

    o.CustomerID,

    oi.ProductID,

    o.EmployeeID,

    CONVERT
    (
        INT,
        CONVERT
        (
            CHAR(8),
            CAST(o.OrderDate AS DATE),
            112
        )
    ),

    oi.Quantity,

    oi.LineTotal,

    oi.Quantity * p.UnitCost,

    oi.DiscountAmount
FROM Sales.OrderItems oi
JOIN Sales.Orders o
    ON o.OrderID = oi.OrderID
JOIN Sales.Products p
    ON p.ProductID = oi.ProductID;
GO


/* =========================================================
   14. Update Statistics
   ========================================================= */

UPDATE STATISTICS Sales.Customers;
UPDATE STATISTICS Sales.Products;
UPDATE STATISTICS Sales.Orders;
UPDATE STATISTICS Sales.OrderItems;

UPDATE STATISTICS HR.Employees;

UPDATE STATISTICS Warehouse.FactSales;
UPDATE STATISTICS Warehouse.DimDate;
GO


/* =========================================================
   15. Verify Dataset
   ========================================================= */

SELECT 'Departments' AS TableName, COUNT(*) AS RowCount
FROM HR.Departments

UNION ALL

SELECT 'Employees', COUNT(*)
FROM HR.Employees

UNION ALL

SELECT 'Customers', COUNT(*)
FROM Sales.Customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM Sales.Products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Sales.Orders

UNION ALL

SELECT 'OrderItems', COUNT(*)
FROM Sales.OrderItems

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM Warehouse.DimDate

UNION ALL

SELECT 'FactSales', COUNT(*)
FROM Warehouse.FactSales;
GO
