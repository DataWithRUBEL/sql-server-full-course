1. Dynamic SQL কী? 🤔
Dynamic SQL হলো এমন SQL statement যা 
আগে থেকে hard-code না করে runtime-এ string হিসেবে তৈরি করে execute করা হয়।
  
Static SQL
SELECT *
FROM Sales.Orders
WHERE CustomerID = 101;

এখানে query structure fixed।



Dynamic SQL
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT *
FROM Sales.Orders
WHERE CustomerID = 101;
';

EXEC(@SQL);
এখানে SQL statement runtime-এ তৈরি হয়েছে।
Real Company Example
ধরুন একজন analyst বললেন:
- কোন column দিয়ে filter হবে?
- কোন table থেকে data আসবে?
- কোন year?
- কোন sort?
- কোন database?
- কোন aggregation?
  
প্রতিবার আলাদা query লিখলে automation করা কঠিন।
Dynamic SQL দিয়ে একটি reusable framework বানানো যায়।








2. কেন Dynamic SQL ব্যবহার করবো? 🎯
- ⚡ Automation: একই logic বহু table/database-এ চালানো।
- 🔄 Flexibility: runtime-এ table, column, filter পরিবর্তন।
- 🏗️ ETL: metadata-driven ETL pipeline তৈরি।
- 📊 Reporting: dynamic PIVOT/column generation।
- 🗄️ Multi-Database: অনেক database process করা।
- 🔧 Maintenance: dynamic index/partition maintenance।
- 🧩 Metadata: sys.tables, sys.columns ব্যবহার করে automatic SQL generation।
- 🚀 Scalability: repetitive DBA/Data Engineering কাজ automate করা।







3.  Dynamic SQL Concept
Syntax
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT *
FROM Sales.Customers;
';

EXEC(@SQL);
Practice
/* Execute a dynamically generated SELECT */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT CustomerID, CustomerName, Country
  FROM Sales.Customers;';

EXEC(@SQL);








4. EXEC()
EXEC() হলো Dynamic SQL execute করার সবচেয়ে basic method।
/* Basic EXEC example */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT COUNT(*) AS CustomerCount
FROM Sales.Customers;
';

EXEC(@SQL);
EXEC-এর limitation
- ❌ Parameterization দুর্বল
- ❌ SQL Injection risk
- ❌ Plan reuse তুলনামূলকভাবে কম
- ❌ Complex parameter handling inconvenient
তাই production-এ সাধারণত sp_executesql বেশি গুরুত্বপূর্ণ।







5. String Concatenation
/* Build SQL dynamically using concatenation */

DECLARE @Country NVARCHAR(50) = N'Kuwait';
DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT *
  FROM Sales.Customers
  WHERE Country = ''' + @Country + N''';';

PRINT @SQL;

EXEC(@SQL);
এখানে সমস্যা আছে।
যদি user input দেয়:
Kuwait' OR 1=1 --
তাহলে query manipulate হতে পারে।
এটাই SQL Injection-এর একটি classic সমস্যা।






6. sp_executesql ⭐
Production Dynamic SQL-এর সবচেয়ে গুরুত্বপূর্ণ skill।
/* Parameterized Dynamic SQL */

DECLARE @SQL NVARCHAR(MAX);
DECLARE @Country NVARCHAR(50) = N'Kuwait';

SET @SQL =
N'
SELECT CustomerID,
       CustomerName,
       Country
FROM Sales.Customers
WHERE Country = @Country;
';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50)',
     @Country = @Country;
কেন ⭐?
- 🔐 Security
- 🚀 Plan reuse
- 🎯 Parameter support
- 🧹 Cleaner code
- 🏭 Production friendly






7. Parameters
/* Multiple parameters */

DECLARE
    @SQL NVARCHAR(MAX),
    @Country NVARCHAR(50) = N'Kuwait',
    @CustomerType VARCHAR(20) = 'VIP';

SET @SQL =
N'
SELECT *
FROM Sales.Customers
WHERE Country = @Country
AND CustomerType = @CustomerType;
';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50),
       @CustomerType VARCHAR(20)',
     @Country = @Country,
     @CustomerType = @CustomerType;







