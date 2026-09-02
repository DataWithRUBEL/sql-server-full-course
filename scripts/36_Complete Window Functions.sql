1. OVER()
  
Window Function-এর মূল হলো:
OVER()
  
এটি SQL Server-কে বলে:
"এই calculation-টি পুরো result set-এর উপর অথবা নির্দিষ্ট window-এর উপর করো, কিন্তু original rows হারিও না।"

সাধারণ Aggregate
SELECT
    SUM(Sales) AS TotalSales
FROM Sales.Orders;

এখানে একটি row পাবেন।


-- Window Aggregate
SELECT
    OrderID,
    Sales,
    SUM(Sales) OVER() AS TotalSales
FROM Sales.Orders;


এখানে প্রতিটি order-এর সাথে TotalSales থাকবে।
মনে রাখুন
GROUP BY
→ rows collapse করে

OVER()
→ rows collapse করে না
এটাই Window Function-এর সবচেয়ে গুরুত্বপূর্ণ ধারণা।





2. PARTITION BY
/* ============================================================
   PARTITION BY
   প্রতিটি Product-এর জন্য আলাদা window তৈরি করে
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS ProductTotalSales
FROM Sales.Orders;


Concept
All Orders
   │
   ├── Product 101 → আলাদা calculation
   ├── Product 102 → আলাদা calculation
   ├── Product 103 → আলাদা calculation
   
কোথায় ব্যবহার করবেন?
        Customer-wise total
        Product-wise total
        Department-wise salary
        Country-wise sales
        Store-wise revenue





3. ORDER BY inside OVER()
/* ============================================================
   ORDER BY
   Window-এর ভিতরে row ordering নির্ধারণ করে
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS RunningSales
FROM Sales.Orders;

এটি একটি Running Total তৈরি করছে।





4. Window Function-এর মূল Syntax
FUNCTION()
OVER
(
    PARTITION BY column
    ORDER BY column
    ROWS/RANGE ...
)

  
সব অংশ সবসময় লাগবে না।
Example
SUM(Sales) OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate
)







5. 🔵 Ranking Functions
-- ROW_NUMBER()
প্রতিটি row-কে unique sequential number দেয়।
/* ============================================================
   ROW_NUMBER
   Highest Sales = 1
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesRank
FROM Sales.Orders;

Output concept
Sales    ROW_NUMBER
1200     1
1200     2
1200     3
1000     4
...
একই Sales হলেও number আলাদা।






6. RANK()
Tie হলে একই rank দেয় এবং পরের rank skip করে।
SELECT
    OrderID,
    Sales,
    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesRank
FROM Sales.Orders;


যদি:
1200 → 1
1200 → 1
1000 → 3
900  → 4





7. DENSE_RANK()
Tie হলে same rank, কিন্তু gap থাকে না।
SELECT
    OrderID,
    Sales,
    DENSE_RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesRank
FROM Sales.Orders;

Output:
1200 → 1
1200 → 1
1000 → 2
900  → 3





8. ROW_NUMBER vs RANK vs DENSE_RANK
Function	                Tie	            Gap
ROW_NUMBER	              আলাদা number	  ❌
RANK	                    Same rank	      ✅
DENSE_RANK	              Same rank	      ❌


Practical rule
      Deduplication → ROW_NUMBER()
      Competition ranking → RANK()
      Distinct ranking → DENSE_RANK()






9. PARTITION BY + ROW_NUMBER()
এটি অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   প্রতিটি Product-এর মধ্যে Sales অনুযায়ী rank
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY ProductID
        ORDER BY Sales DESC
    ) AS RankByProduct
FROM Sales.Orders;







10. Top-1 Sale per Product
/* ============================================================
   TOP 1 ORDER PER PRODUCT
   ============================================================ */
WITH RankedOrders AS
(
    SELECT
        OrderID,
        ProductID,
        Sales,
        ROW_NUMBER() OVER
        (
            PARTITION BY ProductID
            ORDER BY Sales DESC, OrderID
        ) AS rn
    FROM Sales.Orders
)
SELECT
    OrderID,
    ProductID,
    Sales
FROM RankedOrders
WHERE rn = 1;


কেন CTE?
Window Function-এর result সরাসরি একই WHERE-এ ব্যবহার করা যায় না।
  
❌ ভুল:
SELECT
    *,
    ROW_NUMBER() OVER(...) AS rn
