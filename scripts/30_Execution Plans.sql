Execution Plan = SQL Server আপনার query-টি কীভাবে execute করার সিদ্ধান্ত নিয়েছে তার roadmap।

আপনি query লিখলেন:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 105;
SQL Server নিজে সিদ্ধান্ত নেয়:
Query
  ↓
Index Seek?
  ↓
Key Lookup?
  ↓
Join?
  ↓
Sort?
  ↓
Aggregate?
  ↓
Parallelism?
  ↓
Result
এই সিদ্ধান্তগুলো Execution Plan-এ দেখা যায়।





1. Execution Plan কেন শিখবেন? 🎯
🔍 Performance
Execution Plan দেখে বোঝা যায়:
- Query কেন slow?
- Table Scan হচ্ছে কেন?
- Index Seek হচ্ছে কি?
- কোন operator সবচেয়ে expensive?
- Join কোন algorithm ব্যবহার করছে?
- Sort হচ্ছে কেন?
- Memory বেশি লাগছে কেন?
- TempDB spill হচ্ছে কি?
- Query parallel হচ্ছে কি?

  
👨‍💻 Data Analyst
Data Analyst হিসেবে আপনি:
- Slow report query optimize করবেন
- Power BI SQL source optimize করবেন
- JOIN performance analyze করবেন
- Aggregation optimize করবেন
- SARGability বুঝবেন
- Index recommendation বুঝবেন


  
🏗️ Data Engineer
Data Engineer হিসেবে আপনি:
- ETL query optimize করবেন
- Data Warehouse query tune করবেন
- Fact/Dimension join optimize করবেন
- Columnstore performance analyze করবেন
- Partition elimination verify করবেন
- Query Store দিয়ে regression খুঁজবেন
- Production workload tune করবেন








2. Execution PlansDB — Real Company Practice Environment
আমরা একটি fictional কিন্তু realistic E-Commerce + Data Warehouse company তৈরি করব।

  
Architecture:
[Execution plansDB]

├── Sales
│   ├── Customers
│   ├── Products
│   ├── Orders
│   └── OrderItems
│
├── HR
│   ├── Departments
│   └── Employees
│
└── Warehouse
    ├── DimDate
    └── FactSales

  
Business scenario:
Customer
   ↓
Order
   ↓
OrderItems
   ↓
Product
   ↓
Category
এবং:
Employee
   ↓
Department


  
Data Warehouse:
DimDate ─────┐
             │
DimCustomer ─┼── FactSales ── DimProduct
             │
DimEmployee ─┘



/* =========================================================
   Verify Dataset
   ========================================================= */

SELECT 'Departments' AS TableName, COUNT(*) AS RowCount
FROM HR.Departments

UNION ALL

SELECT 'Employees', COUNT(*)
FROM HR.Employees

UNION ALL

SELECT 'Customers', COUNT(*)
FROM Sales.Customers

UNION ALL

SELECT 'Products', COUNT(*)
FROM Sales.Products

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Sales.Orders

UNION ALL

SELECT 'OrderItems', COUNT(*)
FROM Sales.OrderItems

UNION ALL

SELECT 'DimDate', COUNT(*)
FROM Warehouse.DimDate

UNION ALL

SELECT 'FactSales', COUNT(*)
FROM Warehouse.FactSales;
GO






3. প্রথমে Execution Plan কীভাবে দেখবেন? 🔎
  
SSMS-এ:
Estimated Plan
Ctrl + L

  
অথবা:
Query
→ Display Estimated Execution Plan
Actual Plan
Ctrl + M

  
তারপর query execute করুন।
SELECT *
FROM Sales.Customers
WHERE CustomerID = 500;







4. Execution Plan Fundamentals
Execution Plan মূলত SQL Server-এর query execution strategy।
  
উদাহরণ:
SELECT
    CustomerID,
    CustomerName
FROM Sales.Customers
WHERE CustomerID = 500;


Plan হতে পারে:
SELECT
  ↓
Clustered Index Seek
  ↓
