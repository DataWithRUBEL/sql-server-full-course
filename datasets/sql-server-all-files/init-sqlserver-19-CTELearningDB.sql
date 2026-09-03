-- =========================================================
-- Create Database
-- =========================================================

CREATE DATABASE CTELearningDB;
GO

USE CTELearningDB;
GO


-- =========================================================
-- Customers Table
-- =========================================================

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100),
    Country VARCHAR(50),
    City VARCHAR(50)
);

-- Insert Customers
INSERT INTO Customers
(CustomerID, CustomerName, Country, City)
VALUES
(1, 'John Smith', 'USA', 'New York'),
(2, 'David Lee', 'USA', 'Chicago'),
(3, 'Sara Khan', 'UK', 'London'),
(4, 'Ali Hassan', 'UAE', 'Dubai'),
(5, 'Maria Silva', 'Brazil', 'Sao Paulo'),
(6, 'Ahmed Rahman', 'Bangladesh', 'Dhaka'),
(7, 'Robert Brown', 'USA', 'Boston'),
(8, 'Emma Wilson', 'UK', 'Manchester');



-- =========================================================
-- Departments Table
-- =========================================================

CREATE TABLE Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);

INSERT INTO Departments
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance'),
(4, 'HR');

-- =========================================================
-- Employees Table
-- ManagerID points to another Employee
-- =========================================================

CREATE TABLE Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    DepartmentID INT,
    ManagerID INT NULL,
    Salary DECIMAL(12,2),
    HireDate DATE
);


INSERT INTO Employees
VALUES
(1, 'James', 1, NULL, 90000, '2020-01-10'),
(2, 'Robert', 1, 1, 70000, '2021-03-15'),
(3, 'Emma', 1, 1, 68000, '2022-06-20'),
(4, 'David', 2, NULL, 95000, '2019-02-01'),
(5, 'Michael', 2, 4, 75000, '2021-05-10'),
(6, 'Sophia', 2, 4, 72000, '2022-08-15'),
(7, 'Olivia', 3, NULL, 88000, '2020-04-12'),
(8, 'Daniel', 3, 7, 65000, '2023-01-20'),
(9, 'William', 4, NULL, 82000, '2021-09-01'),
(10, 'Lucas', 4, 9, 60000, '2023-05-18');


-- =========================================================
-- Product Categories
-- =========================================================

CREATE TABLE Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100)
);


INSERT INTO Categories
VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Accessories');


-- =========================================================
-- Products Table
-- =========================================================

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    CategoryID INT,
    Price DECIMAL(10,2)
);

INSERT INTO Products
VALUES
(101, 'Laptop', 1, 1200),
(102, 'Phone', 1, 800),
(103, 'Headphones', 1, 150),
(104, 'T-Shirt', 2, 30),
(105, 'Jeans', 2, 60),
(106, 'Jacket', 2, 100),
(107, 'Watch', 3, 200),
(108, 'Backpack', 3, 80);


-- =========================================================
-- Orders Table
-- =========================================================

CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    Status VARCHAR(30)
);

INSERT INTO Orders
VALUES
(1001, 1, 2, '2026-01-05', 'Completed'),
(1002, 2, 2, '2026-01-10', 'Completed'),
(1003, 3, 3, '2026-01-15', 'Completed'),
(1004, 4, 3, '2026-01-20', 'Pending'),
(1005, 5, 2, '2026-02-05', 'Completed'),
(1006, 6, 3, '2026-02-10', 'Completed'),
(1007, 7, 2, '2026-02-15', 'Cancelled'),
(1008, 8, 3, '2026-02-20', 'Completed'),
(1009, 1, 2, '2026-03-05', 'Completed'),
(1010, 2, 3, '2026-03-10', 'Completed'),
(1011, 3, 2, '2026-03-15', 'Completed'),
(1012, 4, 3, '2026-03-20', 'Pending');


-- =========================================================
-- Order Items
-- =========================================================

CREATE TABLE OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2)
);

INSERT INTO OrderItems
VALUES
(1, 1001, 101, 1, 1200),
(2, 1001, 104, 2, 30),

(3, 1002, 102, 1, 800),
(4, 1002, 107, 1, 200),

(5, 1003, 103, 2, 150),
(6, 1003, 105, 1, 60),

(7, 1004, 106, 1, 100),

(8, 1005, 101, 1, 1200),
(9, 1005, 108, 2, 80),

(10, 1006, 102, 2, 800),

(11, 1007, 104, 3, 30),

(12, 1008, 105, 2, 60),
(13, 1008, 107, 1, 200),

(14, 1009, 101, 1, 1200),

(15, 1010, 103, 1, 150),
(16, 1010, 108, 1, 80),

(17, 1011, 102, 1, 800),
(18, 1011, 106, 1, 100),

(19, 1012, 104, 2, 30);
