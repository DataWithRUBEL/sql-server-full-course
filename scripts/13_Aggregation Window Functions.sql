/* ============================================================
   BASIC DATA EXPLORATION
   ============================================================ */

SELECT *
FROM Sales.Customers;

SELECT *
FROM Sales.Orders;

SELECT *
FROM Sales.Products;

SELECT *
FROM Sales.OrderItems;



1. COUNT()
কী কাজ করে?
COUNT() একাধিক row গণনা করে।
Syntax
COUNT(*)
COUNT(column_name)
COUNT(DISTINCT column_name)
  
-- মোট customer
/* মোট customer সংখ্যা */

SELECT
    COUNT(*) AS total_customers
FROM Sales.Customers;


-- মোট orders
/* মোট orders */

SELECT
    COUNT(*) AS total_orders
FROM Sales.Orders;

-- NULL-এর behaviour
/* score NULL হলে COUNT(score) সেই row count করবে না */

SELECT
    COUNT(*) AS total_customers,
    COUNT(score) AS customers_with_score
FROM Sales.Customers;

মনে রাখবেন:
Query	কী                       count করে
COUNT(*)	                     সব row
COUNT(score)	                 শুধু non-NULL score
COUNT(DISTINCT customer_id)	   unique customer






2. SUM()
মোট revenue, quantity, cost ইত্যাদি বের করতে।
/* ============================================================
   Total Sales
   ============================================================ */

SELECT
    SUM(sales) AS total_sales
FROM Sales.Orders;

Quantity
/* মোট বিক্রি হওয়া quantity */

SELECT
    SUM(quantity) AS total_quantity
FROM Sales.OrderItems;





3. AVG()
Average বের করতে।
/* Average order value */

SELECT
    AVG(sales) AS average_order_value
FROM Sales.Orders;


Decimal precision
SELECT
    CAST(AVG(sales) AS DECIMAL(12,2)) AS average_order_value
FROM Sales.Orders;






4. MAX()
/* সর্বোচ্চ order value */

SELECT
    MAX(sales) AS highest_order
FROM Sales.Orders;





5. MIN()
/* সর্বনিম্ন order value */

SELECT
    MIN(sales) AS lowest_order
FROM Sales.Orders;





6. পাঁচটি Aggregate একসাথে
এটাই আপনার দেওয়া প্রথম example-এর proper real-world version।
/* ============================================================
   BUSINESS KPI SUMMARY
   ============================================================ */

SELECT
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales,
    AVG(sales) AS average_sales,
    MIN(sales) AS minimum_sales,
    MAX(sales) AS maximum_sales
FROM Sales.Orders;





7. GROUP BY
GROUP BY aggregate calculation-কে category/group অনুযায়ী ভাগ করে।
প্রশ্ন:
Customer প্রতি কতটি order এবং কত sales?

/* ============================================================
   CUSTOMER LEVEL SALES SUMMARY
   ============================================================ */

SELECT
    customer_id,

    COUNT(*) AS total_orders,

    SUM(sales) AS total_sales,

    AVG(sales) AS average_order_value,

    MIN(sales) AS minimum_order,

    MAX(sales) AS maximum_order

FROM Sales.Orders

GROUP BY customer_id;


এটি অত্যন্ত গুরুত্বপূর্ণ query pattern:
SELECT
    dimension,
    aggregate_measure
FROM table
GROUP BY dimension;





8. HAVING
WHERE row filter করে।
HAVING aggregated result filter করে।
প্রশ্ন:
যেসব customer $1,000-এর বেশি sales করেছে তাদের দেখাও।

/* ============================================================
   CUSTOMERS WITH HIGH TOTAL SALES
   ============================================================ */

SELECT
    customer_id,
    SUM(sales) AS total_sales
FROM Sales.Orders
GROUP BY customer_id
HAVING SUM(sales) > 1000;



WHERE + GROUP BY + HAVING
/* Completed orders থেকে
   যেসব customer $1,000-এর বেশি sales করেছে */

SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales
FROM Sales.Orders
WHERE status = 'Completed'
GROUP BY customer_id
HAVING SUM(sales) > 1000;


Execution concept
FROM
 ↓
WHERE
 ↓
GROUP BY
 ↓
HAVING
 ↓
SELECT
 ↓
ORDER BY





9. COUNT DISTINCT
Unique value count করার জন্য।
/* মোট unique customer যারা order করেছে */

SELECT
    COUNT(DISTINCT customer_id) AS unique_customers
FROM Sales.Orders;


Country অনুযায়ী unique customers
SELECT
    c.country,
    COUNT(DISTINCT o.customer_id) AS unique_customers
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id
GROUP BY c.country;





10. Conditional Aggregation
একটি query-এর মধ্যে condition অনুযায়ী multiple KPI তৈরি করা।
এটি খুব গুরুত্বপূর্ণ professional SQL pattern।
/* ============================================================
   CONDITIONAL AGGREGATION
   ============================================================ */

SELECT
    COUNT(*) AS total_orders,

    COUNT(CASE
        WHEN status = 'Completed'
        THEN 1
    END) AS completed_orders,

    COUNT(CASE
        WHEN status = 'Cancelled'
        THEN 1
    END) AS cancelled_orders,

    SUM(CASE
        WHEN status = 'Completed'
        THEN sales
        ELSE 0
    END) AS completed_sales,

    SUM(CASE
        WHEN status = 'Cancelled'
        THEN sales
        ELSE 0
    END) AS cancelled_sales

