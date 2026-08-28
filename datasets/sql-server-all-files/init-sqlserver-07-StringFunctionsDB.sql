-- =========================================================
-- Create database for String Functions practice
-- =========================================================

IF DB_ID('StringFunctionsDB') IS NULL
BEGIN
    CREATE DATABASE StringFunctionsDB;
END;
GO

USE StringFunctionsDB;
GO


-- =========================================================
-- Create schema for practice tables
-- =========================================================

IF NOT EXISTS (
    SELECT 1
    FROM sys.schemas
    WHERE name = 'dbo'
)
BEGIN
    EXEC('CREATE SCHEMA dbo');
END;
GO


-- =========================================================
-- Create Customers table
-- Contains realistic dirty customer data
-- =========================================================

DROP TABLE IF EXISTS dbo.Customers;
GO

CREATE TABLE dbo.Customers
(
    customer_id       INT,
    first_name        VARCHAR(100),
    last_name         VARCHAR(100),
    email             VARCHAR(150),
    phone             VARCHAR(50),
    city              VARCHAR(100),
    country           VARCHAR(100),
    customer_status   VARCHAR(30),
    tags              VARCHAR(300),
    created_date      DATE
);
GO

-- =========================================================
-- Insert realistic customer source data
-- Notice intentional spaces, inconsistent casing,
-- phone formatting and NULL values
-- =========================================================

INSERT INTO dbo.Customers
(
    customer_id,
    first_name,
    last_name,
    email,
    phone,
    city,
    country,
    customer_status,
    tags,
    created_date
)
VALUES
(1,  '  John  ',     'Smith ',       ' JOHN.SMITH@GMAIL.COM ', '+880-1711-123456', ' Dhaka ',       'Bangladesh', 'Active',   'VIP,Online,Newsletter', '2026-01-05'),
(2,  'sarah',        'JONES',        'sarah.jones@gmail.com', '+1-212-555-0198',  'New York',      'USA',        'ACTIVE',   'Online,Newsletter',     '2026-01-10'),
(3,  '  Ahmed',      ' Rahman ',     ' AHMED.RAHMAN@EMAIL.COM', '01711 987654',   'Dhaka',         'Bangladesh', 'active',   'VIP,Wholesale',         '2026-01-15'),
(4,  'Maria ',       'Garcia',       'maria.garcia@gmail.com', '+34-600-123456',  ' Madrid ',      'Spain',       'Inactive', 'Online',                '2026-02-01'),
(5,  'DAVID',        'brown ',       'DAVID.BROWN@EMAIL.COM',   '+44-7700-900123', ' London',       'UK',          'ACTIVE',   'VIP,Online',             '2026-02-05'),
(6,  '  Fatima ',    'ALI',          NULL,                     '050-123-4567',    ' Dubai ',       'UAE',         'Active',   'Online,VIP',             '2026-02-08'),
(7,  'Michael',      'Wilson',       'michael.wilson@gmail.com','+1-415-555-0101', 'San Francisco', 'USA',        NULL,        'Newsletter',             '2026-02-12'),
(8,  'anna',         'Müller',       'ANNA.MULLER@EMAIL.COM',   '+49-151-1234567', ' Berlin ',      'Germany',     'ACTIVE',   'VIP,Online',             '2026-02-20'),
(9,  'Mohammed ',    'Hassan',       'mohammed.hassan@gmail.com','965-5555-1234',   ' Kuwait City ', 'Kuwait',      'Active',   'VIP,Online',             '2026-02-25'),
(10, 'Emily',        'Taylor',       'emily.taylor@gmail.com',  NULL,              'London',        'UK',          'Inactive', NULL,                    '2026-03-01');
GO


-- =========================================================
-- Create Products table
-- =========================================================

DROP TABLE IF EXISTS dbo.Products;
GO

CREATE TABLE dbo.Products
(
    product_id       INT,
    product_code     VARCHAR(50),
    product_name     VARCHAR(150),
    category         VARCHAR(100),
    brand            VARCHAR(100),
    sku              VARCHAR(100),
    product_tags     VARCHAR(300)
);
GO


-- =========================================================
-- Insert realistic product data
-- =========================================================

