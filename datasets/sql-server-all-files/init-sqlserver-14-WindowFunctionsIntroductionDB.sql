-- ============================================================
-- Window Functions Introduction Practice Database
-- উদ্দেশ্য:
-- Window Function শেখার জন্য আলাদা একটি বাস্তবসম্মত database তৈরি করা
-- ============================================================

CREATE DATABASE WindowFunctionsIntroductionDB;
GO

USE WindowFunctionsIntroductionDB;
GO

-- Sales-related tables রাখার জন্য schema তৈরি
CREATE SCHEMA sales;
GO

-- ============================================================
-- Customers Table
-- উদ্দেশ্য:
-- Customer সম্পর্কে basic information সংরক্ষণ করা
-- ============================================================

CREATE TABLE sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Gender VARCHAR(10),
    City VARCHAR(50),
    CustomerSegment VARCHAR(30),
    JoinDate DATE
);
GO

-- ============================================================
-- Customers Sample Data
-- Real-world customer-like business data
-- ============================================================

INSERT INTO sales.Customers
(
    CustomerID,
    CustomerName,
    Gender,
    City,
    CustomerSegment,
    JoinDate
)
VALUES
(101, 'Ahmed Hassan', 'Male', 'Kuwait City', 'Premium', '2022-01-15'),
(102, 'Sara Ali', 'Female', 'Hawally', 'Regular', '2022-03-20'),
(103, 'Omar Khalid', 'Male', 'Farwaniyah', 'Premium', '2022-05-10'),
(104, 'Fatima Noor', 'Female', 'Salmiya', 'Regular', '2022-07-18'),
(105, 'Mohammed Rahman', 'Male', 'Jahra', 'VIP', '2021-11-25'),
(106, 'Aisha Karim', 'Female', 'Hawally', 'Premium', '2023-01-12'),
(107, 'Yusuf Ahmed', 'Male', 'Salmiya', 'Regular', '2023-02-14'),
(108, 'Maryam Khan', 'Female', 'Kuwait City', 'VIP', '2021-09-30'),
(109, 'Bilal Hasan', 'Male', 'Farwaniyah', 'Regular', '2023-04-05'),
(110, 'Nadia Rahman', 'Female', 'Jahra', 'Premium', '2022-12-11');
GO


-- ============================================================
-- Products Table
-- উদ্দেশ্য:
-- কোন product কোন category-এর তা সংরক্ষণ করা
-- ============================================================

CREATE TABLE sales.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitPrice DECIMAL(12,2)
);
GO


-- ============================================================
-- Products Sample Data
-- ============================================================

INSERT INTO sales.Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice
)
VALUES
(1, 'Laptop Pro 15', 'Electronics', 850.00),
(2, 'Wireless Mouse', 'Accessories', 25.00),
(3, 'Mechanical Keyboard', 'Accessories', 75.00),
(4, '4K Monitor', 'Electronics', 320.00),
(5, 'USB-C Hub', 'Accessories', 45.00),
(6, 'Office Chair', 'Furniture', 180.00),
(7, 'Standing Desk', 'Furniture', 420.00),
(8, 'Headphones', 'Electronics', 120.00);
GO


-- ============================================================
-- Stores Table
-- উদ্দেশ্য:
-- কোন branch/store থেকে sales হয়েছে তা সংরক্ষণ করা
-- ============================================================

CREATE TABLE sales.Stores
(
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100),
    City VARCHAR(50)
);
GO


-- ============================================================
-- Stores Sample Data
-- ============================================================

INSERT INTO sales.Stores
(
    StoreID,
    StoreName,
    City
)
VALUES
(1, 'Kuwait City Store', 'Kuwait City'),
(2, 'Hawally Store', 'Hawally'),
(3, 'Farwaniyah Store', 'Farwaniyah'),
(4, 'Salmiya Store', 'Salmiya');
GO

-- ============================================================
-- Sales Table
-- উদ্দেশ্য:
-- প্রতিটি sales transaction সংরক্ষণ করা
--
-- এই table-ই Window Functions-এর প্রধান practice table হবে।
-- ============================================================

CREATE TABLE sales.Sales
(
    SalesID INT PRIMARY KEY,
    SalesDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    StoreID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) DEFAULT 0,
    
    -- Calculated column:
    -- Quantity × UnitPrice - Discount
    NetSales AS
    (
        Quantity * UnitPrice - DiscountAmount
    ) PERSISTED,

    CONSTRAINT FK_Sales_Customer
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID),

    CONSTRAINT FK_Sales_Product
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID),

    CONSTRAINT FK_Sales_Store
        FOREIGN KEY (StoreID)
        REFERENCES sales.Stores(StoreID)
);
GO

-- ============================================================
-- Sales Transaction Data
-- উদ্দেশ্য:
-- একই customer-এর multiple orders,
-- একই date-এর multiple sales,
-- বিভিন্ন store/category-তে sales তৈরি করা
--
-- এগুলো Window Function practice করার জন্য গুরুত্বপূর্ণ।
-- ============================================================

INSERT INTO sales.Sales
(
    SalesID,
    SalesDate,
    CustomerID,
    ProductID,
    StoreID,
    Quantity,
    UnitPrice,
    DiscountAmount
)
VALUES
(1001, '2026-01-05', 101, 1, 1, 1, 850, 50),
(1002, '2026-01-07', 102, 2, 2, 2, 25, 0),
(1003, '2026-01-10', 103, 4, 3, 1, 320, 20),
(1004, '2026-01-12', 101, 3, 1, 2, 75, 10),
(1005, '2026-01-15', 104, 6, 4, 1, 180, 0),
(1006, '2026-01-18', 105, 7, 3, 1, 420, 40),
(1007, '2026-01-20', 106, 8, 2, 2, 120, 20),
(1008, '2026-01-22', 107, 5, 4, 3, 45, 5),
(1009, '2026-01-25', 108, 1, 1, 850, 100),
(1010, '2026-01-28', 109, 2, 4, 4, 25, 0),

(1011, '2026-02-02', 101, 4, 1, 1, 320, 0),
(1012, '2026-02-04', 102, 3, 2, 1, 75, 5),
(1013, '2026-02-06', 103, 1, 3, 1, 850, 80),
(1014, '2026-02-08', 104, 8, 4, 1, 120, 0),
(1015, '2026-02-10', 105, 6, 3, 2, 180, 20),
(1016, '2026-02-13', 106, 2, 2, 3, 25, 0),
(1017, '2026-02-15', 107, 5, 4, 2, 45, 5),
(1018, '2026-02-18', 108, 7, 1, 1, 420, 30),
(1019, '2026-02-20', 109, 4, 4, 2, 320, 40),
(1020, '2026-02-25', 110, 1, 2, 1, 850, 50),

(1021, '2026-03-01', 101, 8, 1, 1, 120, 0),
(1022, '2026-03-03', 103, 3, 2, 2, 75, 10),
(1023, '2026-03-05', 105, 1, 3, 1, 850, 100),
(1024, '2026-03-07', 108, 4, 1, 1, 320, 20),
(1025, '2026-03-10', 110, 7, 1, 1, 420, 50);
GO


