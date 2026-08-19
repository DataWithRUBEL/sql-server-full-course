1. TempDB কী? 🗄️
TempDB হলো SQL Server-এর একটি system database, যেখানে SQL Server temporary/internal কাজের জন্য অস্থায়ী data রাখে।
TempDB-তে কী কী থাকে?
- 🔹 Local Temporary Table — #Orders
- 🔹 Global Temporary Table — ##Orders
- 🔹 Temporary table-এর index
- 🔹 Temporary objects
- 🔹 Internal sorting/hash operations
- 🔹 কিছু query execution-এর intermediate data
- 🔹 Temporary result sets
- 🔹 Version store-এর কিছু workload



গুরুত্বপূর্ণ
SELECT name
FROM sys.databases;


আপনি tempdb দেখতে পাবেন।
USE tempdb;
GO

SELECT name
FROM sys.tables;







2. Temp Table কী? 📦
Temporary Table হলো এমন একটি table যা সাধারণত temporary কাজের জন্য তৈরি করা হয়।
সবচেয়ে common syntax:
CREATE TABLE #Orders
(
    OrderID INT,
    CustomerID INT,
    OrderDate DATE,
    SalesAmount DECIMAL(12,2)
);

এখানে:
#Orders
এর শুরুতে # থাকায় এটি Local Temporary Table।







3. 3. কেন Temp Table ব্যবহার করবো? 🎯
  
🔹 Intermediate Data
একটি complex query-এর intermediate result সংরক্ষণ করতে:
SELECT *
INTO #Orders
FROM Sales.Orders
WHERE OrderDate >= '2026-01-01';


🔹 Multi-Step Transformation
Source
  ↓
#Temp
  ↓
Clean
  ↓
Aggregate
  ↓
Join
  ↓
Final Result

  
🔹 Performance
একই intermediate dataset বারবার ব্যবহার করলে temporary table উপকারী হতে পারে।
  
🔹 Debugging
Complex ETL/SQL logic-এর মাঝখানের result inspect করা যায়।
  
🔹 Stored Procedure
Stored procedure-এর বিভিন্ন step-এর মধ্যে temporary data ধরে রাখা যায়।








4. SELECT INTO #Temp
এটি সবচেয়ে সহজভাবে temporary table তৈরি করার উপায়।
  
Syntax
SELECT columns
INTO #TempTable
FROM SourceTable
WHERE condition;



Example
/* ==============================================================================
   SELECT INTO #Temp
   Creates #Orders automatically based on SELECT result
   ============================================================================== */
SELECT *
INTO #Orders
FROM Sales_Orders;
Check:
SELECT *
FROM #Orders;


কী হলো?
SQL Server:
Sales_Orders
     ↓
SELECT *
     ↓
#Orders
নিজে থেকে table structure তৈরি করেছে।







5. SELECT INTO দিয়ে Calculated Column
শুধু source column নয়, calculated column-ও রাখা যায়।
/* ==============================================================================
   CREATE TEMP TABLE WITH CALCULATED SALES
   ============================================================================== */
SELECT
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS SalesAmount,
    OrderStatus
INTO #OrderSales
FROM Sales_Orders;


তারপর:
SELECT *
FROM #OrderSales;









6. CREATE TABLE #Temp
যখন table structure-এর উপর আপনার complete control দরকার, তখন CREATE TABLE ব্যবহার করুন।
Syntax
CREATE TABLE #TempTable
(
    Column1 DataType,
    Column2 DataType,
    Column3 DataType
);


Example
/* ==============================================================================
   CREATE TEMP TABLE MANUALLY
   ============================================================================== */
CREATE TABLE #CustomerSales
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100),
    TotalOrders INT,
    TotalSales DECIMAL(18,2)
);






7. INSERT INTO #Temp
CREATE TABLE করার পরে data insert করা যায়।
/* ==============================================================================
   INSERT DATA INTO TEMP TABLE
   ============================================================================== */
