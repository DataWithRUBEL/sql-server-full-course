1. What is Window Function?
সহজভাবে:
Window Function এমন SQL function যা একটি row-এর পাশাপাশি তার related 
অন্য rows-এর উপর calculation করে, কিন্তু original rows-গুলোকে একত্র করে ফেলবে না।

এটাই Window Function-এর সবচেয়ে গুরুত্বপূর্ণ concept।





2. Why Window Functions?
   
সাধারণ business problem
Management জিজ্ঞেস করতে পারে:
- প্রত্যেক customer-এর total sales কত?
- প্রতিটি transaction customer total-এর কত %?
- প্রতিটি store-এর sales rank কত?
- প্রতিটি customer-এর previous order কত ছিল?
- current sales পর্যন্ত cumulative sales কত?
- প্রতিটি product category-তে কোন product #1?
- current order এবং previous order-এর difference কত?

   
Traditional GROUP BY দিয়ে কিছু করা যায়।
কিন্তু সমস্যা:
GROUP BY CustomerID
করলে transaction-level rows হারিয়ে যায়।

Window Function:
SUM(NetSales) OVER(PARTITION BY CustomerID)
ব্যবহার করলে transaction rows থাকে + customer total পাওয়া যায়।






3. Window Function vs Aggregate Function
Aggregate
-- ============================================================
-- Customer-wise total sales
-- GROUP BY ব্যবহার করলে প্রতি customer-এর জন্য একটি row হবে
-- ============================================================
SELECT
    CustomerID,
    SUM(NetSales) AS TotalSales
FROM sales.Sales
GROUP BY CustomerID;


Output concept:
CustomerID | TotalSales
-----------|-----------
101        | 1260
102        | 190
103        | 1060




কিন্তু Window:
-- ============================================================
-- Customer total একই সাথে প্রতিটি transaction row-তে দেখানো
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,
    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales
FROM sales.Sales;


Output concept:
SalesID | CustomerID | NetSales | CustomerTotalSales
--------|------------|----------|------------------
1001    | 101        | 800      | 1260
1004    | 101        | 140      | 1260
1011    | 101        | 320      | 1260



মূল পার্থক্য 
   
GROUP BY	                        Window Function
Rows collapse করে	               Rows preserve করে
Aggregated result দেয়	         Row + calculation দেয়
Summary তৈরি	                  Analytical calculation
Transaction detail হারাতে পারে	   Transaction detail থাকে





4. OVER() Clause
Window Function-এর সবচেয়ে গুরুত্বপূর্ণ অংশ:
OVER()
   
Basic syntax:
FunctionName()
OVER
(
    PARTITION BY column
    ORDER BY column
);



তিনটি প্রধান অংশ:
OVER
 ├── PARTITION BY
 ├── ORDER BY
 └── Window Frame
সবসময় তিনটিই থাকতে হবে এমন নয়।



   


5. Window Concept
একটি window মানে পুরো table নয়।
বরং:
Current row-এর জন্য কোন rows-এর উপর calculation হবে—সেই logical set হলো window।

উদাহরণ:
-- ============================================================
-- Customer অনুযায়ী window তৈরি
-- প্রত্যেক customer তার নিজের rows-এর মধ্যে calculation করবে
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotal
FROM sales.Sales;


Ahmed-এর rows:
Ahmed
 ├── Sales 1001
 ├── Sales 1004
 └── Sales 1011
এটাই Ahmed-এর window।





6. PARTITION BY ⭐
PARTITION BY window-কে group-এর মতো ভাগ করে।
⚠️ কিন্তু GROUP BY-এর মতো rows collapse করে না।
   
Syntax:
Function()
OVER
(
    PARTITION BY column
);



Customer-wise total
-- ============================================================
-- প্রত্যেক customer-এর total sales বের করা
-- কিন্তু প্রতিটি transaction row রাখা
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales

FROM sales.Sales;



