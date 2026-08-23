 Complete Data Warehouse Architecture
                    OLTP SYSTEM
                        │
        ┌───────────────┼────────────────┐
        │               │                │
    Customers        Products         Orders
    Employees        Categories       OrderItems
        │               │                │
        └───────────────┼────────────────┘
                        ↓
                    STAGING
                        ↓
                    BRONZE
                        ↓
                    SILVER
                        ↓
              DIMENSION + FACT
                        ↓
                     GOLD
                        ↓
              ┌─────────┴─────────┐
              ↓                   ↓
        Data Analyst          Power BI
        SQL Analytics         Reporting







LEVEL 1 — Advanced SQL Foundation
1. SQL Fundamentals
Data Warehouse-এর foundation একই SQL।
/* Basic warehouse exploration */

SELECT
    CustomerID,
    CustomerNumber,
    FirstName,
    LastName,
    Country
FROM src.Customers;


শিখবেন
- SELECT
- FROM
- DISTINCT
- TOP
- ORDER BY
- aliases
- expressions





2. Filtering
/* Find VIP customers from Kuwait */

SELECT *
FROM src.Customers
WHERE CustomerType = 'VIP'
  AND Country = 'Kuwait';


গুরুত্বপূর্ণ
WHERE
IN
BETWEEN
LIKE
IS NULL
IS NOT NULL
EXISTS
AND
OR
NOT




3. Aggregation
Data Analyst-এর সবচেয়ে গুরুত্বপূর্ণ অংশ।
/* Sales summary */

SELECT
    COUNT(*) AS TotalOrders,
    SUM(TotalAmount) AS TotalSales,
    AVG(TotalAmount) AS AverageOrderValue,
    MIN(TotalAmount) AS MinimumOrder,
    MAX(TotalAmount) AS MaximumOrder
FROM src.Orders
WHERE OrderStatus = 'Completed';






4. JOIN
/* Orders + Customers */

SELECT
    O.OrderNumber,
    O.OrderDate,
    C.CustomerNumber,
    CONCAT(C.FirstName,' ',C.LastName) AS CustomerName,
    O.TotalAmount
FROM src.Orders O
INNER JOIN src.Customers C
    ON O.CustomerID = C.CustomerID;


Data Warehouse-এ বেশি ব্যবহার হবে
INNER JOIN
LEFT JOIN
FULL JOIN
CROSS JOIN
Anti Join







5. Functions
/* String + date + numeric functions */

SELECT
    UPPER(FirstName) AS FirstName,
    LOWER(Email) AS Email,
    YEAR(CreatedDate) AS CreatedYear,
    ROUND(1234.567,2) AS RoundedValue
FROM src.Customers;


Date functions
GETDATE()
DATEADD()
DATEDIFF()
DATEPART()
DATETRUNC()
EOMONTH()







6. CASE
/* Customer segmentation */

SELECT
    CustomerID,
    CustomerType,
    CASE
        WHEN CustomerType = 'VIP'
            THEN 'High Value'
        WHEN CustomerType = 'Premium'
            THEN 'Medium Value'
        ELSE 'Standard'
    END AS CustomerSegment
FROM src.Customers;






7. Subquery
/* Customers whose order value is above average */

SELECT *
FROM src.Orders
WHERE TotalAmount >
(
    SELECT AVG(TotalAmount)
    FROM src.Orders
);





8. CTE
/* CTE for customer sales */

WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS TotalSales
    FROM src.Orders
    WHERE OrderStatus = 'Completed'
    GROUP BY CustomerID
)
SELECT *
FROM CustomerSales
WHERE TotalSales > 5000;







9. Window Functions
Data Analyst + DWH Analyst-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
/* Rank customers by sales */

SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales,

    RANK() OVER
    (
        ORDER BY SUM(TotalAmount) DESC
    ) AS SalesRank
FROM src.Orders
GROUP BY CustomerID;



Running Total
/* Monthly running sales */

WITH MonthlySales AS
(
    SELECT
        DATETRUNC(MONTH,OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Sales
    FROM src.Orders
    WHERE OrderStatus = 'Completed'
    GROUP BY DATETRUNC(MONTH,OrderDate)
)
SELECT
    SalesMonth,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY SalesMonth
    ) AS RunningSales
FROM MonthlySales;







