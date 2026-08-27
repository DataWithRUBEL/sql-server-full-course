/*
==============================================================================
SQL SELECT Query
==============================================================================

This guide covers various SELECT query techniques used for:
- Retrieving data
- Filtering data
- Sorting data
- Aggregating data
- Finding unique values
- Returning TOP records
- Working with multiple queries
- Selecting static values

Business Scenario:
Retail Sales Company

Tables:
1. customers
2. orders
3. products
4. employees
5. stores
6. payments
7. categories

==============================================================================
*/


/*
==============================================================================
CREATE DATABASE
==============================================================================
*/

CREATE DATABASE RetailSalesDB;
GO

USE RetailSalesDB;
GO


/*
==============================================================================
CREATE TABLES
==============================================================================
*/


/*
------------------------------------------------------------------------------
1. CUSTOMERS TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE customers
(
    id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(50),
    score INT
);


/*
------------------------------------------------------------------------------
2. ORDERS TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE orders
(
    order_id INT PRIMARY KEY,
    customer_id INT,
    product_id INT,
    employee_id INT,
    store_id INT,
    order_date DATE,
    quantity INT,
    sales_amount DECIMAL(10,2)
);


/*
------------------------------------------------------------------------------
3. PRODUCTS TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE products
(
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    price DECIMAL(10,2)
);


/*
------------------------------------------------------------------------------
4. EMPLOYEES TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE employees
(
    employee_id INT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    country VARCHAR(50),
    salary DECIMAL(10,2)
);


/*
------------------------------------------------------------------------------
5. STORES TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE stores
(
    store_id INT PRIMARY KEY,
    store_name VARCHAR(100),
    country VARCHAR(50),
    city VARCHAR(50)
);


/*
------------------------------------------------------------------------------
6. PAYMENTS TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE payments
(
    payment_id INT PRIMARY KEY,
    order_id INT,
    payment_method VARCHAR(30),
    payment_amount DECIMAL(10,2)
);


/*
------------------------------------------------------------------------------
7. CATEGORIES TABLE
------------------------------------------------------------------------------
*/

CREATE TABLE categories
(
    category_id INT PRIMARY KEY,
    category_name VARCHAR(50)
);


/*
==============================================================================
INSERT DATA
==============================================================================
*/


/*
------------------------------------------------------------------------------
CUSTOMERS
------------------------------------------------------------------------------
50 REAL-STYLE CUSTOMER RECORDS
*/

INSERT INTO customers
(id, first_name, last_name, country, city, score)
VALUES
(1, 'John', 'Smith', 'USA', 'New York', 850),
(2, 'Emma', 'Johnson', 'USA', 'Chicago', 720),
(3, 'Michael', 'Brown', 'USA', 'Houston', 650),
(4, 'Olivia', 'Davis', 'USA', 'Boston', 910),
(5, 'William', 'Wilson', 'USA', 'Dallas', 430),

(6, 'James', 'Miller', 'UK', 'London', 780),
(7, 'Sophia', 'Taylor', 'UK', 'Manchester', 920),
(8, 'Benjamin', 'Anderson', 'UK', 'Birmingham', 560),
(9, 'Charlotte', 'Thomas', 'UK', 'London', 690),
(10, 'Henry', 'Moore', 'UK', 'Liverpool', 410),

(11, 'Lucas', 'Martin', 'Germany', 'Berlin', 880),
(12, 'Mia', 'Jackson', 'Germany', 'Munich', 760),
(13, 'Alexander', 'White', 'Germany', 'Hamburg', 590),
(14, 'Amelia', 'Harris', 'Germany', 'Frankfurt', 940),
(15, 'Daniel', 'Martin', 'Germany', 'Berlin', 320),

(16, 'Noah', 'Thompson', 'France', 'Paris', 820),
(17, 'Isabella', 'Garcia', 'France', 'Lyon', 710),
(18, 'Ethan', 'Martinez', 'France', 'Marseille', 480),
(19, 'Ava', 'Robinson', 'France', 'Paris', 960),
(20, 'Matthew', 'Clark', 'France', 'Nice', 350),

(21, 'Liam', 'Rodriguez', 'Canada', 'Toronto', 870),
(22, 'Emily', 'Lewis', 'Canada', 'Vancouver', 730),
(23, 'Oliver', 'Lee', 'Canada', 'Montreal', 610),
(24, 'Ella', 'Walker', 'Canada', 'Calgary', 950),
(25, 'Jacob', 'Hall', 'Canada', 'Toronto', 290),

(26, 'Hassan', 'Ali', 'Kuwait', 'Kuwait City', 890),
(27, 'Fatima', 'Ahmed', 'Kuwait', 'Hawally', 740),
(28, 'Omar', 'Khan', 'Kuwait', 'Farwaniya', 630),
(29, 'Sara', 'Hassan', 'Kuwait', 'Salmiya', 970),
(30, 'Yusuf', 'Mahmoud', 'Kuwait', 'Jahra', 380),

