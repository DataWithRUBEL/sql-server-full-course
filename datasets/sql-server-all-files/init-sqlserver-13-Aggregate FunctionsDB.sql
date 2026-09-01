-- ============================================================
-- Create the practice database
-- Purpose:
-- This database will contain all tables and examples
-- used throughout the Aggregate Functions course.
-- ============================================================

IF DB_ID('AggregateFunctionsDB') IS NULL
BEGIN
    CREATE DATABASE AggregateFunctionsDB;
END;
GO

USE AggregateFunctionsDB;
GO

-- ============================================================
-- Create a dedicated schema
-- Purpose:
-- Keep all aggregate-function training objects organized.
-- ============================================================

IF NOT EXISTS
(
    SELECT 1
    FROM sys.schemas
    WHERE name = 'sales'
)
BEGIN
    EXEC('CREATE SCHEMA sales');
END;
GO



-- ============================================================
-- Customers table
-- Purpose:
-- Stores customer master information.
-- ============================================================

CREATE TABLE sales.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    City            VARCHAR(50),
    Country         VARCHAR(50),
    CustomerSegment VARCHAR(30),
    SignupDate      DATE
);
GO


-- ============================================================
-- Departments table
-- Purpose:
-- Stores company department information.
-- ============================================================

CREATE TABLE sales.Departments
(
    DepartmentID   INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO


-- ============================================================
-- Employees table
-- Purpose:
-- Stores employees responsible for orders/sales.
-- ============================================================

CREATE TABLE sales.Employees
(
    EmployeeID   INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID  INT,
    HireDate      DATE,
    Salary        DECIMAL(12,2),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES sales.Departments(DepartmentID)
);
GO


-- ============================================================
-- Categories table
-- Purpose:
-- Stores product categories.
-- ============================================================

CREATE TABLE sales.Categories
(
    CategoryID   INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO



-- ============================================================
-- Products table
-- Purpose:
-- Stores products and their prices.
-- ============================================================

CREATE TABLE sales.Products
(
    ProductID   INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID  INT NOT NULL,
    UnitPrice   DECIMAL(12,2),
    CostPrice   DECIMAL(12,2),
    StockQty    INT,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES sales.Categories(CategoryID)
);
GO


-- ============================================================
-- Orders table
-- Purpose:
-- Stores order-level information.
-- ============================================================

CREATE TABLE sales.Orders
(
    OrderID     INT PRIMARY KEY,
    CustomerID  INT NOT NULL,
    EmployeeID  INT NULL,
    OrderDate   DATE NOT NULL,
    OrderStatus VARCHAR(30),
    PaymentMethod VARCHAR(30),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES sales.Employees(EmployeeID)
);
GO



-- ============================================================
-- OrderItems table
-- Purpose:
-- Stores individual products sold in each order.
-- This is our main fact-like transaction table.
-- ============================================================

CREATE TABLE sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Quantity    INT NOT NULL,
    UnitPrice   DECIMAL(12,2) NOT NULL,
    DiscountPct DECIMAL(5,2) NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID)
);
GO



-- ============================================================
-- Insert realistic customer data
-- ============================================================

INSERT INTO sales.Customers
(CustomerID, CustomerName, City, Country, CustomerSegment, SignupDate)
VALUES
(1,'Ahmed Rahman','Dhaka','Bangladesh','VIP','2024-01-15'),
(2,'Fatima Khan','Chittagong','Bangladesh','Regular','2024-02-10'),
(3,'John Smith','Dubai','UAE','VIP','2024-03-05'),
(4,'Sara Ahmed','Kuwait City','Kuwait','Regular','2024-03-20'),
(5,'Mohammed Ali','Dhaka','Bangladesh','Regular','2024-04-12'),
(6,'Nadia Islam','Sylhet','Bangladesh','New','2024-05-01'),
(7,'David Brown','Dubai','UAE','VIP','2024-05-18'),
(8,'Ayesha Karim','Kuwait City','Kuwait','Regular','2024-06-11'),
(9,'Omar Hassan','Doha','Qatar','New','2024-07-09'),
(10,'Emily Wilson','Abu Dhabi','UAE','Regular','2024-08-14');
GO


-- ============================================================
-- Insert department data
-- ============================================================