FROM Sales.Orders
WHERE rn = 1;

✅ সঠিক:
Window Function
      ↓
CTE / Subquery
      ↓
WHERE rn = 1







11. Bottom 2 Customers
/* ============================================================
   LOWEST 2 CUSTOMERS BY TOTAL SALES
   ============================================================ */
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
),
RankedCustomers AS
(
    SELECT
        CustomerID,
        TotalSales,

        ROW_NUMBER() OVER
        (
            ORDER BY TotalSales
        ) AS rn
    FROM CustomerSales
)
SELECT *
FROM RankedCustomers
WHERE rn <= 2;






12. NTILE()
Rows-কে bucket/group-এ ভাগ করে।
/* ============================================================
   NTILE
   Orders-কে 4টি bucket-এ ভাগ করা
   ============================================================ */
SELECT
    OrderID,
    Sales,

    NTILE(4) OVER
    (
        ORDER BY Sales DESC
    ) AS SalesBucket
FROM Sales.Orders;

Practical use
      Customer segmentation
      Sales quartile
      Employee performance groups
      Risk bands
      ABC-style analysis






13. High / Medium / Low Sales
/* ============================================================
   SALES SEGMENTATION
   ============================================================ */
WITH SalesBuckets AS
(
    SELECT
        OrderID,
        Sales,

        NTILE(3) OVER
        (
            ORDER BY Sales DESC
        ) AS Bucket
    FROM Sales.Orders
)
SELECT
    OrderID,
    Sales,

    CASE
        WHEN Bucket = 1 THEN 'High'
        WHEN Bucket = 2 THEN 'Medium'
        WHEN Bucket = 3 THEN 'Low'
    END AS SalesSegment
FROM SalesBuckets;








14. CUME_DIST()
Cumulative distribution দেখায়।
/* ============================================================
   CUME_DIST
   ============================================================ */
SELECT
    Product,
    Price,

    CUME_DIST() OVER
    (
        ORDER BY Price DESC
    ) AS Distribution
FROM Sales.Products;


Result:
0.1
0.2
0.3
...
1.0

  
Percentage
SELECT
    Product,
    Price,
    CUME_DIST() OVER
    (
        ORDER BY Price DESC
    ) * 100 AS DistributionPercentage
FROM Sales.Products;





15. 🟣 Value Functions
️-- LAG()
Previous row-এর value দেখতে।
/* ============================================================
   LAG
   Previous Order Sales
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS PreviousSales
FROM Sales.Orders;

সবচেয়ে গুরুত্বপূর্ণ ব্যবহার
MoM
YoY
Previous transaction
Change detection
Customer behavior





16.LEAD()
পরের row-এর value।
/* ============================================================
   LEAD
   Next Order Date
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    LEAD(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS NextOrderDate
FROM Sales.Orders;








17. Customer Order Gap
/* ============================================================
   DAYS UNTIL NEXT ORDER
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    LEAD(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS NextOrderDate,
    DATEDIFF
    (
        DAY,
        OrderDate,
        LEAD(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        )
    ) AS DaysUntilNextOrder
FROM Sales.Orders;






18. FIRST_VALUE()
Partition-এর প্রথম value।
/* ============================================================
   FIRST_VALUE
   Product-এর lowest sale
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    FIRST_VALUE(Sales) OVER
    (
        PARTITION BY ProductID
        ORDER BY Sales
    ) AS LowestProductSale
FROM Sales.Orders;








19. LAST_VALUE()
⚠️ SQL Server-এ LAST_VALUE() ব্যবহার করার সময় window frame খুব গুরুত্বপূর্ণ।
/* ============================================================
   LAST_VALUE
   Product-এর highest sale
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    LAST_VALUE(Sales) OVER
    (
        PARTITION BY ProductID
        ORDER BY Sales
        ROWS BETWEEN CURRENT ROW
                     AND UNBOUNDED FOLLOWING
    ) AS HighestProductSale
FROM Sales.Orders;


Common mistake
অনেকে শুধু লেখেন:
LAST_VALUE(Sales) OVER
(
    PARTITION BY ProductID
    ORDER BY Sales
)
এটি অনেক সময় প্রত্যাশিত "শেষ value" দেবে না।
তাই safest pattern:
ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING









20. 🟠 Aggregate Window Functions
-- SUM() OVER()
/* ============================================================
   TOTAL SALES ON EVERY ROW
   ============================================================ */
