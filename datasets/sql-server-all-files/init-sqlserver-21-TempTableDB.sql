/* ==============================================================================
   STEP 01: CREATE PRACTICE DATABASE
   ============================================================================== */

USE master;
GO

IF DB_ID('TempTableDB') IS NOT NULL
BEGIN
    ALTER DATABASE TempTableDB
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;

    DROP DATABASE TempTableDB;
END;
GO

CREATE DATABASE TempTableDB;
GO

USE TempTableDB;
GO



/* ==============================================================================
   STEP 02: CREATE CUSTOMERS TABLE
   ============================================================================== */

CREATE TABLE Sales_Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    City VARCHAR(50)
);
GO


/* ==============================================================================
   STEP 03: CREATE PRODUCTS TABLE
   ============================================================================== */

CREATE TABLE Sales_Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(12,2)
);
GO



/* ==============================================================================
   STEP 04: CREATE ORDERS TABLE
   ============================================================================== */

CREATE TABLE Sales_Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    OrderStatus VARCHAR(30),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales_Customers(CustomerID),

    CONSTRAINT FK_Orders_Products
        FOREIGN KEY (ProductID)
        REFERENCES Sales_Products(ProductID)
);
GO


/* ==============================================================================
   INSERT CUSTOMERS
   ============================================================================== */

INSERT INTO Sales_Customers
(
    CustomerID,
    CustomerName,
    Country,
    City
)
VALUES
(1, 'John Smith', 'USA', 'New York'),
(2, 'Ahmed Ali', 'Kuwait', 'Kuwait City'),
(3, 'David Lee', 'UK', 'London'),
(4, 'Maria Garcia', 'Spain', 'Madrid'),
(5, 'Robert Brown', 'USA', 'Chicago');
GO


/* ==============================================================================
   INSERT PRODUCTS
   ============================================================================== */

INSERT INTO Sales_Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice
)
VALUES
(101, 'Laptop', 'Electronics', 1200),
(102, 'Monitor', 'Electronics', 400),
(103, 'Keyboard', 'Accessories', 80),
(104, 'Mouse', 'Accessories', 40),
(105, 'Desk', 'Furniture', 300);
GO

/* ==============================================================================
   INSERT ORDERS
   ============================================================================== */

INSERT INTO Sales_Orders
(
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice,
    OrderStatus
)
VALUES
(1001, 1, 101, '2026-01-05', 2, 1200, 'Delivered'),
(1002, 2, 102, '2026-01-08', 3, 400, 'Pending'),
(1003, 3, 103, '2026-01-12', 5, 80, 'Delivered'),
(1004, 4, 104, '2026-02-03', 10, 40, 'Cancelled'),
(1005, 5, 105, '2026-02-10', 2, 300, 'Delivered'),
(1006, 1, 102, '2026-02-15', 4, 400, 'Pending'),
(1007, 2, 101, '2026-03-01', 1, 1200, 'Delivered'),
(1008, 3, 104, '2026-03-05', 8, 40, 'Delivered'),
(1009, 4, 103, '2026-03-10', 6, 80, 'Pending'),
(1010, 5, 101, '2026-03-15', 2, 1200, 'Delivered');
GO