Store-wise total
-- ============================================================
-- প্রত্যেক store-এর total sales
-- ============================================================
SELECT
    SalesID,
    StoreID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY StoreID
    ) AS StoreTotalSales

FROM sales.Sales;



Multiple partition columns
-- ============================================================
-- Store + Product অনুযায়ী total sales
-- ============================================================
SELECT
    SalesID,
    StoreID,
    ProductID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY StoreID, ProductID
    ) AS StoreProductTotal

FROM sales.Sales;






7. ORDER BY inside OVER()
Window-এর ভিতরের ORDER BY খুব গুরুত্বপূর্ণ।
OVER
(
    ORDER BY SalesDate
)

   
এটি বলে:
Rows-গুলোকে কোন logical sequence অনুযায়ী calculate করতে হবে?


   

Running Total
-- ============================================================
-- Date অনুযায়ী cumulative / running sales
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningSales

FROM sales.Sales;

Concept:
800
800 + 50
800 + 50 + 300






8. GROUP BY vs Window Function
একই business question দুইভাবে দেখি।
GROUP BY
-- ============================================================
-- Monthly total sales
-- এখানে transaction-level rows থাকবে না
-- ============================================================
SELECT
    YEAR(SalesDate) AS SalesYear,
    MONTH(SalesDate) AS SalesMonth,
    SUM(NetSales) AS TotalSales
FROM sales.Sales
GROUP BY
    YEAR(SalesDate),
    MONTH(SalesDate);


Window Function
-- ============================================================
-- প্রতিটি transaction-এর সাথে monthly total দেখানো
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY
            YEAR(SalesDate),
            MONTH(SalesDate)
    ) AS MonthlyTotalSales

FROM sales.Sales;


Rule 🧠
Summary only → GROUP BY
Detail + Summary → Window Function






9. Row-Level Result Preservation ⭐
এটাই Window Function-এর সবচেয়ে বড় advantage।
-- ============================================================
-- প্রতিটি transaction রেখে customer total বের করা
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    CustomerID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotal

FROM sales.Sales;


GROUP BY করলে 25টি transaction থেকে customer সংখ্যার মতো কম rows হবে।
Window Function করলে:
25 transactions → 25 rows-ই থাকবে।






10. Aggregate Window Function — Concept
SQL Server-এ সবচেয়ে গুরুত্বপূর্ণ aggregate window functions:
- SUM()
- COUNT()
- AVG()
- MIN()
- MAX()


   
SUM()
-- ============================================================
-- Customer-এর প্রতিটি transaction-এর সাথে customer total
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales

FROM sales.Sales;



COUNT()
-- ============================================================
-- প্রত্যেক customer কতটি transaction করেছে
-- ============================================================
SELECT
    SalesID,
    CustomerID,

    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerOrderCount

FROM sales.Sales;



