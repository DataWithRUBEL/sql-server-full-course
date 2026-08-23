1. PIVOT / UNPIVOT কী?
🔄 PIVOT
Long format → Wide format

  
উদাহরণ:
Year	Month	Sales
2025	Jan	12000
2025	Feb	15000
2025	Mar	18000


PIVOT করলে:
Year	Jan	Feb	Mar
2025	12000	15000	18000


🎯 Data Analyst
Dashboard/report-এর জন্য খুব useful।


🎯 Data Engineer
Reporting layer বা downstream BI consumption-এর জন্য transformation করতে ব্যবহার করা যায়।







2. UNPIVOT কী?
Wide format → Long format
আগের:
Year	Jan	Feb	Mar
2025	12000	15000	18000


UNPIVOT করলে:
Year	Month	Sales
2025	Jan	12000
2025	Feb	15000
2025	Mar	18000


সহজভাবে
PIVOT
Long → Wide

UNPIVOT
Wide → Long








3. কেন PIVOT / UNPIVOT ব্যবহার করবো?
- 📊 Reporting: Month/Year/Category columns তৈরি করা
- 📈 Dashboard: Power BI/Excel-friendly output
- 🔄 ETL: Wide source data normalize করা
- 🏢 Warehouse: Staging data থেকে fact-friendly structure
- 🧹 Transformation: Data shape পরিবর্তন
- ⚡ Analysis: Category/month comparison সহজ করা
- 🔧 Dynamic Reporting: Dynamic columns তৈরি করা






4. Complete Database Architecture
Pivot-UnpivotDB
│
├── sales
│   ├── Customers
│   ├── Categories
│   ├── Products
│   ├── Orders
│   └── OrderItems
│
├── hr
│   └── Employees
│
├── stg
│   └── MonthlySalesWide
│
├── dw
│   ├── DimDate
│   ├── DimCustomer
│   ├── DimProduct
│   ├── DimEmployee
│   └── FactSales
│
└── rpt
    └── Reporting Views






5. Database Verify করুন
USE Pivot-UnpivotDB;
GO

SELECT COUNT(*) AS Customers
FROM sales.Customers;

SELECT COUNT(*) AS Products
FROM sales.Products;

SELECT COUNT(*) AS Orders
FROM sales.Orders;

SELECT COUNT(*) AS OrderItems
FROM sales.OrderItems;

SELECT COUNT(*) AS Employees
FROM hr.Employees;

SELECT COUNT(*) AS FactRows
FROM dw.FactSales;


Expected roughly:
Customers    120
Products     100
Orders       500
OrderItems   1500
Employees    60
FactRows     1500







6. Complete PIVOT / UNPIVOT Roadmap
এখন আপনার দেওয়া 34-step roadmap একে একে practice করি।
LEVEL 1 — Long vs Wide Data
1. Long Data
SELECT
    SalesYear,
    Region,
    MonthName,
    SalesAmount
FROM
(
    SELECT
        SalesYear,
        Region,
        JanSales,
        FebSales,
        MarSales
    FROM stg.MonthlySalesWide
) S
UNPIVOT
(
    SalesAmount
    FOR MonthName IN
    (
        JanSales,
        FebSales,
        MarSales
    )
) U;


Result:
SalesYear	Region	MonthName	SalesAmount
2025	Central	JanSales	120000
2025	Central	FebSales	135000
2025	Central	MarSales	142000

এটাই Long Format।




2. Wide Data
PIVOT:
SELECT
    SalesYear,
    Region,
    [JanSales],
    [FebSales],
    [MarSales]
FROM
(
    SELECT
        SalesYear,
        Region,
        JanSales,
        FebSales,
        MarSales
    FROM stg.MonthlySalesWide
) S
UNPIVOT
(
    SalesAmount
    FOR MonthName IN
    (
        JanSales,
        FebSales,
        MarSales
    )
) U
PIVOT
(
    SUM(SalesAmount)
    FOR MonthName IN
    (
        [JanSales],
        [FebSales],
        [MarSales]
    )
) P;






LEVEL 2 — PIVOT Fundamentals & Syntax
Basic Syntax
SELECT
    <grouping_columns>,
    [Column1],
    [Column2]
