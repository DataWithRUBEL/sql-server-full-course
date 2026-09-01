## Project Architecture
আমরা একটি ছোট E-Commerce / Retail Sales System তৈরি করব।
Business entities
Department
   ↓
Employee

Category
   ↓
Product
   ↓
OrderItem
   ↑
Order
   ↑
Customer




## আমাদের মূল Sales Formula
সবচেয়ে গুরুত্বপূর্ণ বিষয়:
Gross Sales
= Quantity × UnitPrice

Discount Amount
= Quantity × UnitPrice × DiscountPct / 100

Net Sales
= Gross Sales - Discount Amount

Cost
= Quantity × CostPrice

Profit
= Net Sales - Cost
SQL Server-এ আমরা অনেক aggregation এই formula-এর ওপর করব।





🟢 1. COUNT()
Theory
COUNT() নির্দিষ্ট expression-এর non-NULL value-এর সংখ্যা গণনা করে।
Syntax
COUNT(expression)
   
অথবা:
COUNT(*)

   
Basic example
-- ============================================================
-- Count all customers
-- Purpose:
-- Determine total number of customer records.
-- ============================================================
SELECT COUNT(*) AS TotalCustomers
FROM sales.Customers;


COUNT(*) বনাম COUNT(column)
-- ============================================================
-- Compare COUNT(*) and COUNT(EmployeeID)
-- Purpose:
-- Demonstrate how NULL values affect COUNT(column).
-- ============================================================
SELECT
    COUNT(*) AS TotalOrders,
    COUNT(EmployeeID) AS OrdersWithEmployee
FROM sales.Orders;


EmployeeID = NULL হওয়া order COUNT(EmployeeID)-তে count হবে না।
COUNT(DISTINCT)
-- ============================================================
-- Count unique customers who placed orders
-- Purpose:
-- Find how many different customers generated orders.
-- ============================================================
SELECT
    COUNT(DISTINCT CustomerID) AS UniqueCustomers
FROM sales.Orders;


Business use
- Total orders
- Unique customers
- Products sold
- Employees handling orders
- Active customers





🟢 2. SUM()
SUM() numeric values যোগ করে।
Syntax
SUM(expression)

   
Total quantity
-- ============================================================
-- Calculate total units sold
-- Purpose:
-- Measure total product volume sold.
-- ============================================================
SELECT
    SUM(Quantity) AS TotalUnitsSold
FROM sales.OrderItems;


Total sales
-- ============================================================
-- Calculate gross sales
-- Purpose:
-- Quantity multiplied by selling price gives sales value.
-- ============================================================
SELECT
    SUM(Quantity * UnitPrice) AS GrossSales
FROM sales.OrderItems;


Net sales
-- ============================================================
-- Calculate net sales after discounts
-- Purpose:
-- Measure actual revenue after line-level discounts.
-- ============================================================
SELECT
    SUM(
        Quantity * UnitPrice
        -
        Quantity * UnitPrice * ISNULL(DiscountPct,0) / 100
    ) AS NetSales
FROM sales.OrderItems;






🟢 3. AVG()
Average বের করতে AVG() ব্যবহার করা হয়।
Syntax
AVG(expression)

   
Average product price
-- ============================================================
-- Calculate average product selling price
-- Purpose:
-- Understand the average price across sold line items.
-- ============================================================
SELECT
    AVG(UnitPrice) AS AverageSellingPrice
FROM sales.OrderItems;


Average order value
এখানে সরাসরি AVG(OrderItems...) ব্যবহার করলে ভুল হতে পারে, কারণ এক order-এ multiple rows আছে।
প্রথমে order-level aggregation:
-- ============================================================
-- Calculate average order value
-- Purpose:
-- First calculate each order's revenue,
-- then calculate the average across orders.
-- ============================================================
SELECT
    AVG(OrderTotal) AS AverageOrderValue
FROM
(
    SELECT
        OrderID,
        SUM(
            Quantity * UnitPrice
            -
            Quantity * UnitPrice * ISNULL(DiscountPct,0) / 100
        ) AS OrderTotal
    FROM sales.OrderItems
    GROUP BY OrderID
) AS OrderSummary;

এটি real-world interview-এর গুরুত্বপূর্ণ concept।






🟢 4. MIN()
সবচেয়ে ছোট value বের করে।
Syntax
MIN(expression)
   
-- ============================================================
-- Find the lowest product price
-- ============================================================
SELECT
    MIN(UnitPrice) AS MinimumPrice
FROM sales.Products;



Earliest order
-- ============================================================
-- Find the earliest order date
-- Purpose:
-- Determine the beginning of the sales history.
-- ============================================================
SELECT
    MIN(OrderDate) AS FirstOrderDate
