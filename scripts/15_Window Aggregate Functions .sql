1. Window Function কী?
সাধারণ GROUP BY:
SELECT
    CustomerID,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY CustomerID;

এখানে প্রতিটি customer-এর জন্য একটি row থাকবে।
কিন্তু Window Function:
SELECT
    OrderID,
    CustomerID,
    COUNT(*) OVER(PARTITION BY CustomerID) AS TotalOrders
FROM Sales.Orders;

এখানে:
OrderID	CustomerID	TotalOrders
1001	   1	         3
1003	   1	         3
1009	   1	         3


👉 Original order-level rows থাকছে + customer-level aggregate-ও পাওয়া যাচ্ছে।
এটাই Window Function-এর power. 🔥






2. OVER() — Window-এর ভিত্তি
Syntax
FUNCTION() OVER()
উদাহরণ:
/* ============================================================
   সব Order-এর মোট সংখ্যা প্রতিটি row-তে দেখানো
   ============================================================ */

SELECT
    OrderID,
    CustomerID,
    COUNT(*) OVER() AS TotalOrders
FROM Sales.Orders;

এখানে OVER() কোনো partition বা ordering দিচ্ছে না।
অর্থাৎ:
পুরো result set = একটাই window







3. PARTITION BY
Syntax
FUNCTION() OVER
(
    PARTITION BY column
)
উদাহরণ:
  
/* ============================================================
   প্রতিটি Customer-এর মোট Order সংখ্যা
   ============================================================ */

SELECT
    OrderID,
    CustomerID,
    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS OrdersByCustomer
FROM Sales.Orders;

Concept
PARTITION BY CustomerID মানে:
Customer 1 → আলাদা window
Customer 2 → আলাদা window
Customer 3 → আলাদা window





4. COUNT() OVER()
-- Total Orders
/* ============================================================
   TASK 1
   প্রতিটি row-এর সাথে Total Orders দেখানো
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    CustomerID,
    COUNT(*) OVER() AS TotalOrders
FROM Sales.Orders;


-- Customer-wise Orders
/* ============================================================
   প্রতিটি Customer কতটি Order করেছে
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    CustomerID,
    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS OrdersByCustomer
FROM Sales.Orders;








5. COUNT(*) vs COUNT(1) vs COUNT(Column)
/* ============================================================
   COUNT(*) বনাম COUNT(1) বনাম COUNT(Score)
   ============================================================ */

SELECT
    CustomerID,
    Score,

    COUNT(*) OVER() AS CountStar,

    COUNT(1) OVER() AS CountOne,

    COUNT(Score) OVER() AS CountScore

FROM Sales.Customers;

Important Difference
Function	     NULL count করে?
COUNT(*)	    ✅ Row count করে
COUNT(1)	    ✅ Row count করে
COUNT(Score)	❌ NULL বাদ দেয়


আমাদের data-তে Score-এর দুইটি NULL আছে।
তাই:
COUNT(*)      = 10
COUNT(1)      = 10
COUNT(Score)  = 8

  
Best Practice ⭐⭐⭐⭐⭐
সাধারণ row count:
COUNT(*)
ব্যবহার করুন।






6. Duplicate Detection with COUNT() OVER()
Data Engineering-এ এটি অত্যন্ত গুরুত্বপূর্ণ। 🔥
/* ============================================================
   TASK 3
   OrderID duplicate কিনা check করা
   ============================================================ */

SELECT *
FROM
(
    SELECT
        *,
        COUNT(*) OVER
        (
            PARTITION BY OrderID
        ) AS DuplicateCount
    FROM Sales.OrdersArchive
) AS t
WHERE DuplicateCount > 1;


Result
1002 এবং 1004 duplicate হিসেবে পাওয়া যাবে।
কোথায় ব্যবহার করবেন?
      🧹 Data cleansing
      🔍 Data quality
      🚨 Duplicate detection
      🔄 ETL validation
      🏗️ Silver-layer validation







7. SUM() OVER()
Syntax
SUM(column) OVER()