INSERT INTO #CustomerSales
(
    CustomerID,
    CustomerName,
    TotalOrders,
    TotalSales
)
SELECT
    c.CustomerID,
    c.CustomerName,
    COUNT(o.OrderID),
    SUM(o.Quantity * o.UnitPrice)
FROM Sales_Customers c
LEFT JOIN Sales_Orders o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName;


Check:
SELECT *
FROM #CustomerSales;







8. SELECT INTO vs INSERT INTO
  
বিষয়	                         SELECT INTO	           INSERT INTO
Table আগে থাকতে হবে?	         ❌ না	                 ✅ হ্যাঁ
Structure automatically তৈরি	 ✅	                     ❌
Data insert	                   ✅	                     ✅
Data type control	             সীমিত	                 বেশি
Constraints আগে define	       ❌	                     ✅
Reusable design	               কম	                   বেশি


সহজ rule
Quick temporary dataset
        ↓
SELECT INTO
আর:
Controlled temporary structure
        ↓
CREATE TABLE + INSERT INTO







9. UPDATE #Temp
Temporary table-এর data update করা যায়।
/* ==============================================================================
   UPDATE TEMP TABLE
   ============================================================================== */
UPDATE #OrderSales
SET OrderStatus = 'Completed'
WHERE OrderStatus = 'Delivered';


Check:
SELECT *
FROM #OrderSales;






10. DELETE FROM #Temp
/* ==============================================================================
   DELETE SPECIFIC ROWS FROM TEMP TABLE
   ============================================================================== */
DELETE FROM #OrderSales
WHERE OrderStatus = 'Cancelled';

শুধু specific rows delete হবে।






11. TRUNCATE TABLE #Temp
পুরো temporary table-এর data remove করতে:
TRUNCATE TABLE #OrderSales;

⚠️ Table structure থাকবে।
Rows        → removed
Structure   → remains







12. ALTER TABLE #Temp
Temporary table-এর structure পরিবর্তন করা যায়।
নতুন column
/* ==============================================================================
   ADD COLUMN TO TEMP TABLE
   ============================================================================== */
ALTER TABLE #CustomerSales
ADD CustomerSegment VARCHAR(30);


তারপর:
UPDATE #CustomerSales
SET CustomerSegment =
    CASE
        WHEN TotalSales >= 2000 THEN 'VIP'
        WHEN TotalSales >= 500 THEN 'Regular'
        ELSE 'New'
    END;






13. DROP TABLE IF EXISTS
Temporary table delete করার safest modern syntax:
DROP TABLE IF EXISTS #CustomerSales;


এর সুবিধা:
Exists
  ↓
Drop

-- Doesn't exist
  ↓
No error
তাই script-এর শুরুতে:

  
DROP TABLE IF EXISTS #Orders;
SELECT *
INTO #Orders
FROM Sales_Orders;
খুব common pattern।







14. Local Temporary Table #Temp
সবচেয়ে বেশি ব্যবহার করবেন:
#Orders
Example:
CREATE TABLE #Orders
(
    OrderID INT,
    SalesAmount DECIMAL(12,2)
);


Scope
সাধারণভাবে এটি যে session তৈরি করেছে সেই session-এর মধ্যে accessible।
Session A
   ↓
#Orders
   ↓
Available

  
অন্য session:

  
Session B
   ↓
#Orders
   ↓
Not available






15. Global Temporary Table ##Temp
দুইটি #:
##Orders
Example:
CREATE TABLE ##GlobalOrders
(
    OrderID INT,
    SalesAmount DECIMAL(12,2)
);


অন্য session থেকেও access করা যায়।
SELECT *
FROM ##GlobalOrders;


গুরুত্বপূর্ণ
Global temp table সাধারণত তখনই drop হয় যখন:
- যে session এটি তৈরি করেছে সেটি শেষ হয়
- এবং অন্য কোনো session আর table-টি ব্যবহার করছে না

  
Production Best Practice
সাধারণ business logic-এর জন্য:
#Temp
ব্যবহার করাই বেশি appropriate।
##Temp খুব সতর্কতার সাথে ব্যবহার করতে হয়, কারণ অন্য session-এর সাথে name/data collision হতে পারে।







