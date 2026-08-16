1. NULL কী?
NULL মানে:
Unknown / Missing / Not Available

এটি 0 নয়।
এটি '' empty string-ও নয়।
এটি ' ' blank space-ও নয়।
/* ============================================================================
   NULL BASICS

   NULL != 0
   NULL != ''
   NULL != ' '
============================================================================ */

SELECT
    NULL AS NullValue,
    0 AS ZeroValue,
    '' AS EmptyString,
    ' ' AS BlankSpace;




2. TASK 1 — NULL Handle করার সময় Aggregation
মূল code:
AVG(Score)
AVG() নিজে থেকেই NULL বাদ দেয়।
/* ============================================================================
   TASK 1:
   Compare:
   - Original Score
   - NULL replaced by 0
   - AVG ignoring NULL
   - AVG treating NULL as 0
============================================================================ */

SELECT
    CustomerID,
    Score,

    -- NULL হলে 0 দেখাবে
    COALESCE(Score, 0) AS Score2,

    -- AVG automatically ignores NULL
    AVG(Score) OVER () AS AvgScores,

    -- এখানে NULL কে 0 ধরে average করা হচ্ছে
    AVG(COALESCE(Score, 0)) OVER () AS AvgScores2

FROM Sales.Customers;


গুরুত্বপূর্ণ পার্থক্য
ধরা যাক:
80
90
NULL
70
AVG(Score):
(80 + 90 + 70) / 3
= 80

  
কিন্তু:
AVG(COALESCE(Score,0))
হবে:
(80 + 90 + 0 + 70) / 4
= 60

  
⚠️ Business Logic
NULL → 0 করা সবসময় সঠিক নয়।
NULL = customer has no score
0 = customer scored zero
দুটো business meaning আলাদা।








3. COALESCE()
COALESCE() প্রথম non-NULL value return করে।
/* ============================================================================
   COALESCE()

   Return the first non-NULL value.
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,

    COALESCE(LastName, 'Unknown') AS LastName_Cleaned,

    COALESCE(
        Email,
        'No Email Available'
    ) AS Email_Cleaned

FROM Sales.Customers;


Real-world ETL
/* ============================================================================
   DATA ENGINEERING EXAMPLE

   Create standardized customer attributes.
============================================================================ */

SELECT
    CustomerID,

    COALESCE(FirstName, 'Unknown') AS FirstName,

    COALESCE(LastName, 'Unknown') AS LastName,

    COALESCE(City, 'Unknown') AS City,

    COALESCE(Country, 'Unknown') AS Country

FROM Sales.Customers;








4. ISNULL()
SQL Server-specific function।
/* ============================================================================
   ISNULL()

   SQL Server-specific NULL replacement function.
============================================================================ */

SELECT
    CustomerID,
    Score,

    ISNULL(Score, 0) AS Score_Cleaned

FROM Sales.Customers;


COALESCE vs ISNULL
  
Feature	           COALESCE	      ISNULL
SQL Standard	     ✅	           ❌
SQL Server	       ✅	           ✅
Multiple values	   ✅	           ❌
2 values	         ✅	           ✅
Portability	       ⭐⭐⭐⭐⭐	  ⭐⭐⭐
 
-- COALESCE
SELECT COALESCE(NULL, NULL, 100);

-- ISNULL
SELECT ISNULL(NULL, 100);
Best Practice
SQL Server-only code:
ISNULL()
সহজ এবং readable।
Cross-platform SQL:
COALESCE()
ব্যবহার করা ভালো।






5. TASK 2 — NULL + Mathematical Operators
/* ============================================================================
   TASK 2:
   - Build full customer name
   - Add 10 bonus points
   - Handle NULL values
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,

    -- NULL LastName হলে পুরো expression NULL হয়ে যেত।
    -- তাই COALESCE ব্যবহার করা হয়েছে।
    FirstName + ' ' + COALESCE(LastName, '') AS FullName,

    Score,

    -- NULL Score হলে 10 যোগ করলে NULL হবে।
    -- তাই আগে NULL কে 0 করা হয়েছে।
    COALESCE(Score, 0) + 10 AS ScoreWithBonus

FROM Sales.Customers;


কেন?
এটি:
Score + 10
যদি:
Score = NULL
তাহলে:
NULL + 10 = NULL
কিন্তু:
COALESCE(Score,0) + 10
হলে:
0 + 10 = 10





6. NULL + Arithmetic
/* ============================================================================
   NULL + ARITHMETIC

   Any arithmetic operation involving NULL normally returns NULL.
============================================================================ */

SELECT
    10 + NULL AS Addition,
    10 - NULL AS Subtraction,
    10 * NULL AS Multiplication,
    10 / NULL AS Division;

Result:
NULL
NULL
NULL
NULL





