/* ============================================================
   PIVOT / UNPIVOT COMPLETE PRACTICE DATABASE
   Database: Pivot-UnpivotDB

   Purpose:
   - Data Analyst Practice
   - Data Engineer Practice
   - PIVOT
   - UNPIVOT
   - Dynamic PIVOT
   - ETL
   - Data Warehouse
   - Reporting
   - Performance Tuning
   ============================================================ */

USE master;
GO

/* ------------------------------------------------------------
   1. Recreate Database
   ------------------------------------------------------------ */

IF DB_ID('Pivot-UnpivotDB') IS NOT NULL
BEGIN
    ALTER DATABASE [Pivot-UnpivotDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [Pivot-UnpivotDB];
END;
GO

CREATE DATABASE [Pivot-UnpivotDB];
GO

USE [Pivot-UnpivotDB];
GO


/* ============================================================
   2. Create Schemas
   ============================================================ */

CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA stg;
GO

CREATE SCHEMA dw;
GO

CREATE SCHEMA rpt;
GO


/* ============================================================
   3. Categories
   ============================================================ */

CREATE TABLE sales.Categories
(
    CategoryID INT IDENTITY(1,1)
        CONSTRAINT PK_Categories PRIMARY KEY,

    CategoryName VARCHAR(100) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Categories_IsActive DEFAULT 1
);
GO


INSERT INTO sales.Categories
(
    CategoryName
)
VALUES
('Electronics'),
('Computers'),
('Mobile Accessories'),
('Home Appliances'),
('Furniture'),
('Office Supplies'),
('Sports'),
('Clothing'),
('Beauty'),
('Grocery');
GO


/* ============================================================
   4. Customers
   ============================================================ */

CREATE TABLE sales.Customers
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_Customers PRIMARY KEY,

    CustomerName VARCHAR(100) NOT NULL,

    Gender CHAR(1)
        CHECK (Gender IN ('M','F')),

    City VARCHAR(50),

    Region VARCHAR(50),

    CustomerSegment VARCHAR(30),

    JoinDate DATE,

    IsActive BIT DEFAULT 1
);
GO


/* ------------------------------------------------------------
   Generate 120 Customers
   ------------------------------------------------------------ */

;WITH Numbers AS
(
    SELECT 1 AS N

    UNION ALL

    SELECT N + 1
    FROM Numbers
    WHERE N < 120
)
INSERT INTO sales.Customers
(
    CustomerName,
    Gender,
    City,
    Region,
    CustomerSegment,
    JoinDate
)
SELECT
    CONCAT('Customer ', N),

    CASE
        WHEN N % 2 = 0 THEN 'M'
        ELSE 'F'
    END,

    CASE N % 8
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Hawally'
        WHEN 2 THEN 'Farwaniya'
        WHEN 3 THEN 'Salmiya'
        WHEN 4 THEN 'Jahra'
        WHEN 5 THEN 'Ahmadi'
        WHEN 6 THEN 'Mubarak Al-Kabeer'
        ELSE 'Fahaheel'
    END,

    CASE N % 4
        WHEN 0 THEN 'Central'
        WHEN 1 THEN 'North'
        WHEN 2 THEN 'South'
        ELSE 'West'
    END,

    CASE
        WHEN N % 10 <= 1 THEN 'VIP'
        WHEN N % 10 <= 5 THEN 'Regular'
        ELSE 'New'
    END,

    DATEADD(DAY, -N * 7, CAST(GETDATE() AS DATE))
FROM Numbers
OPTION (MAXRECURSION 0);
GO


/* ============================================================
   5. Products
   ============================================================ */

CREATE TABLE sales.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_Products PRIMARY KEY,

    ProductName VARCHAR(150) NOT NULL,

    CategoryID INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    CostPrice DECIMAL(12,2) NOT NULL,

    IsActive BIT DEFAULT 1,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES sales.Categories(CategoryID)
);
GO


/* ------------------------------------------------------------
   Generate 100 Products
   ------------------------------------------------------------ */

