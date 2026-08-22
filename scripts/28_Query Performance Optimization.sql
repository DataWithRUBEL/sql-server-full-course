1. Performance Optimization কেন শিখবেন? 🎯
⚡ Performance Optimization-এর লক্ষ্য
- 🚀 Query দ্রুত করা
- 💾 Logical/physical I/O কমানো
- 🧠 Memory usage নিয়ন্ত্রণ করা
- 🔥 CPU consumption কমানো
- 🔒 Blocking কমানো
- 📈 Large table efficiently query করা
- 📊 Reports/Dashboards দ্রুত করা
- 🏢 Production database stable রাখা
- 💰 Infrastructure cost কমানো



বাস্তব উদাহরণ
ধরুন:
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '2026-01-01';
Table-এ 100 million rows আছে।

Query:
Before Index
    ↓
Table Scan
    ↓
100M rows read
    ↓
High I/O
    ↓
High CPU
    ↓
10–30 seconds

After proper Index
    ↓
Index Seek
    ↓
Only relevant rows
    ↓
Low I/O
    ↓
Low CPU
    ↓
milliseconds/seconds










2. Performance Optimization-এর মূল Formula 🧠
Query Performance
        │
        ├── CPU
        ├── I/O
        ├── Memory
        ├── Network
        ├── Locks
        └── Parallelism
সবচেয়ে গুরুত্বপূর্ণ:
Logical Reads কমানো = অনেক ক্ষেত্রে query performance dramatically improve করা।









3. Complete Practice Database Architecture
আমরা company-টিকে এভাবে model করব:
QueryPerformanceOptimizationDB
│
├── dbo.Customers
├── dbo.Categories
├── dbo.Products
├── dbo.Employees
├── dbo.Departments
├── dbo.Orders
├── dbo.OrderItems
├── dbo.Payments
├── dbo.Shipments
├── dbo.ProductReviews
└── dbo.DateDimension
Relationship:
Departments
     │
     └── Employees

Categories
     │
     └── Products
             │
             └── OrderItems
                    │
Customers ── Orders ─┤
             │
             ├── Payments
             └── Shipments

Products
   │
   └── ProductReviews







4. Performance Fundamentals
1. Performance Fundamentals
প্রথমে বুঝতে হবে query slow কেন হচ্ছে।
Slow Query
   │
   ├── CPU bottleneck
   ├── I/O bottleneck
   ├── Memory bottleneck
   ├── Blocking
   ├── Bad execution plan
   ├── Missing index
   ├── Poor statistics
   └── Bad query design
Practice:

  
SELECT *
FROM Sales.Orders;



তারপর:
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Sales.Orders;
দ্বিতীয় query সাধারণত বেশি efficient কারণ unnecessary columns পড়ছে না।







5. Query Processing
2. Query Processing
আপনি query লিখেন:
SELECT CustomerID, SUM(TotalAmount)
FROM Sales.Orders
GROUP BY CustomerID;
SQL Server internally:
SQL Query
   ↓
Parser
   ↓
Algebrizer
   ↓
Optimizer
   ↓
Execution Plan
   ↓
Storage Engine
   ↓
Result
সবচেয়ে গুরুত্বপূর্ণ component:
Query Optimizer
Optimizer বিভিন্ন execution strategy compare করে এবং একটি plan নির্বাচন করে।







6. SQL Server Architecture
3. SQL Server Architecture
High-level:
SQL Server
│
├── Relational Engine
│     ├── Parser
│     ├── Optimizer
│     └── Execution Engine
│
└── Storage Engine
      ├── Buffer Manager
      ├── Access Methods
      ├── Transaction Manager
      └── Lock Manager
Performance troubleshooting-এ এই architecture বোঝা অত্যন্ত গুরুত্বপূর্ণ।








7. Execution Plans
4. Execution Plans
SSMS-এ:
Ctrl + M
তারপর query execute করুন।
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1000;
Execution Plan-এ দেখতে পাবেন:
Table Scan
Index Scan
Index Seek
Hash Match
Nested Loops
Sort
Stream Aggregate
Hash Aggregate
Key Lookup
Parallelism
Golden Rule
Execution Plan দেখে কেন SQL Server এই operation বেছে নিয়েছে সেটা বুঝতে হবে।








8. STATISTICS IO / TIME
5. STATISTICS IO / TIME
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT *
FROM Sales.Orders
WHERE CustomerID = 1000;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

