/* TransactionsDB
│
├── Banking
│   ├── Accounts
│   └── Transfers
│
├── Sales
│   ├── Customers
│   ├── Orders
│   └── OrderItems
│
├── Inventory
│   ├── Products
│   └── Stock
│
└── ETL
    ├── StagingOrders
    └── ETL_Audit */


-- ============================================================
-- Create TransactionsDB
-- ============================================================

CREATE DATABASE TransactionsDB;
GO

USE TransactionsDB;
GO

-- ============================================================
-- Create Business Schemas
-- ============================================================

USE TransactionsDB;
GO

CREATE SCHEMA Banking;
GO

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Inventory;
GO

CREATE SCHEMA ETL;
GO


-- ============================================================
-- Customer Master Table
-- ============================================================
CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150),
    Country VARCHAR(50),
    CreditLimit DECIMAL(18,2),
    IsActive BIT DEFAULT 1
);
GO


-- ============================================================
-- Sales Order Header
-- ============================================================
CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    OrderDate DATE NOT NULL,
    OrderStatus VARCHAR(30) NOT NULL,
    TotalAmount DECIMAL(18,2) DEFAULT 0,

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID)
);
GO



-- ============================================================
-- Sales Order Detail
-- ============================================================
CREATE TABLE Sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL,

    CONSTRAINT FK_OrderItems_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID)
);
GO


-- ============================================================
-- Bank Account Master
-- ============================================================
CREATE TABLE Banking.Accounts
(
    AccountID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    AccountNumber VARCHAR(30) UNIQUE NOT NULL,
    Balance DECIMAL(18,2) NOT NULL,
    AccountStatus VARCHAR(20) DEFAULT 'Active'
);
GO


-- ============================================================
-- Bank Transfer Transaction History
-- ============================================================
CREATE TABLE Banking.Transfers
(
    TransferID INT IDENTITY(1,1) PRIMARY KEY,
    FromAccountID INT NOT NULL,
    ToAccountID INT NOT NULL,
    Amount DECIMAL(18,2) NOT NULL,
    TransferDate DATETIME2 DEFAULT SYSDATETIME(),
    TransferStatus VARCHAR(20)
);
GO



-- ============================================================
-- Product Master
-- ============================================================

CREATE TABLE Inventory.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    UnitPrice DECIMAL(18,2) NOT NULL
);
GO


-- ============================================================
-- Current Inventory Stock
-- ============================================================
CREATE TABLE Inventory.Stock
(
    ProductID INT PRIMARY KEY,
    QuantityOnHand INT NOT NULL,
    ReorderLevel INT NOT NULL
);
GO


-- ============================================================
-- Customers
-- ============================================================

INSERT INTO Sales.Customers
(
    CustomerID,
    CustomerName,
    Email,
    Country,
    CreditLimit
)
VALUES
(1, 'Ahmed Ali', 'ahmed@company.com', 'Kuwait', 5000),
(2, 'Rahim Khan', 'rahim@company.com', 'Bangladesh', 3000),
(3, 'John Smith', 'john@company.com', 'USA', 10000);
GO


-- ============================================================
-- Products
-- ============================================================

INSERT INTO Inventory.Products
(
    ProductID,
    ProductName,
    UnitPrice
)
VALUES
(101, 'Laptop', 1200),
(102, 'Monitor', 400),
(103, 'Keyboard', 80),
(104, 'Mouse', 40);
GO


-- ============================================================
-- Inventory
-- ============================================================

INSERT INTO Inventory.Stock
VALUES
(101, 50, 10),
(102, 100, 20),
(103, 200, 30),
(104, 300, 50);
GO


-- ============================================================
-- Bank Accounts
-- ============================================================

INSERT INTO Banking.Accounts
(
    AccountID,
    CustomerID,
    AccountNumber,
    Balance
)
VALUES
(101, 1, 'KW-10001', 5000),
(102, 2, 'KW-10002', 3000),
(103, 3, 'US-10003', 10000);
GO

