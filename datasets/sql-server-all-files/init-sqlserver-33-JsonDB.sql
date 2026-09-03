/* =========================================================
   JSON SQL SERVER COMPLETE PRACTICE DATABASE
   Database : JsonDB
   Company  : GlobalMart
   Purpose  : Data Analyst + Data Engineer JSON Training
   ========================================================= */

USE master;
GO

/* ---------------------------------------------------------
   1. Create Database
   --------------------------------------------------------- */

IF DB_ID('JsonDB') IS NOT NULL
BEGIN
    ALTER DATABASE JsonDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE JsonDB;
END;
GO

CREATE DATABASE JsonDB;
GO

USE JsonDB;
GO

/* ---------------------------------------------------------
   2. Create Schemas
   --------------------------------------------------------- */

CREATE SCHEMA Sales;
GO

CREATE SCHEMA Product;
GO

CREATE SCHEMA HR;
GO

CREATE SCHEMA Integration;
GO

CREATE SCHEMA Bronze;
GO

CREATE SCHEMA Silver;
GO

CREATE SCHEMA Gold;
GO


/* =========================================================
   3. MASTER DATA
   ========================================================= */

/* ---------------------------------------------------------
   Categories
   --------------------------------------------------------- */

CREATE TABLE Product.Categories
(
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);
GO

INSERT INTO Product.Categories
(CategoryID, CategoryName)
VALUES
(1, 'Electronics'),
(2, 'Home Appliances'),
(3, 'Office Supplies'),
(4, 'Accessories'),
(5, 'Furniture');
GO


/* ---------------------------------------------------------
   Products
   --------------------------------------------------------- */

CREATE TABLE Product.Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(150) NOT NULL,
    CategoryID INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    StockQuantity INT NOT NULL,
    ProductAttributes NVARCHAR(MAX),

    CONSTRAINT FK_Products_Category
        FOREIGN KEY (CategoryID)
        REFERENCES Product.Categories(CategoryID),

    CONSTRAINT CK_Products_JSON
        CHECK
        (
            ProductAttributes IS NULL
            OR ISJSON(ProductAttributes) = 1
        )
);
GO

INSERT INTO Product.Products
(
    ProductID,
    ProductName,
    CategoryID,
    UnitPrice,
    StockQuantity,
    ProductAttributes
)
VALUES
(
    101,
    'Wireless Keyboard',
    1,
    45.00,
    250,
    N'{
        "brand":"Logitech",
        "color":"Black",
        "wireless":true,
        "dimensions":{"width":44,"height":14,"unit":"cm"},
        "tags":["keyboard","wireless","office"]
    }'
),
(
    102,
    'Wireless Mouse',
    1,
    25.00,
    400,
    N'{
        "brand":"Logitech",
        "color":"Black",
        "wireless":true,
        "dpi":1600,
        "tags":["mouse","wireless"]
    }'
),
(
    103,
    '27 Inch Monitor',
    1,
    220.00,
    100,
    N'{
        "brand":"Dell",
        "screen_size":27,
        "resolution":"2560x1440",
        "ports":["HDMI","DisplayPort"],
        "tags":["monitor","office"]
    }'
),
(
    104,
    'Office Chair',
    5,
    180.00,
    80,
    N'{
        "brand":"ErgoPro",
        "color":"Black",
        "adjustable":true,
        "features":["lumbar-support","armrest","headrest"]
    }'
),
(
    105,
    'Laptop Stand',
    4,
    35.00,
    300,
    N'{
        "brand":"BaseStand",
        "material":"Aluminium",
        "adjustable":true,
        "colors":["Silver","Black"]
    }'
),
(
    106,
    'Coffee Machine',
    2,
    150.00,
    60,
    N'{
        "brand":"Philips",
        "capacity_litre":1.5,
        "automatic":true,
        "features":["espresso","coffee","milk-frother"]
    }'
),
(
    107,
    'Printer',
    3,
    130.00,
    120,
    N'{
        "brand":"HP",
        "type":"Laser",
        "wifi":true,
        "print_speed_ppm":30
    }'
),
(
    108,
    'USB-C Hub',
    4,
    40.00,
    220,
    N'{
        "brand":"Anker",
        "ports":{
            "usb":3,
            "hdmi":1,
            "ethernet":1
        },
        "power_delivery":true
    }'
);
GO


/* =========================================================
   4. HR DATA
   ========================================================= */

/* ---------------------------------------------------------
   Departments
   --------------------------------------------------------- */

CREATE TABLE HR.Departments
(
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL
);
GO

INSERT INTO HR.Departments
VALUES
(10, 'Sales'),
(20, 'IT'),
(30, 'Finance'),
(40, 'Operations'),
(50, 'Customer Service');
GO


/* ---------------------------------------------------------
   Employees
   --------------------------------------------------------- */

