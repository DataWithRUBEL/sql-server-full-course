/* ============================================================
   Check Orders Data
   ============================================================ */

SELECT *
FROM Sales.Orders
ORDER BY OrderDate;



1. Window Function আসলে কী?
সহজভাবে:
Window Function বর্তমান row-এর সাথে সম্পর্কিত অন্য rows-এর উপর calculation করে, কিন্তু rows-গুলোকে collapse করে না।

এটাই সবচেয়ে গুরুত্বপূর্ণ difference।
GROUP BY
10 rows
   ↓
GROUP BY
   ↓
3 rows
Window Function
10 rows
   ↓
Window Function
   ↓
10 rows + calculated column




2. GROUP BY — Window Function বোঝার আগে
-- Total Sales
/* ============================================================
   Total Sales
   ============================================================ */

SELECT
    SUM(Sales) AS Total_Sales
FROM Sales.Orders;

এখানে পুরো table-এর একটি result পাওয়া যাবে।





3. GROUP BY
Product অনুযায়ী Sales
/* ============================================================
   Total Sales by Product
   GROUP BY rows collapse করে।
   ============================================================ */

SELECT
    ProductID,
    SUM(Sales) AS Total_Sales
FROM Sales.Orders
GROUP BY ProductID;

Output হবে approximately:
ProductID | Total_Sales
----------|------------
101       | 7200
102       | 1600
103       | 240
...
কিন্তু প্রতিটি individual Order আর দেখা যাচ্ছে না।





4. OVER() Clause
এখান থেকেই Window Function শুরু।
/* ============================================================
   OVER() = পুরো result set-এর উপর calculation
   কিন্তু rows collapse করবে না।
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,

    SUM(Sales) OVER() AS Total_Sales

FROM Sales.Orders;


প্রতিটি row-তে একই Total_Sales থাকবে।
গুরুত্বপূর্ণ
SUM(Sales)
vs
SUM(Sales) OVER()

Syntax	            কাজ
SUM(Sales)	        Aggregate
SUM(Sales) OVER()	  Window Aggregate






5. PARTITION BY
PARTITION BY Window Function-এর data-কে logical group-এ ভাগ করে।
/* ============================================================
   Total Sales by Product
   কিন্তু individual orders থাকবে।
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    ProductID,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS Sales_By_Product

FROM Sales.Orders;


Concept
Product 101
   ├── Order 1001
   ├── Order 1005
   ├── Order 1010
   └── Order 1014

Product 102
   ├── Order 1002
   ├── Order 1007
   └── ...
প্রতিটি product নিজের আলাদা window পাবে।






6. Multiple PARTITION
একাধিক column দিয়েও partition করা যায়।
/* ============================================================
   Product + Order Status অনুযায়ী Sales
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    OrderStatus,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID, OrderStatus
    ) AS Sales_By_Product_Status

FROM Sales.Orders;

অর্থাৎ:
ProductID + OrderStatus
হলো grouping key।







7. Total + Product Total + Product/Status Total
এটি খুব useful analytical pattern।
/* ============================================================
   Multiple Window Calculations
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    ProductID,
    OrderStatus,
    Sales,

    -- Entire dataset
    SUM(Sales) OVER() AS Total_Sales,

    -- Product level
    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS Product_Total_Sales,

    -- Product + Status level
    SUM(Sales) OVER
    (
        PARTITION BY ProductID, OrderStatus
    ) AS Product_Status_Total

FROM Sales.Orders;






8. ORDER BY in Window Function
ORDER BY window rows-এর logical sequence নির্ধারণ করে।
/* ============================================================
   Rank orders by Sales
   Highest Sales = Rank 1
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS Sales_Rank

FROM Sales.Orders;






9. ROW_NUMBER()
প্রতিটি row-কে unique sequential number দেয়।
/* ============================================================
   ROW_NUMBER()
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    ROW_NUMBER() OVER
    (
        ORDER BY Sales DESC, OrderID
    ) AS Row_Number

FROM Sales.Orders;


ROW_NUMBER vs RANK
যদি Sales হয়:
1200
1200
1200
400
400
150
তাহলে:
ROW_NUMBER
1
2
3
4
5
6








10. RANK()
/* ============================================================
   RANK()
   একই value হলে একই rank।
   তারপর gap তৈরি হয়।
   ============================================================ */

SELECT
    OrderID,
    Sales,

    RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS Sales_Rank

FROM Sales.Orders;
যেমন:
Sales | RANK
------|-----
1200  | 1
1200  | 1
1200  | 1
400   | 4
400   | 4
150   | 6







11. DENSE_RANK()
/* ============================================================
   DENSE_RANK()
   Same value = same rank
   কিন্তু gap তৈরি করে না।
   ============================================================ */

