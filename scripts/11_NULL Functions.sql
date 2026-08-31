Project Architecture
NullFunctionsDB
│
├── source
│   ├── Customers
│   ├── Products
│   ├── Categories
│   ├── Departments
│   ├── Employees
│   ├── Orders
│   ├── OrderItems
│   └── Payments
│
├── bronze
│   └── Raw imported data
│
├── silver
│   └── Cleansed / standardized data
│
├── gold
│   ├── dim_customer
│   ├── dim_product
│   └── fact_sales
│
├── etl
│   └── ETL control / staging
│
└── qa
    └── Data Quality Checks
🎯 Business Scenario
ধরুন এটি একটি E-commerce / Retail Company।
আমাদের data-তে ইচ্ছাকৃতভাবে কিছু NULL থাকবে:
- Customer-এর phone missing
- Customer-এর email missing
- Product-এর discount NULL
- Employee-এর manager NULL
- Order-এর shipped date NULL
- Payment-এর payment date NULL
- Payment status NULL
- Product category missing
- Customer country missing
এর মাধ্যমে বাস্তব production-এর NULL problem practice করা যাবে।





🟢 PART 1 — NULL Fundamentals
1. NULL কী?
NULL মানে:
Unknown / Missing / Not Available / Not Applicable

NULL zero নয়।
NULL empty string নয়।
NULL false নয়।

   
/* NULL এবং zero-এর difference */
SELECT
    NULL AS MissingValue,
    0 AS ZeroValue,
    '' AS EmptyString;
গুরুত্বপূর্ণ
NULL      → Unknown
0         → Known numeric value
''        → Known empty text
'Unknown' → Known text





2. IS NULL
কোন column NULL কিনা খুঁজতে:
/* =========================================================
   Find customers whose email is missing
   ========================================================= */
SELECT
    CustomerID,
    CustomerName,
    Email
FROM source.Customers
WHERE Email IS NULL;


❌ ভুল
WHERE Email = NULL
এটি কাজ করবে না।

   
✅ সঠিক
WHERE Email IS NULL





3. IS NOT NULL
/* =========================================================
   Find customers who provided an email
   ========================================================= */
SELECT
    CustomerID,
    CustomerName,
    Email
FROM source.Customers
WHERE Email IS NOT NULL;





4. ISNULL()
SQL Server-এর খুব গুরুত্বপূর্ণ NULL function।
Syntax
ISNULL(check_expression, replacement_value)

   
Example
/* =========================================================
   Replace missing email with business-friendly text
   ========================================================= */
SELECT
    CustomerName,
    ISNULL(Email, 'No Email Provided') AS Email
FROM source.Customers;


Numeric example
/* =========================================================
   Replace missing discount with zero
   ========================================================= */
SELECT
    ProductName,
    DiscountPercent,
    ISNULL(DiscountPercent, 0) AS EffectiveDiscount
FROM source.Products;


Real project
/* =========================================================
   Calculate stock while treating NULL stock as zero
   ========================================================= */
SELECT
    ProductName,
    ISNULL(StockQty, 0) AS StockQty
FROM source.Products;

⚠️ Important
ISNULL() SQL Server-specific।







5. COALESCE()
একাধিক সম্ভাব্য column/value থেকে প্রথম non-NULL value নেয়।
Syntax
COALESCE(expression1, expression2, expression3, ...)

   
Example
/* =========================================================
   Select preferred customer contact:
   Email → Phone → fallback text
   ========================================================= */
SELECT
    CustomerName,
    COALESCE(
        Email,
        Phone,
        'No Contact Information'
    ) AS PreferredContact
FROM source.Customers;



ISNULL বনাম COALESCE
   
Feature	           ISNULL	      COALESCE
SQL Server	        ✅	         ✅
Multiple values	  ❌	         ✅
Standard SQL	     ❌	         ✅
2 values	           Excellent	   Excellent


Rule
Simple replacement → ISNULL()
Multiple fallback → COALESCE()
Portable SQL → COALESCE()





6. NULLIF()
দুটি value একই হলে NULL return করে।
Syntax
NULLIF(expression1, expression2)

   
Example
/* =========================================================
   Convert zero quantity into NULL
   Useful when zero means "missing/invalid"
   ========================================================= */
SELECT
    OrderItemID,
    Quantity,
    NULLIF(Quantity, 0) AS CleanQuantity
FROM source.OrderItems;


Division-by-zero prevention
/* =========================================================
   NULLIF prevents divide-by-zero
   ========================================================= */
SELECT
    100.0 / NULLIF(0, 0) AS SafeDivision;

Result:
NULL





🟢 PART 2 — Aggregate Functions + NULL
7. COUNT(*)
সব row count করে।
/* =========================================================
   Count all customer records
   ========================================================= */