AVG()
-- ============================================================
-- Customer-এর average order value
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    AVG(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerAverageOrderValue

FROM sales.Sales;



MIN()
-- ============================================================
-- Customer-এর minimum order value
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    MIN(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerMinimumOrder

FROM sales.Sales;



MAX()
-- ============================================================
-- Customer-এর maximum order value
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    MAX(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerMaximumOrder

FROM sales.Sales;






11. Ranking Window Function — Concept 🏆
Ranking-এর জন্য SQL Server-এ গুরুত্বপূর্ণ functions:
- ROW_NUMBER()
- RANK()
- DENSE_RANK()
- NTILE()
- PERCENT_RANK()
- CUME_DIST()

   
Basic syntax:
Function()
OVER
(
    PARTITION BY ...
    ORDER BY ...
)



ROW_NUMBER()
প্রতিটি row-কে unique sequential number দেয়।
-- ============================================================
-- Highest sales থেকে transaction ranking
-- ROW_NUMBER প্রতিটি row-কে unique number দেবে
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    ROW_NUMBER() OVER
    (
        ORDER BY NetSales DESC, SalesID
    ) AS SalesRowNumber

FROM sales.Sales;



RANK()
Tie হলে একই rank দেয় এবং gap রাখে।
-- ============================================================
-- Sales value অনুযায়ী ranking
-- একই sales হলে একই rank
-- ============================================================
SELECT
    SalesID,
    NetSales,

    RANK() OVER
    (
        ORDER BY NetSales DESC
    ) AS SalesRank

FROM sales.Sales;



DENSE_RANK()
Tie হলে same rank দেয় কিন্তু gap রাখে না।
-- ============================================================
-- Dense ranking
-- ============================================================
SELECT
    SalesID,
    NetSales,

    DENSE_RANK() OVER
    (
        ORDER BY NetSales DESC
    ) AS DenseSalesRank

FROM sales.Sales;



NTILE()
Rows-কে প্রায় সমান সংখ্যক bucket-এ ভাগ করে।
-- ============================================================
-- Sales transactions-কে 4টি performance bucket-এ ভাগ করা
-- ============================================================
SELECT
    SalesID,
    NetSales,

    NTILE(4) OVER
    (
        ORDER BY NetSales DESC
    ) AS SalesQuartile

FROM sales.Sales;


Business use:
1 = Top 25%
2 = Upper-middle
3 = Lower-middle
4 = Bottom 25%





12. Value Window Function — Concept
সবচেয়ে গুরুত্বপূর্ণ value functions:
- LAG()
- LEAD()
- FIRST_VALUE()
- LAST_VALUE()
   
এগুলো খুব গুরুত্বপূর্ণ Data Analyst/Data Engineer interview topic।


   
LAG()
Previous row-এর value আনে।
-- ============================================================
-- আগের transaction-এর sales value বের করা
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    LAG(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
    ) AS PreviousSales

FROM sales.Sales;



Difference
-- ============================================================
-- Current sales বনাম previous sales difference
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    LAG(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
    ) AS PreviousSales,

    NetSales
    -
    LAG(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
    ) AS SalesDifference

FROM sales.Sales;




LEAD()
পরের row-এর value আনে।
-- ============================================================
-- পরবর্তী transaction-এর sales value
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    LEAD(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
    ) AS NextSales

FROM sales.Sales;



FIRST_VALUE()
Window-এর প্রথম value আনে।
-- ============================================================
-- প্রতিটি transaction-এর জন্য customer's first sales value
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,

    FIRST_VALUE(NetSales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
    ) AS FirstCustomerSale

FROM sales.Sales;


LAST_VALUE() ⚠️
এখানে beginners সবচেয়ে বেশি ভুল করে।
-- ============================================================
-- Customer-এর শেষ sales value
--
-- Window frame explicitly দেওয়া হয়েছে।
-- এটি LAST_VALUE-এর জন্য গুরুত্বপূর্ণ।
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,

    LAST_VALUE(NetSales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS LastCustomerSale

FROM sales.Sales;



কেন frame দরকার?
ORDER BY সহ LAST_VALUE() default frame অনেক সময় current row পর্যন্ত সীমাবদ্ধ থাকে।
   
তখন:
LAST_VALUE()
দেখতে current row-এর value-এর মতো মনে হতে পারে।
তাই full partition-এর শেষ value চাইলে:
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
খুব গুরুত্বপূর্ণ।







13. Window Frame — Introduction
Window Frame হলো:
Window-এর মধ্যে current calculation-এর জন্য ঠিক কোন rows ব্যবহার হবে।

Syntax:
ROWS BETWEEN
    start_point
    AND
    end_point

   
Common boundaries:
UNBOUNDED PRECEDING
n PRECEDING
CURRENT ROW
n FOLLOWING
UNBOUNDED FOLLOWING






14. ROWS — Introduction
ROWS physical row position-এর ভিত্তিতে frame নির্ধারণ করে।
Running Total
-- ============================================================
-- ROWS ব্যবহার করে running total
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningSales

FROM sales.Sales;



3-row moving total
-- ============================================================
-- Current row + আগের 2 rows
-- অর্থাৎ 3-row rolling total
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
    ) AS Rolling3TransactionSales

FROM sales.Sales;

Business scenario:
একজন manager শেষ 3টি transaction-এর sales trend দেখতে চান।






15. RANGE — Introduction
RANGE logical ordering value-এর ভিত্তিতে peer rows বিবেচনা করে।
SQL Server-এ একটি গুরুত্বপূর্ণ বিষয়:
SQL Server-এর RANGE frame support অন্য কিছু SQL dialect-এর তুলনায় সীমিত।

বিশেষ করে PostgreSQL-এর মতো arbitrary numeric/date interval:
RANGE BETWEEN INTERVAL ...
SQL Server-এ ব্যবহার করা যায় না।


   
Basic SQL Server example:
-- ============================================================
-- RANGE ব্যবহার করে cumulative sales
-- SQL Server-compatible basic RANGE frame
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate
        RANGE BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningSales

FROM sales.Sales;


ROWS vs RANGE
   
ROWS	                                                  RANGE
Physical row ভিত্তিক	                                   Logical ordering value ভিত্তিক
Duplicate ORDER BY values আলাদাভাবে বিবেচিত হতে পারে	  Peer values একই frame-এ আসতে পারে
Running calculation-এ খুব useful	                       Duplicate ordering values থাকলে behavior গুরুত্বপূর্ণ
SQL Server-এ বেশি practical	                          SQL Server-এ সীমিত






Best Practice ⭐
SQL Server-এ deterministic running calculations-এর জন্য সাধারণত:
ORDER BY SalesDate, SalesID
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW
এটি বেশি পরিষ্কার এবং predictable।






16. Basic Business Examples 💼
এখন আসল Data Analyst কাজ শুরু করি।

   
Business Example 1 — Customer Total Sales
-- ============================================================
-- Business Question:
-- প্রতিটি transaction-এর সাথে customer-এর lifetime sales কত?
-- ============================================================
SELECT
    S.SalesID,
    S.SalesDate,
    S.CustomerID,
    C.CustomerName,
    S.NetSales,

    SUM(S.NetSales) OVER
    (
        PARTITION BY S.CustomerID
    ) AS CustomerLifetimeSales

FROM sales.Sales AS S
INNER JOIN sales.Customers AS C
    ON S.CustomerID = C.CustomerID;



Business Example 2 — Customer Sales Percentage
-- ============================================================
-- Business Question:
-- একজন customer-এর individual transaction তার lifetime
-- sales-এর কত শতাংশ?
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotalSales,

    CAST(
        NetSales * 100.0
        /
        NULLIF(
            SUM(NetSales) OVER
            (
                PARTITION BY CustomerID
            ),
            0
        )
        AS DECIMAL(10,2)
    ) AS CustomerSalesPercentage

FROM sales.Sales;


এখানে:
NULLIF(..., 0)
division by zero prevent করতে সাহায্য করে।




Business Example 3 — Store Ranking
-- ============================================================
-- Business Question:
-- প্রতিটি store-এর মোট sales ranking কত?
-- ============================================================
WITH StoreSales AS
(
    SELECT
        StoreID,
        SUM(NetSales) AS TotalSales
    FROM sales.Sales
    GROUP BY StoreID
)
SELECT
    StoreID,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS StoreRank

FROM StoreSales;


গুরুত্বপূর্ণ
প্রথমে aggregate:
GROUP BY StoreID
   
তারপর ranking:
RANK() OVER(...)
এটি real-world SQL-এ খুব common pattern।




Business Example 4 — Customer-এর প্রতিটি Order Ranking
-- ============================================================
-- Business Question:
-- প্রত্যেক customer-এর নিজের orders-এর মধ্যে
-- কোন order সবচেয়ে বড়?
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,

    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY NetSales DESC, SalesID
    ) AS CustomerOrderRank

FROM sales.Sales;


এখানে:
PARTITION BY CustomerID
মানে প্রত্যেক customer আলাদাভাবে ranking পাবে।




Business Example 5 — Top Order Per Customer ⭐
এটি interview-এ খুব common।
-- ============================================================
-- Business Question:
-- প্রত্যেক customer-এর highest-value order বের করা
-- ============================================================
WITH RankedOrders AS
(
    SELECT
        SalesID,
        CustomerID,
        SalesDate,
        NetSales,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY NetSales DESC, SalesID
        ) AS rn

    FROM sales.Sales
)
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales
FROM RankedOrders
WHERE rn = 1;


কেন Window Function?
কারণ:
প্রত্যেক customer
       ↓
তার orders rank
       ↓
rn = 1
       ↓
highest order




Business Example 6 — Previous Customer Purchase
-- ============================================================
-- Business Question:
-- একজন customer তার আগের transaction-এ কত spend করেছিল?
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,

    LAG(NetSales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
    ) AS PreviousCustomerSale

FROM sales.Sales;



Business Example 7 — Customer Purchase Growth
-- ============================================================
-- Business Question:
-- Current order আগের order থেকে কত বেশি/কম?
-- ============================================================
WITH CustomerOrders AS
(
    SELECT
        SalesID,
        CustomerID,
        SalesDate,
        NetSales,

        LAG(NetSales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY SalesDate, SalesID
        ) AS PreviousSale

    FROM sales.Sales
)
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,
    PreviousSale,

    NetSales - PreviousSale AS SalesDifference

FROM CustomerOrders;



Business Example 8 — Running Sales
-- ============================================================
-- Business Question:
-- বছরের শুরু থেকে এখন পর্যন্ত cumulative sales কত?
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningTotalSales

FROM sales.Sales;



Business Example 9 — Customer Running Sales
-- ============================================================
-- Business Question:
-- প্রত্যেক customer-এর first purchase থেকে current purchase
-- পর্যন্ত cumulative sales কত?
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS CustomerRunningSales

FROM sales.Sales;




Business Example 10 — Monthly Sales + Transaction Detail
-- ============================================================
-- Business Question:
-- প্রতিটি transaction-এর সাথে তার মাসের total sales দেখানো
-- ============================================================
SELECT
    SalesID,
    SalesDate,
    NetSales,

    SUM(NetSales) OVER
    (
        PARTITION BY
            YEAR(SalesDate),
            MONTH(SalesDate)
    ) AS MonthlySales

FROM sales.Sales;







17. Common Mistakes ⚠️

   
❌ Mistake 1 — OVER() ভুলে যাওয়া
ভুল:
SELECT
    SUM(NetSales)
FROM sales.Sales;


এটি window function নয়।
সঠিক:
SELECT
    NetSales,
    SUM(NetSales) OVER() AS TotalSales
FROM sales.Sales;



❌ Mistake 2 — GROUP BY-এর সাথে Window Function confuse করা
GROUP BY:
GROUP BY CustomerID
rows collapse করে।
   
Window:
PARTITION BY CustomerID
rows preserve করে।


   
❌ Mistake 3 — Ranking-এ ORDER BY না দেওয়া
ভুল:
ROW_NUMBER() OVER()
SQL Server-এ ranking functions-এর জন্য ordering specification প্রয়োজন।

 
সঠিক:
ROW_NUMBER() OVER
(
    ORDER BY NetSales DESC
)


   
❌ Mistake 4 — PARTITION BY ভুল দেওয়া
যদি store ranking চান:
PARTITION BY StoreID
ব্যবহার করা উচিত কিনা business question অনুযায়ী ঠিক করতে হবে।

   
Global ranking
RANK() OVER
(
    ORDER BY NetSales DESC
)


   
Customer-wise ranking
RANK() OVER
(
    PARTITION BY CustomerID
    ORDER BY NetSales DESC
)
   
দুইটির result সম্পূর্ণ আলাদা।






18. NULL Behavior
Window Function-এ NULL behavior বুঝতে হবে।
SUM()
NULL values সাধারণত aggregate calculation-এ ignore হয়।
-- ============================================================
-- NULL NetSales থাকলেও SUM সাধারণত NULL value ignore করবে
-- ============================================================
SELECT
    SUM(NetSales) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerTotal

FROM sales.Sales;



LAG() এবং NULL
প্রথম row-এর কোনো previous row নেই।
   
তাই:
LAG(NetSales)
এর প্রথম result:
NULL


   
Example:
-- ============================================================
-- প্রথম transaction-এর previous transaction থাকবে না
-- তাই NULL পাওয়া যাবে
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    LAG(NetSales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
    ) AS PreviousSales

FROM sales.Sales;



LAG() default value
SQL Server-এ:
LAG(expression, offset, default)


   
Example:
-- ============================================================
-- Previous sales না থাকলে 0 দেখানো
-- ============================================================
SELECT
    SalesID,
    CustomerID,
    NetSales,

    LAG(NetSales, 1, 0) OVER
    (
        PARTITION BY CustomerID
        ORDER BY SalesDate, SalesID
    ) AS PreviousSales

FROM sales.Sales;






19. Execution Concept ⚙️
SQL Server query logically কীভাবে ভাবতে পারে?
একটি simplified model:
FROM
 ↓
JOIN
 ↓
WHERE
 ↓
GROUP BY
 ↓
HAVING
 ↓
Window Functions
 ↓
SELECT / ORDER BY presentation


একটি গুরুত্বপূর্ণ consequence:
একই SELECT-এর WHERE-এ সরাসরি window function ব্যবহার করা যায় না।
❌:
SELECT
    SalesID,
    ROW_NUMBER() OVER
    (
        ORDER BY NetSales DESC
    ) AS rn
FROM sales.Sales
WHERE rn = 1;

এটি কাজ করবে না।




সঠিক পদ্ধতি: CTE
-- ============================================================
-- Window result প্রথমে CTE-তে তৈরি করা
-- তারপর বাইরে filter করা
-- ============================================================
WITH RankedSales AS
(
    SELECT
        SalesID,
        CustomerID,
        NetSales,

        ROW_NUMBER() OVER
        (
            ORDER BY NetSales DESC
        ) AS rn

    FROM sales.Sales
)
SELECT
    SalesID,
    CustomerID,
    NetSales
FROM RankedSales
WHERE rn = 1;

এটি Data Analyst interview-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।





20. Interview Fundamentals 🎯
   
Q1. What is a Window Function?
Answer:
Window Function performs a calculation across a related 
set of rows while preserving the individual rows in the result set.

   
Q2. Window Function vs GROUP BY?
Answer:
GROUP BY rows collapse করে aggregated result দেয়।
Window Function rows preserve করে এবং একই সাথে analytical calculation করে।

   
Q3. PARTITION BY কী করে?
Answer:
Window-এর rows-গুলোকে logical groups/partitions-এ ভাগ করে।

   
Q4. ORDER BY inside OVER() কেন?
Answer:
Window calculation-এর logical sequence নির্ধারণ করে।

   
বিশেষ করে:
- ROW_NUMBER
- RANK
- LAG
- LEAD
- Running Total
- FIRST_VALUE
- LAST_VALUE
এর জন্য অত্যন্ত গুরুত্বপূর্ণ।

   
Q5. PARTITION BY কি GROUP BY-এর মতো?
Answer:
Conceptually grouping-এর মতো হলেও behavior আলাদা।
GROUP BY rows collapse করে।
PARTITION BY rows collapse করে না।


   
Q6. Running Total কীভাবে করবেন?
-- ============================================================
-- Standard SQL Server running total pattern
-- ============================================================
SELECT
    SalesDate,
    SalesID,
    NetSales,

    SUM(NetSales) OVER
    (
        ORDER BY SalesDate, SalesID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningTotal

FROM sales.Sales;



Q7. Previous row কীভাবে পাবেন?
-- ============================================================
-- Previous transaction value
-- ============================================================
LAG(NetSales) OVER
(
    ORDER BY SalesDate, SalesID
)

   
Q8. Next row?
-- ============================================================
-- Next transaction value
-- ============================================================
LEAD(NetSales) OVER
(
    ORDER BY SalesDate, SalesID
)


   
Q9. Top 1 record per group কীভাবে করবেন?
সবচেয়ে common pattern:
-- ============================================================
-- প্রতি customer-এর highest sales transaction
-- ============================================================
WITH RankedData AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY NetSales DESC, SalesID
        ) AS rn
    FROM sales.Sales
)
SELECT *
FROM RankedData
WHERE rn = 1;