SELECT
    OrderID,
    Sales,
    SUM(Sales) OVER() AS GrandTotalSales
FROM Sales.Orders;






21. Customer Total Sales
SELECT
    OrderID,
    CustomerID,
    Sales,
    SUM(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales
FROM Sales.Orders;








22. AVG() OVER()
/* ============================================================
   CUSTOMER AVERAGE ORDER VALUE
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    Sales,
    AVG(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS AvgCustomerOrderValue
FROM Sales.Orders;




23. MIN() OVER()
SELECT
    OrderID,
    CustomerID,
    Sales,
    MIN(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS MinimumCustomerSale
FROM Sales.Orders;





24. MAX() OVER()
SELECT
    OrderID,
    CustomerID,
    Sales,
    MAX(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS MaximumCustomerSale
FROM Sales.Orders;







25. COUNT() OVER()
/* ============================================================
   NUMBER OF ORDERS PER CUSTOMER
   ============================================================ */
SELECT
    OrderID,
    CustomerID,

    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerOrderCount
FROM Sales.Orders;





26. 🔴 Window Frames
Window Frame হলো window-এর মধ্যে কোন rows calculation-এর অংশ হবে সেটা নির্ধারণ করা।
দুইটি গুরুত্বপূর্ণ concept:
ROWS
RANGE





27. Running Total
/* ============================================================
   RUNNING TOTAL
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS RunningTotal
FROM Sales.Orders;


Meaning
First row
↓
First + Second
↓
First + Second + Third
↓
...





28. Short Syntax
অনেক ক্ষেত্রে:
SUM(Sales) OVER
(
    ORDER BY OrderDate, OrderID
)
ব্যবহার করা যায়।
কিন্তু production code-এ frame-এর intention স্পষ্ট করতে:
ROWS BETWEEN UNBOUNDED PRECEDING
         AND CURRENT ROW
লেখা বেশি explicit।




29. Moving Average
ধরুন current row + previous 2 rows = 3-row moving average।
/* ============================================================
   3-ROW MOVING AVERAGE
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    AVG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN 2 PRECEDING
                     AND CURRENT ROW
    ) AS MovingAverage3
FROM Sales.Orders;





30.Previous 3 Rows Total
SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN 3 PRECEDING
                     AND 1 PRECEDING
    ) AS Previous3RowsSales
FROM Sales.Orders;




31. Percentage of Total
এটি অত্যন্ত গুরুত্বপূর্ণ analytics pattern। ⭐⭐⭐⭐⭐
/* ============================================================
   EACH ORDER AS % OF TOTAL SALES
   ============================================================ */
SELECT
    OrderID,
    Sales,
    Sales /
    NULLIF
    (
        SUM(Sales) OVER(),
        0
    ) * 100 AS SalesPercentage
FROM Sales.Orders;






32. Product % of Total Sales
/* ============================================================
   PRODUCT CONTRIBUTION
   ============================================================ */
WITH ProductSales AS
(
    SELECT
        ProductID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY ProductID
)
SELECT
    ProductID,
    TotalSales,
    TotalSales /
    NULLIF
    (
        SUM(TotalSales) OVER(),
        0
    ) * 100 AS PercentageOfTotal
FROM ProductSales;








33. Month-over-Month — MoM
এটি real-world analytics-এর সবচেয়ে গুরুত্বপূর্ণ patternগুলোর একটি।
/* ============================================================
   MONTHLY SALES
   ============================================================ */
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(OrderDate),
            MONTH(OrderDate),
            1
        ) AS SalesMonth,

        SUM(Sales) AS TotalSales
    FROM Sales.Orders

    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
MoM AS
(
    SELECT
        SalesMonth,
        TotalSales,
        LAG(TotalSales) OVER
        (
            ORDER BY SalesMonth
        ) AS PreviousMonthSales
    FROM MonthlySales
)
SELECT
    SalesMonth,
    TotalSales,
    PreviousMonthSales,
    TotalSales - PreviousMonthSales AS MoMChange,
    ROUND
    (
        (
            TotalSales - PreviousMonthSales
        )
        /
        NULLIF(PreviousMonthSales, 0)
        * 100.0,
        2
    ) AS MoMPercentage
FROM MoM;