FROM Sales.Orders;


কেন গুরুত্বপূর্ণ?
এক query-তে:
Total Orders
Completed Orders
Cancelled Orders
Completed Sales
Cancelled Sales
পাওয়া যাচ্ছে।







11. CASE + Aggregation
ধরা যাক customer segmentation:
Sales >= 1500 → VIP
Sales >= 800  → Premium
Sales >= 300  → Regular
Otherwise     → Low Value
/* ============================================================
   CUSTOMER SEGMENTATION
   ============================================================ */

SELECT
    customer_id,

    SUM(sales) AS total_sales,

    CASE
        WHEN SUM(sales) >= 1500 THEN 'VIP'
        WHEN SUM(sales) >= 800 THEN 'Premium'
        WHEN SUM(sales) >= 300 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment

FROM Sales.Orders

GROUP BY customer_id;





12. Multiple GROUP BY
একাধিক dimension দিয়ে grouping।
/* Country + Gender অনুযায়ী customer analysis */

SELECT
    c.country,
    c.gender,
    COUNT(DISTINCT c.customer_id) AS customers
FROM Sales.Customers c
GROUP BY
    c.country,
    c.gender;







13. GROUP BY + JOIN
এটি বাস্তব project-এ অত্যন্ত common।
প্রশ্ন:
Country অনুযায়ী total sales?

/* ============================================================
   SALES BY COUNTRY
   ============================================================ */

SELECT
    c.country,
    COUNT(DISTINCT o.customer_id) AS customers,
    COUNT(o.order_id) AS orders,
    SUM(o.sales) AS total_sales
FROM Sales.Orders o
INNER JOIN Sales.Customers c
    ON o.customer_id = c.customer_id
GROUP BY c.country;






14. GROUP BY + Date
Year অনুযায়ী sales
/* ============================================================
   YEARLY SALES
   ============================================================ */

SELECT
    YEAR(order_date) AS order_year,
    SUM(sales) AS total_sales
FROM Sales.Orders
GROUP BY YEAR(order_date)
ORDER BY order_year;



Month অনুযায়ী
/* ============================================================
   MONTHLY SALES
   ============================================================ */
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales) AS total_sales
FROM Sales.Orders
GROUP BY
    YEAR(order_date),
    MONTH(order_date)
ORDER BY
    order_year,
    order_month;


Best Practice
Production reporting-এ শুধু:
GROUP BY MONTH(order_date)
ব্যবহার করবেন না।
কারণ 2025 January এবং 2026 January এক group হয়ে যেতে পারে।

  
সঠিক:
GROUP BY
    YEAR(order_date),
    MONTH(order_date);
আর বড় Data Warehouse-এ সাধারণত Date Dimension ব্যবহার করা আরও ভালো।




  


15. NULL + Aggregation
SQL Server aggregate function সাধারণত NULL ignore করে।
SELECT
    COUNT(*) AS total_rows,
    COUNT(score) AS non_null_scores,
    AVG(score) AS average_score,
    MIN(score) AS minimum_score,
    MAX(score) AS maximum_score
FROM Sales.Customers;


NULL-কে 0 হিসেবে ধরতে
SELECT
    AVG(ISNULL(score, 0)) AS average_score
FROM Sales.Customers;


⚠️ কিন্তু এটি business meaning পরিবর্তন করতে পারে।
NULL যদি "score পাওয়া যায়নি" বোঝায়, তাহলে সেটাকে automatically 0 করা ভুল হতে পারে।








16. ROLLUP
Subtotal + Grand Total তৈরি করে।
/* ============================================================
   ROLLUP
   Country → Gender → Subtotal → Grand Total
   ============================================================ */

SELECT
    c.country,
    c.gender,
    SUM(o.sales) AS total_sales
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id
GROUP BY ROLLUP
(
    c.country,
    c.gender
);


Concept:
Country + Gender
Country subtotal
Grand Total






17. GROUPING()
ROLLUP-এর NULL আর actual NULL আলাদা করতে।
SELECT
    c.country,
    c.gender,
    SUM(o.sales) AS total_sales,

    GROUPING(c.country) AS country_grouping,
    GROUPING(c.gender) AS gender_grouping

FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id

GROUP BY ROLLUP
(
    c.country,
    c.gender
);





18. CUBE
সব possible combination-এর subtotal তৈরি করে।
/* ============================================================
   CUBE
   ============================================================ */

SELECT
    c.country,
    c.gender,
    SUM(o.sales) AS total_sales
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id
GROUP BY CUBE
(
    c.country,
    c.gender
);


ROLLUP vs CUBE
Feature	                     ROLLUP	         CUBE
Hierarchical subtotal	       ✅	             ✅
All combinations	           ❌	             ✅
Grand total	                 ✅	             ✅
Data volume	                 কম	           বেশি







19. GROUPING SETS
নিজের প্রয়োজনমতো grouping level define করতে।
/* ============================================================
   GROUPING SETS
   ============================================================ */

SELECT
    c.country,
    c.gender,
    SUM(o.sales) AS total_sales

FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id