7. TASK 3 — NULL Sorting
SQL Server-এ সাধারণ ascending order-এ NULL সাধারণত শুরুতে আসে।
আমরা চাই:
Lowest Score
...
Highest Score
NULL
/* ============================================================================
   TASK 3:
   Sort customers from lowest score to highest score
   while keeping NULL values at the bottom.
============================================================================ */

SELECT
    CustomerID,
    Score

FROM Sales.Customers

ORDER BY
    CASE
        WHEN Score IS NULL THEN 1
        ELSE 0
    END,
    Score;

⭐ Best Practice
NULL-last sorting-এর জন্য:
ORDER BY
    CASE WHEN ColumnName IS NULL THEN 1 ELSE 0 END,
    ColumnName;
খুব practical pattern।



  


8. TASK 4 — NULLIF() দিয়ে Division by Zero
প্রথমে বিপজ্জনক query:
/* ============================================================================
   DO NOT USE THIS VERSION WHEN Quantity CAN BE ZERO
============================================================================ */

-- SELECT
--     OrderID,
--     Sales,
--     Quantity,
--     Sales / Quantity AS Price
-- FROM Sales.Orders;
Quantity = 0 হলে error হবে:
Divide by zero error encountered.

  
সঠিক পদ্ধতি
/* ============================================================================
   TASK 4:
   NULLIF converts Quantity = 0 into NULL.

   Therefore:
       Sales / NULL = NULL

   instead of:
       Sales / 0 = ERROR
============================================================================ */

SELECT
    OrderID,
    Sales,
    Quantity,

    Sales / NULLIF(Quantity, 0) AS Price

FROM Sales.Orders;





9. NULLIF() কী করে?
NULLIF(expression1, expression2)
যদি দুই value equal হয়:
NULL
অন্যথায়:
expression1
উদাহরণ:
/* ============================================================================
   NULLIF() BASIC EXAMPLES
============================================================================ */

SELECT
    NULLIF(10, 10) AS Example1,
    NULLIF(10, 20) AS Example2,
    NULLIF(0, 0) AS Example3;


Result:
Example1 = NULL
Example2 = 10
Example3 = NULL






10. TASK 5 — IS NULL
/* ============================================================================
   TASK 5:
   Find customers whose score is missing.
============================================================================ */

SELECT
    *

FROM Sales.Customers

WHERE Score IS NULL;


⚠️ ভুল
-- ভুল
WHERE Score = NULL;
এটি কাজ করবে না।
কারণ:
NULL = NULL
SQL-এ TRUE নয়।




11. TASK 6 — IS NOT NULL
/* ============================================================================
   TASK 6:
   Find customers who have a score.
============================================================================ */

SELECT
    *

FROM Sales.Customers

WHERE Score IS NOT NULL;





12. NULL + WHERE
NULL-এর ক্ষেত্রে তিন-valued logic গুরুত্বপূর্ণ:
TRUE
FALSE
UNKNOWN
  
উদাহরণ:
/* ============================================================================
   NULL + WHERE
============================================================================ */

SELECT
    CustomerID,
    Score

FROM Sales.Customers

WHERE Score > 80;


Score = NULL হলে:
NULL > 80
ফল:
UNKNOWN
WHERE শুধু TRUE rows রাখে।







13. TASK 7 — LEFT ANTI JOIN
যেসব customer কোনো order করেনি তাদের বের করতে:
/* ============================================================================
   TASK 7:
   LEFT ANTI JOIN

   Find customers who have NOT placed any orders.
============================================================================ */

SELECT
    c.*,
    o.OrderID

FROM Sales.Customers AS c

LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID

WHERE o.CustomerID IS NULL;


Logic
Customers
    |
    LEFT JOIN
    |
Orders
    |
WHERE Orders.CustomerID IS NULL
অর্থাৎ:
Customer আছে, কিন্তু matching order নেই।





14. LEFT ANTI JOIN — Better Version
/* ============================================================================
   BEST PRACTICE:
   NOT EXISTS is often clearer for anti-join logic.
============================================================================ */

SELECT
    c.*

FROM Sales.Customers AS c

WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);


JOIN vs NOT EXISTS
Method	                 Use
LEFT JOIN ... IS NULL	   সহজে বোঝা যায়
NOT EXISTS	             Anti-semi join-এর জন্য excellent
NOT IN	                 NULL থাকলে dangerous







15. NULL + NOT IN — Dangerous Problem ⚠️
ধরা যাক আমরা customers খুঁজছি যাদের ID order table-এ নেই।
/* ============================================================================
   NULL + NOT IN PROBLEM

   If the subquery contains NULL, NOT IN can produce unexpected results.
============================================================================ */

SELECT
    *

FROM Sales.Customers

WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM Sales.Orders
);