Result
কিন্তু যদি filter এমন হয়:
SELECT *
FROM Sales.Customers
WHERE CustomerName LIKE '%500%';



তাহলে:
SELECT
  ↓
Clustered Index Scan
  ↓
Result
কারণ % দিয়ে শুরু হওয়া search সাধারণ B-tree index efficiently seek করতে পারে না।








5. Estimated vs Actual Execution Plan
  
বিষয়	                        Estimated	                 Actual
Query execute করে?	             ❌	                     ✅
Actual rows	                     ❌	                     ✅
Estimated rows	                 ✅	                     ✅
Runtime information	             ❌	                     ✅
Performance debugging	           Good	                   ⭐ Best



Practice
-- Estimated Plan
SELECT *
FROM Sales.Orders
WHERE CustomerID = 100;

-- Actual Plan
SELECT *
FROM Sales.Orders
WHERE CustomerID = 100;







6. Execution Plan Operators
সবচেয়ে গুরুত্বপূর্ণ operators:
Index Seek
Index Scan
Table Scan
Key Lookup
Nested Loops
Hash Match
Merge Join
Sort
Stream Aggregate
Hash Aggregate
Filter
Compute Scalar
Sort
Spool
Parallelism
একজন SQL Server professional-এর জন্য operator চিনতে পারা অত্যন্ত গুরুত্বপূর্ণ।







7. Scan vs Seek
Index Seek ⚡
নির্দিষ্ট data খুঁজে বের করে।

  
SELECT *
FROM Sales.Customers
WHERE CustomerID = 500;
যদি suitable index থাকে:
Index Seek
Scan 🐌
পুরো index/table বা বড় অংশ পড়ে।

  
SELECT *
FROM Sales.Customers
WHERE CustomerName LIKE '%Customer 500%';



গুরুত্বপূর্ণ কথা
Scan সবসময় খারাপ নয়।
যদি table-এর 80% rows দরকার হয়, Scan অনেক সময় Seek + Lookup-এর চেয়ে ভালো হতে পারে।








8. Index + Key Lookup
প্রথমে একটি index তৈরি করুন:
CREATE INDEX IX_Customers_CustomerSegment
ON Sales.Customers(CustomerSegment);


GO
তারপর:
SELECT
    CustomerID,
    CustomerName,
    Email,
    City
FROM Sales.Customers
WHERE CustomerSegment = 'VIP';



Plan হতে পারে:
Index Seek
     ↓
Key Lookup
     ↓
Nested Loops
     ↓
SELECT
কারণ index-এ CustomerSegment আছে, কিন্তু SELECT-এর অন্য columns নেই।






9. Covering Index
Key Lookup কমাতে:
CREATE INDEX IX_Customers_Segment_Covering
ON Sales.Customers(CustomerSegment)
INCLUDE
(
    CustomerName,
    Email,
    City,
    Country
);



GO
এখন query:
SELECT
    CustomerName,
    Email,
    City,
    Country
FROM Sales.Customers
WHERE CustomerSegment = 'VIP';



Plan:
Index Seek
    ↓
SELECT
Key Lookup বাদ যেতে পারে।
⚠️ Best Practice
সব column INCLUDE করবেন না।


  
কারণ:
- Index বড় হবে
- INSERT slow হবে
- UPDATE slow হবে
- Storage বাড়বে
- Maintenance cost বাড়বে








10. Nested Loops
সাধারণত ছোট outer input + indexed inner input-এর ক্ষেত্রে ভালো।
SELECT
    o.OrderID,
    c.CustomerName
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID
WHERE o.CustomerID = 100;


Concept:
Orders
  ↓
Nested Loops
  ↓
Customers Index Seek







11. Hash Match
বড় dataset join বা aggregation-এর ক্ষেত্রে SQL Server Hash Match ব্যবহার করতে পারে।
SELECT
    o.CustomerID,
    SUM(o.TotalAmount)
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID
GROUP BY o.CustomerID;


Concept:
Orders
   ↓
Hash Build
   ↓
