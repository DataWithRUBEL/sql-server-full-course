Window Value Functions
        ↓
OVER()
        ↓
PARTITION BY + ORDER BY
        ↓
Current / Previous / Next Row
        ↓
Window Frame
        ↓
ROWS vs RANGE
        ↓
LAG()
        ↓
LEAD()
        ↓
FIRST_VALUE()
        ↓
LAST_VALUE()
        ↓
NULL Handling
        ↓
Business Analysis
        ↓
Value Functions Combination
        ↓
Advanced Historical Analysis
        ↓
Data Engineering / ETL / SCD
        ↓
Performance & Execution Plan
        ↓
Real-World Projects
        ↓
Interview + 50 Practice Problems





  



🟢 PHASE 1 — Window Value Functions Fundamentals
1. Window Value Functions কী?
Window Value Function এমন function যা একটি row-এর সাথে সম্পর্কিত 
অন্য row-এর value দেখতে সাহায্য করে।
  
মূল চারটি:
LAG()
LEAD()
FIRST_VALUE()
LAST_VALUE()


সহজভাবে:
  
Function	        কী দেখে
LAG()	            Previous row
LEAD()	          Next row
FIRST_VALUE()	    Window-এর first value
LAST_VALUE()	    Window-এর last value






2. কেন ব্যবহার করবো?
ধরুন:
Month	   Sales
Jan	     1000
Feb	     1200
Mar	     900


আপনি জানতে চান:
Feb বনাম Jan = +200
Mar বনাম Feb = -300
  
Self Join না করেও:
LAG(Sales)
দিয়ে previous sales পাওয়া যায়।





  

3. Window Function বনাম Value Function
Window Function হলো বড় category।
Window Functions
│
├── Ranking
│   ├── ROW_NUMBER
│   ├── RANK
│   └── DENSE_RANK
│
├── Aggregate
│   ├── SUM
│   ├── AVG
│   └── COUNT
│
├── Value
│   ├── LAG
│   ├── LEAD
│   ├── FIRST_VALUE
│   └── LAST_VALUE







4. OVER() Clause
Window Function-এর সবচেয়ে গুরুত্বপূর্ণ অংশ:
OVER()
  
Basic:
/* ============================================================
   OVER() Basic Example
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

FROM sales.Orders;






5. PARTITION BY
PARTITION BY data-কে logical group-এ ভাগ করে।
/* ============================================================
   Customer অনুযায়ী previous order
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,
    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousOrderAmount
FROM sales.Orders;

এখানে Customer 101-এর previous order শুধু Customer 101-এর মধ্যেই খোঁজা হবে।







6. ORDER BY
ORDER BY বলে দেয়:
কোন sequence অনুযায়ী previous বা next row নির্ধারণ হবে?

LAG(TotalAmount)
OVER
(
    ORDER BY OrderDate
)
এখানে date sequence।






7. Window Definition
এই অংশটি:
PARTITION BY CustomerID
ORDER BY OrderDate, OrderID
একটি window definition।




8. Current Row
ধরুন:
100
200
300
Current row = বর্তমান row।
LAG() current row-এর আগের দিকে দেখে।
LEAD() current row-এর পরের দিকে দেখে।





9. Previous Row
LAG(TotalAmount, 1)
OVER
(
    ORDER BY OrderDate
)



  

10. Next Row
LEAD(TotalAmount, 1)
OVER
(
    ORDER BY OrderDate
)




11. Window Frame
Frame মূলত বলে:
Current row-এর জন্য window-এর কোন অংশ consider হবে?

বিশেষ করে FIRST_VALUE() এবং LAST_VALUE()-এর ক্ষেত্রে অত্যন্ত গুরুত্বপূর্ণ।






12. ROWS বনাম RANGE
Conceptually:
ROWS
→ physical row based

RANGE
→ ORDER BY value/group ভিত্তিক logical range
SQL Server-এ LAST_VALUE() শেখার সময় এটি বিশেষ গুরুত্বপূর্ণ।







🟢 PHASE 2 — LAG()
13. LAG() কী?
LAG() current row-এর আগের row-এর value ফেরত দেয়।






14. Syntax
LAG
(
    expression
    [, offset]
    [, default]
)
OVER
(
    [PARTITION BY ...]
    ORDER BY ...
)
  
উদাহরণ:
LAG(TotalAmount, 1, 0)
OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate, OrderID
)






15–16. Basic LAG + Previous Row
/* ============================================================
   Previous Order Amount
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

FROM sales.Orders;








17–18. Offset
Previous 2 rows:
/* ============================================================
   Two Orders Back
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount, 2)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS TwoOrdersBack

FROM sales.Orders;







19–20. PARTITION + ORDER BY
Customer-wise:
/* ============================================================
   Customer-wise Order Sequence
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LAG(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousOrderDate

FROM sales.Orders;







21. Default Value
First row-এ previous value থাকে না।
/* ============================================================
   Default Value = 0
   ============================================================ */
SELECT
    CustomerID,
    TotalAmount,

    LAG(TotalAmount, 1, 0)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

FROM sales.Orders;