-- Total Sales
/* ============================================================
   প্রতিটি Order-এর সাথে Overall Total Sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,

    SUM(Sales) OVER() AS TotalSales

FROM Sales.Orders;





8. Product-wise Total Sales
/* ============================================================
   প্রতিটি Product-এর মোট Sales
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS SalesByProduct

FROM Sales.Orders;






9. Overall + Product Total একসাথে
এটি বাস্তব reporting-এর জন্য খুব useful।
/* ============================================================
   Overall Total + Product Total
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    SUM(Sales) OVER() AS TotalSales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS ProductSales

FROM Sales.Orders;


এখন একই row-তে:
Individual Sale
Product Total
Overall Total
সব পাওয়া যাচ্ছে।







10. Percentage of Total
এটি Business Intelligence-এ অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   প্রতিটি Order Total Sales-এর কত শতাংশ
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    SUM(Sales) OVER() AS TotalSales,

    ROUND
    (
        CAST(Sales AS DECIMAL(18,4))
        / NULLIF(SUM(Sales) OVER(), 0)
        * 100,
        2
    ) AS PercentageOfTotal

FROM Sales.Orders;


কেন NULLIF()?
যদি total sales 0 হয়:
Division by zero
হতে পারে।
তাই:
NULLIF(SUM(Sales) OVER(), 0)
ব্যবহার করা safer।






11. AVG() OVER()
Overall Average
/* ============================================================
   Overall Average Order Sales
   ============================================================ */

SELECT
    OrderID,
    Sales,

    AVG(Sales) OVER() AS AvgSales

FROM Sales.Orders;





12. Product-wise Average
/* ============================================================
   Product-এর Average Sales
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    AVG(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS AvgSalesByProduct

FROM Sales.Orders;





13. NULL এবং AVG()
/* ============================================================
   NULL handling with AVG()
   ============================================================ */

SELECT
    CustomerID,
    LastName,
    Score,

    AVG(Score) OVER() AS AvgScore,

    AVG(COALESCE(Score, 0)) OVER() AS AvgScoreWithZero

FROM Sales.Customers;


এখানে খুব গুরুত্বপূর্ণ বিষয় ⚠️
AVG(Score)
NULL ignore করবে।
  
কিন্তু:
AVG(COALESCE(Score, 0))
NULL-কে 0 ধরে average করবে।
দুইটি business meaning এক নয়।
Missing score মানেই zero score নয়।
তাই blindly COALESCE(...,0) করা উচিত নয়।





14. Average-এর চেয়ে বেশি Sales
/* ============================================================
   Average Order Value-এর চেয়ে বেশি Orders
   ============================================================ */

SELECT *
FROM
(
    SELECT
        OrderID,
        ProductID,
        Sales,

        AVG(Sales) OVER() AS AvgSales

    FROM Sales.Orders
) AS t
WHERE Sales > AvgSales;


কেন subquery?
Window Function-এর result একই query level-এর WHERE clause-এ সরাসরি ব্যবহার করা যায় না।
❌ এভাবে নয়:
WHERE Sales > AVG(Sales) OVER()
  
✅ তাই ব্যবহার করুন:
Window Function
      ↓
Subquery / CTE
      ↓
WHERE








15. MIN() এবং MAX()
Overall Minimum & Maximum
/* ============================================================
   Overall Minimum এবং Maximum Sales
   ============================================================ */
SELECT
    MIN(Sales) AS MinSales,
    MAX(Sales) AS MaxSales
FROM Sales.Orders;


এটি aggregate function।
Window version:
/* ============================================================
   প্রতিটি Order-এর সাথে Minimum এবং Maximum Sales
   ============================================================ */
SELECT
    OrderID,
    Sales,

    MIN(Sales) OVER() AS LowestSales,

    MAX(Sales) OVER() AS HighestSales

FROM Sales.Orders;





16. Product-wise Minimum
/* ============================================================
   প্রতিটি Product-এর Lowest Sale
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    Sales,
    MIN(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS LowestSalesByProduct
FROM Sales.Orders;







17. Highest Salary Employee
/* ============================================================
   Highest Salary বের করা
   ============================================================ */
SELECT *
FROM
(
    SELECT
        *,
        MAX(Salary) OVER() AS HighestSalary
    FROM Sales.Employees
) AS t
WHERE Salary = HighestSalary;