গুরুত্বপূর্ণ
আপনার original query-তে:
MONTH(OrderDate)
শুধু ব্যবহার করলে different years-এর same month একসাথে চলে আসতে পারে।
  
Production analytics-এ ভালো:
YEAR(OrderDate),
MONTH(OrderDate)
  
অথবা:
DATETRUNC(MONTH, OrderDate)





34. Year-over-Year — YoY
/* ============================================================
   YEARLY SALES + YOY
   ============================================================ */
WITH YearlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(Sales) AS TotalSales

    FROM Sales.Orders

    GROUP BY YEAR(OrderDate)
),
YoY AS
(
    SELECT
        SalesYear,
        TotalSales,

        LAG(TotalSales) OVER
        (
            ORDER BY SalesYear
        ) AS PreviousYearSales
    FROM YearlySales
)
SELECT
    SalesYear,
    TotalSales,
    PreviousYearSales,
    TotalSales - PreviousYearSales AS YoYChange,
    ROUND
    (
        (
            TotalSales - PreviousYearSales
        )
        /
        NULLIF(PreviousYearSales, 0)
        * 100.0,
        2
    ) AS YoYPercentage
FROM YoY;






35. Top-N per Group
ধরুন প্রতিটি Product-এর top 2 orders।
/* ============================================================
   TOP 2 ORDERS PER PRODUCT
   ============================================================ */
WITH RankedOrders AS
(
    SELECT
        OrderID,
        ProductID,
        Sales,
        ROW_NUMBER() OVER
        (
            PARTITION BY ProductID
            ORDER BY Sales DESC, OrderID
        ) AS rn
    FROM Sales.Orders
)
SELECT
    OrderID,
    ProductID,
    Sales
FROM RankedOrders
WHERE rn <= 2;







36. Customer Retention / Next Order
/* ============================================================
   CUSTOMER REPEAT ORDER ANALYSIS
   ============================================================ */
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        OrderID,
        OrderDate,
        LEAD(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS NextOrderDate
    FROM Sales.Orders
)
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    NextOrderDate,
    CASE
        WHEN NextOrderDate IS NOT NULL
            THEN 'Returning Customer'
        ELSE 'No Subsequent Order'
    END AS CustomerStatus
FROM CustomerOrders;





37. Conditional Window Aggregation
এটি অত্যন্ত useful।
/* ============================================================
   CONDITIONAL WINDOW AGGREGATION
   High-value sales total per customer
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    Sales,
    SUM
    (
        CASE
            WHEN Sales >= 1000
                THEN Sales
            ELSE 0
        END
    ) OVER
    (
        PARTITION BY CustomerID
    ) AS HighValueSales
FROM Sales.Orders;







38. 🔴 Advanced Pattern — Deduplication
Window Functions-এর সবচেয়ে practical Data Engineering use cases-এর একটি।

Duplicate Detection
/* ============================================================
   IDENTIFY DUPLICATES
   ============================================================ */
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY OrderID
        ORDER BY CreationTime DESC
    ) AS rn
FROM Sales.OrdersArchive;

যেখানে:
rn = 1 → latest record
rn > 1 → duplicate






39. Remove Duplicates from Result
/* ============================================================
   KEEP ONLY LATEST RECORD
   ============================================================ */
WITH Deduplicated AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY OrderID
            ORDER BY CreationTime DESC
        ) AS rn
    FROM Sales.OrdersArchive
)
SELECT
    OrderID,
    CustomerID,
    Sales,
    CreationTime
FROM Deduplicated
WHERE rn = 1;







40. Latest Record per Group
এটি Data Engineering-এ must know
/* ============================================================
   LATEST ORDER PER CUSTOMER
   ============================================================ */
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM Sales.Orders
)
SELECT *
FROM RankedOrders
WHERE rn = 1;






41. Change Detection
ধরুন customer-এর previous country-এর সাথে current country compare করতে হবে।
/* ============================================================
   CHANGE DETECTION USING LAG
   ============================================================ */
SELECT
    CustomerID,
    CustomerName,
    Country,
    EffectiveFrom,

    LAG(Country) OVER
    (
        PARTITION BY CustomerID
        ORDER BY EffectiveFrom
    ) AS PreviousCountry
FROM Sales.CustomerHistory;