আমাদের Orders table-এ আছে:
CustomerID = NULL
তাই subquery:
1
2
3
...
19
NULL

  
এখন:
CustomerID NOT IN (1,2,3,...,19,NULL)
NULL-এর কারণে comparison UNKNOWN হতে পারে।
ফলে expected rows নাও পাওয়া যেতে পারে।







16. NOT EXISTS — Recommended
/* ============================================================================
   RECOMMENDED SOLUTION

   NOT EXISTS handles NULL safely for this anti-join pattern.
============================================================================ */

SELECT
    c.*

FROM Sales.Customers AS c

WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);


⭐ Data Engineering Best Practice
Anti-join requirement হলে সাধারণত:
NOT EXISTS
একটি শক্তিশালী এবং নিরাপদ choice।





17. NULL + JOIN Behavior
/* ============================================================================
   NULL + JOIN

   NULL does not equal NULL in a normal equality JOIN.
============================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID

FROM Sales.Customers AS c

LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID;


যেখানে:
c.CustomerID = NULL
এবং
o.CustomerID = NULL
  
থাকলেও:
NULL = NULL
matching condition হয় না।




18. NULL + GROUP BY
GROUP BY-তে সব NULL value একটি group হিসেবে আসে।
/* ============================================================================
   NULL + GROUP BY

   All NULL scores are grouped together.
============================================================================ */

SELECT
    Score,
    COUNT(*) AS CustomerCount

FROM Sales.Customers

GROUP BY Score

ORDER BY Score;


আপনি একটি row পাবেন:
Score = NULL
CustomerCount = ...






19. NULL + COUNT()
এখানে খুব গুরুত্বপূর্ণ difference আছে।
/* ============================================================================
   NULL + COUNT()

   COUNT(*) counts rows.
   COUNT(Score) counts only non-NULL Score values.
============================================================================ */

SELECT
    COUNT(*) AS TotalCustomers,

    COUNT(Score) AS CustomersWithScore,

    COUNT(*) - COUNT(Score) AS CustomersWithoutScore

FROM Sales.Customers;


⭐ খুব গুরুত্বপূর্ণ
COUNT(*)
→ সব row
COUNT(Score)
→ শুধু non-NULL Score






20. NULL + SUM()
/* ============================================================================
   NULL + SUM()

   SUM ignores NULL values.
============================================================================ */

SELECT
    SUM(Sales) AS TotalSales,

    SUM(COALESCE(Sales, 0)) AS TotalSales_WithZero

FROM Sales.Orders;


দুই result সাধারণত একই হবে।
কারণ SUM() নিজেই NULL ignore করে।








21. NULL + AVG()
/* ============================================================================
   NULL + AVG()

   AVG ignores NULL values.
============================================================================ */

SELECT
    AVG(Sales) AS AverageSales,

    AVG(COALESCE(Sales, 0)) AS AverageSales_WithZero

FROM Sales.Orders;


⚠️ এখানে result আলাদা হতে পারে।
কারণ:
AVG(Sales)
NULL বাদ দেয়।
  
কিন্তু:
AVG(COALESCE(Sales,0))
NULL-কে 0 হিসেবে গণনা করে।







22. NULL + HAVING
/* ============================================================================
   NULL + HAVING

   Find customers whose total sales are greater than 500.
============================================================================ */

SELECT
    CustomerID,
    SUM(Sales) AS TotalSales

FROM Sales.Orders

GROUP BY CustomerID

HAVING SUM(Sales) > 500;

এখানে SUM() NULL values ignore করবে।






23. CASE + NULL
/* ============================================================================
   CASE + NULL

   Categorize customers based on score.
============================================================================ */

SELECT
    CustomerID,
    Score,

    CASE
        WHEN Score IS NULL THEN 'Not Rated'
        WHEN Score >= 90 THEN 'Excellent'
        WHEN Score >= 80 THEN 'Good'
        WHEN Score >= 70 THEN 'Average'
        ELSE 'Low'
    END AS ScoreCategory

FROM Sales.Customers;


⭐ Best Practice
NULL-এর জন্য explicit branch রাখুন:
WHEN Score IS NULL THEN 'Not Rated'
এতে business logic পরিষ্কার হয়।





24. NULL + CONCAT()
SQL Server-এর CONCAT() NULL-কে empty string হিসেবে treat করে।
/* ============================================================================
   NULL + CONCAT()

   CONCAT safely handles NULL values.
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,

    CONCAT(
        FirstName,
        ' ',
        LastName
    ) AS FullName

FROM Sales.Customers;


যদি:
FirstName = Sarah
LastName = NULL
তাহলে:
Sarah
পাওয়া যাবে।






25. NULL + CONCAT_WS()
CONCAT_WS() separator ব্যবহার করে।
/* ============================================================================
   CONCAT_WS()

   WS = With Separator
============================================================================ */