INSERT INTO sales.Departments
(DepartmentID, DepartmentName)
VALUES
(1,'Sales'),
(2,'Customer Service'),
(3,'Operations'),
(4,'Finance');
GO


-- ============================================================
-- Insert employee data
-- ============================================================

INSERT INTO sales.Employees
(EmployeeID, EmployeeName, DepartmentID, HireDate, Salary)
VALUES
(101,'Rahim Ahmed',1,'2022-01-10',42000),
(102,'Karim Hasan',1,'2023-03-15',38000),
(103,'Nusrat Jahan',2,'2021-07-20',40000),
(104,'David Lee',3,'2022-11-01',45000),
(105,'Maria Khan',1,'2024-02-01',35000),
(106,'James Wilson',4,'2020-05-18',55000);
GO


-- ============================================================
-- Insert product categories
-- ============================================================

INSERT INTO sales.Categories
(CategoryID, CategoryName)
VALUES
(1,'Electronics'),
(2,'Laptops'),
(3,'Mobile Phones'),
(4,'Accessories'),
(5,'Home Appliances');
GO


-- ============================================================
-- Insert product master data
-- ============================================================

INSERT INTO sales.Products
(ProductID, ProductName, CategoryID, UnitPrice, CostPrice, StockQty)
VALUES
(1001,'Dell Laptop',2,850.00,650.00,25),
(1002,'HP Laptop',2,750.00,560.00,30),
(1003,'iPhone 15',3,999.00,780.00,20),
(1004,'Samsung Galaxy S24',3,899.00,690.00,35),
(1005,'Wireless Mouse',4,25.00,12.00,100),
(1006,'Mechanical Keyboard',4,75.00,40.00,60),
(1007,'27 Inch Monitor',1,300.00,210.00,40),
(1008,'Air Conditioner',5,650.00,500.00,15),
(1009,'Refrigerator',5,950.00,750.00,10),
(1010,'USB-C Hub',4,45.00,25.00,80);
GO


-- ============================================================
-- Insert order header data
-- ============================================================

INSERT INTO sales.Orders
(OrderID, CustomerID, EmployeeID, OrderDate, OrderStatus, PaymentMethod)
VALUES
(5001,1,101,'2025-01-05','Completed','Card'),
(5002,2,102,'2025-01-08','Completed','Cash'),
(5003,3,101,'2025-01-15','Completed','Card'),
(5004,4,105,'2025-02-02','Completed','Card'),
(5005,5,102,'2025-02-10','Cancelled','Card'),
(5006,1,101,'2025-02-18','Completed','Bank Transfer'),
(5007,6,105,'2025-03-03','Completed','Cash'),
(5008,7,102,'2025-03-10','Completed','Card'),
(5009,8,101,'2025-03-20','Completed','Card'),
(5010,9,NULL,'2025-04-01','Pending','Cash'),
(5011,10,105,'2025-04-12','Completed','Card'),
(5012,3,101,'2025-04-25','Completed','Bank Transfer');
GO


-- ============================================================
-- Insert order line data
-- Purpose:
-- This table allows us to calculate sales, quantity,
-- average price, discounts, margins, etc.
-- ============================================================

INSERT INTO sales.OrderItems
(OrderItemID, OrderID, ProductID, Quantity, UnitPrice, DiscountPct)
VALUES
(1,5001,1001,1,850,5),
(2,5001,1005,2,25,0),

(3,5002,1003,1,999,10),
(4,5002,1010,1,45,0),

(5,5003,1004,2,899,5),
(6,5003,1006,1,75,0),

(7,5004,1007,2,300,5),
(8,5004,1005,3,25,0),

(9,5005,1008,1,650,0),

(10,5006,1009,1,950,8),
(11,5006,1010,2,45,0),

(12,5007,1005,5,25,0),
(13,5007,1006,2,75,5),

(14,5008,1001,1,850,0),
(15,5008,1007,1,300,10),

(16,5009,1003,1,999,5),
(17,5009,1005,2,25,0),

(18,5010,1002,1,750,0),

(19,5011,1008,1,650,5),
(20,5011,1010,3,45,0),

(21,5012,1004,1,899,10),
(22,5012,1006,2,75,0);
GO