FROM sales.Orders;






🟢 5. MAX()
সবচেয়ে বড় value বের করে।
-- ============================================================
-- Find the highest product price
-- ============================================================
SELECT
    MAX(UnitPrice) AS MaximumPrice
FROM sales.Products;


Latest order
-- ============================================================
-- Find latest order date
-- ============================================================
SELECT
    MAX(OrderDate) AS LatestOrderDate
FROM sales.Orders;






🟡 6. NULL + Aggregate Functions
এটা অত্যন্ত গুরুত্বপূর্ণ।
সাধারণ aggregate functions সাধারণত NULL ignore করে।
-- ============================================================
-- Demonstrate NULL handling in AVG
-- ============================================================
SELECT
    AVG(DiscountPct) AS AverageDiscount
FROM sales.OrderItems;
NULL discount average-এর denominator-এ ধরা হয় না।



NULL vs 0
-- ============================================================
-- Compare NULL handling with explicit zero replacement
-- ============================================================
SELECT
    AVG(DiscountPct) AS AverageIgnoringNULL,
    AVG(ISNULL(DiscountPct,0)) AS AverageTreatingNULLAsZero
FROM sales.OrderItems;

⚠️ দুটির business meaning আলাদা।
Best Practice:
NULL মানে "unknown/not provided" হলে অন্ধভাবে 0 বানাবেন না।







🟢 7. GROUP BY
এখান থেকেই aggregation বাস্তবে powerful হয়।
Syntax
SELECT
    column,
    aggregate_function(...)
FROM table
GROUP BY column;


Sales by status
-- ============================================================
-- Calculate order count by order status
-- Purpose:
-- Understand completed, pending and cancelled orders.
-- ============================================================
SELECT
    OrderStatus,
    COUNT(*) AS OrderCount
FROM sales.Orders
GROUP BY OrderStatus;


Sales by payment method
-- ============================================================
-- Calculate order count by payment method
-- ============================================================
SELECT
    PaymentMethod,
    COUNT(*) AS OrderCount
FROM sales.Orders
GROUP BY PaymentMethod;




🟢 8. HAVING
WHERE row filter করে।
HAVING group filter করে।
Example
-- ============================================================
-- Find customers with more than one order
-- Purpose:
-- Identify repeat customers.
-- ============================================================
SELECT
    CustomerID,
    COUNT(*) AS OrderCount
FROM sales.Orders
GROUP BY CustomerID
HAVING COUNT(*) > 1;


WHERE + GROUP BY + HAVING
-- ============================================================
-- Find customers with more than one completed order
-- Purpose:
-- Filter rows first, then aggregate, then filter groups.
-- ============================================================
SELECT
    CustomerID,
    COUNT(*) AS CompletedOrders
FROM sales.Orders
WHERE OrderStatus = 'Completed'
GROUP BY CustomerID
HAVING COUNT(*) > 1;


Logical order
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






🟠 9. Conditional Aggregation
এটি Data Analyst-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
SUM(CASE WHEN...)
Completed vs Cancelled
-- ============================================================
-- Calculate completed and cancelled order counts
-- Purpose:
-- Produce multiple KPIs in a single query.
-- ============================================================
SELECT
    COUNT(*) AS TotalOrders,

    SUM(CASE
            WHEN OrderStatus = 'Completed'
            THEN 1 ELSE 0
        END) AS CompletedOrders,

    SUM(CASE
            WHEN OrderStatus = 'Cancelled'
            THEN 1 ELSE 0
        END) AS CancelledOrders,

    SUM(CASE
            WHEN OrderStatus = 'Pending'
            THEN 1 ELSE 0
        END) AS PendingOrders
FROM sales.Orders;



Conditional Revenue
-- ============================================================
-- Calculate revenue only from completed orders
-- Purpose:
-- Exclude cancelled/pending transactions from revenue KPI.
-- ============================================================
SELECT
    SUM
    (
        CASE
            WHEN o.OrderStatus = 'Completed'
            THEN oi.Quantity * oi.UnitPrice
            ELSE 0
        END
    ) AS CompletedGrossSales
FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID;






🟢 10. Multiple Aggregates
এক query-তে multiple aggregate ব্যবহার করা যায়।
-- ============================================================
-- Generate overall sales metrics
-- Purpose:
-- Produce several business metrics in one result.
-- ============================================================
SELECT
    COUNT(*) AS TotalLines,
    SUM(Quantity) AS TotalUnits,
    AVG(UnitPrice) AS AverageUnitPrice,
    MIN(UnitPrice) AS MinimumUnitPrice,
    MAX(UnitPrice) AS MaximumUnitPrice,
    SUM(Quantity * UnitPrice) AS GrossSales
