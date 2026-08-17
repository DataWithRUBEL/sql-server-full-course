/* ============================================================
   STEP 1: Create Database
   ============================================================ */

CREATE DATABASE sql_Aggregate_FunctionsDB;
GO

USE sql_Aggregate_FunctionsDB;
GO


/* ============================================================
   STEP 2: Create Schemas
   ============================================================ */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA HR;
GO



/* ============================================================
   TABLE: HR.Departments
   Purpose:
   Company departments maintain করার জন্য
   ============================================================ */

CREATE TABLE HR.Departments
(
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL
);
GO

INSERT INTO HR.Departments
(
    department_id,
    department_name
)
VALUES
(1, 'Sales'),
(2, 'Marketing'),
(3, 'Finance'),
(4, 'IT'),
(5, 'Operations');
GO



/* ============================================================
   TABLE: HR.Employees
   Purpose:
   Sales representative / employee information
   ============================================================ */

CREATE TABLE HR.Employees
(
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    hire_date DATE,
    salary DECIMAL(12,2),

    CONSTRAINT FK_Employees_Departments
        FOREIGN KEY (department_id)
        REFERENCES HR.Departments(department_id)
);
GO

INSERT INTO HR.Employees
(
    employee_id,
    employee_name,
    department_id,
    hire_date,
    salary
)
VALUES
(101, 'John Smith', 1, '2023-01-10', 45000),
(102, 'Sarah Khan', 1, '2023-03-15', 48000),
(103, 'David Lee', 2, '2022-07-20', 52000),
(104, 'Emma Wilson', 3, '2021-11-05', 58000),
(105, 'Michael Brown', 4, '2020-04-12', 65000),
(106, 'Olivia Martin', 5, '2024-02-18', 43000);
GO




/* ============================================================
   TABLE: Sales.Customers
   Purpose:
   Customer master information
   ============================================================ */

CREATE TABLE Sales.Customers
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    gender VARCHAR(20),
    city VARCHAR(100),
    country VARCHAR(100),
    signup_date DATE,
    score INT NULL
);
GO

INSERT INTO Sales.Customers
(
    customer_id,
    customer_name,
    gender,
    city,
    country,
    signup_date,
    score
)
VALUES
(1, 'Ahmed Hassan', 'Male', 'Kuwait City', 'Kuwait', '2025-01-10', 85),
(2, 'Sara Ali', 'Female', 'Salmiya', 'Kuwait', '2025-01-15', 72),
(3, 'John Smith', 'Male', 'Dubai', 'UAE', '2025-02-05', 91),
(4, 'Emma Brown', 'Female', 'Abu Dhabi', 'UAE', '2025-02-20', 65),
(5, 'David Wilson', 'Male', 'Doha', 'Qatar', '2025-03-10', 78),
(6, 'Fatima Khan', 'Female', 'Kuwait City', 'Kuwait', '2025-03-22', 88),
(7, 'Michael Lee', 'Male', 'Riyadh', 'Saudi Arabia', '2025-04-02', 59),
(8, 'Olivia Martin', 'Female', 'Jeddah', 'Saudi Arabia', '2025-04-18', 95),
(9, 'James Taylor', 'Male', 'Manama', 'Bahrain', '2025-05-03', 71),
(10, 'Sophia Clark', 'Female', 'Dubai', 'UAE', '2025-05-15', NULL),
(11, 'Daniel Lewis', 'Male', 'Kuwait City', 'Kuwait', '2025-06-01', 83),
(12, 'Mia Walker', 'Female', 'Salmiya', 'Kuwait', '2025-06-10', 76),
(13, 'Robert Hall', 'Male', 'Doha', 'Qatar', '2025-07-05', 68),
(14, 'Amelia Young', 'Female', 'Riyadh', 'Saudi Arabia', '2025-07-15', 92),
(15, 'William King', 'Male', 'Dubai', 'UAE', '2025-08-01', 81),
(16, 'Ava Wright', 'Female', 'Kuwait City', 'Kuwait', '2025-08-20', 97),
(17, 'Ethan Scott', 'Male', 'Abu Dhabi', 'UAE', '2025-09-05', 74),
(18, 'Isabella Green', 'Female', 'Doha', 'Qatar', '2025-09-20', 89),
(19, 'Lucas Baker', 'Male', 'Manama', 'Bahrain', '2025-10-10', 63),
(20, 'Charlotte Adams', 'Female', 'Jeddah', 'Saudi Arabia', '2025-10-25', 94);
GO



/* ============================================================
   TABLE: Sales.Categories
   ============================================================ */

CREATE TABLE Sales.Categories
(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);
GO

INSERT INTO Sales.Categories
VALUES
(1, 'Electronics'),
(2, 'Clothing'),
(3, 'Home'),
(4, 'Accessories');
GO



/* ============================================================
   TABLE: Sales.Products
   ============================================================ */