দেখবেন:
logical reads
physical reads
CPU time
elapsed time
সবচেয়ে গুরুত্বপূর্ণ metric
Logical Reads
  
Example:
Before:
logical reads = 250,000

After:
logical reads = 35
এটি বড় performance improvement।










9. CPU / I/O / Memory
6. CPU / I/O / Memory
CPU
↓
Calculations
Joins
Aggregations
Sorting

I/O
↓
Reading pages from storage/buffer

Memory
↓
Sort
Hash
Join
Aggregation
Memory Grants








10. SARGability
7. SARGability
SARGable = Search ARGument Able
  
Bad:
SELECT *
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2026;
কারণ column-এর উপর function apply হচ্ছে।

  
Better:
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '20260101'
  AND OrderDate < '20270101';


⭐ Important
-- Bad
WHERE YEAR(OrderDate) = 2026

-- Good
WHERE OrderDate >= '20260101'
AND OrderDate < '20270101'







11. Predicate Optimization
8. Predicate Optimization

  
Bad:
WHERE ISNULL(CustomerID, 0) = 1000

  
Better:
WHERE CustomerID = 1000
আরেকটি:
-- Bad
WHERE LEFT(Country, 3) = 'Kuw'

-- Better
WHERE Country LIKE 'Kuw%';








12. SELECT Optimization
9. SELECT Optimization
  
❌ Avoid:
SELECT *
FROM Sales.Orders;


✅ Better:
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Sales.Orders;


কারণ:
- Network traffic কমে
- Memory কমে
- I/O কমে
- Covering index তৈরি সহজ হয়







13. JOIN Optimization
10. JOIN Optimization
SELECT
    o.OrderID,
    c.CustomerNumber,
    o.OrderDate,
    o.TotalAmount
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID;


ভালো JOIN-এর জন্য
- Join columns-এর datatype একই রাখুন
- Appropriate indexes রাখুন
- Unnecessary rows আগে filter করুন
- SELECT * avoid করুন









14. GROUP BY Optimization
11. GROUP BY Optimization
SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID;


Execution Plan-এ দেখতে পারেন:
Hash Match (Aggregate)
অথবা:
Stream Aggregate





15. ORDER BY / TOP
12. ORDER BY / TOP
Bad:
SELECT *
FROM Sales.Orders
ORDER BY TotalAmount DESC;


এখানে huge sort হতে পারে।
Better:
SELECT TOP (10)
    OrderID,
    CustomerID,
    TotalAmount
FROM Sales.Orders
ORDER BY TotalAmount DESC;







16. Clustered Index
13. Clustered Index
Primary Key সাধারণত clustered index তৈরি করে:
CREATE CLUSTERED INDEX
CX_Orders_OrderID
ON Sales.Orders(OrderID);

একটি table-এ সাধারণত একটি clustered index থাকে।








17. Nonclustered Index
14. Nonclustered Index
CREATE NONCLUSTERED INDEX
IX_Orders_CustomerID
ON Sales.Orders(CustomerID);


Practice:
SELECT
    OrderID,
    OrderDate,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 1000;







18. Seek vs Scan
15. Seek vs Scan
Index Seek
Index
 ↓
Specific rows
Scan
Index/Table
 ↓
Many/all rows
যেমন:
WHERE CustomerID = 1000
ভালো index থাকলে:
Index Seek
হতে পারে।







19. Key Lookup
16. Key Lookup
ধরুন index:
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);


কিন্তু query:
SELECT
    OrderID,
    OrderDate,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 1000;


Index-এ প্রয়োজনীয় সব columns না থাকলে:
Index Seek
     ↓
Key Lookup
     ↓
Clustered Index
হতে পারে।






20. Covering Index
17. Covering Index
Key Lookup কমাতে:
CREATE INDEX IX_Orders_CustomerID_Covering
ON Sales.Orders(CustomerID)
INCLUDE
(
    OrderDate,
    TotalAmount
);
এখন index query-এর required data cover করতে পারে।







21. Composite Index
18. Composite Index
CREATE INDEX IX_Orders_Customer_Date
ON Sales.Orders
(
    CustomerID,
    OrderDate
);
এই index:
WHERE CustomerID = 1000
AND OrderDate >= '2026-01-01';


এর জন্য ভালো।
Key order গুরুত্বপূর্ণ
(CustomerID, OrderDate)
আর
(OrderDate, CustomerID)
একই নয়।