Hash Match
   ↑
Customers
⚠️ লক্ষ্য করবেন
Hash Match নিজে bad operator নয়।
Large datasets-এ এটি খুব effective হতে পারে।






12. Merge Join
Merge Join সাধারণত দুই input sorted থাকলে কার্যকর।
Input A
  ↓
Sorted
  ↓
Merge Join
  ↑
Sorted
  ↑
Input B

  
Practice:
SELECT
    o.OrderID,
    c.CustomerName
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID;








13. Sort Operator
SELECT
    CustomerID,
    TotalAmount
FROM Sales.Orders
ORDER BY TotalAmount DESC;


Plan-এ:
Scan
 ↓
Sort
 ↓
SELECT
Large data হলে Sort expensive হতে পারে।






14. Aggregate
Stream Aggregate
Sorted input-এর সাথে ভালো কাজ করে।
Hash Aggregate
Unsorted large input-এর ক্ষেত্রে SQL Server Hash Aggregate ব্যবহার করতে পারে।

  
Practice:
SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID;






15. Estimated Rows vs Actual Rows
এটি execution plan tuning-এর সবচেয়ে গুরুত্বপূর্ণ concepts-এর একটি।

  
ধরুন:
Estimated Rows = 10
Actual Rows    = 10,000
এটি বড় সমস্যা।

  
কারণ SQL Server ভেবেছিল:
10 rows

  
কিন্তু বাস্তবে:
10,000 rows
এর ফলে ভুল হতে পারে:
- Nested Loops
- Hash Join
- Memory Grant
- Parallelism
- Join order






16. Cardinality Estimation
Cardinality Estimator SQL Server-কে estimate করতে সাহায্য করে:
"এই operator থেকে কত rows আসবে?"

উদাহরণ:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 999;


SQL Server statistics দেখে estimate করবে।
যদি estimate:
100 rows

  
কিন্তু actual:
10,000 rows
তাহলে plan quality খারাপ হতে পারে।







17. Statistics 📊
Statistics SQL Server-কে data distribution সম্পর্কে ধারণা দেয়।
দেখতে পারেন:
DBCC SHOW_STATISTICS
(
    'Sales.Orders',
    'IX_Orders_CustomerID'
);


Statistics update:
UPDATE STATISTICS Sales.Orders;
সব statistics:
EXEC sys.sp_updatestats;

⚠️ গুরুত্বপূর্ণ
sp_updatestats production tuning-এর automatic replacement নয়। 
Statistics maintenance workload অনুযায়ী পরিকল্পনা করতে হয়।







18. SARGability
SARGable = Search ARGument able
  
Bad:
SELECT *
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2026;


Better:
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '20260101'
  AND OrderDate <  '20270101';


আরেকটি:
❌
WHERE LEFT(CustomerName, 3) = 'Ali'

  
Better:
WHERE CustomerName LIKE 'Ali%';
Rule
Column-এর উপর function
        ↓
অনেক সময় Seek নষ্ট








19. Implicit Conversion
উদাহরণ:
DECLARE @CustomerID VARCHAR(20) = '500';

SELECT *
FROM Sales.Customers
WHERE CustomerID = @CustomerID;


Data type mismatch হলে implicit conversion হতে পারে।
Plan warning দেখা যেতে পারে।

  
Better:
DECLARE @CustomerID INT = 500;


Best Practice
Parameter এবং column-এর data type consistent রাখুন।






20. Execution Plan Warnings ⚠️
  
Plan-এ warning দেখতে পারেন:
- Missing Index
- Implicit Conversion
- Spill to TempDB
- Excessive Grant
- No Join Predicate
- Residual Predicate
- Cardinality issues

  
Missing Index example:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 500
AND OrderStatus = 'Completed';



Plan recommendation দেখতে পারেন।
  
কিন্তু:
Missing Index recommendation blindly create করবেন না।

Existing indexes, write workload, storage এবং query workload analyse করতে হবে।





21. Memory Grant
Sort/Hash operations memory চায়।
  
