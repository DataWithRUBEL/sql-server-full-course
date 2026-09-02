01. Window Ranking Fundamentals
1–15: Concept
  
🟢 What is Window Ranking Function?
Window Ranking Function একটি result set-এর প্রতিটি row-কে তার position/rank নির্ধারণ করে।
ROW_NUMBER()
RANK()
DENSE_RANK()
NTILE()
এগুলোর বিশেষ বৈশিষ্ট্য:
Row হারায় না।



  
1. Ranking বনাম GROUP BY
GROUP BY
-- ============================================================
-- GROUP BY customer অনুযায়ী total sales বের করছে।
-- Result row কমে যাবে।
-- ============================================================
SELECT
    CustomerID,
    SUM(TotalAmount) AS TotalSales
FROM sales.Orders
GROUP BY CustomerID;



2. Ranking
-- ============================================================
-- প্রতিটি order রেখে customer-এর order ranking করছে।
-- ============================================================
SELECT
    OrderID,
    CustomerID,
    TotalAmount,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY TotalAmount DESC
    ) AS OrderRank
FROM sales.Orders;



মূল পার্থক্য
GROUP BY	Ranking
Rows collapse করে	Rows রাখে
Summary দেয়	Position দেয়
Aggregate দরকার	Window function
One row per group	Multiple rows per group


  
3. Ranking Function-এর General Syntax
-- ============================================================
-- Generic Window Ranking Syntax
-- ============================================================
RankingFunction()
OVER
(
    PARTITION BY column1, column2
    ORDER BY column3 DESC
);




OVER() কী করে?
OVER() বলে:
"কোন rows-এর উপর ranking calculation হবে?"


  
4. Entire dataset
-- ============================================================
-- পুরো Orders table-এর মধ্যে ranking।
-- ============================================================
SELECT
    OrderID,
    TotalAmount,
    RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS OverallRank
FROM sales.Orders;



5. Partition
-- ============================================================
-- প্রত্যেক Customer-এর ভিতরে আলাদাভাবে ranking।
-- ============================================================
SELECT
    CustomerID,
    OrderID,
    TotalAmount,
    RANK() OVER
    (
        PARTITION BY CustomerID
        ORDER BY TotalAmount DESC
    ) AS CustomerRank
FROM sales.Orders;




6. ASC vs DESC
-- ============================================================
-- ASC:
-- সবচেয়ে ছোট amount = Rank 1
-- ============================================================
SELECT
    OrderID,
    TotalAmount,
    RANK() OVER
    (
        ORDER BY TotalAmount ASC
    ) AS RankAscending
FROM sales.Orders;




7. -- ============================================================
-- DESC:
-- সবচেয়ে বড় amount = Rank 1
-- ============================================================
SELECT
    OrderID,
    TotalAmount,
    RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS RankDescending
FROM sales.Orders;








🟢 02. ROW_NUMBER()
16–42
ROW_NUMBER() প্রত্যেক row-কে unique sequential number দেয়।
1
2
3
4
5
...
এখানে tie হলেও একই number হবে না।


  
Basic Syntax
-- ============================================================
-- ROW_NUMBER syntax
-- ============================================================
ROW_NUMBER()
OVER
(
    ORDER BY column_name
);




1. Overall Row Number
-- ============================================================
-- Highest-value order থেকে sequential row number।
-- ============================================================
SELECT
    OrderID,
    CustomerID,
    TotalAmount,
    ROW_NUMBER() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS RowNum
FROM sales.Orders;




2. ROW_NUMBER + PARTITION BY
-- ============================================================
-- প্রতিটি Customer-এর order-কে আলাদাভাবে sequence দেওয়া।
-- ============================================================
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS CustomerOrderNumber

FROM sales.Orders;



Result concept:
Customer 101
Order 1001 → 1
Order 1006 → 2
Order 1016 → 3
Order 1021 → 4
ASC / DESC

  
3. -- ============================================================
-- Customer-এর সবচেয়ে পুরোনো order = 1
-- ============================================================
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate ASC
    ) AS FirstOrderPosition
FROM sales.Orders;






4. -- ============================================================
-- Customer-এর সবচেয়ে নতুন order = 1
-- ============================================================
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate DESC
    ) AS LatestOrderPosition

FROM sales.Orders;




⚠️ Deterministic vs Non-Deterministic
এটি খুব গুরুত্বপূর্ণ interview concept।


  
5. ❌ Risky:
-- ============================================================
-- একই OrderDate হলে কোন row আগে হবে তা guaranteed নয়।
-- ============================================================
ROW_NUMBER() OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate
)



  
✅ Better:
-- ============================================================
-- OrderDate একই হলে OrderID tie-breaker হিসেবে ব্যবহার।
-- এতে deterministic ordering পাওয়া যায়।
-- ============================================================
ROW_NUMBER() OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate, OrderID
)
Best Practice
Primary Sort
      ↓
Secondary Sort
      ↓
Unique Tie-Breaker



  
6. 🏆 Latest Record Per Customer
এটি Data Engineering-এর অত্যন্ত গুরুত্বপূর্ণ pattern।
-- ============================================================
-- প্রতিটি Customer-এর সর্বশেষ order বের করা।
-- ROW_NUMBER দিয়ে latest record = 1 করা হচ্ছে।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM RankedOrders
WHERE rn = 1;





7. Earliest Record
-- ============================================================
-- প্রতিটি Customer-এর প্রথম order বের করা।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate ASC, OrderID ASC
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM RankedOrders
WHERE rn = 1;






8. Top N Per Group
-- ============================================================
-- প্রত্যেক Customer-এর Top 2 highest-value orders।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY TotalAmount DESC, OrderID
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM RankedOrders
WHERE rn <= 2;






