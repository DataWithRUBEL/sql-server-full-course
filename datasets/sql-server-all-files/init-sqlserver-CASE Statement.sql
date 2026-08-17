/* ============================================================
   DATABASE: CaseStudyDB
   PURPOSE:
   SQL Server CASE statement শেখার জন্য real-business dataset
   ============================================================ */

CREATE DATABASE CaseStudyDB;
GO

USE CaseStudyDB;
GO

/* ============================================================
   SCHEMAS
   ============================================================ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA MasterData;
GO



/* ============================================================
   CUSTOMER MASTER TABLE
   ============================================================ */

CREATE TABLE MasterData.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    Score INT NULL,
    SignupDate DATE,
    CustomerStatus VARCHAR(20)
);
GO


INSERT INTO MasterData.Customers
(
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score,
    SignupDate,
    CustomerStatus
)
VALUES
(1, 'John',   'Smith',  'USA',     85, '2025-01-10', 'Active'),
(2, 'Maria',  'Miller', 'Germany', 92, '2025-02-15', 'Active'),
(3, 'David',  'Brown',  'USA',     45, '2025-03-20', 'Inactive'),
(4, 'Anna',   'Wilson', 'UK',      NULL, '2025-04-05', 'Active'),
(5, 'Robert', 'Taylor', 'Germany', 65, '2025-05-11', 'Active'),
(6, 'Sophia', 'Davis',  'France',  30, '2025-06-01', 'Inactive'),
(7, 'James',  'Moore',  'USA',     75, '2025-06-20', 'Active'),
(8, 'Emma',   'Thomas', 'UK',      NULL, '2025-07-01', 'Active'),
(9, 'Daniel', 'Martin', 'France',  55, '2025-07-15', 'Active'),
(10,'Olivia', 'White',  'USA',     95, '2025-08-01', 'Active');
GO



/* ============================================================
   PRODUCT MASTER TABLE
   ============================================================ */

CREATE TABLE MasterData.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(10,2),
    StockQuantity INT,
    ProductStatus VARCHAR(20)
);
GO

INSERT INTO MasterData.Products
VALUES
(101, 'Laptop',       'Electronics', 1200, 15, 'Active'),
(102, 'Keyboard',    'Electronics',   80, 50, 'Active'),
(103, 'Mouse',       'Electronics',   40, 100,'Active'),
(104, 'Office Chair', 'Furniture',    250, 20, 'Active'),
(105, 'Desk',         'Furniture',    450, 10, 'Active'),
(106, 'Notebook',     'Stationery',    10, 200,'Active'),
(107, 'Pen',          'Stationery',     3, 500,'Active'),
(108, 'Monitor',      'Electronics',  300, 25, 'Active');
GO


/* ============================================================
   SALES ORDERS
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATE,
    DeliveryDate DATE NULL,
    Sales DECIMAL(12,2),
    OrderStatus VARCHAR(20),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES MasterData.Customers(CustomerID)
);
GO

INSERT INTO Sales.Orders
VALUES
(1001, 1, '2025-01-15', '2025-01-18', 1200, 'Delivered'),
(1002, 2, '2025-02-20', '2025-02-25',   80, 'Delivered'),
(1003, 3, '2025-03-25', NULL,            40, 'Pending'),
(1004, 1, '2025-04-10', '2025-04-15',  450, 'Delivered'),
(1005, 4, '2025-04-15', NULL,           250, 'Pending'),
(1006, 5, '2025-05-20', '2025-05-24',  300, 'Delivered'),
(1007, 6, '2025-06-05', NULL,             20, 'Cancelled'),
(1008, 7, '2025-06-25', '2025-06-29',   900, 'Delivered'),
(1009, 8, '2025-07-05', NULL,            100, 'Pending'),
(1010, 9, '2025-07-20', '2025-07-25',   450, 'Delivered'),
(1011,10, '2025-08-05', '2025-08-10',  1200, 'Delivered'),
(1012, 2, '2025-08-10', NULL,            450, 'Pending'),
(1013, 3, '2025-08-12', '2025-08-15',   300, 'Delivered'),
(1014, 5, '2025-08-13', NULL,             80, 'Pending'),
(1015, 7, '2025-08-15', '2025-08-16',    40, 'Delivered');
GO



/* ============================================================
   ORDER DETAILS
   ============================================================ */

CREATE TABLE Sales.OrderDetails
(
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES MasterData.Products(ProductID)
);
GO

INSERT INTO Sales.OrderDetails
VALUES
(1,1001,101,1,1200),
(2,1002,102,1,80),
(3,1003,103,1,40),
(4,1004,105,1,450),
(5,1005,104,1,250),
(6,1006,108,1,300),
(7,1007,107,5,3),
(8,1008,101,1,900),
(9,1009,102,1,80),
(10,1010,105,1,450),
(11,1011,101,1,1200),
(12,1012,105,1,450),
(13,1013,108,1,300),
(14,1014,102,1,80),
(15,1015,103,1,40);
GO



