/* =========================================================
   PROJECT: SQL Server Trigger Complete Practice
   DATABASE: TriggerDB
   BUSINESS: Retail / E-Commerce Company
   ========================================================= */

USE master;
GO

/* ---------------------------------------------------------
   Create Database
   --------------------------------------------------------- */

IF DB_ID('TriggerDB') IS NULL
BEGIN
    CREATE DATABASE TriggerDB;
END;
GO

USE TriggerDB;
GO

/* ---------------------------------------------------------
   Create Schemas
   --------------------------------------------------------- */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'audit')
    EXEC('CREATE SCHEMA audit');
GO




/* ---------------------------------------------------------
   Department Master Table
   --------------------------------------------------------- */

CREATE TABLE dbo.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100),
    CreatedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO


/* ---------------------------------------------------------
   Product Category Master
   --------------------------------------------------------- */

CREATE TABLE dbo.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO




/* ---------------------------------------------------------
   Customer Master
   --------------------------------------------------------- */

CREATE TABLE dbo.Customers
(
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(150) NOT NULL,
    Email VARCHAR(200) NOT NULL UNIQUE,
    Phone VARCHAR(30),
    Country VARCHAR(100),
    CustomerStatus VARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL
);
GO




/* ---------------------------------------------------------
   Product Master
   --------------------------------------------------------- */

CREATE TABLE dbo.Products
(
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    ProductStatus VARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY(CategoryID)
        REFERENCES dbo.Categories(CategoryID)
);
GO




/* ---------------------------------------------------------
   Employee Master
   --------------------------------------------------------- */

CREATE TABLE dbo.Employees
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName VARCHAR(150) NOT NULL,
    DepartmentID INT NOT NULL,
    JobTitle VARCHAR(100),
    Salary DECIMAL(12,2),
    HireDate DATE,
    EmployeeStatus VARCHAR(20) DEFAULT 'Active',
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY(DepartmentID)
        REFERENCES dbo.Departments(DepartmentID)
);
GO


/* ---------------------------------------------------------
   Sales Order Header
   --------------------------------------------------------- */

CREATE TABLE dbo.Orders
(
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) DEFAULT 'Pending',
    TotalAmount DECIMAL(14,2) DEFAULT 0,
    CreatedAt DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY(CustomerID)
        REFERENCES dbo.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY(EmployeeID)
        REFERENCES dbo.Employees(EmployeeID)
);
GO


/* ---------------------------------------------------------
   Sales Order Line Items
   --------------------------------------------------------- */

CREATE TABLE dbo.OrderItems
(
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    LineTotal AS (Quantity * UnitPrice) PERSISTED,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY(OrderID)
        REFERENCES dbo.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY(ProductID)
        REFERENCES dbo.Products(ProductID)
);
GO



/* ---------------------------------------------------------
   Inventory Table
   --------------------------------------------------------- */

CREATE TABLE dbo.Inventory
(
    InventoryID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT NOT NULL UNIQUE,
    Warehouse VARCHAR(100),
    StockQuantity INT NOT NULL,
    ReorderLevel INT NOT NULL,
    LastUpdated DATETIME2 DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Inventory_Products
        FOREIGN KEY(ProductID)
        REFERENCES dbo.Products(ProductID)
);
GO



/* ---------------------------------------------------------
   Generate 50 Departments
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (50)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Departments
(
    DepartmentID,
    DepartmentName,
    Location
)
SELECT
    n,
    CONCAT('Department ', n),
    CASE
        WHEN n % 5 = 0 THEN 'Kuwait'
        WHEN n % 5 = 1 THEN 'Dubai'
        WHEN n % 5 = 2 THEN 'Riyadh'
        WHEN n % 5 = 3 THEN 'Doha'
        ELSE 'Manama'
    END
FROM N;
GO



/* ---------------------------------------------------------
   Generate 50 Product Categories
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (50)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Categories
(
    CategoryID,
    CategoryName
)
SELECT
    n,
    CONCAT('Category ', n)
FROM N;
GO



/* ---------------------------------------------------------
   Generate 100 Customers
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Customers
(
    CustomerName,
    Email,
    Phone,
    Country,
    CustomerStatus
)
SELECT
    CONCAT('Customer ', n),
    CONCAT('customer', n, '@company.com'),
    CONCAT('+9655000', RIGHT('000' + CAST(n AS VARCHAR(3)), 3)),
    CASE
        WHEN n % 5 = 0 THEN 'Kuwait'
        WHEN n % 5 = 1 THEN 'UAE'
        WHEN n % 5 = 2 THEN 'Saudi Arabia'
        WHEN n % 5 = 3 THEN 'Qatar'
        ELSE 'Bahrain'
    END,
    'Active'
FROM N;
GO



/* ---------------------------------------------------------
   Generate 100 Products
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Products
(
    ProductName,
    CategoryID,
    UnitPrice,
    ProductStatus
)
SELECT
    CONCAT('Product ', n),
    ((n - 1) % 50) + 1,
    CAST(10 + (n * 2.75) AS DECIMAL(12,2)),
    'Active'
FROM N;
GO




/* ---------------------------------------------------------
   Generate 100 Employees
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Employees
(
    EmployeeName,
    DepartmentID,
    JobTitle,
    Salary,
    HireDate,
    EmployeeStatus
)
SELECT
    CONCAT('Employee ', n),
    ((n - 1) % 50) + 1,
    CASE
        WHEN n % 4 = 0 THEN 'Sales Executive'
        WHEN n % 4 = 1 THEN 'Data Analyst'
        WHEN n % 4 = 2 THEN 'Operations Manager'
        ELSE 'Data Engineer'
    END,
    CAST(2500 + (n * 75) AS DECIMAL(12,2)),
    DATEADD(DAY, -(n * 15), CAST(GETDATE() AS DATE)),
    'Active'
FROM N;
GO



/* ---------------------------------------------------------
   Generate 100 Sales Orders
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (100)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.Orders
(
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus,
    TotalAmount
)
SELECT
    n,
    ((n - 1) % 100) + 1,
    DATEADD(DAY, -(n * 2), CAST(GETDATE() AS DATE)),
    CASE
        WHEN n % 10 = 0 THEN 'Cancelled'
        WHEN n % 5 = 0 THEN 'Shipped'
        ELSE 'Completed'
    END,
    0
FROM N;
GO



/* ---------------------------------------------------------
   Generate 300 Order Items
   Each order receives multiple products
   --------------------------------------------------------- */

;WITH N AS
(
    SELECT TOP (300)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO dbo.OrderItems
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
SELECT
    ((n - 1) % 100) + 1,
    ((n * 7 - 1) % 100) + 1,
    ((n - 1) % 5) + 1,
    p.UnitPrice
FROM N
JOIN dbo.Products p
    ON p.ProductID = ((n * 7 - 1) % 100) + 1;
GO