10. Views
Gold layer-এ views খুব common।
/* Customer sales reporting view */

CREATE OR ALTER VIEW gold.vw_CustomerSales
AS
SELECT
    C.CustomerID,
    C.CustomerNumber,
    CONCAT(C.FirstName,' ',C.LastName) AS CustomerName,
    C.Country,
    SUM(O.TotalAmount) AS TotalSales
FROM src.Customers C
LEFT JOIN src.Orders O
    ON C.CustomerID = O.CustomerID
GROUP BY
    C.CustomerID,
    C.CustomerNumber,
    C.FirstName,
    C.LastName,
    C.Country;
GO






11. Stored Procedures
ETL এবং reusable reporting logic-এ অত্যন্ত গুরুত্বপূর্ণ।
/* Stored procedure for customer sales */

CREATE OR ALTER PROCEDURE etl.usp_GetCustomerSales
    @Country VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        C.CustomerID,
        C.CustomerNumber,
        CONCAT(C.FirstName,' ',C.LastName) AS CustomerName,
        SUM(O.TotalAmount) AS TotalSales
    FROM src.Customers C
    JOIN src.Orders O
        ON C.CustomerID = O.CustomerID
    WHERE C.Country = @Country
    GROUP BY
        C.CustomerID,
        C.CustomerNumber,
        C.FirstName,
        C.LastName;

END;
GO

/* Execute procedure */

EXEC etl.usp_GetCustomerSales
    @Country = 'Kuwait';






12. Temporary Tables
ETL transformation বা complex analytics-এ ব্যবহার হয়।
/* Temporary table for high-value customers */

SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
INTO #CustomerSales
FROM src.Orders
GROUP BY CustomerID;

SELECT *
FROM #CustomerSales
WHERE TotalSales > 5000;






13. Dynamic SQL
Dynamic reporting এবং metadata-driven ETL-এ গুরুত্বপূর্ণ।
/* Dynamic SQL example */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT
    Country,
    COUNT(*) AS CustomerCount
FROM src.Customers
GROUP BY Country;
';

EXEC sys.sp_executesql @SQL;


Best Practice
❌ String concatenation করে user input directly execute করবেন না।
✅ sp_executesql + parameters ব্যবহার করুন।






14. PIVOT / UNPIVOT
/* Sales by country */

SELECT *
FROM
(
    SELECT
        ShippingCountry,
        OrderStatus,
        TotalAmount
    FROM src.Orders
) AS SourceData
PIVOT
(
    SUM(TotalAmount)
    FOR OrderStatus IN
    (
        [Completed],
        [Pending],
        [Cancelled],
        [Returned]
    )
) AS P;







15. JSON
Modern applications থেকে JSON data আসা খুব common।
/* JSON example */

DECLARE @CustomerJSON NVARCHAR(MAX) =
N'{
    "CustomerID": 501,
    "Name": "John Smith",
    "Country": "Kuwait",
    "Preferences": {
        "Language": "English",
        "Newsletter": true
    }
}';

SELECT
    JSON_VALUE(@CustomerJSON,'$.CustomerID') AS CustomerID,
    JSON_VALUE(@CustomerJSON,'$.Name') AS CustomerName,
    JSON_VALUE(@CustomerJSON,'$.Country') AS Country;
OPENJSON
/* Parse JSON array */

DECLARE @JSON NVARCHAR(MAX) =
N'[
    {"ProductID":101,"Quantity":2},
    {"ProductID":102,"Quantity":5},
    {"ProductID":103,"Quantity":1}
]';

SELECT *
FROM OPENJSON(@JSON)
WITH
(
    ProductID INT '$.ProductID',
    Quantity INT '$.Quantity'
);





LEVEL 2 — Data Warehouse Fundamentals
  
16. OLTP vs OLAP
  
Feature	                 OLTP	                  OLAP / DWH
Purpose	                 Transactions	          Analytics
Data	                   Current	              Historical
Design	                 Normalized	            Dimensional
Query	                   Short	                Complex
Write	                   Frequent	              Batch/ELT
Example	                 Order system	          Sales warehouse



-- OLTP
Customer
Order
OrderItem
Product

  
-- OLAP
DimCustomer
DimProduct
DimDate
FactSales







17. Data Warehouse Concepts
Data Warehouse হলো:
Integrated + Historical + Subject-oriented + Analytics-optimized data repository.

