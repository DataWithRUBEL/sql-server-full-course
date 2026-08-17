/* ============================================================
   STEP 1: Create Database
   ============================================================ */

CREATE DATABASE WindowFunctionsDB;
GO

USE WindowFunctionsDB;
GO


/* ============================================================
   STEP 2: Create Sales Schema
   ============================================================ */

CREATE SCHEMA Sales;
GO


/* ============================================================
   STEP 3: Customers Table
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID   INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Country      VARCHAR(50)
);
GO


/* ============================================================
   STEP 4: Products Table
   ============================================================ */

CREATE TABLE Sales.Products
(
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category    VARCHAR(50),
    Price       DECIMAL(10,2)
);
GO


/* ============================================================
   STEP 5: Orders Table

   Sales = Quantity × Unit Price
   বাস্তব Business-এ Order table সাধারণত Fact Table-এর
   মতো analytical data ধারণ করতে পারে।
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID     INT PRIMARY KEY,
    OrderDate   DATE,
    CustomerID  INT,
    ProductID   INT,
    OrderStatus VARCHAR(20),
    Sales       DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Products
        FOREIGN KEY (ProductID)
        REFERENCES Sales.Products(ProductID)
);
GO


/* ============================================================
   STEP 6: Insert Customers
   ============================================================ */

INSERT INTO Sales.Customers
(
    CustomerID,
    CustomerName,
    Country
)
VALUES
(1, 'John Smith',   'USA'),
(2, 'David Miller', 'USA'),
(3, 'Emma Wilson',  'UK'),
(4, 'Oliver Brown', 'UK'),
(5, 'Sophia Khan',  'Canada'),
(6, 'James Taylor', 'USA'),
(7, 'Daniel Lee',   'Australia'),
(8, 'Maria Garcia', 'Spain');
GO


/* ============================================================
   STEP 7: Insert Products
   ============================================================ */

INSERT INTO Sales.Products
(
    ProductID,
    ProductName,
    Category,
    Price
)
VALUES
(101, 'Laptop',       'Electronics', 1200.00),
(102, 'Monitor',      'Electronics',  400.00),
(103, 'Keyboard',     'Accessories',   80.00),
(104, 'Mouse',        'Accessories',   50.00),
(105, 'Headphones',   'Accessories',  150.00),
(106, 'Office Chair', 'Furniture',    300.00);
GO


/* ============================================================
   STEP 8: Insert Orders
   ============================================================ */

INSERT INTO Sales.Orders
(
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    OrderStatus,
    Sales
)
VALUES
(1001, '2026-01-01', 1, 101, 'Completed', 1200.00),
(1002, '2026-01-02', 2, 102, 'Completed',  400.00),
(1003, '2026-01-03', 3, 103, 'Completed',   80.00),
(1004, '2026-01-04', 1, 104, 'Cancelled',   50.00),
(1005, '2026-01-05', 4, 101, 'Completed', 1200.00),
(1006, '2026-01-06', 5, 105, 'Completed',  150.00),
(1007, '2026-01-07', 6, 102, 'Pending',    400.00),
(1008, '2026-01-08', 7, 106, 'Completed',  300.00),
(1009, '2026-01-09', 8, 103, 'Completed',   80.00),
(1010, '2026-01-10', 2, 101, 'Completed', 1200.00),

(1011, '2026-01-11', 3, 104, 'Completed',   50.00),
(1012, '2026-01-12', 4, 105, 'Pending',    150.00),
(1013, '2026-01-13', 5, 106, 'Completed',  300.00),
(1014, '2026-01-14', 6, 101, 'Completed', 1200.00),
(1015, '2026-01-15', 7, 102, 'Completed',  400.00),
(1016, '2026-01-16', 8, 103, 'Cancelled',   80.00),
(1017, '2026-01-17', 1, 105, 'Completed',  150.00),
(1018, '2026-01-18', 2, 106, 'Completed',  300.00),
(1019, '2026-01-19', 3, 101, 'Completed', 1200.00),
(1020, '2026-01-20', 4, 102, 'Pending',    400.00),

(1021, '2026-01-21', 5, 104, 'Completed',   50.00),
(1022, '2026-01-22', 6, 105, 'Completed',  150.00),
(1023, '2026-01-23', 7, 106, 'Completed',  300.00),
(1024, '2026-01-24', 8, 101, 'Completed', 1200.00),

(1025, '2026-01-25', 1, 102, 'Completed',  400.00),
(1026, '2026-01-26', 2, 103, 'Completed',   80.00),
(1027, '2026-01-27', 3, 104, 'Completed',   50.00),
(1028, '2026-01-28', 4, 105, 'Completed',  150.00),
(1029, '2026-01-29', 5, 106, 'Completed',  300.00),
(1030, '2026-01-30', 6, 101, 'Completed', 1200.00);
GO
