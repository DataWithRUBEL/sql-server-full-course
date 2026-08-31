/* =========================================================
   Create Database
   Purpose:
   NULL handling practice করার জন্য dedicated database
   ========================================================= */

IF DB_ID('NullFunctionsDB') IS NULL
BEGIN
    CREATE DATABASE NullFunctionsDB;
END;
GO

USE NullFunctionsDB;
GO


/* =========================================================
   Create Schemas
   Purpose:
   Different data layers logically separate করা
   ========================================================= */

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'source')
    EXEC('CREATE SCHEMA source');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'bronze')
    EXEC('CREATE SCHEMA bronze');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'silver')
    EXEC('CREATE SCHEMA silver');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'etl')
    EXEC('CREATE SCHEMA etl');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'qa')
    EXEC('CREATE SCHEMA qa');
GO

/* =========================================================
   Categories
   Purpose:
   Product category information সংরক্ষণ করা
   ========================================================= */

CREATE TABLE source.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO

/* =========================================================
   Insert Category Data
   Purpose:
   Realistic retail category data
   ========================================================= */

INSERT INTO source.Categories
(
    CategoryID,
    CategoryName
)
VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Clothing'),
(4, 'Home & Kitchen'),
(5, 'Sports');
GO

/* =========================================================
   Customers
   Purpose:
   Customer master data সংরক্ষণ করা

   Nullable columns:
   Phone, Email, Country, DateOfBirth
   কারণ বাস্তবে customer সব তথ্য নাও দিতে পারে।
   ========================================================= */

CREATE TABLE source.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NULL,
    Phone VARCHAR(30) NULL,
    Country VARCHAR(50) NULL,
    DateOfBirth DATE NULL,
    CustomerStatus VARCHAR(20) NULL,
    CreatedDate DATE NOT NULL
);
GO

/* =========================================================
   Insert Customer Data
   Purpose:
   NULL scenarios practice করার জন্য realistic data
   ========================================================= */

INSERT INTO source.Customers
(
    CustomerID,
    CustomerName,
    Email,
    Phone,
    Country,
    DateOfBirth,
    CustomerStatus,
    CreatedDate
)
VALUES
(101, 'Ahmed Ali', 'ahmed@example.com', '+96550000001', 'Kuwait', '1990-04-12', 'Active', '2026-01-05'),
(102, 'Mohammed Hasan', NULL, '+96550000002', 'Kuwait', '1988-07-21', 'Active', '2026-01-06'),
(103, 'John Smith', 'john@example.com', NULL, 'USA', NULL, 'Active', '2026-01-07'),
(104, 'Fatima Rahman', NULL, NULL, 'Bangladesh', '1995-11-03', 'Active', '2026-01-08'),
(105, 'David Brown', 'david@example.com', '+44200000005', 'UK', NULL, NULL, '2026-01-09'),
(106, 'Sara Khan', 'sara@example.com', NULL, NULL, '1992-03-17', 'Active', '2026-01-10'),
(107, 'Omar Hassan', NULL, '+97150000007', 'UAE', NULL, 'Inactive', '2026-01-11'),
(108, 'Maria Garcia', 'maria@example.com', '+34900000008', 'Spain', '1991-08-25', NULL, '2026-01-12'),
(109, 'Daniel Lee', NULL, NULL, 'Singapore', '1987-01-19', 'Active', '2026-01-13'),
(110, 'Aisha Rahman', 'aisha@example.com', '+88017000010', 'Bangladesh', NULL, 'Active', '2026-01-14'),
(111, 'Robert Wilson', NULL, '+12000000011', 'USA', '1985-06-15', 'Active', '2026-01-15'),
(112, 'Nadia Ahmed', 'nadia@example.com', NULL, NULL, '1998-01-22', 'Active', '2026-01-16'),
(113, 'James Taylor', 'james@example.com', '+44200000013', 'UK', NULL, 'Inactive', '2026-01-17'),
(114, 'Mariam Ali', NULL, '+96550000014', 'Kuwait', '1994-09-11', NULL, '2026-01-18'),
(115, 'Chris Martin', 'chris@example.com', NULL, NULL, NULL, 'Active', '2026-01-19');
GO


/* =========================================================
   Products
   Purpose:
   Product master information সংরক্ষণ করা

   Discount NULL = product-এর জন্য discount defined হয়নি
   ========================================================= */

