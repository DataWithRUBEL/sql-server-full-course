-- =========================================================
-- Create Database for Date & Time Functions Practice
-- =========================================================

CREATE DATABASE DateTimeFunctionsDB;
GO

-- =========================================================
-- Switch to the new database
-- =========================================================

USE DateTimeFunctionsDB;
GO

-- =========================================================
-- Create schema for Date & Time practice
-- =========================================================

CREATE SCHEMA dt;
GO


-- =========================================================
-- Department master table
-- Used for HR and employee analysis
-- =========================================================

CREATE TABLE dt.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO


-- =========================================================
-- Insert realistic department data
-- =========================================================

INSERT INTO dt.Departments
(
    DepartmentID,
    DepartmentName
)
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Human Resources'),
(5, 'Operations');
GO


-- =========================================================
-- Employee master table
-- Demonstrates different SQL Server date/time data types
-- =========================================================

CREATE TABLE dt.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,

    -- Employee joining date
    HireDate DATE NOT NULL,

    -- Employee birth date
    BirthDate DATE NULL,

    -- Employee shift start time
    ShiftStartTime TIME(0) NULL,

    -- Original system-created timestamp
    CreatedDateTime DATETIME NULL,

    -- High precision employee record timestamp
    LastModifiedDateTime DATETIME2(7) NULL,

    -- Legacy HR timestamp
    HRUpdatedTime SMALLDATETIME NULL,

    -- Timestamp with timezone information
    EmployeeCreatedOffset DATETIMEOFFSET(7) NULL,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES dt.Departments(DepartmentID)
);
GO

-- =========================================================
-- Insert realistic employee records
-- Dates are representative business data
-- =========================================================

INSERT INTO dt.Employees
(
    EmployeeID,
    EmployeeName,
    DepartmentID,
    HireDate,
    BirthDate,
    ShiftStartTime,
    CreatedDateTime,
    LastModifiedDateTime,
    HRUpdatedTime,
    EmployeeCreatedOffset
)
VALUES
(101, 'Ahmed Hassan', 1, '2019-02-15', '1992-06-12',
 '08:00:00', '2019-02-15 08:15:30',
 '2026-08-20 10:15:30.1234567',
 '2026-08-20 10:15',
 '2019-02-15 08:15:30 +03:00'),

(102, 'Sara Ali', 2, '2020-05-10', '1995-09-25',
 '09:00:00', '2020-05-10 09:05:10',
 '2026-08-21 11:25:45.9876543',
 '2026-08-21 11:26',
 '2020-05-10 09:05:10 +03:00'),

(103, 'Mohammed Khan', 3, '2018-01-20', '1989-03-18',
 '08:30:00', '2018-01-20 08:45:20',
 '2026-08-22 12:35:22.1111111',
 '2026-08-22 12:35',
 '2018-01-20 08:45:20 +03:00'),

(104, 'Fatima Noor', 4, '2021-07-05', '1997-11-04',
 '09:00:00', '2021-07-05 09:10:40',
 '2026-08-23 13:20:15.2222222',
 '2026-08-23 13:20',
 '2021-07-05 09:10:40 +03:00'),

(105, 'Omar Saleh', 5, '2022-03-12', '1994-01-30',
 '07:30:00', '2022-03-12 07:40:30',
 '2026-08-24 14:10:30.3333333',
 '2026-08-24 14:10',
 '2022-03-12 07:40:30 +03:00');
GO


-- =========================================================
-- Customer master table
-- Used for customer/order date analysis
-- =========================================================

CREATE TABLE dt.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    RegistrationDate DATE NOT NULL,
    RegistrationTime TIME(0) NULL,
    CreatedAt DATETIME2(7) NOT NULL
);
GO

-- =========================================================
-- Insert realistic customer records
-- =========================================================

INSERT INTO dt.Customers
(
    CustomerID,
    CustomerName,
    Country,
    RegistrationDate,
    RegistrationTime,
    CreatedAt
)
VALUES
(1001, 'Ali Rahman', 'Kuwait', '2024-01-15', '09:30:00',
 '2024-01-15 09:30:15.1234567'),

(1002, 'John Smith', 'Kuwait', '2024-02-20', '11:15:00',
 '2024-02-20 11:15:30.2345678'),

(1003, 'Fatima Ahmed', 'Saudi Arabia', '2024-03-10', '14:20:00',
 '2024-03-10 14:20:45.3456789'),