22. LAG + CASE
Price increase:
/* ============================================================
   Price Change Detection
   ============================================================ */
WITH PriceHistory AS
(
    SELECT
        ProductID,
        EffectiveDate,
        Price,

        LAG(Price)
            OVER
            (
                PARTITION BY ProductID
                ORDER BY EffectiveDate, PriceHistoryID
            ) AS PreviousPrice

    FROM product.ProductPriceHistory
)
SELECT
    ProductID,
    EffectiveDate,
    Price,
    PreviousPrice,

    CASE
        WHEN PreviousPrice IS NULL THEN 'First Price'
        WHEN Price > PreviousPrice THEN 'Price Increased'
        WHEN Price < PreviousPrice THEN 'Price Decreased'
        ELSE 'No Change'
    END AS PriceStatus

FROM PriceHistory;







23. NULL Values
LAG() নিজে NULL skip করে না।
যদি previous row-এর value NULL হয়, result NULL হবে।







24. Previous Sales
SELECT
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            ORDER BY OrderDate, OrderID
        ) AS PreviousSales

FROM sales.Orders;







25. Previous Salary
SELECT
    EmployeeID,
    EffectiveDate,
    Salary,

    LAG(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate, SalaryHistoryID
        ) AS PreviousSalary

FROM hr.EmployeeSalaryHistory;








26. Previous Order
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LAG(OrderID)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousOrderID

FROM sales.Orders;







27. Previous Date
SELECT
    CustomerID,
    OrderDate,

    LAG(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousOrderDate

FROM sales.Orders;







28. Month-over-Month
প্রথমে monthly aggregation, তারপর LAG()।
/* ============================================================
   MoM Sales Analysis
   ============================================================ */
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Sales
    FROM sales.Orders
    WHERE OrderStatus = 'Completed'
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
),
SalesWithPrevious AS
(
    SELECT
        *,
        LAG(Sales)
            OVER
            (
                ORDER BY SalesYear, SalesMonth
            ) AS PreviousMonthSales
    FROM MonthlySales
)
SELECT
    SalesYear,
    SalesMonth,
    Sales,
    PreviousMonthSales,

    Sales - PreviousMonthSales AS SalesChange,

    CASE
        WHEN PreviousMonthSales IS NULL THEN NULL
        WHEN PreviousMonthSales = 0 THEN NULL
        ELSE
            100.0 *
            (Sales - PreviousMonthSales)
            / PreviousMonthSales
    END AS MoM_Growth_Percent

FROM SalesWithPrevious;







29. Year-over-Year
Pattern:
Aggregate
   ↓
LAG()
   ↓
Comparison
/* ============================================================
   YoY Sales Analysis
   ============================================================ */
WITH YearlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        SUM(TotalAmount) AS Sales
    FROM sales.Orders
    WHERE OrderStatus = 'Completed'
    GROUP BY YEAR(OrderDate)
)
SELECT
    SalesYear,
    Sales,

    LAG(Sales)
        OVER
        (
            ORDER BY SalesYear
        ) AS PreviousYearSales

FROM YearlySales;






30. Price Change
SELECT
    ProductID,
    EffectiveDate,
    Price,

    LAG(Price)
        OVER
        (
            PARTITION BY ProductID
            ORDER BY EffectiveDate
        ) AS PreviousPrice

FROM product.ProductPriceHistory;