SELECT
    COUNT(*) AS TotalCustomers
FROM source.Customers;

COUNT(*) NULL ignore করে না।
কারণ এটি row count করে।





8. COUNT(column)
শুধু non-NULL values count করে।
/* =========================================================
   Count customers who provided email
   ========================================================= */
SELECT
    COUNT(Email) AS CustomersWithEmail
FROM source.Customers;


Very important
COUNT(*)       → সব rows
COUNT(Email)   → Email যাদের NULL নয়






9. NULL Percentage
এটি Data Analyst/Data Engineer-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
/* =========================================================
   Calculate missing email percentage
   ========================================================= */
SELECT
    COUNT(*) AS TotalCustomers,

    COUNT(Email) AS CustomersWithEmail,

    COUNT(*) - COUNT(Email) AS MissingEmail,

    CAST(
        100.0 * (COUNT(*) - COUNT(Email))
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS MissingEmailPercentage

FROM source.Customers;






10. SUM()
SUM NULL values ignore করে।
/* =========================================================
   Calculate total payment amount
   NULL amounts are ignored by SUM
   ========================================================= */
SELECT
    SUM(Amount) AS TotalPaymentAmount
FROM source.Payments;


সব value যদি NULL হয়?
SUM() → NULL return করতে পারে।

   
তাই:
/* =========================================================
   Convert NULL aggregate result into zero
   ========================================================= */
SELECT
    ISNULL(SUM(Amount), 0) AS TotalPaymentAmount
FROM source.Payments;







11. AVG()
NULL ignore করে average calculation করে।
/* =========================================================
   Calculate average product price
   NULL UnitPrice is excluded
   ========================================================= */
SELECT
    AVG(UnitPrice) AS AveragePrice
FROM source.Products;






12. MIN()
/* =========================================================
   Find minimum product price
   ========================================================= */
SELECT
    MIN(UnitPrice) AS MinimumPrice
FROM source.Products;
NULL ignore করে।






13. MAX()
/* =========================================================
   Find maximum product price
   ========================================================= */
SELECT
    MAX(UnitPrice) AS MaximumPrice
FROM source.Products;





🟢 PART 3 — CASE + NULL
14. CASE
NULL handling-এ CASE অত্যন্ত গুরুত্বপূর্ণ।
/* =========================================================
   Classify customers based on email availability
   ========================================================= */
SELECT
    CustomerName,
    Email,
    CASE
        WHEN Email IS NULL THEN 'Missing Email'
        ELSE 'Email Available'
    END AS EmailStatus
FROM source.Customers;


Multiple NULL rules
/* =========================================================
   Customer contact quality classification
   ========================================================= */
SELECT
    CustomerName,
    CASE
        WHEN Email IS NOT NULL AND Phone IS NOT NULL
            THEN 'Complete Contact'

        WHEN Email IS NOT NULL OR Phone IS NOT NULL
            THEN 'Partial Contact'

        ELSE 'No Contact'
    END AS ContactQuality
FROM source.Customers;






🟢 PART 4 — CONCAT() এবং CONCAT_WS()
15. CONCAT()
NULL থাকলেও string concatenation break করে না।
/* =========================================================
   Build customer display information
   CONCAT converts NULL values safely
   ========================================================= */
SELECT
    CONCAT(
        CustomerName,
        ' - ',
        Country
    ) AS CustomerDisplay
FROM source.Customers;






16. CONCAT_WS()
Separator সহ multiple values combine করে।
/* =========================================================
   Build customer contact string
   NULL values are automatically skipped
   ========================================================= */
SELECT
    CustomerName,
    CONCAT_WS(
        ' | ',
        Email,
        Phone,
        Country
    ) AS CustomerContact
FROM source.Customers;


Example:
ahmed@example.com | +96550000001 | Kuwait
NULL হলে separator-এর duplicate সমস্যা কমে।






🟡 PART 5 — NULL + WHERE
17. NULL + WHERE
/* =========================================================
   Find orders that have not shipped yet
   ========================================================= */
SELECT
    OrderID,
    OrderStatus,
    ShippedDate
FROM source.Orders
WHERE ShippedDate IS NULL;






18. NULL + AND
/* =========================================================
   Find pending orders without shipping date
   ========================================================= */
SELECT
    OrderID,
    OrderStatus,
    ShippedDate
FROM source.Orders
WHERE OrderStatus = 'Pending'
  AND ShippedDate IS NULL;






19. NULL + OR
/* =========================================================
   Find customers missing either email or phone
   ========================================================= */
SELECT
    CustomerID,
    CustomerName,
    Email,
    Phone
FROM source.Customers
WHERE Email IS NULL
   OR Phone IS NULL;






20. NULL + NOT
এখানে beginner-রা ভুল করে।
/* =========================================================
   Find customers with a non-null email
   ========================================================= */
SELECT
    CustomerID,
    CustomerName
FROM source.Customers
WHERE NOT (Email IS NULL);

Better readable:
WHERE Email IS NOT NULL





🧠 PART 6 — Three-Valued Logic
SQL-এ শুধু:
TRUE
FALSE
নয়।
আরও আছে:
UNKNOWN
Example
/* =========================================================
   Demonstrate NULL comparison
   ========================================================= */
SELECT
    CASE
        WHEN NULL = NULL THEN 'TRUE'
        ELSE 'FALSE OR UNKNOWN'
    END AS Result;

SQL-এর logic:
NULL = NULL
      ↓
UNKNOWN
   
তাই:
WHERE Email = NULL
কাজ করে না।





🔥 PART 7 — NULL + Arithmetic
NULL-এর সাথে arithmetic করলে result সাধারণত NULL হয়।
/* =========================================================
   Demonstrate NULL arithmetic
   ========================================================= */
SELECT
    100 + NULL AS Result1,
    100 - NULL AS Result2,
    100 * NULL AS Result3,
    100 / NULL AS Result4;

সব result:
NULL


Real Project Example
/* =========================================================
   Calculate sales amount safely
   Quantity or UnitPrice NULL হলে result NULL হবে।
   তাই business rule অনুযায়ী COALESCE ব্যবহার করছি।
   ========================================================= */
SELECT
    OrderItemID,
    COALESCE(Quantity, 0) AS Quantity,
    COALESCE(UnitPrice, 0) AS UnitPrice,

    COALESCE(Quantity, 0)
    * COALESCE(UnitPrice, 0) AS SalesAmount
FROM source.OrderItems;

⚠️ তবে মনে রাখবেন:
Missing price = 0 সব business-এ সঠিক নয়।
অনেক সময় missing price-কে 0 বানানো data corruption তৈরি করতে পারে।






🟡 PART 8 — NULL + GROUP BY
NULL একটি group হিসেবে treated হয়।
/* =========================================================
   Group customers by country
   NULL country becomes one group
   ========================================================= */
SELECT
    Country,
    COUNT(*) AS CustomerCount
FROM source.Customers
GROUP BY Country;


Result-এ:
NULL
একটি আলাদা group হবে।

   
Better Reporting
/* =========================================================
   Display NULL country as Unknown
   ========================================================= */
SELECT
    COALESCE(Country, 'Unknown') AS Country,
    COUNT(*) AS CustomerCount
FROM source.Customers
GROUP BY COALESCE(Country, 'Unknown');






🟡 PART 9 — NULL + HAVING
/* =========================================================
   Find countries with at least 2 customers
   NULL is also grouped
   ========================================================= */
SELECT
    Country,
    COUNT(*) AS CustomerCount
FROM source.Customers
GROUP BY Country
HAVING COUNT(*) >= 2;






🟡 PART 10 — NULL + JOIN
21. INNER JOIN
NULL join key সাধারণত match করবে না।
/* =========================================================
   Join customers with orders
   ========================================================= */
SELECT
    c.CustomerName,
    o.OrderID
FROM source.Customers c
INNER JOIN source.Orders o
    ON c.CustomerID = o.CustomerID;





22. LEFT JOIN ... IS NULL
এটি Anti Join-এর সবচেয়ে common pattern।
/* =========================================================
   Find customers who have never placed an order
   ========================================================= */
SELECT
    c.CustomerID,
    c.CustomerName
FROM source.Customers c
LEFT JOIN source.Orders o
    ON c.CustomerID = o.CustomerID
WHERE o.OrderID IS NULL;

এটি real Data Analyst interview-এর অত্যন্ত গুরুত্বপূর্ণ pattern।







23. NOT EXISTS
Same business problem:
/* =========================================================
   Find customers without orders using NOT EXISTS
   ========================================================= */
SELECT
    c.CustomerID,
    c.CustomerName
FROM source.Customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM source.Orders o
    WHERE o.CustomerID = c.CustomerID
);