16. Scope & Lifetime
Local Temp Table
CREATE TABLE #Orders
(
    OrderID INT
);


একই session-এর মধ্যে:
INSERT INTO #Orders
VALUES (1);

SELECT *
FROM #Orders;


কাজ করবে।
একটি stored procedure-এর ভিতরে তৈরি হলে 
সাধারণত procedure-এর execution scope-এর মধ্যে ব্যবহার করা যায়; 
procedure শেষ হওয়ার পর সেই local temp table আর available থাকে না।







17. Temp Table + JOIN 🔗
Temporary table ব্যবহার করে complex join-এর intermediate result তৈরি করা খুব common।
/* ==============================================================================
   TEMP TABLE + JOIN
   Get Delivered Orders
   ============================================================================== */
DROP TABLE IF EXISTS #DeliveredOrders;

SELECT
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice
INTO #DeliveredOrders
FROM Sales_Orders
WHERE OrderStatus = 'Delivered';


তারপর Customer-এর সাথে join:
SELECT
    o.OrderID,
    c.CustomerName,
    c.Country,
    o.OrderDate,
    o.Quantity,
    o.UnitPrice,
    o.Quantity * o.UnitPrice AS SalesAmount
FROM #DeliveredOrders o
INNER JOIN Sales_Customers c
    ON o.CustomerID = c.CustomerID;



Real-world use
Raw Orders
    ↓
Filter Delivered
    ↓
#DeliveredOrders
    ↓
JOIN Customer
    ↓
Reporting






18. Temp Table + GROUP BY 📊
/* ==============================================================================
   TEMP TABLE + GROUP BY
   Customer-level sales summary
   ============================================================================== */
DROP TABLE IF EXISTS #CustomerSummary;

SELECT
    CustomerID,
    COUNT(*) AS TotalOrders,
    SUM(Quantity * UnitPrice) AS TotalSales,
    AVG(Quantity * UnitPrice) AS AverageOrderValue
INTO #CustomerSummary
FROM Sales_Orders
WHERE OrderStatus <> 'Cancelled'
GROUP BY CustomerID;
Result:
SELECT *
FROM #CustomerSummary;








19. Temp Table + JOIN + GROUP BY
আরও realistic example:
/* ==============================================================================
   CUSTOMER SALES REPORT
   ============================================================================== */
DROP TABLE IF EXISTS #CustomerSalesReport;

SELECT
    c.CustomerID,
    c.CustomerName,
    c.Country,
    COUNT(o.OrderID) AS TotalOrders,
    SUM(o.Quantity * o.UnitPrice) AS TotalSales
INTO #CustomerSalesReport
FROM Sales_Customers c
INNER JOIN Sales_Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderStatus = 'Delivered'
GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Country;


তারপর:
SELECT *
FROM #CustomerSalesReport
ORDER BY TotalSales DESC;







20. Temp Table + CTE
CTE এবং Temp Table একসাথেও ব্যবহার করা যায়।
/* ==============================================================================
   TEMP TABLE + CTE
   ============================================================================== */
DROP TABLE IF EXISTS #CustomerSales;

SELECT
    CustomerID,
    SUM(Quantity * UnitPrice) AS TotalSales
INTO #CustomerSales
FROM Sales_Orders
WHERE OrderStatus = 'Delivered'
GROUP BY CustomerID;


তারপর CTE:
/* ==============================================================================
   CTE USES TEMP TABLE
   ============================================================================== */

WITH CustomerRanking AS
(
    SELECT
        CustomerID,
        TotalSales,
        CASE
            WHEN TotalSales >= 2000 THEN 'VIP'
            WHEN TotalSales >= 500 THEN 'Regular'
            ELSE 'Low Value'
        END AS CustomerSegment
    FROM #CustomerSales
)
SELECT *
FROM CustomerRanking;



Concept
Permanent Table
      ↓
  #Temp Table
      ↓
     CTE
      ↓
 Final Query








21. Temp Table + Window Functions 🪟
Temporary table-এর উপর window function চালানো যায়।
/* ==============================================================================
   TEMP TABLE FOR SALES
   ============================================================================== */
