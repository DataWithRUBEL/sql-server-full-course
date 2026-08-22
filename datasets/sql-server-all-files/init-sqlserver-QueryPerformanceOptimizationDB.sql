/* ============================================================
   QUERY PERFORMANCE OPTIMIZATION DATABASE
   SQL Server
   E-Commerce Company Practice Environment
   ============================================================ */

USE master;
GO

/* ------------------------------------------------------------
   1. Create Database
   ------------------------------------------------------------ */

IF DB_ID('QueryPerformanceOptimizationDB') IS NOT NULL
BEGIN
    ALTER DATABASE QueryPerformanceOptimizationDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE QueryPerformanceOptimizationDB;
END;
GO

CREATE DATABASE QueryPerformanceOptimizationDB;
GO

USE QueryPerformanceOptimizationDB;
GO

/* ------------------------------------------------------------
   2. Create Schemas
   ------------------------------------------------------------ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Inventory;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Analytics;
GO

/* ============================================================
   3. DEPARTMENTS
   ============================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT IDENTITY(1,1)
        CONSTRAINT PK_Departments PRIMARY KEY,

    DepartmentName VARCHAR(100) NOT NULL,

    ManagerEmployeeID INT NULL,

    CreatedDate DATETIME2 NOT NULL
        CONSTRAINT DF_Departments_CreatedDate
        DEFAULT SYSDATETIME()
);
GO

/* ============================================================
   4. EMPLOYEES
   ============================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_Employees PRIMARY KEY,

    FirstName VARCHAR(50) NOT NULL,

    LastName VARCHAR(50) NOT NULL,

    DepartmentID INT NOT NULL,

    JobTitle VARCHAR(100) NOT NULL,

    Salary DECIMAL(12,2) NOT NULL,

    HireDate DATE NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Employees_IsActive
        DEFAULT 1,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO

/* ============================================================
   5. CUSTOMERS
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_Customers PRIMARY KEY,

    CustomerNumber VARCHAR(20) NOT NULL,

    FirstName VARCHAR(50) NOT NULL,

    LastName VARCHAR(50) NOT NULL,

    Email VARCHAR(150) NOT NULL,

    City VARCHAR(100) NOT NULL,

    Country VARCHAR(100) NOT NULL,

    CustomerSegment VARCHAR(30) NOT NULL,

    RegistrationDate DATE NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Customers_IsActive
        DEFAULT 1
);
GO

/* ============================================================
   6. CATEGORIES
   ============================================================ */

CREATE TABLE Inventory.Categories
(
    CategoryID INT IDENTITY(1,1)
        CONSTRAINT PK_Categories PRIMARY KEY,

    CategoryName VARCHAR(100) NOT NULL,

    ParentCategoryID INT NULL
);
GO

/* ============================================================
   7. PRODUCTS
   ============================================================ */

CREATE TABLE Inventory.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_Products PRIMARY KEY,

    ProductSKU VARCHAR(30) NOT NULL,

    ProductName VARCHAR(150) NOT NULL,

    CategoryID INT NOT NULL,

    SupplierID INT NOT NULL,

    UnitCost DECIMAL(12,2) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    StockQuantity INT NOT NULL,

    ReorderLevel INT NOT NULL,

    ProductStatus VARCHAR(30) NOT NULL,

    CreatedDate DATE NOT NULL
);
GO

/* ============================================================
   8. ORDERS
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_Orders PRIMARY KEY,

    OrderNumber VARCHAR(30) NOT NULL,

    CustomerID INT NOT NULL,

    EmployeeID INT NULL,

    OrderDate DATETIME2 NOT NULL,

    RequiredDate DATE NULL,

    ShippedDate DATE NULL,

    OrderStatus VARCHAR(30) NOT NULL,

    ShippingCity VARCHAR(100) NOT NULL,

    ShippingCountry VARCHAR(100) NOT NULL,

    TotalAmount DECIMAL(14,2) NOT NULL,

    CreatedDate DATETIME2 NOT NULL
        CONSTRAINT DF_Orders_CreatedDate
        DEFAULT SYSDATETIME()
);
GO

/* ============================================================
   9. ORDER ITEMS
   ============================================================ */

CREATE TABLE Sales.OrderItems
(
    OrderItemID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_OrderItems PRIMARY KEY,

    OrderID BIGINT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    DiscountPercent DECIMAL(5,2) NOT NULL,

    LineTotal AS
    (
        Quantity * UnitPrice
        * (1 - DiscountPercent / 100)
    ) PERSISTED
);
GO

