-- =========================================================
-- Create Window Aggregate Functions Practice Database
-- Purpose:
-- একটি আলাদা database-এ Window Aggregate Functions practice করা
-- =========================================================
USE master;
GO

IF DB_ID('WindowAggregateFunctionsDB') IS NOT NULL
BEGIN
    ALTER DATABASE WindowAggregateFunctionsDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE WindowAggregateFunctionsDB;
END;
GO

CREATE DATABASE WindowAggregateFunctionsDB;
GO

USE WindowAggregateFunctionsDB;
GO


-- =========================================================
-- Create schemas
-- Purpose:
-- Business এবং Data Engineering objects আলাদা রাখা
-- =========================================================
CREATE SCHEMA Sales;
GO

CREATE SCHEMA MasterData;
GO

CREATE SCHEMA Inventory;
GO

CREATE SCHEMA ETL;
GO


-- =========================================================
-- Customers table
-- Purpose:
-- Customer-level sales এবং lifetime analytics করা
-- =========================================================
CREATE TABLE MasterData.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    Gender          VARCHAR(10),
    City            VARCHAR(50),
    CustomerSegment VARCHAR(30),
    SignupDate      DATE
);
GO


-- =========================================================
-- Insert realistic customer data
-- =========================================================
INSERT INTO MasterData.Customers
(
    CustomerID,
    CustomerName,
    Gender,
    City,
    CustomerSegment,
    SignupDate
)
VALUES
(1, 'Ahmed Hassan', 'Male', 'Kuwait City', 'Premium', '2023-01-10'),
(2, 'Mohammad Ali', 'Male', 'Farwaniyah', 'Standard', '2023-02-15'),
(3, 'Fatima Noor', 'Female', 'Hawally', 'Premium', '2023-03-20'),
(4, 'Sara Khan', 'Female', 'Salmiya', 'Standard', '2023-04-05'),
(5, 'Omar Rahman', 'Male', 'Jleeb', 'Premium', '2023-05-18'),
(6, 'Aisha Ahmed', 'Female', 'Kuwait City', 'Standard', '2023-06-11'),
(7, 'Yusuf Karim', 'Male', 'Hawally', 'Premium', '2023-07-22'),
(8, 'Nadia Islam', 'Female', 'Farwaniyah', 'Standard', '2023-08-30'),
(9, 'Khalid Hasan', 'Male', 'Salmiya', 'Premium', '2023-09-12'),
(10, 'Mariam Akter', 'Female', 'Kuwait City', 'Standard', '2023-10-25');
GO