FROM sales.OrderItems;





🟢 11. Aggregation + JOIN
এটি real-world SQL-এর core skill।
Category-wise sales
-- ============================================================
-- Calculate sales by product category
-- Purpose:
-- Join transaction data with product/category dimensions.
-- ============================================================
SELECT
    c.CategoryName,
    SUM(oi.Quantity) AS UnitsSold,
    SUM(oi.Quantity * oi.UnitPrice) AS GrossSales
FROM sales.OrderItems oi
JOIN sales.Products p
    ON oi.ProductID = p.ProductID
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID
GROUP BY
    c.CategoryName
ORDER BY
    GrossSales DESC;


Customer-wise revenue
-- ============================================================
-- Calculate revenue by customer
-- Purpose:
-- Identify high-value customers.
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Customers c
JOIN sales.Orders o
    ON c.CustomerID = o.CustomerID
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    c.CustomerID,
    c.CustomerName

ORDER BY
    NetSales DESC;






🟢 12. Date Aggregation
Yearly sales
-- ============================================================
-- Calculate yearly sales
-- Purpose:
-- Analyze annual revenue trends.
-- ============================================================
SELECT
    YEAR(o.OrderDate) AS SalesYear,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    YEAR(o.OrderDate)

ORDER BY
    SalesYear;




Monthly aggregation
-- ============================================================
-- Calculate monthly sales
-- Purpose:
-- Analyze monthly business performance.
-- ============================================================
SELECT
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    YEAR(o.OrderDate),
    MONTH(o.OrderDate)

ORDER BY
    SalesYear,
    SalesMonth;





Better SQL Server approach
DATETRUNC() ব্যবহার করা যায় SQL Server 2022+ এ।
-- ============================================================
-- Aggregate sales by month using DATETRUNC
-- Purpose:
-- Create a proper month bucket for time-series analysis.
-- ============================================================
SELECT
    DATETRUNC(MONTH, o.OrderDate) AS SalesMonth,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    DATETRUNC(MONTH, o.OrderDate)

ORDER BY
    SalesMonth;





🔵 13. Window Aggregation
Traditional aggregation:
GROUP BY
result-এর row কমিয়ে দেয়।
Window aggregation row রাখে।

   
Syntax
SUM(expression)
OVER
(
    PARTITION BY column
)


   
Customer total sales alongside each order
-- ============================================================
-- Calculate customer lifetime sales beside every order
-- Purpose:
-- Preserve order-level detail while showing customer totals.
-- ============================================================
SELECT
    o.OrderID,
    o.CustomerID,
    o.OrderDate,

    SUM(oi.Quantity * oi.UnitPrice)
        OVER
        (
            PARTITION BY o.CustomerID
        ) AS CustomerTotalSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID;



Running sales total
-- ============================================================
-- Calculate running cumulative sales
-- Purpose:
-- Track cumulative revenue over time.
-- ============================================================
WITH DailySales AS
(
    SELECT
        o.OrderDate,
        SUM(
            oi.Quantity * oi.UnitPrice
            -
            oi.Quantity * oi.UnitPrice
                * ISNULL(oi.DiscountPct,0) / 100
        ) AS DailySales

    FROM sales.Orders o
    JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY o.OrderDate
)
SELECT
    OrderDate,
    DailySales,

    SUM(DailySales)
        OVER
        (
            ORDER BY OrderDate
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS RunningSales

FROM DailySales
ORDER BY OrderDate;






🟣 14. Subquery + Aggregation
Customers above average revenue
-- ============================================================
-- Find customers whose revenue is above average customer revenue
-- Purpose:
-- Demonstrate aggregation inside a subquery.
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        o.CustomerID,
        SUM(
            oi.Quantity * oi.UnitPrice
            -
            oi.Quantity * oi.UnitPrice
                * ISNULL(oi.DiscountPct,0) / 100
        ) AS TotalSales

    FROM sales.Orders o
    JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY o.CustomerID
)
SELECT
    CustomerID,
    TotalSales
FROM CustomerSales
WHERE TotalSales >
(
    SELECT AVG(TotalSales)
    FROM CustomerSales
);


⭐ এখানে aggregation → aggregation হচ্ছে।





🟣 15. CTE + Aggregation
CTE query-কে readable এবং modular করে।
-- ============================================================
-- Calculate category sales using a CTE
-- Purpose:
-- Separate transaction calculation from reporting logic.
-- ============================================================
WITH CategorySales AS
(
    SELECT
        c.CategoryID,
        c.CategoryName,

        SUM(
            oi.Quantity * oi.UnitPrice
            -
            oi.Quantity * oi.UnitPrice
                * ISNULL(oi.DiscountPct,0) / 100
        ) AS NetSales

    FROM sales.OrderItems oi
    JOIN sales.Products p
        ON oi.ProductID = p.ProductID
    JOIN sales.Categories c
        ON p.CategoryID = c.CategoryID

    GROUP BY
        c.CategoryID,
        c.CategoryName
)
SELECT
    CategoryName,
    NetSales