Recommendation
Anti-match logic-এর জন্য:
NOT EXISTS ⭐⭐⭐⭐⭐
LEFT JOIN ... IS NULL ⭐⭐⭐⭐⭐
দুটিই জানবেন।





24. NOT IN + NULL
এটি SQL-এর সবচেয়ে dangerous NULL traps-এর একটি।
ধরুন:
WHERE CustomerID NOT IN (...)
subquery result-এ যদি NULL আসে, unexpected result হতে পারে।
Example
/* =========================================================
   Demonstration of NOT IN NULL problem
   ========================================================= */
SELECT
    CustomerID,
    CustomerName
FROM source.Customers
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM source.Orders
);


Production-এ safer alternative:
/* =========================================================
   Recommended anti-join pattern
   NOT EXISTS avoids NOT IN + NULL problems
   ========================================================= */
SELECT
    c.CustomerID,
    c.CustomerName
FROM source.Customers c
WHERE NOT EXISTS
(
    SELECT 1
    FROM source.Orders o
    WHERE o.CustomerID = c.CustomerID
);





🟡 PART 11 — NULL + DISTINCT
/* =========================================================
   DISTINCT country values
   All NULL values appear as one distinct value
   ========================================================= */
SELECT DISTINCT
    Country
FROM source.Customers;