(31, 'Arif', 'Rahman', 'Bangladesh', 'Dhaka', 830),
(32, 'Nusrat', 'Jahan', 'Bangladesh', 'Chittagong', 700),
(33, 'Sakib', 'Hasan', 'Bangladesh', 'Dhaka', 520),
(34, 'Mim', 'Akter', 'Bangladesh', 'Sylhet', 930),
(35, 'Tanvir', 'Ahmed', 'Bangladesh', 'Rajshahi', 450),

(36, 'Raj', 'Sharma', 'India', 'Mumbai', 860),
(37, 'Priya', 'Patel', 'India', 'Delhi', 750),
(38, 'Rahul', 'Kumar', 'India', 'Bangalore', 580),
(39, 'Ananya', 'Singh', 'India', 'Mumbai', 980),
(40, 'Vikram', 'Mehta', 'India', 'Pune', 360),

(41, 'David', 'Kim', 'Australia', 'Sydney', 810),
(42, 'Grace', 'Lee', 'Australia', 'Melbourne', 670),
(43, 'Daniel', 'Park', 'Australia', 'Brisbane', 490),
(44, 'Chloe', 'Wong', 'Australia', 'Sydney', 900),
(45, 'Ryan', 'Chen', 'Australia', 'Perth', 340),

(46, 'Carlos', 'Silva', 'Brazil', 'Sao Paulo', 840),
(47, 'Maria', 'Santos', 'Brazil', 'Rio', 760),
(48, 'Lucas', 'Oliveira', 'Brazil', 'Brasilia', 550),
(49, 'Julia', 'Costa', 'Brazil', 'Sao Paulo', 920),
(50, 'Pedro', 'Souza', 'Brazil', 'Salvador', 300);


/*
------------------------------------------------------------------------------
PRODUCTS
------------------------------------------------------------------------------
*/

INSERT INTO products
(product_id, product_name, category_id, price)
VALUES
(101, 'Laptop', 1, 850.00),
(102, 'Wireless Mouse', 1, 25.00),
(103, 'Keyboard', 1, 45.00),
(104, 'Monitor', 1, 220.00),
(105, 'USB Cable', 1, 12.00),

(106, 'Office Chair', 2, 180.00),
(107, 'Desk', 2, 250.00),

(108, 'Backpack', 3, 65.00),
(109, 'Travel Bag', 3, 95.00),

(110, 'Running Shoes', 4, 120.00),
(111, 'Sports T-Shirt', 4, 35.00),

(112, 'Coffee Maker', 5, 150.00),
(113, 'Water Bottle', 5, 20.00),

(114, 'Smartphone', 6, 700.00),
(115, 'Headphones', 6, 80.00);


/*
------------------------------------------------------------------------------
CATEGORIES
------------------------------------------------------------------------------
*/

INSERT INTO categories
(category_id, category_name)
VALUES
(1, 'Electronics'),
(2, 'Furniture'),
(3, 'Travel'),
(4, 'Sports'),
(5, 'Kitchen'),
(6, 'Mobile'),
(7, 'Clothing'),
(8, 'Accessories');


/*
------------------------------------------------------------------------------
EMPLOYEES
------------------------------------------------------------------------------
*/

INSERT INTO employees
(employee_id, first_name, last_name, country, salary)
VALUES
(1, 'Robert', 'King', 'USA', 65000),
(2, 'Sarah', 'Brown', 'UK', 58000),
(3, 'David', 'Wilson', 'Germany', 62000),
(4, 'Linda', 'Smith', 'France', 59000),
(5, 'Ahmed', 'Hassan', 'Kuwait', 70000),
(6, 'Karim', 'Rahman', 'Bangladesh', 48000),
(7, 'Neha', 'Patel', 'India', 55000),
(8, 'James', 'Lee', 'Canada', 61000),
(9, 'Daniel', 'Park', 'Australia', 60000),
(10, 'Carlos', 'Santos', 'Brazil', 52000);


/*
------------------------------------------------------------------------------
STORES
------------------------------------------------------------------------------
*/

INSERT INTO stores
(store_id, store_name, country, city)
VALUES
(1, 'Downtown Store', 'USA', 'New York'),
(2, 'Central Store', 'UK', 'London'),
(3, 'Berlin Store', 'Germany', 'Berlin'),
(4, 'Paris Store', 'France', 'Paris'),
(5, 'Kuwait Store', 'Kuwait', 'Kuwait City'),
(6, 'Dhaka Store', 'Bangladesh', 'Dhaka'),
(7, 'Mumbai Store', 'India', 'Mumbai');


/*
------------------------------------------------------------------------------
ORDERS
------------------------------------------------------------------------------
60 REAL-STYLE SALES RECORDS
------------------------------------------------------------------------------
*/

