-- ============================================================
-- ETL PRACTICE DATABASE
-- ============================================================

CREATE DATABASE ETLDB;
GO

USE ETLDB;
GO


-- ============================================================
-- CREATE ETL SCHEMAS
-- ============================================================

CREATE SCHEMA source_system;
GO

CREATE SCHEMA staging;
GO

CREATE SCHEMA warehouse;
GO

CREATE SCHEMA etl;
GO

CREATE SCHEMA audit;
GO

CREATE SCHEMA reject;
GO



-- ============================================================
-- SOURCE CUSTOMER TABLE
-- ============================================================

CREATE TABLE source_system.Customers
(
    CustomerID       INT PRIMARY KEY,
    CustomerCode     VARCHAR(20),
    FirstName        VARCHAR(50),
    LastName         VARCHAR(50),
    Email            VARCHAR(150),
    Phone            VARCHAR(30),
    Country          VARCHAR(50),
    City             VARCHAR(50),
    CustomerType     VARCHAR(20),
    CreatedDate      DATETIME2,
    ModifiedDate     DATETIME2
);
GO

-- ============================================================
-- SOURCE PRODUCT TABLE
-- ============================================================

CREATE TABLE source_system.Products
(
    ProductID        INT PRIMARY KEY,
    ProductCode      VARCHAR(20),
    ProductName      VARCHAR(150),
    Category         VARCHAR(100),
    Brand            VARCHAR(100),
    UnitPrice        DECIMAL(18,2),
    CostPrice        DECIMAL(18,2),
    StockQuantity    INT,
    IsActive         BIT,
    ModifiedDate     DATETIME2
);
GO


-- ============================================================
-- SOURCE EMPLOYEE TABLE
-- ============================================================

CREATE TABLE source_system.Employees
(
    EmployeeID       INT PRIMARY KEY,
    EmployeeCode     VARCHAR(20),
    EmployeeName     VARCHAR(100),
    Department       VARCHAR(100),
    JobTitle         VARCHAR(100),
    Country          VARCHAR(50),
    HireDate         DATE,
    Salary           DECIMAL(18,2),
    ModifiedDate     DATETIME2
);
GO


-- ============================================================
-- SOURCE ORDER TABLE
-- ============================================================

CREATE TABLE source_system.Orders
(
    OrderID          INT PRIMARY KEY,
    OrderNumber      VARCHAR(30),
    CustomerID       INT,
    EmployeeID       INT,
    OrderDate        DATETIME2,
    Status            VARCHAR(30),
    PaymentMethod    VARCHAR(30),
    ShippingCountry  VARCHAR(50),
    TotalAmount      DECIMAL(18,2),
    ModifiedDate     DATETIME2
);
GO


-- ============================================================
-- SOURCE ORDER ITEMS
-- ============================================================

CREATE TABLE source_system.OrderItems
(
    OrderItemID      INT PRIMARY KEY,
    OrderID          INT,
    ProductID        INT,
    Quantity         INT,
    UnitPrice        DECIMAL(18,2),
    DiscountAmount   DECIMAL(18,2)
);
GO

-- ============================================================
-- SOURCE PAYMENT TABLE
-- ============================================================

CREATE TABLE source_system.Payments
(
    PaymentID        INT PRIMARY KEY,
    OrderID          INT,
    PaymentDate      DATETIME2,
    PaymentMethod    VARCHAR(30),
    PaymentAmount    DECIMAL(18,2),
    PaymentStatus    VARCHAR(30)
);
GO

-- ============================================================
-- INSERT CUSTOMER DATA
-- ============================================================

INSERT INTO source_system.Customers
VALUES
(1,'C001','John','Smith','john.smith@gmail.com','5551001','USA','New York','Retail','2025-01-10','2026-01-10'),
(2,'C002','Sarah','Johnson','sarah.johnson@gmail.com','5551002','USA','Chicago','Retail','2025-02-15','2026-02-20'),
(3,'David','Brown','david.brown@gmail.com','5551003','UK','London','Corporate','2025-03-01','2026-03-05'),
(4,'Emily','Davis','emily.davis@gmail.com','5551004','Canada','Toronto','Retail','2025-03-20','2026-03-20'),
(5,'Michael','Wilson','michael.wilson@gmail.com','5551005','Australia','Sydney','Retail','2025-04-10','2026-04-15'),
(6,'Olivia','Taylor','olivia.taylor@gmail.com','5551006','USA','Boston','VIP','2025-05-01','2026-05-05'),
(7,'Daniel','Anderson','daniel.anderson@gmail.com','5551007','Germany','Berlin','Retail','2025-05-20','2026-05-25'),
(8,'Sophia','Thomas','sophia.thomas@gmail.com','5551008','France','Paris','VIP','2025-06-10','2026-06-12'),
(9,'James','Jackson','james.jackson@gmail.com','5551009','USA','Dallas','Retail','2025-07-01','2026-07-05'),
(10,'Emma','White','emma.white@gmail.com','5551010','UK','Manchester','Corporate','2025-07-15','2026-07-20');
GO