CREATE TABLE source.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NULL,
    UnitPrice DECIMAL(12,2) NULL,
    DiscountPercent DECIMAL(5,2) NULL,
    StockQty INT NULL,
    ProductStatus VARCHAR(20) NULL,

    CONSTRAINT FK_Products_Category
        FOREIGN KEY (CategoryID)
        REFERENCES source.Categories(CategoryID)
);
GO

/* =========================================================
   Insert Product Data
   Purpose:
   NULL pricing, discount, stock এবং category scenarios
   practice করা
   ========================================================= */

INSERT INTO source.Products
(
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice,
    DiscountPercent,
    StockQty,
    ProductStatus
)
VALUES
(201, 'Laptop', 1, 850.00, 10.00, 25, 'Active'),
(202, 'Wireless Mouse', 2, 25.00, NULL, 150, 'Active'),
(203, 'Keyboard', 2, 45.00, 5.00, NULL, 'Active'),
(204, 'Monitor', 1, 220.00, NULL, 40, 'Active'),
(205, 'T-Shirt', 3, 20.00, 15.00, 200, 'Active'),
(206, 'Jeans', 3, 40.00, NULL, 100, 'Active'),
(207, 'Coffee Maker', 4, 75.00, 10.00, NULL, 'Active'),
(208, 'Blender', 4, NULL, NULL, 30, 'Inactive'),
(209, 'Football', 5, 30.00, 5.00, 80, 'Active'),
(210, 'Running Shoes', 5, 90.00, NULL, NULL, 'Active');
GO

/* =========================================================
   Departments
   Purpose:
   Employee organizational structure
   ========================================================= */

CREATE TABLE source.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO

INSERT INTO source.Departments
(
    DepartmentID,
    DepartmentName
)
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Operations'),
(5, 'HR');
GO

/* =========================================================
   Employees
   Purpose:
   Employee hierarchy সংরক্ষণ করা

   ManagerID NULL হতে পারে কারণ top-level manager-এর
   manager থাকে না।
   ========================================================= */

CREATE TABLE source.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    ManagerID INT NULL,
    Email VARCHAR(150) NULL,
    Salary DECIMAL(12,2) NULL,

    CONSTRAINT FK_Employee_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES source.Departments(DepartmentID)
);
GO

/* =========================================================
   Insert Employee Data
   Purpose:
   Manager hierarchy এবং missing employee data practice
   ========================================================= */

INSERT INTO source.Employees
(
    EmployeeID,
    EmployeeName,
    DepartmentID,
    ManagerID,
    Email,
    Salary
)
VALUES
(301, 'Ali Hassan', 1, NULL, 'ali@company.com', 5000),
(302, 'John Carter', 1, 301, 'john@company.com', 3500),
(303, 'Sara Ahmed', 1, 301, NULL, 3200),
(304, 'David Wilson', 2, NULL, 'david@company.com', 6000),
(305, 'Omar Khan', 2, 304, NULL, 4200),
(306, 'Mariam Ali', 3, NULL, 'mariam@company.com', 5500),
(307, 'Robert Lee', 3, 306, NULL, NULL),
(308, 'Aisha Rahman', 4, NULL, NULL, 4500),
(309, 'James Smith', 4, 308, 'james@company.com', NULL),
(310, 'Nadia Hasan', 5, NULL, 'nadia@company.com', 4800);
GO

/* =========================================================
   Orders
   Purpose:
   Customer orders সংরক্ষণ করা

   ShippedDate NULL = order এখনও shipped হয়নি
   DeliveredDate NULL = delivered হয়নি
   SalesRepID NULL = sales representative assigned হয়নি
   ========================================================= */

CREATE TABLE source.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    ShippedDate DATE NULL,
    DeliveredDate DATE NULL,
    SalesRepID INT NULL,
    OrderStatus VARCHAR(30) NULL,

    CONSTRAINT FK_Order_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES source.Customers(CustomerID),

    CONSTRAINT FK_Order_SalesRep
        FOREIGN KEY (SalesRepID)
        REFERENCES source.Employees(EmployeeID)
);
GO

/* =========================================================
   Insert Order Data
   Purpose:
   Order lifecycle-এর missing dates/status practice করা
   ========================================================= */