DROP TABLE IF EXISTS #CustomerSales;

SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Quantity * UnitPrice AS SalesAmount
INTO #CustomerSales
FROM Sales_Orders
WHERE OrderStatus = 'Delivered';



ROW_NUMBER
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    SalesAmount,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesAmount DESC
    ) AS SalesRank
FROM #CustomerSales;






22. Temp Table + RANK
SELECT
    CustomerID,
    SUM(SalesAmount) AS TotalSales,

    RANK() OVER
    (
        ORDER BY SUM(SalesAmount) DESC
    ) AS CustomerRank
FROM #CustomerSales
GROUP BY CustomerID;

এখানে প্রথমে:
GROUP BY
  
তারপর:
RANK()






23. Temp Table + LAG
/* ==============================================================================
   MONTHLY SALES TEMP TABLE
   ============================================================================== */
DROP TABLE IF EXISTS #MonthlySales;

SELECT
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    SUM(Quantity * UnitPrice) AS TotalSales
INTO #MonthlySales
FROM Sales_Orders
WHERE OrderStatus = 'Delivered'
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate);


তারপর:
SELECT
    SalesYear,
    SalesMonth,
    TotalSales,

    LAG(TotalSales) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS PreviousMonthSales
FROM #MonthlySales;








24. Primary Key on Temp Table 🔑
Temporary table-এ Primary Key দেওয়া যায়।
/* ==============================================================================
   TEMP TABLE WITH PRIMARY KEY
   ============================================================================== */
DROP TABLE IF EXISTS #Products;

CREATE TABLE #Products
(
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(100),
    Category VARCHAR(50),
    UnitPrice DECIMAL(12,2)
);


Insert:
INSERT INTO #Products
(
    ProductID,
    ProductName,
    Category,
    UnitPrice
)
SELECT
    ProductID,
    ProductName,
    Category,
    UnitPrice
FROM Sales_Products;
এখন duplicate ProductID insert করলে error হবে।






25. Constraints on Temp Table
Temporary table-এ constraints ব্যবহার করা যায়।
DROP TABLE IF EXISTS #Sales;

CREATE TABLE #Sales
(
    SalesID INT PRIMARY KEY,

    CustomerID INT NOT NULL,

    SalesAmount DECIMAL(18,2)
        CHECK (SalesAmount >= 0),

    OrderDate DATE NOT NULL
);



এখানে:
PRIMARY KEY
NOT NULL
CHECK
ব্যবহার করা হয়েছে।






26. Index on Temp Table ⚡
Large temporary dataset হলে index খুব useful হতে পারে।
DROP TABLE IF EXISTS #Orders;

SELECT *
INTO #Orders
FROM Sales_Orders;


Index:
/* ==============================================================================
   CREATE INDEX ON TEMP TABLE
   ============================================================================== */
CREATE INDEX IX_Orders_CustomerID
ON #Orders(CustomerID);
তারপর:
SELECT *
FROM #Orders
WHERE CustomerID = 2;







27. Composite Index
যদি frequently দুই column দিয়ে filter/join করেন:
CREATE INDEX IX_Orders_Customer_OrderDate
ON #Orders
(
    CustomerID,
    OrderDate
);
Example:
SELECT *
FROM #Orders
WHERE CustomerID = 2
  AND OrderDate >= '2026-01-01';






28. কখন Temp Table-এ Index দেবেন?
ভালো use case
#Temp
 ↓
100,000+ rows
 ↓
Repeated JOIN
 ↓
Repeated WHERE
 ↓
Repeated GROUP BY

  
Index বিবেচনা করুন।
ছোট dataset
#Temp = 20 rows
Index তৈরি করার overhead-এর কারণে লাভ নাও হতে পারে।









29. Temp Table in Stored Procedure ⚙️
Stored Procedure-এ temporary table অত্যন্ত common।
/* ==============================================================================
   STORED PROCEDURE + TEMP TABLE
   ============================================================================== */