কেন TOP 1 না?
কারণ একই highest salary একাধিক employee-এর হতে পারে।
আমাদের data-তে:
Grace → 95000
এবং যদি আরেকজন 95000 পায়, দুজনকেই return করবে।







18. Sales Deviation
এটি analytical reporting-এর জন্য খুব useful।
/* ============================================================
   Minimum / Maximum থেকে প্রতিটি Sale-এর deviation
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,

    MAX(Sales) OVER() AS HighestSales,

    MIN(Sales) OVER() AS LowestSales,

    Sales - MIN(Sales) OVER()
        AS DeviationFromMin,

    MAX(Sales) OVER() - Sales
        AS DeviationFromMax
FROM Sales.Orders;





19. ORDER BY inside OVER()
এখন Window Function-এর সবচেয়ে গুরুত্বপূর্ণ অংশে আসি।
FUNCTION()
OVER
(
    PARTITION BY column
    ORDER BY column
)
ORDER BY ব্যবহার করলে row sequence তৈরি হয়।
  
এটি বিশেষ করে দরকার:
      Running Total
      Running Average
      LAG
      LEAD
      Ranking
      Rolling calculations






20. Running Total
Syntax
SUM(Sales) OVER
(
    ORDER BY OrderDate
    ROWS BETWEEN UNBOUNDED PRECEDING
    AND CURRENT ROW
)
/* ============================================================
   RUNNING TOTAL SALES
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
    ) AS RunningTotalSales
FROM Sales.Orders
ORDER BY OrderDate, OrderID;


Concept
Row 1 → Sales 1200 → 1200
Row 2 → Sales 200  → 1400
Row 3 → Sales 100  → 1500
Row 4 → Sales 500  → 2000






21. Customer-wise Running Total
/* ============================================================
   প্রতিটি Customer-এর Running Sales
   ============================================================ */

SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS CustomerRunningSales
FROM Sales.Orders;


এখানে:
PARTITION BY CustomerID
প্রতিটি customer-এর running calculation reset করে।






22. Running Average
/* ============================================================
   RUNNING AVERAGE
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    AVG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningAverage

FROM Sales.Orders;







23. Product-wise Running Average
/* ============================================================
   Product-এর জন্য Running Average
   ============================================================ */