Core concepts
- Historical data
- Facts
- Dimensions
- Grain
- Measures
- Surrogate keys
- ETL/ELT
- SCD
- Star Schema






18. OLTP → DWH Architecture
CRM
ERP
E-Commerce
APIs
Files
    ↓
Staging
    ↓
Bronze
    ↓
Silver
    ↓
Gold
    ↓
Power BI / Reporting









19. Dimensional Modeling
Business questions দিয়ে model design করবেন।
Example:
"Which customers generated the most sales?"

তাহলে:
DimCustomer
DimProduct
DimDate
DimEmployee
       ↓
   FactSales








20. Star Schema ⭐
সবচেয়ে important DWH model।
              DimCustomer
                   |
                   |
DimDate ---- FactSales ---- DimProduct
                   |
                   |
              DimEmployee





21. Snowflake Schema
Dimension-কে আরও normalized করা হয়।
FactSales
   |
DimProduct
   |
DimCategory
   |
DimDepartment
Practical recommendation
👉 Reporting/Power BI-এর জন্য সাধারণত Star Schema সহজ এবং performant।






22. Fact Tables
Fact table business event রাখে।
আমাদের ক্ষেত্রে:
FactSales
প্রতিটি row = একটি order line।






23. Dimension Tables
Dimension business context দেয়।
DimCustomer
DimProduct
DimDate
DimEmployee
DimCategory






24. Grain ⭐⭐⭐⭐⭐
সবচেয়ে গুরুত্বপূর্ণ DWH design concept।
আমাদের FactSales-এর grain:
One row = one product line within one customer order.

অর্থাৎ:
Order 1001
 ├── Product A
 ├── Product B
 └── Product C
FactSales-এ 3 rows।







25. Measures
Measures হলো numerical business metrics।
Quantity
UnitPrice
DiscountAmount
SalesAmount
CostAmount
ProfitAmount


Formula:
Sales = Quantity × UnitPrice

Cost = Quantity × UnitCost

Profit = Sales - Cost







26. Business Keys
Source system-এর natural identifier।
CustomerID
ProductID
OrderID






27. Surrogate Keys
DWH-এর internal integer key।
CustomerKey
ProductKey
DateKey
EmployeeKey

  
Example:
CustomerID = 105
CustomerKey = 1005







28. Date Dimension 📅
Date Dimension প্রতিটি Data Warehouse-এর fundamental dimension।
/* Create Date Dimension */

CREATE TABLE gold.DimDate
(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    YearNumber INT,
    QuarterNumber INT,
    MonthNumber INT,
    MonthName VARCHAR(20),
    WeekNumber INT,
    DayNumber INT,
    DayName VARCHAR(20),
    IsWeekend BIT
);


GO
Populate
/* Generate 10 years of dates */

DECLARE @StartDate DATE = '2020-01-01';
DECLARE @EndDate DATE = '2030-12-31';

;WITH D AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY,1,FullDate)
    FROM D
    WHERE FullDate < @EndDate
)
INSERT INTO gold.DimDate
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    WeekNumber,
    DayNumber,
    DayName,
    IsWeekend
)
SELECT
    CONVERT(INT,FORMAT(FullDate,'yyyyMMdd')),
    FullDate,
    YEAR(FullDate),
    DATEPART(QUARTER,FullDate),
    MONTH(FullDate),
    DATENAME(MONTH,FullDate),
    DATEPART(WEEK,FullDate),
    DAY(FullDate),
    DATENAME(WEEKDAY,FullDate),

    CASE
        WHEN DATENAME(WEEKDAY,FullDate)
             IN ('Saturday','Sunday')
        THEN 1
        ELSE 0
    END
FROM D
OPTION (MAXRECURSION 5000);
GO






29. SCD Type 0
Never change historical value.
Example:
Original Country = Kuwait

Even customer moves to UAE,
historical value remains Kuwait.
Use when:
- Birth Date
- Original Registration Date
- Original Customer Type







30. SCD Type 1
Old value overwrite করা হয়।
/* Type 1 update */

UPDATE D
SET
    D.City = S.City,
    D.Country = S.Country
FROM gold.DimCustomer D
JOIN src.Customers S
    ON D.CustomerID = S.CustomerID;
