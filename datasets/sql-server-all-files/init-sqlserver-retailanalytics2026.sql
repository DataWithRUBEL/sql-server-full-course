/* ============================================================
   DATABASE
   RetailAnalytics2026
   ============================================================ */

CREATE DATABASE RetailAnalytics2026;
GO

USE RetailAnalytics2026;
GO


৭টি Real Business Tables তৈরি
Departments
     ↓
Employees

Customers
     ↓
Orders
     ↓
OrderDetails
     ↓
Products

Orders
     ↓
Payments


/* ============================================================
   TABLE 1: Customers
   Customer master data
   ============================================================ */

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    Score INT,
    Email VARCHAR(100)
);
GO

/* ============================================================
   CUSTOMER DATA
   ============================================================ */

INSERT INTO Customers
(
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score,
    Email
)
VALUES
(1001, 'Michael', 'Brown', 'USA',       720, 'michael.brown@email.com'),
(1002, 'Sarah',   'Wilson', 'Germany',  450, 'sarah.wilson@email.com'),
(1003, 'Robert',  'Smith',  'USA',      580, 'robert.smith@email.com'),
(1004, 'Maria',   'Garcia', 'Spain',    320, 'maria.garcia@email.com'),
(1005, 'Daniel',  'Miller', 'Germany',  610, 'daniel.miller@email.com'),
(1006, 'Emma',    'Taylor', 'UK',       490, 'emma.taylor@email.com'),
(1007, 'Christopher', 'Moore', 'USA',    850, 'chris.moore@email.com'),
(1008, 'Helen',   'Johnson','Canada',   275, 'helen.johnson@email.com'),
(1009, 'Martin',  'Davis',  'Germany',  510, 'martin.davis@email.com'),
(1010, 'Karen',   'Anderson','USA',     390, 'karen.anderson@email.com');
GO



/* ============================================================
   TABLE 2: Products
   Product master data
   ============================================================ */

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    Price DECIMAL(10,2),
    StockQuantity INT
);
GO


/* ============================================================
   PRODUCT DATA
   ============================================================ */

INSERT INTO Products
(
    ProductID,
    ProductName,
    Category,
    Price,
    StockQuantity
)
VALUES
(101, 'Laptop Backpack', 'Accessories', 45.00, 120),
(102, 'Wireless Mouse',  'Electronics', 25.00, 250),
(103, 'Mechanical Keyboard', 'Electronics', 85.00, 100),
(104, 'USB-C Cable', 'Accessories', 15.00, 500),
(105, 'Office Chair', 'Furniture', 180.00, 60),
(106, 'Desk Lamp', 'Furniture', 55.00, 90),
(107, 'Monitor 24 Inch', 'Electronics', 220.00, 45),
(108, 'Notebook', 'Stationery', 8.00, 800);
GO



/* ============================================================
   TABLE 3: Departments
   Company department information
   ============================================================ */

CREATE TABLE Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100)
);
GO


/* ============================================================
   DEPARTMENT DATA
   ============================================================ */

INSERT INTO Departments
(
    DepartmentID,
    DepartmentName
)
VALUES
(1, 'Sales'),
(2, 'Data Engineering'),
(3, 'Finance'),
(4, 'Human Resources'),
(5, 'Operations');
GO


/* ============================================================
   TABLE 4: Employees
   Employee information
   ============================================================ */

CREATE TABLE Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DepartmentID INT,
    JobTitle VARCHAR(100),
    Salary DECIMAL(12,2),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);
GO


/* ============================================================
   EMPLOYEE DATA
   ============================================================ */

INSERT INTO Employees
(
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    JobTitle,
    Salary
)
VALUES
(501, 'James', 'Wilson', 1, 'Sales Manager', 65000),
(502, 'Linda', 'Brown', 1, 'Sales Executive', 48000),
(503, 'David', 'Miller', 2, 'Data Engineer', 78000),
(504, 'Sophia', 'Taylor', 2, 'Data Analyst', 62000),
(505, 'John', 'Anderson', 3, 'Financial Analyst', 59000),
(506, 'Olivia', 'Davis', 4, 'HR Specialist', 52000),
(507, 'William', 'Moore', 5, 'Operations Manager', 70000);
GO



