1. SQL Server Function কী? 🤔
- 🔹 সংজ্ঞা: Function হলো reusable SQL logic, যেটি input নিয়ে একটি value অথবা table return করে।
- 🔹 Reuse: একই business logic বারবার লিখতে হয় না।
- 🔹 Consistency: Customer segmentation, discount, calculation ইত্যাদি একই নিয়মে করা যায়।
- 🔹 Analytics: SELECT, WHERE, JOIN, GROUP BY-এর সাথে ব্যবহার করা যায়।
- 🔹 Engineering: ETL transformation, reusable business rules এবং data standardization-এ কাজে লাগে।
  
প্রধান Function Type
  
Type	              Return	                 প্রধান ব্যবহার
Scalar UDF	        Single Value	           Calculation, formatting, classification
iTVF	              Table	                   Reusable query/filter
MSTVF	              Table	                   Complex multi-step logic
Built-in Function	  Value/Table	SQL          Server-এর built-in operations


⚠️ Important: User-Defined Function (UDF) সাধারণত data modification করার জন্য নয়। 
INSERT, UPDATE, DELETE দিয়ে database state পরিবর্তন করার কাজ Function-এর পরিবর্তে Stored Procedure-এর জন্য বেশি উপযুক্ত।






🟢 BEGINNER
2. Simple Scalar Function
Scalar Function একটি single value return করে।
Example
Customer ID দিলে Customer Name return করবে।
/* ============================================================
   SIMPLE SCALAR FUNCTION
   Purpose:
   CustomerID থেকে CustomerName return করা
   ============================================================ */
CREATE FUNCTION utility.fn_GetCustomerName
(
    @CustomerID INT
)
RETURNS VARCHAR(150)
AS
BEGIN

    DECLARE @CustomerName VARCHAR(150);

    SELECT @CustomerName = CustomerName
    FROM sales.Customers
    WHERE CustomerID = @CustomerID;

    RETURN @CustomerName;

END;


GO
ব্যবহার
SELECT utility.fn_GetCustomerName(1) AS CustomerName;

Result:
Ahmed Ali







3. One Parameter Function
একটি parameter নিয়ে business calculation করা যায়।
Example: Product Price
/* ============================================================
   ONE PARAMETER FUNCTION
   Purpose:
   ProductID দিয়ে product price বের করা
   ============================================================ */
CREATE FUNCTION utility.fn_GetProductPrice
(
    @ProductID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN

    DECLARE @Price DECIMAL(12,2);

    SELECT @Price = UnitPrice
    FROM sales.Products
    WHERE ProductID = @ProductID;

    RETURN @Price;

END;


GO
SELECT utility.fn_GetProductPrice(101) AS ProductPrice;







4. Multiple Parameters
একাধিক parameter দিয়ে complex calculation করা যায়।
Example: Quantity × Price
/* ============================================================
   MULTIPLE PARAMETERS
   Purpose:
   Quantity এবং UnitPrice থেকে line total calculate করা
   ============================================================ */
CREATE FUNCTION utility.fn_CalculateLineTotal
(
    @Quantity INT,
    @UnitPrice DECIMAL(12,2)
)
RETURNS DECIMAL(12,2)
AS
BEGIN

    RETURN @Quantity * @UnitPrice;

END;
GO
SELECT
    utility.fn_CalculateLineTotal(5, 100) AS LineTotal;

Result:
500.00








5. String Function
Company data-তে customer name standardization খুব common।
Example: Full Name
/* ============================================================
   STRING FUNCTION
   Purpose:
   First Name + Last Name combine করা
   ============================================================ */
CREATE FUNCTION utility.fn_FullName
(
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100)
)
RETURNS VARCHAR(201)
AS
BEGIN

    RETURN CONCAT(
        TRIM(@FirstName),
        ' ',
        TRIM(@LastName)
    );

END;


GO
SELECT utility.fn_FullName('Ahmed', 'Ali') AS FullName;

