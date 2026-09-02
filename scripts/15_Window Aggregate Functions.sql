1. Practice Database & Schema
আমরা একটি realistic E-Commerce + Retail + ETL dataset ব্যবহার করব।
Dataset-এ থাকবে
- Customers
- Products
- Categories
- Branches
- Orders
- Order Details
- Payments
- Inventory Transactions
- ETL Batch Log
    
এগুলো দিয়েই Sales, Customer, Product, Category, Branch, Inventory 
এবং Data Engineering analytics করা যাবে।





2. 🧠 প্রথমে সবচেয়ে গুরুত্বপূর্ণ Concept
Window Function-এর General Syntax
-- =========================================================
-- General Window Aggregate syntax
-- =========================================================
SELECT
    Column1,

    AGGREGATE_FUNCTION(Column2)
        OVER
        (
            PARTITION BY Column3
            ORDER BY Column4
            ROWS BETWEEN ...
        ) AS WindowResult
FROM TableName;


এখানে:
    
অংশ	         কাজ
SUM()	         কী aggregate হবে
OVER()	         Window তৈরি করে
PARTITION BY	 কোন group-এর মধ্যে calculation হবে
ORDER BY	     কোন sequence-এ calculation হবে
ROWS/RANGE	     কতগুলো row window-এর মধ্যে থাকবে







🟢 01. Window Aggregate Fundamentals
1–15: Core Concepts
GROUP BY বনাম Window Aggregate
    
-- =========================================================
-- GROUP BY:
-- প্রতিটি Customer-এর একটি করে row return করবে
-- =========================================================
SELECT
    CustomerID,
    SUM(Quantity * UnitPrice) AS TotalSales
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID
GROUP BY CustomerID;



অন্যদিকে:
-- =========================================================
-- Window Aggregate:
-- প্রতিটি transaction row রাখবে এবং customer total দেখাবে
-- =========================================================
SELECT
    o.OrderID,
    o.CustomerID,
    od.ProductID,
    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotalSales
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;



⭐ Difference
GROUP BY	                            Window
Rows collapse করে	                    Rows preserve করে
Summary report	                        Analytical report
Aggregation	                            Aggregation + detail
Ranking/Running analysis-এর জন্য নয়	Running/moving analysis-এর জন্য excellent







🟢 PARTITION BY
-- =========================================================
-- Customer-wise total sales
-- প্রতিটি customer-এর total তার প্রতিটি transaction row-তে দেখাবে
-- =========================================================
SELECT
    o.CustomerID,
    o.OrderID,
    od.ProductID,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotalSales
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;

মনে রাখবেন
PARTITION = logical group
কিন্তু GROUP BY-এর মতো row collapse করে না।






🟢 ORDER BY
-- =========================================================
-- Customer-wise running sales
-- ORDER BY ছাড়া cumulative sequence তৈরি করা যায় না
-- =========================================================
SELECT
    o.CustomerID,
    o.OrderID,
    o.OrderDate,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
            ORDER BY o.OrderDate, o.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningCustomerSales
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;







🟢 Window Frame
Window frame নির্ধারণ করে:
Current calculation-এর সময় কোন rows বিবেচনা করা হবে।

Example:
UNBOUNDED PRECEDING
        ↓
previous rows
        ↓
CURRENT ROW
        ↓
following rows
        ↓
UNBOUNDED FOLLOWING







