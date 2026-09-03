/* ============================================================
   SQL SERVER INDEX COURSE
   DATABASE: IndexesDB
   COMPANY: RUBEL Retail & Distribution Ltd.

   PURPOSE:
   Same realistic company dataset will be used
   throughout the complete Index course.
   ============================================================ */

USE master;
GO

/* ------------------------------------------------------------
   1. Create Database
   ------------------------------------------------------------ */

IF DB_ID('IndexesDB') IS NOT NULL
BEGIN
    ALTER DATABASE IndexesDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE IndexesDB;
END;
GO

CREATE DATABASE IndexesDB;
GO

USE IndexesDB;
GO


/* ============================================================
   2. Create Schemas
   ============================================================ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Product;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Analytics;
GO


/* ============================================================
   3. Departments
   ============================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT IDENTITY(1,1) NOT NULL,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NULL,
    ManagerName VARCHAR(100) NULL,
    CreatedDate DATETIME2 NOT NULL
        CONSTRAINT DF_Departments_CreatedDate
        DEFAULT SYSDATETIME()
);
GO


/* ============================================================
   4. Employees
   ============================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT IDENTITY(1001,1) NOT NULL,
    DepartmentID INT NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    JobTitle VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    HireDate DATE NOT NULL,
    Salary DECIMAL(12,2) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1
);
GO


/* ============================================================
   5. Categories
   ============================================================ */

CREATE TABLE Product.Categories
(
    CategoryID INT IDENTITY(1,1) NOT NULL,
    CategoryName VARCHAR(100) NOT NULL,
    Description VARCHAR(500) NULL
);
GO


/* ============================================================
   6. Products
   ============================================================ */

CREATE TABLE Product.Products
(
    ProductID INT IDENTITY(10001,1) NOT NULL,
    CategoryID INT NOT NULL,
    ProductCode VARCHAR(30) NOT NULL,
    ProductName VARCHAR(150) NOT NULL,
    Brand VARCHAR(100) NOT NULL,
    UnitCost DECIMAL(12,2) NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    StockQuantity INT NOT NULL,
    ReorderLevel INT NOT NULL,
    ProductStatus VARCHAR(20) NOT NULL,
    ProductAttributes NVARCHAR(MAX) NULL,
    ProductSpecs XML NULL
);
GO


/* ============================================================
   7. Customers
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT IDENTITY(20001,1) NOT NULL,
    CustomerCode VARCHAR(30) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    Phone VARCHAR(30) NULL,
    City VARCHAR(100) NULL,
    Country VARCHAR(100) NOT NULL,
    CustomerType VARCHAR(30) NOT NULL,
    RegistrationDate DATE NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CustomerLocation GEOGRAPHY NULL
);
GO


/* ============================================================
   8. Orders
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID BIGINT IDENTITY(500001,1) NOT NULL,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATETIME2 NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL,
    ShippingCity VARCHAR(100) NULL,
    TotalAmount DECIMAL(14,2) NOT NULL,
    OrderAttributes NVARCHAR(MAX) NULL
);
GO


/* ============================================================
   9. Order Items
   ============================================================ */

CREATE TABLE Sales.OrderItems
(
    OrderItemID BIGINT IDENTITY(1,1) NOT NULL,
    OrderID BIGINT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountPercent DECIMAL(5,2) NOT NULL DEFAULT 0,
    LineTotal AS
    (
        Quantity * UnitPrice
        * (1 - DiscountPercent / 100)
    )
);
GO


/* ============================================================
   10. ANALYTICS SALES FACT
   Used mainly for Columnstore exercises
   ============================================================ */

CREATE TABLE Analytics.SalesFact
(
    SalesFactID BIGINT IDENTITY(1,1) NOT NULL,
    OrderID BIGINT NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE NOT NULL,
    Quantity INT NOT NULL,
    SalesAmount DECIMAL(14,2) NOT NULL,
    CostAmount DECIMAL(14,2) NOT NULL,
    ProfitAmount AS
    (
        SalesAmount - CostAmount
    )
);
GO





/* ============================================================
   DEPARTMENTS
   ============================================================ */

INSERT INTO HR.Departments
(
    DepartmentName,
    Location,
    ManagerName
)
VALUES
('Sales', 'Kuwait City', 'Ahmed Rahman'),
('Finance', 'Kuwait City', 'Mohammad Ali'),
('IT', 'Hawally', 'Sami Hassan'),
('Warehouse', 'Shuwaikh', 'Karim Ahmed'),
('Procurement', 'Farwaniya', 'Nabil Khan'),
('HR', 'Kuwait City', 'Rashed Islam'),
('Marketing', 'Salmiya', 'Tariq Hasan'),
('Customer Service', 'Hawally', 'Omar Faruk');
GO


/* ============================================================
   CATEGORIES
   ============================================================ */