FROM CategorySales
ORDER BY NetSales DESC;





🟠 16. STRING_AGG()
STRING_AGG() multiple row-এর string একত্র করে।
   
Syntax
STRING_AGG(expression, separator)


   
Products by category
-- ============================================================
-- Combine product names into one string per category
-- Purpose:
-- Create readable category-level product lists.
-- ============================================================
SELECT
    c.CategoryName,

    STRING_AGG(
        p.ProductName,
        ', '
    ) AS Products

FROM sales.Products p
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

GROUP BY
    c.CategoryName;



With ordering
SQL Server-এ:
-- ============================================================
-- Aggregate product names in a defined alphabetical order
-- ============================================================
SELECT
    c.CategoryName,

    STRING_AGG(
        p.ProductName,
        ', '
    ) WITHIN GROUP
    (
        ORDER BY p.ProductName
    ) AS Products

FROM sales.Products p
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

GROUP BY
    c.CategoryName;


Business use
- Product list
- Employee names by department
- Customer tags
- Error messages
- ETL validation reports





🟠 17. COUNT_BIG()
বড় transaction table-এ row count-এর জন্য COUNT_BIG() ব্যবহার করা হয়।
Syntax
COUNT_BIG(*)

   
-- ============================================================
-- Count transaction rows using COUNT_BIG
-- Purpose:
-- Support very large fact tables where row counts
-- may exceed INT range.
-- ============================================================
SELECT
    COUNT_BIG(*) AS TotalTransactionRows
FROM sales.OrderItems;


COUNT বনাম COUNT_BIG
   
Function	       Return type
COUNT	          INT
COUNT_BIG	    BIGINT

Data Warehouse-এর billion-row fact table-এ COUNT_BIG() গুরুত্বপূর্ণ।







🔴 18. GROUPING SETS
এক query-তে multiple grouping level তৈরি করা যায়।
-- ============================================================
-- Generate sales by category, payment method,
-- and overall total using GROUPING SETS.
-- ============================================================
SELECT
    c.CategoryName,
    o.PaymentMethod,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN sales.Products p
    ON oi.ProductID = p.ProductID
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

WHERE o.OrderStatus = 'Completed'

GROUP BY GROUPING SETS
(
    (c.CategoryName),
    (o.PaymentMethod),
    ()
);

() = grand total।





🔴 19. ROLLUP
Hierarchical subtotal তৈরি করে।
ধরুন:
Year
 └── Month
   
-- ============================================================
-- Generate yearly and monthly sales subtotals
-- Purpose:
-- Produce hierarchical time-based aggregation.
-- ============================================================
SELECT
    YEAR(o.OrderDate) AS SalesYear,
    MONTH(o.OrderDate) AS SalesMonth,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY ROLLUP
(
    YEAR(o.OrderDate),
    MONTH(o.OrderDate)
)

ORDER BY
    SalesYear,
    SalesMonth;


Concept:
Year + Month
Year subtotal
Grand total






🔴 20. CUBE
সব possible combination তৈরি করে।
যেমন:
Category
PaymentMethod

   
CUBE তৈরি করতে পারে:
Category + PaymentMethod
Category
PaymentMethod
Grand Total

   
-- ============================================================
-- Generate multidimensional sales analysis
-- Purpose:
-- Analyze sales across every combination of
-- category and payment method.
-- ============================================================
SELECT
    c.CategoryName,
    o.PaymentMethod,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN sales.Products p
    ON oi.ProductID = p.ProductID
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

WHERE o.OrderStatus = 'Completed'

GROUP BY CUBE
(
    c.CategoryName,
    o.PaymentMethod
);



GROUPING() দিয়ে subtotal চেনা
NULL দেখলেই actual NULL ধরে নেওয়া ঠিক নয়।
ROLLUP/CUBE subtotal row তৈরি করলে NULL আসতে পারে।
-- ============================================================
-- Identify subtotal/grand-total rows generated by ROLLUP
-- Purpose:
-- Distinguish real NULL values from aggregation NULLs.
-- ============================================================
SELECT
    c.CategoryName,
    o.PaymentMethod,

    GROUPING(c.CategoryName) AS IsCategorySubtotal,
    GROUPING(o.PaymentMethod) AS IsPaymentSubtotal,

    SUM(oi.Quantity * oi.UnitPrice) AS GrossSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN sales.Products p
    ON oi.ProductID = p.ProductID
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