/* ============================================================
   10. PAYMENTS
   ============================================================ */

CREATE TABLE Sales.Payments
(
    PaymentID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_Payments PRIMARY KEY,

    OrderID BIGINT NOT NULL,

    PaymentDate DATETIME2 NOT NULL,

    PaymentMethod VARCHAR(30) NOT NULL,

    PaymentStatus VARCHAR(30) NOT NULL,

    Amount DECIMAL(14,2) NOT NULL
);
GO

/* ============================================================
   11. SHIPMENTS
   ============================================================ */

CREATE TABLE Sales.Shipments
(
    ShipmentID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_Shipments PRIMARY KEY,

    OrderID BIGINT NOT NULL,

    Carrier VARCHAR(50) NOT NULL,

    TrackingNumber VARCHAR(100) NOT NULL,

    ShipmentDate DATETIME2 NOT NULL,

    DeliveryDate DATE NULL,

    ShippingCost DECIMAL(10,2) NOT NULL,

    ShipmentStatus VARCHAR(30) NOT NULL
);
GO

/* ============================================================
   12. PRODUCT REVIEWS
   ============================================================ */

CREATE TABLE Inventory.ProductReviews
(
    ReviewID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_ProductReviews PRIMARY KEY,

    ProductID INT NOT NULL,

    CustomerID INT NOT NULL,

    Rating TINYINT NOT NULL,

    ReviewDate DATE NOT NULL,

    ReviewTitle VARCHAR(200) NULL,

    ReviewText VARCHAR(1000) NULL
);
GO

/* ============================================================
   13. DATE DIMENSION
   ============================================================ */

CREATE TABLE Analytics.DateDimension
(
    DateKey INT
        CONSTRAINT PK_DateDimension PRIMARY KEY,

    FullDate DATE NOT NULL,

    YearNumber SMALLINT NOT NULL,

    QuarterNumber TINYINT NOT NULL,

    MonthNumber TINYINT NOT NULL,

    MonthName VARCHAR(20) NOT NULL,

    DayNumber TINYINT NOT NULL,

    DayName VARCHAR(20) NOT NULL,

    IsWeekend BIT NOT NULL
);
GO


/* ============================================================
   DATA GENERATION
   ============================================================ */

/* ------------------------------------------------------------
   Departments
   ------------------------------------------------------------ */

INSERT INTO HR.Departments
(
    DepartmentName
)
VALUES
('Sales'),
('Finance'),
('IT'),
('HR'),
('Operations'),
('Marketing'),
('Customer Service'),
('Supply Chain'),
('Data Analytics'),
('Data Engineering');
GO


/* ------------------------------------------------------------
   Employees - 200 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO HR.Employees
(
    FirstName,
    LastName,
    DepartmentID,
    JobTitle,
    Salary,
    HireDate,
    IsActive
)
SELECT
    CONCAT('Employee', n),
    CONCAT('LastName', n),
    ((n - 1) % 10) + 1,
    CASE
        WHEN n % 5 = 0 THEN 'Senior Analyst'
        WHEN n % 5 = 1 THEN 'Sales Executive'
        WHEN n % 5 = 2 THEN 'Data Engineer'
        WHEN n % 5 = 3 THEN 'Operations Executive'
        ELSE 'Business Analyst'
    END,
    35000 + ((n * 1375) % 85000),
    DATEADD(DAY, -(n * 17), CAST('2026-01-01' AS DATE)),
    CASE WHEN n % 20 = 0 THEN 0 ELSE 1 END
FROM N;
GO


/* ------------------------------------------------------------
   Customers - 50,000 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (50000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    CROSS JOIN sys.all_objects c
)
INSERT INTO Sales.Customers
(
    CustomerNumber,
    FirstName,
    LastName,
    Email,
    City,
    Country,
    CustomerSegment,
    RegistrationDate,
    IsActive
)
SELECT
    CONCAT('CUS-', RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)),
    CONCAT('Customer', n),
    CONCAT('Last', n),
    CONCAT('customer', n, '@company.com'),
    CASE n % 10
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Dubai'
        WHEN 2 THEN 'Riyadh'
        WHEN 3 THEN 'Doha'
        WHEN 4 THEN 'Manama'
        WHEN 5 THEN 'Dhaka'
        WHEN 6 THEN 'London'
        WHEN 7 THEN 'New York'
        WHEN 8 THEN 'Toronto'
        ELSE 'Singapore'
    END,
    CASE n % 10
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'UAE'
        WHEN 2 THEN 'Saudi Arabia'
        WHEN 3 THEN 'Qatar'
        WHEN 4 THEN 'Bahrain'
        WHEN 5 THEN 'Bangladesh'
        WHEN 6 THEN 'UK'
        WHEN 7 THEN 'USA'
        WHEN 8 THEN 'Canada'
        ELSE 'Singapore'
    END,
    CASE
        WHEN n % 20 = 0 THEN 'VIP'
        WHEN n % 5 = 0 THEN 'Premium'
        ELSE 'Regular'
    END,
    DATEADD(DAY, -(n % 2500), CAST('2026-08-01' AS DATE)),
    CASE WHEN n % 25 = 0 THEN 0 ELSE 1 END
FROM N;
GO


/* ------------------------------------------------------------
   Categories
   ------------------------------------------------------------ */

