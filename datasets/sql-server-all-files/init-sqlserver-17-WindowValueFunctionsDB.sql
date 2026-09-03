/* ============================================================
   DATABASE
   Purpose:
   Window Value Functions practice করার জন্য dedicated database
   ============================================================ */
CREATE DATABASE WindowValueFunctionsDB;
GO

USE WindowValueFunctionsDB;
GO

/* ============================================================
   SCHEMAS
   bronze = source/raw data
   sales  = business transaction data
   hr     = employee history
   product = product history
   banking = bank transactions
   inventory = inventory movements
   ============================================================ */
CREATE SCHEMA bronze;
GO

CREATE SCHEMA sales;
GO

CREATE SCHEMA hr;
GO

CREATE SCHEMA product;
GO

CREATE SCHEMA banking;
GO

CREATE SCHEMA inventory;
GO


/* ============================================================
   Customers
   Purpose:
   Customer purchase history এবং customer journey analysis
   ============================================================ */
CREATE TABLE sales.Customers
(
    CustomerID      INT PRIMARY KEY,
    CustomerName    VARCHAR(100),
    City            VARCHAR(50),
    Segment         VARCHAR(30),
    SignupDate      DATE
);
GO

/* ============================================================
   Customer Data
   ============================================================ */
INSERT INTO sales.Customers
(
    CustomerID,
    CustomerName,
    City,
    Segment,
    SignupDate
)
VALUES
(101, 'Ahmed Ali',   'Kuwait City', 'Retail',    '2024-01-10'),
(102, 'Sara Khan',   'Farwaniyah',  'Retail',    '2024-02-15'),
(103, 'Omar Hassan', 'Hawally',     'Corporate', '2024-03-20'),
(104, 'Fatima Noor', 'Salmiya',     'Retail',    '2024-04-05'),
(105, 'John Smith',  'Jabriya',     'Corporate', '2024-05-12');
GO

/* ============================================================
   Products
   Purpose:
   Product sales এবং price history analysis
   ============================================================ */
CREATE TABLE product.Products
(
    ProductID       INT PRIMARY KEY,
    ProductName     VARCHAR(100),
    Category        VARCHAR(50)
);
GO

INSERT INTO product.Products
VALUES
(1, 'Laptop',       'Electronics'),
(2, 'Mobile Phone', 'Electronics'),
(3, 'Headphones',   'Accessories'),
(4, 'Keyboard',     'Accessories'),
(5, 'Monitor',      'Electronics');
GO

/* ============================================================
   Orders
   Purpose:
   Sales analysis, previous/next order,
   customer purchase sequence
   ============================================================ */
CREATE TABLE sales.Orders
(
    OrderID         INT PRIMARY KEY,
    CustomerID      INT,
    OrderDate       DATE,
    OrderStatus     VARCHAR(30),
    TotalAmount     DECIMAL(12,2),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES sales.Customers(CustomerID)
);
GO


/* ============================================================
   Realistic Order Data
   ============================================================ */

INSERT INTO sales.Orders
VALUES
(1001,101,'2024-01-15','Completed',1200),
(1002,102,'2024-01-20','Completed',800),
(1003,101,'2024-02-10','Completed',500),
(1004,103,'2024-02-15','Completed',2000),
(1005,102,'2024-03-05','Completed',900),
(1006,101,'2024-03-15','Completed',700),
(1007,104,'2024-03-20','Cancelled',400),
(1008,103,'2024-04-01','Completed',1500),
(1009,105,'2024-04-10','Completed',2200),
(1010,102,'2024-04-20','Completed',600),
(1011,101,'2024-05-05','Completed',1300),
(1012,103,'2024-05-15','Completed',1800),
(1013,104,'2024-05-20','Completed',750),
(1014,105,'2024-06-01','Completed',2100),
(1015,102,'2024-06-15','Completed',1000),
(1016,101,'2024-06-20','Completed',950),
(1017,103,'2024-07-05','Completed',1700),
(1018,104,'2024-07-10','Completed',850),
(1019,105,'2024-07-20','Completed',2400),
(1020,101,'2024-08-01','Completed',1500);
GO


/* ============================================================
   Order Details
   Purpose:
   Product-level analysis
   ============================================================ */

CREATE TABLE sales.OrderDetails
(
    OrderDetailID INT PRIMARY KEY,
    OrderID       INT,
    ProductID     INT,
    Quantity      INT,
    UnitPrice     DECIMAL(10,2)
);
GO

INSERT INTO sales.OrderDetails
VALUES
(1,1001,1,1,1200),
(2,1002,2,1,800),
(3,1003,3,2,250),
(4,1004,1,1,2000),
(5,1005,2,1,900),
(6,1006,4,2,350),
(7,1007,5,1,400),
(8,1008,1,1,1500),
(9,1009,1,1,2200),
(10,1010,3,2,300),
(11,1011,2,1,1300),
(12,1012,5,2,900),
(13,1013,4,2,375),
(14,1014,1,1,2100),
(15,1015,2,1,1000),
(16,1016,5,1,950),
(17,1017,1,1,1700),
(18,1018,3,2,425),
(19,1019,1,1,2400),
(20,1020,2,1,1500);
GO


