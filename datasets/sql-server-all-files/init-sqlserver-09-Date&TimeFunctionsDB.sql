-- নতুন Date & Time practice database তৈরি করা হচ্ছে
CREATE DATABASE Date&TimeFunctionsDB;
GO

-- নতুন database-এ প্রবেশ করছি
USE Date&TimeFunctionsDB;
GO


-- Sales সম্পর্কিত table রাখার জন্য sales schema তৈরি
CREATE SCHEMA sales;
GO

-- HR সম্পর্কিত table রাখার জন্য hr schema তৈরি
CREATE SCHEMA hr;
GO

-- ETL সম্পর্কিত table রাখার জন্য etl schema তৈরি
CREATE SCHEMA etl;
GO


-- Customer registration এবং profile date/time সংরক্ষণের জন্য table
CREATE TABLE sales.Customers
(
    CustomerID       INT PRIMARY KEY,
    CustomerName     VARCHAR(100) NOT NULL,
    Country          VARCHAR(50) NOT NULL,
    SignupDate       DATE NOT NULL,
    SignupTime       TIME(0) NULL,
    CreatedAt        DATETIME2(3) NOT NULL,
    LocalCreatedAt   DATETIMEOFFSET(3) NULL
);
GO

-- Product information এবং price সংরক্ষণের জন্য table
CREATE TABLE sales.Products
(
    ProductID    INT PRIMARY KEY,
    ProductName  VARCHAR(100) NOT NULL,
    Category     VARCHAR(50) NOT NULL,
    UnitPrice    DECIMAL(10,2) NOT NULL
);
GO

-- Customer order এবং বিভিন্ন date/time scenario practice করার জন্য table
CREATE TABLE sales.Orders
(
    OrderID             BIGINT PRIMARY KEY,
    CustomerID          INT NOT NULL,
    ProductID           INT NOT NULL,
    Quantity             INT NOT NULL,

    -- শুধু date
    OrderDate            DATE NOT NULL,

    -- শুধু time
    OrderTime            TIME(3) NOT NULL,

    -- পুরনো/general date-time type
    OrderDateTime        DATETIME NULL,

    -- বেশি precision-এর date-time
    OrderDateTime2       DATETIME2(3) NOT NULL,

    -- Time-zone offset সহ timestamp
    OrderDateTimeOffset  DATETIMEOFFSET(3) NOT NULL,

    -- Delivery information
    DeliveryDate         DATE NULL,
    DeliveryDateTime     DATETIME2(3) NULL,

    -- Nullable cancellation timestamp
    CancelledAt          DATETIME2(3) NULL,

    -- Optional coupon
    CouponCode           VARCHAR(30) NULL,

    FOREIGN KEY (CustomerID) REFERENCES sales.Customers(CustomerID),
    FOREIGN KEY (ProductID) REFERENCES sales.Products(ProductID)
);
GO


-- Order lifecycle যেমন Created, Paid, Shipped, Delivered track করার জন্য table
CREATE TABLE sales.OrderEvents
(
    EventID       BIGINT PRIMARY KEY,
    OrderID       BIGINT NOT NULL,
    EventType     VARCHAR(30) NOT NULL,
    EventTimeUTC  DATETIME2(3) NOT NULL,
    EventLocalTime DATETIMEOFFSET(3) NULL,

    FOREIGN KEY (OrderID) REFERENCES sales.Orders(OrderID)
);
GO

-- Employee attendance এবং shift duration analysis করার জন্য table
CREATE TABLE hr.EmployeeAttendance
(
    AttendanceID   INT PRIMARY KEY,
    EmployeeID     INT NOT NULL,
    EmployeeName   VARCHAR(100) NOT NULL,
    WorkDate       DATE NOT NULL,
    CheckIn        DATETIME2(3) NOT NULL,
    CheckOut       DATETIME2(3) NULL,
    TimeZoneName   VARCHAR(100) NULL
);
GO

-- ETL pipeline কখন শুরু/শেষ হয়েছে তা track করার জন্য table
CREATE TABLE etl.ETL_RunLog
(
    RunID          BIGINT IDENTITY(1,1) PRIMARY KEY,
    PipelineName   VARCHAR(100) NOT NULL,
    StartTimeUTC   DATETIME2(3) NOT NULL,
    EndTimeUTC     DATETIME2(3) NULL,
    Status         VARCHAR(20) NOT NULL,
    ErrorMessage   VARCHAR(500) NULL
);
GO