INSERT INTO Inventory.Categories
(
    CategoryName
)
VALUES
('Electronics'),
('Computers'),
('Mobile Accessories'),
('Home Appliances'),
('Furniture'),
('Clothing'),
('Sports'),
('Books'),
('Beauty'),
('Grocery'),
('Automotive'),
('Office Supplies'),
('Gaming'),
('Toys'),
('Health');
GO


/* ------------------------------------------------------------
   Products - 5,000 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (5000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    CROSS JOIN sys.all_objects c
)
INSERT INTO Inventory.Products
(
    ProductSKU,
    ProductName,
    CategoryID,
    SupplierID,
    UnitCost,
    UnitPrice,
    StockQuantity,
    ReorderLevel,
    ProductStatus,
    CreatedDate
)
SELECT
    CONCAT('SKU-', RIGHT('000000' + CAST(n AS VARCHAR(6)), 6)),
    CONCAT('Product ', n),
    ((n - 1) % 15) + 1,
    ((n - 1) % 100) + 1,
    CAST(10 + ((n * 17) % 500) AS DECIMAL(12,2)),
    CAST(20 + ((n * 29) % 1000) AS DECIMAL(12,2)),
    (n * 37) % 1000,
    20 + (n % 100),
    CASE
        WHEN n % 25 = 0 THEN 'Discontinued'
        WHEN n % 10 = 0 THEN 'Out of Stock'
        ELSE 'Active'
    END,
    DATEADD(DAY, -(n % 2000), CAST('2026-08-01' AS DATE))
FROM N;
GO


/* ------------------------------------------------------------
   Orders - 500,000 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (500000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    CROSS JOIN sys.all_objects c
    CROSS JOIN sys.all_objects d
)
INSERT INTO Sales.Orders
(
    OrderNumber,
    CustomerID,
    EmployeeID,
    OrderDate,
    RequiredDate,
    ShippedDate,
    OrderStatus,
    ShippingCity,
    ShippingCountry,
    TotalAmount
)
SELECT
    CONCAT('ORD-', RIGHT('0000000' + CAST(n AS VARCHAR(7)), 7)),
    ((n - 1) % 50000) + 1,
    CASE WHEN n % 20 = 0 THEN NULL
         ELSE ((n - 1) % 200) + 1
    END,
    DATEADD
    (
        MINUTE,
        n % 1440,
        DATEADD
        (
            DAY,
            -(n % 1000),
            CAST('2026-08-01' AS DATETIME2)
        )
    ),
    DATEADD
    (
        DAY,
        3,
        DATEADD
        (
            DAY,
            -(n % 1000),
            CAST('2026-08-01' AS DATE)
        )
    ),
    CASE
        WHEN n % 15 = 0 THEN NULL
        ELSE DATEADD
        (
            DAY,
            2,
            DATEADD
            (
                DAY,
                -(n % 1000),
                CAST('2026-08-01' AS DATE)
            )
        )
    END,
    CASE
        WHEN n % 20 = 0 THEN 'Cancelled'
        WHEN n % 10 = 0 THEN 'Pending'
        WHEN n % 7 = 0 THEN 'Processing'
        WHEN n % 5 = 0 THEN 'Shipped'
        ELSE 'Completed'
    END,
    CASE n % 6
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Dubai'
        WHEN 2 THEN 'Riyadh'
        WHEN 3 THEN 'Doha'
        WHEN 4 THEN 'Dhaka'
        ELSE 'Manama'
    END,
    CASE n % 6
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'UAE'
        WHEN 2 THEN 'Saudi Arabia'
        WHEN 3 THEN 'Qatar'
        WHEN 4 THEN 'Bangladesh'
        ELSE 'Bahrain'
    END,
    CAST(50 + ((n * 73) % 5000) AS DECIMAL(14,2))
FROM N;
GO


/* ------------------------------------------------------------
   Order Items - 1,500,000 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (1500000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    CROSS JOIN sys.all_objects c
    CROSS JOIN sys.all_objects d
)
INSERT INTO Sales.OrderItems
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountPercent
)
SELECT
    ((n - 1) % 500000) + 1,
    ((n * 17) % 5000) + 1,
    1 + (n % 5),
    CAST(20 + ((n * 29) % 1000) AS DECIMAL(12,2)),
    CASE
        WHEN n % 20 = 0 THEN 20
        WHEN n % 10 = 0 THEN 10
        ELSE 0
    END
FROM N;
GO


/* ------------------------------------------------------------
   Payments - 500,000 rows
   ------------------------------------------------------------ */