INSERT INTO dbo.Products
VALUES
(101, ' LAP-001 ', 'Dell Latitude 5520', 'Electronics', 'Dell', 'DELL-LAP-001', 'Laptop,Office,Business'),
(102, ' PHN-002 ', 'iPhone 15 Pro', 'Electronics', 'Apple', 'APPLE-PHN-002', 'Phone,Premium,Mobile'),
(103, ' MON-003 ', 'Samsung 27 Inch Monitor', 'Electronics', 'Samsung', 'SAM-MON-003', 'Monitor,Office'),
(104, ' CHR-004 ', 'Ergonomic Office Chair', 'Furniture', 'IKEA', 'IKEA-CHR-004', 'Chair,Office,Furniture'),
(105, ' KEY-005 ', 'Mechanical Keyboard', 'Accessories', 'Logitech', 'LOG-KEY-005', 'Keyboard,Gaming,Office'),
(106, ' MOU-006 ', 'Wireless Mouse', 'Accessories', 'Logitech', 'LOG-MOU-006', 'Mouse,Wireless,Office'),
(107, ' BAG-007 ', 'Business Laptop Bag', 'Accessories', 'HP', 'HP-BAG-007', 'Bag,Laptop,Travel');
GO



-- =========================================================
-- Create Orders table
-- =========================================================

DROP TABLE IF EXISTS dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
    order_id        INT,
    customer_id     INT,
    order_reference VARCHAR(100),
    sales_channel   VARCHAR(50),
    payment_method  VARCHAR(50)
);
GO


-- =========================================================
-- Insert realistic order data
-- =========================================================

INSERT INTO dbo.Orders
VALUES
(1001, 1,  ' ORD-2026-0001 ', 'ONLINE', 'Credit Card'),
(1002, 2,  'ORD-2026-0002',    'Online', 'PAYPAL'),
(1003, 3,  ' ORD-2026-0003',  'STORE',  'Cash'),
(1004, 4,  'ORD-2026-0004 ',   'Online', 'Credit Card'),
(1005, 5,  'ORD-2026-0005',    'STORE',  'Cash'),
(1006, 6,  'ORD-2026-0006',    'ONLINE', NULL),
(1007, 7,  ' ORD-2026-0007',   'Online', 'Credit Card');
GO


-- =========================================================
-- Create OrderItems table
-- =========================================================

DROP TABLE IF EXISTS dbo.OrderItems;
GO

CREATE TABLE dbo.OrderItems
(
    order_item_id INT,
    order_id      INT,
    product_id    INT,
    quantity      INT,
    unit_price    DECIMAL(12,2)
);
GO


-- =========================================================
-- Insert order item data
-- =========================================================

INSERT INTO dbo.OrderItems
VALUES
(1, 1001, 101, 1, 850.00),
(2, 1001, 106, 2, 25.00),
(3, 1002, 102, 1, 1199.00),
(4, 1003, 103, 2, 300.00),
(5, 1004, 104, 1, 450.00),
(6, 1005, 105, 1, 120.00),
(7, 1006, 107, 1, 80.00),
(8, 1007, 106, 3, 25.00);
GO


-- =========================================================
-- Create Employees table
-- =========================================================

DROP TABLE IF EXISTS dbo.Employees;
GO

CREATE TABLE dbo.Employees
(
    employee_id INT,
    full_name    VARCHAR(150),
    email        VARCHAR(150),
    department   VARCHAR(100),
    job_title    VARCHAR(100)
);
GO

-- =========================================================
-- Insert realistic employee data
-- =========================================================

INSERT INTO dbo.Employees
VALUES
(1, 'John Smith',       'john.smith@company.com',       'Data & Analytics', 'Data Analyst'),
(2, 'Sarah Jones',      'sarah.jones@company.com',      'Sales',            'Sales Executive'),
(3, 'Ahmed Rahman',     'ahmed.rahman@company.com',     'Data & Analytics', 'Data Engineer'),
(4, 'Maria Garcia',     'maria.garcia@company.com',     'HR',               'HR Specialist'),
(5, 'David Brown',      'david.brown@company.com',      'Finance',          'Financial Analyst'),
(6, 'Michael Wilson',   'michael.wilson@company.com',   'IT',               'System Administrator');
GO