Plan-এ:
Requested Memory
Granted Memory
Used Memory
দেখা যেতে পারে।
  
Problem:
Requested = 500 MB
Used      = 20 MB
মানে excessive grant হতে পারে।
  
অন্যদিকে:
Requested = 20 MB
Needed    = 500 MB
হলে spill হতে পারে।







22. TempDB Spill
Hash বা Sort memory-তে fit না করলে TempDB ব্যবহার করতে পারে।
Concept:
Sort
 ↓
Memory insufficient
 ↓
TempDB Spill
 ↓
Performance ↓
Execution Plan-এ warning দেখতে পারেন।

  
Practice:
SELECT
    CustomerID,
    SUM(TotalAmount)
FROM Sales.Orders
GROUP BY CustomerID
ORDER BY SUM(TotalAmount) DESC;
Actual plan দেখুন।






23. Spools
Spool operator intermediate result temporarily store করে।

  
Common types:
Table Spool
Index Spool
Lazy Spool
Eager Spool

  
Concept:
Input
 ↓
Spool
 ↓
Reuse
  
Spool সবসময় problem নয়।
কিন্তু unexpected expensive spool থাকলে query/index/join strategy investigate করতে হবে।







24. Parallelism
Large query multiple CPU threads ব্যবহার করতে পারে।
  
Plan:
Parallelism
   ↓
Multiple Threads
   ↓
Parallelism
   ↓
Result

  
Common operators:
Distribute Streams
Repartition Streams
Gather Streams

  
⚠️ ভুল ধারণা
Parallelism = Bad ❌

না।
Large analytical workload-এ parallelism খুব beneficial হতে পারে।





25. Window Function Plans
  
Practice:
SELECT
    CustomerID,
    OrderDate,
    TotalAmount,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS OrderSequence
FROM Sales.Orders;


Plan-এ দেখতে পারেন:
Scan
 ↓
Sort
 ↓
Segment
 ↓
Sequence Project
 ↓
SELECT






26. CTE vs Temp Table Plans
CTE:
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


Temp Table:
SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
INTO #CustomerSales
FROM Sales.Orders
GROUP BY CustomerID;

SELECT *
FROM #CustomerSales
WHERE TotalSales > 10000;



Key idea
CTE সাধারণত materialized temporary table নয়।
  
Temp table:
- Statistics থাকতে পারে
- Index তৈরি করা যায়
- Multiple statements-এ reuse করা যায়







27. Stored Procedure Plans
Create:
CREATE OR ALTER PROCEDURE Sales.GetCustomerOrders
    @CustomerID INT
AS
BEGIN

    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        TotalAmount
    FROM Sales.Orders
    WHERE CustomerID = @CustomerID;

END;



GO
Run:
EXEC Sales.GetCustomerOrders
    @CustomerID = 500;
Actual plan দেখুন।








28. Parameter Sniffing 🎯
এটি SQL Server performance tuning-এর advanced topic।
Stored Procedure compile হওয়ার সময় প্রথম parameter-এর 
value optimizer plan selection-এ প্রভাব ফেলতে পারে।

  
উদাহরণ:
EXEC Sales.GetCustomerOrders
    @CustomerID = 1;


তারপর:
EXEC Sales.GetCustomerOrders
    @CustomerID = 999;


যদি data distribution খুব skewed হয়, একই cached plan দ্বিতীয় parameter-এর জন্য ভালো নাও হতে পারে।
Possible techniques:
OPTION (RECOMPILE)

  
অথবা:
OPTIMIZE FOR
কিন্তু এগুলো blindly ব্যবহার করবেন না।






29. Plan Cache
SQL Server compiled execution plans cache করে।
  
DMV:
SELECT
    cp.usecounts,
    cp.size_in_bytes,
    st.text
FROM sys.dm_exec_cached_plans cp
CROSS APPLY
sys.dm_exec_sql_text(cp.plan_handle) st;


এখানে দেখতে পারেন:
- Cached queries
- Plan reuse
- Use count