Real ETL use
Data warehouse-এর Silver layer-এ standardized customer name তৈরি করতে এই ধরনের logic দেখা যায়।








6. Date Function
Customer registration থেকে কত বছর হয়েছে সেটা বের করি।
/* ============================================================
   DATE FUNCTION
   Purpose:
   RegistrationDate থেকে customer tenure year calculate করা
   ============================================================ */
CREATE FUNCTION utility.fn_CustomerTenureYears
(
    @RegistrationDate DATE
)
RETURNS INT
AS
BEGIN

    RETURN DATEDIFF(
        YEAR,
        @RegistrationDate,
        GETDATE()
    );

END;


GO
SELECT
    CustomerID,
    CustomerName,
    RegistrationDate,
    utility.fn_CustomerTenureYears(RegistrationDate)
        AS TenureYears
FROM sales.Customers;


⚠️ এখানে একটি important বিষয়:
DATEDIFF(YEAR, ...) calendar-year boundary count করে; exact completed years চাইলে আরও precise logic ব্যবহার করতে হবে।







7. Numeric Calculation
Product margin percentage বের করি।
/* ============================================================
   NUMERIC CALCULATION FUNCTION
   Purpose:
   Selling Price এবং Cost Price থেকে Margin %
   ============================================================ */
CREATE FUNCTION utility.fn_MarginPercent
(
    @SellingPrice DECIMAL(12,2),
    @CostPrice DECIMAL(12,2)
)
RETURNS DECIMAL(10,2)
AS
BEGIN

    RETURN
        CASE
            WHEN @SellingPrice = 0 THEN 0
            ELSE
                ((@SellingPrice - @CostPrice)
                / @SellingPrice) * 100
        END;

END;


GO
SELECT
    ProductName,
    UnitPrice,
    CostPrice,
    utility.fn_MarginPercent(UnitPrice, CostPrice)
        AS MarginPercent
FROM sales.Products;







🟡 INTERMEDIATE
8. Customer Segmentation Function
Real company analytics-এ customer segmentation খুব common।
Business rule:
Total Sales	Segment
>= 5000	VIP
>= 2000	Premium
>= 500	Regular
< 500	New


প্রথমে customer sales amount বের করার function:
/* ============================================================
   CUSTOMER SALES FUNCTION
   Purpose:
   Customer-এর total completed sales return করা
   ============================================================ */
CREATE FUNCTION utility.fn_CustomerTotalSales
(
    @CustomerID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN

    DECLARE @TotalSales DECIMAL(18,2);

    SELECT
        @TotalSales = ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)
    FROM sales.Orders o
    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID
    WHERE
        o.CustomerID = @CustomerID
        AND o.Status = 'Completed';

    RETURN @TotalSales;

END;
GO



এরপর segmentation:
/* ============================================================
   CUSTOMER SEGMENTATION
   ============================================================ */
CREATE FUNCTION utility.fn_CustomerSegment
(
    @TotalSales DECIMAL(18,2)
)
RETURNS VARCHAR(20)
AS
BEGIN

    RETURN
        CASE
            WHEN @TotalSales >= 5000 THEN 'VIP'
            WHEN @TotalSales >= 2000 THEN 'Premium'
            WHEN @TotalSales >= 500 THEN 'Regular'
            ELSE 'New'
        END;

END;
GO
ব্যবহার
SELECT
    CustomerID,
    CustomerName,

    utility.fn_CustomerTotalSales(CustomerID)
        AS TotalSales,

    utility.fn_CustomerSegment(
        utility.fn_CustomerTotalSales(CustomerID)
    ) AS CustomerSegment

FROM sales.Customers;
⚠️ এটি শেখার জন্য ভালো example, কিন্তু বড় production table-এ একই scalar function বারবার call করা expensive হতে পারে। পরে আমরা set-based approach দেখব।