তারপর:
WITH Changes AS
(
    SELECT
        *,
        LAG(Country) OVER
        (
            PARTITION BY CustomerID
            ORDER BY EffectiveFrom
        ) AS PreviousCountry
    FROM Sales.CustomerHistory
)
SELECT
    *,
    CASE
        WHEN PreviousCountry IS NULL
            THEN 'Initial Record'

        WHEN Country <> PreviousCountry
            THEN 'Changed'

        ELSE 'No Change'
    END AS ChangeStatus
FROM Changes;







42. SCD Type 2 — Ranking Pattern
SCD Type 2 data সাধারণত এমন:
CustomerID | Country | EffectiveFrom | EffectiveTo | IsCurrent
1          | USA     | 2024-01-01    | 2025-03-01  | 0
1          | UK      | 2025-03-02    | NULL        | 1
Latest/current record বের করতে:


/* ============================================================
   SCD TYPE 2
   FIND CURRENT RECORD
   ============================================================ */
WITH RankedHistory AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY EffectiveFrom DESC
        ) AS rn
    FROM Sales.CustomerHistory
)
SELECT *
FROM RankedHistory
WHERE rn = 1;


কেন ROW_NUMBER()?
কারণ প্রতিটি business key-এর জন্য exactly one latest record দরকার।








43. 🔴 Gaps & Islands
এটি advanced SQL-এর অত্যন্ত গুরুত্বপূর্ণ topic।
  
ধরুন customer কোন কোন date-এ order করেছে:
Jan 1
Jan 2
Jan 3
Jan 8
Jan 9
Jan 15
  
এখানে consecutive dates-এর groups:
Island 1 → Jan 1,2,3
Island 2 → Jan 8,9
Island 3 → Jan 15





44. Gaps & Islands — Basic Pattern
/* ============================================================
   GAPS & ISLANDS
   Consecutive order dates identify করা
   ============================================================ */
WITH OrderedDates AS
(
    SELECT
        CustomerID,
        OrderDate,

        LAG(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS PreviousDate
    FROM Sales.Orders
),
Marked AS
(
    SELECT
        *,
        CASE
            WHEN PreviousDate IS NULL
                THEN 1
            WHEN DATEDIFF
                 (
                     DAY,
                     PreviousDate,
                     OrderDate
                 ) > 1
                THEN 1

            ELSE 0
        END AS NewGroup

    FROM OrderedDates
),
Grouped AS
(
    SELECT
        *,
        SUM(NewGroup) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS IslandID

    FROM Marked
)
SELECT
    CustomerID,
    OrderDate,
    IslandID

FROM Grouped
ORDER BY CustomerID, OrderDate;


Patternটি মনে রাখুন
LAG()
  ↓
Gap detect
  ↓
CASE
  ↓
SUM() OVER()
  ↓
Island ID
🔥 এই pattern interview এবং real projects—দুই জায়গাতেই খুব valuable।








45. Sequence Analysis
Customer-এর order sequence:
/* ============================================================
   CUSTOMER ORDER SEQUENCE
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS OrderSequence
FROM Sales.Orders;


Output:
Customer 1 → Order 1
Customer 1 → Order 2
Customer 1 → Order 3
Customer 2 → Order 1






46. Customer First Order
/* ============================================================
   FIRST ORDER PER CUSTOMER
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    FIRST_VALUE(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS FirstOrderDate
FROM Sales.Orders;







47. Customer Lifetime Days
/* ============================================================
   CUSTOMER LIFETIME ORDER WINDOW
   ============================================================ */
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        OrderDate,

        FIRST_VALUE(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS FirstOrderDate,

        LAST_VALUE(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND UNBOUNDED FOLLOWING
        ) AS LastOrderDate
    FROM Sales.Orders
)
SELECT DISTINCT
    CustomerID,
    FirstOrderDate,
    LastOrderDate,

    DATEDIFF
    (
        DAY,
        FirstOrderDate,
        LastOrderDate
    ) AS CustomerLifetimeDays
FROM CustomerOrders;






48. PERCENT_RANK()
আপনার list-এ PERCENT_RANK()-ও আছে।
/* ============================================================
   PERCENT_RANK
   ============================================================ */
SELECT
    ProductID,
    Sales,
    PERCENT_RANK() OVER
    (
        ORDER BY Sales
    ) AS PercentRank
FROM Sales.Orders;


Formula concept:
(RANK - 1) / (TotalRows - 1)
Range:
0 → 1

  
⭐ CUME_DIST vs PERCENT_RANK
Function	           Purpose
PERCENT_RANK()	     Relative rank
CUME_DIST()	কত %    rows current value-এর নিচে/সমান distribution-এ





49. Multiple Window Functions একসাথে
বাস্তব analytics query-তে একাধিক window function একসাথে থাকবে।
/* ============================================================
   ADVANCED CUSTOMER SALES ANALYSIS
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS OrderNumber,

    SUM(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales,

    AVG(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerAvgSales,

    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS PreviousSales,

    LEAD(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS NextSales
FROM Sales.Orders;


এটি real-world customer analytics-এর খুব ভালো pattern।







50. Customer Sales Ranking
/* ============================================================
   RANK CUSTOMERS BY TOTAL SALES
   ============================================================ */
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS CustomerRank
FROM CustomerSales;





51. Top 3 Customers
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
),
RankedCustomers AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            ORDER BY TotalSales DESC
        ) AS rn
    FROM CustomerSales
)
SELECT *
FROM RankedCustomers
WHERE rn <= 3;