/* ============================================================
   TABLE 5: Orders
   Customer orders
   ============================================================ */

CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    EmployeeID INT,
    OrderDate DATE,
    OrderStatus VARCHAR(30),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);
GO



/* ============================================================
   ORDER DATA
   ============================================================ */

INSERT INTO Orders
(
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus
)
VALUES
(9001, 1001, 501, '2026-01-05', 'Completed'),
(9002, 1002, 502, '2026-01-12', 'Completed'),
(9003, 1003, 501, '2026-02-03', 'Pending'),
(9004, 1004, 502, '2026-02-15', 'Completed'),
(9005, 1005, 501, '2026-03-01', 'Completed'),
(9006, 1006, 502, '2026-03-10', 'Cancelled'),
(9007, 1007, 501, '2026-04-02', 'Completed'),
(9008, 1008, 502, '2026-04-18', 'Pending'),
(9009, 1009, 501, '2026-05-07', 'Completed'),
(9010, 1010, 502, '2026-05-20', 'Pending');
GO



/* ============================================================
   TABLE 6: OrderDetails
   Products inside each order
   ============================================================ */

CREATE TABLE OrderDetails
(
    OrderDetailID INT PRIMARY KEY,
    OrderID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO




/* ============================================================
   ORDER DETAIL DATA
   ============================================================ */

INSERT INTO OrderDetails
(
    OrderDetailID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1, 9001, 101, 2, 45.00),
(2, 9001, 102, 1, 25.00),
(3, 9002, 103, 1, 85.00),
(4, 9002, 104, 3, 15.00),
(5, 9003, 107, 2, 220.00),
(6, 9004, 108, 10, 8.00),
(7, 9005, 105, 1, 180.00),
(8, 9006, 106, 2, 55.00),
(9, 9007, 107, 1, 220.00),
(10, 9008, 102, 4, 25.00),
(11, 9009, 103, 2, 85.00),
(12, 9010, 101, 3, 45.00);
GO



/* ============================================================
   TABLE 7: Payments
   Payment information
   ============================================================ */

CREATE TABLE Payments
(
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    PaymentMethod VARCHAR(30),
    PaymentAmount DECIMAL(12,2),
    PaymentStatus VARCHAR(30),

    CONSTRAINT FK_Payments_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID)
);
GO


/* ============================================================
   PAYMENT DATA
   ============================================================ */

INSERT INTO Payments
(
    PaymentID,
    OrderID,
    PaymentMethod,
    PaymentAmount,
    PaymentStatus
)
VALUES
(7001, 9001, 'Credit Card', 115.00, 'Paid'),
(7002, 9002, 'PayPal',       130.00, 'Paid'),
(7003, 9003, 'Credit Card', 440.00, 'Pending'),
(7004, 9004, 'Cash',         80.00, 'Paid'),
(7005, 9005, 'Bank Transfer',180.00, 'Paid'),
(7006, 9006, 'Credit Card', 110.00, 'Refunded'),
(7007, 9007, 'Credit Card', 220.00, 'Paid'),
(7008, 9008, 'PayPal',       100.00, 'Pending'),
(7009, 9009, 'Bank Transfer',170.00, 'Paid'),
(7010, 9010, 'Credit Card', 135.00, 'Pending');
GO




প্রথমে data ঠিকমতো তৈরি হয়েছে কিনা দেখি।
/* ============================================================
   VERIFY TABLE DATA
   ============================================================ */

SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Departments;

SELECT * FROM Employees;

SELECT * FROM Orders;

SELECT * FROM OrderDetails;

SELECT * FROM Payments;






