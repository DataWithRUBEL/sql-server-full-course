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


-- Order lifecycle-এর বিভিন্ন event insert করা হচ্ছে
-- EventTimeUTC UTC-তে রাখা হচ্ছে এবং EventLocalTime local timezone সহ রাখা হচ্ছে

INSERT INTO sales.OrderEvents
(
    EventID,
    OrderID,
    EventType,
    EventTimeUTC,
    EventLocalTime
)
VALUES

-- Order 10001
(1, 10001, 'Created',
 '2026-01-08 06:15:30.125',
 '2026-01-08 09:15:30.125 +03:00'),

(2, 10001, 'Paid',
 '2026-01-08 06:20:15.250',
 '2026-01-08 09:20:15.250 +03:00'),

(3, 10001, 'Shipped',
 '2026-01-09 05:30:10.500',
 '2026-01-09 08:30:10.500 +03:00'),

(4, 10001, 'Delivered',
 '2026-01-10 11:20:10.100',
 '2026-01-10 14:20:10.100 +03:00'),

-- Order 10002
(5, 10002, 'Created',
 '2026-01-15 10:45:20.250',
 '2026-01-15 14:45:20.250 +04:00'),

(6, 10002, 'Paid',
 '2026-01-15 10:50:00.000',
 '2026-01-15 14:50:00.000 +04:00'),

(7, 10002, 'Shipped',
 '2026-01-16 09:15:30.500',
 '2026-01-16 13:15:30.500 +04:00'),

(8, 10002, 'Delivered',
 '2026-01-18 12:30:00.500',
 '2026-01-18 16:30:00.500 +04:00'),

-- Order 10003
(9, 10003, 'Created',
 '2026-02-05 05:10:05.500',
 '2026-02-05 11:10:05.500 +06:00'),

(10, 10003, 'Paid',
 '2026-02-05 05:15:25.250',
 '2026-02-05 11:15:25.250 +06:00'),

(11, 10003, 'Shipped',
 '2026-02-06 06:30:00.000',
 '2026-02-06 12:30:00.000 +06:00'),

(12, 10003, 'Delivered',
 '2026-02-08 04:05:30.250',
 '2026-02-08 10:05:30.250 +06:00'),

-- Order 10004 - Cancelled
(13, 10004, 'Created',
 '2026-02-20 23:25:45.750',
 '2026-02-20 18:25:45.750 -05:00'),

(14, 10004, 'Paid',
 '2026-02-20 23:30:00.000',
 '2026-02-20 18:30:00.000 -05:00'),

(15, 10004, 'Cancelled',
 '2026-02-21 01:00:00.000',
 '2026-02-20 20:00:00.000 -05:00'),

-- Order 10005
(16, 10005, 'Created',
 '2026-03-03 05:05:10.125',
 '2026-03-03 08:05:10.125 +03:00'),

(17, 10005, 'Paid',
 '2026-03-03 05:10:30.000',
 '2026-03-03 08:10:30.000 +03:00'),

(18, 10005, 'Shipped',
 '2026-03-04 06:20:00.000',
 '2026-03-04 09:20:00.000 +03:00'),

(19, 10005, 'Delivered',
 '2026-03-06 10:45:22.350',
 '2026-03-06 13:45:22.350 +03:00'),

-- Order 10006
(20, 10006, 'Created',
 '2026-03-10 18:30:15.333',
 '2026-03-10 21:30:15.333 +03:00'),

(21, 10006, 'Paid',
 '2026-03-10 18:35:00.000',
 '2026-03-10 21:35:00.000 +03:00'),

(22, 10006, 'Shipped',
 '2026-03-11 07:15:00.000',
 '2026-03-11 10:15:00.000 +03:00'),

(23, 10006, 'Delivered',
 '2026-03-13 12:10:00.000',
 '2026-03-13 15:10:00.000 +03:00'),

-- Order 10007 - Pending
(24, 10007, 'Created',
 '2026-03-18 11:50:45.900',
 '2026-03-18 07:50:45.900 -04:00'),

(25, 10007, 'Paid',
 '2026-03-18 11:55:00.000',
 '2026-03-18 07:55:00.000 -04:00'),

-- Order 10008
(26, 10008, 'Created',
 '2026-04-02 10:20:10.150',
 '2026-04-02 13:20:10.150 +03:00'),