CREATE OR ALTER PROCEDURE GetCustomerSales
    @Country VARCHAR(50)
AS
BEGIN

    SET NOCOUNT ON;

    DROP TABLE IF EXISTS #CustomerSales;

    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Country,
        SUM(o.Quantity * o.UnitPrice) AS TotalSales
    INTO #CustomerSales
    FROM Sales_Customers c
    INNER JOIN Sales_Orders o
        ON c.CustomerID = o.CustomerID
    WHERE c.Country = @Country
      AND o.OrderStatus = 'Delivered'
    GROUP BY
        c.CustomerID,
        c.CustomerName,
        c.Country;

    SELECT *
    FROM #CustomerSales
    ORDER BY TotalSales DESC;

END;



GO
Execute:
EXEC GetCustomerSales
    @Country = 'USA';






30. Temp Table + Transactions 🔄
Temporary table transaction-এর সাথেও কাজ করতে পারে।
/* ==============================================================================
   TEMP TABLE + TRANSACTION
   ============================================================================== */
DROP TABLE IF EXISTS #Orders;

CREATE TABLE #Orders
(
    OrderID INT,
    SalesAmount DECIMAL(18,2)
);

BEGIN TRANSACTION;

BEGIN TRY

    INSERT INTO #Orders
    VALUES
    (1, 1000),
    (2, 2000),
    (3, 3000);

    UPDATE #Orders
    SET SalesAmount = SalesAmount * 1.10;

    SELECT *
    FROM #Orders;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    ROLLBACK TRANSACTION;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;








31. Temp Table + TRY/CATCH 🛡️
Production SQL-এ error handling গুরুত্বপূর্ণ।
DROP TABLE IF EXISTS #Sales;

BEGIN TRY

    CREATE TABLE #Sales
    (
        SalesID INT PRIMARY KEY,
        SalesAmount DECIMAL(18,2)
    );

    INSERT INTO #Sales
    VALUES
    (1, 1000),
    (2, 2000);

    -- Intentional duplicate key error
    INSERT INTO #Sales
    VALUES
    (1, 5000);

END TRY

BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;








32. Temp Table vs Table Variable
  
এটি interview এবং real job—দুই জায়গাতেই গুরুত্বপূর্ণ।
বিষয়	                    Temp Table	                              Table Variable
Syntax	                  #Temp	                                    @Temp
TempDB ব্যবহার	            ✅	                                      ✅
Statistics	              সাধারণত বেশি optimizer-friendly	          সীমাবদ্ধতা আছে
Large data	              ⭐⭐⭐⭐⭐	                              ⭐⭐
Index	                    ✅	                                      সীমিত/ভিন্ন পদ্ধতি
ALTER TABLE	              ✅	                                      সীমিত
Transactions	            ✅	                                      আচরণ আলাদা
Complex query	            ভালো	                                    ছোট workload-এ ভালো
Scope	                    Session/procedure context	                Batch/procedure/function scope
Typical use	              Medium/Large intermediate data	          Small temporary data

  
  
Practical Rule
Small dataset
      ↓
@Table Variable
Medium/Large dataset
      ↓
#Temp Table
এটি absolute rule নয়—actual execution plan এবং workload দেখে সিদ্ধান্ত নিতে হবে।







33. Temp Table vs CTE
  
বিষয়	                          Temp Table	                    CTE
Physical temporary object	      ✅	                            ❌
Intermediate data store	        ✅	                            সাধারণত ❌
Multiple statements	            ✅	                            একটি statement-এর scope
Index	                          ✅	                            সরাসরি temp-table index নয়
Reuse	                          Multiple statements	            CTE statement scope
Large intermediate result	      Often useful	                  সবসময় ideal নয়
Recursive query	                ❌	                            ✅
Readability	                    ভালো	                          খুব ভালো


CTE
WITH SalesData AS
(
    SELECT *
    FROM Sales_Orders
)
SELECT *
FROM SalesData;



Temp Table
SELECT *
INTO #SalesData
FROM Sales_Orders;

SELECT *
FROM #SalesData;








34. Temp Table vs Permanent Staging Table
  