History নেই।








31. SCD Type 2 ⭐⭐⭐⭐⭐
Historical changes preserve করা হয়।
Dimension structure:
CustomerKey
CustomerID
CustomerName
City
Country
ValidFrom
ValidTo
IsCurrent
Example:
CustomerID = 101

Key   City       From        To          Current
1001  Kuwait     2024-01-01  2025-06-01  0
1055  Dubai      2025-06-01  9999-12-31  1
Table
/* SCD Type 2 dimension */

CREATE TABLE gold.DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerNumber VARCHAR(20),
    CustomerName VARCHAR(100),
    Gender VARCHAR(20),
    City VARCHAR(100),
    Country VARCHAR(100),
    CustomerType VARCHAR(30),

    ValidFrom DATE NOT NULL,
    ValidTo DATE NOT NULL,

    IsCurrent BIT NOT NULL
);


GO
Expire old record
/* Expire existing SCD2 record */

UPDATE D
SET
    D.ValidTo = DATEADD(DAY,-1,CAST(GETDATE() AS DATE)),
    D.IsCurrent = 0
FROM gold.DimCustomer D
JOIN src.Customers S
    ON D.CustomerID = S.CustomerID
WHERE D.IsCurrent = 1
  AND
  (
      D.City <> S.City
      OR D.Country <> S.Country
      OR D.CustomerType <> S.CustomerType
  );

তারপর নতুন version insert করবেন।





  

LEVEL 3 — Medallion Architecture
32. Staging
Staging হলো temporary landing area।
Source
 ↓
Staging
এখানে সাধারণত:
- Raw source data
- Batch ID
- Load timestamp
- File name
- Source system
রাখা হয়।








33. Bronze Layer
Bronze = raw historical copy।
/* Bronze customer table */

CREATE TABLE bronze.Customers
(
    CustomerID INT,
    CustomerNumber VARCHAR(20),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Email VARCHAR(150),
    Gender VARCHAR(20),
    City VARCHAR(100),
    Country VARCHAR(100),
    CustomerType VARCHAR(30),

    LoadDateTime DATETIME2 DEFAULT SYSDATETIME()
);






34. Silver Layer
Silver = cleaned + standardized + validated data।
/* Silver customer table */

CREATE TABLE silver.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerNumber VARCHAR(20),
    CustomerName VARCHAR(100),
    Email VARCHAR(150),
    Gender VARCHAR(20),
    City VARCHAR(100),
    Country VARCHAR(100),
    CustomerType VARCHAR(30),
    ModifiedDate DATETIME2
);






35. Gold Layer
Gold = business-ready analytical data।
gold.DimCustomer
gold.DimProduct
gold.DimDate
gold.DimEmployee
gold.FactSales







36. ETL / ELT
ETL
Extract
 ↓
Transform
 ↓
Load
ELT
Extract
 ↓
Load
 ↓
Transform
Modern cloud/data platforms-এ ELT খুব common।







37. Full Load
প্রতিবার পুরো data load।
/* Full load */

TRUNCATE TABLE bronze.Customers;

INSERT INTO bronze.Customers
(
    CustomerID,
    CustomerNumber,
    FirstName,
    LastName,
    Email,
    Gender,
    City,
    Country,
    CustomerType
)
SELECT
    CustomerID,
    CustomerNumber,
    FirstName,
    LastName,
    Email,
    Gender,
    City,
    Country,
    CustomerType
FROM src.Customers;






38. Incremental Load
শুধু নতুন/পরিবর্তিত data।
/* Incremental extraction */

SELECT *
FROM src.Customers
WHERE ModifiedDate >
      @LastSuccessfulLoadDate;






39. Upsert
Insert + Update।
/* Upsert using separate UPDATE + INSERT pattern */

UPDATE T
SET
    T.CustomerName = CONCAT(S.FirstName,' ',S.LastName),
    T.Email = S.Email
FROM silver.Customers T
JOIN src.Customers S
    ON T.CustomerID = S.CustomerID;

INSERT INTO silver.Customers
(
    CustomerID,
    CustomerNumber,
    CustomerName,
    Email,
    Gender,
    City,
    Country,
    CustomerType,
    ModifiedDate
)
SELECT
    S.CustomerID,
    S.CustomerNumber,
    CONCAT(S.FirstName,' ',S.LastName),
    S.Email,
    S.Gender,
    S.City,
    S.Country,
    S.CustomerType,
    S.ModifiedDate