8. OUTPUT Parameters
Dynamic SQL থেকে value বাইরে আনতে OUTPUT parameter ব্যবহার করা যায়।
/* Return COUNT from Dynamic SQL */

DECLARE
    @SQL NVARCHAR(MAX),
    @CustomerCount INT;

SET @SQL =
N'
SELECT @CustomerCount = COUNT(*)
FROM Sales.Customers;
';

EXEC sys.sp_executesql
     @SQL,
     N'@CustomerCount INT OUTPUT',
     @CustomerCount = @CustomerCount OUTPUT;

SELECT @CustomerCount AS CustomerCount;






9. Dynamic WHERE
এটি reporting এবং search system-এ খুব common।
/* Dynamic WHERE conditions */

DECLARE
    @SQL NVARCHAR(MAX),
    @Country NVARCHAR(50) = N'Kuwait',
    @CustomerType VARCHAR(20) = 'VIP';

SET @SQL =
N'
SELECT *
FROM Sales.Customers
WHERE 1 = 1
';

IF @Country IS NOT NULL
    SET @SQL += N'
    AND Country = @Country';

IF @CustomerType IS NOT NULL
    SET @SQL += N'
    AND CustomerType = @CustomerType';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50),
       @CustomerType VARCHAR(20)',
     @Country,
     @CustomerType;








10. Dynamic SELECT
Column list runtime-এ generate করা যায়।
/* Dynamic SELECT column list */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT CustomerID,
       CustomerName,
       Country
FROM Sales.Customers;
';

EXEC(@SQL);
আর যদি column list variable হয়:
/* Dynamic SELECT */

DECLARE @Columns NVARCHAR(MAX);

SET @Columns =
N'CustomerID, CustomerName, Country';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT ' + @Columns + N'
FROM Sales.Customers;';

EXEC(@SQL);
⚠️ User input directly column list-এ ব্যবহার করবেন না।






11. QUOTENAME() ⭐
Dynamic SQL-এর security এবং identifier handling-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
/* QUOTENAME protects SQL identifiers */

DECLARE @TableName SYSNAME = N'Customers';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT *
FROM Sales.' + QUOTENAME(@TableName) + N';';

EXEC(@SQL);
Output হবে:
SELECT *
FROM Sales.[Customers];

  
মনে রাখবেন
QUOTENAME() সাধারণত ব্যবহার করবেন:
- Table name
- Schema name
- Column name
- Database name
কিন্তু values parameterize করবেন।







12. Dynamic Table / Schema / Database
Dynamic Table
/* Dynamic table */

DECLARE @TableName SYSNAME = N'Customers';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT COUNT(*)
FROM Sales.' + QUOTENAME(@TableName) + N';';

EXEC(@SQL);
Dynamic Schema + Table
/* Dynamic schema and table */

DECLARE
    @SchemaName SYSNAME = N'Sales',
    @TableName SYSNAME = N'Orders';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'SELECT COUNT(*)
FROM ' + QUOTENAME(@SchemaName)
+ N'.' + QUOTENAME(@TableName) + N';';

EXEC(@SQL);







13. Dynamic ORDER BY
/* Dynamic ORDER BY */

DECLARE @SortColumn SYSNAME = N'CustomerName';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT CustomerID,
       CustomerName,
       Country
FROM Sales.Customers
ORDER BY ' + QUOTENAME(@SortColumn) + N';';

EXEC(@SQL);
Production approach
Column whitelist করুন:
/* Validate allowed sort columns */

IF @SortColumn NOT IN
(
    'CustomerID',
    'CustomerName',
    'Country',
    'SignupDate'
)
    THROW 50001, 'Invalid sort column', 1;






14. Dynamic GROUP BY
/* Dynamic GROUP BY */

DECLARE @GroupColumn SYSNAME = N'Country';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT ' + QUOTENAME(@GroupColumn) + N',
       COUNT(*) AS CustomerCount
FROM Sales.Customers
GROUP BY ' + QUOTENAME(@GroupColumn) + N';';

EXEC(@SQL);