INSERT INTO Product.Categories
(
    CategoryName,
    Description
)
VALUES
('Electronics','Electronic consumer products'),
('Mobile Accessories','Accessories for mobile devices'),
('Computer Accessories','Computer related products'),
('Office Supplies','Office and stationery products'),
('Home Appliances','Small home appliances'),
('Networking','Networking equipment'),
('Storage','Data storage products'),
('Cables','Electrical and data cables'),
('Audio','Audio products'),
('Smart Devices','Smart technology products');
GO


/* ============================================================
   PRODUCTS
   Generate 120 realistic products
   ============================================================ */

;WITH N AS
(
    SELECT TOP (120)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Product.Products
(
    CategoryID,
    ProductCode,
    ProductName,
    Brand,
    UnitCost,
    UnitPrice,
    StockQuantity,
    ReorderLevel,
    ProductStatus,
    ProductAttributes,
    ProductSpecs
)
SELECT
    ((n - 1) % 10) + 1,

    CONCAT('PRD-', RIGHT('0000' + CAST(n AS VARCHAR(4)),4)),

    CONCAT(
        CASE ((n - 1) % 10) + 1
            WHEN 1 THEN 'Smart Device'
            WHEN 2 THEN 'Mobile Accessory'
            WHEN 3 THEN 'Computer Accessory'
            WHEN 4 THEN 'Office Supply'
            WHEN 5 THEN 'Home Appliance'
            WHEN 6 THEN 'Network Device'
            WHEN 7 THEN 'Storage Device'
            WHEN 8 THEN 'Data Cable'
            WHEN 9 THEN 'Audio Device'
            WHEN 10 THEN 'Smart Home'
        END,
        ' Model ',
        n
    ),

    CASE n % 8
        WHEN 0 THEN 'Samsung'
        WHEN 1 THEN 'Dell'
        WHEN 2 THEN 'HP'
        WHEN 3 THEN 'Lenovo'
        WHEN 4 THEN 'Logitech'
        WHEN 5 THEN 'Anker'
        WHEN 6 THEN 'Sony'
        ELSE 'TP-Link'
    END,

    CAST(10 + (n * 2.75) AS DECIMAL(12,2)),

    CAST(18 + (n * 4.50) AS DECIMAL(12,2)),

    20 + ((n * 17) % 500),

    20 + ((n * 3) % 80),

    CASE
        WHEN n % 13 = 0 THEN 'Discontinued'
        WHEN n % 7 = 0 THEN 'Low Stock'
        ELSE 'Active'
    END,

    CONCAT(
        '{"color":"',
        CASE n % 5
            WHEN 0 THEN 'Black'
            WHEN 1 THEN 'White'
            WHEN 2 THEN 'Blue'
            WHEN 3 THEN 'Silver'
            ELSE 'Gray'
        END,
        '","warranty_months":',
        12 + (n % 24),
        ',"rating":',
        CAST(3.5 + ((n % 15) / 10.0) AS DECIMAL(2,1)),
        '}'
    ),

    CONCAT(
        '<Product>',
        '<Brand>',
        CASE n % 8
            WHEN 0 THEN 'Samsung'
            WHEN 1 THEN 'Dell'
            WHEN 2 THEN 'HP'
            WHEN 3 THEN 'Lenovo'
            WHEN 4 THEN 'Logitech'
            WHEN 5 THEN 'Anker'
            WHEN 6 THEN 'Sony'
            ELSE 'TP-Link'
        END,
        '</Brand>',
        '<WarrantyMonths>',
        12 + (n % 24),
        '</WarrantyMonths>',
        '</Product>'
    )
FROM N;
GO



/* ============================================================
   CUSTOMERS
   ============================================================ */

;WITH N AS
(
    SELECT TOP (500)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Sales.Customers
(
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Phone,
    City,
    Country,
    CustomerType,
    RegistrationDate,
    IsActive
)
SELECT
    CONCAT('CUS-', RIGHT('00000' + CAST(n AS VARCHAR(5)),5)),

    CASE n % 10
        WHEN 0 THEN 'Ahmed'
        WHEN 1 THEN 'Mohammad'
        WHEN 2 THEN 'Omar'
        WHEN 3 THEN 'Ali'
        WHEN 4 THEN 'Hassan'
        WHEN 5 THEN 'Rashed'
        WHEN 6 THEN 'Sami'
        WHEN 7 THEN 'Karim'
        WHEN 8 THEN 'Nabil'
        ELSE 'Tariq'
    END,

    CONCAT('Customer',n),

    CONCAT(
        'customer',
        n,
        '@rubelretail.com'
    ),

    CONCAT(
        '+965-5',
        RIGHT('0000000' + CAST(n AS VARCHAR(7)),7)
    ),

    CASE n % 8
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Hawally'
        WHEN 2 THEN 'Farwaniya'
        WHEN 3 THEN 'Salmiya'
        WHEN 4 THEN 'Jahra'
        WHEN 5 THEN 'Ahmadi'
        WHEN 6 THEN 'Mubarak Al-Kabeer'
        ELSE 'Fahaheel'
    END,

    CASE n % 4
        WHEN 0 THEN 'Kuwait'
        WHEN 1 THEN 'Saudi Arabia'
        WHEN 2 THEN 'Bahrain'
        ELSE 'UAE'
    END,

    CASE n % 5
        WHEN 0 THEN 'VIP'
        WHEN 1 THEN 'Corporate'
        WHEN 2 THEN 'Regular'
        WHEN 3 THEN 'Wholesale'
        ELSE 'Regular'
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




/* ============================================================
   EMPLOYEES
   ============================================================ */

;WITH N AS
(
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO HR.Employees
(
    DepartmentID,
    FirstName,
    LastName,
    JobTitle,
    Email,
    HireDate,
    Salary,
    IsActive
)
SELECT
    ((n - 1) % 8) + 1,

    CONCAT('Employee',n),

    CONCAT('Staff',n),

    CASE n % 5
        WHEN 0 THEN 'Sales Executive'
        WHEN 1 THEN 'Data Analyst'
        WHEN 2 THEN 'Warehouse Officer'
        WHEN 3 THEN 'Account Executive'
        ELSE 'Operations Officer'
    END,

    CONCAT(
        'employee',
        n,
        '@rubelretail.com'
    ),

    DATEADD
    (
        DAY,
        -(n * 20),
        CAST(GETDATE() AS DATE)
    ),

    CAST
    (
        500 + ((n * 137) % 4500)
        AS DECIMAL(12,2)
    ),

    CASE
        WHEN n % 17 = 0 THEN 0
        ELSE 1
    END
FROM N;
GO



/* ============================================================
   ORDERS
   ============================================================ */

;WITH N AS
(
    SELECT TOP (5000)
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
    TotalAmount,
    OrderAttributes
)
SELECT
    20001 + ((n - 1) % 500),

    1001 + ((n - 1) % 100),

    DATEADD
    (
        MINUTE,
        -(n * 37),
        SYSDATETIME()
    ),

    CASE n % 6
        WHEN 0 THEN 'Pending'
        WHEN 1 THEN 'Confirmed'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Shipped'
        WHEN 4 THEN 'Delivered'
        ELSE 'Cancelled'
    END,

    CASE n % 4
        WHEN 0 THEN 'Credit Card'
        WHEN 1 THEN 'Cash'
        WHEN 2 THEN 'KNET'
        ELSE 'Bank Transfer'
    END,

    CASE n % 8
        WHEN 0 THEN 'Kuwait City'
        WHEN 1 THEN 'Hawally'
        WHEN 2 THEN 'Farwaniya'
        WHEN 3 THEN 'Salmiya'
        WHEN 4 THEN 'Jahra'
        WHEN 5 THEN 'Ahmadi'
        WHEN 6 THEN 'Fahaheel'
        ELSE 'Sabah Al Salem'
    END,

    CAST
    (
        50 + ((n * 83) % 5000)
        AS DECIMAL(14,2)
    ),

    CONCAT(
        '{"priority":"',
        CASE n % 3
            WHEN 0 THEN 'High'
            WHEN 1 THEN 'Normal'
            ELSE 'Low'
        END,
        '","source":"Online"}'
    )
FROM N;
GO



/* ============================================================
   ORDER ITEMS
   ============================================================ */

;WITH N AS
(
    SELECT TOP (15000)
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
    500001 + ((n - 1) % 5000),

    10001 + ((n * 7) % 120),

    1 + (n % 10),

    CAST
    (
        18 + (((n * 7) % 120) * 4.50)
        AS DECIMAL(12,2)
    ),

    CAST
    (
        CASE
            WHEN n % 10 = 0 THEN 15
            WHEN n % 5 = 0 THEN 10
            WHEN n % 3 = 0 THEN 5
            ELSE 0
        END
        AS DECIMAL(5,2)
    )
FROM N;
GO





/* ============================================================
   SALES FACT
   ============================================================ */

;WITH N AS
(
    SELECT TOP (50000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS n
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO Analytics.SalesFact
(
    OrderID,
    CustomerID,
    ProductID,
    EmployeeID,
    OrderDate,
    Quantity,
    SalesAmount,
    CostAmount
)
SELECT
    500001 + ((n - 1) % 5000),

    20001 + ((n - 1) % 500),

    10001 + ((n - 1) % 120),

    1001 + ((n - 1) % 100),

    DATEADD
    (
        DAY,
        -(n % 730),
        CAST(GETDATE() AS DATE)
    ),

    1 + (n % 10),

    CAST
    (
        100 + ((n * 37) % 5000)
        AS DECIMAL(14,2)
    ),

    CAST
    (
        60 + ((n * 23) % 3000)
        AS DECIMAL(14,2)
    )
FROM N;
GO



