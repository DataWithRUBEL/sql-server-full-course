ETL = Extract → Transform → Load
একটি real company-তে data সাধারণত এক জায়গায় থাকে না। যেমন:
- 🛒 E-commerce DB → Customers, Orders
- 📦 Inventory DB → Products, Stock
- 👨‍💼 HR DB → Employees
- 💳 Payment System → Payments
- 📄 CSV/Excel/API → External data
- 📊 Data Warehouse → Analytics + Power BI
ETL এই source system-গুলোর data সংগ্রহ করে → পরিষ্কার/রূপান্তর করে → Data Warehouse-এ load করে।



ETL Architecture
                SOURCE SYSTEMS
                     │
       ┌─────────────┼─────────────┐
       │             │             │
    SQL DB        CSV/Excel       API
       │             │             │
       └─────────────┼─────────────┘
                     ↓
                  EXTRACT
                     ↓
                STAGING AREA
                     ↓
                 TRANSFORM
                     ↓
              DATA QUALITY
                     ↓
                    LOAD
                     ↓
              DATA WAREHOUSE
              ┌──────┴──────┐
              │             │
           FACT          DIMENSION
              │             │
              └──────┬──────┘
                     ↓
                  POWER BI






Level 1 — SQL Fundamentals 🟢
ETL-এর আগে SQL foundation strong হতে হবে।
শিখবেন
- SELECT
- WHERE
- ORDER BY
- DISTINCT
- TOP
- GROUP BY
- HAVING
- CASE
- NULL
- CAST
- CONVERT
Example
-- ============================================================
-- BASIC SOURCE DATA EXTRACTION
-- ============================================================

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM source_system.Customers
WHERE Country = 'USA';






Level 2 — Advanced SQL 🔥
ETL transformation-এর জন্য:
- JOIN
- CTE
- Subquery
- Window Functions
- ROW_NUMBER
- RANK
- LAG
- LEAD
- Aggregate
- APPLY
- PIVOT
- UNPIVOT
- Dynamic SQL
- Temp Table
Example:
-- ============================================================
-- FIND CUSTOMER ORDER RANK
-- ============================================================

SELECT
    CustomerID,
    OrderID,
    TotalAmount,
    RANK() OVER
    (
        PARTITION BY CustomerID
        ORDER BY TotalAmount DESC
    ) AS OrderRank
FROM source_system.Orders;






Level 3 — Data Cleaning 🧹
ETL-এর সবচেয়ে গুরুত্বপূর্ণ transformation।
Common Problems
- NULL
- Duplicate
- Leading/trailing spaces
- Wrong datatype
- Invalid date
- Negative amount
- Invalid foreign key
- Inconsistent country
- Duplicate customer
Example:
-- ============================================================
-- CLEAN CUSTOMER NAME
-- ============================================================

SELECT
    CustomerID,
    TRIM(FirstName) AS FirstName,
    TRIM(LastName) AS LastName,
    LOWER(TRIM(Email)) AS Email
FROM source_system.Customers;







Level 4 — ETL Fundamentals
ETL কী?
Extract
   ↓
Transform
   ↓
Load
Extract
Source থেকে data নেওয়া।
Transform
Business rules অনুযায়ী data পরিবর্তন।
Load
Target database/data warehouse-এ data রাখা।






Level 5 — Source Systems
  
Real company-তে source হতে পারে:
  
Source	                Example
SQL Server	            ERP
Oracle	                Finance
PostgreSQL	            Application
CSV	                    Sales export
Excel	                  HR
API	                    Payment
JSON	                  Web application
XML	                    Legacy system


আমাদের:
source_system.Customers
source_system.Products
source_system.Employees
source_system.Orders
source_system.OrderItems
source_system.Payments






Level 6 — Extract
প্রথমে source থেকে data extract করব।
-- ============================================================
-- EXTRACT CUSTOMERS
-- ============================================================

SELECT *
FROM source_system.Customers;
Production ETL-এ সাধারণত:
Source
  ↓
Extract query
  ↓
Staging






Level 7 — Staging
Staging হলো ETL-এর temporary landing area।
-- ============================================================
-- CREATE STAGING CUSTOMER TABLE
-- ============================================================