GROUP BY GROUPING SETS
(
    (c.country, c.gender),
    (c.country),
    (c.gender),
    ()
);


এখানে:
Country + Gender
Country
Gender
Grand Total







20. Window Functions
এখন সবচেয়ে গুরুত্বপূর্ণ advanced section।
Aggregate vs Window
GROUP BY
row collapse করে।
অন্যদিকে:
SUM() OVER()
মূল rows রেখে calculation করে।







21. SUM() OVER()
/* ============================================================
   TOTAL COMPANY SALES
   প্রতিটি order-এর পাশে total sales দেখাবে
   ============================================================ */

SELECT
    order_id,
    customer_id,
    sales,

    SUM(sales) OVER() AS company_total_sales

FROM Sales.Orders;







22. AVG() OVER()
SELECT
    order_id,
    sales,

    AVG(sales) OVER() AS company_average_order

FROM Sales.Orders;







23. PARTITION BY
Customer প্রতি total sales।
/* ============================================================
   CUSTOMER TOTAL SALES
   ============================================================ */

SELECT
    order_id,
    customer_id,
    sales,

    SUM(sales) OVER
    (
        PARTITION BY customer_id
    ) AS customer_total_sales

FROM Sales.Orders;

PARTITION BY = "প্রতিটি group-এর ভিতরে calculation করো, কিন্তু row collapse করো না।"







24. Running Total
/* ============================================================
   RUNNING TOTAL
   ============================================================ */

SELECT
    order_id,
    order_date,
    sales,

    SUM(sales) OVER
    (
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS running_sales

FROM Sales.Orders
ORDER BY order_date, order_id;


কেন order_id যোগ করেছি?
একই date-এ multiple order থাকতে পারে।
তাই deterministic ordering-এর জন্য:
ORDER BY order_date, order_id
ভালো practice।







25. Customer Running Total
SELECT
    customer_id,
    order_id,
    order_date,
    sales,

    SUM(sales) OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING
        AND CURRENT ROW
    ) AS customer_running_sales

FROM Sales.Orders;




26. LAG()
Previous row-এর value।
Month-over-Month-এর foundation
/* ============================================================
   LAG
   ============================================================ */

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS sales_month,

        SUM(sales) AS total_sales

    FROM Sales.Orders

    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)

SELECT
    sales_month,
    total_sales,

    LAG(total_sales) OVER
    (
        ORDER BY sales_month
    ) AS previous_month_sales

FROM MonthlySales;







27. LEAD()
-- পরবর্তী month's value।
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS sales_month,

        SUM(sales) AS total_sales

    FROM Sales.Orders

    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)

SELECT
    sales_month,
    total_sales,

    LEAD(total_sales) OVER
    (
        ORDER BY sales_month
    ) AS next_month_sales

FROM MonthlySales;





28. RANK()
/* ============================================================
   CUSTOMER RANK
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_sales,

    RANK() OVER
    (
        ORDER BY total_sales DESC
    ) AS sales_rank

FROM CustomerSales;
  
RANK tie হলে gap রাখে।







29. DENSE_RANK()
SELECT
    customer_id,
    total_sales,

    DENSE_RANK() OVER
    (
        ORDER BY total_sales DESC
    ) AS sales_dense_rank

FROM
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
) x;


Difference:
RANK:
1
2
2
4

DENSE_RANK:
1
2
2
3








30. ROW_NUMBER()
প্রতিটি row-কে unique sequence number দেয়।
SELECT
    customer_id,
    order_id,
    order_date,
    sales,

    ROW_NUMBER() OVER
    (
        PARTITION BY customer_id
        ORDER BY order_date, order_id
    ) AS order_number

FROM Sales.Orders;
First order per customer
WITH RankedOrders AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY customer_id
            ORDER BY order_date, order_id
        ) AS rn
    FROM Sales.Orders
)

SELECT *
FROM RankedOrders
WHERE rn = 1;

এটি deduplication, first/last record, SCD processing-এ অত্যন্ত গুরুত্বপূর্ণ।






31. Percentage of Total
/* ============================================================
   CUSTOMER % OF TOTAL SALES
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_sales,

    CAST
    (
        total_sales * 100.0
        / SUM(total_sales) OVER()
        AS DECIMAL(10,2)
    ) AS percentage_of_total

FROM CustomerSales;








32. STRING_AGG()
একাধিক row-এর text একত্রে concatenate করে।
Customer-এর orders list
/* ============================================================
   STRING_AGG
   ============================================================ */

SELECT
    customer_id,

    STRING_AGG
    (
        CAST(order_id AS VARCHAR(20)),
        ', '
    ) AS order_list

FROM Sales.Orders

GROUP BY customer_id;
Product list per category
SELECT
    c.category_name,

    STRING_AGG
    (
        p.product_name,
        ', '
    ) AS products

FROM Sales.Products p

JOIN Sales.Categories c
    ON p.category_id = c.category_id

GROUP BY c.category_name;


Useful for:
reporting
emails
audit output
aggregated labels







33. Statistical Functions
SQL Server-এ statistical analysis-এর জন্য যেমন:
STDEV()
STDEVP()
VAR()
VARP()
Standard deviation
/* ============================================================
   STANDARD DEVIATION
   ============================================================ */

