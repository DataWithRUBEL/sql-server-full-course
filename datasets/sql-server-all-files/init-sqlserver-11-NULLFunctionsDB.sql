-- =========================================================
-- Create database for NULL Functions practice
-- =========================================================

CREATE DATABASE NullFunctionsDB;
GO

USE NullFunctionsDB;
GO

-- Bronze = Raw source data
CREATE SCHEMA bronze;
GO

-- Silver = Cleansed and standardized data
CREATE SCHEMA silver;
GO

-- Gold = Analytics-ready data
CREATE SCHEMA gold;
GO

-- =========================================================
-- Customer master table
-- NULL values represent incomplete customer information
-- =========================================================

CREATE TABLE bronze.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NULL,
    Phone           VARCHAR(30) NULL,
    Email           VARCHAR(150) NULL,
    Gender          VARCHAR(20) NULL,
    City            VARCHAR(50) NULL,
    CustomerType    VARCHAR(30) NULL,
    JoinDate        DATE NULL
);
GO

-- =========================================================
-- Insert realistic customer data
-- Several NULL values intentionally represent missing data
-- =========================================================

INSERT INTO bronze.Customers
(
    CustomerID,
    CustomerName,
    Phone,
    Email,
    Gender,
    City,
    CustomerType,
    JoinDate
)
VALUES
(1,  'Ahmed Hassan',   '96550010001', 'ahmed@gmail.com',   'Male',   'Kuwait City', 'Regular', '2025-01-15'),
(2,  'Sara Ali',       '96550010002', NULL,               'Female', 'Hawally',     'VIP',     '2025-02-20'),
(3,  'Omar Khalid',    NULL,          'omar@gmail.com',    'Male',   'Farwaniyah',  'Regular', '2025-03-10'),
(4,  'Fatima Noor',    '96550010004', NULL,               NULL,     'Salmiya',     'Regular', '2025-03-18'),
(5,  'John Mathew',    NULL,          NULL,               'Male',   'Hawally',     'Corporate','2025-04-02'),
(6,  'Aisha Rahman',   '96550010006', 'aisha@gmail.com',  'Female', NULL,           'VIP',     '2025-04-15'),
(7,  'Mohammed Saad',  NULL,          'saad@gmail.com',    'Male',   NULL,           NULL,      '2025-05-01'),
(8,  'Lina George',    '96550010008', NULL,               NULL,     'Salmiya',     'Regular', NULL),
(9,  'David Thomas',   NULL,          'david@gmail.com',   'Male',   'Kuwait City', NULL,      '2025-05-20'),
(10, 'Nadia Karim',    '96550010010', NULL,               'Female', NULL,           'Regular', '2025-06-01');
GO

-- =========================================================
-- Restaurant product/menu table
-- NULL CategoryID and CostPrice simulate incomplete source data
-- =========================================================

CREATE TABLE bronze.Products
(
    ProductID       INT PRIMARY KEY,
    ProductName     VARCHAR(100) NOT NULL,
    CategoryID      INT NULL,
    SellingPrice    DECIMAL(10,2) NULL,
    CostPrice       DECIMAL(10,2) NULL,
    IsAvailable     BIT NULL
);
GO

-- =========================================================
-- Insert realistic menu/product data
-- =========================================================

INSERT INTO bronze.Products
VALUES
(101, 'Chicken Burger',       1, 2.750, 1.300, 1),
(102, 'Beef Burger',          1, 3.250, 1.600, 1),
(103, 'Margherita Pizza',     2, 3.500, 1.800, 1),
(104, 'Chicken Pizza',        2, 4.250, NULL,  1),
(105, 'French Fries',         3, 1.250, 0.500, 1),
(106, 'Caesar Salad',         4, NULL,  1.100, 1),
(107, 'Cola',                 5, 0.750, NULL,  1),
(108, 'Fresh Orange Juice',   5, 1.500, 0.700, NULL),
(109, 'Chocolate Cake',       6, 2.000, 0.900, 1),
(110, 'Ice Cream',            NULL, 1.250, 0.600, NULL);
GO


-- =========================================================
-- Restaurant order header table
-- NULL CustomerID means guest/walk-in customer
-- NULL EmployeeID means employee information was not captured
-- =========================================================