🟡 PART 12 — NULL + ORDER BY
SQL Server-এ ascending sort-এ NULL সাধারণত প্রথম দিকে আসে।
/* =========================================================
   Sort customers by country
   ========================================================= */
SELECT
    CustomerName,
    Country
FROM source.Customers
ORDER BY Country ASC;


NULL শেষে চাইলে
/* =========================================================
   Put NULL countries at the end
   ========================================================= */
SELECT
    CustomerName,
    Country
FROM source.Customers
ORDER BY
    CASE
        WHEN Country IS NULL THEN 1
        ELSE 0
    END,
    Country;




🟡 PART 13 — NULL + Window Functions
ROW_NUMBER()
/* =========================================================
   Rank customers by country
   NULL country is treated as a value
   ========================================================= */
SELECT
    CustomerID,
    CustomerName,
    Country,

    ROW_NUMBER() OVER
    (
        PARTITION BY Country
        ORDER BY CustomerID
    ) AS RowNum

FROM source.Customers;





LAG()
/* =========================================================
   Compare customer/order information using LAG
   ========================================================= */
SELECT
    OrderID,
    CustomerID,
    OrderDate,

    LAG(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS PreviousOrderDate

FROM source.Orders;
First row-এর previous value naturally NULL হবে।




LEAD()
/* =========================================================
   Find next order date
   ========================================================= */
SELECT
    OrderID,
    CustomerID,
    OrderDate,

    LEAD(OrderDate) OVER
    (
        PARTITION BY CustomerID
        ORDER BY OrderDate
    ) AS NextOrderDate

FROM source.Orders;





🟡 PART 14 — NULL + Set Operators
SQL Server-এর set operators:
UNION
UNION ALL
INTERSECT
EXCEPT
UNION

   
/* =========================================================
   UNION removes duplicate rows
   ========================================================= */
SELECT Country
FROM source.Customers
WHERE Country IS NOT NULL

UNION

SELECT Country
FROM source.Customers
WHERE Country IS NULL;

NULL set operation-এ ordinary value-এর মতো নয়, 
কিন্তু duplicate handling-এ NULL values একই হিসেবে treated হয়।






🟡 PART 15 — NULL + PIVOT / UNPIVOT
PIVOT:
/* =========================================================
   Example source dataset for PIVOT
   ========================================================= */
SELECT
    Country,
    CustomerStatus,
    COUNT(*) AS CustomerCount
FROM source.Customers
GROUP BY Country, CustomerStatus;



PIVOT:
/* =========================================================
   Pivot customer status
   ========================================================= */
SELECT
    Country,
    [Active],
    [Inactive]
FROM
(
    SELECT
        Country,
        CustomerStatus,
        CustomerID
    FROM source.Customers
) AS src
PIVOT
(
    COUNT(CustomerID)
    FOR CustomerStatus IN
    (
        [Active],
        [Inactive]
    )
) AS p;

NULL category/status হলে PIVOT-এ missing column/value 
behavior বুঝতে হবে এবং আগে cleansing/business rule প্রয়োগ করা ভালো।






🔴 PART 16 — Production NULL Handling
এখান থেকে সবচেয়ে গুরুত্বপূর্ণ Data Engineering অংশ।
25. NOT NULL
যে column-এ NULL allowed নয়:
   
/* =========================================================
   Example NOT NULL table
   ========================================================= */
CREATE TABLE qa.RequiredCustomer
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL
);





26. PRIMARY KEY + NULL
Primary Key:
NOT NULL
+
UNIQUE
   
অর্থাৎ:
/* =========================================================
   Primary Key automatically prevents NULL
   ========================================================= */
CREATE TABLE qa.TestPrimaryKey
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(100)
);


এখানে:
CustomerID = NULL
allowed নয়।






27. FOREIGN KEY + NULL
Foreign Key NULL হতে পারে যদি column nullable হয়।
আমাদের:
Employees.ManagerID
Orders.SalesRepID
Products.CategoryID

   
এর example।
/* =========================================================
   Find employees without a manager
   Top-level managers naturally have NULL ManagerID
   ========================================================= */
