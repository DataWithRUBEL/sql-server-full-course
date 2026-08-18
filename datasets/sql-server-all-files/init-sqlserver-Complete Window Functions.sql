প্রথমে Database + Schema + Tables তৈরি করি
আমরা একটি ছোট কিন্তু realistic Sales Analytics database তৈরি করব।
Data Model
Customers
   │
   └────< Orders >──── Products
                    │
                    └──── Product Category

OrdersArchive
CustomerHistory



/* ============================================================
   DATABASE CREATION
   ============================================================ */

CREATE DATABASE CompleteWindowFunctionsDB;
GO

USE CompleteWindowFunctionsDB;
GO


/* ============================================================
   SCHEMA CREATION
   ============================================================ */

CREATE SCHEMA Sales;
GO




/* ============================================================
   CUSTOMERS TABLE
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    SignupDate DATE
);


INSERT INTO Sales.Customers
(
    CustomerID,
    CustomerName,
    Country,
    SignupDate
)
VALUES
(1, 'John',    'USA',     '2024-01-10'),
(2, 'Alice',   'USA',     '2024-02-15'),
(3, 'Robert',  'UK',      '2024-03-20'),
(4, 'Emma',    'UK',      '2024-04-12'),
(5, 'Daniel',  'Canada',  '2024-05-05'),
(6, 'Sophia',  'USA',     '2024-06-10'),
(7, 'Michael', 'Canada',  '2024-07-15'),
(8, 'Olivia',  'USA',     '2024-08-20');



/* ============================================================
   PRODUCTS TABLE
   ============================================================ */

CREATE TABLE Sales.Products
(
    ProductID INT PRIMARY KEY,
    Product VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);


INSERT INTO Sales.Products
(
    ProductID,
    Product,
    Category,
    Price
)
VALUES
(101, 'Laptop',       'Electronics', 1200),
(102, 'Monitor',      'Electronics', 500),
(103, 'Keyboard',     'Accessories', 100),
(104, 'Mouse',        'Accessories', 50),
(105, 'Headphone',    'Accessories', 150),
(106, 'Phone',        'Electronics', 900),
(107, 'Tablet',       'Electronics', 700),
(108, 'Chair',        'Furniture',   300),
(109, 'Desk',         'Furniture',   600),
(110, 'Webcam',       'Accessories', 200);



/* ============================================================
   ORDERS TABLE
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    Sales DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Products
        FOREIGN KEY (ProductID)
        REFERENCES Sales.Products(ProductID)
);


INSERT INTO Sales.Orders
(
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    Sales
)
VALUES
(1001,1,101,'2025-01-05',1,1200),
(1002,2,103,'2025-01-07',2,200),
(1003,3,102,'2025-01-10',1,500),
(1004,1,104,'2025-01-15',3,150),
(1005,4,106,'2025-01-20',1,900),

(1006,5,107,'2025-02-03',1,700),
(1007,6,101,'2025-02-08',1,1200),
(1008,2,105,'2025-02-12',2,300),
(1009,7,109,'2025-02-18',1,600),
(1010,8,108,'2025-02-25',2,600),

(1011,1,106,'2025-03-02',1,900),
(1012,3,103,'2025-03-05',3,300),
(1013,4,101,'2025-03-11',1,1200),
(1014,6,104,'2025-03-18',4,200),
(1015,5,102,'2025-03-25',2,1000),

(1016,7,107,'2025-04-02',1,700),
(1017,8,110,'2025-04-06',2,400),
(1018,2,106,'2025-04-10',1,900),
(1019,1,101,'2025-04-15',1,1200),
(1020,4,109,'2025-04-20',1,600),

(1021,3,108,'2025-05-01',1,300),
(1022,5,106,'2025-05-05',1,900),
(1023,6,103,'2025-05-10',5,500),
(1024,7,101,'2025-05-15',1,1200),
(1025,8,102,'2025-05-20',2,1000),

(1026,1,107,'2025-06-01',1,700),
(1027,2,101,'2025-06-05',1,1200),
(1028,3,105,'2025-06-10',2,300),
(1029,4,106,'2025-06-15',1,900),
(1030,5,109,'2025-06-20',2,1200);


/* ============================================================
   ORDER ARCHIVE
   Duplicate OrderID intentionally রাখা হয়েছে
   ============================================================ */

CREATE TABLE Sales.OrdersArchive
(
    OrderID INT,
    CustomerID INT,
    Sales DECIMAL(12,2),
    CreationTime DATETIME2
);


INSERT INTO Sales.OrdersArchive
VALUES
(1001,1,1200,'2025-01-05 10:00'),
(1001,1,1200,'2025-01-05 11:00'),

(1002,2,200,'2025-01-07 10:00'),

(1003,3,500,'2025-01-10 09:00'),
(1003,3,500,'2025-01-10 12:00');




/* ============================================================
   CUSTOMER HISTORY
   ============================================================ */

CREATE TABLE Sales.CustomerHistory
(
    CustomerID INT,
    CustomerName VARCHAR(100),
    Country VARCHAR(50),
    EffectiveFrom DATE,
    EffectiveTo DATE,
    IsCurrent BIT
);