9. Duplicate Detection
-- ============================================================
-- একই Customer + OrderDate + Amount combination duplicate
-- কি না তা শনাক্ত করা।
-- ============================================================
WITH Duplicates AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID, OrderDate, TotalAmount
            ORDER BY OrderID
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM Duplicates
WHERE rn > 1;






10. Deduplication
-- ============================================================
-- Duplicate group থেকে latest record রেখে বাকিগুলো identify।
-- বাস্তবে DELETE করার আগে অবশ্যই SELECT দিয়ে validate করতে হবে।
-- ============================================================
WITH Duplicates AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID, OrderDate, TotalAmount
            ORDER BY OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM Duplicates
WHERE rn > 1;





11. Pagination
-- ============================================================
-- Pagination:
-- প্রতি page-এ 5টি row।
-- Example: Page 2
-- ============================================================
WITH NumberedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT
    *
FROM NumberedOrders
WHERE rn BETWEEN 6 AND 10;





12. CTE / Subquery / Temp Table
ROW_NUMBER() তিনভাবেই ব্যবহার করা যায়।
CTE
-- ============================================================
-- CTE + ROW_NUMBER
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY TotalAmount DESC
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedOrders
WHERE rn <= 3;





13. Subquery
-- ============================================================
-- Subquery + ROW_NUMBER
-- ============================================================
SELECT *
FROM
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY TotalAmount DESC
        ) AS rn
    FROM sales.Orders
) AS x
WHERE rn <= 3;






14. Temp Table
-- ============================================================
-- Temp Table-এ ranked result store করা।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY TotalAmount DESC
    ) AS rn
INTO #RankedOrders
FROM sales.Orders;



-- Ranked data verify
SELECT *
FROM #RankedOrders
WHERE rn <= 2;








🟡 03. RANK()
43–62
RANK() একই value হলে same rank দেয় এবং পরে gap তৈরি করে।
Example:
Sales
1000 → Rank 1
1000 → Rank 1
 900 → Rank 3
 800 → Rank 4
Basic Syntax
-- ============================================================
-- RANK syntax
-- ============================================================

RANK()
OVER
(
    ORDER BY column_name DESC
);





1. Sales Ranking
-- ============================================================
-- Order amount অনুযায়ী competition ranking।
-- ============================================================
SELECT
    OrderID,
    TotalAmount,

    RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS SalesRank

FROM sales.Orders;





2. Partitioned RANK
-- ============================================================
-- প্রত্যেক Branch-এর ভিতরে sales ranking।
-- ============================================================
SELECT
    BranchID,
    OrderID,
    TotalAmount,

    RANK() OVER
    (
        PARTITION BY BranchID
        ORDER BY TotalAmount DESC
    ) AS BranchRank

FROM sales.Orders;





3. Customer Revenue Ranking
প্রথমে customer-level aggregation করতে হবে।
-- ============================================================
-- Customer revenue aggregate করে তারপর ranking।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    Revenue,

    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank

FROM CustomerSales;






এখানে খুব গুরুত্বপূর্ণ pattern:
Raw Transactions
       ↓
GROUP BY
       ↓
Customer Revenue
       ↓
RANK()




  
4. Multiple ORDER BY
-- ============================================================
-- Revenue tie হলে CustomerID দিয়ে deterministic tie-break।
-- ============================================================
SELECT
    CustomerID,
    Revenue,

    RANK() OVER
    (
        ORDER BY Revenue DESC, CustomerID
    ) AS RevenueRank

FROM CustomerSales;




⚠️ এখানে একটি subtle point:
যদি CustomerID ORDER BY-তে যোগ করেন, তাহলে equal revenue-এর customer-রা আর tie করবে না।
অর্থাৎ:
ORDER BY Revenue DESC
→ ties থাকবে।
কিন্তু:
ORDER BY Revenue DESC, CustomerID
→ সাধারণত ties ভেঙে যাবে।




  
5. RANK + CASE
-- ============================================================
-- Revenue ranking-এর উপর business classification।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
RankedCustomers AS
(
    SELECT
        *,
        RANK() OVER
        (
            ORDER BY Revenue DESC
        ) AS RevenueRank
    FROM CustomerSales
)
SELECT
    *,
    CASE
        WHEN RevenueRank <= 3 THEN 'Top Customer'
        WHEN RevenueRank <= 6 THEN 'Mid Customer'
        ELSE 'Low Customer'
    END AS CustomerSegment
FROM RankedCustomers;








🟡 04. DENSE_RANK()
63–79
DENSE_RANK() ties রাখে কিন্তু gap তৈরি করে না।
Example:
1000 → 1
1000 → 1
 900 → 2
 800 → 3
Comparison
RANK()

1000 → 1
1000 → 1
 900 → 3
 800 → 4
DENSE_RANK()

1000 → 1
1000 → 1
 900 → 2
 800 → 3


  
Syntax
-- ============================================================
-- DENSE_RANK syntax
-- ============================================================

DENSE_RANK()
OVER
(
    ORDER BY column_name DESC
);





1. Product Revenue Ranking
-- ============================================================
-- Product-level revenue calculation।
-- তারপর Dense Rank।
-- ============================================================
WITH ProductSales AS
(
    SELECT
        ProductID,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    GROUP BY ProductID
)
SELECT
    ProductID,
    Revenue,

    DENSE_RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS ProductRank

FROM ProductSales;




2. Category Ranking
-- ============================================================
-- Category revenue ranking।
-- ============================================================
WITH CategorySales AS
(
    SELECT
        p.Category,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY p.Category
)
SELECT
    Category,
    Revenue,

    DENSE_RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS CategoryRank

FROM CategorySales;