FROM
(
    SELECT
        <grouping_columns>,
        <pivot_column>,
        <value_column>
    FROM TableName
) Source
PIVOT
(
    AGGREGATE_FUNCTION(value_column)
    FOR pivot_column IN
    (
        [Column1],
        [Column2]
    )
) P;


মনে রাখবেন
PIVOT
│
├── Grouping Column
├── Pivot Column
├── Value Column
└── Aggregate Function






LEVEL 3 — UNPIVOT Fundamentals
SELECT
    SalesYear,
    Region,
    MonthName,
    SalesAmount
FROM stg.MonthlySalesWide
UNPIVOT
(
    SalesAmount
    FOR MonthName IN
    (
        JanSales,
        FebSales,
        MarSales,
        AprSales
    )
) U;





LEVEL 5 — SUM + PIVOT
সবচেয়ে common business scenario।
SELECT
    Region,
    [2025],
    [2026]
FROM
(
    SELECT
        C.Region,
        YEAR(O.OrderDate) AS SalesYear,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.Customers C
        ON C.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR SalesYear IN
    (
        [2025],
        [2026]
    )
) P;

Business Question
প্রতিটি region-এর 2025 বনাম 2026 sales কত?






LEVEL 6 — COUNT + PIVOT
প্রতি region কত order করেছে?
SELECT
    Region,
    [Completed],
    [Pending],
    [Cancelled]
FROM
(
    SELECT
        C.Region,
        O.OrderStatus,
        O.OrderID
    FROM sales.Orders O

    JOIN sales.Customers C
        ON C.CustomerID = O.CustomerID
) S
PIVOT
(
    COUNT(OrderID)
    FOR OrderStatus IN
    (
        [Completed],
        [Pending],
        [Cancelled]
    )
) P;







LEVEL 7 — AVG + PIVOT
প্রতি category-এর average product price:
SELECT
    CategoryName,
    [Central],
    [North],
    [South],
    [West]
FROM
(
    SELECT
        P.ProductID,
        C.CategoryName,
        CU.Region,
        P.UnitPrice
    FROM sales.Products P

    JOIN sales.Categories C
        ON C.CategoryID = P.CategoryID

    CROSS JOIN
    (
        SELECT DISTINCT Region
        FROM sales.Customers
    ) CU
) S
PIVOT
(
    AVG(UnitPrice)
    FOR Region IN
    (
        [Central],
        [North],
        [South],
        [West]
    )
) P;






LEVEL 8 — Monthly PIVOT
এটি Data Analyst-এর সবচেয়ে গুরুত্বপূর্ণ PIVOT scenario।
SELECT
    SalesYear,
    [1]  AS January,
    [2]  AS February,
    [3]  AS March,
    [4]  AS April,
    [5]  AS May,
    [6]  AS June,
    [7]  AS July,
    [8]  AS August,
    [9]  AS September,
    [10] AS October,
    [11] AS November,
    [12] AS December
FROM
(
    SELECT
        YEAR(O.OrderDate) AS SalesYear,
        MONTH(O.OrderDate) AS SalesMonth,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR SalesMonth IN
    (
        [1],[2],[3],[4],[5],[6],
        [7],[8],[9],[10],[11],[12]
    )
) P
ORDER BY SalesYear;







LEVEL 9 — Yearly PIVOT
SELECT
    Region,
    [2024],
    [2025],
    [2026]
FROM
(
    SELECT
        C.Region,
        YEAR(O.OrderDate) AS SalesYear,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.Customers C
        ON C.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR SalesYear IN
    (
        [2024],
        [2025],
        [2026]
    )
) P;







LEVEL 10 — Category PIVOT
Category অনুযায়ী sales:
SELECT
    SalesYear,
    [Electronics],
    [Computers],
    [Mobile Accessories],
    [Home Appliances],
    [Furniture],
    [Office Supplies],
    [Sports],
    [Clothing],
    [Beauty],
    [Grocery]
FROM
(
    SELECT
        YEAR(O.OrderDate) AS SalesYear,
        C.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories C
        ON C.CategoryID = P.CategoryID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        [Electronics],
        [Computers],
        [Mobile Accessories],
        [Home Appliances],
        [Furniture],
        [Office Supplies],
        [Sports],
        [Clothing],
        [Beauty],
        [Grocery]
    )
) P;