FROM src.Customers S
WHERE NOT EXISTS
(
    SELECT 1
    FROM silver.Customers T
    WHERE T.CustomerID = S.CustomerID
);






40. CDC / Change Tracking
SQL Server-এ source table changes track করা যায়।
CDC
/* Enable CDC at database level */

EXEC sys.sp_cdc_enable_db;
GO

/* Enable CDC for customer table */

EXEC sys.sp_cdc_enable_table
    @source_schema = N'src',
    @source_name = N'Customers',
    @role_name = NULL;

GO
তারপর CDC tables থেকে insert/update/delete changes পাওয়া যায়।
⚠️ CDC availability/configuration আপনার SQL Server edition, 
permissions এবং SQL Server Agent setup-এর উপর নির্ভর করতে পারে।

  
Change Tracking
/* Enable Change Tracking */

ALTER DATABASE [Data warehouse sqlDB]
SET CHANGE_TRACKING = ON
(
    CHANGE_RETENTION = 7 DAYS,
    AUTO_CLEANUP = ON
);






41. Data Quality
DWH-এর সবচেয়ে গুরুত্বপূর্ণ engineering responsibility।
Duplicate check
/* Detect duplicate customers */

SELECT
    CustomerID,
    COUNT(*) AS DuplicateCount
FROM silver.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;



NULL check
/* Check missing customer IDs */

SELECT COUNT(*) AS MissingCustomerID
FROM silver.Customers
WHERE CustomerID IS NULL;



Negative sales
/* Detect invalid sales */

SELECT *
FROM gold.FactSales
WHERE SalesAmount < 0;







42. Reconciliation
Source এবং Warehouse একই business result দিচ্ছে কিনা যাচাই।
/* Source vs warehouse row count */

SELECT
    (SELECT COUNT(*) FROM src.OrderItems) AS SourceRows,
    (SELECT COUNT(*) FROM gold.FactSales) AS WarehouseRows;
Sales reconciliation:
SELECT
    (SELECT SUM(TotalAmount)
     FROM src.Orders
     WHERE OrderStatus = 'Completed') AS SourceSales,

    (SELECT SUM(SalesAmount)
     FROM gold.FactSales) AS WarehouseSales;








43. Error Handling
/* ETL error handling */

BEGIN TRY

    BEGIN TRANSACTION;

    /* ETL operations */

    INSERT INTO silver.Customers
    SELECT *
    FROM stg.Customers;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;

END CATCH;







44. Audit Framework
Production ETL-এ audit অত্যন্ত গুরুত্বপূর্ণ।
/* ETL audit table */

CREATE TABLE audit.ETLLog
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    PipelineName VARCHAR(200),
    TableName VARCHAR(200),
    StartTime DATETIME2,
    EndTime DATETIME2,
    RowsRead BIGINT,
    RowsInserted BIGINT,
    RowsUpdated BIGINT,
    Status VARCHAR(30),
    ErrorMessage VARCHAR(MAX)
);


GO
Example:
/* Record successful ETL */

INSERT INTO audit.ETLLog
(
    PipelineName,
    TableName,
    StartTime,
    EndTime,
    RowsRead,
    RowsInserted,
    RowsUpdated,
    Status
)
VALUES
(
    'Customer Load',
    'silver.Customers',
    DATEADD(MINUTE,-5,SYSDATETIME()),
    SYSDATETIME(),
    500,
    500,
    0,
    'SUCCESS'
);







LEVEL 4 — Warehouse Analytics
  
এখান থেকে Data Analyst side সবচেয়ে বেশি ব্যবহার করবে।
45. Warehouse Analytics
Ideal Gold model:
                 DimDate
                    |
DimCustomer ---- FactSales ---- DimProduct
                    |
               DimEmployee







46. KPI
/* Executive KPI */

SELECT
    SUM(SalesAmount) AS TotalSales,
    SUM(Quantity) AS TotalUnits,
    COUNT(DISTINCT CustomerKey) AS TotalCustomers,
    COUNT(DISTINCT OrderKey) AS TotalOrders,
    AVG(SalesAmount) AS AverageLineValue
FROM gold.FactSales;