15. Dynamic JOIN
/* Dynamic JOIN */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT
    o.OrderID,
    c.CustomerName,
    o.OrderDate,
    o.TotalAmount
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID;
';

EXEC(@SQL);
Dynamic JOIN useful যখন join structure runtime-এ পরিবর্তন হবে।






16. Dynamic PIVOT ⭐
Data Analyst-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
ধরুন country অনুযায়ী sales এবং columns runtime-এ তৈরি হবে।
/* ============================================================
   Dynamic PIVOT
   Country values become columns
   ============================================================ */

DECLARE @Columns NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

/* Generate pivot columns dynamically */

SELECT @Columns =
    STRING_AGG(QUOTENAME(Country), ',')
FROM
(
    SELECT DISTINCT ShippingCountry AS Country
    FROM Sales.Orders
) AS C;
  

/* Build dynamic PIVOT */

SET @SQL =
N'
SELECT *
FROM
(
    SELECT
        ShippingCountry,
        TotalAmount
    FROM Sales.Orders
) AS SourceData

PIVOT
(
    SUM(TotalAmount)
    FOR ShippingCountry IN (' + @Columns + N')
) AS P;';
    
EXEC(@SQL);
কেন Dynamic PIVOT?
  
আজ:
Kuwait | UAE | Qatar
আগামীকাল নতুন country:
Kuwait | UAE | Qatar | Bahrain
Static PIVOT হলে query পরিবর্তন করতে হবে।
Dynamic PIVOT automatically নতুন column তৈরি করতে পারে।









17. Dynamic UNPIVOT
/* Dynamic UNPIVOT example */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT CustomerID,
       Attribute,
       Value
FROM
(
    SELECT
        CustomerID,
        CustomerName,
        Country,
        CustomerType
    FROM Sales.Customers
) AS SourceData
UNPIVOT
(
    Value FOR Attribute IN
    (
        CustomerName,
        Country,
        CustomerType
    )
) AS U;';

EXEC(@SQL);






18. Dynamic INSERT
/* Dynamic INSERT */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
INSERT INTO Staging.SalesRaw
(
    SourceOrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice,
    SourceSystem
)
SELECT
    o.OrderID,
    o.CustomerID,
    oi.ProductID,
    o.OrderDate,
    oi.Quantity,
    oi.UnitPrice,
    ''ERP''
FROM Sales.Orders o
INNER JOIN Sales.OrderItems oi
    ON o.OrderID = oi.OrderID;
';

EXEC(@SQL);





19. Dynamic UPDATE
/* Dynamic UPDATE */

DECLARE
    @SQL NVARCHAR(MAX),
    @Country NVARCHAR(50) = N'Kuwait';

SET @SQL =
N'
UPDATE Sales.Customers
SET IsActive = 1
WHERE Country = @Country;
';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50)',
     @Country;







20. Dynamic DELETE
/* Dynamic DELETE */

DECLARE
    @SQL NVARCHAR(MAX),
    @Country NVARCHAR(50) = N'Qatar';

SET @SQL =
N'
DELETE FROM Sales.Customers
WHERE Country = @Country
AND IsActive = 0;
';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50)',
     @Country;

  
⚠️ Production-এ Dynamic DELETE করার আগে:
- Transaction
- Backup/recovery consideration
- Row count validation
- WHERE validation
- Audit logging
অবশ্যই রাখবেন।




  
21. Dynamic MERGE / UPSERT ⭐
Data Engineering-এ গুরুত্বপূর্ণ।
ধরুন staging থেকে target-এ data load করবেন।
/* ============================================================
   Dynamic MERGE / UPSERT
   ============================================================ */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
MERGE Sales.Customers AS Target
USING
(
    SELECT
        CustomerID,
        CustomerName,
        Email,
        Country,
        City,
        CustomerType,
        SignupDate,
        IsActive
    FROM Staging.CustomerSource
) AS Source
ON Target.CustomerID = Source.CustomerID

WHEN MATCHED THEN
    UPDATE SET
        Target.CustomerName = Source.CustomerName,
        Target.Email = Source.Email,
        Target.Country = Source.Country,
        Target.City = Source.City,
        Target.CustomerType = Source.CustomerType,
        Target.IsActive = Source.IsActive