9. Discount Function
Customer segment অনুযায়ী discount।
/* ============================================================
   DISCOUNT FUNCTION
   Purpose:
   Customer segment অনুযায়ী discount percentage return করা
   ============================================================ */
CREATE FUNCTION utility.fn_DiscountRate
(
    @CustomerSegment VARCHAR(20)
)
RETURNS DECIMAL(5,2)
AS
BEGIN

    RETURN
        CASE
            WHEN @CustomerSegment = 'VIP' THEN 20
            WHEN @CustomerSegment = 'Premium' THEN 15
            WHEN @CustomerSegment = 'Regular' THEN 5
            ELSE 0
        END;

END;


GO
SELECT
    utility.fn_DiscountRate('VIP') AS DiscountRate;






10. Order Total Function
OrderID দিয়ে total order amount।
/* ============================================================
   ORDER TOTAL FUNCTION
   Purpose:
   একটি Order-এর total amount calculate করা
   ============================================================ */
CREATE FUNCTION utility.fn_OrderTotal
(
    @OrderID INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN

    DECLARE @Total DECIMAL(18,2);

    SELECT
        @Total = ISNULL(
            SUM(Quantity * UnitPrice),
            0
        )
    FROM sales.OrderItems
    WHERE OrderID = @OrderID;

    RETURN @Total;

END;

GO
SELECT
    OrderID,
    utility.fn_OrderTotal(OrderID) AS OrderTotal
FROM sales.Orders;








11. iTVF — Inline Table-Valued Function
এটি অত্যন্ত গুরুত্বপূর্ণ। ⭐⭐⭐⭐⭐
iTVF একটি table return করে এবং সাধারণত একটি parameterized reusable query হিসেবে কাজ করে।
Syntax
CREATE FUNCTION schema.FunctionName
(
    @Parameter datatype
)
RETURNS TABLE
AS
RETURN
(
    SELECT ...
);
Example
একটি customer-এর orders return করব।
/* ============================================================
   INLINE TABLE-VALUED FUNCTION
   Purpose:
   নির্দিষ্ট customer-এর completed orders return করা
   ============================================================ */
CREATE FUNCTION report.fn_CustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.OrderID,
        o.OrderDate,
        o.Status,
        oi.ProductID,
        oi.Quantity,
        oi.UnitPrice,
        oi.Quantity * oi.UnitPrice AS LineTotal

    FROM sales.Orders o

    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE
        o.CustomerID = @CustomerID
);

GO
ব্যবহার
SELECT *
FROM report.fn_CustomerOrders(1);






12. Function + JOIN
iTVF-এর বড় advantage হলো JOIN করা যায়।
/* ============================================================
   FUNCTION + JOIN
   ============================================================ */
SELECT
    c.CustomerID,
    c.CustomerName,
    f.OrderID,
    f.OrderDate,
    f.LineTotal

FROM sales.Customers c

INNER JOIN report.fn_CustomerOrders(c.CustomerID) f
    ON c.CustomerID = f.CustomerID;


তবে উপরের iTVF-এ CustomerID output রাখা হয়নি। Production query-তে দরকার হলে function-এ o.CustomerID include করবেন।
Correct version:
ALTER FUNCTION report.fn_CustomerOrders
(
    @CustomerID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        o.CustomerID,
        o.OrderID,
        o.OrderDate,
        o.Status,
        oi.ProductID,
        oi.Quantity,
        oi.UnitPrice,
        oi.Quantity * oi.UnitPrice AS LineTotal

    FROM sales.Orders o

    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE o.CustomerID = @CustomerID
);
GO





13. Function + WHERE
/* ============================================================
   FUNCTION + WHERE
   ============================================================ */
SELECT *
FROM report.fn_CustomerOrders(1)
WHERE LineTotal > 500;


আরও practical:
SELECT *
FROM report.fn_CustomerOrders(1)
WHERE OrderDate >= '2026-01-01';