3. Category + Month Ranking
-- ============================================================
-- প্রতিটি Month-এর মধ্যে Category ranking।
-- ============================================================
WITH CategoryMonthlySales AS
(
    SELECT
        YEAR(o.OrderDate) AS SalesYear,
        MONTH(o.OrderDate) AS SalesMonth,
        p.Category,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.Orders o
    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate),
        p.Category
)
SELECT
    *,
    DENSE_RANK() OVER
    (
        PARTITION BY SalesYear, SalesMonth
        ORDER BY Revenue DESC
    ) AS CategoryRank
FROM CategoryMonthlySales;









🟠 05. NTILE()
80–99
NTILE(N) rows-কে Nটি bucket/group-এ ভাগ করে।
NTILE(2) → 2 groups
NTILE(3) → 3 groups
NTILE(4) → 4 groups
NTILE(10) → 10 groups


  
Syntax
-- ============================================================
-- NTILE syntax
-- ============================================================
NTILE(number_of_buckets)
OVER
(
    ORDER BY column_name
);



1. NTILE(2)
-- ============================================================
-- Customers-কে revenue অনুযায়ী 2টি group-এ ভাগ।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    NTILE(2) OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueGroup
FROM CustomerSales;



2. NTILE(4) — Quartile
-- ============================================================
-- Revenue অনুযায়ী customer quartile।
--
-- 1 = Highest 25%
-- 2 = Upper-middle
-- 3 = Lower-middle
-- 4 = Lowest 25%
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    NTILE(4) OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueQuartile
FROM CustomerSales;





3. NTILE(10) — Decile
-- ============================================================
-- Customer revenue decile analysis।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    NTILE(10) OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueDecile
FROM CustomerSales;




⚠️ Important: NTILE(10) মানেই statistical percentile নয়। 
এটি rows-কে প্রায় সমান সংখ্যার 10টি bucket-এ ভাগ করে।


  
4. Top 25%
-- ============================================================
-- Top 25% customer identify করা।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
Segmented AS
(
    SELECT
        *,
        NTILE(4) OVER
        (
            ORDER BY Revenue DESC
        ) AS Quartile
    FROM CustomerSales
)
SELECT *
FROM Segmented
WHERE Quartile = 1;






5. Bottom 25%
-- ============================================================
-- Bottom 25% customers।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
Segmented AS
(
    SELECT
        *,
        NTILE(4) OVER
        (
            ORDER BY Revenue DESC
        ) AS Quartile
    FROM CustomerSales
)
SELECT *
FROM Segmented
WHERE Quartile = 4;






6. NTILE + CASE
-- ============================================================
-- NTILE result-কে business segment-এ convert করা।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
Segmented AS
(
    SELECT
        *,
        NTILE(4) OVER
        (
            ORDER BY Revenue DESC
        ) AS Quartile
    FROM CustomerSales
)
SELECT
    CustomerID,
    Revenue,
    Quartile,

    CASE
        WHEN Quartile = 1 THEN 'High Value'
        WHEN Quartile = 2 THEN 'Medium-High'
        WHEN Quartile = 3 THEN 'Medium-Low'
        ELSE 'Low Value'
    END AS CustomerSegment

FROM Segmented;








06. Ranking Functions Comparison
100–111
একই dataset-এর উপর চারটি একসাথে দেখুন


  
-- ============================================================
-- All four ranking functions comparison।
-- ============================================================
SELECT
    OrderID,
    TotalAmount,

    ROW_NUMBER() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS RowNumber,

    RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS RankNumber,

    DENSE_RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS DenseRankNumber,

    NTILE(4) OVER
    (
        ORDER BY TotalAmount DESC
    ) AS Quartile

FROM sales.Orders;



মনে রাখার shortcut 🧠
Function	        Tie	            Gap	          Main Use
ROW_NUMBER()	    ❌	            ❌	          Unique position
RANK()	          ✅	            ✅	          Competition ranking
DENSE_RANK()	    ✅	            ❌	          Dense competition
NTILE()	          Not tie-based	  N/A	          Segmentation



🎯 কখন কোনটি ব্যবহার করবেন?
  
ROW_NUMBER()
Latest record
First record
Deduplication
Top N without ties
Pagination


  
RANK()
Competition ranking
Sales leaderboard
Employee leaderboard
Tie-এর পরে gap দরকার


  
DENSE_RANK()
Product ranking
Category ranking
Distinct performance levels
Tie থাকবে কিন্তু gap থাকবে না


  
NTILE()
Quartile
Decile
Customer segmentation
Top 25%
Bottom 25%
Revenue buckets








07. Top-N & Bottom-N Analytics
112–134



  
1. Top 1 Overall
-- ============================================================
-- Overall highest-value order।
-- ============================================================
SELECT TOP (1)
    *
FROM sales.Orders
ORDER BY TotalAmount DESC, OrderID DESC;




2. Ranking approach:
-- ============================================================
-- ROW_NUMBER দিয়ে Top 1।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            ORDER BY TotalAmount DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedOrders
WHERE rn = 1;





3. Top 3 Customers
-- ============================================================
-- Revenue অনুযায়ী Top 3 Customers।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
RankedCustomers AS
(
    SELECT
        *,
        DENSE_RANK() OVER
        (
            ORDER BY Revenue DESC
        ) AS rnk
    FROM CustomerSales
)
SELECT *
FROM RankedCustomers
WHERE rnk <= 3;




4. Top N Products Per Category
-- ============================================================
-- প্রত্যেক Category-এর Top 2 products।
-- ============================================================
WITH ProductSales AS
(
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY
        p.Category,
        p.ProductID,
        p.ProductName
),
RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY Revenue DESC, ProductID
        ) AS rn
    FROM ProductSales
)
SELECT *
FROM RankedProducts
WHERE rn <= 2;




