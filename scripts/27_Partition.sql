1. Partitioning কী? 🧩
ধরুন একটি কোম্পানির FactSales table-এ 500 million rows আছে।

  
সব data একটি বড় physical structure-এ রাখার পরিবর্তে:
FactSales
│
├── Partition 1 → 2025-01
├── Partition 2 → 2025-02
├── Partition 3 → 2025-03
├── ...
├── Partition 24 → 2026-12
└── Partition 25 → Future
Logical table কিন্তু একই:
  
SELECT *
FROM fact.FactSales;
কিন্তু SQL Server internally data partition অনুযায়ী manage করতে পারে।




2. Partitioning কেন ব্যবহার করবো? 🎯
⚡ Query Performance
যদি query হয়:
  
SELECT
    SUM(SalesAmount)
FROM fact.FactSales
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2026-02-01';

SQL Server partition elimination করতে পারলে পুরো table scan না করে প্রয়োজনীয় partition-এ কাজ করতে পারে।


🧹 Data Maintenance
পুরনো বছরের data দ্রুত archive/remove করা যায়।
2025 data
   ↓
SWITCH OUT
   ↓
Archive table


  
📥 ETL Loading
নতুন মাসের data আগে staging table-এ load করে validation করার পর:
CSV/API
 ↓
Staging
 ↓
Validation
 ↓
SWITCH IN
 ↓
FactSales


  
📊 Data Warehouse
বিশেষ করে:
FactSales
FactOrders
FactTransactions
FactInventory
FactUsage
এর মতো বড় fact table-এ date-based partitioning খুব common design।







3. Partitioning-এর প্রধান সুবিধা ⭐
সুবিধা	                       ব্যবহার
⚡ Performance	             Partition elimination
🧹 Maintenance	             পুরনো partition manage
📥 ETL	                     SWITCH IN
📤 Archive	                 SWITCH OUT
🔄 Sliding Window	           Rolling historical data
📦 Large Tables	             Billions of rows
🗜️ Compression	             Partition-wise compression
📊 Columnstore	             Large analytical fact table
🔧 Index Maintenance	       Individual partition rebuild


⚠️ Partitioning নিজে কোনো magic performance button নয়। 
ভুল partition key বা non-SARGable predicate হলে benefit নাও পাওয়া যেতে পারে।









4. Partition vs Index 🔥
  
এটি খুব গুরুত্বপূর্ণ।
বিষয়	                      Partition	                       Index
উদ্দেশ্য	                    Data ভাগ করা	                   Data দ্রুত খুঁজে পাওয়া
কাজ	                      Physical/logical organization	   Access path
প্রধান ব্যবহার	                Large table management	         Query performance
Key	                        Partition Key	                   Index Key
Example	                    OrderDate	                       CustomerID
Elimination	                Partition elimination	           Index seek
Data movement	              SWITCH	                         সাধারণত নয়
Maintenance	                Partition-level possible	       Index-level




সহজভাবে
Partition = বড় আলমারিকে drawer-এ ভাগ করা

Index = drawer-এর ভিতরের index/catalog
একসাথে দুটোই ব্যবহার করা যায়।







5. Real Company Dataset 🏢
আমাদের fictional company:
GlobalMart Retail

  
Business:
Customers
Products
Categories
Employees
Departments
Stores
Sales
Main fact:

  
fact.FactSales
Partition key:
OrderDate
কারণ sales analytics সাধারণত date-based।









6. Partition Function 🧠
এটাই partitioning-এর সবচেয়ে গুরুত্বপূর্ণ অংশ।
আমরা OrderDate দিয়ে monthly partitions তৈরি করবো।
RANGE RIGHT
/* ============================================================
   RANGE RIGHT
   Boundary value belongs to the RIGHT partition
   ============================================================ */