SELECT
    STDEV(sales) AS sample_std_dev,
    STDEVP(sales) AS population_std_dev
FROM Sales.Orders;


Variance
SELECT
    VAR(sales) AS sample_variance,
    VARP(sales) AS population_variance
FROM Sales.Orders;

কখন?
Sales variability, customer spending variability, process monitoring ইত্যাদিতে।







34. APPROX_COUNT_DISTINCT()
Large dataset-এ approximate unique count।
/* ============================================================
   APPROXIMATE DISTINCT COUNT
   ============================================================ */

SELECT
    APPROX_COUNT_DISTINCT(customer_id)
        AS approximate_unique_customers
FROM Sales.Orders;



COUNT DISTINCT বনাম APPROX
Function	              Accuracy	              Performance
COUNT(DISTINCT)	        Exact	                  তুলনামূলক expensive
APPROX_COUNT_DISTINCT	  Approximate	            Large data-তে faster

Millions/billions of rows-এর analytics-এ useful।






35. MoM — Month over Month
এটি বাস্তব BI/analytics-এ অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   MONTH OVER MONTH SALES
   ============================================================ */

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS sales_month,

        SUM(sales) AS total_sales

    FROM Sales.Orders

    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
),

MonthlyComparison AS
(
    SELECT
        sales_month,
        total_sales,

        LAG(total_sales) OVER
        (
            ORDER BY sales_month
        ) AS previous_month_sales

    FROM MonthlySales
)

SELECT
    sales_month,
    total_sales,
    previous_month_sales,

    total_sales - previous_month_sales
        AS sales_change,

    CAST
    (
        (total_sales - previous_month_sales)
        * 100.0
        / NULLIF(previous_month_sales, 0)
        AS DECIMAL(10,2)
    ) AS mom_growth_percentage

FROM MonthlyComparison
ORDER BY sales_month;



Formula
MoM % =
(Current Month - Previous Month)
/
Previous Month
× 100






36. YoY — Year over Year
/* ============================================================
   YEAR OVER YEAR SALES
   ============================================================ */

WITH YearlySales AS
(
    SELECT
        YEAR(order_date) AS sales_year,
        SUM(sales) AS total_sales

    FROM Sales.Orders

    GROUP BY YEAR(order_date)
),

Comparison AS
(
    SELECT
        sales_year,
        total_sales,

        LAG(total_sales) OVER
        (
            ORDER BY sales_year
        ) AS previous_year_sales

    FROM YearlySales
)

SELECT
    sales_year,
    total_sales,
    previous_year_sales,

    total_sales - previous_year_sales
        AS yoy_change,

    CAST
    (
        (total_sales - previous_year_sales)
        * 100.0
        / NULLIF(previous_year_sales, 0)
        AS DECIMAL(10,2)
    ) AS yoy_growth_percentage

FROM Comparison;

⚠️ Production environment-এ missing year/month থাকলে simple LAG() 
  সবসময় correct business comparison নাও দিতে পারে। Date Dimension ব্যবহার করা better।







37. Moving Average
ধরা যাক 3-month moving average।
/* ============================================================
   3-MONTH MOVING AVERAGE
   ============================================================ */

WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS
        (
            YEAR(order_date),
            MONTH(order_date),
            1
        ) AS sales_month,

        SUM(sales) AS total_sales

    FROM Sales.Orders

    GROUP BY
        YEAR(order_date),
        MONTH(order_date)
)

SELECT
    sales_month,
    total_sales,

    AVG(total_sales) OVER
    (
        ORDER BY sales_month
        ROWS BETWEEN 2 PRECEDING
        AND CURRENT ROW
    ) AS three_month_moving_average

FROM MonthlySales;


Useful for:
trend analysis
noise reduction
forecasting preparation
dashboard KPI






38. Customer Segmentation
Customer-এর total spending অনুযায়ী segment:
/* ============================================================
   CUSTOMER SEGMENTATION
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales,
        COUNT(*) AS total_orders
    FROM Sales.Orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_orders,
    total_sales,

    CASE
        WHEN total_sales >= 1500
            THEN 'VIP'

        WHEN total_sales >= 800
            THEN 'Premium'

        WHEN total_sales >= 300
            THEN 'Regular'

        ELSE 'Low Value'
    END AS customer_segment

FROM CustomerSales;



-- Segment count
WITH CustomerSales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
),

Segments AS
(
    SELECT
        customer_id,

        CASE
            WHEN total_sales >= 1500 THEN 'VIP'
            WHEN total_sales >= 800 THEN 'Premium'
            WHEN total_sales >= 300 THEN 'Regular'
            ELSE 'Low Value'
        END AS segment

    FROM CustomerSales
)

SELECT
    segment,
    COUNT(*) AS customers
FROM Segments
GROUP BY segment;





39. Cohort Analysis
এটি advanced analytics-এর একটি গুরুত্বপূর্ণ concept।
Concept
Customer যে month-এ প্রথম purchase করেছে সেটিই তার cohort month।
তারপর দেখি:
Cohort Month
↓
Month 0
Month 1
Month 2
Month 3
...


  
Step 1 — First Purchase
/* ============================================================
   STEP 1: FIND FIRST PURCHASE MONTH
   ============================================================ */