🧠 Window Functions-এর Mental Model
এটি মনে রাখলে পুরো topic অনেক সহজ হয়ে যাবে:
                    WINDOW FUNCTION
                           │
                           ▼
                        OVER()
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
        PARTITION BY    ORDER BY    WINDOW FRAME
              │            │            │
              ▼            ▼            ▼
          কোন group?   কোন sequence?  কোন rows?



   
তারপর:
OVER()
 │
 ├── Aggregate
 │    ├── SUM
 │    ├── COUNT
 │    ├── AVG
 │    ├── MIN
 │    └── MAX
 │
 ├── Ranking
 │    ├── ROW_NUMBER
 │    ├── RANK
 │    ├── DENSE_RANK
 │    ├── NTILE
 │    ├── PERCENT_RANK
 │    └── CUME_DIST
 │
 └── Value
      ├── LAG
      ├── LEAD
      ├── FIRST_VALUE
      └── LAST_VALUE






🔥 Data Analyst + Data Engineer-এর জন্য Real-world Use Cases
   
Requirement	                      Window Function
Customer lifetime sales	          SUM() OVER()
Running revenue	                SUM() OVER(ORDER BY)
Customer average order	          AVG() OVER()
Number of orders/customer	       COUNT() OVER()
Highest order/customer	          ROW_NUMBER()
Sales ranking	                   RANK()
Ranking without gaps	             DENSE_RANK()
Top 25% customers	                NTILE(4)
Previous order	                   LAG()
Next order	                      LEAD()
First purchase	                   FIRST_VALUE()
Last purchase	                   LAST_VALUE()
Month cumulative sales	          SUM() OVER(PARTITION BY...)
Customer purchase growth	       LAG()
Rolling calculation	             ROWS BETWEEN
Deduplication	                   ROW_NUMBER()