22. Included Columns
19. Included Columns
CREATE INDEX IX_Orders_Customer
ON Sales.Orders(CustomerID)
INCLUDE
(
    OrderDate,
    OrderStatus,
    TotalAmount
);

INCLUDE columns index key নয়।
তাই unnecessary key width না বাড়িয়ে covering করা যায়।








23. Filtered Index
20. Filtered Index
যদি active orders বেশি গুরুত্বপূর্ণ:
CREATE INDEX IX_Orders_Active
ON Sales.Orders(CustomerID, OrderDate)
INCLUDE(TotalAmount)
WHERE OrderStatus = 'Completed';


Query:
SELECT
    CustomerID,
    SUM(TotalAmount)
FROM Sales.Orders
WHERE OrderStatus = 'Completed'
GROUP BY CustomerID;






24. Statistics
21. Statistics
Statistics optimizer-কে বলে:
Column distribution
+
Data density
+
Estimated row count

  
Check:
DBCC SHOW_STATISTICS
(
    'Sales.Orders',
    'IX_Orders_CustomerID'
);
Update:
UPDATE STATISTICS Sales.Orders;








25. Cardinality Estimation
22. Cardinality Estimation
Optimizer estimate করে:
Expected rows = ?
যদি:
Estimated Rows = 100
Actual Rows    = 1,000,000
তাহলে execution plan ভুল strategy নিতে পারে।







26. Estimated vs Actual Rows
23. Estimated vs Actual Rows
Execution Plan-এ compare করুন:
Estimated Rows: 10
Actual Rows:    100,000
Large mismatch হলে investigate করুন:
- Statistics
- Data skew
- Parameter sniffing
- Expressions
- Poor predicates







27. Join Algorithms
24. Join Algorithms
SQL Server প্রধানত:
Nested Loops
Merge Join
Hash Match
Nested Loops
ছোট outer input + indexed inner input-এর জন্য ভালো।
Merge Join
দুই input sorted থাকলে ভালো।
Hash Join
Large unsorted datasets-এর জন্য useful।









28. Sort
25. Sort
SELECT *
FROM Sales.Orders
ORDER BY TotalAmount DESC;
Execution Plan:
Sort
Large sort:
CPU ↑
Memory ↑
I/O ↑








29. Hash Match
26. Hash Match
বিশেষ করে:
JOIN
GROUP BY
DISTINCT
এ ব্যবহৃত হতে পারে।

  
Example:
SELECT
    c.Country,
    SUM(o.TotalAmount)
FROM Sales.Customers c
JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY c.Country;









30. Spools
27. Spools
Execution Plan-এ:
Table Spool
Index Spool
Lazy Spool
Eager Spool
দেখতে পারেন।
Spool সাধারণত intermediate data temporarily store করে reuse করার জন্য।
কিন্তু unnecessary spool performance issue-এর signal হতে পারে।






31. Memory Grants
28. Memory Grants
SQL Server execution-এর আগে memory reserve করতে পারে:
Sort
Hash Join
Hash Aggregate
এর জন্য।
Too much:
Memory starvation
Too little:
Spill





32. Spills
29. Spills
যদি memory যথেষ্ট না হয়:
Memory
  ↓
Not enough
  ↓
TempDB
  ↓
Spill
  ↓
Performance ↓
Execution Plan-এ warning দেখুন।






33. Parallelism
30. Parallelism
Large query:
Single Thread
থেকে:
CPU Core 1
CPU Core 2
CPU Core 3
CPU Core 4
      ↓
Parallel Execution
হতে পারে।
Common operators:
Parallelism
Distribute Streams
Repartition Streams
Gather Streams
Parallelism সবসময় খারাপ নয়।









34. Window Function Optimization
31. Window Function Optimization
Example:
SELECT
    CustomerID,
    OrderDate,
    TotalAmount,

    SUM(TotalAmount) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS RunningSales

FROM Sales.Orders;


Large data হলে sorting expensive হতে পারে।
Helpful index:
CREATE INDEX IX_Orders_Customer_OrderDate
ON Sales.Orders(CustomerID, OrderDate)
INCLUDE(TotalAmount);







35. Subquery
32. Subquery
Example:
  
SELECT *
FROM Sales.Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Orders
    WHERE TotalAmount > 5000
);


Compare with JOIN/EXISTS:
SELECT c.*
FROM Sales.Customers c
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders o
    WHERE o.CustomerID = c.CustomerID
      AND o.TotalAmount > 5000
);
Execution Plan দেখে সিদ্ধান্ত নেবেন—শুধু syntax দেখে নয়।









