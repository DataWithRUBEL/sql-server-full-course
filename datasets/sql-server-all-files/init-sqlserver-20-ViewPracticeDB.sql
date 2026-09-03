/* ============================================================
   SQL SERVER VIEW PRACTICE DATABASE
   ============================================================ */

-- নতুন Database তৈরি
CREATE DATABASE ViewPracticeDB;
GO

USE ViewPracticeDB;
GO


/* ============================================================
   আলাদা Schema ব্যবহার করছি
   - Sales      → Sales related tables/views
   - HR         → Employee related tables
   ============================================================ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO



/* ============================================================
   Customers Table
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName  VARCHAR(50),
    LastName   VARCHAR(50),
    Country    VARCHAR(50)
);
GO


/* ============================================================
   Products Table
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
   Departments Table
   ============================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50)
);
GO



/* ============================================================
   Employees Table
   ============================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO



/* ============================================================
   Orders Table
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT,
    ProductID INT,
    SalesPersonID INT,
    Quantity INT,
    Sales DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Products
        FOREIGN KEY (ProductID)
        REFERENCES Sales.Products(ProductID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (SalesPersonID)
        REFERENCES HR.Employees(EmployeeID)
);
GO



/* ============================================================
   Departments
   ============================================================ */

INSERT INTO HR.Departments
VALUES
(1, 'Sales'),
(2, 'Marketing'),
(3, 'IT'),
(4, 'Finance');
GO


/* ============================================================
   Employees
   ============================================================ */

INSERT INTO HR.Employees
VALUES
(101, 'John', 'Smith', 1),
(102, 'Sarah', 'Khan', 1),
(103, 'David', 'Lee', 2),
(104, 'Michael', 'Brown', 3),
(105, 'Emma', 'Wilson', 4);
GO


/* ============================================================
   Customers
   ============================================================ */

INSERT INTO Sales.Customers
VALUES
(1, 'Ali', 'Hassan', 'Kuwait'),
(2, 'Ahmed', 'Rahman', 'Bangladesh'),
(3, 'John', 'Miller', 'USA'),
(4, 'Sarah', 'Ali', 'UAE'),
(5, 'David', 'Khan', 'Qatar'),
(6, 'Omar', 'Hassan', 'Kuwait'),
(7, 'Michael', 'Smith', 'USA'),
(8, 'Fatima', 'Rahman', 'Bangladesh');
GO


/* ============================================================
   Products
   ============================================================ */

INSERT INTO Sales.Products
VALUES
(101, 'Laptop', 'Electronics', 1200.00),
(102, 'Monitor', 'Electronics', 450.00),
(103, 'Keyboard', 'Accessories', 80.00),
(104, 'Mouse', 'Accessories', 40.00),
(105, 'Office Chair', 'Furniture', 300.00),
(106, 'Desk', 'Furniture', 500.00);
GO


/* ============================================================
   Orders
   ============================================================ */

INSERT INTO Sales.Orders
VALUES
(1001, '2026-01-05', 1, 101, 101, 2, 2400),
(1002, '2026-01-10', 2, 102, 102, 3, 1350),
(1003, '2026-01-15', 3, 103, 101, 5, 400),
(1004, '2026-02-02', 4, 104, 102, 10, 400),
(1005, '2026-02-08', 5, 105, 101, 4, 1200),
(1006, '2026-02-15', 6, 106, 102, 2, 1000),
(1007, '2026-03-01', 7, 101, 101, 1, 1200),
(1008, '2026-03-05', 8, 102, 102, 2, 900),
(1009, '2026-03-10', 1, 103, 101, 10, 800),
(1010, '2026-03-15', 2, 105, 102, 3, 900);
GO