WHEN NOT MATCHED BY TARGET THEN
    INSERT
    (
        CustomerName,
        Email,
        Country,
        City,
        CustomerType,
        SignupDate,
        IsActive
    )
    VALUES
    (
        Source.CustomerName,
        Source.Email,
        Source.Country,
        Source.City,
        Source.CustomerType,
        Source.SignupDate,
        Source.IsActive
    );
';

-- Execute only after creating the source table.
-- EXEC(@SQL);
গুরুত্বপূর্ণ Production Note
SQL Server-এ MERGE ব্যবহারে concurrency এবং historical engine behavior-এর কারণে অনেক production team explicit:
UPDATE
+
INSERT
pattern prefer করে।
তাই MERGE জানবেন, কিন্তু blindly use করবেন না।






22. Dynamic DDL
Dynamic SQL দিয়ে DDL generate করা যায়।
যেমন নতুন table তৈরি:
/* Dynamic CREATE TABLE */

DECLARE @TableName SYSNAME = N'DynamicCustomerBackup';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
CREATE TABLE Sales.' + QUOTENAME(@TableName) + N'
(
    CustomerID INT,
    CustomerName NVARCHAR(100),
    Country NVARCHAR(50)
);';

EXEC(@SQL);
অন্যান্য DDL
Dynamic SQL দিয়ে করা যায়:
CREATE TABLE
ALTER TABLE
CREATE INDEX
DROP INDEX
CREATE VIEW
CREATE PROCEDURE
CREATE SCHEMA







23. Dynamic Stored Procedures
/* Dynamic CREATE PROCEDURE */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
CREATE OR ALTER PROCEDURE Sales.usp_GetCustomers
    @Country NVARCHAR(50)
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        CustomerID,
        CustomerName,
        Country
    FROM Sales.Customers
    WHERE Country = @Country;

END;

';

EXEC(@SQL);
Execute:
EXEC Sales.usp_GetCustomers
    @Country = N'Kuwait';








24. Dynamic Temp Tables
/* Dynamic temporary table */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
CREATE TABLE #CustomerSummary
(
    Country NVARCHAR(50),
    CustomerCount INT
);

INSERT INTO #CustomerSummary
SELECT
    Country,
    COUNT(*)
FROM Sales.Customers
GROUP BY Country;

';

EXEC(@SQL);
⚠️ গুরুত্বপূর্ণ:
Dynamic SQL-এর ভিতরে তৈরি local temp table-এর scope বুঝতে হবে।
Dynamic SQL scope
       ↓
Local temporary table
       ↓
Scope limitation
Complex procedure design-এ এটি common source of confusion।






25. Dynamic CTE
/* Dynamic CTE */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
WITH CustomerSales AS
(
    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(o.TotalAmount) AS TotalSales
    FROM Sales.Customers c
    INNER JOIN Sales.Orders o
        ON c.CustomerID = o.CustomerID
    GROUP BY
        c.CustomerID,
        c.CustomerName
)
SELECT *
FROM CustomerSales
WHERE TotalSales > 5000;
';

EXEC(@SQL);





26.  Metadata / sys Catalog 
এখান থেকেই Dynamic SQL সত্যিকার অর্থে powerful হয়।
Tables
/* List all user tables */

SELECT
    s.name AS SchemaName,
    t.name AS TableName
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
ORDER BY
    s.name,
    t.name;
Columns
/* List all columns */

SELECT
    s.name AS SchemaName,
    t.name AS TableName,
    c.name AS ColumnName,
    ty.name AS DataType
FROM sys.tables t
INNER JOIN sys.schemas s
    ON t.schema_id = s.schema_id
INNER JOIN sys.columns c
    ON t.object_id = c.object_id
INNER JOIN sys.types ty
    ON c.user_type_id = ty.user_type_id
ORDER BY
    s.name,
    t.name,
    c.column_id;

  
Dynamic SQL + Metadata
এটাই Data Engineering-এর বড় transition:
sys.tables
     ↓
sys.columns
     ↓
Metadata
     ↓
Generate SQL
     ↓