36. CTE
33. CTE
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT *
FROM CustomerSales
WHERE TotalSales > 10000;

Important
CTE নিজে performance optimization technique নয়।
CTE সাধারণত logical readability দেয়।






37. Temp Table
34. Temp Table
SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
INTO #CustomerSales
FROM Sales.Orders
GROUP BY CustomerID;

CREATE INDEX IX_CustomerSales
ON #CustomerSales(CustomerID);

SELECT *
FROM #CustomerSales
WHERE TotalSales > 10000;

Temp table useful যখন:
- Intermediate result reuse হবে
- Statistics দরকার
- Large intermediate dataset
- Multi-step transformation









38. Table Variables
35. Table Variables
DECLARE @CustomerSales TABLE
(
    CustomerID INT,
    TotalSales DECIMAL(18,2)
);

INSERT INTO @CustomerSales
SELECT
    CustomerID,
    SUM(TotalAmount)
FROM Sales.Orders
GROUP BY CustomerID;


Small datasets-এর জন্য useful।
Large datasets-এর জন্য blindly ব্যবহার করবেন না।







39. Set-Based Processing
36. Set-Based Processing
❌ Row-by-row:
WHILE
   ↓
Row
   ↓
UPDATE
   ↓
Next Row

  
✅ Set-based:
UPDATE Sales.Orders
SET OrderStatus = 'Completed'
WHERE OrderStatus = 'Shipped'
  AND ShippedDate < DATEADD(DAY, -7, GETDATE());
SQL Server relational engine-এর জন্য set-based processing সাধারণত superior।





40. Parameter Sniffing
37. Parameter Sniffing
Stored procedure:
CREATE OR ALTER PROCEDURE Sales.GetCustomerOrders
    @CustomerID INT
AS
BEGIN

    SELECT
        OrderID,
        OrderDate,
        TotalAmount
    FROM Sales.Orders
    WHERE CustomerID = @CustomerID;

END;


GO
এক parameter-এর জন্য optimal plan অন্য parameter-এর জন্য bad হতে পারে।
Example:
Customer A → 5 rows
Customer B → 500,000 rows
একই execution plan দুইজনের জন্য optimal নাও হতে পারে।







41. Stored Procedure Tuning
38. Stored Procedure Tuning
Check:
EXEC Sales.GetCustomerOrders
    @CustomerID = 1000;
Investigate:
- Execution plan
- Logical reads
- CPU
- Parameter sniffing
- Missing indexes
- Statistics









42. Query Hints
39. Query Hints
  
Example:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1000
OPTION (RECOMPILE);


অথবা:
OPTION (MAXDOP 2);
⚠️ Rule
Query hint হলো last-resort tuning tool, default solution নয়।








43. Intelligent Query Processing
40. Intelligent Query Processing
Modern SQL Server-এ গুরুত্বপূর্ণ features:
Adaptive Query Processing
Memory Grant Feedback
Table Variable Deferred Compilation
Scalar UDF Inlining
Batch Mode on Rowstore
Interleaved Execution
Parameter Sensitive Plan optimization
Version অনুযায়ী feature availability/configuration আলাদা হতে পারে।









44. Locking
41. Locking
Transaction:
BEGIN TRAN;

UPDATE Sales.Orders
SET OrderStatus = 'Processing'
WHERE OrderID = 1000;

-- Do not commit immediately
এই সময়ে অন্য transaction একই resource access করলে lock behavior দেখা যাবে।
শেষে:
ROLLBACK;









45. Blocking
42. Blocking
Example:
Session A
   │
   └── UPDATE
          ↓
        Lock
          ↓
Session B
   │
   └── SELECT
          ↓
       Waiting
Check:
EXEC sp_who2;
আরও useful DMV:
SELECT
    session_id,
    blocking_session_id,
    wait_type,
    wait_time,
    status
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;









46. Isolation Levels
43. Isolation Levels
SQL Server:
READ UNCOMMITTED
READ COMMITTED
REPEATABLE READ
SERIALIZABLE
SNAPSHOT
READ COMMITTED SNAPSHOT
Example:
SET TRANSACTION ISOLATION LEVEL
READ COMMITTED;
Performance এবং consistency-এর balance বুঝতে হবে।








47. Deadlocks
44. Deadlocks
Transaction A
    ↓
Lock Resource 1
    ↓