CREATE TABLE staging.Customers
(
    CustomerID       INT,
    CustomerCode     VARCHAR(20),
    FirstName        VARCHAR(50),
    LastName         VARCHAR(50),
    Email            VARCHAR(150),
    Phone            VARCHAR(30),
    Country          VARCHAR(50),
    City             VARCHAR(50),
    CustomerType     VARCHAR(20),
    CreatedDate      DATETIME2,
    ModifiedDate     DATETIME2,
    LoadDate         DATETIME2 DEFAULT SYSDATETIME()
);
GO
Load:
-- ============================================================
-- LOAD SOURCE DATA INTO STAGING
-- ============================================================

TRUNCATE TABLE staging.Customers;

INSERT INTO staging.Customers
(
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Phone,
    Country,
    City,
    CustomerType,
    CreatedDate,
    ModifiedDate
)
SELECT
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Phone,
    Country,
    City,
    CustomerType,
    CreatedDate,
    ModifiedDate
FROM source_system.Customers;





Level 8 — Transform
Example:
-- ============================================================
-- TRANSFORM CUSTOMER DATA
-- ============================================================

SELECT
    CustomerID,
    TRIM(CustomerCode) AS CustomerCode,
    UPPER(TRIM(FirstName)) AS FirstName,
    UPPER(TRIM(LastName)) AS LastName,
    LOWER(TRIM(Email)) AS Email,
    TRIM(Country) AS Country,
    TRIM(City) AS City,

    CASE
        WHEN CustomerType = 'VIP' THEN 'VIP'
        WHEN CustomerType = 'Corporate' THEN 'Corporate'
        ELSE 'Retail'
    END AS CustomerType
FROM staging.Customers;







Level 9 — Data Quality 🔍
ETL-এর আগে/পরে quality check করতে হবে।
Duplicate
-- ============================================================
-- DUPLICATE CUSTOMER CHECK
-- ============================================================

SELECT
    CustomerCode,
    COUNT(*) AS DuplicateCount
FROM staging.Customers
GROUP BY CustomerCode
HAVING COUNT(*) > 1;


NULL
-- ============================================================
-- NULL EMAIL CHECK
-- ============================================================

SELECT *
FROM staging.Customers
WHERE Email IS NULL;
Invalid Email
-- ============================================================
-- BASIC EMAIL QUALITY CHECK
-- ============================================================

SELECT *
FROM staging.Customers
WHERE Email NOT LIKE '%@%.%';








Level 10 — Load
Target Data Warehouse তৈরি করি।
Level 18 — Data Warehouse
-- ============================================================
-- CUSTOMER DIMENSION
-- ============================================================

CREATE TABLE warehouse.DimCustomer
(
    CustomerKey      INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID       INT NOT NULL,
    CustomerCode     VARCHAR(20),
    FirstName        VARCHAR(50),
    LastName         VARCHAR(50),
    Email            VARCHAR(150),
    Country          VARCHAR(50),
    City             VARCHAR(50),
    CustomerType     VARCHAR(20),
    StartDate        DATE,
    EndDate          DATE,
    IsCurrent        BIT
);
GO





Level 19 — Fact & Dimension
Dimension
Descriptive data:
DimCustomer
DimProduct
DimEmployee
DimDate
Fact
Business transaction:
FactSales
FactSales
-- ============================================================
-- SALES FACT TABLE
-- ============================================================

CREATE TABLE warehouse.FactSales
(
    SalesKey         BIGINT IDENTITY(1,1) PRIMARY KEY,
    OrderID          INT,
    CustomerKey      INT,
    ProductKey       INT,
    EmployeeKey      INT,
    OrderDateKey     INT,
    Quantity         INT,
    UnitPrice        DECIMAL(18,2),
    DiscountAmount   DECIMAL(18,2),
    SalesAmount      DECIMAL(18,2)
);
GO






Level 11 — Full Load
Full Load মানে target পুরোপুরি refresh করা।
-- ============================================================
-- FULL LOAD CUSTOMER DIMENSION
-- ============================================================

TRUNCATE TABLE warehouse.DimCustomer;

