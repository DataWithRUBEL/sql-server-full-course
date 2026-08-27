/* ==============================================================================
   DATABASE: SETOperationsDB
   PURPOSE : SQL SET OPERATIONS PRACTICE
   ============================================================================== */

CREATE DATABASE SETOperationsDB;
GO

USE SETOperationsDB;
GO


/* ==============================================================================
   SCHEMA
   ============================================================================== */

CREATE SCHEMA Sales;
GO


/* ==============================================================================
   CUSTOMERS
   ============================================================================== */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    Email VARCHAR(100)
);
GO


/* ==============================================================================
   EMPLOYEES
   ============================================================================== */

CREATE TABLE Sales.Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Department VARCHAR(50),
    Email VARCHAR(100)
);
GO


/* ==============================================================================
   ORDERS
   ============================================================================== */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    SalesPersonID INT,
    OrderDate DATE,
    ShipDate DATE,
    OrderStatus VARCHAR(20),
    Quantity INT,
    Sales DECIMAL(12,2),
    CreationTime DATETIME2
);
GO


/* ==============================================================================
   ORDERS ARCHIVE
   Historical orders
   ============================================================================== */

CREATE TABLE Sales.OrdersArchive
(
    OrderID INT,
    ProductID INT,
    CustomerID INT,
    SalesPersonID INT,
    OrderDate DATE,
    ShipDate DATE,
    OrderStatus VARCHAR(20),
    Quantity INT,
    Sales DECIMAL(12,2),
    CreationTime DATETIME2
);
GO




-- Data insert
/* ==============================================================================
   CUSTOMERS
   ============================================================================== */

INSERT INTO Sales.Customers
(
    CustomerID,
    FirstName,
    LastName,
    Country,
    Email
)
VALUES
(1, 'John',  'Smith',  'USA',     'john@gmail.com'),
(2, 'David', 'Brown',  'UK',      'david@gmail.com'),
(3, 'Sarah', 'Wilson', 'Canada',  'sarah@gmail.com'),
(4, 'Mike',  'Taylor', 'USA',     'mike@gmail.com'),
(5, 'Emma',  'Davis',  'Australia','emma@gmail.com'),
(6, 'Robert','Miller', 'USA',     'robert@gmail.com'),
(7, 'Daniel','Moore',  'Germany', 'daniel@gmail.com'),
(8, 'Lisa',  'Taylor', 'UK',      'lisa@gmail.com');
GO


/* ==============================================================================
   EMPLOYEES
   ============================================================================== */

INSERT INTO Sales.Employees
(
    EmployeeID,
    FirstName,
    LastName,
    Department,
    Email
)
VALUES
(101, 'John',  'Smith',  'Sales',       'john.employee@gmail.com'),
(102, 'James', 'Brown',  'IT',          'james@gmail.com'),
(103, 'Sarah', 'Wilson', 'Finance',     'sarah.employee@gmail.com'),
(104, 'Robert','Miller', 'Sales',       'robert.employee@gmail.com'),
(105, 'William','Jones', 'HR',          'william@gmail.com'),
(106, 'Emma',  'Davis',  'Sales',       'emma.employee@gmail.com'),
(107, 'Daniel','Moore',  'IT',          'daniel.employee@gmail.com'),
(108, 'Peter', 'Clark',  'Sales',       'peter@gmail.com');
GO


/* ==============================================================================
   CURRENT ORDERS
   ============================================================================== */

INSERT INTO Sales.Orders
(
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
)
VALUES
(1001, 101, 1, 108, '2026-01-05', '2026-01-07', 'Completed', 2,  20.00, '2026-01-05 10:00'),
(1002, 102, 2, 101, '2026-01-08', '2026-01-10', 'Completed', 3,  45.00, '2026-01-08 11:00'),
(1003, 103, 3, 104, '2026-01-12', '2026-01-15', 'Completed', 5, 100.00, '2026-01-12 09:30'),
(1004, 104, 4, 106, '2026-01-20', '2026-01-22', 'Shipped',   2,  50.00, '2026-01-20 14:00'),
(1005, 105, 5, 108, '2026-02-01', '2026-02-03', 'Completed', 4, 120.00, '2026-02-01 10:15');
GO


/* ==============================================================================
   ARCHIVE ORDERS
   ============================================================================== */

INSERT INTO Sales.OrdersArchive
(
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
)
VALUES
(9001, 101, 6, 101, '2025-11-05', '2025-11-07', 'Completed', 2,  20.00, '2025-11-05 10:00'),
(9002, 102, 7, 104, '2025-11-10', '2025-11-12', 'Completed', 3,  45.00, '2025-11-10 11:00'),
(9003, 103, 1, 108, '2025-12-01', '2025-12-03', 'Completed', 5, 100.00, '2025-12-01 09:30'),
(9004, 104, 8, 106, '2025-12-10', '2025-12-12', 'Shipped',   2,  50.00, '2025-12-10 14:00');
GO