Waiting Resource 2

Transaction B
    ↓
Lock Resource 2
    ↓
Waiting Resource 1
SQL Server একজনকে victim করে।
Prevention:
- Consistent access order
- Short transactions
- Proper indexes
- Avoid unnecessary locks
- Appropriate isolation level






48. Wait Statistics
45. Wait Statistics
SQL Server bottleneck বুঝতে waits খুব গুরুত্বপূর্ণ।
Common waits:
PAGEIOLATCH_*
CXPACKET
CXCONSUMER
LCK_M_*
RESOURCE_SEMAPHORE
WRITELOG
ASYNC_NETWORK_IO
Example:
SELECT
    wait_type,
    waiting_tasks_count,
    wait_time_ms
FROM sys.dm_os_wait_stats
ORDER BY wait_time_ms DESC;

⚠️ Server restart/reset history-এর context মাথায় রাখতে হবে।








49. 50. Query Store
46. Query Store
Query Store production tuning-এর সবচেয়ে গুরুত্বপূর্ণ features-এর একটি।
Enable:
ALTER DATABASE QueryPerformanceOptimizationDB
SET QUERY_STORE = ON;
GO
  
তারপর:
SELECT
    qsq.query_id,
    qsp.plan_id,
    rs.avg_duration,
    rs.avg_cpu_time,
    rs.avg_logical_io_reads
FROM sys.query_store_query AS qsq
JOIN sys.query_store_plan AS qsp
    ON qsq.query_id = qsp.query_id
JOIN sys.query_store_runtime_stats AS rs
    ON qsp.plan_id = rs.plan_id;







50. 51. Query Regression
47. Query Regression
আগে:
Query
↓
100 ms
পরবর্তীতে:
Query
↓
5 seconds
Possible reason:
Statistics changed
Index changed
Data volume increased
Execution plan changed
SQL Server changed
Parameter sensitivity
Query Store দিয়ে old/new plan compare করা যায়।








51. 52. DMV Monitoring
48. DMV Monitoring
Top CPU Queries
SELECT TOP (20)
    qs.total_worker_time / 1000 AS TotalCPU_ms,
    qs.execution_count,
    qs.total_elapsed_time / 1000 AS TotalElapsed_ms,
    qs.total_logical_reads,
    SUBSTRING
    (
        st.text,
        (qs.statement_start_offset / 2) + 1,
        (
            (
                CASE qs.statement_end_offset
                    WHEN -1 THEN DATALENGTH(st.text)
                    ELSE qs.statement_end_offset
                END
                - qs.statement_start_offset
            ) / 2
        ) + 1
    ) AS QueryText
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) st
ORDER BY qs.total_worker_time DESC;








52. 53. Production Troubleshooting
49. Production Troubleshooting
Production-এ query slow হলে এই order follow করুন:
1. Reproduce
      ↓
2. Capture Query
      ↓
3. STATISTICS IO/TIME
      ↓
4. Actual Execution Plan
      ↓
5. Check Waits
      ↓
6. Check Blocking
      ↓
7. Check Statistics
      ↓
8. Check Indexes
      ↓
9. Check Parameter Sniffing
      ↓
10. Optimize
      ↓
11. Test
      ↓
12. Compare Before/After
      ↓
13. Deploy
      ↓
14. Monitor










53.  Partition Elimination
50. Partition Elimination
Large fact table:
Orders
│
├── 2024
├── 2025
├── 2026
└── 2027
Query:
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01'
যদি partitioning properly configured থাকে:
Partition 2024 → Skip
Partition 2025 → Skip
Partition 2026 → Read
Partition 2027 → Skip
এটাই:
Partition Elimination








54. Columnstore
51. Columnstore
Data Warehouse-এর জন্য extremely important।
Example:
CREATE CLUSTERED COLUMNSTORE INDEX
CCI_OrderItems
ON Sales.OrderItems;
Columnstore:
Traditional Rowstore
--------------------
Row1 → all columns
Row2 → all columns
Row3 → all columns

Columnstore
--------------------
Column A → A1 A2 A3...
Column B → B1 B2 B3...
Column C → C1 C2 C3...
Analytical workload-এর জন্য huge benefit হতে পারে।








55. Batch Mode
52. Batch Mode
Traditional:
Row → Row → Row → Row
Batch mode:
Batch
 ↓
Many rows together
বিশেষ করে:
- Aggregation
- Analytics
- Columnstore
- Large datasets
এর জন্য beneficial।