INSERT INTO orders
(order_id, customer_id, product_id, employee_id, store_id,
 order_date, quantity, sales_amount)
VALUES
(1001,1,101,1,1,'2026-01-05',1,850),
(1002,2,102,1,1,'2026-01-06',2,50),
(1003,3,103,1,1,'2026-01-07',1,45),
(1004,4,104,1,1,'2026-01-08',2,440),
(1005,5,105,1,1,'2026-01-09',3,36),

(1006,6,101,2,2,'2026-01-10',1,850),
(1007,7,102,2,2,'2026-01-11',3,75),
(1008,8,106,2,2,'2026-01-12',1,180),
(1009,9,107,2,2,'2026-01-13',1,250),
(1010,10,108,2,2,'2026-01-14',2,130),

(1011,11,101,3,3,'2026-01-15',1,850),
(1012,12,103,3,3,'2026-01-16',2,90),
(1013,13,104,3,3,'2026-01-17',1,220),
(1014,14,106,3,3,'2026-01-18',2,360),
(1015,15,109,3,3,'2026-01-19',1,95),

(1016,16,110,4,4,'2026-01-20',1,120),
(1017,17,111,4,4,'2026-01-21',3,105),
(1018,18,112,4,4,'2026-01-22',1,150),
(1019,19,113,4,4,'2026-01-23',4,80),
(1020,20,115,4,4,'2026-01-24',2,160),

(1021,21,101,8,1,'2026-02-01',1,850),
(1022,22,102,8,1,'2026-02-02',4,100),
(1023,23,103,8,1,'2026-02-03',2,90),
(1024,24,104,8,1,'2026-02-04',1,220),
(1025,25,105,8,1,'2026-02-05',5,60),

(1026,26,114,5,5,'2026-02-06',1,700),
(1027,27,115,5,5,'2026-02-07',2,160),
(1028,28,112,5,5,'2026-02-08',1,150),
(1029,29,113,5,5,'2026-02-09',5,100),
(1030,30,108,5,5,'2026-02-10',2,130),

(1031,31,101,6,6,'2026-02-11',1,850),
(1032,32,102,6,6,'2026-02-12',2,50),
(1033,33,103,6,6,'2026-02-13',1,45),
(1034,34,110,6,6,'2026-02-14',2,240),
(1035,35,111,6,6,'2026-02-15',3,105),

(1036,36,114,7,7,'2026-02-16',1,700),
(1037,37,115,7,7,'2026-02-17',2,160),
(1038,38,108,7,7,'2026-02-18',1,65),
(1039,39,109,7,7,'2026-02-19',2,190),
(1040,40,110,7,7,'2026-02-20',1,120),

(1041,41,101,9,1,'2026-02-21',1,850),
(1042,42,104,9,1,'2026-02-22',2,440),
(1043,43,105,9,1,'2026-02-23',4,48),
(1044,44,102,9,1,'2026-02-24',5,125),
(1045,45,103,9,1,'2026-02-25',2,90),

(1046,46,114,10,7,'2026-02-26',1,700),
(1047,47,115,10,7,'2026-02-27',3,240),
(1048,48,112,10,7,'2026-02-28',1,150),
(1049,49,113,10,7,'2026-03-01',6,120),
(1050,50,108,10,7,'2026-03-02',2,130),

(1051,1,114,1,1,'2026-03-03',1,700),
(1052,7,101,2,2,'2026-03-04',1,850),
(1053,14,104,3,3,'2026-03-05',2,440),
(1054,19,110,4,4,'2026-03-06',2,240),
(1055,26,114,5,5,'2026-03-07',1,700),

(1056,31,101,6,6,'2026-03-08',1,850),
(1057,39,114,7,7,'2026-03-09',1,700),
(1058,41,102,9,1,'2026-03-10',3,75),
(1059,46,115,10,7,'2026-03-11',2,160),
(1060,49,112,10,7,'2026-03-12',1,150);


/*
------------------------------------------------------------------------------
PAYMENTS
------------------------------------------------------------------------------
*/

INSERT INTO payments
(payment_id, order_id, payment_method, payment_amount)
VALUES
(1,1001,'Credit Card',850),
(2,1002,'Cash',50),
(3,1003,'Debit Card',45),
(4,1004,'Credit Card',440),
(5,1005,'Cash',36),
(6,1006,'Credit Card',850),
(7,1007,'Debit Card',75),
(8,1008,'Cash',180),
(9,1009,'Credit Card',250),
(10,1010,'Cash',130),
(11,1026,'Credit Card',700),
(12,1027,'Debit Card',160),
(13,1031,'Credit Card',850),
(14,1036,'Cash',700),
(15,1041,'Credit Card',850),
(16,1046,'Debit Card',700),
(17,1051,'Credit Card',700),
(18,1052,'Cash',850),
(19,1053,'Credit Card',440),
(20,1054,'Debit Card',240);