5. Top N Including Ties
এখানে RANK() বেশি useful।
-- ============================================================
-- Revenue tie থাকলে সব tied products রাখা।
-- ============================================================
WITH ProductSales AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY
        p.ProductID,
        p.ProductName
),
RankedProducts AS
(
    SELECT
        *,
        RANK() OVER
        (
            ORDER BY Revenue DESC
        ) AS rnk
    FROM ProductSales
)
SELECT *
FROM RankedProducts
WHERE rnk <= 3;




6. Top N Without Ties
-- ============================================================
-- Exactly Top 3 rows।
-- Ties থাকলেও 3 rows-এর বেশি হবে না।
-- ============================================================
WITH RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            ORDER BY TotalAmount DESC, OrderID
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedProducts
WHERE rn <= 3;




7. Top N Per Month
-- ============================================================
-- প্রত্যেক মাসের Top 2 orders।
-- ============================================================
WITH MonthlyOrders AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        OrderID,
        CustomerID,
        TotalAmount
    FROM sales.Orders
),
RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY SalesYear, SalesMonth
            ORDER BY TotalAmount DESC, OrderID
        ) AS rn
    FROM MonthlyOrders
)
SELECT *
FROM RankedOrders
WHERE rn <= 2;








🟣 08. Ranking + Ties Mastery
135–151
  
ধরুন:
A = 1000
B = 1000
C = 900
D = 800

  
ROW_NUMBER
A 1
B 2
C 3
D 4


  
RANK
A 1
B 1
C 3
D 4


  
DENSE_RANK
A 1
B 1
C 2
D 3


  
NTILE(4)
A → bucket 1
B → bucket 2
C → bucket 3
D → bucket 4

  
গুরুত্বপূর্ণ: NTILE() tie-aware ranking নয়।
🎯 Tie-Breaking Strategy
Industry-standard approach:
Primary Metric
      ↓
Secondary Metric
      ↓
Unique ID




  
Example:
-- ============================================================
-- Deterministic ranking strategy:
-- 1. Revenue
-- 2. Order count
-- 3. CustomerID
-- ============================================================
RANK() OVER
(
    ORDER BY
        Revenue DESC,
        OrderCount DESC,
        CustomerID
)

  
তবে আবার মনে রাখবেন—secondary/unique column যোগ করলে RANK()-এর ties ভেঙে যেতে পারে।
যদি true ties preserve করতে চান:
-- ============================================================
-- শুধুমাত্র business metric দিয়ে ranking।
-- একই Revenue হলে tie থাকবে।
-- ============================================================
RANK() OVER
(
    ORDER BY Revenue DESC
)








🟣 09. Real-World Business Ranking
152–172
এগুলো মূলত একই ranking patterns-এর business application।



  
1. -Selling Products
-- ============================================================
-- Quantity অনুযায়ী best-selling products।
-- ============================================================
WITH ProductSales AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity) AS TotalQuantity
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY
        p.ProductID,
        p.ProductName
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY TotalQuantity DESC
    ) AS SalesRank
FROM ProductSales;




2. Highest-Revenue Customer
-- ============================================================
-- Customer revenue ranking।
-- ============================================================
WITH CustomerRevenue AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank
FROM CustomerRevenue;




3. Most-Ordered Customers
-- ============================================================
-- Number of orders অনুযায়ী customer ranking।
-- ============================================================
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        COUNT(*) AS OrderCount
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    DENSE_RANK() OVER
    (
        ORDER BY OrderCount DESC
    ) AS OrderRank
FROM CustomerOrders;





4. Average Order Value Ranking
-- ============================================================
-- Customer Average Order Value ranking।
-- ============================================================
WITH CustomerMetrics AS
(
    SELECT
        CustomerID,
        COUNT(*) AS OrderCount,
        SUM(TotalAmount) AS Revenue,
        AVG(TotalAmount) AS AverageOrderValue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY AverageOrderValue DESC
    ) AS AOVRank
FROM CustomerMetrics;







🟣 10. Partitioned Ranking
173–188
এখানে PARTITION BY হলো সবচেয়ে গুরুত্বপূর্ণ বিষয়।
PARTITION BY CustomerID
মানে:
প্রত্যেক Customer-এর জন্য নতুন ranking শুরু করো।




  
1. Customer + Year
-- ============================================================
-- প্রতিটি Customer এবং Year-এর ভিতরে order ranking।
-- ============================================================
SELECT
    CustomerID,
    YEAR(OrderDate) AS SalesYear,
    OrderID,
    TotalAmount,

    ROW_NUMBER() OVER
    (
        PARTITION BY
            CustomerID,
            YEAR(OrderDate)
        ORDER BY
            TotalAmount DESC,
            OrderID
    ) AS RankInCustomerYear

FROM sales.Orders;




2. Branch + Month
-- ============================================================
-- Branch এবং Month অনুযায়ী ranking।
-- ============================================================
SELECT
    BranchID,
    YEAR(OrderDate) AS SalesYear,
    MONTH(OrderDate) AS SalesMonth,
    OrderID,
    TotalAmount,

    RANK() OVER
    (
        PARTITION BY
            BranchID,
            YEAR(OrderDate),
            MONTH(OrderDate)
        ORDER BY TotalAmount DESC
    ) AS BranchMonthRank

FROM sales.Orders;



3. Region Ranking
-- ============================================================
-- Customer Region-এর ভিতরে customer revenue ranking।
-- ============================================================
WITH CustomerRevenue AS
(
    SELECT
        c.Region,
        c.CustomerID,
        SUM(o.TotalAmount) AS Revenue
    FROM customer.Customers c
    INNER JOIN sales.Orders o
        ON c.CustomerID = o.CustomerID
    GROUP BY
        c.Region,
        c.CustomerID
)
SELECT
    *,
    RANK() OVER
    (
        PARTITION BY Region
        ORDER BY Revenue DESC
    ) AS RegionalRank