31. Status Change
/* ============================================================
   Order Status Change Pattern
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    OrderStatus,

    LAG(OrderStatus)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousStatus

FROM sales.Orders;







32. Employee History
SELECT
    EmployeeID,
    EmployeeName,
    EffectiveDate,
    Department,
    Salary,

    LAG(Department)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate
        ) AS PreviousDepartment,

    LAG(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate
        ) AS PreviousSalary

FROM hr.EmployeeSalaryHistory;







33. Customer Purchase History
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousPurchaseDate,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousPurchaseAmount

FROM sales.Orders;








🟢 PHASE 3 — LEAD()
LEAD() হলো LAG()-এর বিপরীত।
LAG
← Previous

Current

LEAD
→ Next
  
Syntax
LEAD
(
    expression
    [, offset]
    [, default]
)
OVER
(
    [PARTITION BY ...]
    ORDER BY ...
)

  
Basic LEAD
/* ============================================================
   Next Order
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LEAD(OrderID)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextOrderID

FROM sales.Orders;





-- Next Date
SELECT
    CustomerID,
    OrderDate,

    LEAD(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextPurchaseDate

FROM sales.Orders;




-- Multiple Offset
SELECT
    CustomerID,
    OrderDate,

    LEAD(OrderDate, 1)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextOrder,

    LEAD(OrderDate, 2)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS TwoOrdersLater

FROM sales.Orders;





-- LEAD + Default
SELECT
    CustomerID,
    OrderID,

    LEAD(OrderID, 1, -1)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextOrderID

FROM sales.Orders;





-- Customer Next Purchase
WITH CustomerJourney AS
(
    SELECT
        CustomerID,
        OrderID,
        OrderDate,

        LEAD(OrderDate)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ) AS NextPurchaseDate

    FROM sales.Orders
)
SELECT
    *,
    DATEDIFF
    (
        DAY,
        OrderDate,
        NextPurchaseDate
    ) AS DaysUntilNextPurchase

FROM CustomerJourney;




-- এটি Customer Retention / Journey Analysis-এর core pattern।
Employee Next Event
SELECT
    EmployeeID,
    EventDate,
    EventType,

    LEAD(EventType)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EventDate, EventID
        ) AS NextEvent

FROM hr.EmployeeEvents;






-- Status Transition
WITH StatusFlow AS
(
    SELECT
        CustomerID,
        OrderDate,
        OrderStatus,

        LEAD(OrderStatus)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ) AS NextStatus

    FROM sales.Orders
)
SELECT
    *,
    CONCAT(OrderStatus, ' -> ', NextStatus) AS StatusTransition
FROM StatusFlow;









🟢 PHASE 4 — FIRST_VALUE()
FIRST_VALUE() কী?
একটি window-এর প্রথম row-এর value দেয়।
  
Syntax
FIRST_VALUE(expression)
OVER
(
    [PARTITION BY ...]
    ORDER BY ...
    [ROWS/RANGE ...]
)



-- Basic Example
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    FIRST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstPurchaseAmount

FROM sales.Orders;




-- First Order Date
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    FIRST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstOrderDate

FROM sales.Orders;






-- First Salary
SELECT
    EmployeeID,
    EmployeeName,
    EffectiveDate,
    Salary,

    FIRST_VALUE(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate, SalaryHistoryID
        ) AS StartingSalary

FROM hr.EmployeeSalaryHistory;




-- First Product Price
SELECT
    ProductID,
    EffectiveDate,
    Price,

    FIRST_VALUE(Price)
        OVER
        (
            PARTITION BY ProductID
            ORDER BY EffectiveDate, PriceHistoryID
        ) AS FirstPrice

FROM product.ProductPriceHistory;






-- First vs Current
SELECT
    CustomerID,
    OrderDate,
    TotalAmount,

    FIRST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstPurchaseAmount,

    TotalAmount -
    FIRST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS DifferenceFromFirstPurchase

FROM sales.Orders;








🟢 PHASE 5 — LAST_VALUE()
এখানেই সবচেয়ে বেশি SQL Server mistake হয়। ⚠️
LAST_VALUE() কী?
Current window frame-এর শেষ value ফেরত দেয়।
এটি:
পুরো partition-এর last value

সবসময় দেয় না।
এই distinction অত্যন্ত গুরুত্বপূর্ণ।


Syntax
LAST_VALUE(expression)
OVER
(
    [PARTITION BY ...]
    ORDER BY ...
    [ROWS/RANGE ...]
)





-- Basic LAST_VALUE()
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LAST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS LastValue

FROM sales.Orders;


-- ⚠️ এটি দেখে অনেকেই ধরে নেয় LastValue = customer's final purchase।
সবসময় তা নয়।
  
কেন Unexpected Result?
Default frame-এর কারণে current row পর্যন্ত frame থাকতে পারে।
ধরুন:
Order 1 → 100
Order 2 → 200
Order 3 → 300

  
Current row:
Order 1
  
Frame:
Order 1
  
তাই:
LAST_VALUE = 100
  
Current row:
Order 2
  
Frame:
Order 1
Order 2
  
তাই:
LAST_VALUE = 200
অর্থাৎ পুরো partition-এর শেষ value পাওয়া যাচ্ছে না।




  

-- Correct Last Value
/* ============================================================
   IMPORTANT:
   পুরো partition-এর final value পেতে
   UNBOUNDED FOLLOWING ব্যবহার করুন
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS FinalPurchaseAmount

FROM sales.Orders;






76. Most Important Frame
এই syntaxটি মনে রাখবেন:
ROWS BETWEEN
    UNBOUNDED PRECEDING
    AND UNBOUNDED FOLLOWING
  
মানে:
First row
   ↓
All rows
   ↓
Last row


  

-- Last Purchase Date
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LAST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS LastPurchaseDate

FROM sales.Orders;





-- Last Salary
SELECT
    EmployeeID,
    EmployeeName,
    EffectiveDate,
    Salary,

    LAST_VALUE(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate, SalaryHistoryID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS CurrentSalary

FROM hr.EmployeeSalaryHistory;





-- First vs Last
SELECT
    EmployeeID,
    EffectiveDate,
    Salary,

    FIRST_VALUE(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate, SalaryHistoryID
        ) AS FirstSalary,

    LAST_VALUE(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate, SalaryHistoryID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS LastSalary

FROM hr.EmployeeSalaryHistory;






🟢 PHASE 6 — NULL Handling
LAG + NULL
SELECT
    EmployeeID,
    Salary,

    LAG(Salary)
        OVER
        (
            PARTITION BY EmployeeID
            ORDER BY EffectiveDate
        ) AS PreviousSalary

FROM hr.EmployeeSalaryHistory;

NULL হলে result NULL।




-- Default Value
LAG(Salary, 1, 0)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate
)





-- LEAD + NULL
LEAD(Salary, 1, 0)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate
)




-- COALESCE
SELECT
    CustomerID,
    OrderDate,

    COALESCE
    (
        LAG(TotalAmount)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ),
        0
    ) AS PreviousAmount

FROM sales.Orders;





-- ISNULL
SELECT
    CustomerID,
    OrderDate,

    ISNULL
    (
        LAG(TotalAmount)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ),
        0
    ) AS PreviousAmount

FROM sales.Orders;



-- Best Practice
LAG default
   vs
COALESCE
   vs
ISNULL
Business meaning বুঝে ব্যবহার করুন।
  
কারণ:
NULL = no previous record
0    = previous record exists and value is zero
এই দুইটি একই business meaning নয়।









🟢 PHASE 7 — Window Frame Mastery
Frame Mental Model
ধরুন:
A
B
C
D
E
Current row = C
  
তাহলে frame হতে পারে:
UNBOUNDED PRECEDING
        ↓
A
B
C
        ↑
CURRENT ROW
  
অথবা:
C
D
E
        ↑
UNBOUNDED FOLLOWING
  
অথবা:
A
B
C
D
E






-- ROWS BETWEEN
ROWS BETWEEN
    UNBOUNDED PRECEDING
    AND CURRENT ROW
  
মানে:
First Row → Current Row

  
-- Current → End
ROWS BETWEEN
    CURRENT ROW
    AND UNBOUNDED FOLLOWING


  
-- Entire Partition
ROWS BETWEEN
    UNBOUNDED PRECEDING
    AND UNBOUNDED FOLLOWING



  
-- FIRST_VALUE Frame
FIRST_VALUE(Salary)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate

    ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND CURRENT ROW
)


  
-- LAST_VALUE Frame
LAST_VALUE(Salary)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate

    ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
)


-- ⚠️ Critical Rule
LAG() / LEAD()
এদের জন্য সাধারণভাবে frame specification ব্যবহার করবেন না।
LAG/LEAD
→ offset based

FIRST/LAST_VALUE
→ frame understanding critical








🟢 PHASE 8 — Business Analysis
এখন আসল Data Analyst/Engineer work শুরু।

107. Previous Month Sales
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Sales
    FROM sales.Orders
    WHERE OrderStatus = 'Completed'
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
)
SELECT
    *,
    LAG(Sales)
        OVER
        (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousMonthSales
FROM MonthlySales;





108. Next Month Sales
SELECT
    *,
    LEAD(Sales)
        OVER
        (
            ORDER BY SalesYear, SalesMonth
        ) AS NextMonthSales
FROM MonthlySales;






109. Sales Growth
SELECT
    Sales,
    PreviousSales,
    Sales - PreviousSales AS SalesGrowth
FROM
(
    SELECT
        Sales,

        LAG(Sales)
            OVER
            (
                ORDER BY SalesYear, SalesMonth
            ) AS PreviousSales
    FROM MonthlySales
) x;






110. Sales Decline
CASE
    WHEN Sales < PreviousSales
        THEN 'Decline'
    WHEN Sales > PreviousSales
        THEN 'Growth'
    ELSE 'No Change'
END






111. MoM Growth %
100.0 *
(Sales - PreviousSales)
/
NULLIF(PreviousSales, 0)





112. YoY Growth %
Same pattern:
100.0 *
(CurrentYearSales - PreviousYearSales)
/
NULLIF(PreviousYearSales, 0)





113–115. Price Analysis
WITH PriceAnalysis AS
(
    SELECT
        ProductID,
        EffectiveDate,
        Price,

        LAG(Price)
            OVER
            (
                PARTITION BY ProductID
                ORDER BY EffectiveDate, PriceHistoryID
            ) AS PreviousPrice
    FROM product.ProductPriceHistory
)
SELECT
    *,
    Price - PreviousPrice AS PriceChange,

    CASE
        WHEN PreviousPrice IS NULL THEN 'Initial'
        WHEN Price > PreviousPrice THEN 'Increase'
        WHEN Price < PreviousPrice THEN 'Decrease'
        ELSE 'No Change'
    END AS PriceStatus

FROM PriceAnalysis;






116–118. Customer Purchase Journey
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    LAG(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousPurchaseDate,

    LEAD(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextPurchaseDate

FROM sales.Orders;


তারপর:
DATEDIFF
(
    DAY,
    PreviousPurchaseDate,
    OrderDate
)

  
এবং:
DATEDIFF
(
    DAY,
    OrderDate,
    NextPurchaseDate
)






121–124. First / Last Business Events
SELECT
    CustomerID,
    OrderID,
    OrderDate,

    FIRST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstPurchaseDate,

    LAST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID

            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS LastPurchaseDate

FROM sales.Orders;







125. Status Change Detection
WITH StatusHistory AS
(
    SELECT
        CustomerID,
        OrderID,
        OrderDate,
        OrderStatus,

        LAG(OrderStatus)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ) AS PreviousStatus

    FROM sales.Orders
)
SELECT
    *,
    CASE
        WHEN PreviousStatus IS NULL THEN 'Initial Status'
        WHEN OrderStatus <> PreviousStatus THEN 'Status Changed'
        ELSE 'No Change'
    END AS StatusChange

FROM StatusHistory;







126. Customer Journey Analysis
Core structure:
Customer
   ↓
First Purchase
   ↓
Previous Purchase
   ↓
Current Purchase
   ↓
Next Purchase
   ↓
Last Purchase


  
এক query-তে:
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousPurchase,

    LEAD(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextPurchase,

    FIRST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstPurchase,

    LAST_VALUE(OrderDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS LastPurchase

FROM sales.Orders;








🟢 PHASE 9 — Combining Value Functions
এখানে four functions একসাথে ব্যবহার করা শুরু করবেন।
/* ============================================================
   LAG + LEAD + FIRST_VALUE + LAST_VALUE
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount,

    LEAD(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS NextAmount,

    FIRST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS FirstAmount,

    LAST_VALUE(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
            ROWS BETWEEN
                UNBOUNDED PRECEDING
                AND UNBOUNDED FOLLOWING
        ) AS LastAmount

FROM sales.Orders;








-- Value Functions + CASE
CASE
    WHEN TotalAmount >
         LAG(TotalAmount) OVER (...)
    THEN 'Growth'

    WHEN TotalAmount <
         LAG(TotalAmount) OVER (...)
    THEN 'Decline'

    ELSE 'No Change'
END
⚠️ Production code-এ একই window function বারবার না লিখে CTE ব্যবহার করা cleaner।





-- Value Functions + Aggregate
Best pattern:
Aggregate first
       ↓
Window function second
উদাহরণ:
WITH MonthlySales AS
(
    SELECT
        YEAR(OrderDate) AS SalesYear,
        MONTH(OrderDate) AS SalesMonth,
        SUM(TotalAmount) AS Sales
    FROM sales.Orders
    GROUP BY
        YEAR(OrderDate),
        MONTH(OrderDate)
)
SELECT
    *,
    LAG(Sales)
        OVER
        (
            ORDER BY SalesYear, SalesMonth
        ) AS PreviousSales
FROM MonthlySales;







-- Value Functions + Ranking
WITH CustomerOrders AS
(
    SELECT
        CustomerID,
        OrderID,
        OrderDate,
        TotalAmount,

        LAG(TotalAmount)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ) AS PreviousAmount
    FROM sales.Orders
)
SELECT
    *,
    ROW_NUMBER()
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PurchaseNumber
FROM CustomerOrders;







-- Value Functions + CTE
এটাই সবচেয়ে common production pattern:
CTE
 ↓
Window calculation
 ↓
Business logic
  
Value Functions + Temp Table
যখন intermediate result reuse করতে হবে:
/* ============================================================
   Temporary result
   ============================================================ */
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