53. Top 3 Customers per Country
/* ============================================================
   TOP 3 CUSTOMERS PER COUNTRY
   ============================================================ */
WITH CustomerSales AS
(
    SELECT
        c.Country,
        c.CustomerID,
        c.CustomerName,
        SUM(o.Sales) AS TotalSales
    FROM Sales.Customers c

    LEFT JOIN Sales.Orders o
        ON c.CustomerID = o.CustomerID
    GROUP BY
        c.Country,
        c.CustomerID,
        c.CustomerName
),
Ranked AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY Country
            ORDER BY TotalSales DESC
        ) AS rn
    FROM CustomerSales
)
SELECT *
FROM Ranked
WHERE rn <= 3;

🔥 এটি একটি Top-N per Group problem-এর standard solution।







54. Conditional Ranking
ধরুন শুধুমাত্র high-value orders rank করতে হবে।
/* ============================================================
   CONDITIONAL WINDOW ANALYSIS
   ============================================================ */
WITH Orders AS
(
    SELECT
        *,
        CASE
            WHEN Sales >= 900
                THEN 'High'
            ELSE 'Normal'
        END AS SalesType
    FROM Sales.Orders
)
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY SalesType
        ORDER BY Sales DESC
    ) AS RankWithinSalesType
FROM Orders;






55. Window Function + CTE
Production SQL-এ এই combination খুব common।
/* ============================================================
   CTE + WINDOW FUNCTION
   ============================================================ */
