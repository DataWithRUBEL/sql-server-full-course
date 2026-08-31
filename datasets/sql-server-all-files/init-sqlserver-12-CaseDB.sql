-- ============================================================
-- Create database for CASE practice
-- Purpose:
-- CASE expression এবং business analytics practice করার জন্য
-- একটি আলাদা database তৈরি করা হচ্ছে।
-- ============================================================

CREATE DATABASE CaseDB;
GO

USE CaseDB;
GO

-- ============================================================
-- Create sales schema
-- Purpose:
-- Sales-related tables একটি logical schema-এর মধ্যে রাখা।
-- ============================================================

CREATE SCHEMA sales;
GO


-- ============================================================
-- Create Customer table
-- Purpose:
-- Customer master information সংরক্ষণ করা।
-- CASE দিয়ে customer classification practice করা হবে।
-- ============================================================

CREATE TABLE sales.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    Gender          VARCHAR(20),
    City            VARCHAR(50),
    CustomerType    VARCHAR(30),
    SignupDate      DATE,
    IsActive        BIT,
    CreditLimit     DECIMAL(12,2),
    Email           VARCHAR(100)
);
GO

-- ============================================================
-- Insert realistic customer data
-- Purpose:
-- বিভিন্ন customer type, NULL value এবং active/inactive
-- condition তৈরি করা হয়েছে যাতে CASE practice করা যায়।
-- ============================================================

INSERT INTO sales.Customers
(
    CustomerID,
    CustomerName,
    Gender,
    City,
    CustomerType,
    SignupDate,
    IsActive,
    CreditLimit,
    Email
)
VALUES
(1, 'Ahmed Hassan',   'Male',   'Kuwait City', 'Retail',    '2023-01-15', 1, 5000,  'ahmed@example.com'),
(2, 'Sara Ali',       'Female', 'Hawally',     'Retail',    '2023-03-20', 1, 3000,  'sara@example.com'),
(3, 'Omar Khalid',    'Male',   'Salmiya',     'Corporate', '2022-07-10', 1, 15000, NULL),
(4, 'Fatima Noor',    'Female', 'Farwaniya',   'Retail',    '2024-02-05', 1, 4000,  'fatima@example.com'),
(5, 'Yusuf Ahmed',    'Male',   'Jahra',       'Wholesale', '2021-11-12', 0, 25000, NULL),
(6, 'Mariam Hassan',  'Female', 'Salmiya',     'Corporate', '2023-08-19', 1, 12000,  'mariam@example.com'),
(7, 'Khalid Salem',   'Male',   'Hawally',     'Retail',    '2024-01-22', 1, 2500,  'khalid@example.com'),
(8, 'Nadia Rahman',   'Female', 'Kuwait City', 'Retail',    '2024-04-11', 1, 3500,  'nadia@example.com');
GO


-- ============================================================
-- Create Product table
-- Purpose:
-- Product information এবং price/margin related data রাখা।
-- CASE দিয়ে product classification করা হবে।
-- ============================================================

CREATE TABLE sales.Products
(
    ProductID       INT PRIMARY KEY,
    ProductName     VARCHAR(100) NOT NULL,
    Category        VARCHAR(50),
    UnitPrice       DECIMAL(12,2),
    CostPrice       DECIMAL(12,2),
    StockQty        INT,
    ReorderLevel    INT,
    IsActive        BIT
);
GO

-- ============================================================
-- Insert realistic product data
-- ============================================================

INSERT INTO sales.Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice,
    CostPrice,
    StockQty,
    ReorderLevel,
    IsActive
)
VALUES
(101, 'Laptop Pro 15',      'Electronics', 850.00, 650.00, 25, 10, 1),
(102, 'Wireless Mouse',     'Accessories', 25.00,  12.00, 120, 30, 1),
(103, 'Mechanical Keyboard','Accessories', 75.00,  40.00, 45, 15, 1),
(104, 'Monitor 27 Inch',    'Electronics', 320.00, 220.00, 8, 10, 1),
(105, 'Office Chair',       'Furniture',   180.00, 110.00, 30, 10, 1),
(106, 'USB-C Hub',          'Accessories', 45.00,  20.00, 60, 20, 1),
(107, 'Desk',               'Furniture',   250.00, 160.00, 5, 8, 1),
(108, 'Webcam HD',          'Electronics', 95.00,  55.00, 40, 10, 1);
GO