Execute SQL
     ↓
Automation






27. Metadata-Driven SQL
এটি Data Engineer-এর জন্য must learn।
ধরুন configuration table:
SELECT *
FROM Config.ETLTableConfig;
এখন enabled tables automatically process করব।
/* ============================================================
   Metadata-driven table processing
   ============================================================ */

DECLARE
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @SQL NVARCHAR(MAX);

DECLARE TableCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT
    SchemaName,
    TableName
FROM Config.ETLTableConfig
WHERE IsEnabled = 1;

OPEN TableCursor;

FETCH NEXT FROM TableCursor
INTO @SchemaName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @SQL =
        N'SELECT COUNT(*) AS RowCount
          FROM ' + QUOTENAME(@SchemaName)
        + N'.' + QUOTENAME(@TableName) + N';';

    PRINT @SQL;

    EXEC(@SQL);

    FETCH NEXT FROM TableCursor
    INTO @SchemaName, @TableName;

END;

CLOSE TableCursor;
DEALLOCATE TableCursor;
এখানে:
Configuration
      ↓
Metadata
      ↓
Dynamic SQL
      ↓
Multiple Tables
      ↓
Automation





28. Dynamic Transactions
Dynamic SQL-এর ভিতরে transaction ব্যবহার করা যায়।
/* Dynamic transaction */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
BEGIN TRY

    BEGIN TRANSACTION;

    UPDATE Sales.Customers
    SET IsActive = 1
    WHERE Country = @Country;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;
';
  

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50)',
     @Country = N'Kuwait';







29. Dynamic ETL
এটাই Data Engineer-এর সবচেয়ে গুরুত্বপূর্ণ অংশগুলোর একটি।
Real ETL:
Source
  ↓
Metadata
  ↓
Dynamic SQL
  ↓
Staging
  ↓
Transformation
  ↓
Target
  ↓
Audit
Example:
/* ============================================================
   Dynamic ETL pattern
   ============================================================ */

DECLARE
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @SQL NVARCHAR(MAX),
    @StartTime DATETIME2 = SYSDATETIME();

SELECT TOP 1
    @SchemaName = SchemaName,
    @TableName = TableName
FROM Config.ETLTableConfig
WHERE IsEnabled = 1
ORDER BY ConfigID;

BEGIN TRY

    SET @SQL =
        N'SELECT COUNT(*) AS RowCount
          FROM ' + QUOTENAME(@SchemaName)
        + N'.' + QUOTENAME(@TableName) + N';';

    EXEC(@SQL);

    INSERT INTO Audit.DynamicSQLLog
    (
        ProcessName,
        SQLStatement,
        StartTime,
        EndTime,
        Status
    )
    VALUES
    (
        N'Dynamic ETL',
        @SQL,
        @StartTime,
        SYSDATETIME(),
        'SUCCESS'
    );

END TRY

BEGIN CATCH

    INSERT INTO Audit.DynamicSQLLog
    (
        ProcessName,
        SQLStatement,
        StartTime,
        EndTime,
        Status,
        ErrorMessage
    )
    VALUES
    (
        N'Dynamic ETL',
        @SQL,
        @StartTime,
        SYSDATETIME(),
        'FAILED',
        ERROR_MESSAGE()
    );

    THROW;

END CATCH;






30. Multi-Table Automation
একই logic:
Customers
Orders
OrderItems
Products
Employees
সব table-এর উপর চালানো।
/* Generate COUNT(*) for every configured table */

DECLARE
    @SQL NVARCHAR(MAX) = N'';

SELECT @SQL +=
N'
SELECT
    ''' + SchemaName + N'.' + TableName + N''' AS TableName,
    COUNT(*) AS RowCount
FROM ' +
QUOTENAME(SchemaName) + N'.' +
QUOTENAME(TableName) + N';
'
FROM Config.ETLTableConfig
WHERE IsEnabled = 1;

PRINT @SQL;

EXEC(@SQL);
এটি Data Quality framework-এর base হতে পারে।






31. Multi-Database SQL
ধরুন:
SalesDB
HRDB
InventoryDB
FinanceDB
সব database-এ একই query চালাতে হবে।
Dynamic SQL:
/* Dynamic database name */

