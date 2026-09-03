/* ============================================================
   PARTITIONS COURSE
   Database + Schemas
   ============================================================ */

USE master;
GO

IF DB_ID('PartitionsDB') IS NOT NULL
BEGIN
    ALTER DATABASE PartitionsDB
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE PartitionsDB;
END;
GO

CREATE DATABASE PartitionsDB;
GO

USE PartitionsDB;
GO

/* ============================================================
   Create business schemas
   ============================================================ */

CREATE SCHEMA dim;
GO

CREATE SCHEMA fact;
GO

CREATE SCHEMA staging;
GO

CREATE SCHEMA archive;
GO

CREATE SCHEMA demo;
GO


CREATE TABLE dim.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO

INSERT INTO dim.Departments
VALUES
(1, 'Sales'),
(2, 'Finance'),
(3, 'HR'),
(4, 'IT'),
(5, 'Operations'),
(6, 'Marketing'),
(7, 'Supply Chain'),
(8, 'Customer Service');
GO


CREATE TABLE dim.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO

INSERT INTO dim.Categories
VALUES
(1, 'Electronics'),
(2, 'Computers'),
(3, 'Mobile'),
(4, 'Accessories'),
(5, 'Home Appliances'),
(6, 'Furniture'),
(7, 'Clothing'),
(8, 'Sports'),
(9, 'Beauty'),
(10, 'Grocery');
GO

CREATE TABLE dim.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    CostPrice DECIMAL(12,2) NOT NULL,
    IsActive BIT NOT NULL DEFAULT 1,

    CONSTRAINT FK_Products_Category
        FOREIGN KEY (CategoryID)
        REFERENCES dim.Categories(CategoryID)
);
GO



/* ============================================================
   Generate 50 products
   ============================================================ */

;WITH ProductSeed AS
(
    SELECT TOP (50)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS ProductID
    FROM sys.all_objects
)
INSERT INTO dim.Products
(
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice,
    CostPrice
)
SELECT
    ProductID,
    CONCAT('GlobalMart Product ', ProductID),
    ((ProductID - 1) % 10) + 1,
    CAST(20 + ((ProductID * 37) % 980) AS DECIMAL(12,2)),
    CAST(10 + ((ProductID * 19) % 500) AS DECIMAL(12,2))
FROM ProductSeed;
GO


CREATE TABLE dim.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    HireDate DATE NOT NULL,
    JobTitle VARCHAR(100) NOT NULL,

    CONSTRAINT FK_Employees_Department
        FOREIGN KEY (DepartmentID)
        REFERENCES dim.Departments(DepartmentID)
);
GO


/* ============================================================
   Generate 30 employees
   ============================================================ */

;WITH EmployeeSeed AS
(
    SELECT TOP (30)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS EmployeeID
    FROM sys.all_objects
)
INSERT INTO dim.Employees
(
    EmployeeID,
    EmployeeName,
    DepartmentID,
    HireDate,
    JobTitle
)
SELECT
    EmployeeID,
    CONCAT('Employee ', EmployeeID),
    ((EmployeeID - 1) % 8) + 1,
    DATEADD(DAY, -((EmployeeID * 73) % 2500), CAST(GETDATE() AS DATE)),
    CASE
        WHEN EmployeeID % 5 = 0 THEN 'Manager'
        WHEN EmployeeID % 3 = 0 THEN 'Senior Executive'
        ELSE 'Sales Executive'
    END
FROM EmployeeSeed;
GO



CREATE TABLE dim.Stores
(
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL,
    Country VARCHAR(100) NOT NULL
);
GO

INSERT INTO dim.Stores
VALUES
(1,'Kuwait City Store','Kuwait City','Kuwait'),
(2,'Salmiya Store','Salmiya','Kuwait'),
(3,'Hawally Store','Hawally','Kuwait'),
(4,'Farwaniya Store','Farwaniya','Kuwait'),
(5,'Ahmadi Store','Ahmadi','Kuwait'),
(6,'Dubai Store','Dubai','UAE'),
(7,'Abu Dhabi Store','Abu Dhabi','UAE'),
(8,'Doha Store','Doha','Qatar'),
(9,'Riyadh Store','Riyadh','Saudi Arabia'),
(10,'Jeddah Store','Jeddah','Saudi Arabia'),
(11,'Manama Store','Manama','Bahrain'),
(12,'Muscat Store','Muscat','Oman'),
(13,'London Store','London','UK'),
(14,'Toronto Store','Toronto','Canada'),
(15,'Singapore Store','Singapore','Singapore');
GO


CREATE TABLE dim.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(150) NOT NULL,
    Gender CHAR(1),
    City VARCHAR(100),
    Country VARCHAR(100),
    SignupDate DATE
);
GO
/* ============================================================
   Generate 100 customers
   ============================================================ */

;WITH CustomerSeed AS
(
    SELECT TOP (100)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS CustomerID
    FROM sys.all_objects
)
INSERT INTO dim.Customers
(
    CustomerID,
    CustomerName,
    Gender,
    City,
    Country,
    SignupDate
)
SELECT
    CustomerID,
    CONCAT('Customer ', CustomerID),
    CASE
        WHEN CustomerID % 2 = 0 THEN 'M'
        ELSE 'F'
    END,
    CASE
        WHEN CustomerID % 5 = 0 THEN 'Dubai'
        WHEN CustomerID % 5 = 1 THEN 'Kuwait City'
        WHEN CustomerID % 5 = 2 THEN 'Doha'
        WHEN CustomerID % 5 = 3 THEN 'Riyadh'
        ELSE 'Manama'
    END,
    CASE
        WHEN CustomerID % 5 = 0 THEN 'UAE'
        WHEN CustomerID % 5 = 1 THEN 'Kuwait'
        WHEN CustomerID % 5 = 2 THEN 'Qatar'
        WHEN CustomerID % 5 = 3 THEN 'Saudi Arabia'
        ELSE 'Bahrain'
    END,
    DATEADD(DAY, -((CustomerID * 17) % 3000), CAST(GETDATE() AS DATE))
FROM CustomerSeed;