SELECT
    EmployeeID,
    EmployeeName
FROM source.Employees
WHERE ManagerID IS NULL;





28. UNIQUE + NULL
SQL Server-এ UNIQUE constraint এবং NULL-এর behavior বিশেষভাবে বুঝতে হবে।
/* =========================================================
   Example UNIQUE constraint
   ========================================================= */
CREATE TABLE qa.UniqueEmailTest
(
    CustomerID INT PRIMARY KEY,
    Email VARCHAR(150) NULL,

    CONSTRAINT UQ_UniqueEmail
        UNIQUE (Email)
);

Production design-এ email optional 
হলে unique constraint-এর behavior carefully test করবেন।





🔴 PART 17 — NULL + Indexes
NULL column index করা যায়।
/* =========================================================
   Create index on customer email
   Purpose:
   Search/filter performance improve করা
   ========================================================= */
CREATE INDEX IX_Customers_Email
ON source.Customers(Email);

কিন্তু NULL search-এর জন্য workload 
এবং execution plan দেখে index design করবেন।





29. Filtered Index
SQL Server-এর powerful feature।
/* =========================================================
   Filtered Index
   Purpose:
   Only customers with email maintain করা
   Useful when NULL rows are numerous
   ========================================================= */
CREATE INDEX IX_Customers_Email_NotNull
ON source.Customers(Email)
WHERE Email IS NOT NULL;

এটি production-এ useful হতে পারে যখন:
90% Email NULL
10% Email populated






🔴 PART 18 — NULL Profiling
Data Engineer-এর প্রথম কাজগুলোর একটি:
Understand how much NULL exists before cleaning it.

30. Customer NULL Profile
/* =========================================================
   NULL profiling for Customers
   Purpose:
   প্রতিটি important column-এর missing count দেখা
   ========================================================= */
SELECT
    COUNT(*) AS TotalRows,

    SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END)
        AS MissingEmail,

    SUM(CASE WHEN Phone IS NULL THEN 1 ELSE 0 END)
        AS MissingPhone,

    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
        AS MissingCountry,

    SUM(CASE WHEN DateOfBirth IS NULL THEN 1 ELSE 0 END)
        AS MissingDOB,

    SUM(CASE WHEN CustomerStatus IS NULL THEN 1 ELSE 0 END)
        AS MissingStatus

FROM source.Customers;




31. NULL Percentage per Column
/* =========================================================
   NULL percentage profiling
   Purpose:
   Data quality dashboard-এর জন্য missing percentage
   ========================================================= */