(27, 10008, 'Paid',
 '2026-04-02 10:25:00.000',
 '2026-04-02 13:25:00.000 +03:00'),

(28, 10008, 'Shipped',
 '2026-04-03 08:00:00.000',
 '2026-04-03 11:00:00.000 +03:00'),

(29, 10008, 'Delivered',
 '2026-04-04 09:00:00.250',
 '2026-04-04 12:00:00.250 +03:00'),

-- Order 10009
(30, 10009, 'Created',
 '2026-04-12 04:30:25.500',
 '2026-04-12 10:30:25.500 +06:00'),

(31, 10009, 'Paid',
 '2026-04-12 04:35:00.000',
 '2026-04-12 10:35:00.000 +06:00'),

(32, 10009, 'Shipped',
 '2026-04-14 05:15:00.000',
 '2026-04-14 11:15:00.000 +06:00'),

(33, 10009, 'Delivered',
 '2026-04-16 05:15:00.125',
 '2026-04-16 11:15:00.125 +06:00'),

-- Order 10010
(34, 10010, 'Created',
 '2026-04-25 15:40:35.750',
 '2026-04-25 16:40:35.750 +01:00'),

(35, 10010, 'Paid',
 '2026-04-25 15:45:00.000',
 '2026-04-25 16:45:00.000 +01:00'),

(36, 10010, 'Shipped',
 '2026-04-27 14:00:00.000',
 '2026-04-27 15:00:00.000 +01:00'),

(37, 10010, 'Delivered',
 '2026-05-01 13:00:00.500',
 '2026-05-01 14:00:00.500 +01:00'),

-- Order 10011
(38, 10011, 'Created',
 '2026-05-03 06:05:15.250',
 '2026-05-03 09:05:15.250 +03:00'),

(39, 10011, 'Paid',
 '2026-05-03 06:10:00.000',
 '2026-05-03 09:10:00.000 +03:00'),

(40, 10011, 'Delivered',
 '2026-05-05 12:30:00.000',
 '2026-05-05 15:30:00.000 +03:00'),

-- Order 10012 - Pending
(41, 10012, 'Created',
 '2026-05-15 03:50:45.900',
 '2026-05-15 07:50:45.900 +04:00'),

(42, 10012, 'Paid',
 '2026-05-15 03:55:00.000',
 '2026-05-15 07:55:00.000 +04:00'),

-- Order 10013
(43, 10013, 'Created',
 '2026-06-01 07:20:10.150',
 '2026-06-01 13:20:10.150 +06:00'),

(44, 10013, 'Paid',
 '2026-06-01 07:25:00.000',
 '2026-06-01 13:25:00.000 +06:00'),

(45, 10013, 'Shipped',
 '2026-06-02 06:00:00.000',
 '2026-06-02 12:00:00.000 +06:00'),

(46, 10013, 'Delivered',
 '2026-06-03 06:00:00.250',
 '2026-06-03 12:00:00.250 +06:00'),

-- Order 10014
(47, 10014, 'Created',
 '2026-06-12 14:15:30.300',
 '2026-06-12 17:15:30.300 +03:00'),

(48, 10014, 'Paid',
 '2026-06-12 14:20:00.000',
 '2026-06-12 17:20:00.000 +03:00'),

(49, 10014, 'Shipped',
 '2026-06-15 10:00:00.000',
 '2026-06-15 13:00:00.000 +03:00'),

(50, 10014, 'Delivered',
 '2026-06-20 13:20:00.000',
 '2026-06-20 16:20:00.000 +03:00'),

-- Order 10015 - Pending
(51, 10015, 'Created',
 '2026-06-25 17:45:55.600',
 '2026-06-25 20:45:55.600 +03:00'),

(52, 10015, 'Paid',
 '2026-06-25 17:50:00.000',
 '2026-06-25 20:50:00.000 +03:00');
GO

-- Employee attendance-এর realistic business data insert করা হচ্ছে
-- Late arrival, normal shift এবং missing checkout scenario রাখা হয়েছে

INSERT INTO hr.EmployeeAttendance
(
    AttendanceID,
    EmployeeID,
    EmployeeName,
    WorkDate,
    CheckIn,
    CheckOut,
    TimeZoneName
)
VALUES

(1,  501, 'Ahmed Hassan',
 '2026-08-24',
 '2026-08-24 08:02:15.100',
 '2026-08-24 17:05:20.250',
 'Arab Standard Time'),

