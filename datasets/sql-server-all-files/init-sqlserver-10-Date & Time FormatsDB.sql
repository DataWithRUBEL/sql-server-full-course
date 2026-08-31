-- ============================================================
-- Create database for Date & Time Format practice
-- ============================================================

CREATE DATABASE DateTimeFormatsDB;
GO

USE DateTimeFormatsDB;
GO

-- ============================================================
-- Create schema for Date & Time format examples
-- ============================================================

CREATE SCHEMA fmt;
GO

-- ============================================================
-- Customers table
-- Stores customer master information
-- ============================================================

CREATE TABLE fmt.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100) NOT NULL,
    Country         VARCHAR(50),
    SignupDate      DATE,
    CreatedAt       DATETIME2(0)
);
GO

-- ============================================================
-- Insert realistic customer data
-- ============================================================

INSERT INTO fmt.Customers
(
    CustomerID,
    CustomerName,
    Country,
    SignupDate,
    CreatedAt
)
VALUES
(1001, 'Ahmed Ali',   'Kuwait',       '2025-01-15', '2025-01-15 09:30:00'),
(1002, 'John Smith',  'United States','2025-02-20', '2025-02-20 14:25:30'),
(1003, 'Sara Khan',   'Bangladesh',   '2025-03-10', '2025-03-10 11:15:45'),
(1004, 'Omar Hassan', 'UAE',          '2025-04-05', '2025-04-05 18:20:10'),
(1005, 'Maria Garcia','Spain',        '2025-05-12', '2025-05-12 08:45:00');
GO

-- ============================================================
-- Orders table
-- Stores validated transactional date/time values
-- ============================================================

CREATE TABLE fmt.Orders
(
    OrderID         INT PRIMARY KEY,
    CustomerID      INT,
    OrderDate       DATE,
    OrderDateTime   DATETIME2(0),
    OrderTime       TIME(0),
    OrderAmount     DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES fmt.Customers(CustomerID)
);
GO

-- ============================================================
-- Insert realistic order transaction data
-- ============================================================

INSERT INTO fmt.Orders
(
    OrderID,
    CustomerID,
    OrderDate,
    OrderDateTime,
    OrderTime,
    OrderAmount
)
VALUES
(50001, 1001, '2026-08-25', '2026-08-25 09:15:20', '09:15:20', 125.50),
(50002, 1002, '2026-08-26', '2026-08-26 14:30:45', '14:30:45', 250.00),
(50003, 1003, '2026-08-27', '2026-08-27 18:45:10', '18:45:10', 89.99),
(50004, 1004, '2026-08-28', '2026-08-28 11:20:30', '11:20:30', 450.75),
(50005, 1005, '2026-08-30', '2026-08-30 16:45:20', '16:45:20', 320.25);
GO


-- ============================================================
-- Raw staging table
-- Source systems often provide dates as VARCHAR strings
-- ============================================================

CREATE TABLE fmt.RawOrderDates
(
    RawOrderID          INT,
    CustomerID          INT,
    RawOrderDate        VARCHAR(50),
    RawOrderDateTime    VARCHAR(50),
    RawOrderTime        VARCHAR(50),
    RawAmount           VARCHAR(50)
);
GO

-- ============================================================
-- Insert raw source data
-- Includes both valid and invalid date/time strings
-- ============================================================

INSERT INTO fmt.RawOrderDates
VALUES
(60001, 1001, '30/08/2026', '2026-08-30T16:45:20', '16:45:20', '150.50'),
(60002, 1002, '2026-08-29', '2026-08-29T10:20:30', '10:20:30', '225.75'),
(60003, 1003, '08/28/2026', '2026-08-28 14:30:00', '14:30:00', '99.99'),
(60004, 1004, '20260827',   '2026-08-27T18:45:10', '18:45:10', '350.00'),
(60005, 1005, '31/02/2026', 'INVALID-DATE',        '25:70:00', 'ABC');
GO