14. Function + GROUP BY
/* ============================================================
   FUNCTION + GROUP BY
   ============================================================ */
SELECT
    ProductID,
    SUM(LineTotal) AS TotalSales,
    SUM(Quantity) AS TotalQuantity

FROM report.fn_CustomerOrders(1)

GROUP BY ProductID;






15. 🔴 ADVANCED
MSTVF
Multi-Statement Table-Valued Function
এখানে intermediate table variable তৈরি করে একাধিক statement ব্যবহার করা যায়।
Structure
CREATE FUNCTION ...
RETURNS @Result TABLE
(
    ...
)
AS
BEGIN

    INSERT INTO @Result
    SELECT ...;

    UPDATE @Result
    SET ...;

    RETURN;

END;
Example
/* ============================================================
   MULTI-STATEMENT TABLE-VALUED FUNCTION
   Purpose:
   Customer order summary তৈরি করা
   ============================================================ */
CREATE FUNCTION report.fn_CustomerSummary
(
    @CustomerID INT
)
RETURNS @Result TABLE
(
    CustomerID INT,
    TotalOrders INT,
    TotalQuantity INT,
    TotalSales DECIMAL(18,2)
)
AS
BEGIN

    INSERT INTO @Result
    SELECT
        @CustomerID,
        COUNT(DISTINCT o.OrderID),
        ISNULL(SUM(oi.Quantity), 0),
        ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)

    FROM sales.Orders o

    INNER JOIN sales.OrderItems oi
        ON o.OrderID = oi.OrderID

    WHERE
        o.CustomerID = @CustomerID
        AND o.Status = 'Completed';

    RETURN;

END;

GO
ব্যবহার
SELECT *
FROM report.fn_CustomerSummary(1);

⚠️ iTVF-এর তুলনায় MSTVF সাধারণত performance-এর দিক থেকে বেশি risky
কারণ optimizer-এর জন্য MSTVF-এর cardinality estimation এবং optimization historically সীমিত ছিল, 
যদিও modern SQL Server versions-এ interleaved execution-এর মতো improvements এসেছে।








16. Function Performance Testing
Function ভালোভাবে কাজ করছে মানেই production-এর জন্য ভালো—এমন নয়।
Test
/* ============================================================
   PERFORMANCE TEST
   ============================================================ */

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    CustomerID,
    utility.fn_CustomerTotalSales(CustomerID)
FROM sales.Customers;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

দেখবেন:
- CPU time
- elapsed time
- logical reads
- scan/seek behavior






17. Scalar UDF vs Set-Based Query
এটি Data Analyst/Data Engineer-এর জন্য অত্যন্ত গুরুত্বপূর্ণ। ⭐⭐⭐⭐⭐
Scalar UDF
SELECT
    CustomerID,
    utility.fn_CustomerTotalSales(CustomerID)
FROM sales.Customers;
প্রতিটি customer-এর জন্য function invocation হতে পারে।
Set-Based
/* ============================================================
   SET-BASED ALTERNATIVE
   একই calculation একবারে করা
   ============================================================ */
SELECT
    c.CustomerID,
    c.CustomerName,
    ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) AS TotalSales

FROM sales.Customers c

LEFT JOIN sales.Orders o
    ON c.CustomerID = o.CustomerID
    AND o.Status = 'Completed'

LEFT JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

GROUP BY
    c.CustomerID,
    c.CustomerName;


Production principle
Large dataset হলে প্রথমে set-based SQL চিন্তা করুন।







18. iTVF vs MSTVF
  
বিষয়	                  iTVF	         MSTVF
Return	                Table	         Table
Query	Single            SELECT	       Multiple statements
Optimizer visibility	  ভালো	         তুলনামূলক সীমিত
Performance	            সাধারণত ভালো	 পরিস্থিতিভেদে খারাপ হতে পারে
Complexity	            কম	           বেশি
Preferred	             ✅ Yes	         প্রয়োজন হলে