GROUP BY ROLLUP
(
    c.CategoryName,
    o.PaymentMethod
);






🟢 21. Business KPI
এখন aggregate functions দিয়ে actual business dashboard KPI বানাব।
KPI Query
-- ============================================================
-- Generate core business KPIs
-- Purpose:
-- Produce dashboard-ready sales metrics.
-- ============================================================
SELECT

    -- Total number of orders
    COUNT(DISTINCT CASE
        WHEN o.OrderStatus = 'Completed'
        THEN o.OrderID
    END) AS TotalCompletedOrders,

   
    -- Total unique customers
    COUNT(DISTINCT CASE
        WHEN o.OrderStatus = 'Completed'
        THEN o.CustomerID
    END) AS ActiveCustomers,

   
    -- Total units sold
    SUM(CASE
        WHEN o.OrderStatus = 'Completed'
        THEN oi.Quantity
        ELSE 0
    END) AS TotalUnitsSold,

   
    -- Gross revenue
    SUM(CASE
        WHEN o.OrderStatus = 'Completed'
        THEN oi.Quantity * oi.UnitPrice
        ELSE 0
    END) AS GrossRevenue,

   
    -- Discount amount
    SUM(CASE
        WHEN o.OrderStatus = 'Completed'
        THEN oi.Quantity * oi.UnitPrice
             * ISNULL(oi.DiscountPct,0) / 100
        ELSE 0
    END) AS TotalDiscount,

   
    -- Net revenue
    SUM(CASE
        WHEN o.OrderStatus = 'Completed'
        THEN
            oi.Quantity * oi.UnitPrice
            -
            oi.Quantity * oi.UnitPrice
                * ISNULL(oi.DiscountPct,0) / 100
        ELSE 0
    END) AS NetRevenue

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID;




💰 Average Order Value — AOV
AOV:
AOV = Total Revenue / Total Orders
-- ============================================================
-- Calculate Average Order Value
-- Purpose:
-- Measure average revenue generated per completed order.
-- ============================================================
SELECT
    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    )
    /
    NULLIF(COUNT(DISTINCT o.OrderID),0)
    AS AverageOrderValue

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed';
NULLIF() এখানে division-by-zero protection দেয়।




📈 Order Cancellation Rate
-- ============================================================
-- Calculate order cancellation rate
-- Purpose:
-- Monitor operational/customer order cancellation behavior.
-- ============================================================
SELECT
    100.0 *
    SUM(CASE
            WHEN OrderStatus = 'Cancelled'
            THEN 1
            ELSE 0
        END)
    /
    NULLIF(COUNT(*),0)
    AS CancellationRatePct
FROM sales.Orders;



💵 Profit KPI
-- ============================================================
-- Calculate revenue, cost and profit
-- Purpose:
-- Measure commercial profitability.
-- ============================================================
SELECT

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetRevenue,

    SUM(
        oi.Quantity * p.CostPrice
    ) AS TotalCost,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
        -
        oi.Quantity * p.CostPrice
    ) AS GrossProfit

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN sales.Products p
    ON oi.ProductID = p.ProductID

WHERE o.OrderStatus = 'Completed';







🏢 22. Data Warehouse Aggregation
Data Warehouse-এ সাধারণ architecture:
OLTP
  ↓
Bronze
  ↓
Silver
  ↓
Gold
  ↓
Power BI / Reporting
   
Aggregation সাধারণত Gold/reporting layer-এ খুব গুরুত্বপূর্ণ।

   
উদাহরণ:
FactSales
   ↓
Daily Sales Aggregate
   ↓
Monthly Sales Aggregate
   ↓
Business KPI



🟣 Example: Gold Monthly Sales Aggregate
-- ============================================================
-- Create a monthly sales aggregate table
-- Purpose:
-- Store pre-aggregated monthly metrics for reporting.
-- This is a simplified Data Warehouse example.
-- ============================================================
CREATE TABLE sales.MonthlySalesAggregate
(
    SalesMonth       DATE,
    TotalOrders      BIGINT,
    TotalUnits       BIGINT,
    GrossSales       DECIMAL(18,2),
    TotalDiscount    DECIMAL(18,2),
    NetSales         DECIMAL(18,2)
);


GO

   
Populate:
-- ============================================================
-- Populate the monthly sales aggregate table
-- Purpose:
-- Transform transaction-level data into reporting-level data.
-- ============================================================
INSERT INTO sales.MonthlySalesAggregate
(
    SalesMonth,
    TotalOrders,
    TotalUnits,
    GrossSales,
    TotalDiscount,
    NetSales
)
SELECT
    DATETRUNC(MONTH, o.OrderDate) AS SalesMonth,

    COUNT(DISTINCT o.OrderID) AS TotalOrders,

    SUM(oi.Quantity) AS TotalUnits,

    SUM(oi.Quantity * oi.UnitPrice) AS GrossSales,

    SUM(
        oi.Quantity * oi.UnitPrice
        * ISNULL(oi.DiscountPct,0) / 100
    ) AS TotalDiscount,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    DATETRUNC(MONTH, o.OrderDate);