LEVEL 11 — Multiple Dimensions
ধরা যাক:
Region
+
Year
+
Category
SELECT
    Region,
    SalesYear,
    [Electronics],
    [Computers],
    [Furniture]
FROM
(
    SELECT
        CU.Region,
        YEAR(O.OrderDate) AS SalesYear,
        C.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.Customers CU
        ON CU.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories C
        ON C.CategoryID = P.CategoryID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        [Electronics],
        [Computers],
        [Furniture]
    )
) P
ORDER BY Region, SalesYear;








LEVEL 12 — NULL Handling
PIVOT-এর খুব common সমস্যা:
NULL
যদি কোনো category/month-এ sales না থাকে:
NULL
দেখাতে পারে।

  
Solution:
SELECT
    Region,
    ISNULL([Electronics],0) AS Electronics,
    ISNULL([Computers],0) AS Computers,
    ISNULL([Furniture],0) AS Furniture
FROM
(
    SELECT
        C.Region,
        CAT.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.Customers C
        ON C.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories CAT
        ON CAT.CategoryID = P.CategoryID
) S
PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        [Electronics],
        [Computers],
        [Furniture]
    )
) P;







LEVEL 13 — PIVOT + JOIN
WITH SalesData AS
(
    SELECT
        C.Region,
        CAT.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.Customers C
        ON C.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories CAT
        ON CAT.CategoryID = P.CategoryID
)
SELECT
    Region,
    [Electronics],
    [Computers],
    [Furniture]
FROM SalesData
PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        [Electronics],
        [Computers],
        [Furniture]
    )
) P;







LEVEL 14 — PIVOT + CTE
CTE দিয়ে query readable করা যায়।
WITH SalesCTE AS
(
    SELECT
        YEAR(O.OrderDate) AS SalesYear,
        MONTH(O.OrderDate) AS SalesMonth,
        OI.Quantity * OI.UnitPrice AS SalesAmount
    FROM sales.Orders O

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID
)
SELECT
    SalesYear,
    [1],
    [2],
    [3],
    [4],
    [5],
    [6]
FROM SalesCTE
PIVOT
(
    SUM(SalesAmount)
    FOR SalesMonth IN
    (
        [1],[2],[3],[4],[5],[6]
    )
) P
ORDER BY SalesYear;









LEVEL 15 — PIVOT + CASE
PIVOT-এর alternative:
SELECT
    C.Region,

    SUM(
        CASE
            WHEN CAT.CategoryName = 'Electronics'
            THEN OI.Quantity * OI.UnitPrice
            ELSE 0
        END
    ) AS ElectronicsSales,

    SUM(
        CASE
            WHEN CAT.CategoryName = 'Computers'
            THEN OI.Quantity * OI.UnitPrice
            ELSE 0
        END
    ) AS ComputerSales,

    SUM(
        CASE
            WHEN CAT.CategoryName = 'Furniture'
            THEN OI.Quantity * OI.UnitPrice
            ELSE 0
        END
    ) AS FurnitureSales

FROM sales.Orders O

JOIN sales.Customers C
    ON C.CustomerID = O.CustomerID

JOIN sales.OrderItems OI
    ON OI.OrderID = O.OrderID

JOIN sales.Products P
    ON P.ProductID = OI.ProductID

JOIN sales.Categories CAT
    ON CAT.CategoryID = P.CategoryID

GROUP BY
    C.Region;







LEVEL 16 — Conditional Aggregation
এটি অত্যন্ত গুরুত্বপূর্ণ।
অনেক production query-তে:
SUM(CASE WHEN ...)
PIVOT-এর চেয়ে বেশি readable হতে পারে।

  
PIVOT বনাম CASE
PIVOT	                      Conditional Aggregation
Short	                      Flexible
Reporting-friendly	        Production-friendly
Fixed columns	              Complex conditions সহজ
Dynamic PIVOT সম্ভব	        Dynamic SQL ছাড়াও অনেক ক্ষেত্রে কাজ করে
Syntax একটু specialized	    SQL knowledge বেশি transferable