SELECT
    OrderID,
    Sales,

    DENSE_RANK() OVER
    (
        ORDER BY Sales DESC
    ) AS Dense_Rank

FROM Sales.Orders;

Result:
1200 → 1
1200 → 1
1200 → 1
400  → 2
400  → 2
150  → 3







12. ROW_NUMBER vs RANK vs DENSE_RANK
Function	            Duplicate হলে	            Gap
ROW_NUMBER()	        আলাদা number	            ❌
RANK()	              Same rank	                ✅
DENSE_RANK()	        Same rank	                ❌


মনে রাখুন 🧠
ROW_NUMBER  → Unique position
RANK        → Competition ranking
DENSE_RANK  → Continuous ranking





13. PARTITION + ROW_NUMBER
এটি অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   প্রতিটি Product-এর ভিতরে Order ranking
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    ROW_NUMBER() OVER
    (
        PARTITION BY ProductID
        ORDER BY Sales DESC, OrderID
    ) AS Product_Row_Number

FROM Sales.Orders;

এখানে প্রতিটি Product-এর ranking আবার 1 থেকে শুরু হবে। 







14. NTILE()
Rows-কে নির্দিষ্ট সংখ্যক bucket/group-এ ভাগ করে।
/* ============================================================
   NTILE(4)
   Customers/Orders-কে 4টি bucket-এ ভাগ করা
   ============================================================ */

SELECT
    OrderID,
    Sales,

    NTILE(4) OVER
    (
        ORDER BY Sales DESC
    ) AS Sales_Quartile

FROM Sales.Orders;

Useful for:
            Top 25%
            Bottom 25%
            Customer segmentation
            Performance bands








15. LAG()
Previous row-এর value দেখতে ব্যবহার হয়।
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
    ) AS Previous_Sales

FROM Sales.Orders;







16. LAG দিয়ে Sales Difference
/* ============================================================
   Current Sales vs Previous Sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS Previous_Sales,

    Sales -
    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS Sales_Difference

FROM Sales.Orders;

এটি business analysis-এ খুব common।








17. LEAD()
পরবর্তী row-এর value দেখায়।
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
    ) AS Next_Sales

FROM Sales.Orders;

মনে রাখুন
LAG  → Previous
LEAD → Next






18. FIRST_VALUE()
Window-এর প্রথম value দেয়।
/* ============================================================
   প্রথম Order-এর Sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    FIRST_VALUE(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS First_Sales

FROM Sales.Orders;






19. LAST_VALUE()
এখানে একটি গুরুত্বপূর্ণ SQL Server issue আছে।
শুধু:
LAST_VALUE(Sales) OVER
(
    ORDER BY OrderDate
)
লিখলে আপনি অনেক সময় expected final row-এর value পাবেন না, কারণ default frame current row পর্যন্ত হতে পারে।
সঠিকভাবে:
/* ============================================================
   LAST_VALUE()
   পুরো window-এর শেষ row পর্যন্ত frame extend করা হয়েছে।
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    LAST_VALUE(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND UNBOUNDED FOLLOWING

    ) AS Last_Sales

FROM Sales.Orders;

Best Practice ⭐
LAST_VALUE() ব্যবহার করলে frame সম্পর্কে সচেতন থাকুন।






20. SUM() OVER()
/* ============================================================
   SUM() OVER()
   ============================================================ */

SELECT
    OrderID,
    Sales,

    SUM(Sales) OVER() AS Grand_Total

FROM Sales.Orders;






21. AVG() OVER()
/* ============================================================
   Average Sales across all orders
   ============================================================ */

SELECT
    OrderID,
    Sales,

    AVG(Sales) OVER() AS Average_Sales

FROM Sales.Orders;





22. COUNT() OVER()
/* ============================================================
   Total number of orders
   ============================================================ */

SELECT
    OrderID,
    CustomerID,

    COUNT(*) OVER() AS Total_Orders

FROM Sales.Orders;





23. MIN() / MAX() OVER()
/* ============================================================
   Minimum and Maximum Sales
   ============================================================ */

SELECT
    OrderID,
    Sales,

    MIN(Sales) OVER() AS Minimum_Sales,
    MAX(Sales) OVER() AS Maximum_Sales

FROM Sales.Orders;