🟣 23. ETL Aggregation
Data Engineer হিসেবে ETL pipeline-এ aggregation ব্যবহার হবে।
   
Example flow
Raw Orders
    ↓
Validate
    ↓
Clean
    ↓
Join Product
    ↓
Calculate Revenue
    ↓
Aggregate
    ↓
Gold Monthly Sales


   
ETL-style transformation
-- ============================================================
-- ETL transformation:
-- Aggregate completed transactions by month and category.
-- Purpose:
-- Prepare data for a reporting/BI layer.
-- ============================================================
SELECT
    DATETRUNC(MONTH, o.OrderDate) AS SalesMonth,
    c.CategoryID,
    c.CategoryName,

    COUNT(DISTINCT o.OrderID) AS OrderCount,

    SUM(oi.Quantity) AS UnitsSold,

    SUM(oi.Quantity * oi.UnitPrice) AS GrossSales,

    SUM(
        oi.Quantity * oi.UnitPrice
        * ISNULL(oi.DiscountPct,0) / 100
    ) AS DiscountAmount,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales

FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
JOIN sales.Products p
    ON oi.ProductID = p.ProductID
JOIN sales.Categories c
    ON p.CategoryID = c.CategoryID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    DATETRUNC(MONTH, o.OrderDate),
    c.CategoryID,
    c.CategoryName;







⚡ 24. Performance Optimization
Aggregate query বড় data-তে expensive হতে পারে।

   
24.1 Index
যদি বারবার OrderDate, OrderStatus, CustomerID দিয়ে aggregation হয়:
-- ============================================================
-- Create an index to support filtering and aggregation
-- Purpose:
-- Improve access to order status/date/customer data.
-- ============================================================
CREATE INDEX IX_Orders_Status_Date_Customer
ON sales.Orders
(
    OrderStatus,
    OrderDate,
    CustomerID
);



24.2 JOIN columns index
-- ============================================================
-- Index OrderItems.OrderID
-- Purpose:
-- Improve joins between Orders and OrderItems.
-- ============================================================
CREATE INDEX IX_OrderItems_OrderID
ON sales.OrderItems(OrderID);



24.3 Product lookup
-- ============================================================
-- Index OrderItems.ProductID
-- Purpose:
-- Improve product-level aggregation and joins.
-- ============================================================
CREATE INDEX IX_OrderItems_ProductID
ON sales.OrderItems(ProductID);



⚡ 24.4 SELECT * Avoid করুন
❌ Bad:
-- Avoid selecting unnecessary columns during aggregation.
SELECT *
FROM sales.OrderItems;


✅ Better:
-- ============================================================
-- Select only columns required for the aggregation.
-- ============================================================
SELECT
    ProductID,
    Quantity,
    UnitPrice
FROM sales.OrderItems;



⚡ 24.5 Filter Early
❌
-- ============================================================
-- Less efficient pattern:
-- aggregate all statuses and filter afterward.
-- ============================================================
SELECT
    CustomerID,
    SUM(Quantity)
FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
GROUP BY CustomerID;




যদি শুধু Completed দরকার:
✅
-- ============================================================
-- Better pattern:
-- filter completed orders before aggregation.
-- ============================================================
SELECT
    o.CustomerID,
    SUM(oi.Quantity) AS UnitsSold
FROM sales.Orders o
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID
WHERE o.OrderStatus = 'Completed'
GROUP BY o.CustomerID;




⚡ 24.6 COUNT vs COUNT_BIG
Small/medium tables
        ↓
COUNT()

Very large fact tables
        ↓
COUNT_BIG()


   
⚡ 24.7 Execution Plan
Aggregation performance investigate করার সময়:
Actual Execution Plan
        ↓
Scan/Seek
        ↓
Join
        ↓
Sort
        ↓
Hash Match / Stream Aggregate


   
বিশেষভাবে দেখবেন:
- Table Scan
- Index Scan
- Index Seek
- Hash Match
- Sort
- Stream Aggregate
- Memory Grant
- Estimated vs Actual Rows





