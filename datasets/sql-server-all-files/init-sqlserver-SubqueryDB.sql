Database Structure
SubqueryDB
│
└── Sales
    ├── Customers
    ├── Products
    ├── Orders
    └── Employees


-- ============================================================
-- CREATE DATABASE
-- ============================================================

CREATE DATABASE SubqueryDB;
GO

USE SubqueryDB;
GO



-- ============================================================
-- CREATE SALES SCHEMA
-- ============================================================

CREATE SCHEMA Sales;
GO




-- ============================================================
-- CUSTOMERS TABLE
-- ============================================================

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    Gender CHAR(1)
);
GO

-- ============================================================
-- INSERT CUSTOMER DATA
-- ============================================================

INSERT INTO Sales.Customers
(CustomerID, FirstName, LastName, Country, Gender)
VALUES
(1, 'John',   'Smith',   'USA',      'M'),
(2, 'Emma',   'Brown',   'Germany',  'F'),
(3, 'Michael','Wilson',  'USA',      'M'),
(4, 'Sophia', 'Miller',  'Germany',  'F'),
(5, 'Daniel', 'Taylor',  'UK',       'M'),
(6, 'Olivia', 'Anderson','Germany',  'F'),
(7, 'James',  'Thomas',  'France',   'M'),
(8, 'Ava',    'Jackson', 'USA',      'F'),
(9, 'William','White',   'UK',       'M'),
(10,'Mia',    'Harris',  'France',   'F');
GO


-- ============================================================
-- PRODUCTS TABLE
-- ============================================================

CREATE TABLE Sales.Products
(
    ProductID INT PRIMARY KEY,
    Product VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2)
);
GO


-- ============================================================
-- INSERT PRODUCT DATA
-- ============================================================

INSERT INTO Sales.Products
(ProductID, Product, Category, Price)
VALUES
(101, 'Laptop',       'Electronics', 1200),
(102, 'Monitor',      'Electronics', 500),
(103, 'Keyboard',     'Accessories', 100),
(104, 'Mouse',        'Accessories', 50),
(105, 'Headphones',   'Accessories', 150),
(106, 'Office Chair', 'Furniture',   300),
(107, 'Desk',         'Furniture',   450),
(108, 'Printer',      'Electronics', 700),
(109, 'Webcam',       'Electronics', 200),
(110, 'Tablet',       'Electronics', 800);
GO


-- ============================================================
-- ORDERS TABLE
-- ============================================================

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
GO


-- ============================================================
-- INSERT ORDER DATA
-- ============================================================

INSERT INTO Sales.Orders
(OrderID, CustomerID, ProductID, OrderDate, Quantity, Sales)
VALUES
(1001, 1, 101, '2026-01-05', 1, 1200),
(1002, 2, 102, '2026-01-08', 2, 1000),
(1003, 3, 103, '2026-01-10', 3, 300),
(1004, 2, 104, '2026-01-12', 2, 100),
(1005, 4, 105, '2026-01-15', 2, 300),
(1006, 5, 106, '2026-01-20', 1, 300),
(1007, 1, 108, '2026-01-22', 1, 700),
(1008, 6, 109, '2026-02-01', 2, 400),
(1009, 7, 110, '2026-02-05', 1, 800),
(1010, 8, 101, '2026-02-10', 1, 1200),
(1011, 3, 107, '2026-02-12', 1, 450),
(1012, 2, 108, '2026-02-15', 1, 700),
(1013, 5, 103, '2026-02-18', 5, 500),
(1014, 9, 102, '2026-02-20', 1, 500),
(1015, 10, 109, '2026-02-25', 3, 600);
GO


-- ============================================================
-- EMPLOYEES TABLE
-- ============================================================

CREATE TABLE Sales.Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Gender CHAR(1),
    Department VARCHAR(50),
    Salary DECIMAL(10,2)
);
GO


-- ============================================================
-- INSERT EMPLOYEE DATA
-- ============================================================

INSERT INTO Sales.Employees
(EmployeeID, FirstName, LastName, Gender, Department, Salary)
VALUES
(1, 'John',   'Adams',   'M', 'IT',        70000),
(2, 'Sarah',  'Brown',   'F', 'IT',        85000),
(3, 'David',  'Clark',   'M', 'Finance',   60000),
(4, 'Emma',   'Davis',   'F', 'Finance',   75000),
(5, 'Robert', 'Evans',   'M', 'HR',        50000),
(6, 'Sophia', 'Frank',   'F', 'HR',        65000),
(7, 'Michael','Green',   'M', 'Sales',     55000),
(8, 'Olivia', 'Hall',    'F', 'Sales',     90000),
(9, 'Daniel', 'King',    'M', 'IT',        95000),
(10,'Ava',    'Lewis',   'F', 'Finance',   80000);
GO

