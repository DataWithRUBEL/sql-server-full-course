-- ============================================================
-- Create Database
-- Purpose:
-- Window Ranking Functions practice করার জন্য
-- নতুন database তৈরি করা হচ্ছে।
-- ============================================================
CREATE DATABASE WindowRankingFunctionsDB;
GO

USE WindowRankingFunctionsDB;
GO

-- ============================================================
-- Create Schemas
-- Purpose:
-- Business domain অনুযায়ী objects আলাদা রাখা।
-- ============================================================
CREATE SCHEMA customer;
GO

CREATE SCHEMA product;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA etl;
GO



-- ============================================================
-- Customer Master Table
-- Purpose:
-- Customer-level ranking, revenue ranking,
-- first/latest order এবং duplicate analysis।
-- ============================================================
CREATE TABLE customer.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    City            VARCHAR(50),
    Region          VARCHAR(50),
    SignupDate      DATE,
    CustomerStatus  VARCHAR(20)
);
GO

-- ============================================================
-- Insert realistic customer data
-- ============================================================
INSERT INTO customer.Customers
(
    CustomerID,
    CustomerName,
    City,
    Region,
    SignupDate,
    CustomerStatus
)
VALUES
(101, 'Ahmed Ali',       'Kuwait City', 'Central', '2023-01-15', 'Active'),
(102, 'Mohammed Hassan', 'Hawally',     'Central', '2023-02-20', 'Active'),
(103, 'Sara Khan',       'Farwaniya',   'South',   '2023-03-10', 'Active'),
(104, 'Omar Rahman',     'Salmiya',     'Central', '2023-04-05', 'Active'),
(105, 'Fatima Noor',     'Jleeb',       'South',   '2023-05-12', 'Active'),
(106, 'Rashid Ahmed',    'Jahra',       'North',   '2023-06-01', 'Inactive'),
(107, 'Nadia Islam',     'Mahboula',    'South',   '2023-07-15', 'Active'),
(108, 'Karim Hasan',     'Mangaf',      'South',   '2023-08-20', 'Active'),
(109, 'Aisha Rahman',    'Salmiya',     'Central', '2023-09-11', 'Active'),
(110, 'Yusuf Khan',      'Jahra',       'North',   '2023-10-25', 'Active');
GO


-- ============================================================
-- Product Master Table
-- Purpose:
-- Product/category ranking এবং product performance analysis।
-- ============================================================
CREATE TABLE product.Products
(
    ProductID       INT PRIMARY KEY,
    ProductName     VARCHAR(100) NOT NULL,
    Category        VARCHAR(50) NOT NULL,
    UnitPrice       DECIMAL(12,2) NOT NULL,
    CostPrice       DECIMAL(12,2) NOT NULL
);
GO

-- ============================================================
-- Insert realistic product data
-- ============================================================
INSERT INTO product.Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice,
    CostPrice
)
VALUES
(1,  'Laptop Pro 15',     'Electronics', 1200, 850),
(2,  'Laptop Air 13',     'Electronics',  900, 620),
(3,  'iPhone 15',          'Mobiles',      850, 650),
(4,  'Galaxy S24',         'Mobiles',      800, 610),
(5,  'iPad Air',           'Tablets',      650, 450),
(6,  'Galaxy Tab',         'Tablets',      550, 380),
(7,  'Office Chair',       'Furniture',    250, 150),
(8,  'Office Desk',        'Furniture',    400, 250),
(9,  'Wireless Mouse',     'Accessories',   35,  18),
(10, 'Mechanical Keyboard','Accessories',   80,  45);
GO


-- ============================================================
-- Branch Master Table
-- Purpose:
-- Branch-level ranking এবং regional performance।
-- ============================================================
CREATE TABLE sales.Branches
(
    BranchID    INT PRIMARY KEY,
    BranchName  VARCHAR(100),
    City        VARCHAR(50),
    Region      VARCHAR(50)
);
GO

-- ============================================================
-- Insert branch data
-- ============================================================
INSERT INTO sales.Branches
(
    BranchID,
    BranchName,
    City,
    Region
)
VALUES
(1, 'Kuwait City Branch', 'Kuwait City', 'Central'),
(2, 'Hawally Branch',     'Hawally',     'Central'),
(3, 'Farwaniya Branch',   'Farwaniya',   'South'),
(4, 'Salmiya Branch',     'Salmiya',     'Central'),
(5, 'Jahra Branch',       'Jahra',       'North');
GO


-- ============================================================
-- Employee / Salesperson Table
-- Purpose:
-- Salesperson এবং employee performance ranking।
-- ============================================================
CREATE TABLE hr.Employees
(
    EmployeeID    INT PRIMARY KEY,
    EmployeeName  VARCHAR(100),
    Department    VARCHAR(50),
    BranchID      INT,
    HireDate      DATE
);
GO

