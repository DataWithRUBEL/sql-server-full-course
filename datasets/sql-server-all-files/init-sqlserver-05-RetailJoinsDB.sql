/* ================================================================
   PROJECT : Retail Operations Analytics
   DATABASE: RetailJoinsDB
================================================================ */

CREATE DATABASE RetailJoinsDB;
GO

USE RetailJoinsDB;
GO




/* ================================================================
   TABLE 1 : Countries
================================================================ */

CREATE TABLE Countries
(
    CountryID INT PRIMARY KEY,
    CountryName VARCHAR(50) NOT NULL
);
GO



/* ================================================================
   TABLE 2 : Categories
================================================================ */

CREATE TABLE Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO



/* ================================================================
   TABLE 3 : Departments
================================================================ */

CREATE TABLE Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(50) NOT NULL
);
GO



/* ================================================================
   TABLE 4 : Customers
================================================================ */

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    CountryID INT NULL,

    CONSTRAINT FK_Customers_Countries
        FOREIGN KEY (CountryID)
        REFERENCES Countries(CountryID)
);
GO





/* ================================================================
   TABLE 5 : Products
================================================================ */

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NULL,
    Price DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);
GO





/* ================================================================
   TABLE 6 : Employees
================================================================ */

CREATE TABLE Employees
(
    EmployeeID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DepartmentID INT NULL,

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);
GO




/* ================================================================
   TABLE 7 : Orders
================================================================ */

CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    CustomerID INT NULL,
    ProductID INT NULL,
    SalesPersonID INT NULL,
    Quantity INT NOT NULL,
    Sales DECIMAL(12,2) NOT NULL
);
GO





/* ================================================================
   COUNTRIES
================================================================ */

INSERT INTO Countries
(
    CountryID,
    CountryName
)
VALUES
(1, 'Kuwait'),
(2, 'Bangladesh'),
(3, 'India'),
(4, 'UAE'),
(5, 'Saudi Arabia');
GO



/* ================================================================
   CATEGORIES
================================================================ */

INSERT INTO Categories
(
    CategoryID,
    CategoryName
)
VALUES
(10, 'Electronics'),
(20, 'Home Appliances'),
(30, 'Office Supplies'),
(40, 'Accessories'),
(50, 'Furniture');
GO



/* ================================================================
   DEPARTMENTS
================================================================ */

INSERT INTO Departments
(
    DepartmentID,
    DepartmentName
)
VALUES
(101, 'Sales'),
(102, 'Marketing'),
(103, 'Finance'),
(104, 'IT');
GO




/* ================================================================
   CUSTOMERS

   CustomerID = 107 has NO orders.
   This will help demonstrate LEFT ANTI JOIN.
================================================================ */

INSERT INTO Customers
(
    CustomerID,
    FirstName,
    LastName,
    CountryID
)
VALUES
(101, 'Ahmed', 'Hassan', 1),
(102, 'Rahim', 'Khan', 2),
(103, 'Arjun', 'Patel', 3),
(104, 'Omar', 'Ali', 4),
(105, 'Fatima', 'Rahman', 2),
(106, 'Salman', 'Khan', 5),
(107, 'Nadia', 'Islam', 2);
GO




/* ================================================================
   PRODUCTS

   ProductID = 205 has NO order.
================================================================ */

INSERT INTO Products
(
    ProductID,
    ProductName,
    CategoryID,
    Price
)
VALUES
(201, 'Laptop', 10, 750.00),
(202, 'Wireless Mouse', 40, 25.00),
(203, 'Office Chair', 50, 120.00),
(204, 'Air Conditioner', 20, 450.00),
(205, 'Printer', 30, 180.00),
(206, 'Keyboard', 40, 35.00);
GO








/* ================================================================
   EMPLOYEES
================================================================ */

INSERT INTO Employees
(
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID
)
VALUES
(301, 'John', 'Smith', 101),
(302, 'David', 'Brown', 101),
(303, 'Sara', 'Wilson', 101),
(304, 'Michael', 'Taylor', 102),
(305, 'Emily', 'Davis', 103);
GO






/* ================================================================
   ORDERS

   OrderID 5010 has CustomerID = 999.
   Customer 999 does NOT exist.

   This is intentional for JOIN/Data Quality practice.
================================================================ */

INSERT INTO Orders
(
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    SalesPersonID,
    Quantity,
    Sales
)
VALUES
(5001, '2026-01-05', 101, 201, 301, 1, 750.00),
(5002, '2026-01-08', 102, 202, 302, 2, 50.00),
(5003, '2026-01-12', 103, 203, 301, 1, 120.00),
(5004, '2026-01-15', 104, 204, 303, 1, 450.00),
(5005, '2026-01-20', 105, 202, 302, 3, 75.00),
(5006, '2026-02-03', 101, 206, 301, 2, 70.00),
(5007, '2026-02-10', 106, 201, 303, 1, 750.00),
(5008, '2026-02-15', 103, 204, 302, 2, 900.00),
(5009, '2026-02-20', 102, 203, 301, 1, 120.00),
(5010, '2026-02-25', 999, 201, 303, 1, 750.00);
GO