Data Engineering-এর জন্য এই distinction খুব গুরুত্বপূর্ণ।
  
বিষয়	                    Temp Table	                      Staging Table
Lifetime	                Temporary	                        Permanent
নাম	                      #Orders	                          stg.Orders
অন্য session	            Local হলে ❌	                    ✅
ETL pipeline	            ছোট/intermediate	                ✅
Audit/history	            ❌	                              ✅
Reusable	                সীমিত	                            ✅
Data persistence	        ❌	                              ✅
TempDB	                  সাধারণত	                          User database
Production ETL	          Intermediate steps	              Ingestion layer


Example
Source CSV
   ↓
Staging Table
   ↓
#CleanOrders
   ↓
Transform
   ↓
Gold Table








35. Temp Table vs Staging Table — Real Data Engineering Example
ধরুন CSV থেকে data এসেছে:
customers.csv
orders.csv
products.csv
প্রথমে:
CSV
 ↓
Permanent Staging Table
যেমন:
stg_orders


  
তারপর transformation:
SELECT *
INTO #CleanOrders
FROM stg_orders
WHERE OrderID IS NOT NULL;



তারপর:
#CleanOrders
      ↓
Validation
      ↓
Transformation
      ↓
Fact Table
  
অর্থাৎ:
Temp Table = temporary transformation workspace

আর:
Staging Table = persistent ingestion layer






36. আপনার দেওয়া Example-এর সঠিক Pattern
আপনার original pattern:
SELECT *
INTO #Orders
FROM Sales.Orders;

DELETE FROM #Orders
WHERE OrderStatus = 'Delivered';

SELECT *
INTO Sales.OrdersTest
FROM #Orders;


এখানে flow:
Sales.Orders
     ↓
#Orders
     ↓
DELETE
     ↓
Sales.OrdersTest
এটি কাজ করবে, তবে production scenario-তে আগে বুঝতে হবে আপনি Delivered rows কেন remove করছেন।
আর যদি উদ্দেশ্য হয় "Delivered ছাড়া clean data permanent table-এ রাখা", তাহলে আরও পরিষ্কার:




/* ==============================================================================
   CREATE TEMP TABLE FROM SOURCE
   ============================================================================== */
DROP TABLE IF EXISTS #Orders;

SELECT *
INTO #Orders
FROM Sales_Orders;


/* ==============================================================================
   CLEAN TEMPORARY DATA
   ============================================================================== */

DELETE FROM #Orders
WHERE OrderStatus = 'Delivered';


/* ==============================================================================
   CREATE TEST/PERMANENT TABLE
   ============================================================================== */

DROP TABLE IF EXISTS Sales_OrdersTest;

SELECT *
INTO Sales_OrdersTest
FROM #Orders;


/* ==============================================================================
   VERIFY RESULT
   ============================================================================== */

SELECT *
FROM Sales_OrdersTest;



তবে যদি Delivered data বাদ দেওয়ার উদ্দেশ্য শুধু filtering হয়, তাহলে unnecessary DELETE না করে শুরুতেই:
SELECT *
INTO #Orders
FROM Sales_Orders
WHERE OrderStatus <> 'Delivered';
এটি বেশি efficient হতে পারে।








37. TempDB Fundamentals ⚙️
Temp Table-এর পিছনে আসলে tempdb কাজ করে।
SELECT
    name,
    physical_name,
    size,
    state_desc
FROM sys.master_files
WHERE database_id = DB_ID('tempdb');


Temp table:
CREATE TABLE #Orders
(
    OrderID INT,
    SalesAmount DECIMAL(18,2)
);


SQL Server এটিকে TempDB-তে manage করে।
আপনি সাধারণত manually:
USE tempdb;

CREATE TABLE ...
করেই local temp table ব্যবহার করবেন না।
সঠিক pattern:
CREATE TABLE #Orders (...);






38. TempDB কেন গুরুত্বপূর্ণ?
High-concurrency SQL Server environment-এ TempDB খুব গুরুত্বপূর্ণ resource।
একসাথে অনেক user:
User 1 → #Temp
User 2 → #Temp
User 3 → #Temp
User 4 → #Temp
       ↓
    TempDB