DECLARE @DatabaseName SYSNAME = N'Dynamic SQLDB';

  

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT COUNT(*)
FROM ' + QUOTENAME(@DatabaseName)
+ N'.Sales.Customers;
';
  

EXEC(@SQL);
Real-world
Data Engineering-এ:
Multiple databases
       ↓
Metadata
       ↓
Dynamic Database Name
       ↓
Dynamic SQL
       ↓
Centralized processing








32. Dynamic Index Maintenance
Production DBA/Data Engineering automation-এ খুব গুরুত্বপূর্ণ।
Fragmentation metadata
/* Find indexes requiring maintenance */

SELECT
    OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName,
    OBJECT_NAME(ps.object_id) AS TableName,
    i.name AS IndexName,
    ps.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) ps
INNER JOIN sys.indexes i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE ps.avg_fragmentation_in_percent >= 10;
Dynamic rebuild:
/* Dynamic index rebuild */

DECLARE
    @SchemaName SYSNAME = N'Sales',
    @TableName SYSNAME = N'Orders',
    @IndexName SYSNAME = N'IX_Orders_CustomerID';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'ALTER INDEX ' + QUOTENAME(@IndexName)
+ N' ON '
+ QUOTENAME(@SchemaName) + N'.'
+ QUOTENAME(@TableName)
+ N' REBUILD;';

EXEC(@SQL);








33. Dynamic Partition Maintenance
Partition management-এর core idea:
Partition Function
       ↓
Boundary
       ↓
Dynamic ALTER PARTITION
       ↓
Split / Merge
Example pattern:
/* Dynamic partition SPLIT example */

DECLARE @BoundaryDate DATE = '2027-01-01';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
ALTER PARTITION FUNCTION pf_OrderDate()
SPLIT RANGE (''' +
CONVERT(VARCHAR(10), @BoundaryDate, 120)
+ N''');';

PRINT @SQL;

-- Execute only when the partition function exists.
-- EXEC(@SQL);

  
Production partition automation-এ আগে verify করতে হবে:
- Boundary already exists কিনা
- Filegroup আছে কিনা
- Partition scheme ঠিক আছে কিনা
- Data distribution
- Locking impact







34. SQL Injection & Security
Dynamic SQL শেখার সময় সবচেয়ে গুরুত্বপূর্ণ security topic।

  
❌ Unsafe
/* NEVER blindly concatenate user values */

SET @SQL =
N'SELECT *
  FROM Sales.Customers
  WHERE Country = ''' + @Country + N''';';


  
✅ Safe
/* Parameterize values */

SET @SQL =
N'
SELECT *
FROM Sales.Customers
WHERE Country = @Country;


';

EXEC sys.sp_executesql
     @SQL,
     N'@Country NVARCHAR(50)',
     @Country;

  
Identifier বনাম Value
  
Input	                  Approach
Country value	          sp_executesql parameter
CustomerID	            parameter
Date	                  parameter
Table name	            QUOTENAME() + whitelist
Schema name	            QUOTENAME() + whitelist
Column name	            QUOTENAME() + whitelist
ORDER BY column	        whitelist + QUOTENAME()


Golden Rule 🔐
Values → Parameters
Identifiers → QUOTENAME + Whitelist







35. Debugging & Error Handling
Dynamic SQL debugging-এর জন্য:
/* Debug dynamic SQL */

DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT *
FROM Sales.Customers
WHERE Country = @Country;


';

PRINT @SQL;
বড় SQL-এর ক্ষেত্রে PRINT সবসময় convenient নয়।
SELECT @SQL AS GeneratedSQL;
TRY/CATCH
/* Dynamic SQL error handling */

BEGIN TRY

    EXEC sys.sp_executesql
         @SQL,
         N'@Country NVARCHAR(50)',
         @Country;

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage,
        ERROR_LINE() AS ErrorLine;

    THROW;

END CATCH;