LEVEL 17 — PIVOT + Window Functions
প্রথমে PIVOT:
WITH MonthlySales AS
(
    SELECT
        YEAR(O.OrderDate) AS SalesYear,
        MONTH(O.OrderDate) AS SalesMonth,
        SUM(OI.Quantity * OI.UnitPrice) AS SalesAmount
    FROM sales.Orders O

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    GROUP BY
        YEAR(O.OrderDate),
        MONTH(O.OrderDate)
),
Pivoted AS
(
    SELECT
        SalesYear,
        [1],
        [2],
        [3]
    FROM MonthlySales
    PIVOT
    (
        SUM(SalesAmount)
        FOR SalesMonth IN
        (
            [1],[2],[3]
        )
    ) P
)
SELECT *
FROM Pivoted;
তারপর Window Function দিয়ে comparison করা যায়।






LEVEL 18 — Dynamic PIVOT 🔥
এটাই Advanced SQL।
Static PIVOT:
[Electronics],
[Computers],
[Furniture]
সমস্যা হলো নতুন category এলে manually query modify করতে হয়।
Dynamic PIVOT automatically columns তৈরি করতে পারে।








LEVEL 19 — QUOTENAME()
Dynamic SQL-এর গুরুত্বপূর্ণ function:
SELECT
    QUOTENAME(CategoryName)
FROM sales.Categories;


Output:
[Electronics]
[Computers]
[Mobile Accessories]

  
...
কেন?
Column identifier safely তৈরি করতে:
QUOTENAME()
ব্যবহার করা ভালো practice।








LEVEL 20 — STRING_AGG()
সব category এক string-এ:
SELECT
    STRING_AGG(
        QUOTENAME(CategoryName),
        ','
    ) AS ColumnList
FROM sales.Categories;

Result:
[Electronics],[Computers],[Mobile Accessories],...







LEVEL 21 — sp_executesql
Dynamic SQL execute করতে:
DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT *
FROM sales.Customers;
';

EXEC sys.sp_executesql @SQL;
EXEC() এর তুলনায় production environment-এ sp_executesql 
সাধারণত preferable, বিশেষ করে parameterization দরকার হলে।









LEVEL 22 — Complete Dynamic PIVOT
DECLARE @Columns NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

/* ------------------------------------------------------------
   Dynamically generate category columns
   ------------------------------------------------------------ */

SELECT
    @Columns =
        STRING_AGG(
            QUOTENAME(CategoryName),
            ','
        )
FROM sales.Categories;


/* ------------------------------------------------------------
   Build Dynamic PIVOT
   ------------------------------------------------------------ */

SET @SQL = N'
SELECT
    Region,
    ' + @Columns + '
FROM
(
    SELECT
        CU.Region,
        CAT.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount

    FROM sales.Orders O

    JOIN sales.Customers CU
        ON CU.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories CAT
        ON CAT.CategoryID = P.CategoryID
) SourceData

PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        ' + @Columns + '
    )
) P

ORDER BY Region;
';

/* ------------------------------------------------------------
   Execute Dynamic SQL
   ------------------------------------------------------------ */

EXEC sys.sp_executesql @SQL;
🔥 এটি আপনার সবচেয়ে গুরুত্বপূর্ণ Dynamic PIVOT practice।








LEVEL 23 — Parameterized Dynamic SQL
Dynamic SQL-এ date filter parameterize করুন।
DECLARE @Columns NVARCHAR(MAX);
DECLARE @SQL NVARCHAR(MAX);

DECLARE @StartDate DATE = '2025-01-01';
DECLARE @EndDate DATE = '2025-12-31';


SELECT
    @Columns =
        STRING_AGG(
            QUOTENAME(CategoryName),
            ','
        )
FROM sales.Categories;


SET @SQL = N'
SELECT
    Region,
    ' + @Columns + '
FROM
(
    SELECT
        CU.Region,
        CAT.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount

    FROM sales.Orders O

    JOIN sales.Customers CU
        ON CU.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories CAT
        ON CAT.CategoryID = P.CategoryID

    WHERE O.OrderDate >= @StartDate
      AND O.OrderDate < DATEADD(DAY,1,@EndDate)
) S

PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN (' + @Columns + ')
) P;
';


EXEC sys.sp_executesql
    @SQL,
    N'@StartDate DATE, @EndDate DATE',
    @StartDate = @StartDate,
    @EndDate = @EndDate;


⭐ গুরুত্বপূর্ণ
Dynamic SQL-এর column names concatenate করতে হতে পারে।
কিন্তু user input যেমন:
Date
CustomerID
Region
parameterize করা উচিত।