SELECT
    COUNT(*) AS TotalRows,

    CAST(
        100.0 * SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS EmailNullPercentage,

    CAST(
        100.0 * SUM(CASE WHEN Phone IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS PhoneNullPercentage,

    CAST(
        100.0 * SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS CountryNullPercentage

FROM source.Customers;





🔴 PART 19 — Bronze → Silver NULL Cleansing
এটাই Data Engineering-এর বাস্তব flow।
Source
  ↓
Bronze
  ↓
Silver
  ↓
Gold







32. Bronze Table
Bronze সাধারণত raw data-এর কাছাকাছি থাকে।
/* =========================================================
   Bronze Customers
   Purpose:
   Source থেকে raw data preserve করা
   ========================================================= */
SELECT
    *
INTO bronze.Customers
FROM source.Customers;
GO





33. Silver Cleansing
/* =========================================================
   Silver Customers
   Purpose:
   Bronze data clean এবং standardized করা

   Business rules:
   NULL Country → 'Unknown'
   NULL Status → 'Unknown'
   Empty/blank values → NULL
   ========================================================= */
SELECT
    CustomerID,

    NULLIF(
        LTRIM(RTRIM(CustomerName)),
        ''
    ) AS CustomerName,

    NULLIF(
        LTRIM(RTRIM(Email)),
        ''
    ) AS Email,

    NULLIF(
        LTRIM(RTRIM(Phone)),
        ''
    ) AS Phone,

    COALESCE(
        NULLIF(LTRIM(RTRIM(Country)), ''),
        'Unknown'
    ) AS Country,

    DateOfBirth,

    COALESCE(
        NULLIF(LTRIM(RTRIM(CustomerStatus)), ''),
        'Unknown'
    ) AS CustomerStatus,

    CreatedDate

INTO silver.Customers

FROM bronze.Customers;
GO

   
এখানে আমরা একসাথে ব্যবহার করেছি:
NULLIF()
LTRIM()
RTRIM()
COALESCE()
এটাই real ETL transformation।






🔴 PART 20 — Unknown Member Strategy
Data Warehouse-এ একটি গুরুত্বপূর্ণ concept।
ধরুন fact table-এর customer ID পাওয়া গেল না।
তখন সবসময় NULL রাখা ভালো নয়।
একটি Unknown Member রাখা যায়:
CustomerKey = 0
CustomerName = 'Unknown Customer'





34. Gold Dimension
/* =========================================================
   Gold Customer Dimension
   Purpose:
   Analytics / Power BI-এর জন্য dimension তৈরি করা

   Unknown member = 0
   ========================================================= */
CREATE TABLE gold.dim_customer
(
    CustomerKey INT PRIMARY KEY,
    CustomerID INT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NULL,
    Country VARCHAR(50) NOT NULL
);


GO
/* =========================================================
   Insert Unknown Member
   Purpose:
   Missing dimension relationship handle করা
   ========================================================= */
INSERT INTO gold.dim_customer
(
    CustomerKey,
    CustomerID,
    CustomerName,
    Email,
    Country
)
VALUES
(
    0,
    NULL,
    'Unknown Customer',
    NULL,
    'Unknown'
);
GO





🔴 PART 21 — Data Quality Checks
NULL quality check production pipeline-এর অংশ হওয়া উচিত।
35. Required Email Check
ধরা যাক business rule:
Active customer-এর Email থাকতে হবে।

/* =========================================================
   Data Quality Check
   Rule:
   Active customers must have email
   ========================================================= */
SELECT
    CustomerID,
    CustomerName,
    Email,
    CustomerStatus
FROM source.Customers
WHERE CustomerStatus = 'Active'
  AND Email IS NULL;

এগুলো হলো DQ failures।






36. Required Product Price
/* =========================================================
   Data Quality Check
   Rule:
   Active products must have price
   ========================================================= */
SELECT
    ProductID,
    ProductName,
    UnitPrice
FROM source.Products
WHERE ProductStatus = 'Active'
  AND UnitPrice IS NULL;






37. NULL Reconciliation
Bronze এবং Silver-এ NULL কত ছিল compare করা।
/* =========================================================
   NULL Reconciliation
   Purpose:
   Bronze বনাম Silver transformation validate করা
   ========================================================= */
SELECT
    'Bronze' AS Layer,
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
        AS NullCountry
FROM bronze.Customers

UNION ALL

SELECT
    'Silver',
    COUNT(*),
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
FROM silver.Customers;


এখানে expected:
Bronze Country NULL > 0
Silver Country NULL = 0
যদি business rule অনুযায়ী Unknown ব্যবহার করা হয়।






🔴 PART 22 — Incremental Load + NULL
Incremental ETL-এ একটি common problem:
LastModifiedDate = NULL
   
তখন:
WHERE LastModifiedDate > @LastLoadDate
NULL rows select করবে না।


   
Safer business logic
/* =========================================================
   Incremental extraction with NULL handling
   Purpose:
   Missing LastModifiedDate rows বাদ না দেওয়া
   ========================================================= */
DECLARE @LastLoadDate DATETIME = '2026-02-01';

SELECT
    *
FROM source.Customers
WHERE
    CreatedDate > CAST(@LastLoadDate AS DATE)
    OR CreatedDate IS NULL;

তবে এখানে CreatedDate যদি mandatory হয়, NULL check unnecessary।
Best practice: Incremental watermark column ideally NOT NULL হওয়া উচিত।







🔴 PART 23 — Fact / Dimension + NULL
Data Warehouse-এ সবচেয়ে গুরুত্বপূর্ণ design principle:
   
Dimension
Customer
Product
Employee
Date

   
Fact
Sales
Orders
Payments

   
Fact table-এ foreign key ideally unknown member-এ point করবে।
   
Example:
CustomerKey
    ↓
0 = Unknown Customer

   
NULL foreign key-এর পরিবর্তে:
0 → Unknown
অনেক dimensional warehouse-এ বেশি useful।






🧠 PART 24 — Real Sales Analysis
এখন আমাদের তৈরি data দিয়ে real business report বানাই।
Total Sales
/* =========================================================
   Calculate total sales
   NULL Quantity / UnitPrice treated according to
   business rule as zero for this analytical example
   ========================================================= */
SELECT
    SUM(
        COALESCE(Quantity, 0)
        * COALESCE(UnitPrice, 0)
    ) AS TotalSales
FROM source.OrderItems;


Average Order Item Price
/* =========================================================
   Average unit price
   NULL prices are ignored
   ========================================================= */

SELECT
    AVG(UnitPrice) AS AverageUnitPrice
FROM source.OrderItems;



Missing Price Products
/* =========================================================
   Find products with missing prices
   ========================================================= */
SELECT
    ProductID,
    ProductName
FROM source.Products
WHERE UnitPrice IS NULL;



Customers Without Contact
/* =========================================================
   Find customers with no email and no phone
   ========================================================= */
SELECT
    CustomerID,
    CustomerName
FROM source.Customers
WHERE Email IS NULL
  AND Phone IS NULL;



Orders Not Delivered
/* =========================================================
   Find orders without delivered date
   ========================================================= */
SELECT
    OrderID,
    OrderStatus,
    DeliveredDate
FROM source.Orders
WHERE DeliveredDate IS NULL;



Payment Missing Information
/* =========================================================
   Find payments with incomplete information
   ========================================================= */
SELECT
    PaymentID,
    OrderID,
    PaymentDate,
    PaymentMethod,
    Amount,
    PaymentStatus
FROM source.Payments
WHERE PaymentDate IS NULL
   OR PaymentMethod IS NULL
   OR Amount IS NULL
   OR PaymentStatus IS NULL;





PART 25 — NULL Data Quality Dashboard Query
এটি portfolio/project-এর জন্য অত্যন্ত ভালো query।
/* =========================================================
   Customer Data Quality Dashboard
   Purpose:
   NULL/missing data monitoring
   ========================================================= */
SELECT
    COUNT(*) AS TotalCustomers,

    COUNT(Email) AS ValidEmailRows,

    COUNT(Phone) AS ValidPhoneRows,

    COUNT(Country) AS ValidCountryRows,

    SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END)
        AS MissingEmail,

    SUM(CASE WHEN Phone IS NULL THEN 1 ELSE 0 END)
        AS MissingPhone,

    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
        AS MissingCountry,

    CAST(
        100.0 *
        SUM(CASE WHEN Email IS NULL THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0)
        AS DECIMAL(5,2)
    ) AS EmailNullPercentage

FROM source.Customers;






PART 26 — NULL Handling Decision Framework
Production-এ NULL দেখলেই ISNULL(column, 0) করবেন না।
প্রথমে প্রশ্ন করবেন:

   
1️⃣ NULL কেন?
Missing?
Unknown?
Not Applicable?
Not Yet Available?
Data Error?

   
2️⃣ Business meaning কী?
উদাহরণ:
ShippedDate NULL
এর মানে:
Order shipped হয়নি

কিন্তু:
UnitPrice NULL
এর মানে:
Price missing

দুটো NULL হলেও meaning সম্পূর্ণ আলাদা।






🎯 NULL Handling Strategy
   
Scenario	                                     Recommended
Missing numeric but business says zero	       COALESCE(x,0)
Missing text for reporting	                   COALESCE(x,'Unknown')
Multiple fallback	                            COALESCE()
Simple SQL Server replacement	                ISNULL()
Zero should become NULL	                      NULLIF()
Detect NULL	                                  IS NULL
Detect populated	                            IS NOT NULL
Conditional handling	                         CASE
Anti join	                                  NOT EXISTS
Missing relationship	                         Unknown Member
Data profiling	                               COUNT, SUM(CASE...)
Divide by zero	                               NULLIF()



PART 27 — Most Important NULL Interview Traps
Trap 1
WHERE Email = NULL
   
❌ Wrong
WHERE Email IS NULL
   
✅ Correct

   
Trap 2
COUNT(*)
সব rows count করে।
COUNT(Email)
শুধু non-NULL Email count করে।

   
Trap 3
SUM(Amount)
NULL values ignore করে।

   
Trap 4
AVG(Amount)
NULL values ignore করে।

   
Trap 5
NULL + 100
Result:
NULL

   
Trap 6
NOT IN
Subquery-তে NULL থাকলে dangerous হতে পারে।
Production-এ অনেক ক্ষেত্রে:
NOT EXISTS
prefer করা হয়।

   
Trap 7
ISNULL()
SQL Server-specific।
COALESCE()
Standard SQL এবং multiple fallback support করে।







PART 28 — Complete Real Project Challenge
এখন নিজের হাতে এই requirements solve করবেন।

   
Challenge 01 — Customer Data Quality
Find:
- Total customers
- Customers with email
- Customers without email
- Email NULL %
- Customers with phone
- Customers without phone
- Customers without both email and phone

   
Challenge 02 — Product Quality
Find:
- Products without price
- Products without discount
- Products without stock
- Products with all three missing
- Active products with missing price


Challenge 03 — Order Operations
Find:
- Pending orders
- Orders not shipped
- Orders not delivered
- Orders without SalesRep
- Orders with missing status

   
Challenge 04 — Payment Quality
Find:
- Payments without payment date
- Payments without method
- Payments without amount
- Payments with incomplete payment information

   
Challenge 05 — Customer Contact
Create:
CustomerName
Email
Phone
PreferredContact
Rules:
Email available → Email
Email missing + Phone available → Phone
Both missing → No Contact





PART 29 — Advanced Combined Query
এখানে অনেক NULL concepts একসাথে ব্যবহার করছি।
/* =========================================================
   Advanced Customer Contact Quality Report

   Concepts:
   COALESCE
   CASE
   COUNT
   NULL handling
   GROUP BY
   ========================================================= */
SELECT
    COALESCE(Country, 'Unknown') AS Country,

    COUNT(*) AS TotalCustomers,

    COUNT(Email) AS CustomersWithEmail,

    COUNT(Phone) AS CustomersWithPhone,

    SUM(
        CASE
            WHEN Email IS NULL
             AND Phone IS NULL
            THEN 1
            ELSE 0
        END
    ) AS NoContactCustomers

FROM source.Customers

GROUP BY
    COALESCE(Country, 'Unknown')

ORDER BY
    TotalCustomers DESC;
এটি একটি real analytical report-এর মতো query।






PART 30 — Recommended Production Architecture
NULL handling-কে এভাবে ভাববেন:
                  SOURCE
                     │
                     ▼
              ┌─────────────┐
              │   BRONZE    │
              │ Raw NULL    │
              │ preserved   │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │   SILVER    │
              │ Clean NULL  │
              │ Standardize │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │    GOLD     │
              │ Business    │
              │ Rules       │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │ Power BI /  │
              │ Analytics   │
              └─────────────┘






NULL-এর ক্ষেত্রে Golden Rules
- 🔹 Meaning first: NULL-এর business meaning না বুঝে replace করবেন না।
- 🔹 Raw preserve: Bronze layer-এ original NULL preserve করা ভালো।
- 🔹 Clean carefully: Silver layer-এ business rule অনুযায়ী cleansing করুন।
- 🔹 Unknown member: Dimension relationship missing হলে অনেক ক্ষেত্রে 0 = Unknown ব্যবহার করুন।
- 🔹 COUNT: COUNT(*) এবং COUNT(column)-এর পার্থক্য অবশ্যই জানুন।
- 🔹 Anti join: NOT IN + NULL-এর trap এড়াতে NOT EXISTS খুব গুরুত্বপূর্ণ।
- 🔹 Aggregates: SUM/AVG/MIN/MAX NULL কীভাবে handle করে জানুন।
- 🔹 Arithmetic: NULL arithmetic result সাধারণত NULL।
- 🔹 Profiling: Production ETL-এর আগে NULL percentage measure করুন।
- 🔹 Constraints: যেসব field অবশ্যই থাকতে হবে সেগুলো NOT NULL করুন।
- 🔹 Index: High-NULL column-এ workload অনুযায়ী filtered index বিবেচনা করুন।
- 🔹 DQ: NULL checks-কে ETL/Data Quality pipeline-এর অংশ করুন।
- 🔹 Don't blindly zero: Missing price = 0 করা সবসময় correct নয়।
- 🔹 Document: কোন NULL → 0, Unknown, বা NULL-ই থাকবে—business rule document করুন।




    

NULL Functions & NULL Handling
🟢 Beginner
- ✅ NULL
- ✅ IS NULL
- ✅ IS NOT NULL
- ✅ ISNULL()
- ✅ COALESCE()
- ✅ NULLIF()
- ✅ COUNT(*)
- ✅ COUNT(column)
- ✅ SUM()
- ✅ AVG()
- ✅ MIN()
- ✅ MAX()
- ✅ CASE
- ✅ CONCAT()
- ✅ CONCAT_WS()
🟡 Intermediate
- ✅ NULL + WHERE
- ✅ NULL + AND / OR / NOT
- ✅ Three-Valued Logic
- ✅ NULL + Arithmetic
- ✅ NULL + GROUP BY
- ✅ NULL + HAVING
- ✅ NULL + JOIN
- ✅ LEFT JOIN ... IS NULL
- ✅ NOT EXISTS
- ✅ NOT IN + NULL
- ✅ NULL + DISTINCT
- ✅ NULL + ORDER BY
- ✅ NULL + Window Functions
- ✅ NULL + Set Operators
- ✅ NULL + PIVOT / UNPIVOT
🔴 Advanced / Data Engineering
- ✅ NOT NULL
- ✅ PRIMARY KEY
- ✅ FOREIGN KEY
- ✅ UNIQUE
- ✅ NULL + Constraints
- ✅ NULL + Indexes
- ✅ Filtered Index
- ✅ NULL Profiling
- ✅ NULL Percentage
- ✅ ETL NULL Handling
- ✅ Bronze → Silver NULL Cleansing
- ✅ Unknown Member Strategy
- ✅ Data Quality Checks
- ✅ NULL Reconciliation
- ✅ Incremental Load + NULL
- ✅ Fact / Dimension + NULL