CREATE TABLE Sales.Products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category_id INT,
    unit_price DECIMAL(12,2),

    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (category_id)
        REFERENCES Sales.Categories(category_id)
);
GO

INSERT INTO Sales.Products
VALUES
(101, 'Laptop', 1, 900),
(102, 'Smartphone', 1, 600),
(103, 'Headphones', 1, 120),
(104, 'T-Shirt', 2, 30),
(105, 'Jeans', 2, 60),
(106, 'Jacket', 2, 100),
(107, 'Office Chair', 3, 180),
(108, 'Desk', 3, 250),
(109, 'Coffee Maker', 3, 90),
(110, 'Backpack', 4, 50),
(111, 'Watch', 4, 150),
(112, 'Sunglasses', 4, 80);
GO



/* ============================================================
   TABLE: Sales.Orders

   Important columns:
   order_id      = unique order
   customer_id   = customer
   employee_id   = salesperson
   order_date    = transaction date
   status        = order status
   sales         = order-level revenue
   ============================================================ */

CREATE TABLE Sales.Orders
(
    order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    order_date DATE NOT NULL,
    status VARCHAR(30),
    sales DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (customer_id)
        REFERENCES Sales.Customers(customer_id),

    CONSTRAINT FK_Orders_Employees
        FOREIGN KEY (employee_id)
        REFERENCES HR.Employees(employee_id)
);
GO



INSERT INTO Sales.Orders
(
    order_id,
    customer_id,
    employee_id,
    order_date,
    status,
    sales
)
VALUES
(1001,1,101,'2025-01-12','Completed',900),
(1002,2,102,'2025-01-18','Completed',120),
(1003,3,101,'2025-02-07','Completed',600),
(1004,4,102,'2025-02-22','Completed',250),
(1005,5,101,'2025-03-12','Completed',180),
(1006,6,102,'2025-03-25','Completed',100),
(1007,7,101,'2025-04-05','Completed',1200),
(1008,8,102,'2025-04-20','Completed',600),
(1009,9,101,'2025-05-05','Completed',300),
(1010,10,102,'2025-05-18','Cancelled',150),
(1011,11,101,'2025-06-03','Completed',900),
(1012,12,102,'2025-06-12','Completed',250),
(1013,13,101,'2025-07-08','Completed',180),
(1014,14,102,'2025-07-17','Completed',1200),
(1015,15,101,'2025-08-03','Completed',600),
(1016,16,102,'2025-08-22','Completed',900),
(1017,17,101,'2025-09-07','Completed',300),
(1018,18,102,'2025-09-23','Completed',600),
(1019,19,101,'2025-10-12','Completed',250),
(1020,20,102,'2025-10-27','Completed',900),
(1021,1,101,'2025-02-15','Completed',120),
(1022,2,102,'2025-03-05','Completed',600),
(1023,3,101,'2025-04-10','Completed',900),
(1024,4,102,'2025-05-10','Completed',180),
(1025,5,101,'2025-06-20','Completed',600),
(1026,6,102,'2025-07-25','Completed',300),
(1027,7,101,'2025-08-10','Completed',900),
(1028,8,102,'2025-09-15','Completed',1200),
(1029,9,101,'2025-10-18','Completed',600),
(1030,10,102,'2025-11-05','Completed',250);
GO


/* ============================================================
   TABLE: Sales.OrderItems

   Detail-level transactional data.
   This table is useful for:
   Product analysis
   Quantity
   Revenue
   Category analysis
   ============================================================ */

CREATE TABLE Sales.OrderItems
(
    order_item_id INT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(12,2),

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (order_id)
        REFERENCES Sales.Orders(order_id),

    CONSTRAINT FK_OrderItems_Products
        FOREIGN KEY (product_id)
        REFERENCES Sales.Products(product_id)
);
GO

INSERT INTO Sales.OrderItems
VALUES
(1,1001,101,1,900),
(2,1002,103,1,120),
(3,1003,102,1,600),
(4,1004,108,1,250),
(5,1005,107,1,180),
(6,1006,106,1,100),
(7,1007,101,1,900),
(8,1007,103,2,120),
(9,1008,102,1,600),
(10,1009,104,10,30),
(11,1010,111,1,150),
(12,1011,101,1,900),
(13,1012,108,1,250),
(14,1013,107,1,180),
(15,1014,101,1,900),
(16,1014,110,6,50),
(17,1015,102,1,600),
(18,1016,101,1,900),
(19,1017,104,10,30),
(20,1018,102,1,600),
(21,1019,108,1,250),
(22,1020,101,1,900),
(23,1021,103,1,120),
(24,1022,102,1,600),
(25,1023,101,1,900),
(26,1024,107,1,180),
(27,1025,102,1,600),
(28,1026,104,10,30),
(29,1027,101,1,900),
(30,1028,101,1,900),
(31,1028,103,1,120),
(32,1029,102,1,600),
(33,1030,108,1,250);
GO