SELECT
    ProductID,
    OrderID,
    OrderDate,
    Sales,
    AVG(Sales) OVER
    (
        PARTITION BY ProductID
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS ProductRunningAverage
FROM Sales.Orders;







24. Rolling Sum
Running Total এবং Rolling Sum এক জিনিস নয়।
Running
1
1+2
1+2+3
1+2+3+4
  
Rolling 3 Rows
1
1+2
1+2+3
2+3+4
3+4+5








25. Rolling 3-Order Sum
/* ============================================================
   LAST 3 ORDERS-এর Sales Sum
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
    ) AS Rolling3OrderSales
FROM Sales.Orders;


2 PRECEDING কেন?
Current row + previous 2 rows:
2 previous + current = 3 rows







26. Rolling 3-Order Average
/* ============================================================
   LAST 3 ORDERS-এর Average Sales
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
    ) AS Rolling3OrderAverage
FROM Sales.Orders;







27. Current Row + Next Order
আপনার Task 14-এর concept:
/* ============================================================
   Current Order + Next Order
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    OrderDate,
    Sales,
    AVG(Sales) OVER
    (
        PARTITION BY ProductID
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN CURRENT ROW
        AND 1 FOLLOWING

    ) AS RollingAverage
FROM Sales.Orders;


এখানে window:
Current Row
+
Next Row






28. Window Frame — অত্যন্ত গুরুত্বপূর্ণ 🔥
Window Frame বলে দেয় কোন rows calculation-এর মধ্যে থাকবে।
Syntax
ROWS BETWEEN
    start_boundary
    AND
    end_boundary






29. UNBOUNDED PRECEDING
মানে:
প্রথম row থেকে শুরু।

ROWS BETWEEN
UNBOUNDED PRECEDING
AND CURRENT ROW
এটি Running Total-এর জন্য সবচেয়ে common।






30. CURRENT ROW
বর্তমান row।
ROWS BETWEEN
CURRENT ROW
AND CURRENT ROW
অর্থাৎ শুধু current row।






31. n PRECEDING
আগের n rows।
ROWS BETWEEN
2 PRECEDING
AND CURRENT ROW
মানে:
Previous 2 rows
+
Current row







32. n FOLLOWING
পরবর্তী n rows।
ROWS BETWEEN
CURRENT ROW
AND 2 FOLLOWING
মানে:
Current row
+
Next 2 rows





33. ROWS BETWEEN
সবচেয়ে explicit syntax:
SUM(Sales) OVER
(
    ORDER BY OrderDate
    ROWS BETWEEN
    2 PRECEDING
    AND CURRENT ROW
)





34. ROWS বনাম RANGE
এখানে অনেক SQL learner ভুল করে। ⚠️

  
ROWS
Physical rows-এর ভিত্তিতে frame তৈরি করে।
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
অর্থাৎ previous 2 rows।

  
RANGE
Ordering value-এর peer/grouping semantics-এর ভিত্তিতে কাজ করে।
বিশেষ করে duplicate ORDER BY values থাকলে ROWS এবং RANGE-এর result আলাদা হতে পারে।

  
Best Practice ⭐
Running calculations-এ যদি exact row-based behavior চান:
ROWS BETWEEN
UNBOUNDED PRECEDING
AND CURRENT ROW
ব্যবহার করা ভালো।






35. কেন ORDER BY-এ Unique Tie-Breaker দেওয়া ভালো?
এটি খুব গুরুত্বপূর্ণ production practice।
  
❌:
ORDER BY OrderDate
যদি একই date-এ একাধিক order থাকে, row ordering ambiguous হতে পারে।
  
✅:
ORDER BY OrderDate, OrderID
OrderID এখানে tie-breaker।







36. ROW_NUMBER()
এটি aggregate নয়, কিন্তু Window Functions-এর সবচেয়ে গুরুত্বপূর্ণ ranking function-এর একটি।
/* ============================================================
   প্রতিটি Customer-এর Order Sequence
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    ROW_NUMBER() OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS OrderSequence
FROM Sales.Orders;


Result concept:
Customer 1
Order 1001 → 1
Order 1003 → 2
Order 1009 → 3






37. RANK()
/* ============================================================
   Sales অনুযায়ী Ranking
   ============================================================ */
SELECT
    OrderID,
    Sales,
    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesRank
FROM Sales.Orders;

Tie হলে একই rank পাবে এবং gap তৈরি হবে।





38. DENSE_RANK()
/* ============================================================
   Dense Ranking
   ============================================================ */
SELECT
    OrderID,
    Sales,
    DENSE_RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesDenseRank
FROM Sales.Orders;

Difference
যদি values:
1000
1000
900
800
  
তাহলে:
Sales	 RANK	 DENSE_RANK
1000	  1	    1
1000	  1	    1
900	    3	    2
800	    4	    3






39. NTILE()
Data segmentation-এর জন্য useful।
/* ============================================================
   Customers-কে 4টি Sales Group-এ ভাগ করা
   ============================================================ */
SELECT
    OrderID,
    Sales,
    NTILE(4) OVER
    (
        ORDER BY Sales DESC
    ) AS SalesQuartile
FROM Sales.Orders;


Use cases:
Top 25%
Bottom 25%
Customer segmentation
Sales performance buckets






40. LAG()
Previous row-এর value আনতে।
/* ============================================================
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





41. LEAD()
Next row-এর value আনতে।
/* ============================================================
   Next Order Sales
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    Sales,
    LEAD(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS NextSales
FROM Sales.Orders;









42. Previous Period Comparison
এটি বাস্তব analytics-এ অত্যন্ত গুরুত্বপূর্ণ। ⭐⭐⭐⭐⭐
প্রথমে monthly sales তৈরি করি।
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
)
SELECT
    SalesMonth,
    TotalSales,
    LAG(TotalSales) OVER
    (
        ORDER BY SalesMonth
    ) AS PreviousMonthSales
FROM MonthlySales
ORDER BY SalesMonth;







43. MoM Analysis
MoM = Month-over-Month.
/* ============================================================
   MONTH-OVER-MONTH SALES GROWTH
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
Comparison AS
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
    ROUND
    (
        (
            TotalSales - PreviousMonthSales
        )
        / NULLIF(PreviousMonthSales, 0)
        * 100,
        2
    ) AS MoMGrowthPercentage
FROM Comparison
ORDER BY SalesMonth;





44. YoY Analysis
-- YoY = Year-over-Year।
-- এখানে একই month-এর আগের year's sales compare করা হয়।
যদি monthly dataset থাকে:
/* ============================================================
   YEAR-OVER-YEAR ANALYSIS
   ============================================================ */
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonthNumber,

        SUM(Sales) AS TotalSales

    FROM Sales.Orders

    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
Comparison AS
(
    SELECT
        SalesYear,
        SalesMonthNumber,
        TotalSales,

        LAG(TotalSales, 12) OVER
        (
            ORDER BY SalesYear, SalesMonthNumber
        ) AS PreviousYearSales
    FROM MonthlySales
)
SELECT
    SalesYear,
    SalesMonthNumber,
    TotalSales,
    PreviousYearSales,
    ROUND
    (
        (
            TotalSales - PreviousYearSales
        )
        / NULLIF(PreviousYearSales, 0)
        * 100,
        2
    ) AS YoYGrowthPercentage
FROM Comparison;

Production data-তে missing months থাকলে LAG(...,12) blindly ব্যবহার করা ঠিক নয়। 
Date dimension/calendar table ব্যবহার করে month continuity নিশ্চিত করা ভালো।







45. FIRST_VALUE()
Window-এর প্রথম value।
/* ============================================================
   Customer-এর প্রথম Order-এর Sales
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    FIRST_VALUE(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS FirstOrderSales
FROM Sales.Orders;







46. LAST_VALUE()
এখানে একটি খুব গুরুত্বপূর্ণ SQL Server trap আছে। ⚠️
অনেক সময়:
LAST_VALUE(Sales) OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate
)
expected result দেয় না, কারণ default window frame current row পর্যন্ত থাকতে পারে।
তাই explicit frame ব্যবহার করুন:
/* ============================================================
   Customer-এর Last Order Sales
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    LAST_VALUE(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
    ) AS LastOrderSales
FROM Sales.Orders;


Best Practice ⭐⭐⭐⭐⭐
LAST_VALUE() ব্যবহার করার সময় window frame বুঝে লিখুন।






47. PERCENT_RANK()
Relative ranking।
/* ============================================================
   Relative Rank Percentage
   ============================================================ */
SELECT
    OrderID,
    Sales,
    PERCENT_RANK() OVER
    (
        ORDER BY Sales
    ) AS PercentRank
FROM Sales.Orders;

Range:
0 → 1






48. CUME_DIST()
Current value পর্যন্ত কত percentage rows এসেছে।
/* ============================================================
   Cumulative Distribution
   ============================================================ */
SELECT
    OrderID,
    Sales,
    CUME_DIST() OVER
    (
        ORDER BY Sales
    ) AS CumulativeDistribution
FROM Sales.Orders;

এটি statistical/business segmentation-এ useful।







49. PERCENTILE_CONT()
Continuous percentile।
উদাহরণ: Median Sales।
/* ============================================================
   MEDIAN SALES
   Continuous Percentile
   ============================================================ */
SELECT DISTINCT

    PERCENTILE_CONT(0.5)
    WITHIN GROUP
    (
        ORDER BY Sales
    ) OVER () AS MedianSales
FROM Sales.Orders;

0.5 = 50th percentile = Median।






50. PERCENTILE_DISC()
Discrete percentile।
/* ============================================================
   DISCRETE MEDIAN
   ============================================================ */
SELECT DISTINCT
    PERCENTILE_DISC(0.5)
    WITHIN GROUP
    (
        ORDER BY Sales
    ) OVER () AS MedianSales
FROM Sales.Orders;


Difference
Function	          Meaning
PERCENTILE_CONT	    Interpolated/continuous value
PERCENTILE_DISC	    Actual value from dataset







51. Complete Real-World Sales Analysis 🚀
এখন এক query-তে অনেক Window Function combine করি।
/* ============================================================
   COMPLETE SALES ANALYSIS
   ============================================================ */
SELECT
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    Sales,

    /* Overall total */
    SUM(Sales) OVER() AS TotalSales,

    /* Product total */
    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS ProductTotalSales,

    /* Overall average */
    AVG(Sales) OVER() AS AverageSales,

    /* Product average */
    AVG(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS ProductAverageSales,

    /* Minimum */
    MIN(Sales) OVER() AS MinimumSales,

    /* Maximum */
    MAX(Sales) OVER() AS MaximumSales,

    /* Customer order count */
    COUNT(*) OVER
    (
        PARTITION BY CustomerID
    ) AS CustomerOrderCount,

    /* Product ranking */
    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS SalesRank,

    /* Previous order */
    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS PreviousSales,

    /* Next order */
    LEAD(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS NextSales,

    /* Running total */
    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS RunningTotalSales,

    /* Rolling 3-order average */
    AVG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN
        2 PRECEDING
        AND CURRENT ROW
    ) AS Rolling3OrderAverage
FROM Sales.Orders;

এটি একটি অত্যন্ত ভালো Window Functions practice query। 🔥







52. কোনটা কোথায় ব্যবহার করবেন?
Business Requirement	         Function
Total rows	                   COUNT() OVER()
Customer-wise count	           COUNT() OVER(PARTITION BY)
Overall sales	                 SUM() OVER()
Product sales	                 SUM() OVER(PARTITION BY)
Average sales	                 AVG() OVER()
Highest/lowest	               MAX()/MIN() OVER()
Running sales	                 SUM() OVER(ORDER BY)
Rolling sales	                 SUM() OVER(ROWS...)
Moving average	               AVG() OVER(ROWS...)
Previous value	               LAG()
Next value	                   LEAD()
MoM	                           LAG()
YoY	                           LAG()
First record	                 FIRST_VALUE()
Last record	                   LAST_VALUE()
Unique numbering	             ROW_NUMBER()
Ranking with gaps	             RANK()
Ranking without gaps	         DENSE_RANK()
Segmentation	                 NTILE()
Relative position	             PERCENT_RANK()
Distribution	                 CUME_DIST()
Median	                       PERCENTILE_CONT()






53. Window Functions-এর সবচেয়ে গুরুত্বপূর্ণ Mental Model 🧠
এটা মনে রাখলে প্রায় সব Window Function বুঝতে পারবেন:

                    WINDOW FUNCTION
                          │
              ┌───────────┴───────────┐
              │                       │
          OVER()                  OVER(...)
              │                       │
        Whole Result          ┌───────┴────────┐
                              │                │
                        PARTITION BY       ORDER BY
                              │                │
                        Group Window      Row Sequence
                                               │
                                         Window Frame
                                               │
                              ┌────────────────┼───────────────┐
                              │                │               │
                         Running         Rolling          Previous/
                         Total           Average           Next









54. Common Mistakes ⚠️
❌ Mistake 1 — GROUP BY এবং Window Function-এর পার্থক্য না বোঝা
GROUP BY
rows collapse করে।
OVER()
individual rows retain করে।

  
❌ Mistake 2 — PARTITION BY-কে GROUP BY ভাবা
PARTITION BY
result rows collapse করে না।

  
❌ Mistake 3 — Running Total-এ ORDER BY না দেওয়া
SUM(Sales) OVER()
Running Total নয়।
এটি Overall Total।
Running Total:
SUM(Sales) OVER
(
    ORDER BY OrderDate
)

  
❌ Mistake 4 — Duplicate date নিয়ে ambiguous ordering
❌
ORDER BY OrderDate
✅
ORDER BY OrderDate, OrderID

  
❌ Mistake 5 — LAST_VALUE() ভুলভাবে ব্যবহার করা
Explicit frame দরকার হতে পারে:
ROWS BETWEEN
UNBOUNDED PRECEDING
AND UNBOUNDED FOLLOWING

  
❌ Mistake 6 — NULL-কে automatically 0 করা
COALESCE(Score, 0)
শুধুমাত্র তখনই ব্যবহার করুন যখন business meaning অনুযায়ী NULL = 0।