CREATE PARTITION FUNCTION pf_SalesByMonth (DATE)
AS RANGE RIGHT
FOR VALUES
(
    '2025-01-01',
    '2025-02-01',
    '2025-03-01',
    '2025-04-01',
    '2025-05-01',
    '2025-06-01',
    '2025-07-01',
    '2025-08-01',
    '2025-09-01',
    '2025-10-01',
    '2025-11-01',
    '2025-12-01',

    '2026-01-01',
    '2026-02-01',
    '2026-03-01',
    '2026-04-01',
    '2026-05-01',
    '2026-06-01',
    '2026-07-01',
    '2026-08-01',
    '2026-09-01',
    '2026-10-01',
    '2026-11-01',
    '2026-12-01'
);
GO
এখানে 24 boundary ⇒ 25 partitions।









7. RANGE RIGHT বুঝুন
যদি:
RANGE RIGHT
এবং boundary:
2026-01-01
তাহলে:
Previous partition:
OrderDate < 2026-01-01

Next partition:
OrderDate >= 2026-01-01
AND
OrderDate < next boundary
অর্থাৎ:
2026-01-01
        ↓
RIGHT partition









8. RANGE LEFT 🆚 RANGE RIGHT
RANGE LEFT
CREATE PARTITION FUNCTION pf_Demo_Left (INT)
AS RANGE LEFT
FOR VALUES (100, 200, 300);



Logical ranges:
P1: < 100
P2: >=100 AND <=200
P3: >200 AND <=300
P4: >300



  
RANGE RIGHT
CREATE PARTITION FUNCTION pf_Demo_Right (INT)
AS RANGE RIGHT
FOR VALUES (100, 200, 300);


Logical ranges:
P1: <100

P2: >=100 AND <200

P3: >=200 AND <300

P4: >=300
Date partition-এর জন্য
আমি সাধারণত এই ধরনের design-এ:
RANGE RIGHT
ব্যবহার করবো।

  
কারণ monthly boundaries খুব পরিষ্কার:
2026-01-01
2026-02-01
2026-03-01






9. Partition Scheme 🗂️
Partition function শুধু বলে:
কোন data কোন partition-এ যাবে?

Partition scheme বলে:
সেই partition কোন filegroup-এ থাকবে?

/* ============================================================
   Partition Scheme
   For this learning project all partitions use PRIMARY.
   Enterprise systems can map partitions to separate filegroups.
   ============================================================ */

CREATE PARTITION SCHEME ps_SalesByMonth
AS PARTITION pf_SalesByMonth
ALL TO ([PRIMARY]);


GO
Production environment-এ multiple filegroup ব্যবহার করা যেতে পারে, যেমন:
FG_2025
FG_2026
FG_Future







10. Partitioned Fact Table 🔥
এটাই আমাদের প্রধান table।
CREATE TABLE fact.FactSales
(
    SaleID BIGINT IDENTITY(1,1) NOT NULL,

    OrderDate DATE NOT NULL,

    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    StoreID INT NOT NULL,

    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) NOT NULL,
    SalesAmount AS
        ((Quantity * UnitPrice) - DiscountAmount) PERSISTED,

    PaymentMethod VARCHAR(30) NOT NULL,

    CONSTRAINT PK_FactSales
        PRIMARY KEY NONCLUSTERED (SaleID)
);



GO
এখন partitioned clustered index তৈরি করবো।
/* ============================================================
   Clustered index is partitioned using OrderDate.
   This physically organizes the fact table by month.
   ============================================================ */

CREATE CLUSTERED INDEX CX_FactSales_OrderDate
ON fact.FactSales
(
    OrderDate,
    SaleID
)
ON ps_SalesByMonth(OrderDate);
GO

  
এখন:
FactSales
   ↓
Partitioned Clustered Index
   ↓
OrderDate
   ↓
Monthly partitions







11. Realistic 100,000 Sales Rows 📊
/* ============================================================
   Generate 100,000 realistic sales transactions
   Date range: 2025-01-01 through 2026-12-31
   ============================================================ */