WITH FirstPurchase AS
(
    SELECT
        customer_id,

        MIN
        (
            DATEFROMPARTS
            (
                YEAR(order_date),
                MONTH(order_date),
                1
            )
        ) AS cohort_month

    FROM Sales.Orders

    WHERE status = 'Completed'

    GROUP BY customer_id
)

SELECT *
FROM FirstPurchase;



Step 2 — Customer Activity Month
/* ============================================================
   STEP 2: CUSTOMER ACTIVITY MONTH
   ============================================================ */

WITH FirstPurchase AS
(
    SELECT
        customer_id,

        MIN
        (
            DATEFROMPARTS
            (
                YEAR(order_date),
                MONTH(order_date),
                1
            )
        ) AS cohort_month

    FROM Sales.Orders

    WHERE status = 'Completed'

    GROUP BY customer_id
),

CustomerActivity AS
(
    SELECT DISTINCT
        o.customer_id,

        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        fp.cohort_month

    FROM Sales.Orders o

    JOIN FirstPurchase fp
        ON o.customer_id = fp.customer_id

    WHERE o.status = 'Completed'
)

SELECT *
FROM CustomerActivity;



Step 3 — Cohort Month Number
/* ============================================================
   STEP 3: COHORT MONTH NUMBER
   ============================================================ */

WITH FirstPurchase AS
(
    SELECT
        customer_id,

        MIN
        (
            DATEFROMPARTS
            (
                YEAR(order_date),
                MONTH(order_date),
                1
            )
        ) AS cohort_month

    FROM Sales.Orders

    WHERE status = 'Completed'

    GROUP BY customer_id
),

CustomerActivity AS
(
    SELECT DISTINCT
        o.customer_id,

        DATEFROMPARTS
        (
            YEAR(o.order_date),
            MONTH(o.order_date),
            1
        ) AS activity_month,

        fp.cohort_month

    FROM Sales.Orders o

    JOIN FirstPurchase fp
        ON o.customer_id = fp.customer_id

    WHERE o.status = 'Completed'
)

SELECT
    cohort_month,
    activity_month,

    DATEDIFF
    (
        MONTH,
        cohort_month,
        activity_month
    ) AS cohort_month_number,

    COUNT(DISTINCT customer_id)
        AS active_customers

FROM CustomerActivity

GROUP BY
    cohort_month,
    activity_month;
এখানে DATEDIFF(MONTH, ...) দিয়ে retention period বের করছি।







40. CTE
CTE = Common Table Expression।
Complex queryকে logical steps-এ ভাগ করতে সাহায্য করে।
Syntax
WITH CTE_Name AS
(
    SELECT ...
)
SELECT ...
FROM CTE_Name;
Example
/* ============================================================
   CTE
   ============================================================ */

WITH CustomerSales AS
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
)

SELECT
    customer_id,
    total_sales
FROM CustomerSales
WHERE total_sales > 1000;


CTE-এর বড় সুবিধা
        Readability
        Modular query
        Complex transformation
        Window function-এর সঙ্গে excellent combination





41. Subquery
Query-এর ভিতরে query।
/* ============================================================
   SUBQUERY
   ============================================================ */

SELECT
    customer_id,
    total_sales
FROM
(
    SELECT
        customer_id,
        SUM(sales) AS total_sales
    FROM Sales.Orders
    GROUP BY customer_id
) AS CustomerSales

WHERE total_sales > 1000;


CTE vs Subquery
CTE	                        Subquery
বেশি readable	              ছোট query-তে সহজ
Multiple steps সহজ	        Nested logic
Recursive CTE support	      সাধারণ nested query
Complex analytics-এ ভালো	  Simple filtering-এ ভালো 







42. View
View হলো saved query।
/* ============================================================
   CUSTOMER SALES VIEW
   ============================================================ */

CREATE VIEW Sales.vw_CustomerSales
AS

SELECT
    c.customer_id,
    c.customer_name,
    c.country,

    COUNT(o.order_id) AS total_orders,

    SUM(o.sales) AS total_sales,

    AVG(o.sales) AS average_order_value

FROM Sales.Customers c

LEFT JOIN Sales.Orders o
    ON c.customer_id = o.customer_id

GROUP BY
    c.customer_id,
    c.customer_name,
    c.country;
GO


  
তারপর:
SELECT *
FROM Sales.vw_CustomerSales;


View কোথায় useful?
      Reporting
      Power BI
      Reusable business logic
      Security abstraction
      Data marts






43. Stored Procedure
Reusable parameterized SQL logic।
/* ============================================================
   STORED PROCEDURE
   Customer অনুযায়ী sales report
   ============================================================ */

CREATE PROCEDURE Sales.usp_CustomerSales
    @CustomerID INT
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        c.customer_id,
        c.customer_name,
        COUNT(o.order_id) AS total_orders,
        SUM(o.sales) AS total_sales,
        AVG(o.sales) AS average_order_value

    FROM Sales.Customers c

    LEFT JOIN Sales.Orders o
        ON c.customer_id = o.customer_id

    WHERE c.customer_id = @CustomerID

    GROUP BY
        c.customer_id,
        c.customer_name;

END;
GO

  
Execute:
EXEC Sales.usp_CustomerSales
    @CustomerID = 1;






44. Temp Table
Temporary intermediate dataset রাখার জন্য।
/* ============================================================
   TEMP TABLE
   ============================================================ */