30. STATISTICS IO
SET STATISTICS IO ON;

SELECT *
FROM Sales.Orders
WHERE CustomerID = 500;


SET STATISTICS IO OFF;

দেখবেন:
logical reads
physical reads
read-ahead reads
lob logical reads
সবচেয়ে গুরুত্বপূর্ণ
Logical Reads
অনেক logical reads মানে query অনেক pages পড়ছে।






31. STATISTICS TIME
SET STATISTICS TIME ON;

SELECT
    CustomerID,
    SUM(TotalAmount)
FROM Sales.Orders
GROUP BY CustomerID;


SET STATISTICS TIME OFF;
দেখবেন:
CPU time
elapsed time
গুরুত্বপূর্ণ
CPU Time
Elapsed Time
দুটো আলাদা।






32. Query Store 
Production performance management-এর জন্য Query Store অত্যন্ত গুরুত্বপূর্ণ।
Enable:
ALTER DATABASE [Execution plansDB]
SET QUERY_STORE = ON;


GO
তারপর Query Store থেকে analyse করতে পারবেন:
- Query performance
- Execution plans
- Runtime statistics
- Plan changes
- Regressions
- CPU
- Duration
- Reads
- Execution count







33. DMVs
SQL Server performance troubleshooting-এ গুরুত্বপূর্ণ DMV:
sys.dm_exec_query_stats
sys.dm_exec_sql_text
sys.dm_exec_cached_plans
sys.dm_exec_query_plan


  
Example:
SELECT TOP 20

    qs.execution_count,

    qs.total_worker_time,

    qs.total_elapsed_time,

    qs.total_logical_reads,

    qs.total_physical_reads,

    qs.total_worker_time
        / NULLIF(qs.execution_count,0)
        AS AvgCPU,

    st.text

FROM sys.dm_exec_query_stats qs

CROSS APPLY
sys.dm_exec_sql_text
(
    qs.sql_handle
) st

ORDER BY
    qs.total_worker_time DESC;








34. Query Regression
একই query:
আগে:
100 ms


  
পরে:
8,000 ms
এটিই query regression-এর example।
Possible reasons:
Statistics changed
        ↓
Data volume changed
        ↓
Index changed
        ↓
Plan changed
        ↓
Performance degraded
Query Store এখানে অত্যন্ত useful।







35. Data Warehouse Execution Plans
Data Warehouse-এ সাধারণ pattern:
DimCustomer
      ↓
DimProduct
      ↓
DimDate
      ↓
FactSales


  
Practice:
SELECT
    d.CalendarYear,
    p.ProductID,
    SUM(f.SalesAmount) AS TotalSales
FROM Warehouse.FactSales f
JOIN Warehouse.DimDate d
    ON f.DateKey = d.DateKey
JOIN Sales.Products p
    ON f.ProductID = p.ProductID
GROUP BY
    d.CalendarYear,
    p.ProductID;



Plan analyse করুন:
FactSales
   ↓
Hash Join
   ↓
Hash Join
   ↓
Aggregate
   ↓
Sort







36. Columnstore
Data Warehouse-এর বড় Fact Table-এর জন্য Columnstore অত্যন্ত গুরুত্বপূর্ণ।
প্রথমে:
CREATE CLUSTERED COLUMNSTORE INDEX
CCI_FactSales
ON Warehouse.FactSales;



GO
তারপর:
SELECT
    ProductID,
    SUM(SalesAmount) AS TotalSales,
    SUM(Quantity) AS TotalQuantity
FROM Warehouse.FactSales
GROUP BY ProductID;



Execution Plan-এ দেখতে পারেন:
Columnstore Scan
       ↓
Batch Mode
       ↓
Aggregate
Analytical workloads-এর জন্য এটি অত্যন্ত powerful।






37. Partition Elimination
  
বড় Fact Table:
2022
2023
2024
2025
2026

  
Date-based partitioning করলে query:
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01'
শুধু প্রয়োজনীয় partition read করতে পারে।
Concept:
Fact Table
│
├── Partition 2022 ❌
├── Partition 2023 ❌
├── Partition 2024 ❌
├── Partition 2025 ❌
└── Partition 2026 ✅
এটাই Partition Elimination।