তাই excessive temporary objects:
Too many temp tables
        +
Huge temp tables
        +
Heavy sorting/hashing
        ↓
TempDB pressure
তৈরি করতে পারে।








39. Execution Plan + Temp Table 🔍
Temporary table performance বুঝতে execution plan ব্যবহার করুন।
SSMS-এ:
Ctrl + M
তারপর:
DROP TABLE IF EXISTS #Orders;

SELECT *
INTO #Orders
FROM Sales_Orders;

CREATE INDEX IX_Orders_CustomerID
ON #Orders(CustomerID);

SELECT *
FROM #Orders
WHERE CustomerID = 2;
Actual Execution Plan দেখুন।








40. Index ছাড়া বনাম Index সহ
Without Index
SELECT *
FROM #Orders
WHERE CustomerID = 2;


অনেক rows scan করতে হলে:
Table/Scan
হতে পারে।
With Index
CREATE INDEX IX_Orders_CustomerID
ON #Orders(CustomerID);



তারপর:
SELECT *
FROM #Orders
WHERE CustomerID = 2;

Optimizer পরিস্থিতি অনুযায়ী index access ব্যবহার করতে পারে।
⚠️ তবে index থাকলেই query faster হবে—এমন guarantee নেই।






41. Temp Table Performance Best Practices ⚡
🚀 1. প্রয়োজনীয় column নিন
❌
SELECT *
INTO #Orders
FROM Sales_Orders;
Better:
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Quantity,
    UnitPrice
INTO #Orders
FROM Sales_Orders;



🚀 2. প্রয়োজনীয় row নিন
❌
SELECT *
INTO #Orders
FROM Sales_Orders;
Better:
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Quantity,
    UnitPrice
INTO #Orders
FROM Sales_Orders
WHERE OrderStatus = 'Delivered';




🚀 3. Repeated access হলে index বিবেচনা করুন
CREATE INDEX IX_Orders_CustomerID
ON #Orders(CustomerID);



🚀 4. Unnecessary Temp Table এড়িয়ে চলুন
এটি:
SELECT *
INTO #Temp
FROM Sales_Orders;

SELECT *
FROM #Temp
WHERE CustomerID = 10;
সবসময় দরকার নেই।
অনেক ক্ষেত্রে সরাসরি:
SELECT *
FROM Sales_Orders
WHERE CustomerID = 10;
যথেষ্ট।









42. Temp Table কখন ব্যবহার করবেন? 🎯
✅ Use করুন যখন:
- 🔹 Complex multi-step transformation
- 🔹 Intermediate dataset বারবার ব্যবহার করবেন
- 🔹 Large intermediate result
- 🔹 Multiple joins
- 🔹 Multiple aggregations
- 🔹 Stored Procedure-এর multiple steps
- 🔹 Debugging দরকার
- 🔹 Intermediate result-এর উপর index দরকার
- 🔹 ETL transformation-এর মাঝখানে temporary workspace দরকার





43. কখন Temp Table ব্যবহার না করাই ভালো?
❌ Avoid করুন যখন:
- 🔹 Query খুব simple
- 🔹 Intermediate result একবারই ব্যবহার হবে
- 🔹 Direct JOIN যথেষ্ট
- 🔹 Direct CTE যথেষ্ট
- 🔹 মাত্র কয়েকটি row
- 🔹 Unnecessary data copy হচ্ছে






44. Complete Real-World Temp Table Workflow 🔥
একটি realistic customer sales report:
/* ==============================================================================
   STEP 01: CLEANUP
   ============================================================================== */
DROP TABLE IF EXISTS #DeliveredOrders;


/* ==============================================================================
   STEP 02: CREATE TEMP TABLE
   Only delivered orders are required
   ============================================================================== */
SELECT
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS SalesAmount
INTO #DeliveredOrders
FROM Sales_Orders
WHERE OrderStatus = 'Delivered';