Simple reusable query
        ↓
      iTVF
        ↓
Complex multi-step logic
        ↓
      MSTVF






19. Deterministic vs Non-Deterministic
Deterministic
একই input → একই output।
/* ============================================================
   DETERMINISTIC FUNCTION
   ============================================================ */
CREATE FUNCTION utility.fn_AddNumbers
(
    @A INT,
    @B INT
)
RETURNS INT
AS
BEGIN

    RETURN @A + @B;

END;
GO
SELECT utility.fn_AddNumbers(10, 20);

সবসময়:
30


Non-Deterministic
সময় বা অন্য changing state-এর ওপর নির্ভর করে।
উদাহরণ:
GETDATE()
/* ============================================================
   NON-DETERMINISTIC EXAMPLE
   ============================================================ */
SELECT GETDATE();

একই query পরে চালালে result পরিবর্তিত হবে।
Production consideration
  
Determinism গুরুত্বপূর্ণ:
- Indexed view
- Indexed computed column
- Schema binding
- Query optimization
- Reproducibility







20. Function Dependencies
একটি function অন্য object-এর ওপর depend করতে পারে।
Example:
fn_CustomerSegment
        ↓
fn_CustomerTotalSales
        ↓
Orders
        ↓
OrderItems
Dependency দেখতে:
/* ============================================================
   FUNCTION DEPENDENCY
   ============================================================ */
SELECT
    referencing_entity_name,
    referenced_entity_name
FROM sys.sql_expression_dependencies
WHERE
    referencing_id =
        OBJECT_ID('utility.fn_CustomerSegment');


আর একটি useful query:
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    OBJECT_NAME(object_id) AS ObjectName,
    definition
FROM sys.sql_modules
WHERE object_id = OBJECT_ID('utility.fn_CustomerTotalSales');









21. Execution Plan Analysis
Function ব্যবহার করলে শুধু result দেখা যথেষ্ট নয়।
Query
/* ============================================================
   EXECUTION PLAN ANALYSIS
   ============================================================ */
SELECT
    CustomerID,
    utility.fn_CustomerTotalSales(CustomerID)
FROM sales.Customers;

SSMS-এ:
Ctrl + M
তারপর query execute করুন।
  
দেখুন:
- Index Scan
- Index Seek
- Nested Loops
- Hash Match
- Sort
- Compute Scalar
- CPU
- Logical Reads
Data Engineering mindset
Correct Result
      ↓
Correct Logic
      ↓
Execution Plan
      ↓
IO / CPU
      ↓
Scalability






🟣 EXPERT
22. Production Optimization
Production function তৈরি করার আগে:
Checklist
- 🔹 Set-Based: সম্ভব হলে scalar UDF avoid করুন।
- 🔹 iTVF: Parameterized reusable query-এর জন্য prefer করুন।
- 🔹 Indexes: JOIN/filter columns index করুন।
- 🔹 Data Types: Appropriate datatype ব্যবহার করুন।
- 🔹 NULL: NULL behavior explicitly handle করুন।
- 🔹 SARGability: Column-এর ওপর unnecessary function ব্যবহার করবেন না।
- 🔹 Testing: Small + medium + large data volume test করুন।
- 🔹 Execution Plan: Actual execution plan দেখুন।







23. UDF Architecture
একটি production database-এ functions logically organize করা যায়।
FunctionsDB
│
├── sales
│   ├── Customers
│   ├── Orders
│   ├── OrderItems
│   └── Products
│
├── hr
│   ├── Employees
│   └── Departments
│
├── utility
│   ├── fn_AddNumbers
│   ├── fn_MarginPercent
│   ├── fn_DiscountRate
│   └── fn_CustomerSegment
│
└── report
    ├── fn_CustomerOrders
    └── fn_CustomerSummary
Naming convention

  
ভালো:
utility.fn_CalculateMargin
utility.fn_GetCustomerSegment
report.fn_CustomerOrders
  