SELECT
    CustomerID,

    CONCAT_WS(
        ' ',
        FirstName,
        LastName
    ) AS FullName

FROM Sales.Customers;

এটি customer full name তৈরিতে খুব useful।






26. CONCAT বনাম +
/* ============================================================================
   STRING CONCATENATION COMPARISON
============================================================================ */

SELECT
    CustomerID,

    -- NULL LastName হলে পুরো expression NULL হতে পারে
    FirstName + ' ' + LastName AS PlusMethod,

    -- NULL safely handled
    CONCAT(FirstName, ' ', LastName) AS ConcatMethod,

    -- Separator-based concatenation
    CONCAT_WS(' ', FirstName, LastName) AS ConcatWSMethod

FROM Sales.Customers;







27. NULL + DISTINCT
DISTINCT-এ multiple NULL একটি unique value হিসেবে গণ্য হয়।
/* ============================================================================
   NULL + DISTINCT
============================================================================ */

SELECT DISTINCT
    Score

FROM Sales.Customers

ORDER BY Score;

একাধিক customer-এর Score NULL হলেও:
NULL
একবারই দেখাবে।






28. NULL + UNIQUE Constraint
SQL Server-এ single-column UNIQUE constraint সাধারণভাবে একটি NULL value allow করে।
Practice:
/* ============================================================================
   UNIQUE CONSTRAINT + NULL

   Demonstration table
============================================================================ */

CREATE TABLE Sales.CustomerEmails
(
    CustomerID INT PRIMARY KEY,
    Email VARCHAR(100) NULL,

    CONSTRAINT UQ_CustomerEmails_Email
        UNIQUE (Email)
);
GO
/* ============================================================================
   INSERT DATA
============================================================================ */

INSERT INTO Sales.CustomerEmails
VALUES
(1, 'john@email.com'),
(2, NULL);
GO

  
কিন্তু একই column-এ দ্বিতীয় NULL insert করার সময় SQL Server-এর unique constraint behavior লক্ষ্য করা গুরুত্বপূর্ণ।
/* ============================================================================
   TEST

   This demonstrates SQL Server's UNIQUE constraint behavior
   with NULL values.
============================================================================ */

-- INSERT INTO Sales.CustomerEmails
-- VALUES (3, NULL);
⭐ Best Practice
Business rule যদি হয়:
Email থাকলে unique হতে হবে, কিন্তু NULL multiple rows allowed।

তাহলে Filtered Unique Index বেশি উপযোগী।






29. Filtered Unique Index + NULL
/* ============================================================================
   FILTERED UNIQUE INDEX

   Only non-NULL email values must be unique.

   Multiple NULL values are allowed because NULL rows are excluded.
============================================================================ */

DROP TABLE Sales.CustomerEmails;
GO

CREATE TABLE Sales.CustomerEmails
(
    CustomerID INT PRIMARY KEY,
    Email VARCHAR(100) NULL
);
GO

CREATE UNIQUE INDEX UX_CustomerEmails_Email
ON Sales.CustomerEmails(Email)
WHERE Email IS NOT NULL;
GO
এখন:
/* ============================================================================
   MULTIPLE NULL VALUES ARE ALLOWED
============================================================================ */

INSERT INTO Sales.CustomerEmails
VALUES
(1, 'john@email.com'),
(2, NULL),
(3, NULL),
(4, 'sarah@email.com');
GO
এটি real-world customer table-এ খুব useful pattern।






30. NULL + Filtered Index
শুধু non-NULL rows দ্রুত query করার প্রয়োজন হলে:
/* ============================================================================
   FILTERED INDEX FOR NON-NULL SCORES

   Useful when queries frequently search only customers
   who already have a score.
============================================================================ */

CREATE INDEX IX_Customers_Score_NotNull
ON Sales.Customers(Score)
WHERE Score IS NOT NULL;
GO
Query:
/* ============================================================================
   QUERY USING THE FILTERED INDEX
============================================================================ */

SELECT
    CustomerID,
    Score

FROM Sales.Customers

WHERE Score IS NOT NULL
  AND Score >= 90;






31. NULL + Window Function
এখন customer order history থেকে previous sales বের করি।
/* ============================================================================
   NULL + LAG()

   LAG returns the previous order's Sales value.

   For the first order of each customer:
   PreviousSales = NULL
============================================================================ */

SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS PreviousSales

FROM Sales.Orders;








32. LAG() + NULL Business Logic
Previous sales না থাকলে:
NULL
এটাই logically correct।
কিন্তু report-এ আমরা চাইলে:
/* ============================================================================
   LAG() + COALESCE()

   Replace missing previous sales with 0 for reporting purposes.
============================================================================ */

SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS PreviousSales,

    COALESCE
    (
        LAG(Sales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ),
        0
    ) AS PreviousSales_Reporting

FROM Sales.Orders;

⚠️ তবে analytical calculation-এ NULL → 0 করার আগে business meaning যাচাই করতে হবে।






33. NULL + Sales Growth
/* ============================================================================
   BUSINESS ANALYSIS:

   Calculate sales difference from previous order.

   NULL sales should remain NULL because the previous/current
   sales value is unknown.
============================================================================ */

SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,

    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS PreviousSales,

    Sales
    -
    LAG(Sales) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS SalesDifference

FROM Sales.Orders;

এখানে NULL arithmetic naturally NULL result দেবে।






34. NULL + Data Quality — NULL vs Empty String vs Blank Space
এখন আপনার দেওয়া original example-এর concept real-world order category দিয়ে দেখানো যাক।
/* ============================================================================
   TASK 8:
   Demonstrate the difference between:

   1. NULL
   2. Empty string ''
   3. Blank spaces '  '

   DATALENGTH helps us understand the actual stored bytes.
============================================================================ */

WITH OrderStatus AS
(
    SELECT 1 AS ID, 'Completed' AS Status
    UNION ALL
    SELECT 2, NULL
    UNION ALL
    SELECT 3, ''
    UNION ALL
    SELECT 4, '  '
)
SELECT
    ID,
    Status,

    DATALENGTH(Status) AS DataLength,

    TRIM(Status) AS CleanStatus,

    NULLIF(TRIM(Status), '') AS Policy2,

    COALESCE
    (
        NULLIF(TRIM(Status), ''),
        'Unknown'
    ) AS Policy3

FROM OrderStatus;





35. এই Logic কী করছে?
সবচেয়ে গুরুত্বপূর্ণ অংশ:
NULLIF(TRIM(Status), '')
ধাপে ধাপে:
Input
'Completed'
NULL
''
'  '
TRIM()
'Completed'
NULL
''
''
NULLIF(...,'')
'Completed'
NULL
NULL
NULL
COALESCE(...,'Unknown')
Completed
Unknown
Unknown
Unknown
  
🎯 অর্থাৎ:
Empty string এবং blank spaces-কে standardized NULL করা যায়, তারপর reporting-এর সময় Unknown দেখানো যায়।







36. Real Data Cleaning Pattern
এটি Data Engineering-এর জন্য খুব গুরুত্বপূর্ণ।
/* ============================================================================
   DATA CLEANING PATTERN

   Convert:
       NULL
       ''
       '   '

   into:
       'Unknown'
============================================================================ */

SELECT
    CustomerID,

    COALESCE(
        NULLIF(TRIM(FirstName), ''),
        'Unknown'
    ) AS FirstName_Clean,

    COALESCE(
        NULLIF(TRIM(LastName), ''),
        'Unknown'
    ) AS LastName_Clean,

    COALESCE(
        NULLIF(TRIM(City), ''),
        'Unknown'
    ) AS City_Clean,

    COALESCE(
        NULLIF(TRIM(Country), ''),
        'Unknown'
    ) AS Country_Clean

FROM Sales.Customers;








37. NULL + Aggregation + Business Logic
এখন customer-level sales report তৈরি করি।
/* ============================================================================
   BUSINESS REPORT:

   Customer-level order count and sales.

   Important:
   - COUNT(*) counts orders
   - SUM(Sales) ignores NULL
   - COALESCE converts NULL total sales to 0
============================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,

    COUNT(o.OrderID) AS OrderCount,

    SUM(o.Sales) AS TotalSales,

    COALESCE(
        SUM(o.Sales),
        0
    ) AS TotalSales_Clean

FROM Sales.Customers AS c

LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID

GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName;







38. NULL + JOIN + Aggregation
Customer order না থাকলেও customer যেন report-এ থাকে:
/* ============================================================================
   LEFT JOIN is important.

   INNER JOIN would remove customers without orders.
============================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,

    COUNT(o.OrderID) AS TotalOrders,

    COALESCE(
        SUM(o.Sales),
        0
    ) AS TotalSales

FROM Sales.Customers AS c

LEFT JOIN Sales.Orders AS o
    ON c.CustomerID = o.CustomerID

GROUP BY
    c.CustomerID,
    c.FirstName;


কেন COUNT(o.OrderID)?
LEFT JOIN-এর unmatched row-এ:
o.OrderID = NULL
তাই:
COUNT(o.OrderID)
= 0
এটি:
COUNT(*)
এর থেকে আলাদা।







39. COUNT(*) বনাম COUNT(Column)
/* ============================================================================
   IMPORTANT COUNT COMPARISON
============================================================================ */

SELECT
    COUNT(*) AS CountAllRows,

    COUNT(CustomerID) AS CountCustomerID,

    COUNT(Score) AS CountScores