24. PARTITION + AVG
/* ============================================================
   Average Sales per Product
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    Sales,

    AVG(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS Avg_Product_Sales

FROM Sales.Orders;







25. FRAME CLAUSE
এখন Window Function-এর advanced অংশ।
মূল syntax:
ROWS BETWEEN
    start_point
    AND
    end_point
Common values:
UNBOUNDED PRECEDING
n PRECEDING
CURRENT ROW
n FOLLOWING
UNBOUNDED FOLLOWING






26. Running Total
সবচেয়ে গুরুত্বপূর্ণ Window Function patternগুলোর একটি।
/* ============================================================
   RUNNING TOTAL

   প্রথম row থেকে current row পর্যন্ত cumulative sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Running_Total

FROM Sales.Orders;

Example:
Sales | Running Total
------|--------------
1200  | 1200
400   | 1600
80    | 1680
50    | 1730









27. Short Syntax for Running Total
এটিও equivalent:
/* ============================================================
   Short version
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS UNBOUNDED PRECEDING
    ) AS Running_Total

FROM Sales.Orders;






28. Running Total by Product
/* ============================================================
   Product-wise Running Total
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Product_Running_Total

FROM Sales.Orders;





29. Current + Previous 2 Rows
/* ============================================================
   Current row + previous 2 rows
   = 3-row rolling window
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            2 PRECEDING
            AND CURRENT ROW

    ) AS Three_Row_Total

FROM Sales.Orders;








30. Previous 2 Rows ONLY
আপনার original code-এ:
ROWS 2 PRECEDING
ছিল।
⚠️ এটি previous 2 rows only নয়।
এটি equivalent to:
ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
অর্থাৎ current row-ও include করে।
Previous 2 rows only চাইলে:
/* ============================================================
   Previous 2 rows ONLY
   Current row বাদ
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            2 PRECEDING
            AND 1 PRECEDING

    ) AS Previous_2_Rows_Total

FROM Sales.Orders;

এটি একটি গুরুত্বপূর্ণ correction। ✅






31. Current + Next 2 Rows
/* ============================================================
   Current row + next 2 rows
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            CURRENT ROW
            AND 2 FOLLOWING

    ) AS Current_Next_2_Total

FROM Sales.Orders;







32. Moving Average
3-row moving average:
/* ============================================================
   3-row Moving Average
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    AVG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            2 PRECEDING
            AND CURRENT ROW

    ) AS Moving_Average

FROM Sales.Orders;

Business Use
যেমন daily sales:
Day 1 = 100
Day 2 = 200
Day 3 = 300
Day 3 moving average:
(100 + 200 + 300) / 3
= 200
Trend analysis-এ খুব useful।







33. Advanced Frame
Previous 7 rows
/* ============================================================
   7-row rolling total
   ============================================================ */

SELECT
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS Rolling_7_Row_Sales

FROM Sales.Orders;

⚠️ এটি 7 calendar days নয়; এটি 7 physical rows।







34. % of Total
এটি Data Analyst-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   Product Sales as % of Grand Total
   ============================================================ */

SELECT
    ProductID,

    SUM(Sales) AS Product_Sales,

    SUM(Sales) * 100.0
    / SUM(SUM(Sales)) OVER() AS Percentage_of_Total

FROM Sales.Orders

GROUP BY ProductID;


এখানে খুব গুরুত্বপূর্ণ concept:
SUM(SUM(Sales)) OVER()
প্রথম:
SUM(Sales)
GROUP BY অনুযায়ী aggregate করে।
তারপর:
SUM(...) OVER()
সেই aggregated rows-এর উপর window calculation করে।






35. Customer % of Total Sales
/* ============================================================
   Customer contribution to total sales
   ============================================================ */

SELECT
    CustomerID,

    SUM(Sales) AS Customer_Sales,

    SUM(Sales) * 100.0
    / SUM(SUM(Sales)) OVER()
        AS Sales_Percentage

FROM Sales.Orders

GROUP BY CustomerID;




36. Previous / Next Comparison
/* ============================================================
   Compare Current Sales with Previous Sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS Previous_Sales,

    LEAD(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS Next_Sales

FROM Sales.Orders;







37. Previous vs Current Growth %
/* ============================================================
   Sales Growth Percentage
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
    ) AS Previous_Sales,

    (
        Sales -
        LAG(Sales) OVER
        (
            ORDER BY OrderDate, OrderID
        )
    ) * 100.0
    /
    NULLIF
    (
        LAG(Sales) OVER
        (
            ORDER BY OrderDate, OrderID
        ),
        0
    ) AS Growth_Percentage

FROM Sales.Orders;

NULLIF(...,0) division by zero prevent করে।









38. Top N per Group
এটি Window Function-এর সবচেয়ে important real-world use cases-এর একটি।
Requirement:
প্রতিটি Product-এর Top 2 highest sales orders।
/* ============================================================
   STEP 1:
   Product-wise ranking
   ============================================================ */

WITH RankedOrders AS
(
    SELECT
        OrderID,
        ProductID,
        OrderDate,
        Sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY ProductID
            ORDER BY Sales DESC, OrderID
        ) AS rn

    FROM Sales.Orders
)