-- বাস্তব e-commerce customer scenario অনুযায়ী sample customer data insert
INSERT INTO sales.Customers
(
    CustomerID,
    CustomerName,
    Country,
    SignupDate,
    SignupTime,
    CreatedAt,
    LocalCreatedAt
)
VALUES
(1, 'Ahmed Hassan',   'Kuwait', '2026-01-05', '09:15:00',
 '2026-01-05 09:15:23.120', '2026-01-05 09:15:23.120 +03:00'),

(2, 'Sara Ali',       'UAE',    '2026-01-10', '14:30:00',
 '2026-01-10 14:30:12.450', '2026-01-10 14:30:12.450 +04:00'),

(3, 'Mohammed Rahman','Bangladesh', '2026-02-02', '10:05:00',
 '2026-02-02 10:05:44.225', '2026-02-02 10:05:44.225 +06:00'),

(4, 'John Smith',     'USA',    '2026-02-15', '16:20:00',
 '2026-02-15 16:20:15.500', '2026-02-15 16:20:15.500 -05:00'),

(5, 'Fatima Noor',    'Kuwait', '2026-03-01', '08:45:00',
 '2026-03-01 08:45:31.775', '2026-03-01 08:45:31.775 +03:00');
GO

-- E-commerce product master data insert করা হচ্ছে
INSERT INTO sales.Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice
)
VALUES
(101, 'Wireless Mouse',     'Electronics', 15.00),
(102, 'Mechanical Keyboard','Electronics', 55.00),
(103, 'USB-C Cable',        'Accessories', 10.00),
(104, 'Laptop Stand',       'Accessories', 35.00),
(105, 'Office Chair',       'Furniture',   120.00);
GO

-- বিভিন্ন date/time data type এবং NULL scenario practice করার জন্য order data
INSERT INTO sales.Orders
(
    OrderID,
    CustomerID,
    ProductID,
    Quantity,
    OrderDate,
    OrderTime,
    OrderDateTime,
    OrderDateTime2,
    OrderDateTimeOffset,
    DeliveryDate,
    DeliveryDateTime,
    CancelledAt,
    CouponCode
)
VALUES
(10001, 1, 101, 2,
 '2026-03-05', '09:15:30.125',
 '2026-03-05 09:15:30',
 '2026-03-05 09:15:30.125',
 '2026-03-05 09:15:30.125 +03:00',
 '2026-03-07',
 '2026-03-07 14:20:10.100',
 NULL,
 'WELCOME10'),

(10002, 2, 102, 1,
 '2026-03-08', '14:45:20.250',
 '2026-03-08 14:45:20',
 '2026-03-08 14:45:20.250',
 '2026-03-08 14:45:20.250 +04:00',
 '2026-03-10',
 '2026-03-10 16:30:00.500',
 NULL,
 NULL),

(10003, 3, 103, 3,
 '2026-03-15', '11:10:05.500',
 '2026-03-15 11:10:05',
 '2026-03-15 11:10:05.500',
 '2026-03-15 11:10:05.500 +06:00',
 '2026-03-18',
 '2026-03-18 10:05:30.250',
 NULL,
 'SAVE5'),

(10004, 4, 104, 1,
 '2026-04-02', '18:25:45.750',
 '2026-04-02 18:25:45',
 '2026-04-02 18:25:45.750',
 '2026-04-02 18:25:45.750 -05:00',
 NULL,
 NULL,
 '2026-04-02 20:00:00.000',
 NULL),

(10005, 5, 105, 2,
 '2026-04-10', '08:05:10.125',
 '2026-04-10 08:05:10',
 '2026-04-10 08:05:10.125',
 '2026-04-10 08:05:10.125 +03:00',
 '2026-04-13',
 '2026-04-13 13:45:22.350',
 NULL,
 'VIP20'),

(10006, 1, 103, 5,
 '2026-05-01', '21:30:15.333',
 '2026-05-01 21:30:15',
 '2026-05-01 21:30:15.333',
 '2026-05-01 21:30:15.333 +03:00',
 '2026-05-03',
 '2026-05-03 15:10:00.000',
 NULL,
 NULL),

(10007, 2, 101, 1,
 '2026-05-15', '07:50:45.900',
 '2026-05-15 07:50:45',
 '2026-05-15 07:50:45.900',
 '2026-05-15 07:50:45.900 +04:00',
 NULL,
 NULL,
 NULL,
 NULL),

(10008, 3, 102, 2,
 '2026-06-01', '13:20:10.150',
 '2026-06-01 13:20:10',
 '2026-06-01 13:20:10.150',
 '2026-06-01 13:20:10.150 +06:00',
 '2026-06-04',
 '2026-06-04 12:00:00.250',
 NULL,
 'SUMMER10');
GO