FROM CustomerRevenue;









🟠 11. Ranking + Date Analytics
189–205
Ranking functions date-based analytics-এ অত্যন্ত powerful।


1. First Order Per Customer
-- ============================================================
-- প্রতিটি Customer-এর প্রথম order।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedOrders
WHERE rn = 1;




2. Latest Order Per Customer
-- ============================================================
-- প্রতিটি Customer-এর latest order।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedOrders
WHERE rn = 1;




3. First Sale Per Month
-- ============================================================
-- প্রতিটি Month-এর প্রথম sale।
-- ============================================================
WITH RankedSales AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                YEAR(OrderDate),
                MONTH(OrderDate)
            ORDER BY OrderDate, OrderID
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedSales
WHERE rn = 1;





4. Last Sale Per Month
-- ============================================================
-- প্রতিটি Month-এর শেষ sale।
-- ============================================================
WITH RankedSales AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                YEAR(OrderDate),
                MONTH(OrderDate)
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM RankedSales
WHERE rn = 1;





5. Latest Status Per Entity
Data Engineering-এর common pattern:
-- ============================================================
-- Customer-এর latest order/status record।
-- ============================================================
WITH LatestRecord AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    OrderStatus
FROM LatestRecord
WHERE rn = 1;







🔴 12. Duplicate & Data Quality Analytics
206–220
Duplicate Business Key
ধরি:
CustomerID + OrderDate + Amount
একটি business key।
-- ============================================================
-- Business key duplicate detection।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY
            CustomerID,
            OrderDate,
            TotalAmount
        ORDER BY OrderID
    ) AS DuplicateNumber
FROM sales.Orders;





যেখানে:
-- ============================================================
-- Duplicate rows only।
-- ============================================================
WITH DQ AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY
                CustomerID,
                OrderDate,
                TotalAmount
            ORDER BY OrderID
        ) AS DuplicateNumber
    FROM sales.Orders
)
SELECT *
FROM DQ
WHERE DuplicateNumber > 1;




Duplicate Count
-- ============================================================
-- প্রতিটি business-key group-এ কতটি record আছে।
-- ============================================================

SELECT
    CustomerID,
    OrderDate,
    TotalAmount,
    COUNT(*) OVER
    (
        PARTITION BY
            CustomerID,
            OrderDate,
            TotalAmount
    ) AS DuplicateCount
FROM sales.Orders;

এটি Ranking-এর সাথে খুব useful combination:
COUNT() OVER()
+
ROW_NUMBER()








13. Advanced Ranking Patterns
221–240
এখানে ranking অন্য Window Functions-এর সাথে combine করা হবে।

1. Ranking + SUM() OVER()
-- ============================================================
-- Customer revenue + overall revenue share context।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    CustomerID,
    Revenue,

    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank,

    SUM(Revenue) OVER () AS TotalCompanyRevenue

FROM CustomerSales;





2. Ranking + AVG() OVER()
-- ============================================================
-- Customer revenue এবং average customer revenue comparison।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank,

    AVG(Revenue) OVER () AS AverageCustomerRevenue

FROM CustomerSales;






3. Ranking + COUNT() OVER()
-- ============================================================
-- Customer order ranking এবং total customer count।
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank,

    COUNT(*) OVER () AS TotalCustomers

FROM CustomerSales;





4. Ranking + LAG()
-- ============================================================
-- Customer monthly sales ranking এবং previous month sales।
-- ============================================================
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS MonthlyRank,

    LAG(Revenue) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS PreviousMonthRevenue

FROM MonthlySales;





5. Ranking + LEAD()
-- ============================================================
-- Current month বনাম next month।
-- ============================================================
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS MonthlyRank,

    LEAD(Revenue) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS NextMonthRevenue

FROM MonthlySales;



Ranking After GROUP BY
এটি খুব গুরুত্বপূর্ণ real-world pattern:
Raw Data
   ↓
JOIN
   ↓
GROUP BY
   ↓
Business Metric
   ↓
RANK()
   ↓
Filter


  
6. -- ============================================================
-- Category revenue aggregate করার পর ranking।
-- ============================================================

WITH CategorySales AS
(
    SELECT
        p.Category,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY p.Category
)
SELECT
    *,
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS CategoryRank
FROM CategorySales;



Ranking Before Filtering vs After Filtering
এটি interview-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।


  
7. Filter Before Ranking
-- ============================================================
-- শুধু Completed orders-এর মধ্যে ranking।
-- ============================================================
SELECT
    *,
    RANK() OVER
    (
        ORDER BY TotalAmount DESC
    ) AS RankNumber
FROM sales.Orders
WHERE OrderStatus = 'Completed';

এখানে ranking-এর input-ই filtered data।




  
8. Filter After Ranking
-- ============================================================
-- প্রথমে পুরো dataset rank করে তারপর rank filter।
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        *,
        RANK() OVER
        (
            ORDER BY TotalAmount DESC
        ) AS RankNumber
    FROM sales.Orders
)
SELECT *
FROM RankedOrders
WHERE RankNumber <= 5;








14. Data Engineering Use Cases
241–264
এখানে Ranking Functions-এর সবচেয়ে গুরুত্বপূর্ণ enterprise use cases।
Latest Record Per Business Key
ধরি source data:
CustomerID = 101
Load 1 → old
Load 2 → updated
Load 3 → latest


1. Pattern:
-- ============================================================
-- Latest source record নির্বাচন।
-- এটি ETL/ELT pipeline-এ common pattern।
-- ============================================================
WITH RankedSource AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY LoadDate DESC, SourceRecordID DESC
        ) AS rn
    FROM etl.CustomerStage
)
SELECT *
FROM RankedSource
WHERE rn = 1;