/* ============================================================
   STEP 2:
   Keep Top 2
   ============================================================ */

SELECT
    OrderID,
    ProductID,
    OrderDate,
    Sales

FROM RankedOrders

WHERE rn <= 2;

Business use
        প্রতিটি category-এর Top 5 products
        প্রতিটি customer-এর Top 3 orders
        প্রতিটি region-এর Top 10 salespeople
        প্রতিটি department-এর Top 3 employees





39. Deduplication
ধরুন একই customer-এর duplicate records আছে।
Example:
CustomerID | Email             | UpdatedDate
-----------|-------------------|------------
1          | a@gmail.com       | 2026-01-01
1          | a@gmail.com       | 2026-02-01
1          | a@gmail.com       | 2026-03-01
Latest record রাখতে:
/* ============================================================
   Deduplication pattern
   Latest record = rn 1
   ============================================================ */

WITH Dedup AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY UpdatedDate DESC
        ) AS rn

    FROM CustomerSource
)

SELECT *
FROM Dedup
WHERE rn = 1;

এটি ETL/Data Engineering-এর খুব গুরুত্বপূর্ণ pattern।





40. Latest Record
ধরুন প্রতিটি customer-এর latest order দরকার।
/* ============================================================
   Latest order per customer
   ============================================================ */

WITH LatestOrder AS
(
    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        Sales,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn

    FROM Sales.Orders
)

SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Sales

FROM LatestOrder

WHERE rn = 1;







41. CTE + Window Function
Window Function + CTE খুব common।
/* ============================================================
   Rank customers by total sales
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS Total_Sales

    FROM Sales.Orders

    GROUP BY CustomerID
)

SELECT
    CustomerID,
    Total_Sales,

    RANK() OVER
    (
        ORDER BY Total_Sales DESC
    ) AS Customer_Rank

FROM CustomerSales;






42. JOIN + Window Function
/* ============================================================
   Customer name + total sales + ranking
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS Total_Sales

    FROM Sales.Orders

    GROUP BY CustomerID
)

SELECT
    c.CustomerID,
    c.CustomerName,
    cs.Total_Sales,

    RANK() OVER
    (
        ORDER BY cs.Total_Sales DESC
    ) AS Customer_Rank

FROM CustomerSales cs

INNER JOIN Sales.Customers c
    ON cs.CustomerID = c.CustomerID;

এটি একটি খুব realistic reporting query।





43. CASE + Window Function
ধরুন customer sales অনুযায়ী segmentation:
>= 3000 → VIP
>= 1500 → Regular
< 1500  → New
/* ============================================================
   Customer Segmentation
   CASE + Window Function
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS Total_Sales

    FROM Sales.Orders

    GROUP BY CustomerID
)

SELECT
    CustomerID,
    Total_Sales,

    CASE
        WHEN Total_Sales >= 3000
            THEN 'VIP'

        WHEN Total_Sales >= 1500
            THEN 'Regular'

        ELSE 'New'
    END AS Customer_Segment,

    RANK() OVER
    (
        ORDER BY Total_Sales DESC
    ) AS Customer_Rank

FROM CustomerSales;





44. GROUP BY + Window Function
আপনার original Task 12-এর pattern:
/* ============================================================
   Rank customers by total sales
   GROUP BY first,
   তারপর Window Function
   ============================================================ */

SELECT
    CustomerID,

    SUM(Sales) AS Total_Sales,

    RANK() OVER
    (
        ORDER BY SUM(Sales) DESC
    ) AS Customer_Rank

FROM Sales.Orders

GROUP BY CustomerID;

এটি valid এবং অত্যন্ত useful।






45. GROUP BY + Window এর Mental Model
এটি মনে রাখুন:
Raw Orders
     ↓
GROUP BY CustomerID
     ↓
Customer Sales
     ↓
RANK() OVER(...)
     ↓
Customer Ranking
  
অর্থাৎ:
GROUP BY
প্রথমে logical aggregation তৈরি করে।
  
তারপর:
RANK() OVER(...)
সেই result-এর উপর calculation করে।





46. PARTITION BY Status + Running Total
/* ============================================================
   Status-wise Running Sales
   ============================================================ */

SELECT
    OrderID,
    OrderDate,
    OrderStatus,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY OrderStatus

        ORDER BY OrderDate, OrderID

        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Status_Running_Sales

FROM Sales.Orders;







47. PARTITION + Ranking
/* ============================================================
   প্রতিটি Order Status-এর ভিতরে Sales Rank
   ============================================================ */

SELECT
    OrderID,
    OrderStatus,
    Sales,

    RANK() OVER
    (
        PARTITION BY OrderStatus
        ORDER BY Sales DESC
    ) AS Status_Sales_Rank