38. Adaptive Query Processing
Modern SQL Server-এ optimizer runtime information ব্যবহার করে query execution improve করতে পারে।

  
Important concepts:
Adaptive Join
Memory Grant Feedback
Interleaved Execution
Batch Mode on Rowstore
Adaptive Join


  
একই plan runtime-এ সিদ্ধান্ত নিতে পারে:
Small input
   ↓
Nested Loops
অথবা:
Large input
   ↓
Hash Join







39. Production Performance Tuning
Production-এ query tuning করার সময় এই workflow ব্যবহার করুন:
1. Identify slow query
       ↓
2. Capture Actual Plan
       ↓
3. Check duration
       ↓
4. Check CPU
       ↓
5. Check logical reads
       ↓
6. Find expensive operators
       ↓
7. Compare Estimated vs Actual Rows
       ↓
8. Check indexes
       ↓
9. Check statistics
       ↓
10. Check SARGability
       ↓
11. Check joins
       ↓
12. Check memory
       ↓
13. Check spills
       ↓
14. Check parallelism
       ↓
15. Rewrite query
       ↓
16. Test
       ↓
17. Compare metrics
       ↓
18. Deploy
       ↓
19. Monitor








40. End-to-End Real Company Project
এখন পুরো Execution Plan skill একটি project-এ প্রয়োগ করুন।
Scenario
একটি E-Commerce company-এর Power BI Sales Dashboard slow।
Business query:
SELECT
    c.Country,
    p.Category,
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,

    SUM(oi.LineTotal) AS TotalSales,

    SUM(oi.Quantity) AS TotalQuantity,

    COUNT(DISTINCT o.CustomerID) AS Customers

FROM Sales.Orders o

JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID

JOIN Sales.OrderItems oi
    ON o.OrderID = oi.OrderID

JOIN Sales.Products p
    ON oi.ProductID = p.ProductID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    c.Country,
    p.Category,
    YEAR(o.OrderDate),
    MONTH(o.OrderDate)

ORDER BY
    SalesYear,
    SalesMonth;








41. Project Phase 1 — Baseline
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    c.Country,
    p.Category,
    SUM(oi.LineTotal) AS TotalSales
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.CustomerID = c.CustomerID
JOIN Sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN Sales.Products p
    ON oi.ProductID = p.ProductID
WHERE o.OrderStatus = 'Completed'
GROUP BY
    c.Country,
    p.Category;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;



Record:
CPU Time
Elapsed Time
Logical Reads
Physical Reads
Execution Plan






42. Project Phase 2 — Identify Bottleneck
Plan-এ check করুন:
❓ Table Scan?
❓ Index Scan?
❓ Key Lookup?
❓ Sort?
❓ Hash Match?
❓ Large memory grant?
❓ Spill?
❓ Estimated/Actual mismatch?
❓ Parallelism?







43. Project Phase 3 — Index Experiment
উদাহরণ:
CREATE INDEX IX_Orders_Status_Customer_Date
ON Sales.Orders
(
    OrderStatus,
    CustomerID,
    OrderDate
)
INCLUDE
(
    EmployeeID,
    TotalAmount
);




GO
OrderItems:
CREATE INDEX IX_OrderItems_Order_Product
ON Sales.OrderItems
(
    OrderID,
    ProductID
)
INCLUDE
(
    Quantity,
    UnitPrice,
    DiscountAmount
);
GO









44. Project Phase 4 — Re-run
একই query আবার execute করুন।
  
Compare:
  
Metric	                   Before	                 After
CPU	                       High	                    ?
Duration	                 High	                    ?
Logical Reads	             High	                    ?
Scan	                     Yes	                    ?
Lookup	                   Yes	                    ?
Memory	                   High	                    ?


নিজে numbers লিখে compare করবেন।
এটাই real-world performance tuning-এর মূল methodology।