🚀 25. Real Project — Sales Performance Analytics
এখন পুরো শেখা concept একত্র করে একটি real project query তৈরি করি।
Project Requirement
Management চায়:
"Completed sales-এর ওপর ভিত্তি করে customer, category এবং monthly performance দেখতে চাই।"

   
Project Query 1 — Customer Performance
-- ============================================================
-- CUSTOMER SALES PERFORMANCE
-- Business Question:
-- Which customers generate the most revenue?
-- ============================================================
SELECT
    c.CustomerID,
    c.CustomerName,
    c.CustomerSegment,

    COUNT(DISTINCT o.OrderID) AS TotalOrders,

    SUM(oi.Quantity) AS TotalUnits,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales,

    AVG(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS AverageLineValue

FROM sales.Customers c
JOIN sales.Orders o
    ON c.CustomerID = o.CustomerID
JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    c.CustomerID,
    c.CustomerName,
    c.CustomerSegment

ORDER BY
    NetSales DESC;




Project Query 2 — Product Performance
-- ============================================================
-- PRODUCT PERFORMANCE
-- Business Question:
-- Which products generate the most revenue and profit?
-- ============================================================
SELECT
    p.ProductID,
    p.ProductName,

    SUM(oi.Quantity) AS UnitsSold,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales,

    SUM(
        oi.Quantity * p.CostPrice
    ) AS TotalCost,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
        -
        oi.Quantity * p.CostPrice
    ) AS GrossProfit

FROM sales.Products p
JOIN sales.OrderItems oi
    ON p.ProductID = oi.ProductID
JOIN sales.Orders o
    ON oi.OrderID = o.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    p.ProductID,
    p.ProductName

ORDER BY
    GrossProfit DESC;





Project Query 3 — Category KPI
-- ============================================================
-- CATEGORY KPI REPORT
-- Business Question:
-- Which product categories perform best?
-- ============================================================
SELECT
    c.CategoryName,

    COUNT(DISTINCT o.OrderID) AS Orders,

    SUM(oi.Quantity) AS UnitsSold,

    SUM(
        oi.Quantity * oi.UnitPrice
    ) AS GrossSales,

    SUM(
        oi.Quantity * oi.UnitPrice
        * ISNULL(oi.DiscountPct,0) / 100
    ) AS DiscountAmount,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
    ) AS NetSales,

    SUM(
        oi.Quantity * oi.UnitPrice
        -
        oi.Quantity * oi.UnitPrice
            * ISNULL(oi.DiscountPct,0) / 100
        -
        oi.Quantity * p.CostPrice
    ) AS GrossProfit

FROM sales.Categories c
JOIN sales.Products p
    ON c.CategoryID = p.CategoryID
JOIN sales.OrderItems oi
    ON p.ProductID = oi.ProductID
JOIN sales.Orders o
    ON oi.OrderID = o.OrderID

WHERE o.OrderStatus = 'Completed'

GROUP BY
    c.CategoryName

ORDER BY
    NetSales DESC;




📊 Project Query 4 — Monthly KPI + Running Total
-- ============================================================
-- MONTHLY SALES KPI WITH RUNNING TOTAL
-- Business Question:
-- How is monthly revenue changing over time?
-- ============================================================
WITH MonthlySales AS
(
    SELECT
        DATETRUNC(MONTH, o.OrderDate) AS SalesMonth,

        COUNT(DISTINCT o.OrderID) AS TotalOrders,

        SUM(oi.Quantity) AS TotalUnits,

        SUM(
            oi.Quantity * oi.UnitPrice
            -
            oi.Quantity * oi.UnitPrice
                * ISNULL(oi.DiscountPct,0) / 100
        ) AS NetSales

    FROM sales.Orders o
    JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY
        DATETRUNC(MONTH, o.OrderDate)
)
SELECT
    SalesMonth,
    TotalOrders,
    TotalUnits,
    NetSales,

    SUM(NetSales)
        OVER
        (
            ORDER BY SalesMonth
            ROWS BETWEEN UNBOUNDED PRECEDING
                     AND CURRENT ROW
        ) AS RunningNetSales

FROM MonthlySales

ORDER BY SalesMonth;






🧠 Aggregate Functions — কোনটা কখন?
   
Function/Concept	           কখন ব্যবহার করবেন
COUNT()	                    কতগুলো row/entity
COUNT(DISTINCT)	           কতগুলো unique entity
COUNT_BIG()	                 খুব বড় row count
SUM()	                       Total amount/quantity
AVG()	                       Average
MIN()	                       Lowest/Earliest
MAX()	                       Highest/Latest
GROUP BY	                    Group-level analysis
HAVING	                    Aggregate result filter
CASE + SUM	                 Conditional KPI
JOIN + Aggregate	           Dimension-wise analysis
Date + Aggregate	           Time-series KPI
Window SUM()	              Running/partition total
Subquery + Aggregate	        Compare against aggregate
CTE + Aggregate	           Multi-step analytics
STRING_AGG()	              Multiple strings → one string
GROUPING SETS	              Selected aggregation levels
ROLLUP	                    Hierarchical subtotals
CUBE	                       All dimensional combinations