FROM Sales.Orders;




48. ROWS vs RANGE
এটি advanced এবং interview-এও গুরুত্বপূর্ণ।
ROWS
ROWS physical rows নিয়ে কাজ করে।
ROWS BETWEEN
    2 PRECEDING
    AND CURRENT ROW
  
মানে:
Current row + ঠিক আগের 2 physical rows।

RANGE
RANGE logical ORDER BY value-এর ভিত্তিতে peer rows consider করতে পারে।
বিশেষ করে duplicate ORDER BY values থাকলে ROWS এবং RANGE-এর ফল আলাদা হতে পারে।







49. Simple ROWS Example
/* ============================================================
   ROWS frame
   ============================================================ */

SELECT
    OrderID,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY Sales

        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Rows_Total

FROM Sales.Orders;







50. RANGE Example
/* ============================================================
   RANGE frame

   Same Sales value-এর peer rows
   logical frame-এ একসাথে affect করতে পারে।
   ============================================================ */

SELECT
    OrderID,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY Sales

        RANGE BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Range_Total

FROM Sales.Orders;

Best Practice ⭐
Business reporting-এ যখন row-by-row deterministic cumulative calculation চান, সাধারণত explicit:
ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
ব্যবহার করা safer।






51. Deterministic Ordering
এটি খুব গুরুত্বপূর্ণ।
ধরুন:
ORDER BY Sales DESC
এবং অনেক order-এর Sales একই:
1200
1200
1200
তাহলে ROW_NUMBER() কোন order-কে 1, 2, 3 দেবে—এটি tie-breaker ছাড়া নির্ভরযোগ্যভাবে নির্ধারিত নয়।
তাই:
/* ============================================================
   Deterministic ordering
   Sales DESC = primary sorting
   OrderID = tie breaker
   ============================================================ */

SELECT
    OrderID,
    Sales,

    ROW_NUMBER() OVER
    (
        ORDER BY Sales DESC, OrderID
    ) AS rn

FROM Sales.Orders;

Best Practice
ORDER BY BusinessMetric DESC,
         UniqueKey







52. Window Function Rules
Rule 1 — WHERE-তে directly Window Function নয়
আপনার দেওয়া code:
/* ============================================================
   INVALID
   ============================================================ */

SELECT
    OrderID,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY OrderStatus
    ) AS Total_Sales

FROM Sales.Orders

WHERE SUM(Sales) OVER
(
    PARTITION BY OrderStatus
) > 100;


এটি SQL Server-এ invalid।
কেন?
SQL logical processing-এর কারণে Window Function পরে calculate হয়।
Solution:
/* ============================================================
   CORRECT
   Window calculation first,
   filtering outside
   ============================================================ */

WITH x AS
(
    SELECT
        OrderID,
        OrderStatus,
        Sales,

        SUM(Sales) OVER
        (
            PARTITION BY OrderStatus
        ) AS Total_Sales

    FROM Sales.Orders
)

SELECT *
FROM x
WHERE Total_Sales > 100;







53. Window Function Nesting
আপনার দেওয়া:
/* INVALID */

SUM
(
    SUM(Sales) OVER(...)
) OVER(...)
এভাবে সরাসরি Window Function nest করা যায় না।
Wrong
SELECT
    SUM
    (
        SUM(Sales) OVER(PARTITION BY OrderStatus)
    ) OVER()

FROM Sales.Orders;


Correct — CTE ব্যবহার করুন
/* ============================================================
   STEP 1: First Window Calculation
   ============================================================ */

WITH x AS
(
    SELECT
        OrderID,
        OrderStatus,
        Sales,

        SUM(Sales) OVER
        (
            PARTITION BY OrderStatus
        ) AS Status_Total

    FROM Sales.Orders
)

/* ============================================================
   STEP 2: Second Calculation
   ============================================================ */

SELECT
    *,
    SUM(Status_Total) OVER() AS Grand_Total

FROM x;





54. Window Syntax Master Template
এই template-টি মুখস্থ করার দরকার নেই, বোঝা দরকার:
FUNCTION(Column)
OVER
(
    PARTITION BY Column1, Column2

    ORDER BY Column3, Column4

    ROWS BETWEEN
        Start_Point
        AND
        End_Point
)
সব অংশ সবসময় লাগবে না।

  
Basic
SUM(Sales) OVER()
Partition
SUM(Sales) OVER
(
    PARTITION BY ProductID
)
Ordered
SUM(Sales) OVER
(
    ORDER BY OrderDate
)
Full
SUM(Sales) OVER
(
    PARTITION BY ProductID

    ORDER BY OrderDate

    ROWS BETWEEN
        2 PRECEDING
        AND CURRENT ROW
)