INTO #CustomerOrderHistory

FROM sales.Orders;


তারপর:
SELECT *
FROM #CustomerOrderHistory
WHERE TotalAmount > PreviousAmount;







-- Value Functions + View
/* ============================================================
   Customer Purchase History View
   ============================================================ */
CREATE VIEW sales.vw_CustomerPurchaseHistory
AS
SELECT
    CustomerID,
    OrderID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

FROM sales.Orders;
GO




  


🟢 PHASE 10 — Advanced SQL Server Use Cases
143. Multiple PARTITION BY
PARTITION BY CustomerID
  
অথবা:
PARTITION BY CustomerID, OrderStatus
  
অথবা:
PARTITION BY ProductID, Category






144. Multi-column ORDER BY
  
এটি অত্যন্ত গুরুত্বপূর্ণ।
❌ শুধু:
ORDER BY OrderDate
যদি একই date-এ multiple order থাকে।
  
✅ Better:
ORDER BY OrderDate, OrderID





  

145–149. Tie + Duplicate Dates + Deterministic Ordering
  
ধরুন:
CustomerID | OrderDate  | OrderID
101        | 2024-01-01 | 1001
101        | 2024-01-01 | 1002

  
শুধু:
ORDER BY OrderDate
দিলে ordering ambiguous হতে পারে।