WITH MonthlySales AS
(
    SELECT
        DATETRUNC(MONTH, OrderDate) AS SalesMonth,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY DATETRUNC(MONTH, OrderDate)
),
Analytics AS
(
    SELECT
        SalesMonth,
        TotalSales,

        LAG(TotalSales) OVER
        (
            ORDER BY SalesMonth
        ) AS PreviousMonth,

        SUM(TotalSales) OVER
        (
            ORDER BY SalesMonth
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS RunningSales

    FROM MonthlySales
)
SELECT *
FROM Analytics;





56. Complex Business Analysis
        একটি query-তে:
        Customer total
        Customer rank
        Previous order
        Order sequence
        Running customer sales
  
/* ============================================================
   COMPLETE CUSTOMER ORDER ANALYSIS
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS OrderSequence,

    SUM(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS CustomerRunningSales,

    SUM(Sales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerLifetimeSales,

    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS PreviousOrderSales,

    LEAD(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS NextOrderSales
FROM Sales.Orders;







57. 🔴 Query Performance & Indexing
Window Function শুধু syntax জানলেই হবে না। Production-এ performance বুঝতে হবে।

কেন Window Function Slow হতে পারে?
  
ধরুন:
ROW_NUMBER() OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate
)
  
SQL Server-কে সাধারণত data-কে এই logical order অনুযায়ী process করতে হবে:
CustomerID
     ↓
OrderDate
     ↓
Window Calculation
Millions of rows হলে sorting expensive হতে পারে।






58. Useful Index
/* ============================================================
   INDEX FOR CUSTOMER + ORDER DATE ANALYSIS
   ============================================================ */
CREATE INDEX IX_Orders_Customer_OrderDate
ON Sales.Orders
(
    CustomerID,
    OrderDate
)
INCLUDE
(
    Sales,
    ProductID
);


এটি বিশেষভাবে helpful হতে পারে:
PARTITION BY CustomerID
ORDER BY OrderDate
ধরনের queries-এর জন্য।







59. Product Ranking-এর জন্য Index
CREATE INDEX IX_Orders_Product_Sales
ON Sales.Orders
(
    ProductID,
    Sales DESC
)
INCLUDE
(
    OrderID,
    OrderDate
);


⚠️ Indexing Best Practices
        🔹 -- Index purpose: Query pattern দেখে index করুন।
        🔹 -- Avoid over-indexing: বেশি index INSERT/UPDATE/DELETE slow করতে পারে।
        🔹 -- Check execution plan: Actual Execution Plan দেখুন।
        🔹 -- Large tables: Statistics এবং index fragmentation monitor করুন।
        🔹 -- Don't guess: বাস্তব workload দিয়ে benchmark করুন।






60. 🎯 কোন Function কোন কাজের জন্য?
Ranking
ROW_NUMBER()
→ Unique sequence / Dedup / Latest record

RANK()
→ Ranking with gaps

DENSE_RANK()
→ Ranking without gaps

NTILE()
→ Bucketing / Segmentation

PERCENT_RANK()
→ Relative ranking

CUME_DIST()
→ Distribution percentage
Value Analysis
LAG()
→ Previous row

LEAD()
→ Next row

FIRST_VALUE()
→ First value

LAST_VALUE()
→ Last value
Aggregate Analytics
SUM() OVER()
→ Running / partition total

AVG() OVER()
→ Moving / partition average

MIN() OVER()
→ Minimum within window

MAX() OVER()
→ Maximum within window

COUNT() OVER()
→ Count within window






61. 🏆 Job-Ready Window Function Formula
আপনি যদি SQL Server Data Analyst/Data Engineer হিসেবে কাজ করতে চান, এই patternগুলো মুখস্থ না করে বুঝে practice করুন:

                    WINDOW FUNCTIONS
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
     Ranking             Value             Aggregate
        │                  │                  │
 ROW_NUMBER()           LAG()             SUM()
 RANK()                 LEAD()            AVG()
 DENSE_RANK()           FIRST_VALUE()     MIN()
 NTILE()                LAST_VALUE()      MAX()
 PERCENT_RANK()                           COUNT()
 CUME_DIST()
        │
        └─────────────────────────────────────────
                           │
                    Advanced Patterns
                           │
       ┌─────────────┬─────┼─────┬──────────────┐
       │             │     │     │              │
    Running        Top-N   MoM   YoY       Deduplication
     Total         Group
       │
       ├── Moving Average
       ├── % of Total
       ├── Retention
       ├── Change Detection
       ├── Gaps & Islands
       ├── Latest Record
       └── SCD Type 2





62. 🔥 Final Practice Set
এই database দিয়ে নিচের problems নিজে solve করার চেষ্টা করুন:
  
  
🟢 Beginner
প্রতিটি order-এর ROW_NUMBER() বের করুন।
Sales অনুযায়ী RANK() করুন।
RANK() এবং DENSE_RANK() compare করুন।
Customer-wise order sequence বের করুন।
Product-wise highest sale বের করুন।
Product-wise lowest sale বের করুন।
Customer-এর total sales প্রতিটি row-তে দেখান।
Customer-এর average order value দেখান।

  
🔵 Intermediate
প্রতিটি Customer-এর latest order বের করুন।
প্রতিটি Product-এর Top 2 orders বের করুন।
Customer-এর previous order sales বের করুন।
Customer-এর next order date বের করুন।
Customer-এর average days between orders বের করুন।
Running total sales বের করুন।
3-row moving average বের করুন।
প্রতিটি order-এর total sales-এর percentage বের করুন।
Monthly sales বের করুন।
Monthly MoM percentage বের করুন।

  
🔴 Advanced
Top 3 customers per country।
Duplicate orders identify করুন।
Latest duplicate record রাখুন।
Customer change detection করুন।
Customer retention analysis করুন।
Consecutive order-date islands বের করুন।
Customer-এর first এবং last order date বের করুন।
Customer lifetime period বের করুন।
SCD Type 2 current record বের করুন।
LAG() দিয়ে change detection করুন।
SUM() OVER() দিয়ে island ID তৈরি করুন।
Actual Execution Plan ব্যবহার করে window query optimize করুন।
  
