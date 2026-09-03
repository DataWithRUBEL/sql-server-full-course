/* ============================================================
   DYNAMIC SQLDB
   Realistic E-Commerce / Retail Company Practice Database
   For:
      - Data Analyst
      - Data Engineer
      - SQL Developer
      - ETL Developer
   ============================================================ */

USE master;
GO

/* ------------------------------------------------------------
   1. Drop existing database
   ------------------------------------------------------------ */

IF DB_ID(N'Dynamic SQLDB') IS NOT NULL
BEGIN
    ALTER DATABASE [Dynamic SQLDB]
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE [Dynamic SQLDB];
END;
GO

/* ------------------------------------------------------------
   2. Create database
   ------------------------------------------------------------ */

CREATE DATABASE [Dynamic SQLDB];
GO

USE [Dynamic SQLDB];
GO

/* ------------------------------------------------------------
   3. Create schemas
   ------------------------------------------------------------ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Inventory;
GO

CREATE SCHEMA Staging;
GO

CREATE SCHEMA Config;
GO

CREATE SCHEMA Audit;
GO



/* ============================================================
   Customers
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(150),
    Country NVARCHAR(50),
    City NVARCHAR(50),
    CustomerType VARCHAR(20),
    SignupDate DATE,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT SYSDATETIME()
);
GO




/* ============================================================
   Product Categories
   ============================================================ */

CREATE TABLE Inventory.Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL
);
GO





/* ============================================================
   Products
   ============================================================ */

CREATE TABLE Inventory.Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName NVARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(12,2),
    CostPrice DECIMAL(12,2),
    StockQty INT,
    IsActive BIT DEFAULT 1,
    CreatedDate DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Inventory.Categories(CategoryID)
);
GO




/* ============================================================
   Departments
   ============================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT IDENTITY(1,1) PRIMARY KEY,
    DepartmentName NVARCHAR(100) NOT NULL
);
GO



/* ============================================================
   Employees
   ============================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(100) NOT NULL,
    DepartmentID INT,
    JobTitle NVARCHAR(100),
    Salary DECIMAL(12,2),
    HireDate DATE,
    IsActive BIT DEFAULT 1,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO


/* ============================================================
   Orders
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT IDENTITY(10001,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30),
    PaymentMethod VARCHAR(30),
    ShippingCountry NVARCHAR(50),
    TotalAmount DECIMAL(14,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID)
);
GO




/* ============================================================
   Order Items
   ============================================================ */

CREATE TABLE Sales.OrderItems
(
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2),
    DiscountPercent DECIMAL(5,2),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Inventory.Products(ProductID)
);
GO



/* ============================================================
   Staging table for ETL practice
   ============================================================ */

