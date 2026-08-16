/* ============================================================================
   DATABASE: NULL_Analytics_DB

   Purpose:
   - SQL Server NULL handling practice
   - Sales Analytics
   - Data Engineering data-quality practice
============================================================================ */

CREATE DATABASE NULL_Analytics_DB;
GO

USE NULL_Analytics_DB;
GO



/* ============================================================================
   SCHEMAS
   Sales  -> Business transaction/customer data
============================================================================ */

CREATE SCHEMA Sales;
GO


/* ============================================================================
   CUSTOMERS TABLE

   Score:
   - Customer satisfaction / loyalty score
   - NULL means score is not available
============================================================================ */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NULL,
    Email VARCHAR(100) NULL,
    City VARCHAR(50) NULL,
    Country VARCHAR(50) NULL,
    Score INT NULL,
    CreatedDate DATE NOT NULL
);
GO



/* ============================================================================
   REALISTIC CUSTOMER DATA

   NULL values are intentionally inserted to simulate real-world
   incomplete / missing data.
============================================================================ */

INSERT INTO Sales.Customers
(
    CustomerID,
    FirstName,
    LastName,
    Email,
    City,
    Country,
    Score,
    CreatedDate
)
VALUES
(1,  'John',    'Smith',    'john.smith@email.com',    'New York',     'USA',        85, '2025-01-10'),
(2,  'Sarah',   NULL,       'sarah@email.com',         'London',       'UK',         90, '2025-01-15'),
(3,  'Michael', 'Brown',    'michael@email.com',        'Chicago',      'USA',        NULL, '2025-01-20'),
(4,  'Emma',    'Wilson',   NULL,                      'Manchester',   'UK',         75, '2025-02-01'),
(5,  'David',   'Taylor',   'david@email.com',          'Toronto',      'Canada',     NULL, '2025-02-05'),
(6,  'Olivia',  'Martin',   'olivia@email.com',        'Paris',        'France',     95, '2025-02-10'),
(7,  'Daniel',  NULL,       'daniel@email.com',         'Berlin',       'Germany',    80, '2025-02-15'),
(8,  'Sophia',  'Anderson', NULL,                      'Madrid',       'Spain',      NULL, '2025-02-20'),
(9,  'James',   'Thomas',   'james@email.com',          'Dubai',        'UAE',        88, '2025-03-01'),
(10, 'Ava',     'Jackson',  'ava@email.com',             'Sydney',       'Australia',  92, '2025-03-05'),
(11, 'William', 'White',    NULL,                       'Boston',       'USA',        NULL, '2025-03-10'),
(12, 'Isabella',NULL,       'isabella@email.com',       'Rome',         'Italy',      78, '2025-03-15'),
(13, 'Benjamin', 'Harris',  'benjamin@email.com',       'Seattle',      'USA',        91, '2025-03-20'),
(14, 'Mia',      'Clark',   NULL,                       'Paris',        'France',     NULL, '2025-03-25'),
(15, 'Lucas',    'Lewis',   'lucas@email.com',          'Madrid',       'Spain',      70, '2025-04-01'),
(16, 'Charlotte','Walker',  'charlotte@email.com',      'London',       'UK',         NULL, '2025-04-05'),
(17, 'Henry',    'Hall',    'henry@email.com',          'Chicago',      'USA',        84, '2025-04-10'),
(18, 'Amelia',   NULL,      'amelia@email.com',         'Toronto',      'Canada',     NULL, '2025-04-15'),
(19, 'Alexander','Allen',   NULL,                       'Berlin',       'Germany',    89, '2025-04-20'),
(20, 'Ella',     'Young',   'ella@email.com',           'Dubai',        'UAE',        96, '2025-04-25');
GO





/* ============================================================================
   ORDERS TABLE

   Quantity = 0 is intentionally included.

   This allows us to demonstrate:
       Sales / Quantity
   and
       Sales / NULLIF(Quantity, 0)
============================================================================ */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NULL,
    OrderDate DATE NOT NULL,
    Sales DECIMAL(12,2) NULL,
    Quantity INT NULL,
    PaymentMethod VARCHAR(30) NULL,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID)
);
GO


/* ============================================================================
   REALISTIC ORDER DATA

   NULL CustomerID:
   - Order exists
   - Customer information is missing

   NULL Sales:
   - Sales amount unavailable

   NULL Quantity:
   - Quantity unavailable

   Quantity = 0:
   - Demonstrates division-by-zero problem
============================================================================ */

INSERT INTO Sales.Orders
(
    OrderID,
    CustomerID,
    OrderDate,
    Sales,
    Quantity,
    PaymentMethod
)
VALUES
(1001, 1,    '2025-05-01', 120.00, 2,    'Credit Card'),
(1002, 2,    '2025-05-02', 250.00, 5,    'PayPal'),
(1003, 3,    '2025-05-03', 180.00, NULL, 'Credit Card'),
(1004, 4,    '2025-05-04', NULL,   3,    'Cash'),
(1005, 5,    '2025-05-05', 500.00, 10,   'Credit Card'),
(1006, 6,    '2025-05-06', 90.00,  2,    'PayPal'),
(1007, 7,    '2025-05-07', 300.00, 0,    'Credit Card'),
(1008, 8,    '2025-05-08', NULL,   NULL, 'Cash'),
(1009, 9,    '2025-05-09', 450.00, 9,    'Credit Card'),
(1010, 10,   '2025-05-10', 200.00, 4,    'PayPal'),
(1011, 1,    '2025-05-11', 150.00, 3,    'Credit Card'),
(1012, 2,    '2025-05-12', NULL,   2,    'Cash'),
(1013, 3,    '2025-05-13', 600.00, 12,   'Credit Card'),
(1014, 4,    '2025-05-14', 220.00, 4,    'PayPal'),
(1015, 5,    '2025-05-15', 350.00, 7,    'Credit Card'),
(1016, 6,    '2025-05-16', NULL,   1,    'Cash'),
(1017, 7,    '2025-05-17', 400.00, 8,    'Credit Card'),
(1018, 8,    '2025-05-18', 125.00, 5,    'PayPal'),
(1019, 9,    '2025-05-19', NULL,   NULL, 'Cash'),
(1020, 10,   '2025-05-20', 700.00, 14,   'Credit Card'),
(1021, 11,   '2025-05-21', 180.00, 3,    'PayPal'),
(1022, 12,   '2025-05-22', 240.00, 4,    'Credit Card'),
(1023, 13,   '2025-05-23', NULL,   2,    'Cash'),
(1024, 14,   '2025-05-24', 310.00, 6,    'Credit Card'),
(1025, 15,   '2025-05-25', 275.00, 5,    'PayPal'),
(1026, 16,   '2025-05-26', 190.00, 3,    'Credit Card'),
(1027, 17,   '2025-05-27', 800.00, 16,   'Credit Card'),
(1028, 18,   '2025-05-28', NULL,   NULL, 'Cash'),
(1029, 19,   '2025-05-29', 330.00, 6,    'PayPal'),
(1030, NULL, '2025-05-30', 450.00, 9,    'Credit Card');
GO