-- ============================================================
-- Create Orders table
-- Purpose:
-- Customer order header information সংরক্ষণ করা।
-- CASE দিয়ে order status, order value, SLA ইত্যাদি
-- classify করা হবে।
-- ============================================================

CREATE TABLE sales.Orders
(
    OrderID          INT PRIMARY KEY,
    CustomerID       INT,
    OrderDate        DATETIME2,
    ShipDate         DATETIME2 NULL,
    DeliveryDate     DATETIME2 NULL,
    OrderStatus      VARCHAR(30),
    PaymentStatus    VARCHAR(30),
    DiscountPercent  DECIMAL(5,2),
    ShippingCost     DECIMAL(10,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID)
);
GO

-- ============================================================
-- Insert realistic order data
-- NULL ShipDate/DeliveryDate intentionally রাখা হয়েছে
-- যাতে NULL + CASE practice করা যায়।
-- ============================================================

INSERT INTO sales.Orders
(
    OrderID,
    CustomerID,
    OrderDate,
    ShipDate,
    DeliveryDate,
    OrderStatus,
    PaymentStatus,
    DiscountPercent,
    ShippingCost
)
VALUES
(1001, 1, '2026-01-05 10:15', '2026-01-06 09:00', '2026-01-08 14:00', 'Delivered', 'Paid',    5,  3.00),
(1002, 2, '2026-01-08 11:30', '2026-01-09 10:00', '2026-01-12 16:30', 'Delivered', 'Paid',   10,  5.00),
(1003, 3, '2026-01-15 14:10', '2026-01-16 09:30', '2026-01-18 13:00', 'Delivered', 'Paid',   15,  0.00),
(1004, 4, '2026-02-02 09:20', '2026-02-03 10:00', NULL,               'Shipped',   'Paid',    5,  4.00),
(1005, 5, '2026-02-10 15:00', NULL,               NULL,               'Pending',   'Pending', 20, 10.00),
(1006, 6, '2026-02-14 12:30', '2026-02-15 09:00', '2026-02-17 15:00', 'Delivered', 'Paid',   12,  0.00),
(1007, 7, '2026-02-20 16:45', NULL,               NULL,               'Cancelled', 'Failed',   0,  5.00),
(1008, 8, '2026-03-01 10:00', '2026-03-02 09:00', '2026-03-04 11:30', 'Delivered', 'Paid',    8,  3.00),
(1009, 1, '2026-03-05 13:20', '2026-03-06 10:00', NULL,               'Shipped',   'Paid',    5,  3.00),
(1010, 3, '2026-03-10 17:15', NULL,               NULL,               'Pending',   'Pending', 15,  0.00);
GO

-- ============================================================
-- Create OrderItems table
-- Purpose:
-- একটি order-এর individual products সংরক্ষণ করা।
-- Revenue এবং conditional aggregation practice করা হবে।
-- ============================================================

CREATE TABLE sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID     INT,
    ProductID   INT,
    Quantity    INT,
    UnitPrice   DECIMAL(12,2),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID)
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
(1,  1001, 101, 1, 850),
(2,  1001, 102, 2, 25),

(3,  1002, 104, 1, 320),
(4,  1002, 106, 2, 45),

(5,  1003, 101, 2, 850),
(6,  1003, 103, 1, 75),

(7,  1004, 105, 2, 180),
(8,  1004, 102, 1, 25),

(9,  1005, 107, 1, 250),
(10, 1005, 105, 3, 180),

(11, 1006, 104, 2, 320),
(12, 1006, 108, 1, 95),

(13, 1007, 102, 2, 25),

(14, 1008, 101, 1, 850),
(15, 1008, 106, 3, 45),

(16, 1009, 103, 2, 75),
(17, 1009, 108, 2, 95),

(18, 1010, 107, 2, 250),
(19, 1010, 102, 5, 25);
GO




