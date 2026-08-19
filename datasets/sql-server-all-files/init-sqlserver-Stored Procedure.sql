/* ============================================================
   CREATE DATABASE
   Real company: Retail / E-commerce
   ============================================================ */

CREATE DATABASE StoredProcedureDB;
GO

USE StoredProcedureDB;
GO


/* ============================================================
   CREATE BUSINESS SCHEMAS
   ============================================================ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Product;
GO

CREATE SCHEMA ETL;
GO

CREATE SCHEMA Reporting;
GO

CREATE SCHEMA Audit;
GO



/* ============================================================
   PRODUCT CATEGORIES
   ============================================================ */

CREATE TABLE Product.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO

INSERT INTO Product.Categories
(
    CategoryID,
    CategoryName
)
VALUES
(1, 'Electronics'),
(2, 'Computers'),
(3, 'Accessories'),
(4, 'Home Appliances'),
(5, 'Office Supplies');
GO

/* ============================================================
   PRODUCTS
   ============================================================ */

CREATE TABLE Product.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(200) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    StockQuantity INT NOT NULL,

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Product.Categories(CategoryID)
);
GO

INSERT INTO Product.Products
VALUES
(101, 'Laptop', 2, 1200.00, 50),
(102, 'Wireless Mouse', 3, 25.00, 500),
(103, 'Keyboard', 3, 45.00, 300),
(104, 'Monitor', 2, 350.00, 120),
(105, 'Headphones', 3, 80.00, 200),
(106, 'Refrigerator', 4, 950.00, 30),
(107, 'Printer', 5, 250.00, 75),
(108, 'Smartphone', 1, 900.00, 100);
GO


/* ============================================================
   CUSTOMERS
   ============================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(150) NOT NULL,
    Email VARCHAR(200),
    Country VARCHAR(100),
    RegistrationDate DATE
);
GO


INSERT INTO Sales.Customers
VALUES
(1, 'Ahmed Ali', 'ahmed@example.com', 'Kuwait', '2025-01-10'),
(2, 'John Smith', 'john@example.com', 'USA', '2025-02-15'),
(3, 'Rahim Khan', 'rahim@example.com', 'Bangladesh', '2025-03-20'),
(4, 'David Lee', 'david@example.com', 'UK', '2025-04-12'),
(5, 'Sara Ahmed', 'sara@example.com', 'Kuwait', '2025-05-05');
GO

/* ============================================================
   DEPARTMENTS
   ============================================================ */

CREATE TABLE HR.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO

INSERT INTO HR.Departments
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance'),
(4, 'Operations'),
(5, 'HR');
GO


/* ============================================================
   EMPLOYEES
   ============================================================ */

CREATE TABLE HR.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(150) NOT NULL,
    DepartmentID INT,
    HireDate DATE,
    Salary DECIMAL(12,2),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO


INSERT INTO HR.Employees
VALUES
(1001, 'Robert Brown', 1, '2023-01-10', 50000),
(1002, 'James Wilson', 1, '2023-03-15', 55000),
(1003, 'Mary Johnson', 2, '2022-06-20', 70000),
(1004, 'Daniel Miller', 3, '2021-08-12', 65000),
(1005, 'Linda Davis', 4, '2024-01-05', 48000);
GO


/* ============================================================
   ORDERS
   ============================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES HR.Employees(EmployeeID)
);
GO

INSERT INTO Sales.Orders
VALUES
(10001, 1, 1001, '2026-01-05', 'Completed'),
(10002, 2, 1002, '2026-01-10', 'Completed'),
(10003, 3, 1001, '2026-01-15', 'Pending'),
(10004, 1, 1002, '2026-02-01', 'Completed'),
(10005, 4, 1003, '2026-02-10', 'Cancelled'),
(10006, 5, 1001, '2026-02-15', 'Completed');
GO


/* ============================================================
   ORDER ITEMS
   ============================================================ */

CREATE TABLE Sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Product.Products(ProductID)
);
GO

INSERT INTO Sales.OrderItems
VALUES
(1, 10001, 101, 1, 1200),
(2, 10001, 102, 2, 25),
(3, 10002, 104, 2, 350),
(4, 10003, 105, 1, 80),
(5, 10004, 108, 1, 900),
(6, 10004, 103, 1, 45),
(7, 10005, 106, 1, 950),
(8, 10006, 107, 2, 250);
GO