🏗️ Data Engineering-এ Window Function কোথায় ব্যবহার করবেন?
Window Function শুধু reporting-এর জন্য নয়।
Data Engineering-এ অত্যন্ত গুরুত্বপূর্ণ:

   
1. Deduplication
-- ============================================================
-- Duplicate records-এর মধ্যে latest record নির্বাচন
-- ============================================================
WITH Deduplicated AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY JoinDate DESC
        ) AS rn
    FROM sales.Customers
)
SELECT *
FROM Deduplicated
WHERE rn = 1;



2. Latest Record
Business Key
     ↓
PARTITION BY
     ↓
ORDER BY UpdatedDate DESC
     ↓
ROW_NUMBER()
     ↓
rn = 1
এটি ETL/ELT pipeline-এ খুব common pattern।





🧪 Practice Tasks — Beginner → Advanced
🟢 Beginner
Practice 1
প্রতিটি sales transaction-এর সাথে overall total sales দেখান।
Practice 2
প্রতিটি customer-এর total sales দেখান।
Practice 3
প্রতিটি customer-এর order count দেখান।
Practice 4
প্রতিটি customer-এর average order value বের করুন।
Practice 5
প্রতিটি store-এর total sales বের করে প্রতিটি transaction-এর সাথে দেখান।


   
🟡 Intermediate
Practice 6
প্রতিটি customer-এর order ranking বের করুন।
Practice 7
প্রতিটি customer-এর highest-value order বের করুন।
Practice 8
প্রতিটি transaction-এর previous transaction বের করুন।
Practice 9
Previous এবং current sales-এর difference বের করুন।
Practice 10
Overall running sales বের করুন।
Practice 11
প্রতিটি customer-এর running sales বের করুন।
Practice 12
প্রতিটি customer-এর first purchase value বের করুন।
Practice 13
প্রতিটি customer-এর last purchase value বের করুন।


   
🔴 Advanced Practice
Practice 14
প্রতিটি store-এর মধ্যে sales ranking বের করুন।
Practice 15
প্রতিটি product category-এর মধ্যে product ranking বের করুন।
Practice 16
Top 10% sales transactions identify করুন।
Practice 17
Customer-এর previous order থেকে কতদিন পর next order হয়েছে তা বের করুন।

   
Concept:
DATEDIFF(
    DAY,
    PreviousDate,
    SalesDate
)
   
