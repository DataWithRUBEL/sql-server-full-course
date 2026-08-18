👤 Customers
📦 Products
🛒 Orders
👨‍💼 Employees
🗄️ OrdersArchive



/* ============================================================
   STEP 1: CREATE DATABASE
   ============================================================ */

CREATE DATABASE Window_Aggregate_FunctionsDB;
GO

USE Window_Aggregate_FunctionsDB;
GO


/* ============================================================
   STEP 2: CREATE SCHEMA
   ============================================================ */

CREATE SCHEMA Sales;
GO


/* ============================================================
   STEP 3: CUSTOMERS TABLE
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    Score INT NULL
);
GO


/* ============================================================
   STEP 4: PRODUCTS TABLE
   ============================================================ */

CREATE TABLE Sales.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);
GO


/* ============================================================
   STEP 5: ORDERS TABLE
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    Sales DECIMAL(10,2),
    Quantity INT
);
GO


/* ============================================================
   STEP 6: EMPLOYEES TABLE
   ============================================================ */

CREATE TABLE Sales.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Department VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO


/* ============================================================
   STEP 7: ORDERS ARCHIVE
   Duplicate detection practice-এর জন্য
   ============================================================ */

CREATE TABLE Sales.OrdersArchive
(
    OrderID INT,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    Sales DECIMAL(10,2)
);
GO


/* ============================================================
   CUSTOMERS DATA
   ============================================================ */

INSERT INTO Sales.Customers
(CustomerID, FirstName, LastName, Country, Score)
VALUES
(1, 'John', 'Smith', 'USA', 850),
(2, 'Emma', 'Brown', 'UK', 720),
(3, 'Michael', 'Johnson', 'USA', 650),
(4, 'Sophia', 'Wilson', 'Canada', NULL),
(5, 'Daniel', 'Taylor', 'UK', 900),
(6, 'Olivia', 'Anderson', 'USA', 780),
(7, 'James', 'Thomas', 'Canada', 600),
(8, 'Ava', 'Martin', 'USA', NULL),
(9, 'William', 'Jackson', 'Australia', 750),
(10, 'Isabella', 'White', 'UK', 880);
GO


/* ============================================================
   PRODUCTS DATA
   ============================================================ */

INSERT INTO Sales.Products
(ProductID, ProductName, Category, Price)
VALUES
(101, 'Laptop', 'Electronics', 1200),
(102, 'Monitor', 'Electronics', 500),
(103, 'Keyboard', 'Accessories', 100),
(104, 'Mouse', 'Accessories', 50),
(105, 'Headphone', 'Accessories', 150);
GO


/* ============================================================
   ORDERS DATA
   ============================================================ */

INSERT INTO Sales.Orders
(OrderID, OrderDate, CustomerID, ProductID, Sales, Quantity)
VALUES
(1001, '2026-01-05', 1, 101, 1200, 1),
(1002, '2026-01-08', 2, 103, 200, 2),
(1003, '2026-01-15', 1, 104, 100, 2),
(1004, '2026-01-20', 3, 102, 500, 1),
(1005, '2026-02-03', 4, 101, 2400, 2),
(1006, '2026-02-10', 5, 103, 300, 3),
(1007, '2026-02-15', 2, 104, 150, 3),
(1008, '2026-02-20', 6, 105, 450, 3),
(1009, '2026-03-02', 1, 101, 1200, 1),
(1010, '2026-03-05', 7, 102, 1000, 2),
(1011, '2026-03-12', 8, 103, 100, 1),
(1012, '2026-03-18', 9, 105, 300, 2),
(1013, '2026-04-01', 10, 101, 1200, 1),
(1014, '2026-04-10', 5, 102, 500, 1),
(1015, '2026-04-15', 3, 104, 200, 4);
GO


/* ============================================================
   EMPLOYEES DATA
   ============================================================ */

INSERT INTO Sales.Employees
(EmployeeID, EmployeeName, Department, Salary)
VALUES
(1, 'Alice', 'IT', 70000),
(2, 'Bob', 'IT', 85000),
(3, 'Charlie', 'Finance', 75000),
(4, 'David', 'Finance', 90000),
(5, 'Eva', 'HR', 65000),
(6, 'Frank', 'HR', 65000),
(7, 'Grace', 'IT', 95000);
GO


/* ============================================================
   ARCHIVE DATA
   Intentionally duplicate OrderID রাখা হয়েছে
   ============================================================ */

INSERT INTO Sales.OrdersArchive
VALUES
(1001, '2026-01-05', 1, 101, 1200),
(1002, '2026-01-08', 2, 103, 200),
(1002, '2026-01-08', 2, 103, 200),
(1003, '2026-01-15', 1, 104, 100),
(1004, '2026-01-20', 3, 102, 500),
(1004, '2026-01-20', 3, 102, 500);
GO