LEVEL 24 — ETL Transformation
Data Engineering-এর সবচেয়ে গুরুত্বপূর্ণ অংশগুলোর একটি।
ধরা যাক source system দিয়েছে:

  
CustomerID
Year
JanSales
FebSales
MarSales
AprSales
...

  
কিন্তু Warehouse চাই:
CustomerID
Year
Month
Sales
এখানে:
UNPIVOT
ব্যবহার করতে পারেন।







LEVEL 25 — Staging + UNPIVOT
SELECT
    SalesYear,
    Region,
    MonthName,
    SalesAmount
FROM stg.MonthlySalesWide
UNPIVOT
(
    SalesAmount
    FOR MonthName IN
    (
        JanSales,
        FebSales,
        MarSales,
        AprSales,
        MaySales,
        JunSales,
        JulSales,
        AugSales,
        SepSales,
        OctSales,
        NovSales,
        DecSales
    )
) U
ORDER BY
    SalesYear,
    Region;


ETL Pattern
Source System
     ↓
Wide Data
     ↓
Staging
     ↓
UNPIVOT
     ↓
Long Data
     ↓
Silver
     ↓
Gold









LEVEL 26 — Data Warehouse
Warehouse-এ সাধারণত:
Dimension
+
Fact
ব্যবহার করা হয়।
আমাদের:
dw.DimDate
dw.DimCustomer
dw.DimProduct
dw.DimEmployee

dw.FactSales








LEVEL 27 — Fact & Dimension
Fact:
SELECT TOP 10 *
FROM dw.FactSales;


Dimension:
SELECT TOP 10 *
FROM dw.DimProduct;







LEVEL 28 — PIVOT Reporting Layer
এখন Warehouse থেকে reporting query:
SELECT
    D.YearNumber,
    D.MonthNumber,
    SUM(F.SalesAmount) AS TotalSales
FROM dw.FactSales F

JOIN dw.DimDate D
    ON D.DateKey = F.DateKey

GROUP BY
    D.YearNumber,
    D.MonthNumber

ORDER BY
    D.YearNumber,
    D.MonthNumber;


এরপর PIVOT:
SELECT
    YearNumber,
    [1] AS January,
    [2] AS February,
    [3] AS March,
    [4] AS April,
    [5] AS May,
    [6] AS June
FROM
(
    SELECT
        D.YearNumber,
        D.MonthNumber,
        SUM(F.SalesAmount) AS SalesAmount

    FROM dw.FactSales F

    JOIN dw.DimDate D
        ON D.DateKey = F.DateKey

    GROUP BY
        D.YearNumber,
        D.MonthNumber
) S

PIVOT
(
    SUM(SalesAmount)
    FOR MonthNumber IN
    (
        [1],[2],[3],[4],[5],[6]
    )
) P;






LEVEL 29 — Real Reporting Scenario #1
Region × Month Sales
SELECT
    Region,
    [1] AS January,
    [2] AS February,
    [3] AS March,
    [4] AS April,
    [5] AS May,
    [6] AS June
FROM
(
    SELECT
        DC.Region,
        DD.MonthNumber,
        F.SalesAmount
    FROM dw.FactSales F

    JOIN dw.DimCustomer DC
        ON DC.CustomerKey = F.CustomerKey

    JOIN dw.DimDate DD
        ON DD.DateKey = F.DateKey
) S

PIVOT
(
    SUM(SalesAmount)
    FOR MonthNumber IN
    (
        [1],[2],[3],[4],[5],[6]
    )
) P;








LEVEL 30 — Reporting Scenario #2
Category × Year
SELECT
    CategoryName,
    [2024],
    [2025],
    [2026]
FROM
(
    SELECT
        DP.CategoryName,
        DD.YearNumber,
        F.SalesAmount

    FROM dw.FactSales F

    JOIN dw.DimProduct DP
        ON DP.ProductKey = F.ProductKey

    JOIN dw.DimDate DD
        ON DD.DateKey = F.DateKey
) S

PIVOT
(
    SUM(SalesAmount)
    FOR YearNumber IN
    (
        [2024],
        [2025],
        [2026]
    )
) P;






LEVEL 31 — Reporting Scenario #3
Employee × Order Status
SELECT
    EmployeeID,
    [Completed],
    [Pending],
    [Cancelled]
