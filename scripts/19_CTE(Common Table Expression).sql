1. CTE Fundamentals
  
CTE কী?
CTE = Common Table Expression
সহজভাবে:
CTE হলো একটি temporary named result set, যেটাকে একই SQL statement-এর মধ্যে table-এর মতো ব্যবহার করা যায়।

Basic Syntax
-- =========================================================
-- Basic CTE Syntax
-- =========================================================
WITH CTE_Name AS
(
    SELECT
        column1,
        column2
    FROM TableName
)
SELECT *
FROM CTE_Name;


গুরুত্বপূর্ণ
CTE নিজে permanent table নয়।
WITH CTE
   ↓
Temporary Result
   ↓
Main Query
   ↓
CTE শেষ

  
CTE কেন ব্যবহার করব?
🧹 Readable: complex query সহজ হয়
🔄 Reusable: একই result একাধিকবার ব্যবহার করা যায়
🧩 Modular: বড় query ছোট logical অংশে ভাগ করা যায়
📊 Analytics: Window Function-এর সাথে খুব useful
🌳 Hierarchy: Recursive CTE দিয়ে hierarchy পাওয়া যায়
⚙️ ETL: Transformation logic পরিষ্কার করা যায়







2. Basic CTE
-- =========================================================
-- Basic CTE
-- Get all completed orders
-- =========================================================
WITH CompletedOrders AS
(
    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        Status
    FROM Orders
    WHERE Status = 'Completed'
)
SELECT *
FROM CompletedOrders;


কী হচ্ছে?
প্রথমে:
WITH CompletedOrders AS (...)
একটি result তৈরি হলো।
  
তারপর:
SELECT *
FROM CompletedOrders;

সেই result ব্যবহার করল।







3. CTE + WHERE
CTE-এর ভিতরে filtering করা যায়।
-- =========================================================
-- CTE + WHERE
-- Find high-value products
-- =========================================================
WITH ExpensiveProducts AS
(
    SELECT
        ProductID,
        ProductName,
        Price
    FROM Products
    WHERE Price >= 500
)
SELECT *
FROM ExpensiveProducts;

Real-world use
যেমন:
শুধু active customer → তারপর তাদের উপর analytics চালানো।






4. CTE + CASE
-- =========================================================
-- CTE + CASE
-- Categorize products by price
-- =========================================================
WITH ProductCategory AS
(
    SELECT
        ProductID,
        ProductName,
        Price,

        CASE
            WHEN Price >= 1000 THEN 'Premium'
            WHEN Price >= 500 THEN 'High'
            WHEN Price >= 100 THEN 'Medium'
            ELSE 'Low'
        END AS PriceCategory

    FROM Products
)
SELECT *
FROM ProductCategory;







5. CTE + GROUP BY
-- =========================================================
-- CTE + GROUP BY
-- Calculate total sales by customer
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    INNER JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT *
FROM CustomerSales;


কখন?
      Customer sales
      Product sales
      Monthly sales
      Department salary
      Employee performance







6. CTE + HAVING
HAVING aggregate result filter করে।
-- =========================================================
-- CTE + HAVING
-- Find customers whose sales exceed 1000
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    INNER JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
    HAVING SUM(oi.Quantity * oi.UnitPrice) > 1000
)
SELECT *
FROM CustomerSales;


WHERE বনাম HAVING
  
WHERE	                HAVING
Row filter	          Group filter
GROUP BY-এর আগে	    GROUP BY-এর পরে
Normal column	        Aggregate condition






7. CTE + JOIN
-- =========================================================
-- CTE + JOIN
-- Calculate customer sales and join customer information
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    INNER JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY CustomerID
)
SELECT
    c.CustomerID,
    c.CustomerName,
    c.Country,
    cs.TotalSales
FROM Customers c
INNER JOIN CustomerSales cs
    ON c.CustomerID = cs.CustomerID;


Real-world
CTE → Calculate
       ↓
JOIN → Add business information
       ↓
Final Report