36. Performance / Plan Cache 🚀
Dynamic SQL-এর performance বুঝতে হবে।
Bad pattern
EXEC
(
    'SELECT *
     FROM Sales.Customers
     WHERE CustomerID = 10'
);
তারপর:
EXEC
(
    'SELECT *
     FROM Sales.Customers
     WHERE CustomerID = 20'
);
Literal পরিবর্তনের কারণে বিভিন্ন SQL text তৈরি হতে পারে।
Better
DECLARE @SQL NVARCHAR(MAX);

SET @SQL =
N'
SELECT *
FROM Sales.Customers
WHERE CustomerID = @CustomerID;
';



  
EXEC sys.sp_executesql
     @SQL,
     N'@CustomerID INT',
     @CustomerID = 10;

  
তারপর:
EXEC sys.sp_executesql
     @SQL,
     N'@CustomerID INT',
     @CustomerID = 20;
লক্ষ্য
Same SQL structure
       ↓
Different parameters
       ↓
Potential plan reuse
       ↓
Better scalability
তবে plan reuse guaranteed নয়; SQL Server optimizer এবং cache behavior-এর উপর নির্ভর করে।







37. Dynamic Data Validation
Data Quality automation-এর জন্য অত্যন্ত powerful।
ধরুন সব configured table-এ row count দেখতে চাই।
/* Dynamic data quality validation */

DECLARE
    @SchemaName SYSNAME,
    @TableName SYSNAME,
    @SQL NVARCHAR(MAX);

DECLARE C CURSOR LOCAL FAST_FORWARD
FOR
SELECT SchemaName, TableName
FROM Config.ETLTableConfig
WHERE IsEnabled = 1;

OPEN C;

FETCH NEXT FROM C
INTO @SchemaName, @TableName;

WHILE @@FETCH_STATUS = 0
BEGIN

    SET @SQL =
    N'
    SELECT
        ''' + @SchemaName + N'.' + @TableName + N''' AS TableName,
        COUNT(*) AS RowCount
    FROM ' +
    QUOTENAME(@SchemaName) + N'.' +
    QUOTENAME(@TableName) + N';';

    EXEC(@SQL);

    FETCH NEXT FROM C
    INTO @SchemaName, @TableName;

END;

CLOSE C;
DEALLOCATE C;

  
এরপর আরও advanced validation যোগ করা যায়:
Row Count
Null Count
Duplicate Count
Min Date
Max Date
Invalid FK
Invalid Values
Orphan Records







38. Dynamic Logging & Audit Framework
Production Dynamic SQL framework-এ logging অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   Dynamic SQL Audit Framework
   ============================================================ */

DECLARE
    @SQL NVARCHAR(MAX),
    @StartTime DATETIME2 = SYSDATETIME();

SET @SQL =
N'
SELECT COUNT(*)
FROM Sales.Orders;
';

BEGIN TRY

    EXEC(@SQL);

    INSERT INTO Audit.DynamicSQLLog
    (
        ProcessName,
        SQLStatement,
        StartTime,
        EndTime,
        Status,
        ErrorMessage
    )
    VALUES
    (
        N'Order Count Process',
        @SQL,
        @StartTime,
        SYSDATETIME(),
        'SUCCESS',
        NULL
    );

END TRY

BEGIN CATCH

    INSERT INTO Audit.DynamicSQLLog
    (
        ProcessName,
        SQLStatement,
        StartTime,
        EndTime,
        Status,
        ErrorMessage
    )
    VALUES
    (
        N'Order Count Process',
        @SQL,
        @StartTime,
        SYSDATETIME(),
        'FAILED',
        ERROR_MESSAGE()
    );

    THROW;

END CATCH;

  
Audit দেখুন:
SELECT *
FROM Audit.DynamicSQLLog
ORDER BY LogID DESC;