CREATE TABLE #CustomerSales
(
    customer_id INT,
    total_orders INT,
    total_sales DECIMAL(12,2)
);

INSERT INTO #CustomerSales
(
    customer_id,
    total_orders,
    total_sales
)
SELECT
    customer_id,
    COUNT(*) AS total_orders,
    SUM(sales) AS total_sales
FROM Sales.Orders
GROUP BY customer_id;

SELECT *
FROM #CustomerSales
WHERE total_sales > 1000;

Session শেষ হলে #CustomerSales automatically disappear করে।


45. Temp Table বনাম CTE বনাম View
Feature	                        CTE	              Temp Table	             View
Temporary	                      ✅	                ✅	                    ❌
Persisted definition	          ❌	                ❌	                    ✅
Multiple statements	            সীমিত	              ✅	                    Query dependent
Index করা	                      সরাসরি নয়	          ✅	                    Indexed View possible
Complex ETL	                    মাঝারি	              ⭐⭐⭐⭐⭐	            ⭐⭐⭐
Reporting	                      ⭐⭐⭐⭐	          ⭐⭐⭐	                ⭐⭐⭐⭐⭐









46. Performance Optimization
এখন সবচেয়ে গুরুত্বপূর্ণ professional part।
  
-- Index
আমাদের query frequently customer অনুযায়ী orders খুঁজছে।
/* ============================================================
   INDEX FOR CUSTOMER-BASED ANALYSIS
   ============================================================ */

CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(customer_id);


Date-based reporting:
CREATE INDEX IX_Orders_OrderDate
ON Sales.Orders(order_date);


Customer + Date:
CREATE INDEX IX_Orders_Customer_Date
ON Sales.Orders
(
    customer_id,
    order_date
);





47. Covering Index
যদি query হয়:
SELECT
    customer_id,
    order_date,
    sales
FROM Sales.Orders
WHERE customer_id = 1;


তাহলে:
CREATE INDEX IX_Orders_Customer_Covering
ON Sales.Orders(customer_id)
INCLUDE
(
    order_date,
    sales
);

এতে SQL Server অনেক ক্ষেত্রে base table lookup কমাতে পারে।







48. SELECT * Avoid করুন
❌ Bad:
SELECT *
FROM Sales.Orders;


✅ Better:
SELECT
    order_id,
    customer_id,
    order_date,
    sales
FROM Sales.Orders;






49. Function on Filtered Column Avoid
❌ অনেক ক্ষেত্রে:
WHERE YEAR(order_date) = 2025;
এতে index usage খারাপ হতে পারে।


  
✅ Better:
WHERE order_date >= '20250101'
  AND order_date <  '20260101';
এটি SARGable predicate-এর ভালো example।






50. WHERE আগে Filter করুন
❌
SELECT
    customer_id,
    SUM(sales)
FROM Sales.Orders
GROUP BY customer_id
HAVING status = 'Completed';
এটি ভুল কারণ status grouping-এর পরে filter করার জন্য HAVING-এর appropriate use নয়।


  
✅
SELECT
    customer_id,
    SUM(sales) AS total_sales
FROM Sales.Orders
WHERE status = 'Completed'
GROUP BY customer_id;







51. Execution Plan
SQL Server Management Studio-তে:
  
Ctrl + M
দিয়ে Actual Execution Plan enable করতে পারেন।
তারপর query execute করুন।
  
বিশেষভাবে দেখবেন:
Table Scan
Index Scan
Index Seek
Key Lookup
Sort
Hash Match
Nested Loops
Missing Index suggestion





52. Statistics এবং IO/Time
/* ============================================================
   PERFORMANCE TEST
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    customer_id,
    SUM(sales) AS total_sales
FROM Sales.Orders
GROUP BY customer_id;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

এতে logical reads এবং CPU/time সম্পর্কে ধারণা পাওয়া যায়।






53. সবচেয়ে গুরুত্বপূর্ণ Combined Query
এখন অনেকগুলো concept একসাথে।
Business Question
প্রতিটি country-এর customer sales, order count, average order value এবং total company sales-এর percentage বের করো।

/* ============================================================
   ADVANCED BUSINESS ANALYSIS
   GROUP BY + JOIN + WINDOW FUNCTION
   ============================================================ */

WITH CountrySales AS
(
    SELECT
        c.country,

        COUNT(o.order_id) AS total_orders,

        COUNT(DISTINCT o.customer_id)
            AS unique_customers,

        SUM(o.sales) AS total_sales,

        AVG(o.sales) AS average_order_value

    FROM Sales.Orders o

    JOIN Sales.Customers c
        ON o.customer_id = c.customer_id

    WHERE o.status = 'Completed'

    GROUP BY c.country
)

SELECT
    country,
    total_orders,
    unique_customers,
    total_sales,
    average_order_value,

    CAST
    (
        total_sales * 100.0
        / SUM(total_sales) OVER()
        AS DECIMAL(10,2)
    ) AS percentage_of_total,

    RANK() OVER
    (
        ORDER BY total_sales DESC
    ) AS country_rank

FROM CountrySales

ORDER BY country_rank;