;WITH Numbers AS
(
    SELECT 1 AS N

    UNION ALL

    SELECT N + 1
    FROM Numbers
    WHERE N < 100
)
INSERT INTO sales.Products
(
    ProductName,
    CategoryID,
    UnitPrice,
    CostPrice
)
SELECT
    CONCAT('Product ', N),

    ((N - 1) % 10) + 1,

    CAST(
        20 + ((N * 17) % 500)
        AS DECIMAL(12,2)
    ),

    CAST(
        (20 + ((N * 17) % 500)) * 0.65
        AS DECIMAL(12,2)
    )
FROM Numbers
OPTION (MAXRECURSION 0);
GO


/* ============================================================
   6. Employees
   ============================================================ */

CREATE TABLE hr.Employees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_Employees PRIMARY KEY,

    EmployeeName VARCHAR(100) NOT NULL,

    Department VARCHAR(50),

    JobTitle VARCHAR(100),

    Region VARCHAR(50),

    HireDate DATE,

    Salary DECIMAL(12,2)
);
GO


;WITH Numbers AS
(
    SELECT 1 AS N

    UNION ALL

    SELECT N + 1
    FROM Numbers
    WHERE N < 60
)
INSERT INTO hr.Employees
(
    EmployeeName,
    Department,
    JobTitle,
    Region,
    HireDate,
    Salary
)
SELECT
    CONCAT('Employee ', N),

    CASE N % 5
        WHEN 0 THEN 'Sales'
        WHEN 1 THEN 'Sales'
        WHEN 2 THEN 'Operations'
        WHEN 3 THEN 'Finance'
        ELSE 'Management'
    END,

    CASE N % 4
        WHEN 0 THEN 'Sales Executive'
        WHEN 1 THEN 'Sales Manager'
        WHEN 2 THEN 'Business Analyst'
        ELSE 'Operations Executive'
    END,

    CASE N % 4
        WHEN 0 THEN 'Central'
        WHEN 1 THEN 'North'
        WHEN 2 THEN 'South'
        ELSE 'West'
    END,

    DATEADD(DAY, -(N * 30), CAST(GETDATE() AS DATE)),

    CAST(500 + ((N * 73) % 2500) AS DECIMAL(12,2))
FROM Numbers
OPTION (MAXRECURSION 0);
GO


/* ============================================================
   7. Orders
   ============================================================ */

CREATE TABLE sales.Orders
(
    OrderID INT IDENTITY(1,1)
        CONSTRAINT PK_Orders PRIMARY KEY,

    CustomerID INT NOT NULL,

    EmployeeID INT NOT NULL,

    OrderDate DATE NOT NULL,

    OrderStatus VARCHAR(30) NOT NULL,

    PaymentMethod VARCHAR(30),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES hr.Employees(EmployeeID)
);
GO


/* ------------------------------------------------------------
   Generate 500 Orders
   ------------------------------------------------------------ */

;WITH Numbers AS
(
    SELECT 1 AS N

    UNION ALL

    SELECT N + 1
    FROM Numbers
    WHERE N < 500
)
INSERT INTO sales.Orders
(
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus,
    PaymentMethod
)
SELECT
    ((N - 1) % 120) + 1,

    ((N - 1) % 60) + 1,

    DATEADD(
        DAY,
        -((N * 3) % 700),
        CAST(GETDATE() AS DATE)
    ),

    CASE N % 10
        WHEN 0 THEN 'Cancelled'
        WHEN 1 THEN 'Pending'
        ELSE 'Completed'
    END,

    CASE N % 4
        WHEN 0 THEN 'Cash'
        WHEN 1 THEN 'Card'
        WHEN 2 THEN 'KNET'
        ELSE 'Online'
    END
FROM Numbers
OPTION (MAXRECURSION 0);
GO


/* ============================================================
   8. Order Items
   ============================================================ */

CREATE TABLE sales.OrderItems
(
    OrderItemID INT IDENTITY(1,1)
        CONSTRAINT PK_OrderItems PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    DiscountPercent DECIMAL(5,2) DEFAULT 0,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID)
);
GO


/* ------------------------------------------------------------
   Generate 3 items per order
   Total = 1,500+ OrderItems
   ------------------------------------------------------------ */

INSERT INTO sales.OrderItems
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPercent
)
SELECT
    O.OrderID,

    ((O.OrderID * V.ItemNo * 7) % 100) + 1,

    ((O.OrderID + V.ItemNo) % 5) + 1,

    P.UnitPrice,

    CASE
        WHEN O.OrderID % 10 = 0 THEN 10
        WHEN O.OrderID % 5 = 0 THEN 5
        ELSE 0
    END