8. Multiple CTE
একটি query-তে একাধিক CTE থাকতে পারে।
-- =========================================================
-- Multiple CTE
-- Customer sales + product sales
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
),

ProductSales AS
(
    SELECT
        oi.ProductID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY oi.ProductID
)

SELECT *
FROM CustomerSales;



Syntax
WITH CTE1 AS (...),
     CTE2 AS (...),
     CTE3 AS (...)
SELECT ...





9. Chained CTE
এখানে দ্বিতীয় CTE প্রথম CTE-কে ব্যবহার করবে।
-- =========================================================
-- Chained CTE
-- CTE2 uses CTE1
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
),
CustomerClassification AS
(
    SELECT
        CustomerID,
        TotalSales,

        CASE
            WHEN TotalSales >= 2000 THEN 'VIP'
            WHEN TotalSales >= 1000 THEN 'Regular'
            ELSE 'Low Value'
        END AS CustomerType
    FROM CustomerSales
)
SELECT *
FROM CustomerClassification;



এটি খুব গুরুত্বপূর্ণ pattern:
Raw Data
   ↓
CTE 1: Aggregation
   ↓
CTE 2: Classification
   ↓
Final Report






10. CTE + Aggregate
-- =========================================================
-- CTE + Aggregate
-- Calculate average customer sales
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY CustomerID
)
SELECT
    AVG(TotalSales) AS AverageCustomerSales,
    MAX(TotalSales) AS HighestCustomerSales,
    MIN(TotalSales) AS LowestCustomerSales
FROM CustomerSales;


এখানে CTE আগে customer-level aggregation করেছে।
তারপর outer query সেই result-এর উপর aggregate করেছে।








11. CTE + Window Functions
CTE + Window Function হলো real-world analytics-এর অত্যন্ত গুরুত্বপূর্ণ combination।
-- =========================================================
-- CTE + Window Function
-- Add overall average sales
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT
    CustomerID,
    TotalSales,

    AVG(TotalSales) OVER () AS AverageSales
FROM CustomerSales;








12. CTE + ROW_NUMBER
Customer sales ranking তৈরি করি।
-- =========================================================
-- CTE + ROW_NUMBER
-- Rank customers by sales
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT
    CustomerID,
    TotalSales,

    ROW_NUMBER() OVER
    (
        ORDER BY TotalSales DESC
    ) AS SalesRank
FROM CustomerSales;


গুরুত্বপূর্ণ
ROW_NUMBER() সবসময় unique sequence দেয়।








13. CTE + RANK / DENSE_RANK
-- =========================================================
-- CTE + RANK + DENSE_RANK
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT
    CustomerID,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS SalesRank,

    DENSE_RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS DenseSalesRank
FROM CustomerSales;


পার্থক্য
ROW_NUMBER()
→ 1, 2, 3, 4

RANK()
→ 1, 2, 2, 4

DENSE_RANK()
→ 1, 2, 2, 3





14. CTE + LAG / LEAD
Monthly sales comparison:
-- =========================================================
-- CTE + LAG
-- Compare current month with previous month
-- =========================================================
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.OrderDate),
            MONTH(o.OrderDate),
            1
        ) AS SalesMonth,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate)
)
SELECT
    SalesMonth,
    TotalSales,
    LAG(TotalSales) OVER
    (
        ORDER BY SalesMonth
    ) AS PreviousMonthSales
FROM MonthlySales;



LEAD
-- =========================================================
-- LEAD
-- Get next month's sales
-- =========================================================
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.OrderDate),
            MONTH(o.OrderDate),
            1
        ) AS SalesMonth,

        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales

    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.Status = 'Completed'

    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate)
)
SELECT
    SalesMonth,
    TotalSales,

    LEAD(TotalSales) OVER
    (
        ORDER BY SalesMonth
    ) AS NextMonthSales
FROM MonthlySales;









