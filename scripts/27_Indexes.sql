1. Index কী? 🎯
- 🔎 সহজভাবে: Index হলো SQL Server-এর এমন একটি data structure 
  যা table-এর প্রয়োজনীয় row দ্রুত খুঁজে বের করতে সাহায্য করে।
- 📚 উদাহরণ: বইয়ের 500 page থেকে "SQL Server" খুঁজতে প্রতিটি page না পড়ে index ব্যবহার করলে দ্রুত পাওয়া যায়।
- 🗄️ Database: একইভাবে Orders table-এর 1 কোটি row থেকে CustomerID = 1050 খুঁজতে index সাহায্য করতে পারে।
- ⚡ মূল লক্ষ্য: I/O কমানো → কম page পড়া → query দ্রুত করা। 



-- Index ছাড়া SQL Server-কে অনেক বেশি data পড়তে হতে পারে
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1050;


-- CustomerID-এর উপর index থাকলে SQL Server
-- প্রয়োজনীয় row দ্রুত locate করতে পারে
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);








2. কেন Index ব্যবহার করবো?
- ⚡ Faster Search: WHERE query দ্রুত।
- 🔗 Faster JOIN: Foreign key দিয়ে join দ্রুত।
- 📊 Faster Aggregation: GROUP BY / aggregation-এ সাহায্য করতে পারে।
- ↕️ Faster Sorting: ORDER BY-এর জন্য useful।
- 🎯 Index Seek: প্রয়োজনীয় অংশ পড়তে পারে।
- 📉 I/O কমায়: কম data pages পড়তে হয়।
- 📈 Scalability: বড় table-এ performance ধরে রাখতে সাহায্য করে।
কিন্তু ⚠️
Index সবসময় ভালো নয়।
- ✍️ INSERT ধীর হতে পারে
- 🔄 UPDATE-এর overhead বাড়ে
- 🗑️ DELETE-এর overhead বাড়ে
- 💾 Disk space লাগে
- 🛠️ Maintenance প্রয়োজন
Rule:
"More indexes ≠ More performance."








3. Course Dataset Architecture
আমরা এই company dataset ব্যবহার করব:
IndexesDB
│
├── Sales
│   ├── Customers
│   ├── Orders
│   └── OrderItems
│
├── Product
│   ├── Categories
│   └── Products
│
├── HR
│   ├── Departments
│   └── Employees
│
└── Analytics
    └── SalesFact











4. এখন Dataset Check
/* ============================================================
   CHECK ROW COUNTS
   ============================================================ */

SELECT 'Departments' AS TableName, COUNT(*) AS RowCount
FROM HR.Departments

UNION ALL

SELECT 'Employees', COUNT(*)
FROM HR.Employees

UNION ALL

SELECT 'Categories', COUNT(*)
FROM Product.Categories

UNION ALL

SELECT 'Products', COUNT(*)
FROM Product.Products

UNION ALL

SELECT 'Customers', COUNT(*)
FROM Sales.Customers

UNION ALL

SELECT 'Orders', COUNT(*)
FROM Sales.Orders

UNION ALL

SELECT 'OrderItems', COUNT(*)
FROM Sales.OrderItems

UNION ALL

SELECT 'SalesFact', COUNT(*)
FROM Analytics.SalesFact;
GO








5. এখন শুরু হবে Actual Index Course 🔥
Level 1 — Index Fundamentals
1. Index Fundamentals
Index-এর মূল architecture:
Query
  ↓
Index
  ↓
Locate Row
  ↓
Data Page
  ↓
Result
  
Example:
CREATE INDEX IX_Customers_CustomerCode
ON Sales.Customers(CustomerCode);









Level 2 — Heap
2. Heap
যে table-এ clustered index নেই, সেটি সাধারণত heap।
CREATE TABLE dbo.HeapDemo
(
    ID INT,
    Name VARCHAR(100)
);

INSERT INTO dbo.HeapDemo
VALUES
(1,'Ahmed'),
(2,'Rahman'),
(3,'Karim');

-- কোনো clustered index নেই
-- তাই এটি Heap
Heap-এর data pages কোনো clustered key order অনুসারে সাজানো থাকে না।






