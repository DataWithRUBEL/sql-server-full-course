Create Database Sales_AnalyticsNF

/* ============================================================
   SQL SERVER NUMBER FUNCTIONS
   Real Business Example: Retail Sales Analytics
   ============================================================ */


/* ============================================================
   1. PRODUCTS TABLE
   ============================================================ */

CREATE TABLE Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitCost DECIMAL(10,2),
    UnitPrice DECIMAL(10,2)
);
GO


/* ============================================================
   2. SALES TABLE
   ============================================================ */

CREATE TABLE Sales
(
    SaleID INT PRIMARY KEY,
    ProductID INT,
    Quantity INT,
    UnitPrice DECIMAL(10,2),
    DiscountAmount DECIMAL(10,2),
    TargetAmount DECIMAL(12,2),

    CONSTRAINT FK_Sales_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO


/* ============================================================
   3. STORE LOCATIONS TABLE
   Geographic calculations-এর জন্য
   ============================================================ */

CREATE TABLE StoreLocations
(
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100),
    Latitude DECIMAL(10,6),
    Longitude DECIMAL(10,6)
);
GO



/* ============================================================
   PRODUCTS DATA
   ============================================================ */

INSERT INTO Products
(
    ProductID,
    ProductName,
    Category,
    UnitCost,
    UnitPrice
)
VALUES
(101, 'Bottle',  'Accessories',  7.50, 10.00),
(102, 'Tire',    'Accessories', 11.00, 15.00),
(103, 'Socks',   'Clothing',     13.00, 20.00),
(104, 'Caps',    'Clothing',     17.00, 25.00),
(105, 'Gloves',  'Clothing',     21.00, 30.00);
GO


/* ============================================================
   SALES DATA
   ============================================================ */

INSERT INTO Sales
(
    SaleID,
    ProductID,
    Quantity,
    UnitPrice,
    DiscountAmount,
    TargetAmount
)
VALUES
(1,  101, 10, 10.00,  5.00, 100.00),
(2,  102,  7, 15.00,  3.00, 120.00),
(3,  103, 15, 20.00, 10.00, 250.00),
(4,  104,  8, 25.00,  5.00, 220.00),
(5,  105,  5, 30.00,  8.00, 180.00),
(6,  101, 20, 10.00, 15.00, 180.00),
(7,  102, 12, 15.00,  7.00, 200.00),
(8,  103,  4, 20.00,  2.00, 100.00),
(9,  104, 10, 25.00, 12.00, 250.00),
(10, 105, 0, 30.00,  0.00,   0.00);
GO


/* ============================================================
   STORE LOCATION DATA
   ============================================================ */

INSERT INTO StoreLocations
(
    StoreID,
    StoreName,
    Latitude,
    Longitude
)
VALUES
(1, 'Kuwait City Store', 29.375900, 47.977400),
(2, 'Al Farwaniyah Store', 29.277500, 47.958600),
(3, 'Hawally Store', 29.332700, 48.028700);
GO


