FROM sales.Orders O

CROSS JOIN
(
    VALUES
    (1),
    (2),
    (3)
) V(ItemNo)

JOIN sales.Products P
    ON P.ProductID =
       ((O.OrderID * V.ItemNo * 7) % 100) + 1;
GO


/* ============================================================
   9. STAGING TABLE
   Wide monthly sales source
   ============================================================ */

CREATE TABLE stg.MonthlySalesWide
(
    SalesYear INT NOT NULL,

    Region VARCHAR(50) NOT NULL,

    JanSales DECIMAL(14,2),
    FebSales DECIMAL(14,2),
    MarSales DECIMAL(14,2),
    AprSales DECIMAL(14,2),
    MaySales DECIMAL(14,2),
    JunSales DECIMAL(14,2),
    JulSales DECIMAL(14,2),
    AugSales DECIMAL(14,2),
    SepSales DECIMAL(14,2),
    OctSales DECIMAL(14,2),
    NovSales DECIMAL(14,2),
    DecSales DECIMAL(14,2)
);
GO


INSERT INTO stg.MonthlySalesWide
VALUES
(2025,'Central',120000,135000,142000,150000,160000,170000,
175000,180000,190000,200000,210000,225000),

(2025,'North',95000,105000,112000,118000,125000,130000,
140000,145000,150000,160000,170000,180000),

(2025,'South',85000,92000,100000,110000,118000,125000,
130000,138000,145000,150000,158000,165000),

(2025,'West',70000,78000,85000,90000,95000,100000,
110000,115000,120000,125000,130000,140000),

(2026,'Central',140000,150000,165000,175000,180000,190000,
200000,210000,220000,230000,240000,250000),

(2026,'North',110000,120000,130000,140000,150000,160000,
170000,180000,190000,200000,210000,220000),

(2026,'South',100000,110000,120000,130000,140000,150000,
160000,170000,180000,190000,200000,210000),

(2026,'West',90000,100000,110000,120000,130000,140000,
150000,160000,170000,180000,190000,200000);
GO


/* ============================================================
   10. Data Warehouse - Date Dimension
   ============================================================ */

CREATE TABLE dw.DimDate
(
    DateKey INT
        CONSTRAINT PK_DimDate PRIMARY KEY,

    FullDate DATE NOT NULL,

    YearNumber INT,

    QuarterNumber INT,

    MonthNumber INT,

    MonthName VARCHAR(20),

    DayNumber INT,

    DayName VARCHAR(20)
);
GO


DECLARE @StartDate DATE = '2024-01-01';
DECLARE @EndDate DATE = '2026-12-31';

;WITH Dates AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY,1,FullDate)
    FROM Dates
    WHERE FullDate < @EndDate
)
INSERT INTO dw.DimDate
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    DayNumber,
    DayName
)
SELECT
    CONVERT(INT,FORMAT(FullDate,'yyyyMMdd')),
    FullDate,
    YEAR(FullDate),
    DATEPART(QUARTER,FullDate),
    MONTH(FullDate),
    DATENAME(MONTH,FullDate),
    DAY(FullDate),
    DATENAME(WEEKDAY,FullDate)
FROM Dates
OPTION (MAXRECURSION 0);
GO


/* ============================================================
   11. Dimension Tables
   ============================================================ */

CREATE TABLE dw.DimCustomer
(
    CustomerKey INT IDENTITY(1,1)
        CONSTRAINT PK_DimCustomer PRIMARY KEY,

    CustomerID INT,

    CustomerName VARCHAR(100),

    Gender CHAR(1),

    City VARCHAR(50),

    Region VARCHAR(50),

    CustomerSegment VARCHAR(30)
);
GO


INSERT INTO dw.DimCustomer
(
    CustomerID,
    CustomerName,
    Gender,
    City,
    Region,
    CustomerSegment
)
SELECT
    CustomerID,
    CustomerName,
    Gender,
    City,
    Region,
    CustomerSegment
FROM sales.Customers;
GO