Level 3 — B-Tree
3. B-Tree
SQL Server rowstore index সাধারণত B+ tree structure ব্যবহার করে; 
Microsoft documentation-ও rowstore indexes-এর ক্ষেত্রে B-tree/B+ tree terminology ব্যবহার করে। 
Microsoft Learn
Root
          ↓
      Branch Pages
       ↓      ↓
    Leaf     Leaf
     ↓        ↓
   Rows      Rows






Level 4 — Data Pages
4. Data Pages
SQL Server data page সাধারণত 8 KB।
Clustered table-এ clustered index-এর leaf level-ই table data ধারণ করে।






Level 5 — Index Pages
5. Index Pages
Nonclustered index-এর intermediate/leaf pages index key এবং row locator ধারণ করে।
Root Page
   ↓
Intermediate Page
   ↓
Leaf Page
   ↓
RID / Clustering Key






Level 6 — Clustered Index
CREATE CLUSTERED INDEX CX_Orders_OrderID
ON Sales.Orders(OrderID);

Clustered index-এর ক্ষেত্রে table-এর row storage clustered key-এর organization অনুসরণ করে।
⚠️ একটি table-এ সর্বোচ্চ একটি clustered index থাকতে পারে।






Level 7 — Nonclustered Index
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);

একটি table-এ একাধিক nonclustered index থাকতে পারে।





Level 8 — Primary Key + Index
ALTER TABLE Sales.Customers
ADD CONSTRAINT PK_Customers
PRIMARY KEY CLUSTERED(CustomerID);
Primary key একটি constraint।
Primary key নিজে index-এর সমার্থক নয়, 
কিন্তু SQL Server সাধারণত primary key enforce করার জন্য unique index তৈরি করে।






Level 9 — Unique Index
CREATE UNIQUE INDEX UX_Customers_Email
ON Sales.Customers(Email);

এখন duplicate email prevent হবে।






Level 10 — Single Column Index
CREATE INDEX IX_Orders_OrderDate
ON Sales.Orders(OrderDate);


Useful:
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '2026-01-01';






Level 11 — Composite Index
CREATE INDEX IX_Orders_Customer_Status
ON Sales.Orders(CustomerID, OrderStatus);

এটি দুই column-এর combination-এর জন্য।







12. Level 12 — Index Column Order
CREATE INDEX IX_Orders_Customer_Date
ON Sales.Orders
(
    CustomerID,
    OrderDate
);


এই query:
WHERE CustomerID = 20001
AND OrderDate >= '2026-01-01'
খুব natural fit।

  
কিন্তু:
WHERE OrderDate >= '2026-01-01'
এর জন্য একই index সবসময় ideal নয়।

  
গুরুত্বপূর্ণ ধারণা
(CustomerID, OrderDate)
        ↑
     Leading Key
Column order query workload অনুযায়ী design করতে হবে।







Level 13 — Selectivity
Selectivity = একটি predicate কতটা data বাদ দিতে পারে।
CustomerID = 20001
  
সাধারণত:
High Selectivity
      ↓
Few rows returned
      ↓
Index useful

  
কিন্তু:
IsActive = 1
যদি 99% row 1 হয়, selectivity কম।






Level 14 — Cardinality
Cardinality = একটি column-এ কত distinct value আছে।
SELECT
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT CustomerID) AS DistinctCustomers
FROM Sales.Orders;







Level 15 — Included Columns
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID)
INCLUDE
(
    OrderDate,
    OrderStatus,
    TotalAmount
);

এখানে CustomerID হলো key।
অন্যগুলো included columns।








Level 16 — Covering Index
এই query:
SELECT
    OrderDate,
    OrderStatus,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 20001;


Covering index:
CREATE INDEX IX_Orders_Customer_Covering
ON Sales.Orders(CustomerID)
INCLUDE
(
    OrderDate,
    OrderStatus,
    TotalAmount
);


Goal:
Index Seek
   ↓
সব প্রয়োজনীয় column
   ↓
No Key Lookup







Level 17 — Filtered Index
CREATE INDEX IX_Customers_Active
ON Sales.Customers(CustomerType)
WHERE IsActive = 1;