Source Priority Ranking
যদি একই business key একাধিক source থেকে আসে:
CRM       Priority 1
ERP       Priority 2
Website   Priority 3
তাহলে:

-- ============================================================
-- Source priority + latest timestamp ব্যবহার করে
-- authoritative record নির্বাচন।
-- ============================================================
ROW_NUMBER() OVER
(
    PARTITION BY CustomerID
    ORDER BY
        SourcePriority ASC,
        LoadDate DESC,
        SourceRecordID DESC
)
CDC-Style Latest Record
-- ============================================================
-- CDC-style source data থেকে latest version নির্বাচন।
-- ============================================================
WITH LatestVersion AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY BusinessKey
            ORDER BY
                ChangeTimestamp DESC,
                VersionNumber DESC
        ) AS rn
    FROM etl.CustomerStage
)
SELECT *
FROM LatestVersion
WHERE rn = 1;






2. Batch Ranking
-- ============================================================
-- একই batch-এর records sequence করা।
-- Data ingestion debugging-এ useful।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY BatchID
        ORDER BY LoadDate, SourceRecordID
    ) AS BatchRowNumber
FROM etl.CustomerStage;





3. Error Record Prioritization
-- ============================================================
-- Error records business priority অনুযায়ী rank।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        ORDER BY
            ErrorPriority DESC,
            LoadDate ASC,
            SourceRecordID
    ) AS ProcessingOrder
FROM etl.CustomerStage
WHERE IsValid = 0;

Warehouse Dimension Deduplication




  
4. এটি Data Engineer interview-এ খুব common:
-- ============================================================
-- Dimension table load-এর আগে duplicate business keys
-- থেকে latest record নির্বাচন।
-- ============================================================
WITH Deduplicated AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerBusinessKey
            ORDER BY
                ModifiedDate DESC,
                SourceRecordID DESC
        ) AS rn
    FROM etl.CustomerStage
)
SELECT *
FROM Deduplicated
WHERE rn = 1;








15. SQL Server Performance & Execution
265–284
Ranking Functions internally সাধারণত sorting-এর উপর নির্ভরশীল।
একটি simplified execution concept:
FROM
 ↓
JOIN
 ↓
WHERE
 ↓
GROUP BY
 ↓
Window Calculation
 ↓
ORDER BY
 ↓
SELECT Result

  
SQL Server execution plan-এ ranking-এর ক্ষেত্রে আপনি অনেক সময় দেখতে পারেন:
Index Scan / Seek
       ↓
Sort
       ↓
Segment
       ↓
Sequence Project
       ↓
Window-related operators
Sort Operator
Ranking-এর ORDER BY অনুযায়ী SQL Server-কে rows order করতে হতে পারে।




1. Example:
-- ============================================================
-- Ranking query যা sorting require করতে পারে।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY TotalAmount DESC
    ) AS rn
FROM sales.Orders;

Large table হলে Sort expensive হতে পারে।


  
2. Index Impact
যেমন:
-- ============================================================
-- Customer + OrderDate ভিত্তিক query-কে support করার জন্য
-- একটি composite index।
-- বাস্তবে workload এবং execution plan দেখে index design করতে হবে।
-- ============================================================
CREATE INDEX IX_Orders_Customer_OrderDate
ON sales.Orders
(
    CustomerID,
    OrderDate DESC
);




⚠️ শুধু ranking query দেখেই index বানাবেন না।
প্রথমে:
Actual Execution Plan
+
Logical Reads
+
CPU Time
+
Duration
+
Sort Warning
+
Memory Grant
দেখুন।
Filtering Before Ranking



  
3. যদি unnecessary rows ranking-এর আগে বাদ দেওয়া যায়:
-- ============================================================
-- Completed orders filter করার পরে ranking।
-- এতে ranking-এর input rows কমতে পারে।
-- ============================================================
SELECT
    *,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate DESC
    ) AS rn
FROM sales.Orders
WHERE OrderStatus = 'Completed';


এটি large dataset-এ গুরুত্বপূর্ণ optimization pattern হতে পারে।
Sort Spill
যদি memory যথেষ্ট না হয়, SQL Server-এর Sort operation tempdb-তে spill করতে পারে।
তাই production ranking query-তে লক্ষ্য রাখবেন:
Large Sort
   ↓
Memory Grant
   ↓
Possible Spill
   ↓
tempdb I/O
   ↓
Performance degradation









16. Master-Level Comparisons
285–302
  
1. ROW_NUMBER vs TOP
-- ============================================================
-- Overall Top 5।
-- ============================================================
SELECT TOP (5)
    *
FROM sales.Orders
ORDER BY TotalAmount DESC;



TOP simple overall Top-N-এর জন্য excellent।
কিন্তু:
Top 5 per Customer
Top 3 per Category
Top 2 per Month
এর জন্য ROW_NUMBER() অনেক বেশি flexible।


  
2. ROW_NUMBER vs TOP WITH TIES
-- ============================================================
-- Highest amount-এর সঙ্গে tied rows include করার চেষ্টা।
-- ============================================================
SELECT TOP (5) WITH TIES
    *
FROM sales.Orders
ORDER BY TotalAmount DESC;



কিন্তু TOP WITH TIES overall result-এর জন্য ভালো।
PARTITION BY-based Top-N-এর জন্য:
ROW_NUMBER()
RANK()
DENSE_RANK()
বেশি উপযোগী।


  
3. ROW_NUMBER vs OFFSET/FETCH
Pagination-এর জন্য:
-- ============================================================
-- OFFSET/FETCH pagination।
-- ============================================================
SELECT
    *
FROM sales.Orders
ORDER BY OrderDate DESC, OrderID DESC
OFFSET 5 ROWS
FETCH NEXT 5 ROWS ONLY;