FROM
(
    SELECT
        E.EmployeeID,
        O.OrderStatus,
        O.OrderID

    FROM sales.Orders O

    JOIN hr.Employees E
        ON E.EmployeeID = O.EmployeeID
) S

PIVOT
(
    COUNT(OrderID)
    FOR OrderStatus IN
    (
        [Completed],
        [Pending],
        [Cancelled]
    )
) P;





LEVEL 32 — PIVOT vs UNPIVOT

  
বিষয়	                        PIVOT	                 UNPIVOT
Transformation	              Long → Wide	           Wide → Long
Main use	                    Reporting	             ETL
Dashboard	                   ⭐⭐⭐⭐⭐	           ⭐⭐⭐
ETL	                         ⭐⭐⭐	               ⭐⭐⭐⭐⭐
Dynamic SQL	                  খুব common	              তুলনামূলক কম
Monthly columns	              Excellent	              Excellent reverse
Data normalization	          কম	                    বেশি
BI reporting	                Excellent	              Preparation






LEVEL 33 — PIVOT vs CASE
  
Production SQL-এ এই comparison খুব গুরুত্বপূর্ণ।

  
বিষয়	                     PIVOT	                 CASE
Syntax	                   Specialized	           Standard SQL
Readability	               Small reports-এ ভালো	 Complex query-তে ভালো
Dynamic	                   Dynamic SQL প্রয়োজন	   অনেক ক্ষেত্রে সহজ
Multiple conditions	       সীমিত	                 Excellent
Custom logic	             কম flexible	           Very flexible
Interview	                 অবশ্যই জানতে হবে	       অবশ্যই জানতে হবে



Practical Rule
Simple report
      ↓
PIVOT

Complex business logic
      ↓
CASE + Conditional Aggregation








LEVEL 34 — NULL Handling Best Practice
  
Bad:
SELECT
    [Electronics]
FROM ...

  
Better:
SELECT
    ISNULL([Electronics],0) AS Electronics
FROM ...
  
অথবা:
COALESCE([Electronics],0)






LEVEL 35 — Indexing
PIVOT নিজে সাধারণত "index তৈরি করার জায়গা" নয়।
PIVOT-এর আগে source data দ্রুত retrieve করতে index গুরুত্বপূর্ণ।
Orders
CREATE INDEX IX_Orders_OrderDate_Customer
ON sales.Orders
(
    OrderDate,
    CustomerID
);


OrderItems
CREATE INDEX IX_OrderItems_Order_Product
ON sales.OrderItems
(
    OrderID,
    ProductID
)
INCLUDE
(
    Quantity,
    UnitPrice,
    DiscountPercent
);



Fact
CREATE INDEX IX_FactSales_Date_Product
ON dw.FactSales
(
    DateKey,
    ProductKey
)
INCLUDE
(
    SalesAmount,
    Quantity
);






LEVEL 36 — Execution Plans
PIVOT query performance বুঝতে:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    Region,
    [Electronics],
    [Computers],
    [Furniture]
FROM
(
    SELECT
        CU.Region,
        CAT.CategoryName,
        OI.Quantity * OI.UnitPrice AS SalesAmount

    FROM sales.Orders O

    JOIN sales.Customers CU
        ON CU.CustomerID = O.CustomerID

    JOIN sales.OrderItems OI
        ON OI.OrderID = O.OrderID

    JOIN sales.Products P
        ON P.ProductID = OI.ProductID

    JOIN sales.Categories CAT
        ON CAT.CategoryID = P.CategoryID
) S

PIVOT
(
    SUM(SalesAmount)
    FOR CategoryName IN
    (
        [Electronics],
        [Computers],
        [Furniture]
    )
) P;



SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;


SSMS-এ:
Query
 ↓
Actual Execution Plan
 ↓
Execution Operators
 ↓
Scan / Seek
 ↓
Join
 ↓
Sort
 ↓
Aggregate
 ↓
PIVOT









LEVEL 37 — Performance Tuning
PIVOT query slow হলে প্রথমে:

  
🔍 Check 1 — Data Volume
SELECT COUNT(*)
FROM dw.FactSales;


🔍 Check 2 — Index
EXEC sp_helpindex 'dw.FactSales';


🔍 Check 3 — Logical Reads
SET STATISTICS IO ON;


🔍 Check 4 — CPU
SET STATISTICS TIME ON;