Useful যখন subset ছোট এবং frequently queried।






Level 18 — Foreign Key Index
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);

CREATE INDEX IX_Orders_EmployeeID
ON Sales.Orders(EmployeeID);

CREATE INDEX IX_OrderItems_OrderID
ON Sales.OrderItems(OrderID);

CREATE INDEX IX_OrderItems_ProductID
ON Sales.OrderItems(ProductID);

CREATE INDEX IX_Employees_DepartmentID
ON HR.Employees(DepartmentID);

CREATE INDEX IX_Products_CategoryID
ON Product.Products(CategoryID);

Foreign key column-এ index অনেক join workload-এর জন্য useful হতে পারে।









Level 19 — Index + WHERE
CREATE INDEX IX_Orders_Status
ON Sales.Orders(OrderStatus);


Test:
SELECT *
FROM Sales.Orders
WHERE OrderStatus = 'Delivered';





Level 20 — Index + JOIN
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);
Test:
SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.TotalAmount
FROM Sales.Customers c
INNER JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID = 20001;








Level 21 — Index + ORDER BY
CREATE INDEX IX_Orders_Customer_OrderDate
ON Sales.Orders
(
    CustomerID,
    OrderDate DESC
);
Query:
SELECT TOP 20
    OrderID,
    CustomerID,
    OrderDate,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 20001
ORDER BY OrderDate DESC;






Level 22 — Index + GROUP BY
CREATE INDEX IX_Orders_Customer
ON Sales.Orders(CustomerID);
Test:
SELECT
    CustomerID,
    COUNT(*) AS OrderCount,
    SUM(TotalAmount) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID;

⚠️ তবে GROUP BY query-তে index ব্যবহার হবে কিনা তা optimizer cost-এর উপর নির্ভর করে।





Level 23 — SARGability 🎯
SARGable predicate optimizer-কে index seek করার সুযোগ দেয়।
ভালো
SELECT *
FROM Sales.Orders
WHERE OrderDate >= '2026-01-01';
খারাপ pattern
SELECT *
FROM Sales.Orders
WHERE YEAR(OrderDate) = 2026;
কারণ column-এর উপর function apply করা হয়েছে।







Level 24 — Non-SARGable Query
❌
WHERE YEAR(OrderDate) = 2026
  
✅
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01';

আরও একটি
❌
WHERE LEFT(CustomerCode,3) = 'CUS'
  
✅
WHERE CustomerCode LIKE 'CUS%';







Level 25 — Index Seek
SELECT *
FROM Sales.Orders
WHERE OrderID = 500100;

যদি appropriate index থাকে:
Index Seek
অর্থাৎ SQL Server targeted location থেকে data খোঁজে।






Level 26 — Index Scan
SELECT *
FROM Sales.Orders
WHERE OrderStatus = 'Delivered';
যদি অনেক row match করে, optimizer scan বেছে নিতে পারে।
Scan মানেই খারাপ নয়।






Level 27 — Table Scan
Heap table-এর ক্ষেত্রে:
Table Scan
মানে পুরো heap-এর data pages পড়তে হতে পারে।






Level 28 — Key Lookup
Nonclustered index query-র প্রয়োজনীয় সব column না দিলে:
Index Seek
   ↓
Key Lookup
   ↓
Clustered Index

  
Example:
CREATE INDEX IX_Orders_Customer
ON Sales.Orders(CustomerID);
তারপর:
SELECT
    OrderDate,
    TotalAmount
FROM Sales.Orders
WHERE CustomerID = 20001;


এখানে lookup হতে পারে।
Covering index দিয়ে eliminate করার চেষ্টা করা যায়:
CREATE INDEX IX_Orders_Customer_Covering
ON Sales.Orders(CustomerID)
INCLUDE(OrderDate, TotalAmount);






Level 29 — RID Lookup
Heap table-এর nonclustered index lookup-এ RID Lookup দেখা যায়।
Nonclustered Index
       ↓
RID
       ↓
Heap Data Row






Level 30 — Execution Plan
SQL Server query execute করার আগে optimizer একটি execution strategy তৈরি করে।
SELECT *
FROM Sales.Orders
WHERE CustomerID = 20001;