কখন কোনটি?
Requirement	Preferred
Simple pagination	OFFSET/FETCH
Complex pagination/filtering	ROW_NUMBER()
Top N overall	TOP
Top N per group	ROW_NUMBER()
Include ties	RANK()


Ranking vs Self JOIN
আগে ranking-এর কাজ অনেক সময় self-join/correlated subquery দিয়ে করা হতো।
কিন্তু modern SQL Server-এ:
ROW_NUMBER()
RANK()
DENSE_RANK()
সাধারণত বেশি readable এবং maintainable।



  
  
🚀 Final Master Project 1 — E-Commerce Product Ranking
303–308
-- ============================================================
-- FINAL PROJECT:
-- E-Commerce Product Ranking
--
-- Metrics:
-- Revenue
-- Quantity
-- Profit
-- Revenue Rank
-- Quantity Rank
-- Profit Rank
-- ============================================================
WITH ProductMetrics AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        p.Category,

        SUM(oi.Quantity) AS TotalQuantity,

        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,

        SUM
        (
            oi.Quantity *
            (oi.UnitPrice - p.CostPrice)
        ) AS Profit

    FROM sales.OrderItems oi

    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID

    GROUP BY
        p.ProductID,
        p.ProductName,
        p.Category
)
SELECT
    *,
    
    RANK() OVER
    (
        ORDER BY Revenue DESC
    ) AS RevenueRank,

    RANK() OVER
    (
        ORDER BY TotalQuantity DESC
    ) AS QuantityRank,

    RANK() OVER
    (
        ORDER BY Profit DESC
    ) AS ProfitRank

FROM ProductMetrics
ORDER BY RevenueRank;





🚀 Final Master Project 2 — Top Customers by Revenue
-- ============================================================
-- FINAL PROJECT:
-- Top Customers by Revenue
--
-- Customer-level metrics:
-- Orders
-- Revenue
-- Average Order Value
-- Rank
-- ============================================================
WITH CustomerMetrics AS
(
    SELECT
        c.CustomerID,
        c.CustomerName,
        c.Region,

        COUNT(o.OrderID) AS OrderCount,

        SUM(o.TotalAmount) AS Revenue,

        AVG(o.TotalAmount) AS AverageOrderValue

    FROM customer.Customers c

    INNER JOIN sales.Orders o
        ON c.CustomerID = o.CustomerID

    GROUP BY
        c.CustomerID,
        c.CustomerName,
        c.Region
),
RankedCustomers AS
(
    SELECT
        *,

        RANK() OVER
        (
            ORDER BY Revenue DESC
        ) AS RevenueRank

    FROM CustomerMetrics
)
SELECT *
FROM RankedCustomers
WHERE RevenueRank <= 5
ORDER BY RevenueRank;





🚀 Final Master Project 3 — Top Product Per Category
-- ============================================================
-- FINAL PROJECT:
-- Best Product Per Category
--
-- ROW_NUMBER ব্যবহার করা হয়েছে কারণ
-- প্রত্যেক Category থেকে exactly 1 product চাই।
-- ============================================================
WITH ProductSales AS
(
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,
        SUM(oi.Quantity * oi.UnitPrice) AS Revenue
    FROM sales.OrderItems oi
    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID
    GROUP BY
        p.Category,
        p.ProductID,
        p.ProductName
),
RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY Revenue DESC, ProductID
        ) AS rn
    FROM ProductSales
)
SELECT
    Category,
    ProductID,
    ProductName,
    Revenue
FROM RankedProducts
WHERE rn = 1;






🚀 Final Master Project 4 — Restaurant POS Ranking
একই ranking logic restaurant POS-এ সরাসরি ব্যবহার করা যায়।
Business model:
Branch
  ↓
Orders
  ↓
Order Items
  ↓
Menu Item
  ↓
Quantity
  ↓
Revenue
  ↓
Ranking


  
উদাহরণ:
-- ============================================================
-- Restaurant POS style query:
-- Branch অনুযায়ী best-selling menu/product।
-- আমাদের Products table এখানে menu item হিসেবে ধরা হয়েছে।
-- ============================================================
WITH BranchProductSales AS
(
    SELECT
        o.BranchID,
        p.ProductID,
        p.ProductName,

        SUM(oi.Quantity) AS QuantitySold,

        SUM(oi.Quantity * oi.UnitPrice) AS Revenue

    FROM sales.Orders o

    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    INNER JOIN product.Products p
        ON oi.ProductID = p.ProductID

    GROUP BY
        o.BranchID,
        p.ProductID,
        p.ProductName
),
RankedProducts AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY BranchID
            ORDER BY Revenue DESC, ProductID
        ) AS rn
    FROM BranchProductSales
)
SELECT *
FROM RankedProducts
WHERE rn <= 3;






🚀 Final Master Project 5 — Customer Revenue Quartile
-- ============================================================
-- Customer Revenue Quartile Analysis
--
-- Q1 = highest revenue group
-- Q4 = lowest revenue group
-- ============================================================
WITH CustomerRevenue AS
(
    SELECT
        CustomerID,
        SUM(TotalAmount) AS Revenue
    FROM sales.Orders
    GROUP BY CustomerID
),
Quartiles AS
(
    SELECT
        *,
        NTILE(4) OVER
        (
            ORDER BY Revenue DESC
        ) AS RevenueQuartile
    FROM CustomerRevenue
)
SELECT
    *,
    CASE
        WHEN RevenueQuartile = 1 THEN 'High Value'
        WHEN RevenueQuartile = 2 THEN 'Upper Middle'
        WHEN RevenueQuartile = 3 THEN 'Lower Middle'
        WHEN RevenueQuartile = 4 THEN 'Low Value'
    END AS Segment