Best practice:
ORDER BY OrderDate, OrderID
Deterministic ordering production SQL-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।







150. DateTime
SELECT
    TransactionID,
    TransactionDate,

    LAG(TransactionDate)
        OVER
        (
            PARTITION BY AccountID
            ORDER BY TransactionDate, TransactionID
        ) AS PreviousTransaction

FROM banking.BankTransactions;







151. Numeric
LAG(Amount)
OVER
(
    PARTITION BY AccountID
    ORDER BY TransactionDate, TransactionID
)







152. Text
LAG(EventType)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EventDate, EventID
)






153. Status
LAG(OrderStatus)
OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate, OrderID
)






154–160 Historical Analysis
Value functions historical data-এর জন্য অত্যন্ত শক্তিশালী:
Price History
Salary History
Customer History
Order History
Status History
Event History
Transaction History







🟢 PHASE 11 — Data Engineering Use Cases
এখানে একই functions ETL এবং historical data pipeline-এ ব্যবহার করব।

  
161. Change Detection
WITH Changes AS
(
    SELECT
        EmployeeID,
        EffectiveDate,
        Department,
        Salary,

        LAG(Department)
            OVER
            (
                PARTITION BY EmployeeID
                ORDER BY EffectiveDate
            ) AS PreviousDepartment,

        LAG(Salary)
            OVER
            (
                PARTITION BY EmployeeID
                ORDER BY EffectiveDate
            ) AS PreviousSalary

    FROM hr.EmployeeSalaryHistory
)
SELECT
    *,
    CASE
        WHEN Department <> PreviousDepartment
          OR Salary <> PreviousSalary
        THEN 1
        ELSE 0
    END AS IsChanged