/* ==============================================================================
   STEP 03: CREATE INDEX
   CustomerID will be used for JOIN
   ============================================================================== */

CREATE INDEX IX_DeliveredOrders_CustomerID
ON #DeliveredOrders(CustomerID);


/* ==============================================================================
   STEP 04: CUSTOMER SUMMARY
   ============================================================================== */
DROP TABLE IF EXISTS #CustomerSales;

SELECT
    c.CustomerID,
    c.CustomerName,
    c.Country,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(o.SalesAmount) AS TotalSales,

    AVG(o.SalesAmount) AS AverageOrderValue

INTO #CustomerSales

FROM Sales_Customers c

INNER JOIN #DeliveredOrders o
    ON c.CustomerID = o.CustomerID

GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.Country;


/* ==============================================================================
   STEP 05: FINAL ANALYTICAL REPORT
   Window Function
   ============================================================================== */
SELECT
    CustomerID,
    CustomerName,
    Country,
    TotalOrders,
    TotalSales,
    AverageOrderValue,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS CustomerRank,

    CASE
        WHEN TotalSales >= 2000 THEN 'VIP'
        WHEN TotalSales >= 500 THEN 'Regular'
        ELSE 'Low Value'
    END AS CustomerSegment

FROM #CustomerSales

ORDER BY TotalSales DESC;



এখানে আপনি একসাথে ব্যবহার করেছেন:
#Temp
   ↓
SELECT INTO
   ↓
WHERE
   ↓
Index
   ↓
JOIN
   ↓
GROUP BY
   ↓
Aggregate
   ↓
Window Function
   ↓
CASE
   ↓
Final Report









45. Advanced Practice — Temp Table + CTE + Window Function 🚀
/* ==============================================================================
   ADVANCED TEMP TABLE PRACTICE
   ============================================================================== */
DROP TABLE IF EXISTS #MonthlyCustomerSales;

SELECT
    CustomerID,

    YEAR(OrderDate) AS SalesYear,

    MONTH(OrderDate) AS SalesMonth,

    SUM(Quantity * UnitPrice) AS TotalSales

INTO #MonthlyCustomerSales

FROM Sales_Orders

WHERE OrderStatus = 'Delivered'

GROUP BY
    CustomerID,
    YEAR(OrderDate),
    MONTH(OrderDate);




তারপর CTE:
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SalesYear,
        SalesMonth,
        TotalSales,

        LAG(TotalSales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousSales

    FROM #MonthlyCustomerSales
)

SELECT
    CustomerID,
    SalesYear,
    SalesMonth,
    TotalSales,
    PreviousSales,

    TotalSales - ISNULL(PreviousSales, 0) AS SalesChange

FROM CustomerSales

ORDER BY
    CustomerID,
    SalesYear,
    SalesMonth;


এটি Data Analyst-এর জন্য খুব realistic analytical pattern।






46. Temp Table Interview Concepts 🎓
আপনার অবশ্যই এই প্রশ্নগুলোর উত্তর জানা উচিত:
  
Beginner
- #Temp কী?
- TempDB কী?
- Temporary Table কেন ব্যবহার করি?
- SELECT INTO কী?
- CREATE TABLE #Temp কী?
- INSERT INTO #Temp কী?
- DROP TABLE IF EXISTS কেন ব্যবহার করি?


  
Intermediate
- Local vs Global Temp Table?
- Temp Table-এর scope কী?
- Temp Table-এর lifetime কী?
- Temp Table-এ index দেওয়া যায়?
- Primary Key দেওয়া যায়?
- Temp Table + JOIN কীভাবে কাজ করে?
- Temp Table + GROUP BY কেন ব্যবহার করবো?


  
Advanced
- Temp Table vs Table Variable?
- Temp Table vs CTE?
- Temp Table vs Staging Table?
- Temp Table কখন performance improve করে?
- Temp Table কখন performance খারাপ করতে পারে?
- TempDB contention কী?
- Execution Plan-এ Temp Table কীভাবে analyze করবেন?
- Temp Table-এর statistics optimizer-এর জন্য কেন গুরুত্বপূর্ণ?