FROM Sales.Customers;

Rule
COUNT(*)       → rows
COUNT(column)  → non-NULL values






40. NULL + WHERE vs HAVING
/* ============================================================================
   WHERE filters rows BEFORE GROUPING.
   HAVING filters groups AFTER GROUPING.
============================================================================ */

SELECT
    CustomerID,
    SUM(Sales) AS TotalSales

FROM Sales.Orders

WHERE Sales IS NOT NULL

GROUP BY CustomerID

HAVING SUM(Sales) > 300;


এখানে:
WHERE → NULL sales বাদ দেয়
GROUP BY → customer অনুযায়ী group
SUM() → sales total
HAVING → total > 300






41. NULL Data Profiling
Data Engineer হিসেবে NULL percentage বের করা খুব গুরুত্বপূর্ণ।
/* ============================================================================
   DATA QUALITY CHECK:

   Calculate NULL percentage for Customer Score.
============================================================================ */

SELECT
    COUNT(*) AS TotalCustomers,

    COUNT(Score) AS NonNullScores,

    COUNT(*) - COUNT(Score) AS NullScores,

    CAST
    (
        100.0 *
        (COUNT(*) - COUNT(Score))
        / COUNT(*)
        AS DECIMAL(5,2)
    ) AS NullPercentage

FROM Sales.Customers;

এটি production data-quality monitoring-এর খুব common pattern।







42. Multiple Columns-এর NULL Profiling
/* ============================================================================
   DATA QUALITY PROFILING

   Check NULL percentage for important customer attributes.
============================================================================ */

SELECT
    COUNT(*) AS TotalRows,

    SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END) AS NullEmail,

    SUM(CASE WHEN LastName IS NULL THEN 1 ELSE 0 END) AS NullLastName,

    SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS NullCity,

    SUM(CASE WHEN Score IS NULL THEN 1 ELSE 0 END) AS NullScore

FROM Sales.Customers;





43. NULL + CASE + Data Quality Flag
/* ============================================================================
   DATA QUALITY FLAG

   Identify customers with missing important information.
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Score,

    CASE
        WHEN Email IS NULL
             AND Score IS NULL
            THEN 'Critical Missing Data'

        WHEN Email IS NULL
            THEN 'Missing Email'

        WHEN Score IS NULL
            THEN 'Missing Score'

        ELSE 'Complete'

    END AS DataQualityStatus

FROM Sales.Customers;






44. NULL + COALESCE + CASE
/* ============================================================================
   CUSTOMER SEGMENTATION

   NULL scores are classified separately.
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    Score,

    CASE
        WHEN Score IS NULL
            THEN 'Unrated'

        WHEN Score >= 90
            THEN 'VIP'

        WHEN Score >= 80
            THEN 'Regular'

        ELSE 'Low Engagement'
    END AS CustomerSegment

FROM Sales.Customers;







45. NULL + ORDER BY Business Logic
/* ============================================================================
   BUSINESS REPORT:

   VIP/high scores first,
   NULL scores last.
============================================================================ */

SELECT
    CustomerID,
    FirstName,
    Score

FROM Sales.Customers

ORDER BY
    CASE
        WHEN Score IS NULL THEN 1
        ELSE 0
    END,

    Score DESC;







46. NULL + DISTINCT + Data Cleaning
/* ============================================================================
   BEFORE CLEANING
============================================================================ */

SELECT DISTINCT
    LastName

FROM Sales.Customers;
তারপর standardized:
/* ============================================================================
   AFTER CLEANING

   NULL, empty and whitespace-only values can be standardized.
============================================================================ */

SELECT DISTINCT

    COALESCE(
        NULLIF(TRIM(LastName), ''),
        'Unknown'
    ) AS CleanLastName

FROM Sales.Customers;






47. NULL + LEFT JOIN + Missing Dimension
একটি বাস্তব Data Warehouse scenario:
/* ============================================================================
   FIND ORDERS WHERE CUSTOMER INFORMATION IS MISSING

   This is useful as a data-quality check before loading a fact table.
============================================================================ */

SELECT
    o.OrderID,
    o.CustomerID,
    o.Sales

FROM Sales.Orders AS o

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID

WHERE c.CustomerID IS NULL;
এখানে OrderID = 1030-এর মতো record পাওয়া যাবে, যেখানে:
Order exists
Customer does not exist
এটি ETL pipeline-এ গুরুত্বপূর্ণ data-quality issue।







48. NULL + COALESCE + Default Dimension
Data Warehouse-এ অনেক সময় missing customer-এর জন্য Unknown Customer ব্যবহার করা হয়।
/* ============================================================================
   DATA WAREHOUSE REPORTING PATTERN

   Missing customer is represented as "Unknown Customer".
============================================================================ */