INSERT INTO warehouse.DimCustomer
(
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Country,
    City,
    CustomerType,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Country,
    City,
    CustomerType,
    CAST(CreatedDate AS DATE),
    '9999-12-31',
    1
FROM staging.Customers;
Full Load কখন?
- Small table
- Initial migration
- Reference table
- Full refresh requirement





Level 12 — Incremental Load
প্রতিবার সব data load না করে শুধু changed/new records load করা।
-- ============================================================
-- FIND NEW OR CHANGED RECORDS
-- ============================================================

SELECT *
FROM source_system.Customers
WHERE ModifiedDate >
(
    SELECT ISNULL(MAX(ModifiedDate), '1900-01-01')
    FROM staging.Customers
);



Production-এ watermark ব্যবহার করা হয়।
LastSuccessfulLoadTime
        ↓
Source ModifiedDate
        ↓
Only changed records







Level 13 — UPSERT
UPSERT = UPDATE + INSERT
-- ============================================================
-- UPSERT CUSTOMER DATA
-- ============================================================

UPDATE T
SET
    T.FirstName = S.FirstName,
    T.LastName = S.LastName,
    T.Email = S.Email,
    T.Country = S.Country,
    T.City = S.City,
    T.CustomerType = S.CustomerType
FROM warehouse.DimCustomer T
JOIN staging.Customers S
    ON T.CustomerID = S.CustomerID
WHERE T.IsCurrent = 1;



তারপর নতুন records:
-- ============================================================
-- INSERT NEW CUSTOMERS
-- ============================================================

INSERT INTO warehouse.DimCustomer
(
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Country,
    City,
    CustomerType,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
    S.CustomerID,
    S.CustomerCode,
    S.FirstName,
    S.LastName,
    S.Email,
    S.Country,
    S.City,
    S.CustomerType,
    CAST(SYSDATETIME() AS DATE),
    '9999-12-31',
    1
FROM staging.Customers S
WHERE NOT EXISTS
(
    SELECT 1
    FROM warehouse.DimCustomer T
    WHERE T.CustomerID = S.CustomerID
);






Level 14 — SCD Type 0
No change allowed.
Example:
Original Country = USA
Customer পরে country change করলেও historical value unchanged থাকবে।







Level 15 — SCD Type 1
Old value overwrite।
USA → Canada

Target:
Canada
History রাখা হয় না।
-- ============================================================
-- SCD TYPE 1
-- OVERWRITE OLD VALUE
-- ============================================================

UPDATE T
SET
    T.Country = S.Country,
    T.City = S.City
FROM warehouse.DimCustomer T
JOIN staging.Customers S
    ON T.CustomerID = S.CustomerID;






Level 16 — SCD Type 2 🔥
Data Engineering-এর অত্যন্ত গুরুত্বপূর্ণ topic।
ধরুন:
Customer = John
Country = USA
পরে:
Country = Canada
আমরা old record delete করব না।
CustomerKey | CustomerID | Country | IsCurrent
------------------------------------------------
1            | 1          | USA     | 0
25           | 1          | Canada  | 1
Implementation:
-- ============================================================
-- SCD TYPE 2
-- CLOSE OLD RECORD
-- ============================================================

UPDATE T
SET
    T.EndDate = DATEADD(DAY, -1, CAST(SYSDATETIME() AS DATE)),
    T.IsCurrent = 0
FROM warehouse.DimCustomer T
JOIN staging.Customers S
    ON T.CustomerID = S.CustomerID
WHERE T.IsCurrent = 1
  AND
  (
       ISNULL(T.Country,'') <> ISNULL(S.Country,'')
    OR ISNULL(T.City,'') <> ISNULL(S.City,'')
    OR ISNULL(T.CustomerType,'') <> ISNULL(S.CustomerType,'')
  );
তারপর new version:
-- ============================================================
-- INSERT NEW SCD TYPE 2 VERSION
-- ============================================================

INSERT INTO warehouse.DimCustomer
(
    CustomerID,
    CustomerCode,
    FirstName,
    LastName,
    Email,
    Country,
    City,
    CustomerType,
    StartDate,
    EndDate,
    IsCurrent
)
SELECT
    S.CustomerID,
    S.CustomerCode,
    S.FirstName,
    S.LastName,
    S.Email,
    S.Country,
    S.City,
    S.CustomerType,
    CAST(SYSDATETIME() AS DATE),
    '9999-12-31',
    1
FROM staging.Customers S
WHERE EXISTS
(
    SELECT 1
    FROM warehouse.DimCustomer T
    WHERE T.CustomerID = S.CustomerID
      AND T.IsCurrent = 0
      AND T.EndDate = DATEADD(DAY, -1, CAST(SYSDATETIME() AS DATE))
);






Level 17 — Surrogate Keys
Source:
CustomerID = 100
Warehouse:
CustomerKey = 5001
CustomerKey হলো Surrogate Key।
কারণ একই Customer-এর SCD Type 2-তে multiple versions থাকতে পারে।







Level 20 — Stored Procedures
Production ETL সাধারণত stored procedure দিয়ে orchestrate করা হয়।
-- ============================================================
-- ETL STORED PROCEDURE
-- ============================================================

CREATE OR ALTER PROCEDURE etl.LoadCustomers
AS
BEGIN

    SET NOCOUNT ON;

    -- Step 1: Clear staging
    TRUNCATE TABLE staging.Customers;

    -- Step 2: Extract
    INSERT INTO staging.Customers
    (
        CustomerID,
        CustomerCode,
        FirstName,
        LastName,
        Email,
        Phone,
        Country,
        City,
        CustomerType,
        CreatedDate,
        ModifiedDate
    )
    SELECT
        CustomerID,
        CustomerCode,
        FirstName,
        LastName,
        Email,
        Phone,
        Country,
        City,
        CustomerType,
        CreatedDate,
        ModifiedDate
    FROM source_system.Customers;

END;
GO
Run:
EXEC etl.LoadCustomers;










Level 21 — Transactions
ETL যেন half-loaded অবস্থায় না থাকে।
-- ============================================================
-- ETL TRANSACTION
-- ============================================================

BEGIN TRY

    BEGIN TRANSACTION;

    -- ETL operations
    TRUNCATE TABLE staging.Customers;

    INSERT INTO staging.Customers
    SELECT
        CustomerID,
        CustomerCode,
        FirstName,
        LastName,
        Email,
        Phone,
        Country,
        City,
        CustomerType,
        CreatedDate,
        ModifiedDate
    FROM source_system.Customers;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    THROW;

END CATCH;






Level 22 — Error Handling
-- ============================================================
-- ETL ERROR HANDLING
-- ============================================================

BEGIN TRY

    -- ETL code here

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure;

    THROW;

END CATCH;






Level 23 — Reject Handling
সব source data valid হবে না।
Example:
CustomerID = 99
Email = invalidemail
Country = NULL
এগুলো reject table-এ রাখা যায়।
-- ============================================================
-- REJECT TABLE
-- ============================================================

CREATE TABLE reject.CustomerReject
(
    RejectID        BIGINT IDENTITY PRIMARY KEY,
    CustomerID      INT,
    CustomerCode    VARCHAR(20),
    Email           VARCHAR(150),
    RejectReason    VARCHAR(500),
    RejectDate      DATETIME2 DEFAULT SYSDATETIME()
);
GO
Example:
-- ============================================================
-- REJECT INVALID EMAIL
-- ============================================================

INSERT INTO reject.CustomerReject
(
    CustomerID,
    CustomerCode,
    Email,
    RejectReason
)
SELECT
    CustomerID,
    CustomerCode,
    Email,
    'Invalid Email'
FROM staging.Customers
WHERE Email NOT LIKE '%@%.%';







Level 24 — ETL Logging
Production ETL-এ অবশ্যই logging থাকতে হবে।
-- ============================================================
-- ETL LOG TABLE
-- ============================================================

CREATE TABLE audit.ETLLog
(
    LogID          BIGINT IDENTITY PRIMARY KEY,
    PackageName    VARCHAR(200),
    ProcessName    VARCHAR(200),
    StartTime      DATETIME2,
    EndTime        DATETIME2,
    RowsExtracted  BIGINT,
    RowsInserted   BIGINT,
    RowsUpdated    BIGINT,
    RowsRejected   BIGINT,
    Status         VARCHAR(30),
    ErrorMessage   VARCHAR(MAX)
);
GO
Production report:
Package       Start       End         Inserted  Updated  Status
----------------------------------------------------------------
Customer_ETL  01:00       01:02       15000     230      SUCCESS
Product_ETL   01:02       01:03       1200      15       SUCCESS
Sales_ETL     01:03       01:10       450000    0        SUCCESS







Level 25 — SQL Server Agent ⏰
SQL Server Agent দিয়ে ETL schedule করা যায়।
Example:
01:00 AM
   ↓
Extract Customers
   ↓
Extract Products
   ↓
Transform
   ↓
Load Dimensions
   ↓
Load Fact
   ↓
Data Quality
   ↓
ETL Log
Typical schedules:
- Daily
- Hourly
- Every 15 minutes
- Weekly
- Monthly






Level 26 — SSIS
SSIS = SQL Server Integration Services
SQL Server ecosystem-এর traditional enterprise ETL tool।
Typical SSIS package:
Execute SQL Task
      ↓
Data Flow Task
      ↓
OLE DB Source
      ↓
Lookup
      ↓
Derived Column
      ↓
Conditional Split
      ↓
OLE DB Destination
গুরুত্বপূর্ণ SSIS Components
- OLE DB Source
- Flat File Source
- Excel Source
- Lookup
- Derived Column
- Conditional Split
- Aggregate
- Sort
- Union All
- Merge
- Execute SQL Task
- Data Flow Task
- For Each Loop
- Variables
- Parameters
- Event Handlers







Level 27 — Bulk Loading
Large dataset হলে row-by-row insert inefficient।
SQL Server-এ:
-- ============================================================
-- BULK INSERT EXAMPLE
-- ============================================================

BULK INSERT staging.Customers
FROM 'C:\ETL\customers.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    TABLOCK
);
Large-volume ETL-এ bulk loading অত্যন্ত গুরুত্বপূর্ণ।





Level 28 — CDC
CDC = Change Data Capture
Source table-এ কী INSERT/UPDATE/DELETE হয়েছে তা capture করতে পারে।
Concept:
Source Table
     ↓
CDC
     ↓
Changed Records
     ↓
ETL
     ↓
Warehouse
Enable example:
-- ============================================================
-- ENABLE CDC AT DATABASE LEVEL
-- ============================================================

EXEC sys.sp_cdc_enable_db;
Table-level configuration environment/version অনুযায়ী করা হয়।







Level 29 — Change Tracking
Change Tracking CDC-এর চেয়ে lightweight।
মূলত জানতে:
Which rows changed?
CDC:
What changed?

  
Difference
  
Feature	                   CDC	           Change Tracking
Changed rows	             ✅	           ✅
Historical change values	 ✅	           Limited
Delete tracking	           ✅	           ✅
Detailed history	         Strong	         Weak
ETL use	                   Excellent	     Good
Overhead	                 Higher	         Lower







Level 30 — Partitioning
Large Fact table:
FactSales
500 Million rows
তখন date-based partition ব্যবহার করা যায়।
2024 → Partition 1
2025 → Partition 2
2026 → Partition 3
2027 → Partition 4
  
Benefit:
- Faster query
- Easier maintenance
- Partition switching
- Archive management






Level 31 — ETL Performance 🚀
ETL performance-এর জন্য:
ভালো Practice
- 🔹 Set-based SQL
- 🔹 Proper indexing
- 🔹 Batch processing
- 🔹 Bulk loading
- 🔹 Incremental loading
- 🔹 Avoid cursor
- 🔹 Avoid unnecessary DISTINCT
- 🔹 Avoid SELECT *
- 🔹 Correct datatype
- 🔹 Partition large tables
- 🔹 Update statistics
- 🔹 Review execution plans
Example:

  
❌ Slow:
DECLARE @ID INT;

DECLARE c CURSOR FOR
SELECT CustomerID
FROM staging.Customers;


✅ Better:
UPDATE T
SET
    T.Email = S.Email
FROM warehouse.DimCustomer T
JOIN staging.Customers S
    ON T.CustomerID = S.CustomerID;





Level 32 — Metadata-Driven ETL 🔥
Advanced Data Engineering-এর গুরুত্বপূর্ণ skill।
একটি metadata table:
-- ============================================================
-- ETL METADATA TABLE
-- ============================================================

CREATE TABLE etl.ETLMetadata
(
    MetadataID       INT IDENTITY PRIMARY KEY,
    SourceTable      VARCHAR(200),
    TargetTable      VARCHAR(200),
    LoadType         VARCHAR(30),
    WatermarkColumn  VARCHAR(100),
    IsActive         BIT,
    LastLoadTime     DATETIME2
);
GO
Data:
Source                    Target                 LoadType
----------------------------------------------------------
Customers                 DimCustomer            Incremental
Products                  DimProduct             Incremental
Orders                    FactSales              Incremental
Employees                 DimEmployee            Full
এর ফলে একই ETL framework multiple tables-এর জন্য ব্যবহার করা যায়।







Level 33 — Data Lineage
Data কোথা থেকে কোথায় গেল সেটা track করা।
source_system.Customers
        ↓
staging.Customers
        ↓
etl.LoadCustomers
        ↓
warehouse.DimCustomer
        ↓
Power BI
  
Example documentation:
  
Source	                 Transformation	               Target
Customers.Email	         LOWER/TRIM	                   DimCustomer.Email
Customers.Country	       Standardization	             DimCustomer.Country
Orders	                 Business filter	             FactSales
OrderItems	             Revenue calculation	         FactSales.SalesAmount






Level 34 — ETL Security 🔐
Production ETL-এ:
- Least privilege
- Role-based access
- Database roles
- Stored procedure permissions
- Credential protection
- SQL Agent proxy
- Sensitive data encryption
- Password কখনো code-এ hard-code না করা
Example:
-- ============================================================
-- CREATE ETL ROLE
-- ============================================================

CREATE ROLE ETLExecutor;
GO

GRANT EXECUTE
ON SCHEMA::etl
TO ETLExecutor;
GO






Level 35 — Monitoring 📊
Production ETL monitor করতে হবে।
Track:
Job Status
Duration
Rows Extracted
Rows Inserted
Rows Updated
Rows Rejected
Error Count
Last Successful Run
Last Failed Run
Example query:
-- ============================================================
-- ETL MONITORING REPORT
-- ============================================================

SELECT
    ProcessName,
    StartTime,
    EndTime,
    RowsExtracted,
    RowsInserted,
    RowsUpdated,
    RowsRejected,
    Status
FROM audit.ETLLog
ORDER BY StartTime DESC;








Level 36 — Production Deployment
Development:
DEV
 ↓
TEST
 ↓
UAT
 ↓
PROD
Deployment-এর সময়:
- SQL scripts
- Stored procedures
- Tables
- Views
- SSIS packages
- SQL Agent Jobs
- Security
- Configuration
- Environment variables
সব version-controlled হওয়া উচিত।







Level 37 — End-to-End ETL Project 🔥🔥🔥
এটাই আপনার portfolio-level ETL project।
Project Name
ETL Retail Data Warehouse — SQL Server

Source
source_system
├── Customers
├── Products
├── Employees
├── Orders
├── OrderItems
└── Payments
Staging
staging
├── Customers
├── Products
├── Employees
├── Orders
├── OrderItems
└── Payments
Warehouse
warehouse
├── DimCustomer
├── DimProduct
├── DimEmployee
├── DimDate
└── FactSales
ETL
etl
├── LoadCustomers
├── LoadProducts
├── LoadEmployees
├── LoadOrders
└── LoadSales
Audit
audit
└── ETLLog
Reject
reject
├── CustomerReject
├── ProductReject
└── SalesReject



  
End-to-End Flow
              ┌──────────────────┐
              │ SOURCE SYSTEM    │
              │                  │
              │ Customers        │
              │ Products         │
              │ Employees        │
              │ Orders           │
              │ OrderItems       │
              │ Payments         │
              └────────┬─────────┘
                       │
                       ↓
                 ┌───────────┐
                 │ EXTRACT   │
                 └─────┬─────┘
                       ↓
              ┌─────────────────┐
              │ STAGING         │
              └────────┬────────┘
                       ↓
              ┌─────────────────┐
              │ TRANSFORM       │
              │                 │
              │ Clean           │
              │ Standardize     │
              │ Join            │
              │ Validate        │
              │ Calculate       │
              └────────┬────────┘
                       ↓
              ┌─────────────────┐
              │ DATA QUALITY    │
              └────────┬────────┘
                  ┌────┴────┐
                  ↓         ↓
              VALID       INVALID
                ↓           ↓
             WAREHOUSE    REJECT
                ↓
             POWER BI






Level 38 — Power BI Integration 📊
শেষে Power BI warehouse-এর সাথে connect করবে।
Power BI model:
                DimDate
                   │
                   │
DimCustomer ─── FactSales ─── DimProduct
                   │
                   │
              DimEmployee

  
Power BI Measures
Total Sales =

  
SUM(FactSales[SalesAmount])
Total Quantity =

  
SUM(FactSales[Quantity])
Average Sales =

  
AVERAGE(FactSales[SalesAmount])
Total Orders =

DISTINCTCOUNT(FactSales[OrderID])