SSMS:
Ctrl + M
তারপর query execute করুন।







Level 31 — Estimated Plan
Ctrl + L
Actual query execute না করেই estimated plan দেখা যায়।





Level 32 — Actual Plan
Ctrl + M
তারপর query execute করুন।
  
Compare করুন:
Estimated Rows
vs
Actual Rows





Level 33 — Statistics
SQL Server statistics optimizer-কে data distribution সম্পর্কে ধারণা দেয়।
UPDATE STATISTICS Sales.Orders;


Specific:
UPDATE STATISTICS Sales.Orders IX_Orders_CustomerID;








Level 34 — Cardinality Estimation
Optimizer অনুমান করে:
How many rows will this predicate return?
  
যেমন:
WHERE CustomerID = 20001
Estimated rows এবং actual rows-এর বড় difference হলে plan quality ক্ষতিগ্রস্ত হতে পারে।






Level 35 — Missing Index
Execution plan বা DMVs missing index suggestion দিতে পারে।
SELECT *
FROM Sales.Orders
WHERE CustomerID = 20001
AND OrderStatus = 'Delivered';

Plan-এ missing index suggestion দেখা যেতে পারে।
⚠️ Missing index recommendation blindly create করবেন না।






36. Level 36 — Index Usage DMV
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ius.user_seeks,
    ius.user_scans,
    ius.user_lookups,
    ius.user_updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats ius
    ON i.object_id = ius.object_id
    AND i.index_id = ius.index_id
    AND ius.database_id = DB_ID()
WHERE i.object_id > 0
ORDER BY
    ius.user_seeks DESC;






37. Level 37 — Index Metadata
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    OBJECT_NAME(object_id) AS TableName,
    index_id,
    name AS IndexName,
    type_desc,
    is_unique,
    is_primary_key,
    is_disabled
FROM sys.indexes
WHERE object_id > 0
ORDER BY TableName, index_id;





Level 38 — Duplicate Index
Example:
IX_Orders_Customer
(CustomerID)

  
এবং:
IX_Orders_Customer2
(CustomerID)
দুটো একই হলে duplicate index।
এটি unnecessary storage + write overhead তৈরি করে।






Level 39 — Redundant Index
ধরুন:
IX_Orders_Customer
(CustomerID)
  
এবং:
IX_Orders_Customer_Status
(CustomerID, OrderStatus)
প্রথম index workload অনুযায়ী redundant হতে পারে—কিন্তু automaticভাবে drop করা যাবে না।








Level 40 — Overlapping Index
Index A:
(CustomerID, OrderDate)

Index B:
(CustomerID, OrderDate, OrderStatus)
দুটোর workload overlap করতে পারে।
Production-এ workload analysis ছাড়া drop করবেন না।






Level 41 — Write Overhead
একটি row insert হলে:
INSERT
 ↓
Table
 ↓
Index 1
 ↓
Index 2
 ↓
Index 3
 ↓
Index 4
অর্থাৎ বেশি index → বেশি maintenance।






Level 42 — Fragmentation
SELECT
    OBJECT_SCHEMA_NAME(ps.object_id) AS SchemaName,
    OBJECT_NAME(ps.object_id) AS TableName,
    i.name AS IndexName,
    ps.avg_fragmentation_in_percent,
    ps.page_count
FROM sys.dm_db_index_physical_stats
(
    DB_ID(),
    NULL,
    NULL,
    NULL,
    'LIMITED'
) ps
JOIN sys.indexes i
    ON ps.object_id = i.object_id
    AND ps.index_id = i.index_id
WHERE ps.index_id > 0;







Level 43 — Reorganize
সাধারণভাবে moderate fragmentation-এর ক্ষেত্রে ব্যবহার করা যায়।
ALTER INDEX IX_Orders_CustomerID
ON Sales.Orders
REORGANIZE;





Level 44 — Rebuild
ALTER INDEX IX_Orders_CustomerID
ON Sales.Orders
REBUILD;
Rebuild বেশি intensive operation।





Level 45 — Statistics Maintenance
UPDATE STATISTICS Sales.Orders
WITH FULLSCAN;

