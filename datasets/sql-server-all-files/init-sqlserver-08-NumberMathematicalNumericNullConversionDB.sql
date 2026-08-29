-- Create the practice database
CREATE DATABASE NumberMathematicalNumericNullConversionDB;
GO

-- Switch to the practice database
USE NumberMathematicalNumericNullConversionDB;
GO

-- Create a dedicated schema for the project
CREATE SCHEMA analytics;
GO


-- Create customer master data
CREATE TABLE analytics.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50),
    CustomerSegment VARCHAR(30)
);
GO


-- Insert realistic customer data
INSERT INTO analytics.Customers
(CustomerID, CustomerName, Country, CustomerSegment)
VALUES
(1001, 'Ahmed Ali', 'Kuwait', 'Premium'),
(1002, 'Mohammed Hassan', 'Kuwait', 'Standard'),
(1003, 'John Smith', 'USA', 'Premium'),
(1004, 'Sarah Wilson', 'UK', 'Standard'),
(1005, 'David Brown', 'Canada', 'Premium'),
(1006, 'Fatima Noor', 'Kuwait', 'Standard'),
(1007, 'Omar Khalid', 'UAE', 'Premium'),
(1008, 'Emily Davis', 'USA', 'Standard'),
(1009, 'Daniel Lee', 'Australia', 'Premium'),
(1010, 'Sophia Taylor', 'UK', 'Standard');
GO


-- Create product master table
CREATE TABLE analytics.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50),
    UnitCost DECIMAL(12,2),
    UnitPrice DECIMAL(12,2),
    WeightKG DECIMAL(10,3),
    Rating FLOAT,
    RiskScore REAL,
    StockQuantity INT,
    LifetimeUnits BIGINT
);
GO


-- Insert realistic product data
INSERT INTO analytics.Products
(ProductID, ProductName, Category, UnitCost, UnitPrice,
 WeightKG, Rating, RiskScore, StockQuantity, LifetimeUnits)
VALUES
(101, 'Premium Laptop', 'Electronics', 650.00, 899.99, 1.850, 4.70, 0.12, 120, 250000),
(102, 'Office Monitor', 'Electronics', 180.00, 279.99, 4.500, 4.40, 0.18, 250, 180000),
(103, 'Wireless Mouse', 'Accessories', 12.00, 24.99, 0.120, 4.20, 0.05, 500, 750000),
(104, 'Mechanical Keyboard', 'Accessories', 45.00, 89.99, 0.850, 4.60, 0.08, 300, 420000),
(105, 'USB-C Hub', 'Accessories', 22.00, 49.99, 0.250, 4.30, 0.15, 400, 310000),
(106, 'Office Chair', 'Furniture', 110.00, 199.99, 15.500, 4.10, 0.21, 80, 95000),
(107, 'Desk Lamp', 'Furniture', 18.00, 39.99, 1.200, 4.00, 0.10, 150, 130000),
(108, 'Web Camera', 'Electronics', 35.00, 79.99, 0.350, 4.50, 0.09, 200, 270000),
(109, 'External SSD', 'Electronics', 70.00, 129.99, 0.080, 4.80, 0.06, 180, 390000),
(110, 'Laptop Stand', 'Accessories', 28.00, 59.99, 1.100, 4.30, 0.11, 220, 210000);
GO


-- Create sales transaction table
CREATE TABLE analytics.Sales
(
    SalesID BIGINT PRIMARY KEY,
    SalesDate DATE NOT NULL,
    CustomerID INT,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    DiscountPercent DECIMAL(5,2),
    ShippingCost DECIMAL(12,2),

    FOREIGN KEY (CustomerID)
        REFERENCES analytics.Customers(CustomerID),

    FOREIGN KEY (ProductID)
        REFERENCES analytics.Products(ProductID)
);
GO

-- Insert realistic retail sales transactions
INSERT INTO analytics.Sales
(SalesID, SalesDate, CustomerID, ProductID, Quantity,
 UnitPrice, DiscountPercent, ShippingCost)
VALUES
(500001, '2026-01-05', 1001, 101, 2, 899.99, 5.00, 15.00),
(500002, '2026-01-08', 1002, 103, 10, 24.99, 0.00, 8.00),
(500003, '2026-01-12', 1003, 102, 3, 279.99, 10.00, 20.00),
(500004, '2026-01-18', 1004, 104, 5, 89.99, 5.00, 12.00),
(500005, '2026-02-02', 1005, 109, 4, 129.99, 8.00, 10.00),
(500006, '2026-02-05', 1006, 106, 2, 199.99, 0.00, 25.00),
(500007, '2026-02-10', 1007, 108, 6, 79.99, 5.00, 15.00),
(500008, '2026-02-15', 1008, 105, 8, 49.99, 3.00, 10.00),
(500009, '2026-03-01', 1009, 107, 7, 39.99, 0.00, 12.00),
(500010, '2026-03-07', 1010, 110, 5, 59.99, 5.00, 10.00),
(500011, '2026-03-12', 1001, 101, 1, 899.99, 10.00, 15.00),
(500012, '2026-03-20', 1003, 109, 3, 129.99, 5.00, 10.00);
GO


-- Create monthly sales target table
CREATE TABLE analytics.Targets
(
    TargetMonth DATE PRIMARY KEY,
    SalesTarget DECIMAL(14,2),
    ProfitTarget DECIMAL(14,2)
);
GO

-- Insert monthly business targets
INSERT INTO analytics.Targets
(TargetMonth, SalesTarget, ProfitTarget)
VALUES
('2026-01-01', 5000.00, 1200.00),
('2026-02-01', 6000.00, 1500.00),
('2026-03-01', 7500.00, 1900.00);
GO



-- Create raw source table where numeric values arrive as text
CREATE TABLE analytics.ETL_Source_Sales
(
    SourceID INT IDENTITY(1,1),
    SalesID VARCHAR(30),
    Quantity VARCHAR(30),
    UnitPrice VARCHAR(30),
    Discount VARCHAR(30),
    SourceAmount VARCHAR(50)
);
GO

-- Insert realistic source-system data including bad values
INSERT INTO analytics.ETL_Source_Sales
(SalesID, Quantity, UnitPrice, Discount, SourceAmount)
VALUES
('500001', '2', '899.99', '5', '1799.98'),
('500002', '10', '24.99', '0', '249.90'),
('500003', '3', '279.99', '10', '839.97'),
('500004', '5', '89.99', '5', '449.95'),
('500005', '4', '129.99', '8', '519.96'),
('500006', '2', '199.99', '0', '399.98'),
('500007', '6', '79.99', '5', '479.94'),
('500008', '8', '49.99', '3', '399.92'),
('500009', '7', '39.99', '0', '279.93'),
('500010', '5', '59.99', '5', '299.95'),
('500011', 'INVALID', '899.99', '10', 'INVALID'),
('500012', '3', 'BAD_PRICE', '5', '389.97'),
('500013', '-5', '100.00', '0', '-500.00'),
('500014', '0', '250.00', '0', '0');
GO