;WITH SalesSeed AS
(
    SELECT TOP (100000)
        ROW_NUMBER() OVER
        (
            ORDER BY
                a.object_id,
                b.object_id
        ) AS RowNum
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT INTO fact.FactSales
(
    OrderDate,
    CustomerID,
    ProductID,
    EmployeeID,
    StoreID,
    Quantity,
    UnitPrice,
    DiscountAmount,
    PaymentMethod
)
SELECT
    DATEADD
    (
        DAY,
        RowNum % 730,
        CAST('2025-01-01' AS DATE)
    ) AS OrderDate,

    ((RowNum - 1) % 100) + 1 AS CustomerID,

    ((RowNum - 1) % 50) + 1 AS ProductID,

    ((RowNum - 1) % 30) + 1 AS EmployeeID,

    ((RowNum - 1) % 15) + 1 AS StoreID,

    ((RowNum - 1) % 10) + 1 AS Quantity,

    p.UnitPrice,

    CAST
    (
        CASE
            WHEN RowNum % 10 = 0
                THEN p.UnitPrice * 0.10
            ELSE 0
        END
        AS DECIMAL(12,2)
    ) AS DiscountAmount,

    CASE
        WHEN RowNum % 4 = 0 THEN 'Credit Card'
        WHEN RowNum % 4 = 1 THEN 'Cash'
        WHEN RowNum % 4 = 2 THEN 'Bank Transfer'
        ELSE 'Digital Wallet'
    END
FROM SalesSeed s
JOIN dim.Products p
    ON p.ProductID = ((s.RowNum - 1) % 50) + 1;
GO








12. Verify Data
SELECT
    COUNT(*) AS TotalRows,
    MIN(OrderDate) AS MinOrderDate,
    MAX(OrderDate) AS MaxOrderDate
FROM fact.FactSales;


Expected concept:
TotalRows = 100000
MinOrderDate = 2025-01-01
MaxOrderDate = 2026-12-31







13. Partition Information দেখা 🔎
/* ============================================================
   Check partition metadata
   ============================================================ */
SELECT
    OBJECT_SCHEMA_NAME(p.object_id) AS SchemaName,
    OBJECT_NAME(p.object_id) AS TableName,
    i.name AS IndexName,
    p.partition_number,
    p.rows
FROM sys.partitions p
JOIN sys.indexes i
    ON p.object_id = i.object_id
   AND p.index_id = i.index_id
WHERE p.object_id = OBJECT_ID('fact.FactSales')
ORDER BY
    p.partition_number;


এখানে আপনি দেখতে পারবেন:
Partition 1
Partition 2
Partition 3
...
Partition 25
এবং প্রত্যেক partition-এর row count।








14. Partition Boundary দেখুন
SELECT
    pf.name AS PartitionFunction,
    prv.boundary_id,
    prv.value AS BoundaryValue
FROM sys.partition_functions pf
JOIN sys.partition_range_values prv
    ON pf.function_id = prv.function_id
WHERE pf.name = 'pf_SalesByMonth'
ORDER BY prv.boundary_id;








15. কোন Date কোন Partition-এ? 🎯
SELECT
    $PARTITION.pf_SalesByMonth(OrderDate) AS PartitionNumber,
    COUNT(*) AS RowCount,
    MIN(OrderDate) AS MinDate,
    MAX(OrderDate) AS MaxDate
FROM fact.FactSales
GROUP BY
    $PARTITION.pf_SalesByMonth(OrderDate)
ORDER BY
    PartitionNumber;

$PARTITION হলো partition debugging শেখার জন্য খুব useful tool।







16. Partition Elimination ⚡
এটি Data Analyst-এর জন্য সবচেয়ে গুরুত্বপূর্ণ performance concept।
Query:
/* ============================================================
   SARGable date filter
   SQL Server can potentially eliminate unrelated partitions.
   ============================================================ */

SELECT
    SUM(SalesAmount) AS TotalSales
FROM fact.FactSales
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2026-02-01';



Conceptually:
FactSales
│
├── 2025 partitions ❌
│
├── 2026-01 partition ✅
│
└── other 2026 partitions ❌
এটিই:
Partition Elimination







17. SARGability কী? 🎯
SARGable predicate হলো এমন filter যা SQL Server-এর index/partition structure efficiently ব্যবহার করতে পারে।
ভালো
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2026-02-01'
সমস্যা তৈরি করতে পারে
WHERE YEAR(OrderDate) = 2026
কারণ column-এর উপর function apply করা হয়েছে।

  
আরেকটি:
WHERE MONTH(OrderDate) = 1
এখানেও একই সমস্যা।







18. SARGable Rewrite
❌ Avoid
SELECT *
FROM fact.FactSales
WHERE YEAR(OrderDate) = 2026
  AND MONTH(OrderDate) = 1;


✅ Prefer
SELECT *
FROM fact.FactSales
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2026-02-01';


Best Practice
Date filtering-এর জন্য:
>= StartDate
AND
< EndDate
pattern ব্যবহার করুন।







19. Execution Plan দিয়ে Partition Elimination দেখুন 🔍
SET STATISTICS IO ON;

SELECT
    COUNT(*)
FROM fact.FactSales
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2026-02-01';

SET STATISTICS IO OFF;
SSMS-এ:
Actual Execution Plan
enable করুন।
তারপর plan properties-এ partition-related information দেখুন।







20. Partitioned Index 📚
Table partitioned হলেই সব index automatically partitioned হয় না।
আমরা explicit aligned index তৈরি করতে পারি।
/* ============================================================
   Partitioned / Aligned Nonclustered Index
   ============================================================ */
CREATE INDEX IX_FactSales_Customer_OrderDate
ON fact.FactSales
(
    CustomerID,
    OrderDate
)
ON ps_SalesByMonth(OrderDate);

GO
এটি table-এর partition function/scheme অনুসরণ করছে।









21. Aligned Index কী?
যখন:
Table
 ↓
Partition Function A
 ↓
Partition Scheme A

Index
 ↓
Partition Function A
 ↓
Partition Scheme A
তখন index হলো Aligned Index।

  
Visual
FactSales
├── P1
├── P2
├── P3
└── P4

Index
├── P1
├── P2
├── P3
└── P4
এটি partition maintenance-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।









22. Non-Aligned Index
যেমন:
CREATE INDEX IX_FactSales_PaymentMethod
ON fact.FactSales(PaymentMethod)
ON [PRIMARY];


এটি table-এর partition scheme follow করছে না।
তাই এটি:
Non-Aligned Index
হতে পারে।
Partition SWITCH/maintenance-এর সময় non-aligned indexes গুরুত্বপূর্ণ constraint তৈরি করতে পারে। 
বিশেষ করে columnstore partition switching-এর ক্ষেত্রে index alignment requirements আরও কঠোর।










23. Partition Maintenance 🛠️
Partition function modify করার জন্য:
ALTER PARTITION FUNCTION
ব্যবহার হয়।
দুটি প্রধান operation:
SPLIT
MERGE
একটি partition function বহু table/index ব্যবহার করলে modification 
তাদের সবাইকে affect করে এবং atomic operation হিসেবে execute হয়।








24. SPLIT RANGE ➕
ধরুন future partition আছে এবং নতুন:
2027-01-01
boundary দরকার।
/* ============================================================
   Add a new partition boundary
   ============================================================ */

ALTER PARTITION FUNCTION pf_SalesByMonth()
SPLIT RANGE ('2027-01-01');
GO
এতে একটি partition দুই ভাগ হবে।







25. SPLIT-এর আগে NEXT USED
যদি partition scheme-এ multiple filegroups ব্যবহার করেন, SPLIT করার আগে নতুন partition-এর জন্য NEXT USED filegroup set করতে হয়।
Example:
ALTER PARTITION SCHEME ps_SalesByMonth
NEXT USED [PRIMARY];
GO

ALTER PARTITION FUNCTION pf_SalesByMonth()
SPLIT RANGE ('2027-01-01');
GO
Production-এ:
FG_2027
এর মতো filegroup ব্যবহার করা বেশি meaningful।








26. MERGE RANGE ➖
একটি boundary remove করে দুটি adjacent partition merge করা যায়।
/* ============================================================
   Merge two adjacent partitions
   ============================================================ */

ALTER PARTITION FUNCTION pf_SalesByMonth()
MERGE RANGE ('2027-01-01');
GO
⚠️ Production-এ populated partitions merge করার আগে খুব careful হতে হবে। 
Microsoft empty edge partitions রাখার এবং populated partition split/merge 
এড়িয়ে চলার recommendation দেয়, কারণ data movement/logging/locking-এর overhead হতে পারে।








27. SWITCH OUT 📤
এটি Partitioning-এর সবচেয়ে powerful featureগুলোর একটি।
ধরুন:
2025-01
data archive করতে চাই।
Concept:
FactSales
    │
    │ SWITCH OUT
    ↓
Archive.FactSales_2025_01
Data copy হয় না; metadata-level movement-এর মাধ্যমে partition reassignment হয়, subject to SWITCH restrictions.








28. SWITCH OUT Table তৈরি
প্রথমে archive table:
CREATE TABLE archive.FactSales_2025_01
(
    SaleID BIGINT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    StoreID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) NOT NULL,
    SalesAmount DECIMAL(12,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL
);
GO
⚠️ Actual SWITCH implementation-এ source/target
schema, indexes, constraints, filegroup, partition boundary 
এবং অন্যান্য SWITCH requirements exactly match করতে হবে। Target partition-টি empty হওয়াও গুরুত্বপূর্ণ।








28. SWITCH OUT-এর Conceptual Syntax
/* ============================================================
   SWITCH OUT pattern
   Replace partition number with the correct partition
   after checking sys.partitions.
   ============================================================ */

ALTER TABLE fact.FactSales
SWITCH PARTITION 2
TO archive.FactSales_2025_01;
GO
Partition number blindly assume করবেন না।

  
আগে:
SELECT
    $PARTITION.pf_SalesByMonth(OrderDate) AS PartitionNumber,
    COUNT(*) AS Rows
FROM fact.FactSales
GROUP BY $PARTITION.pf_SalesByMonth(OrderDate)
ORDER BY PartitionNumber;
দিয়ে verify করবেন।







29. SWITCH IN 📥
ETL process:
Source
  ↓
Staging
  ↓
Data Quality Check
  ↓
Staging Table
  ↓
SWITCH IN
  ↓
FactSales
এটি huge data movement-এর ক্ষেত্রে অত্যন্ত useful architecture।








30. SWITCH IN-এর জন্য Staging Table
CREATE TABLE staging.FactSales_Load
(
    SaleID BIGINT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    StoreID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) NOT NULL,
    SalesAmount DECIMAL(12,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL
);


GO
তারপর শুধু একটি নির্দিষ্ট partition range-এর data load করতে হবে।
উদাহরণ:
INSERT INTO staging.FactSales_Load
(
    SaleID,
    OrderDate,
    CustomerID,
    ProductID,
    EmployeeID,
    StoreID,
    Quantity,
    UnitPrice,
    DiscountAmount,
    SalesAmount,
    PaymentMethod
)
SELECT
    SaleID,
    OrderDate,
    CustomerID,
    ProductID,
    EmployeeID,
    StoreID,
    Quantity,
    UnitPrice,
    DiscountAmount,
    SalesAmount,
    PaymentMethod
FROM SomeSource
WHERE OrderDate >= '2027-01-01'
  AND OrderDate <  '2027-02-01';


তারপর SWITCH IN করার আগে validation:
SELECT
    MIN(OrderDate),
    MAX(OrderDate),
    COUNT(*)
FROM staging.FactSales_Load;






31. Sliding Window Architecture 🔄
Large Data Warehouse-এর খুব important pattern।
ধরুন retention:
Keep last 24 months

  
প্রতি মাসে:
Step 1
নতুন month boundary:
SPLIT

  
Step 2
নতুন data:
Load → Staging

  
Step 3
Validation:
Data Quality

  
Step 4
SWITCH IN

  
Step 5
পুরনো month:
SWITCH OUT

  
Step 6
Archive:
Archive.FactSales

  
Step 7
পুরনো empty partition:
MERGE







32. Sliding Window Visual
                 TIME →
────────────────────────────────────────────

2025-01  2025-02  ...  2026-11  2026-12  2027-01
   │        │               │        │        │
   │        │               │        │        │
   ↓        ↓               ↓        ↓        ↓

Archive ← SWITCH OUT       ACTIVE DATA       SWITCH IN

  
আরও practical:
          ┌───────────────────────┐
          │     FactSales         │
          ├───────────────────────┤
Oldest →  │ 2025-01               │ → SWITCH OUT
          │ 2025-02               │
          │ ...                   │
          │ 2026-11               │
          │ 2026-12               │
New     → │ 2027-01               │ ← SWITCH IN
          └───────────────────────┘










33. Fact Table + Partitioning 📊
Data Warehouse-এ common architecture:
                DimCustomer
                     │
                     │
DimProduct ───── FactSales ───── DimDate
                     │
                     │
                DimEmployee
                     │
                  DimStore

  
Fact table:
100M+
500M+
1B+
rows

  
এখানে:
Partition Key = OrderDate
খুব natural choice হতে পারে যখন workload predominantly time-based।







34. Columnstore + Partitioning 🚀
Large analytical fact table-এর জন্য Clustered Columnstore Index (CCI) অত্যন্ত গুরুত্বপূর্ণ।
Columnstore data column-wise compression এবং analytical scan-এর জন্য optimized।
আমরা আলাদা training table বানাবো:
CREATE TABLE fact.FactSalesColumnstore
(
    SaleID BIGINT NOT NULL,
    OrderDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    EmployeeID INT NOT NULL,
    StoreID INT NOT NULL,
    Quantity INT NOT NULL,
    UnitPrice DECIMAL(12,2) NOT NULL,
    DiscountAmount DECIMAL(12,2) NOT NULL,
    SalesAmount DECIMAL(12,2) NOT NULL,
    PaymentMethod VARCHAR(30) NOT NULL
)
ON ps_SalesByMonth(OrderDate);
GO
তারপর:
/* ============================================================
   Partitioned Clustered Columnstore Index
   ============================================================ */

CREATE CLUSTERED COLUMNSTORE INDEX CCI_FactSalesColumnstore
ON fact.FactSalesColumnstore
ON ps_SalesByMonth(OrderDate);


GO
এখন architecture:
FactSalesColumnstore
       │
       ├── Partition 1
       ├── Partition 2
       ├── Partition 3
       ├── ...
       └── Partition N
             │
             └── Columnstore
Partitioned clustered columnstore-এর জন্য SWITCH-এর সময় 
additional index/partition alignment restrictions থাকে; 
তাই production design-এ alignment আগে থেকে পরিকল্পনা করা জরুরি।








35. Columnstore-এ Analytical Query
/* ============================================================
   Analytical aggregation over partitioned columnstore fact
   ============================================================ */

SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    SUM(SalesAmount) AS TotalSales,
    SUM(Quantity) AS TotalQuantity
FROM fact.FactSalesColumnstore
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2027-01-01'
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY
    SalesYear,
    SalesMonth;


এটি:
Partitioning
+
Partition Elimination
+
Columnstore
+
Aggregation
এর একটি real analytical scenario।







36. Partition-level Compression 🗜️
Partition-wise maintenance/compression করা যায়।
উদাহরণ:
/* ============================================================
   Rebuild a specific partition
   ============================================================ */

ALTER TABLE fact.FactSales
REBUILD PARTITION = 10
WITH
(
    DATA_COMPRESSION = PAGE
);
GO
SQL Server partition-level rebuild support করে এবং compression setting partition অনুযায়ী maintain করা যায়।







37. Partition-wise Statistics/Metadata Investigation
SELECT
    OBJECT_SCHEMA_NAME(p.object_id) AS SchemaName,
    OBJECT_NAME(p.object_id) AS TableName,
    i.name AS IndexName,
    p.partition_number,
    p.rows,
    p.data_compression_desc
FROM sys.partitions p
JOIN sys.indexes i
    ON p.object_id = i.object_id
   AND p.index_id = i.index_id
WHERE p.object_id = OBJECT_ID('fact.FactSales')
ORDER BY
    p.partition_number;









38. Partition Distribution Analysis 📊
SELECT
    $PARTITION.pf_SalesByMonth(OrderDate) AS PartitionNumber,
    COUNT(*) AS TotalRows,
    SUM(SalesAmount) AS TotalSales,
    MIN(OrderDate) AS MinOrderDate,
    MAX(OrderDate) AS MaxOrderDate
FROM fact.FactSales
GROUP BY
    $PARTITION.pf_SalesByMonth(OrderDate)
ORDER BY
    PartitionNumber;


এটি Data Analyst-এর জন্য useful কারণ আপনি দেখতে পারবেন:
Partition
↓
Rows
↓
Sales
↓
Date range






39. Partition Function Metadata 🔍
SELECT
    pf.name AS PartitionFunction,
    pf.type_desc,
    pf.boundary_value_on_right,
    ps.name AS PartitionScheme
FROM sys.partition_functions pf
LEFT JOIN sys.partition_schemes ps
    ON pf.function_id = ps.function_id;
boundary_value_on_right = 1 হলে:
RANGE RIGHT






40. কোন Table কোন Partition Function ব্যবহার করছে?
SELECT
    SCHEMA_NAME(t.schema_id) AS SchemaName,
    t.name AS TableName,
    i.name AS IndexName,
    pf.name AS PartitionFunction,
    ps.name AS PartitionScheme
FROM sys.tables t
JOIN sys.indexes i
    ON t.object_id = i.object_id
JOIN sys.partition_schemes ps
    ON i.data_space_id = ps.data_space_id
JOIN sys.partition_functions pf
    ON ps.function_id = pf.function_id
ORDER BY
    SchemaName,
    TableName;
এটি production troubleshooting-এ খুব useful।








41. Partitioning + Index + SARGability একসাথে 🔥
ধরুন query:
SELECT
    c.Country,
    SUM(f.SalesAmount) AS TotalSales
FROM fact.FactSales f
JOIN dim.Customers c
    ON f.CustomerID = c.CustomerID
WHERE f.OrderDate >= '2026-01-01'
  AND f.OrderDate <  '2026-02-01'
GROUP BY
    c.Country;


এখানে:
OrderDate filter
       ↓
Partition Elimination
       ↓
Relevant partition
       ↓
Index access
       ↓
Join
       ↓
Aggregation
এটাই real-world analytical workload।









42. Common Mistake ❌
  
❌ Partitioning ≠ Index
Partitioning
এবং
Indexing
দুটি আলাদা optimization/organization technique।

  
❌ Wrong Partition Key
যদি query সবসময়:
WHERE CustomerID = 100
কিন্তু partition key:
OrderDate
তাহলে CustomerID filter-এর জন্য partition elimination হবে না।

  
❌ Function on Partition Key
WHERE YEAR(OrderDate) = 2026
এর বদলে:
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01'

  
❌ Too Many Partitions
প্রতিটি table-কে হাজার হাজার partition বানানোর প্রয়োজন নেই।
Partition granularity workload অনুযায়ী নির্বাচন করতে হবে:
Yearly
Monthly
Weekly
Daily

  
❌ Populated Partition SPLIT
Production-এ populated partition split করলে data movement এবং 
logging overhead হতে পারে। Empty edge partitions রেখে sliding-window design করা safer pattern।



❌ SWITCH-এর আগে Validation না করা
SWITCH কোনো সাধারণ INSERT নয়।
আগে verify:
Schema
Data types
Indexes
Constraints
Partition boundary
Filegroup
Data range







43. Data Analyst-এর জন্য Partitioning 🎯
Data Analyst হিসেবে সবচেয়ে গুরুত্বপূর্ণ:
1. Partition concept
2. Partition Key
3. RANGE LEFT
4. RANGE RIGHT
5. Partition elimination
6. SARGability
7. Execution Plan
8. Partition distribution
9. Fact table partitioning
10. Columnstore + partitioning

  
বিশেষ করে query optimization:
WHERE OrderDate >= @StartDate
AND OrderDate < @EndDate
pattern বুঝতে হবে।