55. Real Business Example — Customer Ranking
/* ============================================================
   Business Problem:
   কোন customer সবচেয়ে বেশি sales করেছে?
   ============================================================ */

SELECT
    c.CustomerID,
    c.CustomerName,

    SUM(o.Sales) AS Total_Sales,

    RANK() OVER
    (
        ORDER BY SUM(o.Sales) DESC
    ) AS Customer_Rank

FROM Sales.Customers c

INNER JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID

GROUP BY
    c.CustomerID,
    c.CustomerName

ORDER BY Customer_Rank;






56. Real Business Example — Product Ranking
/* ============================================================
   Product Sales Ranking
   ============================================================ */

SELECT
    p.ProductID,
    p.ProductName,

    SUM(o.Sales) AS Total_Sales,

    RANK() OVER
    (
        ORDER BY SUM(o.Sales) DESC
    ) AS Product_Rank

FROM Sales.Products p

INNER JOIN Sales.Orders o
    ON p.ProductID = o.ProductID

GROUP BY
    p.ProductID,
    p.ProductName;





57. Real Business Example — Category Ranking
/* ============================================================
   Category Sales Ranking
   ============================================================ */

SELECT
    p.Category,

    SUM(o.Sales) AS Total_Sales,

    RANK() OVER
    (
        ORDER BY SUM(o.Sales) DESC
    ) AS Category_Rank

FROM Sales.Products p

INNER JOIN Sales.Orders o
    ON p.ProductID = o.ProductID

GROUP BY
    p.Category;






58. Real Business Example — Top 2 Products per Category
/* ============================================================
   Step 1:
   Calculate category + product sales
   ============================================================ */

WITH ProductSales AS
(
    SELECT
        p.Category,
        p.ProductID,
        p.ProductName,

        SUM(o.Sales) AS Total_Sales

    FROM Sales.Products p

    INNER JOIN Sales.Orders o
        ON p.ProductID = o.ProductID

    GROUP BY
        p.Category,
        p.ProductID,
        p.ProductName
),

/* ============================================================
   Step 2:
   Rank products within category
   ============================================================ */

RankedProducts AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            PARTITION BY Category
            ORDER BY Total_Sales DESC, ProductID
        ) AS rn

    FROM ProductSales
)

/* ============================================================
   Step 3:
   Keep Top 2
   ============================================================ */

SELECT
    Category,
    ProductID,
    ProductName,
    Total_Sales

FROM RankedProducts

WHERE rn <= 2;

এটি real-world SQL-এ অত্যন্ত গুরুত্বপূর্ণ pattern।








59. Real Business Example — Running Sales Dashboard
/* ============================================================
   Daily sales + cumulative sales
   ============================================================ */

SELECT
    OrderDate,

    SUM(Sales) AS Daily_Sales,

    SUM(SUM(Sales)) OVER
    (
        ORDER BY OrderDate
        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Running_Sales

FROM Sales.Orders

GROUP BY OrderDate

ORDER BY OrderDate;


এখানে:
GROUP BY
    ↓
Daily Sales

Window Function
    ↓
Running Sales






60. Real Business Example — 3-Day Moving Average
প্রথমে daily sales aggregate করি:
/* ============================================================
   Daily Sales + 3-Day Moving Average
   ============================================================ */

WITH DailySales AS
(
    SELECT
        OrderDate,
        SUM(Sales) AS Daily_Sales

    FROM Sales.Orders

    GROUP BY OrderDate
)

SELECT
    OrderDate,
    Daily_Sales,

    AVG(Daily_Sales) OVER
    (
        ORDER BY OrderDate

        ROWS BETWEEN
            2 PRECEDING
            AND CURRENT ROW

    ) AS Moving_3_Day_Average

FROM DailySales

ORDER BY OrderDate;





61. Real Business Example — Customer Latest Order
/* ============================================================
   Latest order per customer
   ============================================================ */

WITH x AS
(
    SELECT
        o.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate DESC, OrderID DESC
        ) AS rn

    FROM Sales.Orders o
)

SELECT
    OrderID,
    CustomerID,
    OrderDate,
    ProductID,
    Sales

FROM x

WHERE rn = 1;










62. Real Business Example — First Order per Customer
/* ============================================================
   First order per customer
   ============================================================ */

WITH x AS
(
    SELECT
        o.*,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS rn

    FROM Sales.Orders o
)

SELECT *
FROM x
WHERE rn = 1;








63. Real Business Example — Previous Order Date
/* ============================================================
   Previous order date per customer
   ============================================================ */

SELECT
    OrderID,
    CustomerID,
    OrderDate,

    LAG(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate, OrderID
    ) AS Previous_Order_Date

FROM Sales.Orders;