সাথে:
LAG(SalesDate)




Practice 18 — Running Percentage
প্রতিটি transaction পর্যন্ত cumulative sales / total sales বের করুন।
Concept:
Running Sales
      ÷
Total Sales
      × 100


   
Practice 19 — Top Customer per Store
প্রতিটি store-এর highest-spending customer বের করুন।
Expected pattern:
GROUP BY / aggregation
        ↓
ROW_NUMBER()
        ↓
PARTITION BY StoreID
        ↓
WHERE rn = 1



   
Practice 20 — Deduplication
একটি নতুন table তৈরি করে একই CustomerID-এর multiple records insert করুন।
তারপর:
ROW_NUMBER()
PARTITION BY CustomerID
ORDER BY UpdatedDate DESC
ব্যবহার করে latest record রাখুন।
এটি Data Engineering interview-এর must-practice problem।





SQL Server Window Function Best Practices
🔹 1. Deterministic ORDER BY
শুধু:
ORDER BY SalesDate
এর পরিবর্তে প্রয়োজন হলে:
ORDER BY SalesDate, SalesID
ব্যবহার করুন।
কারণ একই date-এ multiple rows থাকতে পারে।


   
   
🔹 2. Running Total-এ ROWS explicitly দিন
Recommended:
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW



   
   