(2,  502, 'Sara Ali',
 '2026-08-24',
 '2026-08-24 08:15:30.000',
 '2026-08-24 17:10:45.500',
 'Arab Standard Time'),

(3,  503, 'Mohammed Rahman',
 '2026-08-24',
 '2026-08-24 08:05:10.250',
 '2026-08-24 16:55:30.000',
 'Bangladesh Standard Time'),

(4,  504, 'John Smith',
 '2026-08-24',
 '2026-08-24 09:05:45.500',
 '2026-08-24 18:10:15.250',
 'Eastern Standard Time'),

(5,  505, 'Fatima Noor',
 '2026-08-24',
 '2026-08-24 07:55:20.125',
 '2026-08-24 16:30:00.000',
 'Arab Standard Time'),

(6,  501, 'Ahmed Hassan',
 '2026-08-25',
 '2026-08-25 08:12:10.300',
 '2026-08-25 17:15:45.500',
 'Arab Standard Time'),

(7,  502, 'Sara Ali',
 '2026-08-25',
 '2026-08-25 08:01:25.000',
 '2026-08-25 16:55:30.250',
 'Arab Standard Time'),

(8,  503, 'Mohammed Rahman',
 '2026-08-25',
 '2026-08-25 08:20:15.750',
 '2026-08-25 17:20:10.500',
 'Bangladesh Standard Time'),

(9,  504, 'John Smith',
 '2026-08-25',
 '2026-08-25 08:45:00.000',
 NULL,
 'Eastern Standard Time'),

(10, 505, 'Fatima Noor',
 '2026-08-25',
 '2026-08-25 08:05:35.125',
 '2026-08-25 17:02:15.750',
 'Arab Standard Time'),

(11, 501, 'Ahmed Hassan',
 '2026-08-26',
 '2026-08-26 08:00:10.000',
 '2026-08-26 17:00:00.000',
 'Arab Standard Time'),

(12, 502, 'Sara Ali',
 '2026-08-26',
 '2026-08-26 08:25:45.500',
 '2026-08-26 17:30:20.125',
 'Arab Standard Time'),

(13, 503, 'Mohammed Rahman',
 '2026-08-26',
 '2026-08-26 08:03:15.250',
 '2026-08-26 16:45:30.000',
 'Bangladesh Standard Time'),

(14, 504, 'John Smith',
 '2026-08-26',
 '2026-08-26 08:55:20.750',
 '2026-08-26 18:05:10.500',
 'Eastern Standard Time'),

(15, 505, 'Fatima Noor',
 '2026-08-26',
 '2026-08-26 07:50:00.000',
 '2026-08-26 16:40:45.250',
 'Arab Standard Time'),

(16, 501, 'Ahmed Hassan',
 '2026-08-27',
 '2026-08-27 08:18:30.125',
 '2026-08-27 17:20:00.000',
 'Arab Standard Time'),

(17, 502, 'Sara Ali',
 '2026-08-27',
 '2026-08-27 08:04:15.500',
 '2026-08-27 17:05:45.750',
 'Arab Standard Time'),

(18, 503, 'Mohammed Rahman',
 '2026-08-27',
 '2026-08-27 08:10:00.000',
 '2026-08-27 17:00:00.000',
 'Bangladesh Standard Time'),

(19, 504, 'John Smith',
 '2026-08-27',
 '2026-08-27 08:35:45.250',
 '2026-08-27 17:55:30.125',
 'Eastern Standard Time'),

(20, 505, 'Fatima Noor',
 '2026-08-27',
 '2026-08-27 08:00:20.500',
 '2026-08-27 16:50:15.000',
 'Arab Standard Time');
GO


-- ETL pipeline execution log-এর realistic data insert করা হচ্ছে
-- Success, Failed এবং Running pipeline scenario রাখা হয়েছে

INSERT INTO etl.ETL_RunLog
(
    PipelineName,
    StartTimeUTC,
    EndTimeUTC,
    Status,
    ErrorMessage
)
VALUES

-- Successful daily sales load
(
    'Sales_Daily_Load',
    '2026-08-24 01:00:00.000',
    '2026-08-24 01:18:35.250',
    'SUCCESS',
    NULL
),