15. CTE + Running Total
-- =========================================================
-- Running Total
-- =========================================================
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(o.OrderDate),
            MONTH(o.OrderDate),
            1
        ) AS SalesMonth,

        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales

    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.Status = 'Completed'

    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate)
)
SELECT
    SalesMonth,
    TotalSales,

    SUM(TotalSales) OVER
    (
        ORDER BY SalesMonth
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningTotal
FROM MonthlySales;


Real-world use
        📈 YTD Sales
        💰 Cumulative Revenue
        📦 Cumulative Quantity
        📊 Running Customer Count






16. CTE + Subquery
CTE-এর ভিতরেও subquery ব্যবহার করা যায়।
-- =========================================================
-- CTE + Subquery
-- Find customers above average sales
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT *
FROM CustomerSales
WHERE TotalSales >
(
    SELECT AVG(TotalSales)
    FROM CustomerSales
);

এখানে CTE result-এর ওপর subquery average বের করছে।








17. CTE + IN / EXISTS
IN
-- =========================================================
-- CTE + IN
-- Find customers who placed completed orders
-- =========================================================
WITH CompletedCustomers AS
(
    SELECT DISTINCT
        CustomerID
    FROM Orders
    WHERE Status = 'Completed'
)
SELECT
    CustomerID,
    CustomerName
FROM Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM CompletedCustomers
);





EXISTS
-- =========================================================
-- CTE + EXISTS
-- =========================================================

WITH CompletedCustomers AS
(
    SELECT DISTINCT
        CustomerID
    FROM Orders
    WHERE Status = 'Completed'
)
SELECT
    c.CustomerID,
    c.CustomerName
FROM Customers c
WHERE EXISTS
(
    SELECT 1
    FROM CompletedCustomers cc
    WHERE cc.CustomerID = c.CustomerID
);



EXISTS কখন useful?
বিশেষ করে:
শুধু record আছে কিনা check করতে হলে।







18. CTE + Deduplication
Real data engineering-এ duplicate removal অত্যন্ত গুরুত্বপূর্ণ।
ধরি customer data-তে duplicate আছে।
-- =========================================================
-- Create duplicate customer example
-- =========================================================
SELECT *
INTO CustomerStaging
FROM Customers;

INSERT INTO CustomerStaging
VALUES
(9, 'John Smith', 'USA', 'New York'),
(10, 'John Smith', 'USA', 'New York');
এখন deduplication:


  
-- =========================================================
-- Deduplication using ROW_NUMBER
-- =========================================================
WITH DeduplicatedCustomers AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerName, Country, City
            ORDER BY CustomerID
        ) AS rn
    FROM CustomerStaging
)
SELECT *
FROM DeduplicatedCustomers
WHERE rn = 1;


Pattern
Duplicate data
      ↓
ROW_NUMBER()
      ↓
rn = 1
      ↓
Unique data







19. CTE + Top N per Group
এটি Data Analyst interview এবং real reporting-এ খুব common।
প্রতিটি category-এর Top 2 products
-- =========================================================
-- Top 2 Products per Category
-- =========================================================
WITH ProductSales AS
(
    SELECT
        p.CategoryID,
        p.ProductID,
        p.ProductName,

        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales

    FROM Products p

    JOIN OrderItems oi
        ON p.ProductID = oi.ProductID

    JOIN Orders o
        ON oi.OrderID = o.OrderID

    WHERE o.Status = 'Completed'

    GROUP BY
        p.CategoryID,
        p.ProductID,
        p.ProductName
),

RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CategoryID
            ORDER BY TotalSales DESC
        ) AS rn

    FROM ProductSales
)
SELECT *
FROM RankedProducts
WHERE rn <= 2;


⭐ গুরুত্বপূর্ণ Pattern
ROW_NUMBER()
OVER
(
    PARTITION BY GroupColumn
    ORDER BY Measure DESC
)
এটাই Top N per Group pattern।






20. Non-Recursive CTE
আমরা এখন পর্যন্ত যেসব CTE ব্যবহার করেছি সেগুলোর অধিকাংশই Non-Recursive CTE।
-- =========================================================
-- Non-Recursive CTE
-- CTE does NOT call itself
-- =========================================================
WITH HighValueProducts AS
(
    SELECT
        ProductID,
        ProductName,
        Price
    FROM Products
    WHERE Price > 500
)
SELECT *
FROM HighValueProducts;