-- ============================================================
-- INSERT PRODUCT DATA
-- ============================================================

INSERT INTO source_system.Products
VALUES
(101,'P101','Laptop Pro 15','Electronics','TechBrand',1500,1100,100,1,'2026-01-10'),
(102,'P102','Wireless Mouse','Electronics','TechBrand',35,20,500,1,'2026-01-15'),
(103,'P103','Mechanical Keyboard','Electronics','KeyBrand',90,55,300,1,'2026-01-20'),
(104,'P104','Office Chair','Furniture','ComfortBrand',250,150,100,1,'2026-02-01'),
(105,'P105','Standing Desk','Furniture','OfficeBrand',450,280,80,1,'2026-02-05'),
(106,'P106','USB-C Hub','Accessories','TechBrand',60,35,250,1,'2026-02-10'),
(107,'P107','Monitor 27 Inch','Electronics','ViewBrand',350,220,150,1,'2026-02-15'),
(108,'P108','Webcam HD','Electronics','CamBrand',120,70,200,1,'2026-02-20'),
(109,'P109','Laptop Bag','Accessories','BagBrand',75,40,350,1,'2026-03-01'),
(110,'P110','Headphones','Electronics','AudioBrand',180,100,250,1,'2026-03-05');
GO



-- ============================================================
-- INSERT EMPLOYEE DATA
-- ============================================================

INSERT INTO source_system.Employees
VALUES
(1,'E001','Robert Wilson','Sales','Sales Manager','USA','2020-01-10',75000,'2026-01-10'),
(2,'E002','Linda Smith','Sales','Sales Executive','USA','2021-03-15',55000,'2026-02-10'),
(3,'E003','James Brown','IT','Data Engineer','UK','2022-01-20',85000,'2026-02-15'),
(4,'E004','Patricia Davis','Finance','Financial Analyst','Canada','2021-06-10',70000,'2026-03-01'),
(5,'E005','William Miller','Sales','Sales Executive','USA','2022-07-10',52000,'2026-03-05');
GO


-- ============================================================
-- INSERT ORDER DATA
-- ============================================================

INSERT INTO source_system.Orders
VALUES
(1001,'ORD1001',1,1,'2026-01-05','Completed','Credit Card','USA',1570,'2026-01-05'),
(1002,'ORD1002',2,2,'2026-01-10','Completed','PayPal','USA',125,'2026-01-10'),
(1003,'ORD1003',3,1,'2026-01-15','Completed','Credit Card','UK',450,'2026-01-15'),
(1004,'ORD1004',4,2,'2026-02-05','Completed','Credit Card','Canada',700,'2026-02-05'),
(1005,'ORD1005',5,5,'2026-02-15','Pending','PayPal','Australia',350,'2026-02-15'),
(1006,'ORD1006',6,1,'2026-03-01','Completed','Credit Card','USA',1800,'2026-03-01'),
(1007,'ORD1007',7,2,'2026-03-10','Completed','Bank Transfer','Germany',530,'2026-03-10'),
(1008,'ORD1008',8,5,'2026-04-01','Cancelled','Credit Card','France',180,'2026-04-01'),
(1009,'ORD1009',9,1,'2026-04-15','Completed','Credit Card','USA',350,'2026-04-15'),
(1010,'ORD1010',10,2,'2026-05-01','Completed','PayPal','UK',510,'2026-05-01');
GO


-- ============================================================
-- INSERT ORDER ITEM DATA
-- ============================================================

INSERT INTO source_system.OrderItems
VALUES
(1,1001,101,1,1500,0),
(2,1001,102,2,35,0),
(3,1002,102,1,35,0),
(4,1002,103,1,90,0),
(5,1003,105,1,450,0),
(6,1004,107,2,350,0),
(7,1005,107,1,350,0),
(8,1006,101,1,1500,0),
(9,1006,108,1,120,0),
(10,1007,104,2,250,0),
(11,1007,106,1,60,30),
(12,1008,110,1,180,0),
(13,1009,107,1,350,0),
(14,1010,105,1,450,0),
(15,1010,109,1,75,15);
GO

-- ============================================================
-- INSERT PAYMENT DATA
-- ============================================================

INSERT INTO source_system.Payments
VALUES
(1,1001,'2026-01-05','Credit Card',1570,'Paid'),
(2,1002,'2026-01-10','PayPal',125,'Paid'),
(3,1003,'2026-01-15','Credit Card',450,'Paid'),
(4,1004,'2026-02-05','Credit Card',700,'Paid'),
(5,1005,'2026-02-15','PayPal',350,'Pending'),
(6,1006,'2026-03-01','Credit Card',1800,'Paid'),
(7,1007,'2026-03-10','Bank Transfer',530,'Paid'),
(8,1008,'2026-04-01','Credit Card',180,'Refunded'),
(9,1009,'2026-04-15','Credit Card',350,'Paid'),
(10,1010,'2026-05-01','PayPal',510,'Paid');
GO