INSERT INTO Sales.Payments
(
    OrderID,
    PaymentDate,
    PaymentMethod,
    PaymentStatus,
    Amount
)
SELECT
    OrderID,
    DATEADD(HOUR, 2, OrderDate),
    CASE OrderID % 5
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Debit Card'
        WHEN 2 THEN 'PayPal'
        WHEN 3 THEN 'Bank Transfer'
        ELSE 'Cash'
    END,
    CASE
        WHEN OrderID % 20 = 0 THEN 'Failed'
        WHEN OrderID % 15 = 0 THEN 'Pending'
        ELSE 'Completed'
    END,
    TotalAmount
FROM Sales.Orders;
GO


/* ------------------------------------------------------------
   Shipments - approximately 475,000 rows
   ------------------------------------------------------------ */

INSERT INTO Sales.Shipments
(
    OrderID,
    Carrier,
    TrackingNumber,
    ShipmentDate,
    DeliveryDate,
    ShippingCost,
    ShipmentStatus
)
SELECT
    OrderID,
    CASE OrderID % 4
        WHEN 0 THEN 'DHL'
        WHEN 1 THEN 'FedEx'
        WHEN 2 THEN 'Aramex'
        ELSE 'UPS'
    END,
    CONCAT('TRK-', OrderID),
    DATEADD(DAY, 2, CAST(OrderDate AS DATE)),
    DATEADD(DAY, 5, CAST(OrderDate AS DATE)),
    CAST(5 + (OrderID % 50) AS DECIMAL(10,2)),
    CASE
        WHEN OrderID % 20 = 0 THEN 'Returned'
        ELSE 'Delivered'
    END
FROM Sales.Orders
WHERE OrderStatus <> 'Cancelled';
GO


/* ------------------------------------------------------------
   Product Reviews - 100,000 rows
   ------------------------------------------------------------ */

;WITH N AS
(
    SELECT TOP (100000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
    CROSS JOIN sys.all_objects c
)
INSERT INTO Inventory.ProductReviews
(
    ProductID,
    CustomerID,
    Rating,
    ReviewDate,
    ReviewTitle,
    ReviewText
)
SELECT
    ((n * 13) % 5000) + 1,
    ((n * 17) % 50000) + 1,
    CAST(1 + (n % 5) AS TINYINT),
    DATEADD(DAY, -(n % 1000), CAST('2026-08-01' AS DATE)),
    CONCAT('Review Title ', n),
    CONCAT('Customer review for product ', ((n * 13) % 5000) + 1)
FROM N;
GO


/* ------------------------------------------------------------
   Date Dimension
   ------------------------------------------------------------ */

;WITH D AS
(
    SELECT CAST('2024-01-01' AS DATE) AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM D
    WHERE FullDate < '2030-12-31'
)
INSERT INTO Analytics.DateDimension
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    DayNumber,
    DayName,
    IsWeekend
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)),
    FullDate,
    YEAR(FullDate),
    DATEPART(QUARTER, FullDate),
    MONTH(FullDate),
    DATENAME(MONTH, FullDate),
    DAY(FullDate),
    DATENAME(WEEKDAY, FullDate),
    CASE
        WHEN DATENAME(WEEKDAY, FullDate)
             IN ('Saturday','Sunday')
        THEN 1 ELSE 0
    END
FROM D
OPTION (MAXRECURSION 0);
GO