CREATE TABLE HR.Employees
(
    EmployeeID INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    JobTitle VARCHAR(100),
    ManagerID INT NULL,

    FOREIGN KEY (DepartmentID)
        REFERENCES HR.Departments(DepartmentID)
);
GO

INSERT INTO HR.Employees
VALUES
(1001, 'Omar Hassan', 10, 'Sales Manager', NULL),
(1002, 'Sara Ali', 10, 'Sales Executive', 1001),
(1003, 'John Mathew', 10, 'Sales Executive', 1001),
(1004, 'David Joseph', 20, 'Data Engineer', NULL),
(1005, 'Maya Khan', 20, 'Database Developer', 1004),
(1006, 'Noor Ahmed', 50, 'Customer Support', NULL),
(1007, 'Lina George', 40, 'Operations Executive', NULL);
GO


/* =========================================================
   5. CUSTOMER DATA
   ========================================================= */

CREATE TABLE Sales.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(150) NOT NULL,
    Email VARCHAR(200),
    Country VARCHAR(100),
    City VARCHAR(100),
    CustomerType VARCHAR(30),
    CreatedDate DATE,
    CustomerProfile NVARCHAR(MAX),

    CONSTRAINT CK_Customers_JSON
        CHECK
        (
            CustomerProfile IS NULL
            OR ISJSON(CustomerProfile) = 1
        )
);
GO

INSERT INTO Sales.Customers
VALUES
(
    10001,
    'Ahmed Hassan',
    'ahmed@example.com',
    'Kuwait',
    'Kuwait City',
    'Retail',
    '2026-01-05',
    N'{
        "phone":"+96550000001",
        "preferences":{
            "language":"English",
            "newsletter":true
        },
        "loyalty":{
            "tier":"Gold",
            "points":4500
        }
    }'
),
(
    10002,
    'Fatima Ali',
    'fatima@example.com',
    'Kuwait',
    'Hawally',
    'Retail',
    '2026-01-10',
    N'{
        "phone":"+96550000002",
        "preferences":{
            "language":"Arabic",
            "newsletter":false
        },
        "loyalty":{
            "tier":"Silver",
            "points":2100
        }
    }'
),
(
    10003,
    'Michael John',
    'michael@example.com',
    'UAE',
    'Dubai',
    'Corporate',
    '2026-01-15',
    N'{
        "phone":"+97150000003",
        "preferences":{
            "language":"English",
            "newsletter":true
        },
        "loyalty":{
            "tier":"Platinum",
            "points":8500
        }
    }'
),
(
    10004,
    'Sara Mohammed',
    'sara@example.com',
    'Saudi Arabia',
    'Riyadh',
    'Retail',
    '2026-02-01',
    N'{
        "phone":"+96650000004",
        "preferences":{
            "language":"Arabic",
            "newsletter":true
        },
        "loyalty":{
            "tier":"Bronze",
            "points":800
        }
    }'
),
(
    10005,
    'Daniel Thomas',
    'daniel@example.com',
    'Qatar',
    'Doha',
    'Corporate',
    '2026-02-12',
    N'{
        "phone":"+97450000005",
        "preferences":{
            "language":"English",
            "newsletter":true
        },
        "loyalty":{
            "tier":"Gold",
            "points":3900
        }
    }'
);
GO


/* =========================================================
   6. ORDERS
   ========================================================= */

CREATE TABLE Sales.Orders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT NOT NULL,
    EmployeeID INT NULL,
    OrderDate DATETIME2 NOT NULL,
    OrderStatus VARCHAR(30),
    PaymentMethod VARCHAR(30),
    ShippingAddress NVARCHAR(MAX),
    OrderMetadata NVARCHAR(MAX),

    FOREIGN KEY (CustomerID)
        REFERENCES Sales.Customers(CustomerID),

    FOREIGN KEY (EmployeeID)
        REFERENCES HR.Employees(EmployeeID),

    CONSTRAINT CK_Orders_Address_JSON
        CHECK (ISJSON(ShippingAddress) = 1),

    CONSTRAINT CK_Orders_Metadata_JSON
        CHECK (ISJSON(OrderMetadata) = 1)
);
GO