Non-Recursive
CTE
 ↓
Query
নিজেকে নিজে call করে না।








21. Recursive CTE
Recursive CTE নিজেকেই reference করে।
মূল structure:
WITH CTE AS
(
    -- Anchor Query

    UNION ALL

    -- Recursive Query
)
SELECT *
FROM CTE;


Recursive CTE-এর দুই অংশ:
Anchor
Recursive Member







22. Hierarchy CTE
আমাদের Employees table-এর ManagerID ব্যবহার করি।
Employee hierarchy
-- =========================================================
-- Recursive CTE
-- Employee Hierarchy
-- =========================================================
WITH EmployeeHierarchy AS
(
    -- -----------------------------------------------------
    -- Anchor
    -- Top-level employees have ManagerID = NULL
    -- -----------------------------------------------------
    SELECT
        EmployeeID,
        EmployeeName,
        ManagerID,
        0 AS HierarchyLevel
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- -----------------------------------------------------
    -- Recursive Member
    -- Find employees under each manager
    -- -----------------------------------------------------
    SELECT
        e.EmployeeID,
        e.EmployeeName,
        e.ManagerID,
        eh.HierarchyLevel + 1

    FROM Employees e

    INNER JOIN EmployeeHierarchy eh
        ON e.ManagerID = eh.EmployeeID
)
SELECT
    EmployeeID,
    EmployeeName,
    ManagerID,
    HierarchyLevel
FROM EmployeeHierarchy
ORDER BY
    HierarchyLevel,
    EmployeeID;



Result concept
James
 ├── Robert
 └── Emma

David
 ├── Michael
 └── Sophia

Olivia
 └── Daniel

William
 └── Lucas







23. Recursive Date CTE
Date/calendar generation-এর জন্য recursive CTE ব্যবহার করা যায়।
-- =========================================================
-- Recursive Date CTE
-- Generate dates from January 1 to January 10
-- =========================================================
WITH DateSeries AS
(
    -- Anchor
    SELECT
        CAST('2026-01-01' AS DATE) AS CalendarDate

    UNION ALL

    -- Recursive Member
    SELECT
        DATEADD(DAY, 1, CalendarDate)
    FROM DateSeries
    WHERE CalendarDate < '2026-01-10'
)
SELECT
    CalendarDate
FROM DateSeries
OPTION (MAXRECURSION 100);


MAXRECURSION
SQL Server recursive CTE-এর recursion limit control করতে:
OPTION (MAXRECURSION 100);
Production calendar dimension-এর ক্ষেত্রে সাধারণত dedicated Date Dimension বেশি appropriate।







24. CTE + INSERT
CTE থেকে table-এ data insert করা যায়।
-- =========================================================
-- CTE + INSERT
-- Insert high-value products into another table
-- =========================================================
CREATE TABLE PremiumProducts
(
    ProductID INT,
    ProductName VARCHAR(100),
    Price DECIMAL(10,2)
);
-- =========================================================
-- Insert using CTE
-- =========================================================
WITH PremiumProductsCTE AS
(
    SELECT
        ProductID,
        ProductName,
        Price
    FROM Products
    WHERE Price >= 500
)
INSERT INTO PremiumProducts
(
    ProductID,
    ProductName,
    Price
)
SELECT
    ProductID,
    ProductName,
    Price
FROM PremiumProductsCTE;








25. CTE + UPDATE
CTE দিয়ে complex update করা যায়।
-- =========================================================
-- CTE + UPDATE
-- Increase price of electronics by 10%
-- =========================================================
WITH ElectronicsProducts AS
(
    SELECT
        p.ProductID,
        p.Price
    FROM Products p
    INNER JOIN Categories c
        ON p.CategoryID = c.CategoryID
    WHERE c.CategoryName = 'Electronics'
)
UPDATE ElectronicsProducts
SET Price = Price * 1.10;