64. Days Between Customer Orders
/* ============================================================
   Calculate days between current and previous order
   ============================================================ */

WITH x AS
(
    SELECT
        OrderID,
        CustomerID,
        OrderDate,

        LAG(OrderDate) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS Previous_Order_Date

    FROM Sales.Orders
)

SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Previous_Order_Date,

    DATEDIFF
    (
        DAY,
        Previous_Order_Date,
        OrderDate
    ) AS Days_Between_Orders

FROM x;






65. Window Functions in Data Warehouse
Data Warehouse project-এ Window Functions অত্যন্ত গুরুত্বপূর্ণ।
Common uses:
Bronze
   ↓
Silver
   ↓
ROW_NUMBER()
   ↓
Duplicate removal
   ↓
Latest record
   ↓
Gold
বিশেষ করে:
        Deduplication
        SCD Type 2 logic
        Latest source record
        Surrogate key generation
        Fact validation
        Ranking
        Aggregation
        Customer segmentation









66. SCD Type 2-এর একটি গুরুত্বপূর্ণ Window Pattern
ধরুন একই customer-এর multiple historical records আছে।
/* ============================================================
   SCD Type 2 style:
   Latest record শনাক্ত করা
   ============================================================ */

WITH CustomerHistory AS
(
    SELECT
        CustomerID,
        CustomerName,
        Country,
        UpdatedDate,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY UpdatedDate DESC
        ) AS rn

    FROM Silver.CustomerHistory
)

SELECT
    CustomerID,
    CustomerName,
    Country,
    UpdatedDate,

    CASE
        WHEN rn = 1 THEN 1
        ELSE 0
    END AS Is_Current

FROM CustomerHistory;

এটি Data Engineering-এ অত্যন্ত গুরুত্বপূর্ণ pattern।







67. Window Function দিয়ে Duplicate Detection
/* ============================================================
   Duplicate detection
   ============================================================ */

WITH x AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            PARTITION BY CustomerID
            ORDER BY UpdatedDate DESC
        ) AS rn

    FROM CustomerSource
)

SELECT *
FROM x
WHERE rn > 1;

এখানে:
rn = 1 → Keep
rn > 1 → Duplicate/Older records







68. সবচেয়ে গুরুত্বপূর্ণ Real-World Patterns ⭐
আপনার learning priority আমি এভাবে রাখব:
  
Priority	             Topic	                Importance
🔥 1	                 OVER()	               ⭐⭐⭐⭐⭐
🔥 2	                 PARTITION BY	         ⭐⭐⭐⭐⭐
🔥 3	                 ORDER BY	             ⭐⭐⭐⭐⭐
🔥 4	                 ROW_NUMBER()	         ⭐⭐⭐⭐⭐
🔥 5	                 RANK()	               ⭐⭐⭐⭐⭐
🔥 6	                 SUM() OVER()	         ⭐⭐⭐⭐⭐
🔥 7	                 Running Total	       ⭐⭐⭐⭐⭐
🔥 8	                 LAG()	               ⭐⭐⭐⭐⭐
🔥 9	                 LEAD()	               ⭐⭐⭐⭐⭐
🔥 10	                 Top N per Group	     ⭐⭐⭐⭐⭐
🔥 11	                 Deduplication	       ⭐⭐⭐⭐⭐
🔥 12	                 Latest Record	       ⭐⭐⭐⭐⭐
🔥 13	                 GROUP BY + Window	   ⭐⭐⭐⭐⭐
🔥 14	                 AVG() OVER()	         ⭐⭐⭐⭐
🔥 15	                 Moving Average	       ⭐⭐⭐⭐
🔥 16	                 DENSE_RANK()	         ⭐⭐⭐⭐
🔥 17	                 NTILE()	             ⭐⭐⭐
🔥 18	                 FIRST_VALUE()	       ⭐⭐⭐
🔥 19	                 LAST_VALUE()	         ⭐⭐⭐
🔥 20	                 ROWS/RANGE	           ⭐⭐⭐⭐







69. সবচেয়ে গুরুত্বপূর্ণ পার্থক্যগুলো
GROUP BY vs Window
  
GROUP BY	                  Window Function
Rows collapse করে	          Rows collapse করে না
Summary তৈরি করে	          Detail + Summary
Aggregation	                Aggregation/Ranking/Comparison
Reporting summary	          Advanced analytics


Example
-- GROUP BY
SELECT
    ProductID,
    SUM(Sales)
FROM Sales.Orders
GROUP BY ProductID;
vs
-- Window
SELECT
    OrderID,
    ProductID,
    Sales,

    SUM(Sales) OVER
    (
        PARTITION BY ProductID
    ) AS Product_Total

FROM Sales.Orders;