🔍 Check 5 — Execution Plan
Actual Execution Plan চালু করুন।







LEVEL 38 — Large Dataset Testing
Production-এর মতো testing করতে Fact table বড় করুন।
SELECT
    COUNT(*) AS FactRows,
    SUM(SalesAmount) AS TotalSales,
    AVG(SalesAmount) AS AvgSales
FROM dw.FactSales;
Performance test:
SET STATISTICS IO ON;
SET STATISTICS TIME ON;




SELECT
    DP.CategoryName,
    DD.YearNumber,
    SUM(F.SalesAmount) AS TotalSales
FROM dw.FactSales F

JOIN dw.DimProduct DP
    ON DP.ProductKey = F.ProductKey

JOIN dw.DimDate DD
    ON DD.DateKey = F.DateKey

GROUP BY
    DP.CategoryName,
    DD.YearNumber;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;






LEVEL 39 — Production Patterns 🏢
Production environment-এ সাধারণত এই architecture ভালো:
OLTP
 │
 ▼
Staging
 │
 ▼
UNPIVOT
 │
 ▼
Transformation
 │
 ▼
Data Warehouse
 │
 ├── Fact
 └── Dimensions
 │
 ▼
Reporting Layer
 │
 ▼
Power BI


  
PIVOT কোথায়?
Data Warehouse
       ↓
Reporting Layer
       ↓
PIVOT
       ↓
Dashboard / Excel / Report



  
UNPIVOT কোথায়?
Source
       ↓
Staging
       ↓
UNPIVOT
       ↓
Normalized Structure
       ↓
Warehouse





LEVEL 40 — Production Best Practices
🏆 Rule 1 — Raw Data Pivot করবেন না
Raw
 ↓
Staging
 ↓
Transform
 ↓
Reporting







🏆 Rule 2 — Dynamic PIVOT Carefully ব্যবহার করুন
Dynamic PIVOT powerful কিন্তু:
- debugging কঠিন
- execution plan complex হতে পারে
- SQL injection risk থাকতে পারে
- generated SQL বড় হতে পারে
তাই:
QUOTENAME()
এবং parameterized:
sp_executesql
ব্যবহার করুন।


  
🏆 Rule 3 — Reporting Layer-এ PIVOT
Fact table permanently wide করার পরিবর্তে:
Fact = Long / normalized
এবং reporting query-তে:
PIVOT = Wide
করাই সাধারণত ভালো architecture।



  
🏆 Rule 4 — CASE Alternative জানুন
সবসময় PIVOT ব্যবহার করবেন না।
অনেক ক্ষেত্রে:
SUM(
    CASE
        WHEN CategoryName = 'Electronics'
        THEN SalesAmount
        ELSE 0
    END
)
আরও maintainable হতে পারে।






LEVEL 41 — Interview Problems 🎯

  
Problem 1
প্রতি region-এর monthly sales বের করুন।
Region | Jan | Feb | Mar | Apr


  
Problem 2
প্রতি category-এর yearly sales:
Category | 2024 | 2025 | 2026

  
Problem 3
প্রতি employee-এর order status:
Employee | Completed | Pending | Cancelled


  
Problem 4
প্রতি customer segment-এর payment method:
Segment | Cash | Card | KNET | Online


  
Problem 5
প্রতি region-এর category sales:
Region | Electronics | Computers | Furniture


  
Problem 6
Dynamic category PIVOT করুন।
Requirements:
STRING_AGG()
QUOTENAME()
sp_executesql
ব্যবহার করতে হবে।


  
Problem 7
এই Wide table:
Year
Region
Jan
Feb
Mar
Apr
May
Jun
কে Long format-এ convert করুন।
Expected:
Year
Region
Month
Sales


  
Problem 8
PIVOT-এর NULL-কে 0 করুন।
ISNULL()
ব্যবহার করুন।


  
Problem 9
PIVOT-এর পরিবর্তে Conditional Aggregation ব্যবহার করুন।


  
Problem 10 — Senior Level 🔥
একটি dynamic report তৈরি করুন:
Region
    ↓
Year
    ↓
Dynamic Category Columns
    ↓
Total Sales
এবং:
QUOTENAME()
STRING_AGG()
sp_executesql
Parameterized Date Filter
ব্যবহার করুন।