39. Production Dynamic SQL Framework 
এটাই আপনার final destination।
একটি production-grade architecture এমন হবে:
                ┌───────────────────────┐
                │   Configuration       │
                │ Config.ETLTableConfig │
                └───────────┬───────────┘
                            ↓
                ┌───────────────────────┐
                │       Metadata        │
                │ sys.tables            │
                │ sys.columns           │
                │ sys.indexes           │
                └───────────┬───────────┘
                            ↓
                ┌───────────────────────┐
                │ SQL Generator         │
                │ QUOTENAME()           │
                │ sp_executesql         │
                └───────────┬───────────┘
                            ↓
             ┌──────────────┼──────────────┐
             ↓              ↓              ↓
         SELECT          INSERT          UPDATE
             ↓              ↓              ↓
          PIVOT           ETL           MERGE
             ↓              ↓              ↓
       Data Analysis   Data Engineering  DBA
             └──────────────┬──────────────┘
                            ↓
                ┌───────────────────────┐
                │ Validation            │
                │ Row Count             │
                │ Null Check            │
                │ Duplicate Check       │
                └───────────┬───────────┘
                            ↓
                ┌───────────────────────┐
                │ Transaction           │
                │ TRY/CATCH             │
                │ COMMIT / ROLLBACK     │
                └───────────┬───────────┘
                            ↓
                ┌───────────────────────┐
                │ Audit / Logging       │
                │ Success / Failed      │
                │ Execution Time        │
                └───────────┬───────────┘
                            ↓
                ┌───────────────────────┐
                │ Production Automation │
                └───────────────────────┘






40. সবচেয়ে গুরুত্বপূর্ণ 10টি Dynamic SQL Skill
যদি job-ready হতে চান, বিশেষ করে এইগুলোতে বেশি practice করুন:

  
1️⃣ sp_executesql ⭐⭐⭐⭐⭐
EXEC sys.sp_executesql
    @SQL,
    @ParameterDefinition,
    @Parameter;


  
2️⃣ QUOTENAME() ⭐⭐⭐⭐⭐
QUOTENAME(@TableName)


  
3️⃣ Parameterization ⭐⭐⭐⭐⭐
User Value
   ↓
Parameter
   ↓
sp_executesql


  
4️⃣ Dynamic PIVOT ⭐⭐⭐⭐⭐
Rows
 ↓
Dynamic Columns
 ↓
PIVOT


  
5️⃣ Metadata ⭐⭐⭐⭐⭐
sys.tables
sys.columns
sys.schemas
sys.indexes
sys.objects


  
6️⃣ Metadata-Driven SQL ⭐⭐⭐⭐⭐
Metadata
 ↓
Generate SQL
 ↓
Execute
 ↓
Automation


  
7️⃣ Dynamic ETL ⭐⭐⭐⭐⭐
Config
 ↓
Source
 ↓
Dynamic SQL
 ↓
Transform
 ↓
Target
 ↓
Audit


  
8️⃣ Security ⭐⭐⭐⭐⭐
Values
→ Parameters

Identifiers
→ QUOTENAME + Whitelist
9️⃣ Error Handling ⭐⭐⭐⭐⭐
BEGIN TRY
    -- Dynamic SQL
END TRY
BEGIN CATCH
    -- Log
    -- Rollback
    -- THROW
END CATCH


  
🔟 Production Framework 🏆
Configuration
      ↓
Metadata
      ↓
SQL Generator
      ↓
sp_executesql
      ↓
Transaction
      ↓
Validation
      ↓
Logging
      ↓
Automation






41. Common Mistakes
- ❌ String concatenation: User values সরাসরি SQL string-এ concatenate করা।
- ❌ No QUOTENAME(): Dynamic table/schema/column name নিরাপদভাবে handle না করা।
- ❌ Everything dynamic: প্রয়োজন না থাকলেও Dynamic SQL ব্যবহার করা।
- ❌ No validation: Dynamic SQL execute করার আগে object/column whitelist না করা।
- ❌ No logging: Production ETL failure-এর কারণ trace করতে না পারা।
- ❌ No transaction: Dynamic UPDATE/DELETE/ETL-এ transaction না রাখা।
- ❌ No error handling: TRY...CATCH বাদ দেওয়া।
- ❌ Blind MERGE: সব পরিস্থিতিতে MERGE ব্যবহার করা।
- ❌ Huge SQL string: অত্যন্ত বড় এবং maintain করা কঠিন dynamic query তৈরি করা।
- ❌ Ignoring performance: Dynamic SQL-এর plan/cache behavior না বোঝা।