অথবা:
EXEC sys.sp_updatestats;
Production maintenance workload অনুযায়ী পরিকল্পনা করতে হবে।






Level 46 — Computed Column Index
আমাদের OrderItems-এ:
LineTotal AS
(
    Quantity * UnitPrice
    * (1 - DiscountPercent / 100)
)
Computed column indexing-এর ক্ষেত্রে deterministic/precise requirements গুরুত্বপূর্ণ।


Example concept:
ALTER TABLE Sales.Customers
ADD FullName AS
(
    FirstName + ' ' + LastName
) PERSISTED;


তারপর:
CREATE INDEX IX_Customers_FullName
ON Sales.Customers(FullName);






Level 47 — Implicit Conversion
ধরুন:
CustomerID INT
  
কিন্তু query:
WHERE CustomerID = '20001'
SQL Server conversion করতে পারে।

  
Best:
WHERE CustomerID = 20001;
Data type matching index performance-এর জন্য গুরুত্বপূর্ণ।







Level 48 — Index Performance Testing
প্রথমে:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;


তারপর:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 20001;


Compare:
Logical Reads
CPU Time
Elapsed Time
Execution Plan
তারপর index create করে আবার test করুন।






Level 49 — Columnstore Index
Columnstore analytical workload-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
CREATE NONCLUSTERED COLUMNSTORE INDEX
NCCI_SalesFact
ON Analytics.SalesFact
(
    OrderDate,
    CustomerID,
    ProductID,
    Quantity,
    SalesAmount,
    CostAmount
);

Columnstore analytical aggregation-এর জন্য খুব উপযোগী।






Level 50 — Clustered Columnstore
CREATE CLUSTERED COLUMNSTORE INDEX
CCI_SalesFact
ON Analytics.SalesFact;
এতে table-এর primary storage columnstore format হয়।







Level 51 — Nonclustered Columnstore
CREATE NONCLUSTERED COLUMNSTORE INDEX
NCCI_SalesFact
ON Analytics.SalesFact
(
    OrderDate,
    ProductID,
    Quantity,
    SalesAmount
);

Operational rowstore table-এর উপর analytics acceleration-এর জন্য useful।







Level 52 — Row Groups
Columnstore data rowgroups-এ সংগঠিত হয়।
Columnstore
   ↓
Row Group
   ↓
Column Segments
একটি compressed rowgroup-এর maximum প্রায় 1,048,576 rows।





Level 53 — Column Segments
  
ধরুন:
SalesAmount
  
একটি rowgroup-এর মধ্যে SalesAmount column-এর compressed segment থাকবে।
Row Group
├── CustomerID Segment
├── ProductID Segment
├── OrderDate Segment
└── SalesAmount Segment







Level 54 — Delta Store
ছোট insert প্রথমে delta rowgroup-এ যেতে পারে।
SQL Server columnstore architecture-এ delta rowgroup একটি B-tree structure; 
threshold পূরণ হলে tuple mover এটিকে compressed columnstore rowgroup-এ রূপান্তর করতে পারে।






Level 55 — Segment Elimination
Query:
SELECT
    SUM(SalesAmount)
FROM Analytics.SalesFact
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2026-02-01';

যদি metadata দিয়ে বোঝা যায় কোনো segment-এ এই date নেই, SQL Server সেটি skip করতে পারে।




Level 56 — Batch Mode
Columnstore-এর অন্যতম গুরুত্বপূর্ণ advantage হলো batch mode execution।
Row Mode
1 row → process
1 row → process
1 row → process

Batch Mode
many rows → process together
Microsoft documentation অনুযায়ী batch mode columnstore workload-এর জন্য 
optimized এবং aggregation workload-এ substantial performance improvement দিতে পারে।







Level 57 — Partitioning
আমাদের SalesFact table-কে OrderDate অনুযায়ী partition করার practice করা যাবে।
Concept:
2025
2026
2027
2028
  
প্রতিটি partition আলাদা data subset ধারণ করবে।





Level 58 — Partitioned Index
Partition function:
  