47. Trend Analysis
/* Monthly sales trend */

SELECT
    D.YearNumber,
    D.MonthNumber,
    D.MonthName,
    SUM(F.SalesAmount) AS Sales
FROM gold.FactSales F
JOIN gold.DimDate D
    ON F.DateKey = D.DateKey
GROUP BY
    D.YearNumber,
    D.MonthNumber,
    D.MonthName
ORDER BY
    D.YearNumber,
    D.MonthNumber;







48. Ranking
/* Top 10 products */

SELECT TOP 10
    P.ProductName,
    SUM(F.SalesAmount) AS Sales
FROM gold.FactSales F
JOIN gold.DimProduct P
    ON F.ProductKey = P.ProductKey
GROUP BY P.ProductName
ORDER BY Sales DESC;







49. YoY / MoM
YoY
/* Year-over-Year sales */

WITH YearSales AS
(
    SELECT
        D.YearNumber,
        SUM(F.SalesAmount) AS Sales
    FROM gold.FactSales F
    JOIN gold.DimDate D
        ON F.DateKey = D.DateKey
    GROUP BY D.YearNumber
)
SELECT
    YearNumber,
    Sales,
    LAG(Sales) OVER
    (
        ORDER BY YearNumber
    ) AS PreviousYearSales,

    Sales -
    LAG(Sales) OVER
    (
        ORDER BY YearNumber
    ) AS YoYChange
FROM YearSales;







50. Running Total
/* Cumulative sales */