🔥 সবচেয়ে গুরুত্বপূর্ণ Interview Concepts
   
1. COUNT(*) vs COUNT(column)
Question: Difference?
Answer:
- COUNT(*) → rows count করে
- COUNT(column) → non-NULL values count করে 



   
2. WHERE vs HAVING
WHERE
→ filters rows
→ before GROUP BY

HAVING
→ filters groups
→ after GROUP BY


   
3. GROUP BY কেন লাগে?
যখন আপনি জানতে চান:
"প্রতি customer কত sales?"

তখন:
GROUP BY CustomerID


   
4. AVG কেন কখনও misleading?
যদি order-level average চান কিন্তু line-level data থাকে:
Order 1 → 10 items
Order 2 → 1 item
সরাসরি line-level AVG() business-wise ভুল metric হতে পারে।
প্রথমে:
Order-level total
       ↓
AVG(order total)




🎯 Practice Problems
এগুলো নিজে solve করা খুব গুরুত্বপূর্ণ।

   
🟢 Beginner
1. মোট customer কত?
2. মোট order কত?
3. মোট product কত?
4. মোট units sold কত?
5. সর্বোচ্চ product price কত?
6. সর্বনিম্ন product price কত?
7. average product price কত?


🟡 Intermediate
8. Customer-wise order count বের করুন।
9. Category-wise units sold বের করুন।
10. Category-wise revenue বের করুন।
11. Payment method-wise orders বের করুন।
12. Employee-wise completed orders বের করুন।
13. যেসব customer 1-এর বেশি order করেছে তাদের বের করুন।
14. যেসব product-এর sales average product sales-এর চেয়ে বেশি তাদের বের করুন।
15. Monthly revenue বের করুন।

   
🔴 Advanced
16. Completed vs Cancelled order percentage বের করুন।
17. Customer-wise AOV বের করুন।
18. Category-wise gross profit বের করুন।
19. Monthly running revenue বের করুন।
20. Category + Payment Method CUBE করুন।
21. Year + Month ROLLUP করুন।
22. Category + Payment Method GROUPING SETS করুন।
23. প্রতিটি category-এর সব product STRING_AGG() করুন।
24. Customer total sales প্রতিটি order-এর পাশে দেখান।
25. Above-average customer revenue বের করুন।
26. Monthly sales-এর সাথে running total দেখান।
27. Category-wise revenue ranking তৈরি করুন।
28. Completed order-এর cancellation rate বের করুন।
29. Total revenue, discount, cost এবং profit একই query-তে বের করুন।
30. একটি Management Sales KPI Report তৈরি করুন।






## Final Mental Model
এই পুরো chapter-টি এভাবে মনে রাখুন:
                  AGGREGATION
                       │
        ┌──────────────┴──────────────┐
        ↓                             ↓
   Basic Aggregate              Group Aggregate
        │                             │
 COUNT / SUM / AVG              GROUP BY
 MIN / MAX                           │
        │                         HAVING
        ↓                             │
   NULL Handling                      ↓
        │                       Conditional
        ↓                       Aggregation
        │                             │
        └──────────────┬──────────────┘
                       ↓
                  JOIN + Aggregate
                       ↓
                  Date Aggregate
                       ↓
                 Window Aggregate
                       ↓
              Subquery / CTE Aggregate
                       ↓
                STRING_AGG
                       ↓
              COUNT_BIG
                       ↓
          GROUPING SETS / ROLLUP / CUBE
                       ↓
                  Business KPI
                       ↓
             Data Warehouse Gold
                       ↓
                ETL Aggregation
                       ↓
              Performance Tuning
                       ↓
              Real BI Reporting



Aggregate Functions
1. COUNT
2. SUM
3. AVG
4. MIN
5. MAX
   ↓
6. NULL + Aggregates
   ↓
7. GROUP BY
   ↓
8. HAVING
   ↓
9. Conditional Aggregation
   ↓
10. Multiple Aggregates
    ↓
11. Aggregation + JOIN
    ↓
12. Date Aggregation
    ↓
13. Window Aggregation
    ↓
14. Subquery + Aggregation
    ↓
15. CTE + Aggregation
    ↓
16. STRING_AGG
17. COUNT_BIG
18. GROUPING SETS
19. ROLLUP
20. CUBE
    ↓
21. Business KPI
    ↓
22. Data Warehouse Aggregation
    ↓
23. ETL Aggregation
    ↓
24. Performance Optimization
    ↓
25. Real Project + Interview

