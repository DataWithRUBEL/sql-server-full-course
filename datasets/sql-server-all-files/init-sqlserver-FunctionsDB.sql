/* ============================================================
   CREATE DATABASE
   ============================================================ */
CREATE DATABASE FunctionsDB;
GO

USE FunctionsDB;
GO


/* ============================================================
   CREATE SCHEMAS
   ============================================================ */
CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA utility;
GO

CREATE SCHEMA report;
GO



/* ============================================================
   DEPARTMENT MASTER
   ============================================================ */
CREATE TABLE hr.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO


INSERT INTO hr.Departments
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance'),
(4, 'HR'),
(5, 'Operations');
GO


/* ============================================================
   EMPLOYEE MASTER
   ============================================================ */
CREATE TABLE hr.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    DepartmentID INT,
    HireDate DATE,
    Salary DECIMAL(12,2),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES hr.Departments(DepartmentID)
);
GO

INSERT INTO hr.Employees
VALUES
(101, 'John Smith', 1, '2020-01-15', 55000),
(102, 'Sarah Khan', 1, '2021-03-10', 62000),
(103, 'David Lee', 2, '2019-07-20', 75000),
(104, 'Maria Garcia', 3, '2022-05-01', 68000),
(105, 'James Wilson', 5, '2023-02-15', 48000);
GO




/* ============================================================
   PRODUCT CATEGORIES
   ============================================================ */
CREATE TABLE sales.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO

INSERT INTO sales.Categories
VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Clothing'),
(4, 'Home Appliances');
GO

/* ============================================================
   PRODUCT MASTER
   ============================================================ */
CREATE TABLE sales.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150),
    CategoryID INT,
    UnitPrice DECIMAL(12,2),
    CostPrice DECIMAL(12,2),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES sales.Categories(CategoryID)
);
GO


INSERT INTO sales.Products
VALUES
(101, 'Laptop',        1, 1200, 850),
(102, 'Wireless Mouse',2,   35,  20),
(103, 'Keyboard',      2,   55,  30),
(104, 'T-Shirt',       3,   25,  12),
(105, 'Coffee Maker',  4,  95,  60),
(106, 'Monitor',       1,  350, 220);
GO


/* ============================================================
   CUSTOMER MASTER
   ============================================================ */
CREATE TABLE sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(150),
    Email VARCHAR(150),
    Country VARCHAR(100),
    RegistrationDate DATE
);
GO

INSERT INTO sales.Customers
VALUES
(1, 'Ahmed Ali',    'ahmed@example.com', 'Kuwait',     '2022-01-10'),
(2, 'John Brown',   'john@example.com',  'USA',        '2021-05-15'),
(3, 'Maria Lopez',  'maria@example.com', 'Spain',      '2023-02-20'),
(4, 'David Khan',   'david@example.com', 'Bangladesh', '2024-01-05'),
(5, 'Sarah Wilson', 'sarah@example.com', 'UK',         '2022-09-12');
GO



/* ============================================================
   ORDER HEADER
   ============================================================ */
CREATE TABLE sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    Status VARCHAR(30),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES hr.Employees(EmployeeID)
);
GO


INSERT INTO sales.Orders
VALUES
(1001, 1, 101, '2026-01-10', 'Completed'),
(1002, 2, 102, '2026-01-15', 'Completed'),
(1003, 1, 101, '2026-02-05', 'Completed'),
(1004, 3, 102, '2026-02-20', 'Pending'),
(1005, 4, 105, '2026-03-01', 'Completed'),
(1006, 5, 101, '2026-03-10', 'Completed');
GO

/* ============================================================
   ORDER LINE ITEMS
   ============================================================ */
CREATE TABLE sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(12,2),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID)
);
GO


INSERT INTO sales.OrderItems
VALUES
(1, 1001, 101, 1, 1200),
(2, 1001, 102, 2, 35),
(3, 1002, 103, 2, 55),
(4, 1002, 104, 3, 25),
(5, 1003, 106, 2, 350),
(6, 1003, 102, 1, 35),
(7, 1004, 105, 1, 95),
(8, 1005, 101, 2, 1200),
(9, 1005, 103, 1, 55),
(10, 1006, 106, 1, 350);
GO