(1004, 'David Wilson', 'UAE', '2024-04-05', '16:40:00',
 '2024-04-05 16:40:10.4567890'),

(1005, 'Mary Joseph', 'Kuwait', '2024-05-18', '10:10:00',
 '2024-05-18 10:10:25.5678901'),

(1006, 'Hassan Omar', 'Qatar', '2024-06-22', '13:30:00',
 '2024-06-22 13:30:50.6789012');
GO

-- =========================================================
-- Product master table
-- Used to calculate sales
-- =========================================================

CREATE TABLE dt.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL
);
GO


-- =========================================================
-- Insert realistic product data
-- =========================================================

INSERT INTO dt.Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice
)
VALUES
(101, 'Wireless Mouse', 'Accessories', 10.00),
(102, 'Keyboard', 'Accessories', 15.00),
(103, 'USB Cable', 'Accessories', 8.00),
(104, 'Laptop Bag', 'Bags', 25.00),
(105, 'Office Chair', 'Furniture', 120.00),
(106, 'Monitor', 'Electronics', 180.00);
GO



-- =========================================================
-- Sales order table
-- Demonstrates DATE, DATETIME2 and DATETIMEOFFSET
-- =========================================================

CREATE TABLE dt.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,

    -- Business order date
    OrderDate DATE NOT NULL,

    -- Time portion of order
    OrderTime TIME(0) NOT NULL,

    -- Order timestamp
    OrderDateTime DATETIME2(7) NOT NULL,

    -- Order timestamp including timezone
    OrderDateTimeOffset DATETIMEOFFSET(7) NOT NULL,

    -- Shipment date
    ShipDate DATE NULL,

    -- Delivery timestamp
    DeliveryDateTime DATETIME2(7) NULL,

    -- Legacy timestamp
    LegacyOrderTime SMALLDATETIME NULL,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES dt.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES dt.Employees(EmployeeID)
);
GO


-- =========================================================
-- Insert realistic sales order data
-- =========================================================

INSERT INTO dt.Orders
(
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderTime,
    OrderDateTime,
    OrderDateTimeOffset,
    ShipDate,
    DeliveryDateTime,
    LegacyOrderTime
)
VALUES
(5001, 1001, 101, '2026-01-05', '09:15:00',
 '2026-01-05 09:15:30.1234567',
 '2026-01-05 09:15:30.1234567 +03:00',
 '2026-01-06',
 '2026-01-08 14:30:00',
 '2026-01-05 09:16'),

(5002, 1002, 102, '2026-01-15', '13:20:00',
 '2026-01-15 13:20:15.2234567',
 '2026-01-15 13:20:15.2234567 +03:00',
 '2026-01-16',
 '2026-01-18 16:10:00',
 '2026-01-15 13:20'),

(5003, 1003, 103, '2026-02-10', '10:45:00',
 '2026-02-10 10:45:45.3234567',
 '2026-02-10 10:45:45.3234567 +03:00',
 '2026-02-11',
 '2026-02-14 11:30:00',
 '2026-02-10 10:46'),

(5004, 1004, 101, '2026-02-28', '17:30:00',
 '2026-02-28 17:30:20.4234567',
 '2026-02-28 17:30:20.4234567 +03:00',
 '2026-03-01',
 '2026-03-04 12:00:00',
 '2026-02-28 17:30'),

(5005, 1005, 104, '2026-03-12', '08:10:00',
 '2026-03-12 08:10:10.5234567',
 '2026-03-12 08:10:10.5234567 +03:00',
 '2026-03-13',
 '2026-03-15 15:45:00',
 '2026-03-12 08:10'),

(5006, 1006, 105, '2026-04-20', '19:25:00',
 '2026-04-20 19:25:55.6234567',
 '2026-04-20 19:25:55.6234567 +03:00',
 '2026-04-21',
 '2026-04-25 17:20:00',
 '2026-04-20 19:26'),

(5007, 1001, 102, '2026-05-05', '11:00:00',
 '2026-05-05 11:00:35.7234567',
 '2026-05-05 11:00:35.7234567 +03:00',
 '2026-05-06',
 NULL,
 '2026-05-05 11:01'),

(5008, 1002, 103, '2026-06-18', '15:40:00',
 '2026-06-18 15:40:25.8234567',
 '2026-06-18 15:40:25.8234567 +03:00',
 '2026-06-19',
 '2026-06-23 10:15:00',
 '2026-06-18 15:40'),

