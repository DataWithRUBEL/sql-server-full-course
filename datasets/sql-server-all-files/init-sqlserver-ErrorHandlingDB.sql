-- =========================================================
-- Create Database for SQL Server Error Handling Practice
-- =========================================================

CREATE DATABASE ErrorHandlingDB;
GO

USE ErrorHandlingDB;
GO

-- =========================================================
-- Create schemas for different business areas
-- =========================================================

CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA etl;
GO



-- =========================================================
-- Customer master table
-- =========================================================

CREATE TABLE sales.Customers
(
    CustomerID INT IDENTITY(1,1)
        CONSTRAINT PK_Customers PRIMARY KEY,

    CustomerName VARCHAR(100) NOT NULL,

    Email VARCHAR(150) NULL,

    Country VARCHAR(50) NOT NULL,

    IsActive BIT NOT NULL
        CONSTRAINT DF_Customers_IsActive DEFAULT 1,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Customers_CreatedAt DEFAULT SYSDATETIME()
);
GO


-- =========================================================
-- Product master table
-- =========================================================

CREATE TABLE sales.Products
(
    ProductID INT IDENTITY(1,1)
        CONSTRAINT PK_Products PRIMARY KEY,

    ProductName VARCHAR(100) NOT NULL,

    Category VARCHAR(50) NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    StockQty INT NOT NULL
);
GO


-- =========================================================
-- Order header table
-- =========================================================

CREATE TABLE sales.Orders
(
    OrderID INT IDENTITY(1001,1)
        CONSTRAINT PK_Orders PRIMARY KEY,

    CustomerID INT NOT NULL,

    OrderDate DATE NOT NULL,

    OrderStatus VARCHAR(20) NOT NULL,

    TotalAmount DECIMAL(14,2) NOT NULL
        CONSTRAINT DF_Orders_TotalAmount DEFAULT 0,

    CreatedAt DATETIME2 NOT NULL
        CONSTRAINT DF_Orders_CreatedAt DEFAULT SYSDATETIME(),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID)
);
GO

-- =========================================================
-- Order line-item table
-- =========================================================

CREATE TABLE sales.OrderItems
(
    OrderItemID INT IDENTITY(1,1)
        CONSTRAINT PK_OrderItems PRIMARY KEY,

    OrderID INT NOT NULL,

    ProductID INT NOT NULL,

    Quantity INT NOT NULL,

    UnitPrice DECIMAL(12,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES sales.Products(ProductID),

    CONSTRAINT CK_OrderItems_Quantity
        CHECK (Quantity > 0)
);
GO



-- =========================================================
-- Employee table
-- =========================================================

CREATE TABLE hr.Employees
(
    EmployeeID INT IDENTITY(1,1)
        CONSTRAINT PK_Employees PRIMARY KEY,

    EmployeeName VARCHAR(100) NOT NULL,

    Department VARCHAR(50) NOT NULL,

    Salary DECIMAL(12,2) NOT NULL,

    ManagerID INT NULL
);
GO


-- =========================================================
-- ETL batch execution tracking table
-- =========================================================

CREATE TABLE etl.BatchLog
(
    BatchID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_BatchLog PRIMARY KEY,

    PipelineName VARCHAR(100) NOT NULL,

    StartTime DATETIME2 NOT NULL,

    EndTime DATETIME2 NULL,

    Status VARCHAR(20) NOT NULL,

    RowsProcessed INT NULL,

    ErrorCount INT NOT NULL DEFAULT 0
);
GO


-- =========================================================
-- Centralized error logging table
-- =========================================================

CREATE TABLE etl.ErrorLog
(
    ErrorLogID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_ErrorLog PRIMARY KEY,

    BatchID BIGINT NULL,

    ErrorDateTime DATETIME2 NOT NULL
        CONSTRAINT DF_ErrorLog_DateTime DEFAULT SYSDATETIME(),

    ErrorNumber INT NULL,

    ErrorSeverity INT NULL,

    ErrorState INT NULL,

    ErrorProcedure SYSNAME NULL,

    ErrorLine INT NULL,

    ErrorMessage NVARCHAR(4000) NULL,

    ErrorCategory VARCHAR(50) NULL,

    ErrorSource VARCHAR(100) NULL
);
GO



-- =========================================================
-- ETL staging table
-- Represents raw incoming order data
-- =========================================================

CREATE TABLE etl.StagingOrders
(
    StagingID BIGINT IDENTITY(1,1)
        CONSTRAINT PK_StagingOrders PRIMARY KEY,

    CustomerID VARCHAR(50),

    ProductID VARCHAR(50),

    Quantity VARCHAR(50),

    UnitPrice VARCHAR(50),

    OrderDate VARCHAR(50),

    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO


-- =========================================================
-- Insert sample customers
-- =========================================================

INSERT INTO sales.Customers
(
    CustomerName,
    Email,
    Country
)
VALUES
('Ahmed Trading', 'ahmed@example.com', 'Kuwait'),
('ABC Retail', 'abc@example.com', 'Kuwait'),
('Global Mart', 'global@example.com', 'UAE'),
('Dhaka Electronics', 'dhaka@example.com', 'Bangladesh');
GO


-- =========================================================
-- Insert sample products
-- =========================================================

INSERT INTO sales.Products
(
    ProductName,
    Category,
    UnitPrice,
    StockQty
)
VALUES
('Laptop', 'Electronics', 850.00, 50),
('Monitor', 'Electronics', 250.00, 100),
('Keyboard', 'Accessories', 45.00, 200),
('Mouse', 'Accessories', 25.00, 300);
GO


-- =========================================================
-- Insert sample employees
-- =========================================================

INSERT INTO hr.Employees
(
    EmployeeName,
    Department,
    Salary
)
VALUES
('John Smith', 'Sales', 4500),
('David Lee', 'IT', 6000),
('Sarah Khan', 'Finance', 5500),
('Ali Hassan', 'Sales', 4800);
GO