FROM Changes;

এটি SCD preparation-এর foundation।







162. Source-to-Target Comparison
ধরা যাক source data এবং target data:
Source
Target
তারপর previous/current version compare করে change detect করা যায়।







163. Previous Record Detection
LAG(RecordValue)
OVER
(
    PARTITION BY BusinessKey
    ORDER BY EffectiveDate
)





164. Next Record Detection
LEAD(EffectiveDate)
OVER
(
    PARTITION BY BusinessKey
    ORDER BY EffectiveDate
)






168. SCD Type 2 Preparation
এটি Data Engineering-এর খুব গুরুত্বপূর্ণ pattern।

  
ধরুন:
CustomerID | EffectiveDate | City
101        | Jan           | Kuwait
101        | Jun           | Salmiya
101        | Sep           | Hawally


  
Next effective date:
SELECT
    CustomerID,
    EffectiveDate,
    City,

    LEAD(EffectiveDate)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY EffectiveDate
        ) AS NextEffectiveDate

FROM CustomerHistory;

তারপর:
StartDate
EndDate
IsCurrent
তৈরি করা যায়।








169. Effective Date
EffectiveDate
হলো current record কখন থেকে valid।





170. Expiry Date
সাধারণ pattern:
DATEADD
(
    DAY,
    -1,
    LEAD(EffectiveDate)
        OVER (...)
)
  
অর্থাৎ:
Next Start Date - 1 Day







171. Record Version
ROW_NUMBER()
OVER
(
    PARTITION BY BusinessKey
    ORDER BY EffectiveDate
)
  
এর সাথে:
LAG()
ব্যবহার করে version history তৈরি করা যায়।








174. Data Quality
Duplicate sequence:
ROW_NUMBER()
OVER
(
    PARTITION BY BusinessKey, EffectiveDate
    ORDER BY LoadDate
)
  
তারপর:
WHERE RowNumber > 1







175. ETL Validation with LAG()
ধরা যাক daily sales:
Day 1 = 1000
Day 2 = 1200
Day 3 = 1300

  
Pipeline validation:
SELECT
    SalesDate,
    SalesAmount,

    LAG(SalesAmount)
        OVER
        (
            ORDER BY SalesDate
        ) AS PreviousSales

FROM staging.DailySales;

তারপর abnormal change detect করা যায়।







176. ETL Validation with LEAD()
Future expected event:
SELECT
    BusinessKey,
    EffectiveDate,

    LEAD(EffectiveDate)
        OVER
        (
            PARTITION BY BusinessKey
            ORDER BY EffectiveDate
        ) AS NextEffectiveDate

FROM staging.CustomerHistory;








🟢 PHASE 12 — Performance & Best Practices
177. Window Execution Concept
Conceptually:
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
ORDER BY
তাই aggregate result-এর উপর window function চালানো খুব common।







178–180. Indexing
যদি query:
PARTITION BY CustomerID
ORDER BY OrderDate, OrderID

হয়, তাহলে index strategy হতে পারে:
  
CREATE INDEX IX_Orders_Customer_OrderDate
ON sales.Orders
(
    CustomerID,
    OrderDate,
    OrderID
)
INCLUDE
(
    TotalAmount,
    OrderStatus
);






181. Sort Operation
Window functions-এর জন্য SQL Server-কে sorting করতে হতে পারে।
Large data হলে:
Sort
 ↓
Window Aggregate / Sequence Project
performance impact করতে পারে।







182. Execution Plan
Check করুন:
/* ============================================================
   Execution Plan
   ============================================================ */
SELECT
    CustomerID,
    OrderDate,
    TotalAmount,

    LAG(TotalAmount)
        OVER
        (
            PARTITION BY CustomerID
            ORDER BY OrderDate, OrderID
        ) AS PreviousAmount

FROM sales.Orders;

SSMS-এ:
Ctrl + M
দিয়ে Actual Execution Plan দেখতে পারেন।





183. Large Dataset
Million-row table-এ:
❌ unnecessary window calculations
❌ unnecessary columns
❌ non-deterministic ordering
❌ poor indexes
avoid করুন।







184. Avoid Unnecessary Window Functions
একই expression বারবার:
LAG(...)
LAG(...)
LAG(...)
না লিখে CTE-তে calculate করে পরে reuse করুন।






185. CTE vs Temp Table
   
Scenario	                   Better
One-time transformation	     CTE
Complex multi-step	         Temp Table
Reuse result	               Temp Table
Index intermediate data	     Temp Table
Simple readability	         CTE







