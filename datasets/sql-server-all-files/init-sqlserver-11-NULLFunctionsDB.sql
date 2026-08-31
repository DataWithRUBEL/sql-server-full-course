-- ============================================================
-- Create database for NULL Functions and NULL Handling practice
-- ============================================================

IF DB_ID('NullFunctionsDB') IS NULL
BEGIN
    CREATE DATABASE NullFunctionsDB;
END;
GO

USE NullFunctionsDB;
GO

-- ============================================================
-- Create schemas
-- ============================================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'sales')
    EXEC('CREATE SCHEMA sales');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'hr')
    EXEC('CREATE SCHEMA hr');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'staging')
    EXEC('CREATE SCHEMA staging');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'warehouse')
    EXEC('CREATE SCHEMA warehouse');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'dq')
    EXEC('CREATE SCHEMA dq');
GO

-- ============================================================
-- Customer master table
-- NULL values intentionally exist for data-quality practice
-- ============================================================

DROP TABLE IF EXISTS sales.Customers;
GO

CREATE TABLE sales.Customers
(
    CustomerID      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    Email           VARCHAR(150) NULL,
    Phone           VARCHAR(30) NULL,
    City            VARCHAR(50) NULL,
    Country         VARCHAR(50) NULL,
    CustomerStatus  VARCHAR(20) NULL,
    SignupDate      DATE NULL
);
GO

-- ============================================================
-- Insert realistic customer data
-- Some attributes intentionally contain NULL
-- ============================================================

INSERT INTO sales.Customers
(
    CustomerName,
    Email,
    Phone,
    City,
    Country,
    CustomerStatus,
    SignupDate
)
VALUES
('Ahmed Hassan','ahmed@gmail.com','50123456','Kuwait City','Kuwait','Active','2025-01-15'),
('Sara Ali','sara@gmail.com',NULL,'Hawally','Kuwait','Active','2025-02-10'),
('Mohammed Rahman',NULL,'55001122','Farwaniya','Kuwait','Active','2025-03-05'),
('Fatima Noor','fatima@gmail.com','60001122',NULL,'Kuwait','Active','2025-03-20'),
('Omar Khan',NULL,NULL,'Salmiya','Kuwait','Inactive','2025-04-01'),
('Aisha Ahmed','aisha@gmail.com','51112233','Jahra','Kuwait',NULL,'2025-04-15'),
('John Mathew','john@gmail.com','','Kuwait City','Kuwait','Active',NULL),
('Nadia Islam','nadia@gmail.com','53334455',NULL,'Kuwait','Active','2025-05-12'),
('Ali Raza',NULL,'57778899','Hawally','Kuwait','Active','2025-06-01'),
('Mariam Khan','mariam@gmail.com',NULL,'Salmiya','Kuwait','Inactive',NULL);
GO


-- ============================================================
-- Orders table
-- NULL values represent incomplete operational data
-- ============================================================

DROP TABLE IF EXISTS sales.Orders;
GO

CREATE TABLE sales.Orders
(
    OrderID          INT PRIMARY KEY,
    CustomerID       INT NULL,
    SalesRepID       INT NULL,
    OrderDate        DATE NULL,
    ShipDate         DATE NULL,
    PaymentDate      DATE NULL,
    ProductCategory  VARCHAR(50) NULL,
    Quantity         INT NULL,
    UnitPrice        DECIMAL(10,2) NULL,
    Discount         DECIMAL(10,2) NULL,
    PaymentMethod    VARCHAR(30) NULL,
    OrderStatus      VARCHAR(30) NULL
);
GO

-- ============================================================
-- Insert realistic retail order data
-- NULLs intentionally represent source-system issues
-- ============================================================

INSERT INTO sales.Orders
(
    OrderID, CustomerID, SalesRepID, OrderDate, ShipDate,
    PaymentDate, ProductCategory, Quantity, UnitPrice,
    Discount, PaymentMethod, OrderStatus
)
VALUES
(1001,1,101,'2026-01-05','2026-01-07','2026-01-05','Electronics',2,250.00,20.00,'Card','Completed'),
(1002,2,102,'2026-01-06','2026-01-09','2026-01-06','Furniture',1,500.00,NULL,'Cash','Completed'),
(1003,3,NULL,'2026-01-08',NULL,NULL,'Electronics',3,150.00,10.00,'Card','Pending'),
(1004,4,103,'2026-01-10','2026-01-12','2026-01-10',NULL,2,75.00,NULL,'Card','Completed'),
(1005,5,NULL,'2026-01-11',NULL,NULL,'Furniture',1,NULL,0,'Cash','Cancelled'),
(1006,6,101,'2026-01-15','2026-01-17','2026-01-16','Electronics',NULL,300.00,30.00,'Card','Completed'),
(1007,7,102,NULL,NULL,NULL,'Clothing',5,40.00,NULL,'Card','Pending'),
(1008,8,NULL,'2026-02-01','2026-02-03',NULL,'Clothing',2,60.00,5.00,NULL,'Completed'),
(1009,9,103,'2026-02-05','2026-02-07','2026-02-05',NULL,NULL,NULL,NULL,'Cash','Completed'),
(1010,10,101,'2026-02-08',NULL,NULL,'Electronics',1,900.00,50.00,'Card','Pending'),
(1011,1,NULL,'2026-02-10','2026-02-12','2026-02-10','Furniture',2,400.00,NULL,'Card','Completed'),
(1012,2,102,'2026-02-12','2026-02-14','2026-02-12','Clothing',3,55.00,5.00,'Cash','Completed'),
(1013,NULL,NULL,'2026-02-15',NULL,NULL,'Electronics',1,200.00,NULL,NULL,'Pending'),
(1014,4,103,'2026-02-18','2026-02-20','2026-02-18','Furniture',1,750.00,50.00,'Card','Completed'),
(1015,5,NULL,'2026-02-20',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'Pending');
GO

-- ============================================================
-- Sales representative master table
-- Used for JOIN and NULL analysis
-- ============================================================

DROP TABLE IF EXISTS hr.SalesRepresentatives;
GO

CREATE TABLE hr.SalesRepresentatives
(
    SalesRepID INT PRIMARY KEY,
    SalesRepName VARCHAR(100) NOT NULL,
    Region VARCHAR(50) NULL
);
GO

-- ============================================================
-- Insert sales representatives
-- ============================================================

INSERT INTO hr.SalesRepresentatives
VALUES
(101,'David Wilson','Kuwait City'),
(102,'James Smith','Hawally'),
(103,'Michael Brown',NULL),
(104,'Daniel Lee','Salmiya');
GO