(5009, 1003, 104, '2026-07-25', '12:30:00',
 '2026-07-25 12:30:50.9234567',
 '2026-07-25 12:30:50.9234567 +03:00',
 '2026-07-26',
 '2026-07-29 13:30:00',
 '2026-07-25 12:31'),

(5010, 1004, 105, '2026-08-10', '18:15:00',
 '2026-08-10 18:15:05.1234567',
 '2026-08-10 18:15:05.1234567 +03:00',
 '2026-08-11',
 '2026-08-14 16:45:00',
 '2026-08-10 18:15');
GO

-- =========================================================
-- Order line items
-- Used for sales analysis
-- =========================================================

CREATE TABLE dt.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES dt.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES dt.Products(ProductID)
);
GO

-- =========================================================
-- Insert realistic order item data
-- =========================================================

INSERT INTO dt.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1, 5001, 101, 2, 10.00),
(2, 5001, 104, 1, 25.00),
(3, 5002, 102, 2, 15.00),
(4, 5002, 106, 1, 180.00),
(5, 5003, 103, 5, 8.00),
(6, 5003, 105, 1, 120.00),
(7, 5004, 101, 3, 10.00),
(8, 5005, 106, 2, 180.00),
(9, 5006, 105, 2, 120.00),
(10, 5007, 104, 2, 25.00),
(11, 5008, 102, 3, 15.00),
(12, 5009, 106, 1, 180.00),
(13, 5010, 101, 4, 10.00);
GO


-- =========================================================
-- Employee attendance table
-- Used for working-hour and time analysis
-- =========================================================

CREATE TABLE dt.EmployeeAttendance
(
    AttendanceID INT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    CheckInTime DATETIME2(7) NULL,
    CheckOutTime DATETIME2(7) NULL,

    CONSTRAINT FK_Attendance_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES dt.Employees(EmployeeID)
);
GO

-- =========================================================
-- Insert realistic attendance data
-- NULL CheckOutTime represents an open attendance record
-- =========================================================

INSERT INTO dt.EmployeeAttendance
(
    AttendanceID,
    EmployeeID,
    AttendanceDate,
    CheckInTime,
    CheckOutTime
)
VALUES
(1, 101, '2026-08-24',
 '2026-08-24 08:02:15.1234567',
 '2026-08-24 17:05:20.1234567'),

(2, 102, '2026-08-24',
 '2026-08-24 09:10:10.1234567',
 '2026-08-24 18:00:15.1234567'),

(3, 103, '2026-08-24',
 '2026-08-24 08:25:30.1234567',
 '2026-08-24 17:15:40.1234567'),

(4, 104, '2026-08-24',
 '2026-08-24 09:05:20.1234567',
 NULL),

(5, 105, '2026-08-24',
 '2026-08-24 07:35:00.1234567',
 '2026-08-24 16:30:00.1234567');
GO

-- =========================================================
-- System event log
-- Useful for ETL, pipeline monitoring and audit analysis
-- =========================================================

CREATE TABLE dt.SystemEvents
(
    EventID BIGINT PRIMARY KEY,
    EventType VARCHAR(50) NOT NULL,
    EventMessage VARCHAR(500) NOT NULL,
    EventTimeUTC DATETIME2(7) NOT NULL,
    EventTimeOffset DATETIMEOFFSET(7) NOT NULL
);
GO

-- =========================================================
-- Insert realistic system/ETL event data
-- Times are stored in UTC and with offset
-- =========================================================

INSERT INTO dt.SystemEvents
(
    EventID,
    EventType,
    EventMessage,
    EventTimeUTC,
    EventTimeOffset
)
VALUES
(900001, 'ETL_START',
 'Daily sales ETL started',
 '2026-08-24 00:00:00.1234567',
 '2026-08-24 00:00:00.1234567 +00:00'),

(900002, 'ETL_END',
 'Daily sales ETL completed',
 '2026-08-24 00:12:30.4567890',
 '2026-08-24 00:12:30.4567890 +00:00'),

(900003, 'LOGIN',
 'Employee login detected',
 '2026-08-24 05:02:15.1234567',
 '2026-08-24 05:02:15.1234567 +00:00'),

(900004, 'ETL_START',
 'Customer ETL started',
 '2026-08-25 00:00:00.1234567',
 '2026-08-25 00:00:00.1234567 +00:00'),

(900005, 'ETL_END',
 'Customer ETL completed',
 '2026-08-25 00:08:40.6543210',
 '2026-08-25 00:08:40.6543210 +00:00');
GO