SELECT
    SalesDate,
    SalesAmount,

    SUM(SalesAmount) OVER
    (
        ORDER BY SalesDate
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningSales

FROM
(
    SELECT
        D.FullDate AS SalesDate,
        SUM(F.SalesAmount) AS SalesAmount
    FROM gold.FactSales F
    JOIN gold.DimDate D
        ON F.DateKey = D.DateKey
    GROUP BY D.FullDate
) X;






51. Customer Segmentation
/* Customer segmentation based on total sales */

WITH CustomerSales AS
(
    SELECT
        CustomerKey,
        SUM(SalesAmount) AS TotalSales
    FROM gold.FactSales
    GROUP BY CustomerKey
)
SELECT
    CustomerKey,
    TotalSales,

    CASE
        WHEN TotalSales >= 10000 THEN 'VIP'
        WHEN TotalSales >= 5000 THEN 'Premium'
        WHEN TotalSales >= 1000 THEN 'Regular'
        ELSE 'Low Value'
    END AS CustomerSegment
FROM CustomerSales;






52. Product Analytics
/* Product profitability */

SELECT
    P.ProductName,

    SUM(F.Quantity) AS UnitsSold,

    SUM(F.SalesAmount) AS Sales,

    SUM(F.CostAmount) AS Cost,

    SUM(F.SalesAmount - F.CostAmount) AS Profit,

    CAST
    (
        SUM(F.SalesAmount - F.CostAmount)
        / NULLIF(SUM(F.SalesAmount),0)
        * 100
        AS DECIMAL(10,2)
    ) AS ProfitMarginPercent

FROM gold.FactSales F
JOIN gold.DimProduct P
    ON F.ProductKey = P.ProductKey

GROUP BY
    P.ProductName

ORDER BY Profit DESC;







LEVEL 5 — Data Warehouse Performance
53. Indexing
Dimension:
/* Business key lookup index */

CREATE INDEX IX_DimCustomer_CustomerID
ON gold.DimCustomer(CustomerID);


Fact:
/* Fact table date index */

CREATE INDEX IX_FactSales_DateKey
ON gold.FactSales(DateKey);


Principle
WHERE
JOIN
GROUP BY
ORDER BY
এর উপর ভিত্তি করে indexing design করবেন।







54. Columnstore
Large fact tables-এর জন্য SQL Server Columnstore অত্যন্ত powerful।
/* Columnstore index for analytical fact table */

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSales
ON gold.FactSales;


কেন?
Traditional Rowstore
        ↓
Row by row

Columnstore
        ↓
Column oriented
        ↓
Compression
        ↓
Batch Mode
        ↓
Fast Analytics








55. Partitioning
Large fact table date অনুযায়ী partition করা যায়।
Example:
2023
2024
2025
2026
2027
  
Typical partitioning flow:
Partition Function
        ↓
Partition Scheme
        ↓
Fact Table

  
Conceptual syntax:
/* Partition function example */

CREATE PARTITION FUNCTION pf_SalesDate
(
    DATE
)
AS RANGE RIGHT FOR VALUES
(
    '2024-01-01',
    '2025-01-01',
    '2026-01-01',
    '2027-01-01'
);
Production environment-এ partitioning করার আগে 
workload, filegroups, maintenance এবং partition elimination analyse করতে হবে।







56. Execution Plans
/* Enable actual execution plan in SSMS:
   Ctrl + M

   Then execute query.
*/

SELECT
    C.Country,
    SUM(O.TotalAmount) AS Sales
FROM src.Customers C
JOIN src.Orders O
    ON C.CustomerID = O.CustomerID
GROUP BY C.Country;


দেখবেন:
Index Seek
Index Scan
Table Scan
Hash Match
Nested Loops
Merge Join
Sort
Aggregate
Parallelism







57. Query Optimization
Bad
/* FORMAT can be expensive for large datasets */

SELECT
    FORMAT(OrderDate,'yyyy-MM') AS SalesMonth
FROM src.Orders;


Better
/* Prefer date functions for large analytical workloads */

SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth
FROM src.Orders;



আরও গুরুত্বপূর্ণ:
Avoid SELECT *
Avoid unnecessary JOIN
Avoid functions on indexed columns in WHERE
Use appropriate indexes
Check execution plan
Update statistics
Use correct data types
Filter early
Aggregate appropriately








LEVEL 6 — Production Data Warehouse
58. Security 🔐
Schema-based permissions:
/* Create reporting user/role */

CREATE ROLE DataAnalystRole;
GO

/* Grant read access to Gold */

GRANT SELECT
ON SCHEMA::gold
TO DataAnalystRole;


GO
Data Engineer:
/* ETL role */

CREATE ROLE DataEngineerRole;


GO

GRANT SELECT, INSERT, UPDATE, DELETE
ON SCHEMA::stg
TO DataEngineerRole;


GO
Principle:
Least Privilege

Data Analyst-এর source/bronze/silver write permission প্রয়োজন নেই।







59. Backup / Restore
Full Backup
/* Full database backup */

BACKUP DATABASE [Data warehouse sqlDB]
TO DISK = 'D:\SQLBackup\DataWarehouseSQLDB_FULL.bak'
WITH
    INIT,
    COMPRESSION,
    CHECKSUM;
Restore
/* Restore example */

RESTORE DATABASE [Data warehouse sqlDB]
FROM DISK = 'D:\SQLBackup\DataWarehouseSQLDB_FULL.bak'
WITH
    REPLACE,
    RECOVERY;


Production-এ backup strategy সাধারণত:
Full Backup
     +
Differential Backup
     +
Transaction Log Backup







60. Production Monitoring
Production Data Engineer হিসেবে monitor করবেন:
Pipeline Status
ETL Duration
Rows Read
Rows Inserted
Rows Updated
Rows Rejected
Data Quality
Source-to-DWH Reconciliation
Failed Jobs
Long Running Queries
CPU
Memory
IO
Blocking
Deadlocks
Disk Space
Index Health
Statistics
Backup Status

  
Example:
/* Find currently running requests */

SELECT
    session_id,
    status,
    command,
    cpu_time,
    total_elapsed_time,
    reads,
    writes
FROM sys.dm_exec_requests
WHERE session_id <> @@SPID;








Final Gold Data Warehouse Model
আপনার practice database শেষ পর্যন্ত এই structure follow করবে:
[Data warehouse sqlDB]

├── src
│   ├── Customers
│   ├── Products
│   ├── Categories
│   ├── Orders
│   ├── OrderItems
│   ├── Employees
│   └── Departments
│
├── stg
│   └── Raw Landing Tables
│
├── bronze
│   └── Raw Historical Tables
│
├── silver
│   ├── Clean Customers
│   ├── Clean Products
│   ├── Clean Orders
│   └── Clean OrderItems
│
├── gold
│   ├── DimCustomer
│   ├── DimProduct
│   ├── DimDate
│   ├── DimEmployee
│   ├── DimCategory
│   └── FactSales
│
├── audit
│   └── ETLLog
│
└── etl
    ├── Stored Procedures
    └── ETL Logic