-- Successful customer load
(
    'Customer_Daily_Load',
    '2026-08-24 01:30:00.000',
    '2026-08-24 01:42:15.500',
    'SUCCESS',
    NULL
),

-- Product load failed
(
    'Product_Daily_Load',
    '2026-08-24 02:00:00.000',
    '2026-08-24 02:05:20.125',
    'FAILED',
    'Source product file was not available'
),

-- Retry successful
(
    'Product_Daily_Load',
    '2026-08-24 03:00:00.000',
    '2026-08-24 03:08:45.750',
    'SUCCESS',
    NULL
),

-- Sales load
(
    'Sales_Daily_Load',
    '2026-08-25 01:00:00.000',
    '2026-08-25 01:22:10.500',
    'SUCCESS',
    NULL
),

-- Customer load
(
    'Customer_Daily_Load',
    '2026-08-25 01:30:00.000',
    '2026-08-25 01:40:25.250',
    'SUCCESS',
    NULL
),

-- Sales load failed
(
    'Sales_Daily_Load',
    '2026-08-26 01:00:00.000',
    '2026-08-26 01:04:55.125',
    'FAILED',
    'Source database connection timeout'
),

-- Retry
(
    'Sales_Daily_Load',
    '2026-08-26 01:30:00.000',
    '2026-08-26 01:55:30.750',
    'SUCCESS',
    NULL
),

-- Customer load
(
    'Customer_Daily_Load',
    '2026-08-26 02:00:00.000',
    '2026-08-26 02:12:45.500',
    'SUCCESS',
    NULL
),

-- Product load
(
    'Product_Daily_Load',
    '2026-08-26 02:30:00.000',
    '2026-08-26 02:38:20.250',
    'SUCCESS',
    NULL
),

-- Sales load
(
    'Sales_Daily_Load',
    '2026-08-27 01:00:00.000',
    '2026-08-27 01:20:15.125',
    'SUCCESS',
    NULL
),

-- Customer load failed
(
    'Customer_Daily_Load',
    '2026-08-27 01:30:00.000',
    '2026-08-27 01:34:40.500',
    'FAILED',
    'Duplicate customer key detected'
),

-- Retry
(
    'Customer_Daily_Load',
    '2026-08-27 02:00:00.000',
    '2026-08-27 02:15:30.250',
    'SUCCESS',
    NULL
),

-- Product load
(
    'Product_Daily_Load',
    '2026-08-27 02:30:00.000',
    '2026-08-27 02:39:10.750',
    'SUCCESS',
    NULL
),

-- Currently running pipeline
(
    'Sales_Daily_Load',
    '2026-08-29 01:00:00.000',
    NULL,
    'RUNNING',
    NULL
);
GO


-- 2026 সালের প্রতিটি দিনের Date Dimension তৈরি করা হচ্ছে
-- YEAR, MONTH, DAY, DATEPART, DATENAME, DATETRUNC এবং EOMONTH ব্যবহার করা হয়েছে

DECLARE @StartDate DATE = '2026-01-01';
DECLARE @EndDate   DATE = '2026-12-31';

;WITH DateSeries AS
(
    -- প্রথম date থেকে series শুরু করা হচ্ছে
    SELECT
        @StartDate AS FullDate

    UNION ALL

    -- প্রতিদিন 1 দিন করে date বাড়ানো হচ্ছে
    SELECT
        DATEADD(DAY, 1, FullDate)
    FROM DateSeries
    WHERE FullDate < @EndDate
)

INSERT INTO sales.DimDate
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    DayNumber,
    DayName,
    WeekNumber,
    MonthStart,
    MonthEnd
)
SELECT
    -- YYYYMMDD format-কে integer DateKey হিসেবে তৈরি করা হচ্ছে
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)),

    -- Full calendar date
    FullDate,

    -- Year number
    YEAR(FullDate),

    -- Quarter number
    DATEPART(QUARTER, FullDate),

    -- Month number
    MONTH(FullDate),

    -- Month name
    DATENAME(MONTH, FullDate),

    -- Day number
    DAY(FullDate),

    -- Day name
    DATENAME(WEEKDAY, FullDate),

    -- Week number
    DATEPART(WEEK, FullDate),

    -- Month-এর প্রথম date
    DATETRUNC(MONTH, FullDate),

    -- Month-এর শেষ date
    EOMONTH(FullDate)

FROM DateSeries
OPTION (MAXRECURSION 0);
GO