Avoid:
fn1
myfunction
test
abc






24. Large-Table Performance
ধরুন:
Customers     = 10 Million
Orders        = 100 Million
OrderItems    = 500 Million

  
এখন:
SELECT
    CustomerID,
    utility.fn_CustomerTotalSales(CustomerID)
FROM sales.Customers;


এটি dangerous হতে পারে।
কারণ function-এর ভিতরে আবার:
Orders
   ↓
OrderItems
access হচ্ছে।


  
Better approach
SELECT
    o.CustomerID,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalSales

FROM sales.Orders o

INNER JOIN sales.OrderItems oi
    ON o.OrderID = oi.OrderID

WHERE o.Status = 'Completed'

GROUP BY
    o.CustomerID;

Large-scale analytics → set-based aggregation সাধারণত বেশি scalable।






25. Scalar UDF Inlining
SQL Server 2019+ এ eligible scalar UDF-এর জন্য Scalar UDF Inlining optimization available।
আগে:
Query
 ↓
Scalar UDF
 ↓
Repeated invocation
Inlining হলে optimizer কিছু eligible scalar UDF-এর logic query plan-এর মধ্যে integrate করতে পারে।
Database compatibility level check
/* ============================================================
   CHECK DATABASE COMPATIBILITY LEVEL
   ============================================================ */
SELECT
    name,
    compatibility_level
FROM sys.databases
WHERE name = 'FunctionsDB';


Set compatibility level
/* ============================================================
   SQL SERVER 2019+ COMPATIBILITY LEVEL
   ============================================================ */

ALTER DATABASE FunctionsDB
SET COMPATIBILITY_LEVEL = 150;

GO
⚠️ সব scalar UDF automatically inline হবে না। Function-এর structure, SQL Server version এবং database/function configuration অনুযায়ী eligibility নির্ভর করে।








26. Computed Columns + Functions
Computed column:
/* ============================================================
   COMPUTED COLUMN
   ============================================================ */
ALTER TABLE sales.OrderItems
ADD LineTotal AS
(
    Quantity * UnitPrice
);

GO  
এখন:
SELECT
    OrderItemID,
    Quantity,
    UnitPrice,
    LineTotal
FROM sales.OrderItems;


Important
Computed column-এর সঙ্গে UDF ব্যবহার করার আগে:
- deterministic হতে হবে
- precision বিষয় বিবেচনা করতে হবে
- ownership/schema binding requirements বুঝতে হবে
- indexing করলে আরও restrictions প্রযোজ্য হতে পারে







27. Indexed View Restrictions
Indexed View-এর ক্ষেত্রে function usage নিয়ে strict rules আছে।
Indexed View সাধারণ ordinary view-এর মতো unrestricted নয়।
  
উদাহরণস্বরূপ indexed view-তে:
- ❌ অনেক nondeterministic expression
- ❌ unsupported constructs
- ❌ কিছু function
- ❌ কিছু query patterns


  
ব্যবহার করা যায় না।
প্রথমে view তৈরি করার সময়
WITH SCHEMABINDING
প্রয়োজন হয় এবং নির্দিষ্ট SET options/ownership/indexing requirements মানতে হয়।
Principle
Normal View
    ↓
More flexibility

Indexed View
    ↓
More restrictions
    ↓
Potential performance benefit







28. Deployment & Versioning
Production environment-এ function directly edit না করে deployment script/version control ব্যবহার করুন।
Example
/* ============================================================
   FUNCTION VERSIONED DEPLOYMENT
   ============================================================ */
CREATE OR ALTER FUNCTION utility.fn_DiscountRate
(
    @CustomerSegment VARCHAR(20)
)
RETURNS DECIMAL(5,2)
AS
BEGIN

    RETURN
        CASE
            WHEN @CustomerSegment = 'VIP' THEN 20
            WHEN @CustomerSegment = 'Premium' THEN 15
            WHEN @CustomerSegment = 'Regular' THEN 5
            ELSE 0
        END;