186. Window Function vs Self Join
আগে:
Self Join
দিয়ে previous row বের করা হতো।
  
Modern SQL:
LAG()
অনেক ক্ষেত্রে cleaner এবং easier।






187. Window Function vs Correlated Subquery
Previous order:
Correlated subquery
  
versus:
LAG(OrderDate)
OVER(...)
Window function সাধারণত বেশি declarative এবং readable।








188. Performance Benchmark
একই problem:
LAG()
vs
Self Join
vs
Correlated Subquery
  
এর জন্য compare করুন:
- Logical Reads
- CPU Time
- Elapsed Time
- Execution Plan






189. Common Performance Mistakes
- 🔴 Wrong Order: unnecessary columns in ORDER BY
- 🔴 No Index: large table scan/sort
- 🔴 Repeated Logic: same window expression multiple times
- 🔴 Huge Dataset: filtering too late
- 🔴 Non-deterministic: incomplete ordering




  


🟢 PHASE 13 — 10 Real-World Projects
আপনার course-এর hands-on portfolio projectগুলো:
190. E-Commerce Sales Analysis
Monthly Sales
Previous Sales
Next Sales
MoM Growth
YoY Growth
First Purchase
Last Purchase




191. Customer Purchase History
First Purchase
Previous Purchase
Next Purchase
Last Purchase
Days Between Purchases
Purchase Sequence





192. Product Price History
Previous Price
Next Price
First Price
Last Price
Price Increase
Price Decrease




193. Employee Salary History
Starting Salary
Previous Salary
Next Salary
Current Salary
Salary Increase
Salary Growth %








194. Bank Transaction Analysis
Previous Transaction
Next Transaction
Transaction Gap
Transaction Sequence
Large Transaction Detection






195. Inventory Movement
Previous Movement
Next Movement
IN → OUT transition
Movement Gap
Stock Event Sequence






196. Order Status History
Previous Status
Next Status
Status Transition
Status Change Detection







197. Customer Churn Analysis
Pattern:
Last Purchase
        ↓
Current Date
        ↓
Days Since Last Purchase
        ↓
Churn Candidate






198. SCD Type 2
Pattern:
Business Key
      ↓
ORDER BY EffectiveDate
      ↓
LAG()
      ↓
Change Detection
      ↓
LEAD()
      ↓
Expiry Date
      ↓
IsCurrent










199. ETL Data Validation
Pattern:
Source
 ↓
Target
 ↓
Sequence
 ↓
LAG / LEAD
 ↓
Difference
 ↓
Exception







🟢 PHASE 14 — Interview + Practice
200–204. Core Interview Questions

  
Q1. LAG() কী?
Answer: Current row-এর আগের row-এর value return করে।

  
Q2. LEAD() কী?
Answer: Current row-এর পরের row-এর value return করে।

  
Q3. LAG() এবং LEAD() difference?
LAG  → Previous
LEAD → Next

  
Q4. FIRST_VALUE() কী?
Partition/window-এর first value return করে।

  
Q5. LAST_VALUE() কেন tricky?
কারণ এটি window frame-এর last row return করে, necessarily entire partition-এর last row নয়।

  
Q6. LAST_VALUE()-এর correct full partition syntax?
LAST_VALUE(Column)
OVER
(
    PARTITION BY ...
    ORDER BY ...

    ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
)
⭐ এই প্রশ্ন interview-এ অত্যন্ত গুরুত্বপূর্ণ।






205. Scenario Question
Question: একজন customer-এর previous order amount বের করবেন কীভাবে?
LAG(TotalAmount)
OVER
(
    PARTITION BY CustomerID
    ORDER BY OrderDate, OrderID
)





206. Business Case
Question: কোন customer-এর purchase amount previous purchase-এর চেয়ে কম?
WITH x AS
(
    SELECT
        CustomerID,
        OrderID,
        TotalAmount,

        LAG(TotalAmount)
            OVER
            (
                PARTITION BY CustomerID
                ORDER BY OrderDate, OrderID
            ) AS PreviousAmount

    FROM sales.Orders
)
SELECT *
FROM x
WHERE TotalAmount < PreviousAmount;







207. Data Engineering Question
Question: SCD Type 2-এর next effective date কীভাবে বের করবেন?
LEAD(EffectiveDate)
OVER
(
    PARTITION BY BusinessKey
    ORDER BY EffectiveDate
)






208. Performance Question
Question: Window function slow হলে কী check করবেন?
1. Execution Plan
2. Sort
3. Index
4. PARTITION BY
5. ORDER BY
6. Data volume
7. Filter timing
8. Repeated window calculations





209. Debugging Question
এই query:
LAST_VALUE(Salary)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate
)
যদি expected final salary না দেয়?
  
কারণ:
Window frame।

  
Fix:
LAST_VALUE(Salary)
OVER
(
    PARTITION BY EmployeeID
    ORDER BY EffectiveDate
    ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
)






210 — 50 Hands-on Practice Problems
  