-- ============================================================
-- Insert employee data
-- ============================================================
INSERT INTO hr.Employees
(
    EmployeeID,
    EmployeeName,
    Department,
    BranchID,
    HireDate
)
VALUES
(201, 'Ali Hassan',   'Sales', 1, '2021-01-10'),
(202, 'John Mathew',  'Sales', 1, '2021-03-15'),
(203, 'Sara Ahmed',   'Sales', 2, '2022-01-20'),
(204, 'David Khan',   'Sales', 3, '2022-05-10'),
(205, 'Nadia Karim',  'Sales', 4, '2023-02-01'),
(206, 'Omar Ali',     'Sales', 5, '2023-06-15');
GO


-- ============================================================
-- Orders Transaction Table
-- Purpose:
-- Date-based ranking, customer ranking,
-- monthly/yearly ranking এবং latest/earliest records।
-- ============================================================
CREATE TABLE sales.Orders
(
    OrderID       INT PRIMARY KEY,
    CustomerID    INT NOT NULL,
    BranchID      INT NOT NULL,
    EmployeeID    INT NOT NULL,
    OrderDate     DATE NOT NULL,
    OrderStatus   VARCHAR(20),
    TotalAmount   DECIMAL(12,2)
);
GO


-- ============================================================
-- Insert realistic sales transactions
-- একই amount রাখা হয়েছে যাতে RANK/DENSE_RANK-এর ties
-- ভালোভাবে practice করা যায়।
-- ============================================================
INSERT INTO sales.Orders
(
    OrderID,
    CustomerID,
    BranchID,
    EmployeeID,
    OrderDate,
    OrderStatus,
    TotalAmount
)
VALUES
(1001,101,1,201,'2025-01-05','Completed',1200),
(1002,102,1,202,'2025-01-08','Completed', 850),
(1003,103,2,203,'2025-01-12','Completed', 850),
(1004,104,3,204,'2025-01-15','Completed',1500),
(1005,105,4,205,'2025-01-20','Completed', 650),
(1006,101,1,201,'2025-02-03','Completed', 900),
(1007,106,5,206,'2025-02-07','Completed', 400),
(1008,107,3,204,'2025-02-10','Completed',1200),
(1009,108,3,204,'2025-02-15','Completed',1200),
(1010,109,4,205,'2025-02-18','Completed', 650),
(1011,110,5,206,'2025-02-22','Completed', 400),
(1012,102,1,202,'2025-03-01','Completed',2000),
(1013,103,2,203,'2025-03-05','Completed', 900),
(1014,104,3,204,'2025-03-10','Completed',1500),
(1015,105,4,205,'2025-03-15','Completed', 650),
(1016,101,1,201,'2025-03-20','Completed',2000),
(1017,107,3,204,'2025-04-01','Completed',1200),
(1018,108,3,204,'2025-04-05','Completed', 900),
(1019,109,4,205,'2025-04-10','Completed', 650),
(1020,110,5,206,'2025-04-15','Completed', 400),
(1021,101,1,201,'2025-04-20','Completed',1500),
(1022,102,1,202,'2025-05-01','Completed',2000),
(1023,103,2,203,'2025-05-05','Completed', 900),
(1024,104,3,204,'2025-05-10','Completed',1500),
(1025,105,4,205,'2025-05-15','Completed', 650);
GO

-- ============================================================
-- Order Items Fact Table
-- Purpose:
-- Product quantity, revenue এবং profit ranking।
-- ============================================================
CREATE TABLE sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID     INT,
    ProductID   INT,
    Quantity    INT,
    UnitPrice   DECIMAL(12,2)
);
GO

-- ============================================================
-- Insert order item data
-- ============================================================
INSERT INTO sales.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1,1001,1,1,1200),
(2,1002,3,1,850),
(3,1003,4,1,800),
(4,1004,1,1,1200),
(5,1004,7,1,250),
(6,1005,5,1,650),
(7,1006,2,1,900),
(8,1007,8,1,400),
(9,1008,1,1,1200),
(10,1009,1,1,1200),
(11,1010,5,1,650),
(12,1011,8,1,400),
(13,1012,1,1,1200),
(14,1012,2,1,900),
(15,1013,2,1,900),
(16,1014,1,1,1200),
(17,1014,7,1,250),
(18,1015,5,1,650),
(19,1016,1,1,1200),
(20,1016,2,1,900),
(21,1017,1,1,1200),
(22,1018,2,1,900),
(23,1019,5,1,650),
(24,1020,8,1,400),
(25,1021,1,1,1200),
(26,1022,1,1,1200),
(27,1022,2,1,900),
(28,1023,2,1,900),
(29,1024,1,1,1200),
(30,1024,7,1,250),
(31,1025,5,1,650);
GO