SELECT
    o.OrderID,

    COALESCE(
        c.FirstName + ' ' + c.LastName,
        'Unknown Customer'
    ) AS CustomerName,

    o.Sales

FROM Sales.Orders AS o

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID;
আরও robust version:
/* ============================================================================
   ROBUST VERSION

   CONCAT handles NULL names safely.
============================================================================ */

SELECT
    o.OrderID,

    COALESCE(
        NULLIF(
            CONCAT_WS(' ', c.FirstName, c.LastName),
            ''
        ),
        'Unknown Customer'
    ) AS CustomerName,

    o.Sales

FROM Sales.Orders AS o

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID;






49. NULL + Mathematical Business Calculation
Average order value:
/* ============================================================================
   BUSINESS KPI:

   Average Sales per Unit

   NULLIF prevents division by zero.
============================================================================ */

SELECT
    OrderID,
    Sales,
    Quantity,

    Sales / NULLIF(Quantity, 0) AS SalesPerUnit

FROM Sales.Orders;







50. NULL + CASE + Division
/* ============================================================================
   BUSINESS KPI WITH DATA QUALITY STATUS
============================================================================ */

SELECT
    OrderID,
    Sales,
    Quantity,

    CASE
        WHEN Sales IS NULL
            THEN 'Missing Sales'

        WHEN Quantity IS NULL
            THEN 'Missing Quantity'

        WHEN Quantity = 0
            THEN 'Invalid Quantity'

        ELSE 'Valid'
    END AS DataQualityStatus,

    CASE
        WHEN Sales IS NULL
             OR Quantity IS NULL
             OR Quantity = 0
            THEN NULL

        ELSE Sales / Quantity
    END AS UnitPrice

FROM Sales.Orders;

এটি production reporting-এর জন্য খুব পরিষ্কার approach।







51. NULL + NOT EXISTS Data Quality Check
/* ============================================================================
   FIND ORDERS WITH INVALID CUSTOMER REFERENCES

   CustomerID NULL অথবা customer table-এ customer নেই।
============================================================================ */

SELECT
    o.*

FROM Sales.Orders AS o

WHERE o.CustomerID IS NULL

   OR NOT EXISTS
   (
       SELECT 1
       FROM Sales.Customers AS c
       WHERE c.CustomerID = o.CustomerID
   );





52. NULL + Window Aggregate
Window function-এর সাথে NULL behavior:
/* ============================================================================
   WINDOW AGGREGATION

   SUM(Sales) OVER() ignores NULL Sales values.
============================================================================ */

SELECT
    OrderID,
    Sales,

    SUM(Sales) OVER () AS TotalSales,

    AVG(Sales) OVER () AS AverageSales

FROM Sales.Orders;






53. NULL + Running Total
/* ============================================================================
   RUNNING TOTAL

   NULL Sales values do not contribute to SUM().
============================================================================ */

SELECT
    OrderID,
    OrderDate,
    Sales,

    SUM(Sales) OVER
    (
        ORDER BY OrderDate, OrderID
        ROWS BETWEEN UNBOUNDED PRECEDING
                 AND CURRENT ROW
    ) AS RunningSales

FROM Sales.Orders;






54. NULL + LAG + COALESCE + Business Logic
/* ============================================================================
   COMPLETE ANALYTICAL EXAMPLE

   Compare current sales with previous order.

   NULL previous sales means there is no previous order.
============================================================================ */

WITH SalesAnalysis AS
(
    SELECT
        CustomerID,
        OrderID,
        OrderDate,
        Sales,

        LAG(Sales) OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate
        ) AS PreviousSales

    FROM Sales.Orders
)
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    Sales,
    PreviousSales,

    CASE
        WHEN PreviousSales IS NULL
            THEN 'First Order / No Previous Sales'

        WHEN Sales IS NULL
            THEN 'Current Sales Missing'

        WHEN Sales > PreviousSales
            THEN 'Sales Increased'

        WHEN Sales < PreviousSales
            THEN 'Sales Decreased'

        ELSE 'No Change'
    END AS SalesTrend

FROM SalesAnalysis;







55. Complete NULL Handling Pipeline
একটি বাস্তব ETL-style pattern:
/* ============================================================================
   END-TO-END NULL HANDLING PATTERN

   Step 1:
       Detect NULL

   Step 2:
       Normalize empty strings / spaces

   Step 3:
       Apply business default

   Step 4:
       Calculate metrics safely

   Step 5:
       Create data-quality status
============================================================================ */