🟢 Beginner
1. প্রতিটি order-এর previous order amount বের করুন।
2. প্রতিটি order-এর next order amount বের করুন।
3. Customer-wise previous order date বের করুন।
4. Customer-wise next order date বের করুন।
5. Product-এর previous price বের করুন।
6. Product-এর next price বের করুন।
7. Employee-এর previous salary বের করুন।
8. Employee-এর next salary বের করুন।
9. প্রথম purchase date বের করুন।
10. শেষ purchase date বের করুন।



🟡 Intermediate
11. Previous purchase amount বনাম current amount।
12. Next purchase amount বনাম current amount।
13. Price increase detection।
14. Price decrease detection।
15. Salary increase detection।
16. Salary decrease detection।
17. Previous department detection।
18. Employee promotion detection।
19. Customer purchase sequence তৈরি করুন।
20. Days between purchases বের করুন।


  
🟠 Business Analysis
21. MoM sales growth।
22. MoM sales decline।
23. MoM growth percentage।
24. YoY sales growth।
25. YoY growth percentage।
26. Previous month sales।
27. Next month sales।
28. First customer transaction।
29. Last customer transaction।
30. Customer churn candidate।


  
🔵 Advanced
31. First price বনাম current price।
32. First salary বনাম current salary।
33. First purchase বনাম last purchase।
34. Price change percentage।
35. Salary change percentage।
36. Customer purchase gap।
37. Employee career sequence।
38. Status transition।
39. Transaction sequence।
40. Event sequence।


  
🔴 Data Engineering
41. SCD Type 2 change detection।
42. Next effective date।
43. Expiry date calculation।
44. Current record detection।
45. Duplicate sequence detection।
46. Source-target change detection।
47. ETL sequence validation।
48. Missing event detection।
49. Historical record validation।
50. CDC-style change analysis।





211. সবচেয়ে গুরুত্বপূর্ণ Mental Model
পুরো Window Value Functions course-কে এই চারটি প্রশ্নে নামিয়ে আনতে পারেন:
┌─────────────────────────────────┐
│ আমি আগের row দেখতে চাই?         │
│             ↓                   │
│           LAG()                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ আমি পরের row দেখতে চাই?         │
│             ↓                   │
│          LEAD()                 │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Partition-এর প্রথম value চাই?   │
│             ↓                   │
│       FIRST_VALUE()             │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Partition-এর শেষ value চাই?     │
│             ↓                   │
│        LAST_VALUE()             │
│             +                   │
│ UNBOUNDED FOLLOWING             │
└─────────────────────────────────┘






212. Production-Level Golden Rules

1️⃣ Deterministic ORDER BY
ORDER BY OrderDate, OrderID
শুধু:
ORDER BY OrderDate
এর চেয়ে নিরাপদ।



2️⃣ Customer/Entity আলাদা করতে PARTITION
PARTITION BY CustomerID



3️⃣ FIRST_VALUE সহজ
FIRST_VALUE(...)
OVER(...)



4️⃣ LAST_VALUE সাবধানে
LAST_VALUE(...)
OVER
(
    ...
    ROWS BETWEEN
        UNBOUNDED PRECEDING
        AND UNBOUNDED FOLLOWING
)



5️⃣ NULL-এর business meaning বুঝুন
NULL ≠ 0



6️⃣ Aggregate আগে, Window পরে
Raw Transactions
      ↓
GROUP BY
      ↓
Monthly/Yearly Data
      ↓
LAG / LEAD



7️⃣ Historical Data-তে Value Functions অত্যন্ত powerful
Customer History
Employee History
Price History
Status History
SCD History
Transaction History






213. 210-topic roadmap-এর Core Mastery
শেষ পর্যন্ত আপনার মাথায় এই architecture থাকা উচিত:
                    WINDOW VALUE FUNCTIONS
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
        LAG()             LEAD()          FIRST/LAST
          │                  │                  │
      Previous             Next             Boundary
          │                  │                  │
          └──────────────────┼──────────────────┘
                             │
                      OVER()
                             │
              ┌──────────────┴──────────────┐
              │                             │
         PARTITION BY                   ORDER BY
              │                             │
          Entity Group                 Sequence
                                            │
                                      ┌─────┴─────┐
                                      │           │
                                  Current      History
                                      │           │
                                      └─────┬─────┘
                                            │
                                      WINDOW FRAME
                                            │
                                  ┌─────────┴─────────┐
                                  │                   │
                                ROWS                RANGE
                                  │
                    ┌─────────────┼─────────────┐
                    │             │             │
              PRECEDING      CURRENT ROW    FOLLOWING
                    │             │             │
                    └─────────────┼─────────────┘
                                  │
                         BUSINESS ANALYSIS
                                  │
       ┌──────────────┬───────────┼───────────┬──────────────┐
       │              │           │           │              │
      MoM            YoY       Customer    Employee       Price
       │              │        Journey      History       History
       └──────────────┴───────────┼───────────┴──────────────┘
                                  │
                           DATA ENGINEERING
                                  │
             ┌────────────────────┼───────────────────┐
             │                    │                   │
          Change               SCD-2                ETL
         Detection            Preparation         Validation
             │                    │                   │
             └────────────────────┼───────────────────┘
                                  │
                            PERFORMANCE
                                  │
                         INDEX + EXECUTION PLAN