CREATE PARTITION FUNCTION pf_OrderDate
(
    DATE
)
AS RANGE RIGHT FOR VALUES
(
    '2026-01-01',
    '2027-01-01',
    '2028-01-01'
);


Partition scheme:
CREATE PARTITION SCHEME ps_OrderDate
AS PARTITION pf_OrderDate
ALL TO ([PRIMARY]);

তারপর partitioned index/table design করা যায়।





Level 59 — Partition Elimination
Query:
SELECT *
FROM Analytics.SalesFact
WHERE OrderDate >= '2026-01-01'
AND OrderDate < '2027-01-01';

Partitioning ঠিকভাবে design হলে SQL Server প্রয়োজনীয় partition-এ সীমাবদ্ধ থাকতে পারে।






Level 60 — Partition Switching
ETL/Data Engineering-এর জন্য গুরুত্বপূর্ণ।
Concept:
Staging Partition
       ↓
SWITCH
       ↓
Production Partition
Example syntax:
ALTER TABLE dbo.StageSales
SWITCH TO Analytics.SalesFact
PARTITION 2;

⚠️ বাস্তবে SWITCH-এর জন্য source/target 
schema, indexes, constraints, partition boundaries ইত্যাদি compatible হতে হবে।






Level 61 — XML Index
আমাদের:
Product.Products.ProductSpecs
XML data।
CREATE PRIMARY XML INDEX
PXML_Products_ProductSpecs
ON Product.Products(ProductSpecs);


তারপর XML query:
SELECT
    ProductID,
    ProductName
FROM Product.Products
WHERE ProductSpecs.exist
(
    '/Product[WarrantyMonths > 12]'
) = 1;





Level 62 — Full-Text Index
Product description/search workload-এর জন্য Full-Text Search ব্যবহার করা যায়।
  
উদাহরণ:
ALTER TABLE Product.Products
ADD SearchDescription AS
(
    ProductName + ' ' + Brand
) PERSISTED;


তারপর Full-Text infrastructure configure করে:
CREATE FULLTEXT INDEX
ON Product.Products
(
    SearchDescription
)
KEY INDEX PK_Products;


এখানে আগে appropriate unique key তৈরি করতে হবে।
Search:
SELECT *
FROM Product.Products
WHERE CONTAINS
(
    SearchDescription,
    '"Samsung"'
);







Level 63 — Spatial Index
আমাদের customer location:
  
CustomerLocation GEOGRAPHY
Spatial index:
CREATE SPATIAL INDEX
SIX_Customers_Location
ON Sales.Customers(CustomerLocation);

Business example:
একটি নির্দিষ্ট location-এর কাছাকাছি customer খোঁজা।







Level 64 — JSON Index
আমাদের:
ProductAttributes NVARCHAR(MAX)
Traditional approach:
JSON_VALUE(ProductAttributes,'$.brand')
SQL Server 2025 (17.x)-এ native JSON 
data type এবং CREATE JSON INDEX এসেছে/available in preview; 
JSON index-এর জন্য clustered key requirement আছে। Microsoft Learn
  
Concept:
-- SQL Server 2025 / 17.x
CREATE JSON INDEX
JIX_Products_Attributes
ON Product.Products(ProductAttributes);

⚠️ আপনার SQL Server version অনুযায়ী এই section আলাদাভাবে test করতে হবে। 
Current Microsoft documentation অনুযায়ী featureটি SQL Server 2025 (17.x)-এর preview feature।






Level 65 — Memory-Optimized Index
Memory-optimized table-এর indexes disk-based table-এর traditional indexes থেকে আলাদা।
  
Example:
CREATE TABLE Sales.MemoryOrders
(
    OrderID BIGINT NOT NULL
        PRIMARY KEY NONCLUSTERED,

    CustomerID INT NOT NULL
        INDEX IX_MemoryOrders_Customer
        HASH WITH (BUCKET_COUNT = 10000),

    OrderDate DATETIME2 NOT NULL
)
WITH
(
    MEMORY_OPTIMIZED = ON
);

Hash index exact equality lookup-এর জন্য useful:
WHERE CustomerID = 20001
Range query-র জন্য nonclustered index বেশি appropriate হতে পারে।