এখানে একসাথে ব্যবহার হয়েছে:
CTE
↓
JOIN
↓
WHERE
↓
COUNT
↓
COUNT DISTINCT
↓
SUM
↓
AVG
↓
GROUP BY
↓
Window Function
↓
Percentage of Total
↓
RANK







54. Customer 360° Analysis
এটি portfolio/project-এর জন্য খুব গুরুত্বপূর্ণ।
/* ============================================================
   CUSTOMER 360 ANALYSIS
   ============================================================ */

WITH CustomerMetrics AS
(
    SELECT
        c.customer_id,
        c.customer_name,
        c.country,

        COUNT(o.order_id) AS total_orders,

        SUM(o.sales) AS total_sales,

        AVG(o.sales) AS average_order_value,

        MIN(o.order_date) AS first_order_date,

        MAX(o.order_date) AS last_order_date

    FROM Sales.Customers c

    LEFT JOIN Sales.Orders o
        ON c.customer_id = o.customer_id

    GROUP BY
        c.customer_id,
        c.customer_name,
        c.country
),

RankedCustomers AS
(
    SELECT
        *,

        RANK() OVER
        (
            ORDER BY total_sales DESC
        ) AS customer_rank

    FROM CustomerMetrics
)

SELECT
    *,
    
    CASE
        WHEN total_sales >= 1500 THEN 'VIP'
        WHEN total_sales >= 800 THEN 'Premium'
        WHEN total_sales >= 300 THEN 'Regular'
        ELSE 'Low Value'
    END AS customer_segment

FROM RankedCustomers

ORDER BY customer_rank;








55. Product Performance Analysis
/* ============================================================
   PRODUCT PERFORMANCE
   ============================================================ */

SELECT
    p.product_id,
    p.product_name,
    c.category_name,

    SUM(oi.quantity) AS total_quantity,

    SUM(oi.quantity * oi.unit_price)
        AS total_revenue,

    AVG(oi.unit_price)
        AS average_selling_price,

    COUNT(DISTINCT oi.order_id)
        AS total_orders

FROM Sales.OrderItems oi

JOIN Sales.Products p
    ON oi.product_id = p.product_id

JOIN Sales.Categories c
    ON p.category_id = c.category_id

GROUP BY
    p.product_id,
    p.product_name,
    c.category_name

ORDER BY total_revenue DESC;








56. Top 3 Products per Category
এখানে ROW_NUMBER()/RANK() খুব practical।
/* ============================================================
   TOP 3 PRODUCTS PER CATEGORY
   ============================================================ */

WITH ProductSales AS
(
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,

        SUM(oi.quantity * oi.unit_price)
            AS total_revenue

    FROM Sales.OrderItems oi

    JOIN Sales.Products p
        ON oi.product_id = p.product_id

    JOIN Sales.Categories c
        ON p.category_id = c.category_id

    GROUP BY
        p.product_id,
        p.product_name,
        c.category_name
),

RankedProducts AS
(
    SELECT
        *,

        ROW_NUMBER() OVER
        (
            PARTITION BY category_name
            ORDER BY total_revenue DESC
        ) AS rn

    FROM ProductSales
)

SELECT
    *
FROM RankedProducts
WHERE rn <= 3;





57. Employee Sales Performance
/* ============================================================
   EMPLOYEE SALES PERFORMANCE
   ============================================================ */

SELECT
    e.employee_id,
    e.employee_name,
    d.department_name,

    COUNT(o.order_id) AS total_orders,

    SUM(o.sales) AS total_sales,

    AVG(o.sales) AS average_order_value,

    RANK() OVER
    (
        ORDER BY SUM(o.sales) DESC
    ) AS sales_rank

FROM HR.Employees e

JOIN HR.Departments d
    ON e.department_id = d.department_id

LEFT JOIN Sales.Orders o
    ON e.employee_id = o.employee_id

GROUP BY
    e.employee_id,
    e.employee_name,
    d.department_name;







58. সবচেয়ে গুরুত্বপূর্ণ Priority
এই 42টি topic-এর মধ্যে সবগুলো গুরুত্বপূর্ণ হলেও বাস্তব কাজের জন্য priority এমন রাখুন:

  
🔥 Level 1 — Must Know
COUNT
SUM
AVG
MIN
MAX
GROUP BY
HAVING
COUNT DISTINCT
CASE
Conditional Aggregation
JOIN + GROUP BY
Date + GROUP BY
NULL + Aggregation


  
🔥 Level 2 — Very Important
CTE
Subquery
Window Functions
PARTITION BY
SUM() OVER()
AVG() OVER()
ROW_NUMBER
RANK
DENSE_RANK
LAG
LEAD
Running Total
Percentage of Total


  
🔥 Level 3 — Analytics
MoM
YoY
Moving Average
Customer Segmentation
Cohort Analysis
STRING_AGG
Statistical Functions
APPROX_COUNT_DISTINCT


  
🔥 Level 4 — Advanced SQL
ROLLUP
CUBE
GROUPING SETS
Views
Stored Procedures
Temp Tables
Performance Optimization
Indexes
Execution Plan
SARGability
Statistics