/* ============================================================
   Product Price History
   Purpose:
   Previous price
   Next price
   First price
   Last price
   Price increase/decrease
   Historical analysis
   ============================================================ */
CREATE TABLE product.ProductPriceHistory
(
    PriceHistoryID INT PRIMARY KEY,
    ProductID      INT,
    EffectiveDate  DATE,
    Price          DECIMAL(10,2)
);
GO

INSERT INTO product.ProductPriceHistory
VALUES
(1,1,'2024-01-01',1000),
(2,1,'2024-02-01',1100),
(3,1,'2024-03-01',1200),
(4,1,'2024-04-01',1150),
(5,1,'2024-05-01',1300),

(6,2,'2024-01-01',700),
(7,2,'2024-02-01',750),
(8,2,'2024-03-01',800),
(9,2,'2024-04-01',850),
(10,2,'2024-05-01',900),

(11,3,'2024-01-01',200),
(12,3,'2024-02-01',220),
(13,3,'2024-03-01',210),
(14,3,'2024-04-01',250);
GO

/* ============================================================
   Employee Salary History
   Purpose:
   Employee career history
   Previous salary
   Next salary
   First salary
   Last salary
   Salary increase detection
   ============================================================ */
CREATE TABLE hr.EmployeeSalaryHistory
(
    SalaryHistoryID INT PRIMARY KEY,
    EmployeeID      INT,
    EmployeeName    VARCHAR(100),
    EffectiveDate   DATE,
    Department      VARCHAR(50),
    Salary          DECIMAL(12,2)
);
GO

INSERT INTO hr.EmployeeSalaryHistory
VALUES
(1,201,'Ali','2023-01-01','IT',800),
(2,201,'Ali','2024-01-01','IT',950),
(3,201,'Ali','2025-01-01','IT',1100),

(4,202,'Sara','2023-01-01','Finance',900),
(5,202,'Sara','2024-06-01','Finance',1000),
(6,202,'Sara','2025-01-01','Finance',1200),

(7,203,'Omar','2023-01-01','Sales',750),
(8,203,'Omar','2024-01-01','Sales',800),
(9,203,'Omar','2025-01-01','Sales',950);
GO



/* ============================================================
   Employee Event History
   Purpose:
   Employee status transition এবং career journey
   ============================================================ */

CREATE TABLE hr.EmployeeEvents
(
    EventID        INT PRIMARY KEY,
    EmployeeID     INT,
    EventDate      DATE,
    EventType      VARCHAR(50),
    Department     VARCHAR(50)
);
GO

INSERT INTO hr.EmployeeEvents
VALUES
(1,201,'2023-01-01','Joined','IT'),
(2,201,'2024-01-01','Promotion','IT'),
(3,201,'2025-01-01','Transfer','Data'),

(4,202,'2023-01-01','Joined','Finance'),
(5,202,'2024-06-01','Promotion','Finance'),
(6,202,'2025-01-01','Transfer','Audit');
GO

/* ============================================================
   Bank Transactions
   Purpose:
   Transaction sequence analysis
   Previous balance
   Next transaction
   Running historical analysis
   ============================================================ */
CREATE TABLE banking.BankTransactions
(
    TransactionID   INT PRIMARY KEY,
    AccountID       INT,
    TransactionDate DATETIME,
    TransactionType VARCHAR(20),
    Amount          DECIMAL(12,2)
);
GO

INSERT INTO banking.BankTransactions
VALUES
(1,501,'2024-01-01 09:00','Deposit',1000),
(2,501,'2024-01-02 10:00','Withdraw',200),
(3,501,'2024-01-03 11:00','Deposit',500),
(4,501,'2024-01-05 09:30','Withdraw',100),
(5,501,'2024-01-07 14:00','Deposit',800),

(6,502,'2024-01-01 10:00','Deposit',2000),
(7,502,'2024-01-03 12:00','Withdraw',300),
(8,502,'2024-01-05 15:00','Withdraw',400);
GO


/* ============================================================
   Inventory Movement
   Purpose:
   Inventory event sequence
   Previous stock movement
   Next stock movement
   ============================================================ */
CREATE TABLE inventory.InventoryMovement
(
    MovementID     INT PRIMARY KEY,
    ProductID      INT,
    MovementDate   DATE,
    MovementType   VARCHAR(20),
    Quantity       INT
);
GO

INSERT INTO inventory.InventoryMovement
VALUES
(1,1,'2024-01-01','IN',100),
(2,1,'2024-01-05','OUT',20),
(3,1,'2024-01-10','OUT',15),
(4,1,'2024-01-15','IN',50),
(5,1,'2024-01-20','OUT',30),

(6,2,'2024-01-01','IN',200),
(7,2,'2024-01-05','OUT',40),
(8,2,'2024-01-12','OUT',30);
GO