END;


GO
Git structure
database/
│
├── schemas/
├── tables/
├── functions/
│   ├── utility.fn_DiscountRate.sql
│   ├── utility.fn_OrderTotal.sql
│   └── report.fn_CustomerOrders.sql
│
├── views/
└── deployment/
এটি Data Engineer-এর জন্য খুব গুরুত্বপূর্ণ।








29. Production Code Review
Production function review করার সময় এই checklist ব্যবহার করুন। 🔍

  
Logic
- 🔹 Purpose: Function-এর উদ্দেশ্য clear?
- 🔹 Parameters: Parameter naming meaningful?
- 🔹 Return: Return datatype appropriate?
- 🔹 NULL: NULL handling আছে?
- 🔹 Errors: Divide-by-zero বা invalid input handle করা হয়েছে?
- 🔹 Business Rule: Logic documented?

  
Performance
- 🔹 Scale: Million-row data-তে test করা হয়েছে?
- 🔹 SARGability: Search column-এর ওপর function লাগানো হয়েছে কি?
- 🔹 UDF: Scalar UDF সত্যিই দরকার?
- 🔹 iTVF: iTVF ব্যবহার করা যায় কি?
- 🔹 Plan: Execution plan reviewed?
- 🔹 IO: Logical reads acceptable?

  
Engineering
- 🔹 Naming: Standard naming convention?
- 🔹 Schema: Correct schema?
- 🔹 Dependencies: Dependency জানা আছে?
- 🔹 Versioning: Git-এ আছে?
- 🔹 Deployment: CREATE OR ALTER / migration script আছে?
- 🔹 Testing: Unit + integration test আছে?







সবচেয়ে গুরুত্বপূর্ণ Function Patterns
আপনার Data Analyst + Data Engineer career-এর জন্য এই patternগুলো বিশেষভাবে master করুন:

  
Pattern 1 — Calculation
SELECT
    ProductName,
    utility.fn_MarginPercent(UnitPrice, CostPrice)
        AS MarginPercent
FROM sales.Products;


Pattern 2 — Classification
SELECT
    utility.fn_CustomerSegment(2500)
        AS CustomerSegment;
Result:
Premium


  
Pattern 3 — Parameterized Query
SELECT *
FROM report.fn_CustomerOrders(1);
Pattern 4 — Function + WHERE
SELECT *
FROM report.fn_CustomerOrders(1)
WHERE LineTotal > 500;



Pattern 5 — Function + GROUP BY
SELECT
    ProductID,
    SUM(LineTotal) AS TotalSales
FROM report.fn_CustomerOrders(1)
GROUP BY ProductID;



Pattern 6 — Function + JOIN
SELECT
    c.CustomerName,
    f.OrderID,
    f.LineTotal
FROM sales.Customers c
CROSS APPLY report.fn_CustomerOrders(c.CustomerID) f;

এখানে CROSS APPLY parameterized iTVF-এর সঙ্গে অত্যন্ত useful pattern।






⚠️ Function বনাম Stored Procedure
  
Feature	                Function	            Stored Procedure
Value return	          ✅	                  সীমিত/ভিন্ন pattern
Table return	          ✅	                  Result set
SELECT-এর ভিতরে ব্যবহার	✅	                  ❌
JOIN	iTVF-এর ক্ষেত্রে     ✅	                  ❌
WHERE	                  ✅	                  ❌
GROUP BY	              ✅	                  ❌
Data modification	      ❌ সাধারণভাবে	        ✅
Transaction control	    সীমিত/নিষিদ্ধ pattern	  ✅
Dynamic SQL	            ❌	                  ✅
ETL workflow	          সীমিত	                ✅
Reusable calculation	  ⭐⭐⭐⭐⭐	         ⭐⭐⭐
Complex process	        ⭐⭐	               ⭐⭐⭐⭐⭐


