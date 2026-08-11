-- ============================================================
-- Create Database
-- ============================================================

CREATE DATABASE SalesDB;
GO

USE SalesDB;
GO



-- ============================================================
-- Customers
-- ============================================================

CREATE TABLE Customers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    BirthDate DATE NULL,
    Phone VARCHAR(20) NOT NULL,

    CONSTRAINT PK_Customers
        PRIMARY KEY (CustomerID)
);

-- ============================================================
-- Insert Customers
-- ============================================================

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(1, 'Rubel Ahmed', 'Bangladesh', '1995-05-10', '01711111111'),
(2, 'Omar Hasan', 'Kuwait', '1992-08-15', '96551111111'),
(3, 'John Smith', 'USA', '1988-03-20', '12125551111'),
(4, 'David Lee', 'UK', '1990-11-05', '44791111111'),
(5, 'Sarah Khan', 'Bangladesh', '1997-02-18', '01811111111');



-- ============================================================
-- Categories
-- ============================================================

CREATE TABLE Categories
(
    CategoryID INT NOT NULL,
    CategoryName VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Categories
        PRIMARY KEY (CategoryID)
);


-- ============================================================
-- Insert Categories
-- ============================================================

INSERT INTO Categories
(
    CategoryID,
    CategoryName
)
VALUES
(1, 'Electronics'),
(2, 'Accessories'),
(3, 'Clothing');





-- ============================================================
-- Products
-- ============================================================

CREATE TABLE Products
(
    ProductID INT NOT NULL,
    ProductName VARCHAR(100) NOT NULL,
    CategoryID INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Products
        PRIMARY KEY (ProductID),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID)
        REFERENCES Categories(CategoryID)
);

-- ============================================================
-- Insert Products
-- ============================================================

INSERT INTO Products
(
    ProductID,
    ProductName,
    CategoryID,
    Price
)
VALUES
(101, 'Laptop', 1, 900.00),
(102, 'Keyboard', 2, 50.00),
(103, 'Mouse', 2, 30.00),
(104, 'T-Shirt', 3, 20.00),
(105, 'Jacket', 3, 80.00);






-- ============================================================
-- Departments
-- ============================================================

CREATE TABLE Departments
(
    DepartmentID INT NOT NULL,
    DepartmentName VARCHAR(50) NOT NULL,

    CONSTRAINT PK_Departments
        PRIMARY KEY (DepartmentID)
);


-- ============================================================
-- Insert Departments
-- ============================================================

INSERT INTO Departments
(
    DepartmentID,
    DepartmentName
)
VALUES
(1, 'Sales'),
(2, 'IT'),
(3, 'Finance');





-- ============================================================
-- Employees
-- ============================================================

CREATE TABLE Employees
(
    EmployeeID INT NOT NULL,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_Employees
        PRIMARY KEY (EmployeeID),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (DepartmentID)
        REFERENCES Departments(DepartmentID)
);

-- ============================================================
-- Insert Employees
-- ============================================================

INSERT INTO Employees
(
    EmployeeID,
    EmployeeName,
    DepartmentID,
    Salary
)
VALUES
(1, 'Ahmed Ali', 1, 3500.00),
(2, 'Karim Hasan', 1, 4200.00),
(3, 'David John', 2, 5000.00),
(4, 'Sarah Lee', 3, 4500.00);







-- ============================================================
-- Orders
-- ============================================================

CREATE TABLE Orders
(
    OrderID INT NOT NULL,
    CustomerID INT NOT NULL,
    EmployeeID INT NOT NULL,
    OrderDate DATE NOT NULL,

    CONSTRAINT PK_Orders
        PRIMARY KEY (OrderID),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (EmployeeID)
        REFERENCES Employees(EmployeeID)
);


-- ============================================================
-- Insert Orders
-- ============================================================

INSERT INTO Orders
(
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate
)
VALUES
(1001, 1, 1, '2026-01-10'),
(1002, 2, 2, '2026-01-15'),
(1003, 1, 1, '2026-02-05'),
(1004, 3, 2, '2026-02-20'),
(1005, 4, 1, '2026-03-01'),
(1006, 5, 2, '2026-03-10');






-- ============================================================
-- OrderItems
-- ============================================================

CREATE TABLE OrderItems
(
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_OrderItems
        PRIMARY KEY (OrderID, ProductID),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);



-- ============================================================
-- Insert Order Items
-- ============================================================

INSERT INTO OrderItems
(
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(1001, 101, 1, 900.00),
(1001, 102, 2, 50.00),

(1002, 103, 3, 30.00),

(1003, 104, 4, 20.00),
(1003, 105, 1, 80.00),

(1004, 101, 1, 900.00),
(1004, 103, 2, 30.00),

(1005, 102, 3, 50.00),

(1006, 105, 2, 80.00);