🟢 ROWS বনাম RANGE
এটি Window Functions-এর সবচেয়ে গুরুত্বপূর্ণ বিষয়গুলোর একটি।
ROWS
Physical rows ধরে।
-- =========================================================
-- ROWS:
-- Current row এবং আগের 2 physical rows
-- =========================================================
SELECT
    OrderID,
    OrderDate,

    SUM(PaymentAmount)
        OVER
        (
            ORDER BY PaymentDate, PaymentID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS ThreeRowTotal
FROM Sales.Payments;



RANGE
Same ORDER BY value-কে peer হিসেবে বিবেচনা করতে পারে।
-- =========================================================
-- RANGE:
-- একই ORDER BY value থাকা rows একই logical range-এর মধ্যে পড়ে
-- =========================================================
SELECT
    PaymentDate,
    PaymentAmount,

    SUM(PaymentAmount)
        OVER
        (
            ORDER BY PaymentDate
            RANGE BETWEEN UNBOUNDED PRECEDING
                      AND CURRENT ROW
        ) AS RunningPayment
FROM Sales.Payments;


⭐ Best Practice
Running total-এর ক্ষেত্রে সাধারণত:
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
ব্যবহার করা safer।







🟢 02. SUM() OVER()
16–33: SUM Mastery
Grand Total
    
-- =========================================================
-- সমস্ত transaction-এর grand total
-- =========================================================
SELECT
    OrderID,
    Quantity * UnitPrice AS Sales,

    SUM(Quantity * UnitPrice)
        OVER () AS GrandTotalSales
FROM Sales.OrderDetails;




Customer Total
-- =========================================================
-- Customer-level total sales
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotal
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Running Total
-- =========================================================
-- Overall running sales
-- =========================================================
SELECT
    o.OrderID,
    o.OrderDate,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, o.OrderID, od.OrderDetailID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningSales
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;



Running Quantity
-- =========================================================
-- Running quantity
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,
    od.Quantity,

    SUM(od.Quantity)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningQuantity
FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Running Profit
-- =========================================================
-- Running profit
-- Profit = Sales - Cost
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,
    od.ProductID,

    od.Quantity * (od.UnitPrice - p.UnitCost) AS Profit,

    SUM
    (
        od.Quantity * (od.UnitPrice - p.UnitCost)
    )
    OVER
    (
        ORDER BY o.OrderDate, od.OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS RunningProfit

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID
JOIN MasterData.Products p
    ON od.ProductID = p.ProductID;





📊 Running Percentage / Contribution %
-- =========================================================
-- Sales contribution percentage
-- Current transaction sales / Grand Total Sales
-- =========================================================
SELECT
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    CAST
    (
        100.0 *
        (od.Quantity * od.UnitPrice)
        /
        NULLIF
        (
            SUM(od.Quantity * od.UnitPrice) OVER (),
            0
        )
        AS DECIMAL(10,2)
    ) AS SalesContributionPct

FROM Sales.OrderDetails od;






🟡 03. AVG() OVER()
34–51


Overall Average
-- =========================================================
-- Overall average transaction sales
-- =========================================================
SELECT
    OrderID,
    Quantity * UnitPrice AS Sales,

    AVG(Quantity * UnitPrice)
        OVER () AS OverallAverageSales
FROM Sales.OrderDetails;



Customer Average
-- =========================================================
-- Customer-wise average sales
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    AVG(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerAverageSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




📈 Running Average
-- =========================================================
-- Cumulative / Running Average Sales
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    AVG(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningAverageSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




📊 Moving Average
3-row Moving Average
-- =========================================================
-- 3-row moving average
-- Current row + previous 2 rows
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    AVG(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS MovingAverage3

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;


Formula
Current
Previous 1
Previous 2
────────────
3-row average







🟡 04. MIN() OVER()
52–62

    
-- =========================================================
-- Overall minimum sales
-- =========================================================
SELECT
    OrderID,
    Quantity * UnitPrice AS Sales,

    MIN(Quantity * UnitPrice)
        OVER () AS MinimumSales

FROM Sales.OrderDetails;




Customer Minimum
-- =========================================================
-- Minimum transaction sales per customer
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    MIN(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerMinimumSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;



Running Minimum
-- =========================================================
-- Running minimum sales
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    MIN(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningMinimum

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;






🟡 05. MAX() OVER()
63–73

    
-- =========================================================
-- Overall maximum transaction
-- =========================================================
SELECT
    OrderID,
    Quantity * UnitPrice AS Sales,

    MAX(Quantity * UnitPrice)
        OVER () AS MaximumSales

FROM Sales.OrderDetails;




Customer Maximum
-- =========================================================
-- Maximum sales per customer
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    MAX(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerMaximumSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Historical Peak
-- =========================================================
-- Running historical maximum
-- Useful for Peak Sales Analysis
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    MAX(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS HistoricalPeak

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;







🟠 06. COUNT() OVER()
74–87
    
COUNT(*)
-- =========================================================
-- Total transaction count
-- COUNT(*) সব rows গণনা করে
-- =========================================================
SELECT
    OrderID,

    COUNT(*)
        OVER () AS TotalTransactions

FROM Sales.OrderDetails;





COUNT(column)
-- =========================================================
-- COUNT(OrderID)
-- NULL OrderID হলে সেটি গণনা হবে না
-- =========================================================
SELECT
    COUNT(OrderID)
        OVER () AS NonNullOrderIDCount
FROM Sales.OrderDetails;





Customer Order Count
-- =========================================================
-- প্রতিটি customer কতটি order করেছে
-- =========================================================
SELECT
    o.CustomerID,
    o.OrderID,

    COUNT(*)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerOrderCount

FROM Sales.Orders o;





Running Count
-- =========================================================
-- Running transaction count
-- =========================================================
SELECT
    OrderDate,
    OrderID,

    COUNT(*)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningOrderCount

FROM Sales.Orders;



🧠 COUNT(*) vs COUNT(column)
    
Function	     NULL গণনা করে?
COUNT(*)	     ✅ Yes
COUNT(Column)	 ❌ No








🟠 07. Window Frame Mastery
88–103

    
Default-style running frame explicitly লেখা
-- =========================================================
-- Explicit running frame
-- Best practice:
-- Frame intent পরিষ্কারভাবে লিখুন
-- =========================================================
SELECT
    OrderDate,
    OrderID,

    SUM(1)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningCount

FROM Sales.Orders;




Previous 2 Rows
-- =========================================================
-- Current row + previous 2 rows
-- =========================================================
SELECT
    OrderID,
    OrderDate,

    SUM(1)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS ThreeRowCount

FROM Sales.Orders;



Current + Following 2 Rows
-- =========================================================
-- Current row এবং next 2 rows
-- Leading window
-- =========================================================
SELECT
    OrderID,
    OrderDate,

    SUM(1)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN CURRENT ROW AND 2 FOLLOWING
        ) AS ForwardThreeRowCount

FROM Sales.Orders;




Centered Window
-- =========================================================
-- Previous 2 + Current + Following 2
-- Centered moving window
-- =========================================================
SELECT
    OrderID,
    OrderDate,

    AVG(CAST(OrderID AS DECIMAL(18,2)))
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN 2 PRECEDING AND 2 FOLLOWING
        ) AS CenteredAverage

FROM Sales.Orders;







🔴 08. Running & Cumulative Analytics
104–119

এখানে মূল pattern:
ORDER BY Date
+
ROWS BETWEEN UNBOUNDED PRECEDING
AND CURRENT ROW

    
Running Sales
-- =========================================================
-- Running sales
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Running Orders
-- =========================================================
-- Cumulative order count
-- =========================================================
SELECT
    OrderDate,
    OrderID,

    COUNT(*)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeOrders

FROM Sales.Orders;



👤 Customer-Level Cumulative Sales
-- =========================================================
-- Customer-level running sales
-- Partition = Customer
-- Order = Order Date
-- =========================================================
SELECT
    o.CustomerID,
    o.OrderDate,
    od.OrderID,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CustomerRunningSales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;


একই pattern:
- Product-level
- Category-level
- Branch-level
শুধু PARTITION BY পরিবর্তন হবে।








🔴 09. Moving / Rolling Analytics
120–138

    
Rolling Sum
-- =========================================================
-- 3-row rolling sales
-- Current + previous 2 rows
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling3Sales

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Rolling Minimum
-- =========================================================
-- 3-row rolling minimum
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    MIN(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling3Minimum

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Rolling Maximum
-- =========================================================
-- 3-row rolling maximum
-- =========================================================
SELECT
    o.OrderDate,
    od.OrderID,

    MAX(od.Quantity * od.UnitPrice)
        OVER
        (
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling3Maximum

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Rolling Count
-- =========================================================
-- 3-row rolling count
-- =========================================================
SELECT
    OrderDate,
    OrderID,

    COUNT(*)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ) AS Rolling3Count

FROM Sales.Orders;





📅 7-Day / 30-Day Rolling Sales
এখানে একটি গুরুত্বপূর্ণ distinction আছে:
7 ROWS
≠
7 DAYS
যদি প্রতিদিন transaction না থাকে, ROWS BETWEEN 6 PRECEDING 7 calendar days বোঝাবে না।
সঠিক daily analytics-এর জন্য আগে daily aggregation/date spine তৈরি করা ভালো।


    
📅 Daily Sales → Rolling Analysis
-- =========================================================
-- Step 1:
-- প্রতিদিনের total sales তৈরি
-- =========================================================
WITH DailySales AS
(
    SELECT
        o.OrderDate,

        SUM(od.Quantity * od.UnitPrice) AS DailySales

    FROM Sales.Orders o
    JOIN Sales.OrderDetails od
        ON o.OrderID = od.OrderID

    GROUP BY
        o.OrderDate
)

-- =========================================================
-- Step 2:
-- Daily sales-এর উপর 7-row rolling average
-- =========================================================
SELECT
    OrderDate,
    DailySales,

    AVG(DailySales)
        OVER
        (
            ORDER BY OrderDate
            ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
        ) AS Rolling7DayAverage

FROM DailySales;








🟣 10. Business Analytics
139–155
এখানে Window Aggregate-এর সবচেয়ে valuable business applications আসে।


    
Sales vs Overall Total
-- =========================================================
-- Individual sales vs grand total
-- =========================================================
SELECT
    OrderID,

    Quantity * UnitPrice AS Sales,

    SUM(Quantity * UnitPrice)
        OVER () AS GrandTotal,

    100.0 *
    (Quantity * UnitPrice)
    /
    NULLIF
    (
        SUM(Quantity * UnitPrice) OVER (),
        0
    ) AS ContributionPct

FROM Sales.OrderDetails;




Sales vs Customer Total
-- =========================================================
-- Transaction sales বনাম customer total
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotal,

    100.0 *
    (od.Quantity * od.UnitPrice)
    /
    NULLIF
    (
        SUM(od.Quantity * od.UnitPrice)
        OVER (PARTITION BY o.CustomerID),
        0
    ) AS CustomerContributionPct

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;





Sales vs Product Total
-- =========================================================
-- Product-level revenue contribution
-- =========================================================
SELECT
    ProductID,
    OrderID,

    Quantity * UnitPrice AS Sales,

    SUM(Quantity * UnitPrice)
        OVER
        (
            PARTITION BY ProductID
        ) AS ProductTotal,

    100.0 *
    (Quantity * UnitPrice)
    /
    NULLIF
    (
        SUM(Quantity * UnitPrice)
        OVER (PARTITION BY ProductID),
        0
    ) AS ProductContributionPct

FROM Sales.OrderDetails;




Current Sales vs Running Average
-- =========================================================
-- Current transaction sales বনাম historical running average
-- =========================================================
WITH SalesData AS
(
    SELECT
        o.OrderDate,
        od.OrderID,
        od.Quantity * od.UnitPrice AS Sales
    FROM Sales.OrderDetails od
    JOIN Sales.Orders o
        ON od.OrderID = o.OrderID
)
SELECT
    OrderDate,
    OrderID,
    Sales,

    AVG(Sales)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningAverage,

    Sales -
    AVG(Sales)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS DifferenceFromRunningAverage

FROM SalesData;




Historical Maximum / Minimum
-- =========================================================
-- Current sales বনাম historical maximum/minimum
-- =========================================================
WITH SalesData AS
(
    SELECT
        o.OrderDate,
        od.OrderID,
        od.Quantity * od.UnitPrice AS Sales
    FROM Sales.OrderDetails od
    JOIN Sales.Orders o
        ON od.OrderID = o.OrderID
)
SELECT
    OrderDate,
    OrderID,
    Sales,

    MAX(Sales)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS HistoricalMax,

    MIN(Sales)
        OVER
        (
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS HistoricalMin

FROM SalesData;









🟣 11. Advanced Window Aggregate Patterns
156–171


    
একই query-তে multiple Window Aggregates ব্যবহার করা যায়।
-- =========================================================
-- Multiple Window Aggregates
-- SUM + AVG + MIN + MAX + COUNT
-- =========================================================
SELECT
    o.CustomerID,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotalSales,

    AVG(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerAverageSales,

    MIN(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerMinimumSales,

    MAX(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerMaximumSales,

    COUNT(*)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTransactionCount

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Grand Total + Partition Total + Running Total
এটি interview এবং real project—দুই জায়গাতেই অত্যন্ত গুরুত্বপূর্ণ।
-- =========================================================
-- তিন ধরনের metric একসাথে:
-- 1. Grand Total
-- 2. Customer Total
-- 3. Customer Running Total
-- =========================================================
SELECT
    o.CustomerID,
    o.OrderDate,
    od.OrderID,

    od.Quantity * od.UnitPrice AS Sales,

    -- Grand Total
    SUM(od.Quantity * od.UnitPrice)
        OVER () AS GrandTotal,

    -- Customer Partition Total
    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotal,

    -- Customer Running Total
    SUM(od.Quantity * od.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
            ORDER BY o.OrderDate, od.OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CustomerRunningTotal

FROM Sales.OrderDetails od
JOIN Sales.Orders o
    ON od.OrderID = o.OrderID;




Window Aggregate + CASE
-- =========================================================
-- Customer sales total অনুযায়ী customer classification
-- =========================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        od.Quantity * od.UnitPrice AS Sales,

        SUM(od.Quantity * od.UnitPrice)
            OVER
            (
                PARTITION BY o.CustomerID
            ) AS CustomerTotalSales

    FROM Sales.OrderDetails od
    JOIN Sales.Orders o
        ON od.OrderID = o.OrderID
)
SELECT
    CustomerID,
    Sales,
    CustomerTotalSales,

    CASE
        WHEN CustomerTotalSales >= 1000
            THEN 'High Value'
        WHEN CustomerTotalSales >= 500
            THEN 'Medium Value'
        ELSE 'Low Value'
    END AS CustomerValueSegment

FROM CustomerSales;





Window Aggregate + NULLIF
Percentage calculation-এ division by zero prevent করতে:
-- =========================================================
-- NULLIF ব্যবহার করে safe percentage calculation
-- =========================================================
SELECT
    OrderID,

    Quantity * UnitPrice AS Sales,

    100.0 * (Quantity * UnitPrice)
    /
    NULLIF
    (
        SUM(Quantity * UnitPrice) OVER (),
        0
    ) AS ContributionPct

FROM Sales.OrderDetails;





Window Aggregate + CTE
-- =========================================================
-- CTE দিয়ে প্রথমে daily sales তৈরি
-- তারপর Window Aggregate
-- =========================================================
WITH DailySales AS
(
    SELECT
        o.OrderDate,
        SUM(od.Quantity * od.UnitPrice) AS DailySales

    FROM Sales.Orders o
    JOIN Sales.OrderDetails od
        ON o.OrderID = od.OrderID

    GROUP BY
        o.OrderDate
)
SELECT
    OrderDate,
    DailySales,

    SUM(DailySales)
        OVER
        (
            ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningSales

FROM DailySales;





Window Aggregate + Temp Table
-- =========================================================
-- Temporary table
-- Intermediate daily sales dataset
-- =========================================================
DROP TABLE IF EXISTS #DailySales;

SELECT
    o.OrderDate,
    SUM(od.Quantity * od.UnitPrice) AS DailySales
INTO #DailySales
FROM Sales.Orders o
JOIN Sales.OrderDetails od
    ON o.OrderID = od.OrderID
GROUP BY o.OrderDate;


-- =========================================================
-- Window Aggregate on temporary table
-- =========================================================
SELECT
    OrderDate,
    DailySales,

    SUM(DailySales)
        OVER
        (
            ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningSales

FROM #DailySales;







12. Real-World Data Analyst Patterns
172–194
    
এই section-টি production analytics-এর জন্য সবচেয়ে গুরুত্বপূর্ণ।

    
Pattern Map
Requirement	                  Window Pattern
Daily Running Sales	          SUM() OVER(ORDER BY Date)
Monthly Running Sales	      SUM() OVER(PARTITION BY Year, Month ORDER BY Date)
Yearly Running Sales	      SUM() OVER(PARTITION BY Year ORDER BY Date)
Customer Lifetime Sales	      SUM() OVER(PARTITION BY CustomerID)
Customer Running Spend	      SUM() OVER(PARTITION BY CustomerID ORDER BY Date)
Product Running Sales	      SUM() OVER(PARTITION BY ProductID ORDER BY Date)
Category Running Sales	      SUM() OVER(PARTITION BY CategoryID ORDER BY Date)
Branch Running Sales	      SUM() OVER(PARTITION BY BranchID ORDER BY Date)
Moving Average	              AVG() OVER(... ROWS BETWEEN...)
Running Quantity	          SUM(Quantity) OVER(...)
Running Profit	              SUM(Profit) OVER(...)
Contribution %	              Value / SUM(Value) OVER()
Target Progress	              RunningSales / Target
Inventory Balance	          SUM(TransactionQty) OVER(PARTITION BY Product)
Payment Balance	              SUM(Payment) OVER(ORDER BY PaymentDate)



    
📅 Month-to-Date Sales
-- =========================================================
-- Month-to-Date Sales
-- প্রতিটি month নতুন করে running total শুরু করবে
-- =========================================================
WITH SalesData AS
(
    SELECT
        o.OrderDate,
        od.OrderID,
        od.Quantity * od.UnitPrice AS Sales
    FROM Sales.Orders o
    JOIN Sales.OrderDetails od
        ON o.OrderID = od.OrderID
)
SELECT
    OrderDate,
    OrderID,
    Sales,

    SUM(Sales)
        OVER
        (
            PARTITION BY
                YEAR(OrderDate),
                MONTH(OrderDate)
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS MTD_Sales

FROM SalesData;




📅 Year-to-Date Sales
-- =========================================================
-- Year-to-Date Sales
-- =========================================================
WITH SalesData AS
(
    SELECT
        o.OrderDate,
        od.OrderID,
        od.Quantity * od.UnitPrice AS Sales
    FROM Sales.Orders o
    JOIN Sales.OrderDetails od
        ON o.OrderID = od.OrderID
)
SELECT
    OrderDate,
    OrderID,
    Sales,

    SUM(Sales)
        OVER
        (
            PARTITION BY YEAR(OrderDate)
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS YTD_Sales

FROM SalesData;




📦 Inventory Running Balance
-- =========================================================
-- Inventory running balance
-- Purchase = positive
-- Sale = negative
-- =========================================================
SELECT
    ProductID,
    TransactionDate,
    TransactionID,
    TransactionType,
    Quantity,

    SUM(Quantity)
        OVER
        (
            PARTITION BY ProductID
            ORDER BY TransactionDate, TransactionID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningInventoryBalance

FROM Inventory.StockTransactions;




💳 Payment Running Balance
-- =========================================================
-- Payment running balance
-- =========================================================
SELECT
    PaymentDate,
    PaymentID,
    PaymentAmount,

    SUM(PaymentAmount)
        OVER
        (
            ORDER BY PaymentDate, PaymentID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningPaymentBalance

FROM Sales.Payments
WHERE PaymentStatus = 'Paid';








13. Data Engineering Use Cases
195–210


    
Window Aggregate শুধু BI/Sales-এর জন্য নয়।
ETL monitoring-এও অত্যন্ত useful।

ETL Running Record Count
-- =========================================================
-- Cumulative ETL records processed
-- =========================================================
SELECT
    BatchID,
    SourceSystem,
    LoadDate,
    TotalRecords,

    SUM(TotalRecords)
        OVER
        (
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeRecords

FROM ETL.BatchLog;



Partition by Source System
-- =========================================================
-- Source-system-wise cumulative records
-- =========================================================
SELECT
    BatchID,
    SourceSystem,
    LoadDate,
    TotalRecords,

    SUM(TotalRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS SourceCumulativeRecords

FROM ETL.BatchLog;





Running Errors
-- =========================================================
-- Running ETL errors
-- =========================================================
SELECT
    BatchID,
    SourceSystem,
    LoadDate,
    FailedRecords,

    SUM(FailedRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningErrors

FROM ETL.BatchLog;





Running Successful Records
-- =========================================================
-- Running successful records
-- =========================================================
SELECT
    BatchID,
    SourceSystem,
    LoadDate,
    SuccessfulRecords,

    SUM(SuccessfulRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningSuccessfulRecords

FROM ETL.BatchLog;






ETL Success Rate
-- =========================================================
-- ETL cumulative success percentage
-- =========================================================
SELECT
    BatchID,
    SourceSystem,

    TotalRecords,
    SuccessfulRecords,
    FailedRecords,

    100.0 *
    SUM(SuccessfulRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )
    /
    NULLIF
    (
        SUM(TotalRecords)
            OVER
            (
                PARTITION BY SourceSystem
                ORDER BY LoadDate, BatchID
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ),
        0
    ) AS CumulativeSuccessRate

FROM ETL.BatchLog;




Duplicate Analysis
একটি important real-world pattern:
-- =========================================================
-- Duplicate detection using COUNT() OVER()
-- =========================================================
SELECT
    CustomerID,
    CustomerName,
    City,

    COUNT(*)
        OVER
        (
            PARTITION BY CustomerID
        ) AS CustomerIDCount

FROM MasterData.Customers;





যদি:
CustomerIDCount > 1
তাহলে duplicate candidate।


    
NULL Analysis
-- =========================================================
-- NULL analysis
-- COUNT(Column) NULL বাদ দেয়
-- COUNT(*) সব row গণনা করে
-- =========================================================
SELECT
    COUNT(*) OVER () AS TotalRows,

    COUNT(Gender) OVER () AS NonNullGenderRows,

    COUNT(*) OVER ()
    -
    COUNT(Gender) OVER () AS NullGenderRows

FROM MasterData.Customers;







🔬 Source-to-Target Reconciliation
-- =========================================================
-- Source vs Target reconciliation concept
-- Running source/target counts compare করা
-- =========================================================
SELECT
    BatchID,
    SourceSystem,

    SUM(TotalRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS SourceCumulativeRecords,

    SUM(SuccessfulRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS TargetCumulativeRecords

FROM ETL.BatchLog;









14. Advanced SQL Server Concepts
211–225

    
এখন SQL syntax থেকে SQL Server engine-এর দিকে যাই।
Logical Concept
    
একটি simplified query flow:
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
SELECT
 ↓
WINDOW FUNCTIONS
 ↓
ORDER BY
 
Window functions logically SELECT phase-এর কাছাকাছি কাজ করে।

    
Execution Plan
Window Aggregate query চালালে SQL Server execution plan-এ বিভিন্ন operator দেখতে পারেন:
- Sort
- Segment
- Sequence Project
- Window Spool
- Stream Aggregate
- Window Aggregate
    
বিশেষ করে complex window expressions-এ Sort performance গুরুত্বপূর্ণ।
Sort কেন expensive?


    
এই query:
-- =========================================================
-- ORDER BY-এর কারণে SQL Server-কে ordered rows প্রয়োজন
-- =========================================================
SELECT
    OrderDate,
    OrderID,

    SUM(1)
        OVER
        (
            ORDER BY OrderDate, OrderID
        ) AS RunningCount

FROM Sales.Orders;



SQL Server-কে OrderDate, OrderID অনুযায়ী data order করতে হতে পারে।
Large table হলে:
Large Data
   ↓
Sort
   ↓
Memory Requirement
   ↓
Possible TempDB Spill
   ↓
Performance degradation
Index Impact


যদি frequently এই ধরনের query চালান:
-- =========================================================
-- Customer + Date ভিত্তিক window analytics-এর জন্য
-- supporting index
-- =========================================================
CREATE INDEX IX_Orders_Customer_OrderDate
ON Sales.Orders
(
    CustomerID,
    OrderDate,
    OrderID
);





তবে optimizer কিছু ক্ষেত্রে existing ordering কাজে লাগাতে পারে।
⚠️ তবে index শুধু window function-এর জন্য blindly তৈরি করা উচিত নয়।
    
Consider:
- Read frequency
- Write overhead
- Existing indexes
- Query plan
- Table size
- Selectivity
Memory Grant এবং TempDB Spill


    
Large window queries-এর ক্ষেত্রে:
Sort
 ↓
Memory Grant
 ↓
Memory যথেষ্ট?
 ├── Yes → In-memory execution
 └── No
      ↓
   TempDB Spill
      ↓
   Slower Query
Execution Plan-এ warning থাকলে investigate করুন।
Batch Mode বনাম Row Mode
Modern SQL Server workloads-এ analytical queries-এর ক্ষেত্রে 
Batch Mode performance dramatically improve করতে পারে—বিশেষ করে large analytical datasets-এ।
তবে এটি automatically সব query-তে হবে এমন নয়।
Execution plan দেখে verify করতে হবে।





🧠 Performance Best Practices
✅ 1. Deterministic ORDER BY

খারাপ:
-- =========================================================
-- Duplicate date থাকলে ordering ambiguous হতে পারে
-- =========================================================
SUM(Sales)
OVER
(
    ORDER BY OrderDate
)
    
ভালো:
-- =========================================================
-- Tie-breaker যোগ করা হয়েছে
-- =========================================================
SUM(Sales)
OVER
(
    ORDER BY OrderDate, OrderID, OrderDetailID
)



✅ 2. Running Total-এ ROWS ব্যবহার করুন
-- =========================================================
-- Recommended running total pattern
-- =========================================================
SUM(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)


    
✅ 3. আগে aggregate, পরে window
বিশেষ করে daily/monthly analytics-এ:
Raw Fact
   ↓
GROUP BY Day
   ↓
Daily Dataset
   ↓
Window Function
এটি raw transaction-level window calculation-এর চেয়ে অনেক efficient হতে পারে।









15. Master-Level Comparison
226–236
    
Requirement	                        Best candidate
শুধু summary	                        GROUP BY
Detail + summary	                Window
Running total	                    Window
Moving average	                    Window
Customer total beside transaction	Window
Simple grouped report	            GROUP BY
Complex historical calculation	    Window
Correlated lookup	                Often Window better
Recursive hierarchy	                CTE
Small one-off lookup	            Subquery can be fine




SUM() OVER vs GROUP BY
GROUP BY
-- =========================================================
-- GROUP BY summary
-- =========================================================
SELECT
    CustomerID,
    SUM(Sales) AS CustomerSales
FROM CustomerSales
GROUP BY CustomerID;




Window
-- =========================================================
-- Window version
-- Detail rows preserved
-- =========================================================
SELECT
    CustomerID,
    OrderID,
    Sales,

    SUM(Sales)
        OVER
        (
            PARTITION BY CustomerID
        ) AS CustomerSales

FROM CustomerSales;




Window vs Correlated Subquery
Old-style:
-- =========================================================
-- Correlated subquery example
-- =========================================================
SELECT
    a.CustomerID,
    a.OrderID,
    a.Sales,

    (
        SELECT SUM(b.Sales)
        FROM CustomerSales b
        WHERE b.CustomerID = a.CustomerID
    ) AS CustomerTotal

FROM CustomerSales a;




Window:
-- =========================================================
-- Window version
-- Usually clearer and often more efficient
-- =========================================================
SELECT
    CustomerID,
    OrderID,
    Sales,

    SUM(Sales)
        OVER
        (
            PARTITION BY CustomerID
        ) AS CustomerTotal

FROM CustomerSales;



কখন Window Function Avoid করবেন?
❌ শুধু grouped summary দরকার
Customer → Total Sales
তাহলে GROUP BY যথেষ্ট।


❌ Massive unnecessary detail
যদি millions of rows রেখে শুধু 10-row summary দরকার হয়, 
window unnecessarily অনেক rows process করতে পারে।


    
❌ Incorrect grain
সবচেয়ে common mistake:
Transaction grain
vs
Daily grain
vs
Monthly grain
Window করার আগে data grain পরিষ্কার করতে হবে।







16. Final Master Projects
আপনার 237–246 সব project একই Window Aggregate skill দিয়ে করা যাবে।


237. E-Commerce Sales Analytics
    
Metrics:
Grand Sales
Customer Sales
Product Sales
Category Sales
Running Sales
Moving Average
Contribution %
Customer Lifetime Value-like revenue metrics


    
238. Retail Sales Analytics
    
Branch Sales
Daily Sales
MTD
YTD
Running Sales
Peak Sales
Rolling Average


    
239. Restaurant POS Analytics 🍽️
    
Recommended tables:
Orders
OrderItems
Menu
Customers
Branches
Payments
Metrics:
Daily Revenue
Running Revenue
Average Order Value
Branch Contribution
Customer Spend
Product/Item Performance



    
240. Customer Revenue Analytics
    
Customer Total Revenue
Running Customer Spend
Average Spend
Minimum Spend
Maximum Spend
Revenue Contribution
Customer Order Count



    
241. Product Performance
    
Product Sales
Product Quantity
Product Average Sales
Product Minimum
Product Maximum
Running Product Sales
Rolling Product Sales
Product Contribution %



    
242. Inventory Analytics
    
আমাদের Inventory.StockTransactions table দিয়ে:
Running Inventory
Product Stock Balance
Stock Movement
Rolling Stock Movement
Negative Inventory Detection




    
243. Bank Transaction Analytics
    
Recommended structure:
AccountID
TransactionDate
TransactionType
Debit
Credit


    
তারপর:
-- =========================================================
-- Bank account running balance
-- =========================================================
SELECT
    AccountID,
    TransactionDate,

    Credit - Debit AS NetMovement,

    SUM(Credit - Debit)
        OVER
        (
            PARTITION BY AccountID
            ORDER BY TransactionDate
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningBalance

FROM BankTransactions;





244. Employee Payroll Analytics
    
Possible metrics:
Department Total Payroll
Employee Running Payroll
Average Salary
Department Average
Minimum Salary
Maximum Salary
Salary Contribution




    
245. Data Warehouse Fact Analytics
    
আপনার Data Warehouse environment-এ:
gold.fact_sales
       ↓
Daily Sales
       ↓
Monthly Sales
       ↓
Running Sales
       ↓
YTD
       ↓
Customer Contribution
       ↓
Product Contribution
       ↓
Category Contribution
       ↓
Power BI




    
246. ETL Monitoring Dashboard
    
আমাদের ETL.BatchLog table দিয়ে Power BI-ready metrics:
Total Records
Successful Records
Failed Records
Success Rate
Cumulative Records
Running Errors
Running Success
Average Processing Time
Maximum Processing Time
Source-wise Performance
Load-date Performance



    
উদাহরণ:
-- =========================================================
-- ETL monitoring dashboard dataset
-- =========================================================
SELECT
    BatchID,
    SourceSystem,
    LoadDate,
    TotalRecords,
    SuccessfulRecords,
    FailedRecords,
    ProcessingSeconds,

    SUM(TotalRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeRecords,

    SUM(FailedRecords)
        OVER
        (
            PARTITION BY SourceSystem
            ORDER BY LoadDate, BatchID
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS CumulativeErrors,

    AVG(ProcessingSeconds)
        OVER
        (
            PARTITION BY SourceSystem
        ) AS AvgProcessingSeconds,

    MAX(ProcessingSeconds)
        OVER
        (
            PARTITION BY SourceSystem
        ) AS MaxProcessingSeconds

FROM ETL.BatchLog;









17. আপনার 246 Topics-এর Mental Model
এতগুলো topic আসলে এই 5টি core pattern-এর উপর দাঁড়িয়ে আছে:
                    WINDOW AGGREGATE
                           │
          ┌────────────────┼────────────────┐
          ↓                ↓                ↓
      PARTITION          ORDER            FRAME
          │                │                │
       "WHO?"          "SEQUENCE?"      "HOW MANY?"
          │                │                │
          ↓                ↓                ↓
      Customer          Date            ROWS
      Product            ID             RANGE
      Category
      Branch
      Source



তারপর পাঁচটি প্রধান aggregate:
SUM()
AVG()
MIN()
MAX()
COUNT()
এবং এগুলো থেকে:
                 WINDOW AGGREGATE
                       │
       ┌───────────────┼───────────────┐
       ↓               ↓               ↓
   Partition        Running          Moving
   Analytics        Analytics        Analytics
       │               │               │
       ↓               ↓               ↓
Customer Total     Running Sales    7-Day Avg
Product Total      YTD Sales        30-Day Avg
Category Total     Running Qty      Rolling Sum
Branch Total       Running Profit   Rolling Min/Max








18. সবচেয়ে গুরুত্বপূর্ণ 10টি Production Patterns
আপনি SQL Server Data Analyst/Data Engineer হিসেবে এগুলো খুব ভালোভাবে আয়ত্ত করুন:
    
-- =========================================================
-- 1. Grand Total
-- =========================================================
SUM(Sales) OVER ()


    
-- =========================================================
-- 2. Partition Total
-- =========================================================
SUM(Sales)
OVER
(
    PARTITION BY CustomerID
)



-- =========================================================
-- 3. Running Total
-- =========================================================
SUM(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)


    
-- =========================================================
-- 4. Partitioned Running Total
-- =========================================================
SUM(Sales)
OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)





-- =========================================================
-- 5. Running Average
-- =========================================================
AVG(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)




    
-- =========================================================
-- 6. Moving Average
-- =========================================================
AVG(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
)




    
-- =========================================================
-- 7. Running Minimum
-- =========================================================
MIN(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)



    
-- =========================================================
-- 8. Running Maximum
-- =========================================================
MAX(Sales)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)




    
-- =========================================================
-- 9. Running Count
-- =========================================================
COUNT(*)
OVER
(
    ORDER BY OrderDate, OrderID
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)



    
-- =========================================================
-- 10. Contribution %
-- =========================================================
100.0 * Sales
/
NULLIF(SUM(Sales) OVER (), 0)









19. Interview Questions — Must Know
    
Q1. GROUP BY এবং Window Aggregate-এর মূল পার্থক্য কী?
Answer: GROUP BY rows collapse করে; Window Aggregate 
original rows preserve করে এবং aggregate result প্রতিটি applicable row-তে দেয়।

    
Q2. OVER() কী করে?
Answer: Window-এর scope define করে।


    
Q3. PARTITION BY কী?
Answer: Window calculation-এর logical groups তৈরি করে।


    
Q4. Running total কীভাবে করবেন?
SUM(Sales)
OVER
(
    ORDER BY OrderDate
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)


    
Q5. ROWS এবং RANGE পার্থক্য?
Answer: ROWS physical row-based frame; RANGE logical ORDER BY value/peer-based frame।

    
Q6. Running total-এ ROWS কেন prefer করা হয়?
Answer: Duplicate ORDER BY values থাকলেও physical row behavior বেশি predictable।


    
Q7. COUNT(*) বনাম COUNT(Column)?
Answer: COUNT(*) সব rows গণনা করে; COUNT(Column) NULL বাদ দেয়।


    
Q8. Window Aggregate কি GROUP BY replace করে?
Answer: সবসময় নয়। Summary-only query-তে GROUP BY সাধারণত বেশি 
appropriate; detail + aggregate দরকার হলে Window Function superior।


    
Q9. 7 rows এবং 7 days কি একই?
Answer: না। Missing dates থাকলে 7 rows ≠ 7 calendar days।


    
Q10. Window Function slow হওয়ার প্রধান কারণ?
Answer: Large sort, memory grant pressure, 
TempDB spill, large partitions এবং inefficient indexing/query design।






    

    
20. 🏆 Final Best-Practice Checklist
- ✅ Grain: Window করার আগে data grain বুঝুন।
- ✅ ORDER BY: Tie থাকলে unique tie-breaker যোগ করুন।
- ✅ ROWS: Running calculation-এ explicit ROWS prefer করুন।
- ✅ NULL: Percentage calculation-এ NULLIF() ব্যবহার করুন।
- ✅ Performance: Large raw fact-এর উপর unnecessary window calculation করবেন না।
- ✅ Pre-aggregation: Daily/monthly metric হলে আগে GROUP BY, তারপর window।
- ✅ Index: PARTITION BY + ORDER BY pattern অনুযায়ী index evaluate করুন।
- ✅ Execution Plan: Sort, memory grant এবং spill check করুন।
- ✅ Data Engineering: Batch/source/load-date partition ব্যবহার করে ETL monitoring করুন।
- ✅ BI: Window-generated metrics Power BI semantic model-এর জন্য excellent analytical inputs হতে পারে।





    
সবচেয়ে গুরুত্বপূর্ণ formula:
WINDOW AGGREGATE
       =
AGGREGATE
+
OVER()
+
OPTIONAL PARTITION BY
+
OPTIONAL ORDER BY
+
OPTIONAL FRAME
আর আপনার 246-topic roadmap-এর মূল mastery path হবে:
SUM()
  ↓
AVG()
  ↓
MIN()
  ↓
MAX()
  ↓
COUNT()
  ↓
PARTITION BY
  ↓
ORDER BY
  ↓
ROWS / RANGE
  ↓
Running Analytics
  ↓
Moving Analytics
  ↓
Business Analytics
  ↓
ETL Analytics
  ↓
Execution Plan
  ↓
Performance Optimization
  ↓
Real Projects
    
এটাই SQL Server-এ Window Aggregate mastery-এর complete architecture।