CREATE TABLE dw.DimProduct
(
    ProductKey INT IDENTITY(1,1)
        CONSTRAINT PK_DimProduct PRIMARY KEY,

    ProductID INT,

    ProductName VARCHAR(150),

    CategoryID INT,

    CategoryName VARCHAR(100),

    UnitPrice DECIMAL(12,2)
);
GO


INSERT INTO dw.DimProduct
(
    ProductID,
    ProductName,
    CategoryID,
    CategoryName,
    UnitPrice
)
SELECT
    P.ProductID,
    P.ProductName,
    P.CategoryID,
    C.CategoryName,
    P.UnitPrice
FROM sales.Products P
JOIN sales.Categories C
    ON C.CategoryID = P.CategoryID;
GO


CREATE TABLE dw.DimEmployee
(
    EmployeeKey INT IDENTITY(1,1)
        CONSTRAINT PK_DimEmployee PRIMARY KEY,

    EmployeeID INT,

    EmployeeName VARCHAR(100),

    Department VARCHAR(50),

    JobTitle VARCHAR(100),

    Region VARCHAR(50)
);
GO


INSERT INTO dw.DimEmployee
(
    EmployeeID,
    EmployeeName,
    Department,
    JobTitle,
    Region
)
SELECT
    EmployeeID,
    EmployeeName,
    Department,
    JobTitle,
    Region
FROM hr.Employees;
GO


/* ============================================================
   12. Fact Table
   ============================================================ */

CREATE TABLE dw.FactSales
(
    SalesKey BIGINT IDENTITY(1,1)
        CONSTRAINT PK_FactSales PRIMARY KEY,

    OrderID INT,

    OrderItemID INT,

    DateKey INT,

    CustomerKey INT,

    ProductKey INT,

    EmployeeKey INT,

    Quantity INT,

    UnitPrice DECIMAL(12,2),

    DiscountAmount DECIMAL(14,2),

    SalesAmount DECIMAL(14,2),

    CostAmount DECIMAL(14,2),

    ProfitAmount DECIMAL(14,2)
);
GO


/* ------------------------------------------------------------
   Populate Fact Table
   ------------------------------------------------------------ */

INSERT INTO dw.FactSales
(
    OrderID,
    OrderItemID,
    DateKey,
    CustomerKey,
    ProductKey,
    EmployeeKey,
    Quantity,
    UnitPrice,
    DiscountAmount,
    SalesAmount,
    CostAmount,
    ProfitAmount
)
SELECT
    O.OrderID,

    OI.OrderItemID,

    CONVERT(INT,FORMAT(O.OrderDate,'yyyyMMdd')),

    DC.CustomerKey,

    DP.ProductKey,

    DE.EmployeeKey,

    OI.Quantity,

    OI.UnitPrice,

    OI.Quantity *
    OI.UnitPrice *
    OI.DiscountPercent / 100,

    OI.Quantity *
    OI.UnitPrice *
    (1 - OI.DiscountPercent / 100),

    OI.Quantity *
    P.CostPrice,

    (
        OI.Quantity *
        OI.UnitPrice *
        (1 - OI.DiscountPercent / 100)
    )
    -
    (
        OI.Quantity *
        P.CostPrice
    )
FROM sales.Orders O

JOIN sales.OrderItems OI
    ON O.OrderID = OI.OrderID

JOIN sales.Products P
    ON P.ProductID = OI.ProductID

JOIN dw.DimCustomer DC
    ON DC.CustomerID = O.CustomerID

JOIN dw.DimProduct DP
    ON DP.ProductID = OI.ProductID

JOIN dw.DimEmployee DE
    ON DE.EmployeeID = O.EmployeeID;
GO


/* ============================================================
   13. Basic Indexes
   ============================================================ */

CREATE INDEX IX_Orders_OrderDate
ON sales.Orders(OrderDate);

CREATE INDEX IX_Orders_CustomerID
ON sales.Orders(CustomerID);

CREATE INDEX IX_OrderItems_ProductID
ON sales.OrderItems(ProductID);

CREATE INDEX IX_FactSales_DateKey
ON dw.FactSales(DateKey);

CREATE INDEX IX_FactSales_ProductKey
ON dw.FactSales(ProductKey);

CREATE INDEX IX_FactSales_CustomerKey
ON dw.FactSales(CustomerKey);

CREATE INDEX IX_FactSales_EmployeeKey
ON dw.FactSales(EmployeeKey);
GO