-- =========================================================
-- Product Categories
-- =========================================================
CREATE TABLE MasterData.Categories
(
    CategoryID   INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

INSERT INTO MasterData.Categories
VALUES
(1, 'Electronics'),
(2, 'Mobile'),
(3, 'Laptop'),
(4, 'Accessories'),
(5, 'Home Appliances');
GO


-- =========================================================
-- Products table
-- Purpose:
-- Product/category-level Window Analytics
-- =========================================================
CREATE TABLE MasterData.Products
(
    ProductID    INT PRIMARY KEY,
    ProductName  VARCHAR(100) NOT NULL,
    CategoryID   INT NOT NULL,
    UnitPrice    DECIMAL(12,2) NOT NULL,
    UnitCost     DECIMAL(12,2) NOT NULL,

    CONSTRAINT FK_Products_Category
        FOREIGN KEY (CategoryID)
        REFERENCES MasterData.Categories(CategoryID)
);
GO

-- =========================================================
-- Insert realistic product data
-- =========================================================

INSERT INTO MasterData.Products
VALUES
(101, 'iPhone 15',          2, 320.00, 250.00),
(102, 'Samsung Galaxy S24', 2, 280.00, 215.00),
(103, 'Dell Laptop',        3, 650.00, 520.00),
(104, 'HP Laptop',          3, 580.00, 450.00),
(105, 'AirPods',             4, 120.00, 75.00),
(106, 'Samsung Earbuds',     4, 90.00, 55.00),
(107, 'Microwave Oven',      5, 150.00, 105.00),
(108, 'Smart TV',            1, 450.00, 350.00);
GO

-- =========================================================
-- Branches table
-- Purpose:
-- Branch-level running and contribution analysis
-- =========================================================
CREATE TABLE MasterData.Branches
(
    BranchID   INT PRIMARY KEY,
    BranchName VARCHAR(100),
    City       VARCHAR(50)
);
GO

INSERT INTO MasterData.Branches
VALUES
(1, 'Kuwait City Branch', 'Kuwait City'),
(2, 'Farwaniyah Branch', 'Farwaniyah'),
(3, 'Hawally Branch', 'Hawally'),
(4, 'Salmiya Branch', 'Salmiya');
GO

-- =========================================================
-- Orders table
-- Purpose:
-- Transaction-level analytics
-- =========================================================

CREATE TABLE Sales.Orders
(
    OrderID     INT PRIMARY KEY,
    OrderDate   DATE NOT NULL,
    CustomerID  INT NOT NULL,
    BranchID    INT NOT NULL,
    OrderStatus VARCHAR(20),

    CONSTRAINT FK_Orders_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES MasterData.Customers(CustomerID),

    CONSTRAINT FK_Orders_Branch
        FOREIGN KEY (BranchID)
        REFERENCES MasterData.Branches(BranchID)
);
GO

-- =========================================================
-- Insert realistic order data
-- =========================================================

INSERT INTO Sales.Orders
VALUES
(1001,'2026-01-02',1,1,'Completed'),
(1002,'2026-01-03',2,2,'Completed'),
(1003,'2026-01-04',3,3,'Completed'),
(1004,'2026-01-05',4,4,'Completed'),
(1005,'2026-01-07',1,1,'Completed'),
(1006,'2026-01-08',5,2,'Completed'),
(1007,'2026-01-10',6,3,'Completed'),
(1008,'2026-01-12',7,4,'Completed'),
(1009,'2026-01-15',2,2,'Completed'),
(1010,'2026-01-18',8,1,'Completed'),
(1011,'2026-01-20',9,3,'Completed'),
(1012,'2026-01-22',10,4,'Completed'),
(1013,'2026-02-02',1,1,'Completed'),
(1014,'2026-02-04',3,3,'Completed'),
(1015,'2026-02-06',5,2,'Completed'),
(1016,'2026-02-08',7,4,'Completed'),
(1017,'2026-02-10',2,2,'Completed'),
(1018,'2026-02-13',4,1,'Completed'),
(1019,'2026-02-15',6,3,'Completed'),
(1020,'2026-02-18',9,4,'Completed'),
(1021,'2026-03-01',1,1,'Completed'),
(1022,'2026-03-03',2,2,'Completed'),
(1023,'2026-03-05',3,3,'Completed'),
(1024,'2026-03-07',5,2,'Completed');
GO


-- =========================================================
-- Order Details
-- Purpose:
-- Sales, quantity and profit calculation
-- =========================================================
CREATE TABLE Sales.OrderDetails
(
    OrderDetailID INT PRIMARY KEY,
    OrderID       INT NOT NULL,
    ProductID     INT NOT NULL,
    Quantity      INT NOT NULL,
    UnitPrice     DECIMAL(12,2) NOT NULL,
    Discount      DECIMAL(5,2) NOT NULL,

    CONSTRAINT FK_OrderDetails_Order
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Product
        FOREIGN KEY (ProductID)
        REFERENCES MasterData.Products(ProductID)
);
GO


-- =========================================================
-- Insert realistic sales transaction data
-- =========================================================

INSERT INTO Sales.OrderDetails
VALUES
(1,1001,101,1,320,0.05),
(2,1001,105,2,120,0.00),
(3,1002,102,1,280,0.10),
(4,1002,106,2,90,0.05),
(5,1003,103,1,650,0.00),
(6,1004,104,1,580,0.05),
(7,1005,101,2,320,0.05),
(8,1006,107,2,150,0.00),
(9,1007,105,1,120,0.00),
(10,1008,108,1,450,0.10),
(11,1009,102,2,280,0.00),
(12,1010,106,3,90,0.05),
(13,1011,103,1,650,0.10),
(14,1012,107,1,150,0.00),
(15,1013,101,1,320,0.00),
(16,1014,104,2,580,0.05),
(17,1015,108,1,450,0.00),
(18,1016,105,4,120,0.05),
(19,1017,102,1,280,0.00),
(20,1018,106,2,90,0.00),
(21,1019,103,1,650,0.05),
(22,1020,107,2,150,0.00),
(23,1021,101,1,320,0.05),
(24,1022,108,1,450,0.00),
(25,1023,104,1,580,0.10),
(26,1024,105,2,120,0.00);
GO


-- =========================================================
-- Payments
-- Purpose:
-- Account/payment running balance practice
-- =========================================================

CREATE TABLE Sales.Payments
(
    PaymentID     INT PRIMARY KEY,
    OrderID       INT,
    PaymentDate   DATE,
    PaymentAmount DECIMAL(12,2),
    PaymentStatus VARCHAR(20)
);
GO

INSERT INTO Sales.Payments
VALUES
(1,1001,'2026-01-02',548,'Paid'),
(2,1002,'2026-01-03',414,'Paid'),
(3,1003,'2026-01-04',650,'Paid'),
(4,1004,'2026-01-05',551,'Paid'),
(5,1005,'2026-01-07',608,'Paid'),
(6,1006,'2026-01-08',300,'Paid'),
(7,1007,'2026-01-10',120,'Paid'),
(8,1008,'2026-01-12',405,'Paid'),
(9,1009,'2026-01-15',560,'Paid'),
(10,1010,'2026-01-18',256.5,'Paid');
GO

-- =========================================================
-- Inventory transactions
-- Purpose:
-- Running inventory balance practice
-- =========================================================

CREATE TABLE Inventory.StockTransactions
(
    TransactionID INT PRIMARY KEY,
    TransactionDate DATE,
    ProductID INT,
    TransactionType VARCHAR(20),
    Quantity INT
);
GO

INSERT INTO Inventory.StockTransactions
VALUES
(1,'2026-01-01',101,'Purchase',100),
(2,'2026-01-02',101,'Sale',-1),
(3,'2026-01-05',101,'Sale',-2),
(4,'2026-01-10',101,'Purchase',50),
(5,'2026-01-15',101,'Sale',-1),
(6,'2026-02-01',101,'Sale',-1),
(7,'2026-02-05',101,'Sale',-2),
(8,'2026-02-10',101,'Purchase',50);
GO


-- =========================================================
-- ETL batch monitoring table
-- Purpose:
-- Data Engineering Window Aggregate practice
-- =========================================================

CREATE TABLE ETL.BatchLog
(
    BatchID          INT,
    SourceSystem     VARCHAR(50),
    LoadDate         DATE,
    TotalRecords     INT,
    SuccessfulRecords INT,
    FailedRecords    INT,
    ProcessingSeconds INT
);
GO

INSERT INTO ETL.BatchLog
VALUES
(1,'ERP','2026-09-01',1000,980,20,120),
(2,'ERP','2026-09-02',1200,1175,25,135),
(3,'CRM','2026-09-01',500,495,5,60),
(4,'CRM','2026-09-02',650,640,10,72),
(5,'POS','2026-09-01',2000,1980,20,210),
(6,'POS','2026-09-02',2200,2180,20,225);
GO