FROM Quartiles;






🚀 Final Master Project 6 — ETL Staging Deduplication
এটি Data Engineering-এর সবচেয়ে গুরুত্বপূর্ণ project pattern-গুলোর একটি।
-- ============================================================
-- Create ETL staging table
-- Purpose:
-- Multiple source records থেকে latest record নির্বাচন।
-- ============================================================
CREATE TABLE etl.CustomerStage
(
    SourceRecordID     INT,
    CustomerBusinessKey VARCHAR(50),
    CustomerName       VARCHAR(100),
    Email              VARCHAR(150),
    SourceSystem       VARCHAR(50),
    SourcePriority     INT,
    LoadDate           DATETIME2,
    IsValid             BIT
);



GO
-- ============================================================
-- Insert staging records
-- একই business key-এর multiple versions deliberately রাখা হয়েছে।
-- ============================================================
INSERT INTO etl.CustomerStage
VALUES
(1,'C001','Ahmed Ali','ahmed@email.com','CRM',1,'2026-08-01 08:00',1),
(2,'C001','Ahmed Ali','ahmed.new@email.com','CRM',1,'2026-08-02 08:00',1),
(3,'C001','Ahmed Ali','ahmed.final@email.com','ERP',2,'2026-08-03 08:00',1),

(4,'C002','Sara Khan','sara@email.com','CRM',1,'2026-08-01 09:00',1),
(5,'C002','Sara Khan','sara.updated@email.com','CRM',1,'2026-08-04 09:00',1),

(6,'C003','Omar Rahman','omar@email.com','Website',3,'2026-08-02 10:00',1);



GO
Latest record নির্বাচন
-- ============================================================
-- Latest valid record per business key।
--
-- Priority:
-- 1. SourcePriority
-- 2. Latest LoadDate
-- 3. SourceRecordID
-- ============================================================
WITH RankedSource AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerBusinessKey
            ORDER BY
                SourcePriority ASC,
                LoadDate DESC,
                SourceRecordID DESC
        ) AS rn
    FROM etl.CustomerStage
    WHERE IsValid = 1
)
SELECT *
FROM RankedSource
WHERE rn = 1;







17. সবচেয়ে গুরুত্বপূর্ণ 20টি Real-Job Patterns
SQL Server Data Analyst + Data Engineer হিসেবে এগুলো অবশ্যই mastery করবেন:
1. 🥇 ROW_NUMBER() — latest record
2. 🥇 ROW_NUMBER() — first record
3. 🥇 ROW_NUMBER() — deduplication
4. 🥇 ROW_NUMBER() — Top N per group
5. 🥇 ROW_NUMBER() — pagination
6. 🥈 RANK() — competition ranking
7. 🥈 RANK() — tied leaderboard
8. 🥈 DENSE_RANK() — dense leaderboard
9. 🥈 DENSE_RANK() — product/category ranking
10. 🟠 NTILE(4) — quartile
11. 🟠 NTILE(10) — decile
12. 🟠 Customer segmentation
13. 🔥 PARTITION BY — group-level ranking
14. 🔥 Ranking after GROUP BY
15. 🔥 Ranking aggregated metrics
16. 🔥 Ranking + CASE
17. 🔥 Ranking + LAG()
18. 🔥 Ranking + SUM() OVER()
19. 🏗️ ETL latest-record selection
20. 🏗️ ETL deduplication



  
18. Interview Master Cheat Sheet

  
Q1. ROW_NUMBER() আর RANK() পার্থক্য?
Answer:
ROW_NUMBER()
→ Every row gets unique number.

RANK()
→ Ties get same rank.
→ Gap appears after tie.




Q2. RANK() আর DENSE_RANK()?
RANK:
1, 1, 3, 4

DENSE_RANK:
1, 1, 2, 3





Q3. Latest record per customer কীভাবে করবেন?
-- ============================================================
-- Interview-standard latest-record pattern।
-- ============================================================
WITH x AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn
    FROM sales.Orders
)
SELECT *
FROM x
WHERE rn = 1;




Q4. Top 3 products per category?
-- ============================================================
-- Interview-standard Top-N-per-group pattern।
-- ============================================================
WITH x AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY Revenue DESC, ProductID
        ) AS rn
    FROM ProductSales
)
SELECT *
FROM x
WHERE rn <= 3;






Q5. Ties সহ Top 3?
-- ============================================================
-- Ties preserve করার জন্য RANK।
-- ============================================================
RANK() OVER
(
    ORDER BY Revenue DESC
)
তারপর:
WHERE RankNumber <= 3



  
Q6. Deduplication-এর জন্য কোন function?
সাধারণত ROW_NUMBER()।
PARTITION BY BusinessKey
ORDER BY ModifiedDate DESC
  
তারপর:
rn = 1 → Keep
rn > 1 → Duplicate




  
Q7. Customer-কে 4টি revenue group-এ ভাগ করতে?
-- ============================================================
-- Quartile segmentation।
-- ============================================================
NTILE(4) OVER
(
    ORDER BY Revenue DESC
)







19. Final Mental Model
সবকিছু এই চার লাইনে মনে রাখুন:

  
ROW_NUMBER()
→ কে 1st, 2nd, 3rd?


  
RANK()
→ Competition ranking + ties + gaps



  
DENSE_RANK()
→ Competition ranking + ties + no gaps



  
NTILE()
→ Rows-কে Nটি bucket-এ ভাগ


  
  
আর PARTITION BY মনে রাখবেন:
NO PARTITION
    ↓
Entire Dataset Ranking


PARTITION BY CustomerID
    ↓
Each Customer Ranking


PARTITION BY Category
    ↓
Each Category Ranking


PARTITION BY BranchID, Year, Month
    ↓
Each Branch + Year + Month Ranking