56. 57. Large Table Optimization
53. Large Table Optimization
আমাদের:
Customers      → 50K
Products       → 5K
Orders         → 500K
OrderItems     → 1.5M
Reviews        → 100K

  
এখানে practice করুন:
Indexing
Partitioning
Columnstore
Statistics
Compression
Batch Mode
Query Rewrite
Aggregation
Archiving









57. 58. Data Warehouse Optimization
54. Data Warehouse Optimization
Data Warehouse:
Bronze
  ↓
Silver
  ↓
Gold
  ↓
Power BI
Optimization:
Fact Tables
    ↓
Partitioning
    ↓
Columnstore
    ↓
Proper Distribution
    ↓
Statistics
    ↓
Aggregation
    ↓
Query Optimization
Typical:
FactSales
FactOrders
FactPayments
এবং:
DimCustomer
DimProduct
DimDate
DimEmployee






58. Hands-on Performance Lab
এখন আমাদের database দিয়ে আসল optimization practice শুরু করুন।
Lab 1 — SELECT *
❌ Bad
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1000;


✅ Better
SELECT
    OrderID,
    OrderDate,
    OrderStatus,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 1000;
Lab 2 — SARGability


  
❌ Bad
SELECT *
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2026;


✅ Good
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '20260101'
AND OrderDate < '20270101';


তারপর দুটো query-এর:
Execution Plan
STATISTICS IO
STATISTICS TIME
compare করুন।

  
Lab 3 — Scan বনাম Seek
প্রথমে:
SET STATISTICS IO ON;

SELECT *
FROM Sales.Orders
WHERE CustomerID = 25000;
Index তৈরি করুন:
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);
আবার:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 25000;
compare:
Scan
vs
Seek

  
Lab 4 — Key Lookup
CREATE INDEX IX_Orders_Customer
ON Sales.Orders(CustomerID);
Run:
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 1000;


Plan দেখুন।
যদি:
Index Seek
+
Key Lookup
দেখেন, তাহলে covering index বানান।
CREATE INDEX IX_Orders_Customer_Covering
ON Sales.Orders(CustomerID)
INCLUDE
(
    OrderDate,
    TotalAmount
);


Lab 5 — JOIN Optimization
SELECT
    c.Country,
    COUNT(*) AS OrderCount,
    SUM(o.TotalAmount) AS Revenue
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID
GROUP BY c.Country;


Analyze:
Join Type
Logical Reads
CPU
Memory
Execution Time


  
Lab 6 — GROUP BY
SELECT
    CustomerID,
    COUNT(*) AS Orders,
    SUM(TotalAmount) AS Revenue
FROM Sales.Orders
GROUP BY CustomerID;



দেখুন:
Hash Match
Stream Aggregate
Sort
Memory Grant


  
Lab 7 — Window Function
SELECT
    CustomerID,
    OrderDate,
    TotalAmount,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate DESC
    ) AS rn

FROM Sales.Orders;


তারপর:
CREATE INDEX IX_Orders_Customer_OrderDate
ON Sales.Orders(CustomerID, OrderDate DESC)
INCLUDE(TotalAmount);
Execution Plan compare করুন।


  
Lab 8 — CTE vs Temp Table
CTE
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT *
FROM CustomerSales
WHERE Revenue > 10000;
Temp Table
SELECT
    CustomerID,
    SUM(TotalAmount) AS Revenue
INTO #CustomerSales
FROM Sales.Orders
GROUP BY CustomerID;

CREATE INDEX IX_Temp_Customer
ON #CustomerSales(CustomerID);


SELECT *
FROM #CustomerSales
WHERE Revenue > 10000;



Compare:
CPU
I/O
Elapsed Time
Plan
Statistics


  
Lab 9 — Top 10 Customers
SELECT TOP (10)
    CustomerID,
    SUM(TotalAmount) AS Revenue
FROM Sales.Orders
GROUP BY CustomerID
ORDER BY SUM(TotalAmount) DESC;


Analyze:
Scan
Aggregate
Sort
Top
Memory Grant

  
Lab 10 — DMV Top Queries
SELECT TOP (20)
    execution_count,
    total_worker_time / 1000 AS CPU_ms,
    total_elapsed_time / 1000 AS Elapsed_ms,
    total_logical_reads,
    total_logical_writes
FROM sys.dm_exec_query_stats
ORDER BY total_worker_time DESC;