59. একটি গুরুত্বপূর্ণ Mental Model
এই পুরো chapter-টা এভাবে মনে রাখুন:

                SQL ANALYTICS
                     │
        ┌────────────┴────────────┐
        │                         │
   AGGREGATION              WINDOW FUNCTION
        │                         │
 COUNT / SUM / AVG          SUM() OVER()
 MIN / MAX                  AVG() OVER()
        │                    RANK()
   GROUP BY                 ROW_NUMBER()
   HAVING                   LAG()
        │                    LEAD()
        │                         │
        └────────────┬────────────┘
                     │
              BUSINESS ANALYSIS
                     │
       ┌─────────────┼──────────────┐
       │             │              │
      MoM           YoY         Segmentation
       │             │              │
 Moving Avg      Growth %       Cohort
       │             │              │
       └─────────────┴──────────────┘
                     │
              ADVANCED SQL
                     │
        CTE / Subquery / View
        Stored Procedure
        Temp Table
        Performance









60. Practice Set 🎯
এই database-এর উপর নিজে নিচের queries লিখুন।

  
Beginner
🟢 Q1: মোট customers কত?
🟢 Q2: মোট orders কত?
🟢 Q3: মোট sales কত?
🟢 Q4: average order value কত?
🟢 Q5: highest এবং lowest order কত?
🟢 Q6: customer প্রতি order count বের করুন।
🟢 Q7: customer প্রতি total sales বের করুন।

  
Intermediate
🟡 Q8: $1,000-এর বেশি sales করা customers।
🟡 Q9: country অনুযায়ী sales।
🟡 Q10: country + gender অনুযায়ী customer count।
🟡 Q11: month অনুযায়ী sales।
🟡 Q12: completed বনাম cancelled orders।
🟡 Q13: customer-এর percentage of total sales।
🟡 Q14: country rank।
🟡 Q15: customer-এর first এবং last order।

  
Advanced
🔴 Q16: customer running total।
🔴 Q17: MoM sales growth।
🔴 Q18: YoY sales growth।
🔴 Q19: 3-month moving average।
🔴 Q20: Top 3 products per category।
🔴 Q21: VIP/Premium/Regular customer segmentation।
🔴 Q22: customer cohort month।
🔴 Q23: cohort retention।
🔴 Q24: ROLLUP দিয়ে country subtotal।
🔴 Q25: CUBE দিয়ে all-level summary।
🔴 Q26: GROUPING SETS দিয়ে custom summary।
🔴 Q27: একই result CTE দিয়ে এবং Subquery দিয়ে লিখুন।
🔴 Q28: reporting-এর জন্য View তৈরি করুন।
🔴 Q29: customer report-এর Stored Procedure তৈরি করুন।
🔴 Q30: Execution Plan দেখে query optimize করুন।







সবচেয়ে গুরুত্বপূর্ণ 15টি SQL Pattern
বাস্তব চাকরির SQL-এর জন্য নিচেরগুলো সবচেয়ে বেশি practice করুন:
-- 1. Basic aggregation
SELECT COUNT(*), SUM(sales), AVG(sales)
FROM Sales.Orders;


-- 2. GROUP BY
SELECT customer_id, SUM(sales)
FROM Sales.Orders
GROUP BY customer_id;


-- 3. HAVING
SELECT customer_id, SUM(sales)
FROM Sales.Orders
GROUP BY customer_id
HAVING SUM(sales) > 1000;


-- 4. Conditional aggregation
SELECT
    SUM(CASE WHEN status = 'Completed' THEN sales ELSE 0 END)
FROM Sales.Orders;


-- 5. JOIN + GROUP BY
SELECT c.country, SUM(o.sales)
FROM Sales.Orders o
JOIN Sales.Customers c
    ON o.customer_id = c.customer_id
GROUP BY c.country;


-- 6. Window SUM
SELECT
    customer_id,
    sales,
    SUM(sales) OVER(PARTITION BY customer_id)
FROM Sales.Orders;


-- 7. Running total
SELECT
    order_date,
    sales,
    SUM(sales) OVER(
        ORDER BY order_date, order_id
    )
FROM Sales.Orders;


-- 8. ROW_NUMBER
SELECT
    *,
    ROW_NUMBER() OVER(
        PARTITION BY customer_id
        ORDER BY order_date
    ) AS rn
FROM Sales.Orders;


-- 9. RANK
SELECT
    *,
    RANK() OVER(
        ORDER BY sales DESC
    ) AS sales_rank
FROM Sales.Orders;


-- 10. LAG
SELECT
    sales,
    LAG(sales) OVER(
        ORDER BY order_date
    )
FROM Sales.Orders;


-- 11. Percentage of total
SELECT
    sales,
    sales * 100.0 / SUM(sales) OVER()
FROM Sales.Orders;


-- 12. CTE
WITH CustomerSales AS
(
    SELECT customer_id, SUM(sales) total_sales
    FROM Sales.Orders
    GROUP BY customer_id
)
SELECT *
FROM CustomerSales;


-- 13. CASE segmentation
SELECT
    customer_id,
    CASE
        WHEN SUM(sales) >= 1500 THEN 'VIP'
        WHEN SUM(sales) >= 800 THEN 'Premium'
        ELSE 'Regular'
    END
FROM Sales.Orders
GROUP BY customer_id;


-- 14. MoM
LAG(total_sales) OVER(
    ORDER BY sales_month
);


-- 15. Top N per group
ROW_NUMBER() OVER(
    PARTITION BY category_name
    ORDER BY total_revenue DESC
);