⚠️ Production environment-এ update করার আগে অবশ্যই:
SELECT *
FROM Products;
দিয়ে affected rows verify করবেন।








26. CTE + DELETE
Deduplication-এর classic example:
-- =========================================================
-- CTE + DELETE
-- Delete duplicate rows
-- Keep ROW_NUMBER = 1
-- =========================================================
WITH DuplicateCustomers AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerName, Country, City
            ORDER BY CustomerID
        ) AS rn
    FROM CustomerStaging
)
DELETE FROM DuplicateCustomers
WHERE rn > 1;



Pattern
ROW_NUMBER()
     ↓
rn = 1 → Keep
rn > 1 → Delete
⚠️ DELETE করার আগে একই CTE দিয়ে SELECT করে verify করা best practice।







27. CTE + Temp Table
CTE এবং Temp Table একসাথে ব্যবহার করা যায়।
-- =========================================================
-- CTE → Temp Table
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
    FROM Orders o
    JOIN OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE o.Status = 'Completed'
    GROUP BY o.CustomerID
)
SELECT *
INTO #CustomerSales
FROM CustomerSales;




তারপর:
-- =========================================================
-- Reuse temporary result
-- =========================================================
SELECT *
FROM #CustomerSales
WHERE TotalSales > 1000;



আরও query চালানো যাবে:
SELECT
    AVG(TotalSales) AS AverageSales
FROM #CustomerSales;



মূল পার্থক্য
CTE
→ One statement-এর logical result

Temp Table
→ Session-এর মধ্যে physical temporary table







কখন কোনটি?
  
CTE
Complex SELECT
+ Logical steps
+ Window Functions
+ Recursive logic

  
Subquery
Simple one-time calculation

  
Temp Table
Large intermediate result
+ Multiple queries
+ Indexing
+ Multiple transformation stages









29. CTE in ETL / Data Transformation
Data Engineering-এ CTE খুব useful।
ধরি:
Raw Orders
     ↓
Filter
     ↓
Join
     ↓
Calculate Revenue
     ↓
Classify
     ↓
Final Dataset

  
এটি CTE দিয়ে:
-- =========================================================
-- Multi-step ETL Transformation using CTE
-- =========================================================
WITH FilteredOrders AS
(
    -- Step 1: Keep completed orders
    SELECT
        OrderID,
        CustomerID,
        OrderDate
    FROM Orders
    WHERE Status = 'Completed'
),

OrderRevenue AS
(
    -- Step 2: Calculate revenue
    SELECT
        fo.OrderID,
        fo.CustomerID,
        fo.OrderDate,

        SUM(oi.Quantity * oi.UnitPrice) AS Revenue

    FROM FilteredOrders fo

    INNER JOIN OrderItems oi
        ON fo.OrderID = oi.OrderID

    GROUP BY
        fo.OrderID,
        fo.CustomerID,
        fo.OrderDate
),

CustomerRevenue AS
(
    -- Step 3: Aggregate customer revenue
    SELECT
        CustomerID,
        SUM(Revenue) AS TotalRevenue
    FROM OrderRevenue
    GROUP BY CustomerID
),

CustomerSegment AS
(
    -- Step 4: Business classification
    SELECT
        CustomerID,
        TotalRevenue,

        CASE
            WHEN TotalRevenue >= 2000 THEN 'VIP'
            WHEN TotalRevenue >= 1000 THEN 'Regular'
            ELSE 'Low Value'
        END AS CustomerSegment

    FROM CustomerRevenue
)

-- Step 5: Final result
SELECT
    c.CustomerID,
    c.CustomerName,
    cs.TotalRevenue,
    cs.CustomerSegment

FROM Customers c

INNER JOIN CustomerSegment cs
    ON c.CustomerID = cs.CustomerID

ORDER BY
    cs.TotalRevenue DESC;

এটি একটি excellent ETL transformation pattern।








30. Real-World Multi-CTE Analytics 🔥
এখন সব concept combine করে একটি realistic analytics query তৈরি করি।
Business Requirement
Completed orders থেকে customer sales বের করতে হবে, customer rank করতে হবে, 
average sales-এর সাথে compare করতে হবে এবং VIP/Regular/Low Value segment তৈরি করতে হবে।