🔹 3. LAST_VALUE সতর্কভাবে ব্যবহার করুন
LAST_VALUE() + ORDER BY হলে frame বুঝুন।
প্রয়োজনে:
ROWS BETWEEN UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING
ব্যবহার করুন।


   
   
🔹 4. Ranking-এর পরে filter করতে CTE ব্যবহার করুন
Window Function
      ↓
CTE / Derived Table
      ↓
WHERE



   
🔹 5. Performance মাথায় রাখুন
বড় table-এ Window Function-এর জন্য SQL Server-কে sorting/partitioning করতে হতে পারে।
বাস্তব production environment-এ প্রয়োজন অনুযায়ী:
- ভালো indexing
- SARGable filtering
- unnecessary columns avoid
- appropriate partition/order columns
- execution plan analysis
ব্যবহার করুন।








14. Window Functions — Introduction

1. What is Window Function
2. Why Window Functions
3. Window Function vs Aggregate Function
4. OVER() Clause
5. Window Concept
6. PARTITION BY
7. ORDER BY inside OVER()
8. GROUP BY vs Window Function
9. Row-level result preservation
10. Aggregate Window Function — Concept
11. Ranking Window Function — Concept
12. Value Window Function — Concept
13. Window Frame — Introduction
14. ROWS — Introduction
15. RANGE — Introduction
16. Basic Business Examples
17. Common Mistakes
18. NULL Behavior
19. Execution Concept
20. Interview Fundamentals