CREATE TABLE Staging.SalesRaw
(
    SourceOrderID INT,
    CustomerID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    SourceSystem VARCHAR(50),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO




/* ============================================================
   ETL Configuration
   ============================================================ */

CREATE TABLE Config.ETLTableConfig
(
    ConfigID INT IDENTITY(1,1) PRIMARY KEY,
    SchemaName SYSNAME,
    TableName SYSNAME,
    IsEnabled BIT DEFAULT 1,
    LoadType VARCHAR(20),
    LastLoadDate DATETIME2 NULL
);
GO



/* ============================================================
   Dynamic SQL execution audit
   ============================================================ */

CREATE TABLE Audit.DynamicSQLLog
(
    LogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProcessName NVARCHAR(200),
    SQLStatement NVARCHAR(MAX),
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status VARCHAR(20),
    ErrorMessage NVARCHAR(MAX)
);
GO


/* ============================================================
   Categories
   ============================================================ */

INSERT INTO Inventory.Categories
(CategoryName)
VALUES
('Electronics'),
('Clothing'),
('Home'),
('Sports'),
('Accessories');
GO


/* ============================================================
   Departments
   ============================================================ */

INSERT INTO HR.Departments
(DepartmentName)
VALUES
('Sales'),
('Finance'),
('IT'),
('HR'),
('Operations');
GO



/* ============================================================
   Generate 100 realistic customers
   ============================================================ */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Customers
(
    CustomerName,
    Email,
    Country,
    City,
    CustomerType,
    SignupDate,
    IsActive
)
SELECT
    CONCAT('Customer ', n),
    CONCAT('customer', n, '@company.com'),

    CASE n % 5
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'Bangladesh'
        WHEN 2 THEN 'UAE'
        WHEN 3 THEN 'Saudi Arabia'
        ELSE 'Qatar'
    END,

    CASE n % 5
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Dhaka'
        WHEN 2 THEN 'Dubai'
        WHEN 3 THEN 'Riyadh'
        ELSE 'Doha'
    END,

    CASE
        WHEN n % 10 = 0 THEN 'VIP'
        WHEN n % 3 = 0 THEN 'Regular'
        ELSE 'New'
    END,

    DATEADD(DAY, -n * 7, CAST(GETDATE() AS DATE)),
    CASE WHEN n % 10 = 0 THEN 0 ELSE 1 END
FROM N;
GO


/* ============================================================
   Generate employees
   ============================================================ */

;WITH N AS
(
    SELECT TOP (50)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects
)
INSERT INTO HR.Employees
(
    EmployeeName,
    DepartmentID,
    JobTitle,
    Salary,
    HireDate,
    IsActive
)
SELECT
    CONCAT('Employee ', n),
    ((n - 1) % 5) + 1,

    CASE n % 4
        WHEN 0 THEN 'Manager'
        WHEN 1 THEN 'Analyst'
        WHEN 2 THEN 'Executive'
        ELSE 'Specialist'
    END,

    25000 + (n * 750),

    DATEADD(DAY, -n * 30, CAST(GETDATE() AS DATE)),

    CASE WHEN n % 10 = 0 THEN 0 ELSE 1 END
FROM N;
GO



/* ============================================================
   Generate products
   ============================================================ */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Inventory.Products
(
    ProductName,
    CategoryID,
    UnitPrice,
    CostPrice,
    StockQty,
    IsActive
)
SELECT
    CONCAT('Product ', n),
    ((n - 1) % 5) + 1,
    CAST(20 + (n * 3.75) AS DECIMAL(12,2)),
    CAST(10 + (n * 2.10) AS DECIMAL(12,2)),
    50 + (n * 10),
    CASE WHEN n % 15 = 0 THEN 0 ELSE 1 END
FROM N;
GO




/* ============================================================
   Generate 500 orders
   ============================================================ */

;WITH N AS
(
    SELECT TOP (500)
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
    ShippingCountry,
    TotalAmount
)
SELECT
    ((n - 1) % 100) + 1,
    ((n - 1) % 50) + 1,
    DATEADD(DAY, -(n % 730), CAST(GETDATE() AS DATE)),

    CASE n % 5
        WHEN 0 THEN 'Cancelled'
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Shipped'
        WHEN 3 THEN 'Delivered'
        ELSE 'Processing'
    END,

    CASE n % 4
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'Bank Transfer'
        ELSE 'Online'
    END,

    CASE n % 5
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'Bangladesh'
        WHEN 2 THEN 'UAE'
        WHEN 3 THEN 'Saudi Arabia'
        ELSE 'Qatar'
    END,

    CAST(100 + ((n * 37) % 5000) AS DECIMAL(14,2))
FROM N;
GO


/* ============================================================
   Generate order items
   ============================================================ */

;WITH N AS
(
    SELECT TOP (1500)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
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
    10001 + ((n - 1) % 500),
    ((n - 1) % 100) + 1,
    (n % 5) + 1,
    CAST(20 + ((((n - 1) % 100) + 1) * 3.75) AS DECIMAL(12,2)),
    CASE
        WHEN n % 10 = 0 THEN 15
        WHEN n % 5 = 0 THEN 10
        ELSE 0
    END
FROM N;
GO



/* ============================================================
   Configure tables for metadata-driven processing
   ============================================================ */

INSERT INTO Config.ETLTableConfig
(
    SchemaName,
    TableName,
    IsEnabled,
    LoadType
)
VALUES
('Sales', 'Customers', 1, 'FULL'),
('Sales', 'Orders', 1, 'FULL'),
('Sales', 'OrderItems', 1, 'INCREMENTAL'),
('Inventory', 'Products', 1, 'FULL'),
('HR', 'Employees', 1, 'FULL');
GO