70. একটি Full Example
একটি query-তে অনেক concept:
/* ============================================================
   FULL WINDOW FUNCTION EXAMPLE

   Customer-এর:
   - Order Sales
   - Customer Total
   - Customer Rank
   - Previous Order Sales
   - Running Customer Sales
   ============================================================ */

SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,
    o.Sales,

    /* Customer total */
    SUM(o.Sales) OVER
    (
        PARTITION BY o.CustomerID
    ) AS Customer_Total_Sales,

    /* Customer ranking */
    RANK() OVER
    (
        ORDER BY
            SUM(o.Sales) OVER
            (
                PARTITION BY o.CustomerID
            ) DESC
    ) AS Customer_Rank,

    /* Previous order */
    LAG(o.Sales) OVER
    (
        PARTITION BY o.CustomerID
        ORDER BY o.OrderDate, o.OrderID
    ) AS Previous_Order_Sales,

    /* Running customer sales */
    SUM(o.Sales) OVER
    (
        PARTITION BY o.CustomerID
        ORDER BY o.OrderDate, o.OrderID

        ROWS BETWEEN
            UNBOUNDED PRECEDING
            AND CURRENT ROW
    ) AS Customer_Running_Sales

FROM Sales.Orders o;


⚠️ তবে SQL Server-এ একই SELECT level-এ window function-এর result আরেক window function-এর ভিতরে ব্যবহার করার restriction আছে। 
  তাই production query-তে এই ধরনের nested dependency হলে CTE/subquery দিয়ে দুই ধাপে করা safer এবং সাধারণত প্রয়োজনীয়।







71. Production-Friendly Version
/* ============================================================
   STEP 1:
   Customer-level metrics
   ============================================================ */

WITH CustomerMetrics AS
(
    SELECT
        o.*,

        SUM(Sales) OVER
        (
            PARTITION BY CustomerID
        ) AS Customer_Total_Sales,

        LAG(Sales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS Previous_Order_Sales,

        SUM(Sales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND CURRENT ROW
        ) AS Customer_Running_Sales

    FROM Sales.Orders o
)

/* ============================================================
   STEP 2:
   Rank customers
   ============================================================ */

SELECT
    *,

    RANK() OVER
    (
        ORDER BY Customer_Total_Sales DESC
    ) AS Customer_Rank

FROM CustomerMetrics;

এই approach production SQL-এ অনেক বেশি পরিষ্কার।







72. পুরো Window Functions Roadmap 🗺️
01. Aggregate Function
       ↓
02. GROUP BY
       ↓
03. OVER()
       ↓
04. PARTITION BY
       ↓
05. ORDER BY
       ↓
06. FRAME
       ↓
07. ROW_NUMBER()
       ↓
08. RANK()
       ↓
09. DENSE_RANK()
       ↓
10. NTILE()
       ↓
11. LAG()
       ↓
12. LEAD()
       ↓
13. FIRST_VALUE()
       ↓
14. LAST_VALUE()
       ↓
15. SUM() OVER()
       ↓
16. AVG() OVER()
       ↓
17. COUNT() OVER()
       ↓
18. MIN/MAX() OVER()
       ↓
19. Running Total
       ↓
20. Running Average
       ↓
21. Moving Average
       ↓
22. % of Total
       ↓
23. Previous/Next Comparison
       ↓
24. Top N per Group
       ↓
25. Deduplication
       ↓
26. Latest Record
       ↓
27. CTE + Window
       ↓
28. JOIN + Window
       ↓
29. CASE + Window
       ↓
30. ROWS vs RANGE
       ↓
31. Deterministic Ordering
       ↓
32. Real-world Analytics
       ↓
33. Data Warehouse / ETL








73. সবচেয়ে গুরুত্বপূর্ণ 10টি 
যদি SQL Server-এ Data Analyst + Data Engineer হিসেবে job-ready হতে চান, প্রথমে এগুলো খুব শক্ত করুন:
1. OVER()
2. PARTITION BY
3. ORDER BY
4. ROW_NUMBER()
5. RANK()
6. SUM() OVER()
7. Running Total
8. LAG()
9. LEAD()
10. Top N / Deduplication / Latest Record

  
বিশেষ করে এই ৫টি pattern বারবার practice করুন:
-- 1. Partition Total
SUM(Sales) OVER
(
    PARTITION BY CustomerID
)

-- 2. Ranking
ROW_NUMBER() OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate DESC
)

-- 3. Running Total
SUM(Sales) OVER
(
    ORDER BY OrderDate
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)

-- 4. Previous Value
LAG(Sales) OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate
)

-- 5. Top N per Group
ROW_NUMBER() OVER
(
    PARTITION BY Category
    ORDER BY Sales DESC
)