Level 66 — Index Monitoring
Regular monitoring:
SELECT
    OBJECT_SCHEMA_NAME(i.object_id) AS SchemaName,
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    ISNULL(u.user_seeks,0) AS Seeks,
    ISNULL(u.user_scans,0) AS Scans,
    ISNULL(u.user_lookups,0) AS Lookups,
    ISNULL(u.user_updates,0) AS Updates
FROM sys.indexes i
LEFT JOIN sys.dm_db_index_usage_stats u
    ON i.object_id = u.object_id
    AND i.index_id = u.index_id
    AND u.database_id = DB_ID()
WHERE i.index_id > 0
ORDER BY
    Updates DESC;






Level 67 — Index Maintenance
Production maintenance-এর মধ্যে:
Index Usage
      ↓
Fragmentation
      ↓
Statistics
      ↓
Reorganize / Rebuild
      ↓
Performance Validation
Maintenance blindly schedule না করে workload অনুযায়ী করতে হবে।







Level 68 — Production Index Design 🏢
Production-এ index design করার সময়:
- 🎯 Workload: কোন query বেশি চলে?
- 🔎 Predicate: WHERE কোন column-এ?
- 🔗 JOIN: কোন column দিয়ে join?
- ↕️ Sorting: ORDER BY কী?
- 📊 Aggregation: GROUP BY কী?
- 🧮 Selectivity: কত rows return করে?
- 📦 Size: table কত বড়?
- ✍️ Writes: INSERT/UPDATE/DELETE কত বেশি?
- 💾 Storage: index কত space নিচ্ছে?
- 🛠️ Maintenance: rebuild/statistics cost কত?








Level 69 — Query Performance Tuning 🔥
  
একটি complete tuning workflow:
Slow Query
    ↓
Reproduce
    ↓
Actual Execution Plan
    ↓
STATISTICS IO/TIME
    ↓
Identify Bottleneck
    ↓
SARGability Check
    ↓
Index Check
    ↓
Statistics Check
    ↓
Create/Modify Index
    ↓
Retest
    ↓
Compare Before vs After


  
Example:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM Sales.Orders o
WHERE o.CustomerID = 20001
AND o.OrderDate >= '2026-01-01'
ORDER BY o.OrderDate DESC;



Candidate:
CREATE INDEX IX_Orders_Customer_Date
ON Sales.Orders
(
    CustomerID,
    OrderDate DESC
)
INCLUDE
(
    OrderStatus,
    TotalAmount
);




তারপর আবার:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM Sales.Orders o
WHERE o.CustomerID = 20001
AND o.OrderDate >= '2026-01-01'
ORDER BY o.OrderDate DESC;


Compare:
Before
Logical Reads = ?

After
Logical Reads = ?

Before
CPU = ?

After
CPU = ?







Level 70 — End-to-End Index Optimization Project 🏆
এটাই হবে পুরো course-এর final project।
Business Scenario
RUBEL Retail & Distribution Ltd.-এর management বলছে:
"Sales dashboard এবং customer order report ধীর হয়ে গেছে।"


  
আপনার কাজ:
Step 1 — Baseline
SET STATISTICS IO ON;
SET STATISTICS TIME ON;



Step 2 — Slow Query
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSales
FROM Sales.Customers c
INNER JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2026-01-01'
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalSales DESC;





Step 3 — Execution Plan
Check:
Table Scan?
Index Scan?
Index Seek?
Key Lookup?
Sort?
Hash Match?
Nested Loops?
Missing Index?



Step 4 — Analyze Existing Indexes
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    OBJECT_NAME(object_id) AS TableName,
    name AS IndexName,
    type_desc
FROM sys.indexes
WHERE object_id IN
(
    OBJECT_ID('Sales.Customers'),
    OBJECT_ID('Sales.Orders')
);




Step 5 — Candidate Index
CREATE INDEX IX_Orders_OrderDate_Customer
ON Sales.Orders
(
    OrderDate,
    CustomerID
)
INCLUDE
(
    TotalAmount
);





Step 6 — Retest
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.TotalAmount) AS TotalSales
FROM Sales.Customers c
INNER JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderDate >= '2026-01-01'
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY TotalSales DESC;