CREATE TABLE bronze.Orders
(
    OrderID         INT PRIMARY KEY,
    CustomerID      INT NULL,
    EmployeeID      INT NULL,
    OrderDate       DATETIME2 NULL,
    OrderStatus     VARCHAR(30) NULL,
    DiscountAmount  DECIMAL(10,2) NULL,
    DeliveryFee     DECIMAL(10,2) NULL
);
GO

-- =========================================================
-- Insert realistic restaurant orders
-- =========================================================

INSERT INTO bronze.Orders
VALUES
(1001, 1,    201, '2026-08-01 12:10:00', 'Completed', 0.00,  0.00),
(1002, 2,    202, '2026-08-01 13:20:00', 'Completed', NULL,  0.00),
(1003, NULL, 203, '2026-08-01 18:45:00', 'Completed', 0.50,  NULL),
(1004, 3,    NULL,'2026-08-02 19:10:00', 'Completed', NULL,  1.00),
(1005, 4,    201, '2026-08-02 20:15:00', 'Cancelled', NULL,  NULL),
(1006, 5,    202, '2026-08-03 12:30:00', 'Completed', 1.00,  0.00),
(1007, NULL, NULL,'2026-08-03 14:10:00', 'Completed', NULL,  2.00),
(1008, 6,    203, '2026-08-04 17:50:00', NULL,        0.00,  NULL),
(1009, 7,    201, '2026-08-04 19:30:00', 'Completed', NULL,  0.00),
(1010, 8,    202, '2026-08-05 20:00:00', 'Completed', 0.25,  NULL),
(1011, NULL, 203, '2026-08-05 21:15:00', 'Completed', NULL,  1.50),
(1012, 10,   NULL,'2026-08-06 13:45:00', 'Completed', 0.00,  0.00);
GO

-- =========================================================
-- Order line-level transaction table
-- NULL Quantity/UnitPrice simulate incomplete transaction data
-- =========================================================

CREATE TABLE bronze.OrderItems
(
    OrderItemID     INT PRIMARY KEY,
    OrderID         INT NOT NULL,
    ProductID       INT NOT NULL,
    Quantity        INT NULL,
    UnitPrice       DECIMAL(10,2) NULL
);
GO

-- =========================================================
-- Insert realistic order line data
-- =========================================================

INSERT INTO bronze.OrderItems
VALUES
(1,  1001, 101, 2, 2.750),
(2,  1001, 105, 1, 1.250),
(3,  1002, 103, 1, 3.500),
(4,  1002, 107, 2, 0.750),
(5,  1003, 102, 2, 3.250),
(6,  1003, 105, NULL, 1.250),
(7,  1004, 104, 1, NULL),
(8,  1004, 109, 2, 2.000),
(9,  1006, 101, 1, 2.750),
(10, 1006, 106, 2, NULL),
(11, 1007, 108, 2, 1.500),
(12, 1008, 102, NULL, 3.250),
(13, 1009, 103, 1, 3.500),
(14, 1009, 105, 2, 1.250),
(15, 1010, 109, 1, 2.000),
(16, 1011, 107, 3, 0.750),
(17, 1012, 101, 2, 2.750);
GO

-- =========================================================
-- Payment table
-- NULL payment method/amount represent incomplete payment data
-- =========================================================

CREATE TABLE bronze.Payments
(
    PaymentID       INT PRIMARY KEY,
    OrderID         INT NOT NULL,
    PaymentMethod   VARCHAR(30) NULL,
    PaymentAmount   DECIMAL(10,2) NULL,
    PaymentStatus   VARCHAR(30) NULL
);
GO

-- =========================================================
-- Insert realistic payment data
-- =========================================================

INSERT INTO bronze.Payments
VALUES
(1, 1001, 'KNET',        6.750, 'Paid'),
(2, 1002, 'Cash',        5.000, 'Paid'),
(3, 1003, NULL,          7.250, 'Paid'),
(4, 1004, 'KNET',        NULL,  'Paid'),
(5, 1005, 'Cash',        0.000, 'Refunded'),
(6, 1006, 'Card',        5.250, 'Paid'),
(7, 1007, 'KNET',        NULL,  'Paid'),
(8, 1008, NULL,          6.500, NULL),
(9, 1009, 'Card',        6.000, 'Paid'),
(10,1010, 'Cash',        1.750, 'Paid'),
(11,1011, 'KNET',        3.750, 'Paid'),
(12,1012, NULL,          5.500, 'Paid');
GO