INSERT INTO Sales.Orders
VALUES
(
    50001,
    10001,
    1002,
    '2026-03-01 10:15:00',
    'Completed',
    'CreditCard',

    N'{
        "street":"Salmiya Street",
        "city":"Kuwait City",
        "country":"Kuwait",
        "postal_code":"10001"
    }',

    N'{
        "channel":"Website",
        "coupon":"WELCOME10",
        "priority":"High",
        "device":{
            "type":"Mobile",
            "os":"Android"
        }
    }'
),
(
    50002,
    10002,
    1003,
    '2026-03-02 11:30:00',
    'Completed',
    'KNET',

    N'{
        "street":"Tunis Street",
        "city":"Hawally",
        "country":"Kuwait",
        "postal_code":"32001"
    }',

    N'{
        "channel":"MobileApp",
        "coupon":null,
        "priority":"Normal",
        "device":{
            "type":"Mobile",
            "os":"iOS"
        }
    }'
),
(
    50003,
    10003,
    1002,
    '2026-03-03 15:20:00',
    'Shipped',
    'CreditCard',

    N'{
        "street":"Downtown",
        "city":"Dubai",
        "country":"UAE",
        "postal_code":"00001"
    }',

    N'{
        "channel":"Website",
        "coupon":"CORP20",
        "priority":"High",
        "device":{
            "type":"Desktop",
            "os":"Windows"
        }
    }'
),
(
    50004,
    10004,
    1003,
    '2026-03-04 09:40:00',
    'Pending',
    'BankTransfer',

    N'{
        "street":"King Fahd Road",
        "city":"Riyadh",
        "country":"Saudi Arabia",
        "postal_code":"12001"
    }',

    N'{
        "channel":"Website",
        "coupon":null,
        "priority":"Normal",
        "device":{
            "type":"Desktop",
            "os":"Windows"
        }
    }'
),
(
    50005,
    10005,
    1002,
    '2026-03-05 18:10:00',
    'Completed',
    'CreditCard',

    N'{
        "street":"West Bay",
        "city":"Doha",
        "country":"Qatar",
        "postal_code":"22001"
    }',

    N'{
        "channel":"MobileApp",
        "coupon":"QATAR15",
        "priority":"High",
        "device":{
            "type":"Mobile",
            "os":"Android"
        }
    }'
);
GO


/* =========================================================
   7. ORDER ITEMS
   ========================================================= */

CREATE TABLE Sales.OrderItems
(
    OrderItemID INT PRIMARY KEY,
    OrderID INT NOT NULL,
    ProductID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,

    FOREIGN KEY (OrderID)
        REFERENCES Sales.Orders(OrderID),

    FOREIGN KEY (ProductID)
        REFERENCES Product.Products(ProductID)
);
GO

INSERT INTO Sales.OrderItems
VALUES
(1, 50001, 101, 2, 45.00),
(2, 50001, 102, 1, 25.00),

(3, 50002, 103, 1, 220.00),
(4, 50002, 105, 2, 35.00),

(5, 50003, 103, 2, 220.00),
(6, 50003, 104, 1, 180.00),
(7, 50003, 108, 2, 40.00),

(8, 50004, 107, 1, 130.00),
(9, 50004, 105, 1, 35.00),

(10, 50005, 106, 2, 150.00),
(11, 50005, 108, 3, 40.00);
GO


/* =========================================================
   8. JSON STAGING TABLE
   ========================================================= */

CREATE TABLE Integration.JsonStaging
(
    StagingID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SourceSystem VARCHAR(100),
    FileName VARCHAR(255),
    LoadDateTime DATETIME2 DEFAULT SYSDATETIME(),
    JsonPayload NVARCHAR(MAX),

    CONSTRAINT CK_JsonStaging_JSON
        CHECK (ISJSON(JsonPayload) = 1)
);
GO


/* =========================================================
   9. API LOG TABLE
   ========================================================= */

CREATE TABLE Integration.ApiLogs
(
    ApiLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ApiName VARCHAR(200),
    RequestMethod VARCHAR(20),
    RequestDateTime DATETIME2,
    ResponseStatus INT,
    ResponsePayload NVARCHAR(MAX),

    CONSTRAINT CK_ApiLogs_JSON
        CHECK
        (
            ResponsePayload IS NULL
            OR ISJSON(ResponsePayload) = 1
        )
);
GO


/* =========================================================
   10. BRONZE TABLE
   ========================================================= */

CREATE TABLE Bronze.JsonRawOrders
(
    BronzeID BIGINT IDENTITY(1,1) PRIMARY KEY,
    SourceFile VARCHAR(255),
    LoadDateTime DATETIME2 DEFAULT SYSDATETIME(),
    JsonPayload NVARCHAR(MAX),

    CONSTRAINT CK_Bronze_JSON
        CHECK (ISJSON(JsonPayload) = 1)
);
GO


/* =========================================================
   11. SILVER TABLE
   ========================================================= */

CREATE TABLE Silver.CleanOrders
(
    OrderID INT PRIMARY KEY,
    CustomerID INT,
    OrderDate DATETIME2,
    OrderStatus VARCHAR(30),
    PaymentMethod VARCHAR(30),
    ShippingCity VARCHAR(100),
    ShippingCountry VARCHAR(100),
    SalesChannel VARCHAR(50),
    Coupon VARCHAR(100),
    Priority VARCHAR(30),
    LoadDateTime DATETIME2 DEFAULT SYSDATETIME()
);
GO


/* =========================================================
   12. GOLD FACT TABLE
   ========================================================= */

CREATE TABLE Gold.FactSales
(
    SalesKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT,
    CustomerID INT,
    ProductID INT,
    OrderDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(12,2),
    SalesAmount AS
        CONVERT(DECIMAL(18,2), Quantity * UnitPrice)
);
GO