SELECT
    o.OrderID,

    -- Customer ID
    COALESCE(
        CAST(o.CustomerID AS VARCHAR(20)),
        'Unknown'
    ) AS CustomerID_Clean,

    -- Sales
    o.Sales,

    -- Quantity
    o.Quantity,

    -- Safe Unit Price
    o.Sales / NULLIF(o.Quantity, 0) AS UnitPrice,

    -- Data Quality
    CASE
        WHEN o.CustomerID IS NULL
            THEN 'Missing Customer'

        WHEN o.Sales IS NULL
            THEN 'Missing Sales'

        WHEN o.Quantity IS NULL
            THEN 'Missing Quantity'

        WHEN o.Quantity = 0
            THEN 'Invalid Quantity'

        ELSE 'Valid'
    END AS DataQualityStatus

FROM Sales.Orders AS o;







56. Final NULL Handling Cheat Sheet 🧠
  
Function / Concept	            কাজ	                            Real-world Use
COALESCE()	                    প্রথম non-NULL value	              Data cleaning
ISNULL()	                      NULL replace	SQL                 Server-specific
NULLIF()	                      equal হলে NULL	                  Division by zero
IS NULL	                        NULL খোঁজা	                      Missing data
IS NOT NULL	                    Non-NULL খোঁজা	                  Valid data
COUNT(*)	                      সব rows	                          Row count
COUNT(column)	                  Non-NULL values	Data              completeness
SUM()	                          NULL ignore করে	                  Revenue
AVG()	                          NULL ignore করে	                  KPI
GROUP BY	                      NULL এক group	                  Profiling
HAVING	                        Group filter	                    Aggregation filtering
CASE	                          NULL business logic	              Segmentation
CONCAT()	                      NULL-safe concatenation	          Full name
CONCAT_WS()	                    Separator সহ concatenation	      Address/name
LAG()	                          Previous row	                    Trend analysis
LEFT JOIN ... IS NULL	          Anti join	                        Missing relationships
NOT EXISTS	                    Safe anti join	                  ETL validation
NOT IN	⚠️                      NULL থাকলে সমস্যা	                Avoid when nullable
DISTINCT	                      NULL একবার দেখায়	                Deduplication
Filtered Index	                নির্দিষ্ট rows index	                  Performance
UNIQUE	                        Duplicate prevent	                Data integrity








57. Data Analyst + Data Engineer-এর জন্য সবচেয়ে গুরুত্বপূর্ণ Best Practices ⭐
🟢 1. NULL আর 0 এক করবেন না
COALESCE(Score, 0)
শুধু তখনই ব্যবহার করুন যখন business logic অনুযায়ী:
NULL = 0
সত্যি।
  
🟢 2. Division করার সময় NULLIF() ব্যবহার করুন
Sales / NULLIF(Quantity, 0)
এটি production SQL-এ অত্যন্ত useful।
  
🟢 3. Nullable column-এ NOT IN সাবধানে ব্যবহার করুন
❌ Risky:
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM Sales.Orders
)
  
✅ Better:
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders o
    WHERE o.CustomerID = c.CustomerID
)
  
🟢 4. String cleaning-এ এই pattern মনে রাখুন
COALESCE(
    NULLIF(TRIM(ColumnName), ''),
    'Unknown'
)
এটি:
NULL
''
'   '
কে standardize করতে খুব useful।
  
🟢 5. COUNT-এর difference মনে রাখুন
COUNT(*)
→ সব rows
COUNT(Column)
→ শুধু non-NULL values
  
🟢 6. Aggregation-এর আগে business meaning বুঝুন
AVG(Score)
এবং:
AVG(COALESCE(Score, 0))
একই query নয়।
প্রথমটি:
Missing score বাদ দেয়।

দ্বিতীয়টি:
Missing score-কে zero ধরে।

  
🟢 7. Data Warehouse-এ NULL handling আলাদা করে design করুন
Bronze:
Raw NULL
Silver:
Clean / Standardized NULL
Gold:
Business-friendly Unknown / Default
উদাহরণ:
Bronze:
LastName = NULL

        ↓

Silver:
LastName = NULL

        ↓

Gold:
LastName = 'Unknown'
এতে raw data হারিয়ে যায় না এবং reporting layer business-friendly থাকে।






🎯 এই অধ্যায়ের Core SQL Pattern
সবচেয়ে বেশি মনে রাখার মতো ৮টি pattern:
-- 1. Replace NULL
COALESCE(ColumnName, DefaultValue)

-- 2. SQL Server NULL replacement
ISNULL(ColumnName, DefaultValue)

-- 3. Prevent division by zero
Numerator / NULLIF(Denominator, 0)

-- 4. Find NULL
WHERE ColumnName IS NULL

-- 5. Find non-NULL
WHERE ColumnName IS NOT NULL

-- 6. Clean empty/blank strings
NULLIF(TRIM(ColumnName), '')

-- 7. Safe anti-join
WHERE NOT EXISTS (...)

-- 8. NULL-safe string concatenation
CONCAT_WS(' ', FirstName, LastName)