INSERT INTO source.Orders
(
    OrderID,
    CustomerID,
    OrderDate,
    ShippedDate,
    DeliveredDate,
    SalesRepID,
    OrderStatus
)
VALUES
(5001, 101, '2026-02-01', '2026-02-02', '2026-02-05', 302, 'Delivered'),
(5002, 102, '2026-02-02', '2026-02-03', NULL, 303, 'Shipped'),
(5003, 103, '2026-02-03', NULL, NULL, NULL, 'Pending'),
(5004, 104, '2026-02-04', '2026-02-05', '2026-02-08', 302, 'Delivered'),
(5005, 105, '2026-02-05', NULL, NULL, 303, NULL),
(5006, 106, '2026-02-06', '2026-02-07', NULL, NULL, 'Shipped'),
(5007, 107, '2026-02-07', NULL, NULL, 302, 'Cancelled'),
(5008, 108, '2026-02-08', '2026-02-09', '2026-02-12', NULL, 'Delivered'),
(5009, 109, '2026-02-09', NULL, NULL, 303, 'Pending'),
(5010, 110, '2026-02-10', '2026-02-11', '2026-02-14', 302, 'Delivered');
GO

/* =========================================================
   OrderItems
   Purpose:
   Order-এর individual products সংরক্ষণ করা
   ========================================================= */

CREATE TABLE source.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NULL,
    UnitPrice DECIMAL(12,2) NULL,

    CONSTRAINT FK_OrderItem_Order
        FOREIGN KEY (OrderID)
        REFERENCES source.Orders(OrderID),

    CONSTRAINT FK_OrderItem_Product
        FOREIGN KEY (ProductID)
        REFERENCES source.Products(ProductID)
);
GO

/* =========================================================
   Insert Order Item Data
   Purpose:
   Quantity / UnitPrice NULL scenarios practice
   ========================================================= */

INSERT INTO source.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1, 5001, 201, 1, 850.00),
(2, 5001, 202, 2, 25.00),
(3, 5002, 203, 1, 45.00),
(4, 5002, 204, 1, 220.00),
(5, 5003, 205, 3, 20.00),
(6, 5003, 206, NULL, 40.00),
(7, 5004, 207, 1, 75.00),
(8, 5004, 209, 2, 30.00),
(9, 5005, 210, 1, NULL),
(10, 5005, 202, 2, 25.00),
(11, 5006, 201, 1, 850.00),
(12, 5006, 203, NULL, 45.00),
(13, 5007, 206, 1, 40.00),
(14, 5008, 208, 1, NULL),
(15, 5008, 209, 2, 30.00),
(16, 5009, 205, 2, 20.00),
(17, 5009, 210, NULL, 90.00),
(18, 5010, 204, 2, 220.00),
(19, 5010, 202, 1, 25.00);
GO

/* =========================================================
   Payments
   Purpose:
   Payment information এবং missing payment information
   practice করা
   ========================================================= */

CREATE TABLE source.Payments
(
    PaymentID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    PaymentDate DATE NULL,
    PaymentMethod VARCHAR(30) NULL,
    Amount DECIMAL(12,2) NULL,
    PaymentStatus VARCHAR(30) NULL,

    CONSTRAINT FK_Payment_Order
        FOREIGN KEY (OrderID)
        REFERENCES source.Orders(OrderID)
);
GO

/* =========================================================
   Insert Payment Data
   Purpose:
   Missing payment date/method/status/amount scenarios
   ========================================================= */

INSERT INTO source.Payments
(
    PaymentID,
    OrderID,
    PaymentDate,
    PaymentMethod,
    Amount,
    PaymentStatus
)
VALUES
(9001, 5001, '2026-02-01', 'Card', 900.00, 'Paid'),
(9002, 5002, '2026-02-02', 'Cash', 265.00, 'Paid'),
(9003, 5003, NULL, NULL, NULL, 'Pending'),
(9004, 5004, '2026-02-04', 'Card', 135.00, 'Paid'),
(9005, 5005, NULL, 'Card', NULL, NULL),
(9006, 5006, '2026-02-06', NULL, 850.00, 'Paid'),
(9007, 5007, NULL, NULL, NULL, 'Failed'),
(9008, 5008, '2026-02-08', 'Card', NULL, 'Paid'),
(9009, 5009, NULL, 'Cash', 40.00, 'Pending'),
(9010, 5010, '2026-02-10', 'Card', 465.00, 'Paid');
GO