-- =========================================================
-- REAL-WORLD MULTI-CTE CUSTOMER ANALYTICS
-- =========================================================
WITH OrderRevenue AS
(
    -- -----------------------------------------------------
    -- CTE 1
    -- Calculate revenue for each order
    -- -----------------------------------------------------
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,

        SUM
        (
            oi.Quantity * oi.UnitPrice
        ) AS OrderRevenue

    FROM Orders o

    INNER JOIN OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.Status = 'Completed'

    GROUP BY
        o.OrderID,
        o.CustomerID,
        o.OrderDate
),

CustomerSales AS
(
    -- -----------------------------------------------------
    -- CTE 2
    -- Calculate total customer revenue
    -- -----------------------------------------------------
    SELECT
        CustomerID,

        SUM(OrderRevenue) AS TotalSales

    FROM OrderRevenue

    GROUP BY CustomerID
),

CustomerAnalytics AS
(
    -- -----------------------------------------------------
    -- CTE 3
    -- Window Functions
    -- -----------------------------------------------------
    SELECT
        CustomerID,
        TotalSales,

        ROW_NUMBER() OVER
        (
            ORDER BY TotalSales DESC
        ) AS SalesRank,

        AVG(TotalSales) OVER ()
            AS AverageCustomerSales,

        LAG(TotalSales) OVER
        (
            ORDER BY TotalSales DESC
        ) AS PreviousCustomerSales

    FROM CustomerSales
),

CustomerSegment AS
(
    -- -----------------------------------------------------
    -- CTE 4
    -- Business segmentation
    -- -----------------------------------------------------
    SELECT
        CustomerID,
        TotalSales,
        SalesRank,
        AverageCustomerSales,
        PreviousCustomerSales,

        CASE
            WHEN TotalSales >= 2000
                THEN 'VIP'

            WHEN TotalSales >= 1000
                THEN 'Regular'

            ELSE 'Low Value'
        END AS CustomerSegment

    FROM CustomerAnalytics
)

-- ---------------------------------------------------------
-- Final Report
-- ---------------------------------------------------------
SELECT
    ca.CustomerID,
    c.CustomerName,
    c.Country,
    c.City,

    ca.TotalSales,
    ca.SalesRank,
    ca.AverageCustomerSales,
    ca.PreviousCustomerSales,
    ca.CustomerSegment

FROM CustomerSegment ca

INNER JOIN Customers c
    ON ca.CustomerID = c.CustomerID

ORDER BY
    ca.SalesRank;





🧠 পুরো CTE Roadmap এক নজরে
01. CTE Fundamentals
        ↓
02. Basic CTE
        ↓
03. CTE + WHERE
        ↓
04. CTE + CASE
        ↓
05. CTE + GROUP BY
        ↓
06. CTE + HAVING
        ↓
07. CTE + JOIN
        ↓
08. Multiple CTE
        ↓
09. Chained CTE
        ↓
10. CTE + Aggregate
        ↓
11. CTE + Window Functions
        ↓
12. CTE + ROW_NUMBER
        ↓
13. CTE + RANK / DENSE_RANK
        ↓
14. CTE + LAG / LEAD
        ↓
15. CTE + Running Total
        ↓
16. CTE + Subquery
        ↓
17. CTE + IN / EXISTS
        ↓
18. CTE + Deduplication
        ↓
19. CTE + Top N per Group
        ↓
20. Non-Recursive CTE
        ↓
21. Recursive CTE
        ↓
22. Hierarchy CTE
        ↓
23. Recursive Date CTE
        ↓
24. CTE + INSERT
        ↓
25. CTE + UPDATE
        ↓
26. CTE + DELETE
        ↓
27. CTE + Temp Table
        ↓
28. CTE vs Subquery vs Temp Table
        ↓
29. CTE in ETL/Data Transformation
        ↓
30. Real-World Multi-CTE Analytics


