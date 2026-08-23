1. JSON কী?
JSON = JavaScript Object Notation
এটি একটি lightweight, text-based data format, যা সাধারণত:
- 🌐 API data
- 📱 Mobile/Web applications
- 🔄 Data integration
- 🏗️ ETL/ELT pipelines
- ☁️ Cloud services
- 🧩 Semi-structured data
- 📦 Event/log data
এর জন্য ব্যবহার হয়।




JSON Example
{
  "customer_id": 1001,
  "customer_name": "Ahmed Hassan",
  "country": "Kuwait",
  "is_active": true,
  "orders": [
    {
      "order_id": 50001,
      "amount": 125.50
    },
    {
      "order_id": 50002,
      "amount": 75.00
    }
  ]
}
  
এখানে:
- customer_id → number
- customer_name → string
- is_active → boolean
- orders → array
- প্রতিটি order → object






2. Data Analyst বনাম Data Engineer — JSON কেন?
  
কাজ	             Data Analyst	             Data Engineer 
JSON read	          ✅	                     ✅
JSON_VALUE	        ✅	                     ✅
JSON_QUERY	        ✅	                     ✅
OPENJSON	          ✅	                     ⭐⭐⭐
JSON → Table	      ✅	                     ⭐⭐⭐
FOR JSON	          ✅	                     ⭐⭐⭐
API JSON	          ✅	                     ⭐⭐⭐
JSON ETL	          Basic	                   ⭐⭐⭐
Staging	            Basic	                   ⭐⭐⭐
Bronze/Silver/Gold	Basic	                   ⭐⭐⭐
Performance	        Intermediate	           ⭐⭐⭐
Production pipeline	Basic	                   ⭐⭐⭐







3. Complete JSON Roadmap
roadmap-টি সঠিক এবং যথেষ্ট comprehensive। আমি এটিকে ৫টি practical phase-এ ভাগ করছি।
🟢 Phase 1 — JSON Fundamentals
1. JSON Fundamentals
2. JSON Structure
3. JSON Data Types
4. JSON Stored in SQL Server
5. ISJSON()
6. JSON_VALUE()
7. JSON_QUERY()
8. JSON_MODIFY()
9. OPENJSON()
10. OPENJSON() WITH


  
🟡 Phase 2 — JSON Extraction
11. JSON Path
12. Nested JSON
13. JSON Arrays
14. Array + Object Extraction
15. CROSS APPLY + OPENJSON()
16. OUTER APPLY + OPENJSON()
17. JSON → Relational Table



  
🔵 Phase 3 — Relational → JSON
18. Relational Table → JSON
19. FOR JSON AUTO
20. FOR JSON PATH ⭐⭐⭐
21. WITHOUT_ARRAY_WRAPPER
22. INCLUDE_NULL_VALUES
23. ROOT()
24. Nested FOR JSON
25. JSON Aggregation
26. JSON API Response
27. JSON API Request Data


  
🟠 Phase 4 — JSON Engineering
28. JSON ETL ⭐⭐⭐
29. JSON Staging Tables ⭐⭐⭐
30. JSON Data Validation
31. JSON Data Cleaning
32. Error Handling
33. JSON + Temp Tables
34. JSON + CTE
35. JSON + Stored Procedures ⭐⭐⭐
36. JSON + Views
37. JSON + Dynamic SQL
38. JSON + Transactions
39. JSON Deduplication
40. JSON Incremental Loading


  
🔴 Phase 5 — Production Data Engineering
41. JSON → Bronze ⭐⭐⭐
42. Bronze → Silver ⭐⭐⭐
43. Silver → Gold ⭐⭐⭐
44. JSON Indexing / Computed Columns
45. JSON Performance Optimization
46. JSON Security
47. JSON Data Warehouse
48. JSON Data Engineering Patterns
49. Real-World JSON ETL Project ⭐⭐⭐
50. Production Best Practices ⭐⭐⭐








4. Real Company Scenario
আমরা একটি fictional e-commerce company ধরে কাজ করব:
GlobalMart

Business flow:
Customer
   ↓
Order
   ↓
Order Items
   ↓
Product
   ↓
Category

  
আর external system থেকে JSON আসে:
API
 ↓
JSON
 ↓
JSON Staging
 ↓
Bronze
 ↓
Silver
 ↓
Gold
 ↓
Power BI / Reporting








5. JsonDB Database Architecture
আমরা এক database-এর মধ্যে বিভিন্ন schema ব্যবহার করব।
JsonDB
│
├── Sales
│   ├── Customers
│   ├── Orders
│   └── OrderItems
│
├── Product
│   ├── Products
│   └── Categories
│
├── HR
│   ├── Departments
│   └── Employees
│
├── Integration
│   ├── JsonStaging
│   └── ApiLogs
│
├── Bronze
│   └── JsonRawOrders
│
├── Silver
│   └── CleanOrders
│
└── Gold
    └── FactSales







6. -- JSON Fundamentals

1 Object
{
  "customer_id": 10001,
  "name": "Ahmed"
}



2. Array
[
  {
    "product_id": 101,
    "quantity": 2
  },
  {
    "product_id": 102,
    "quantity": 1
  }
]




3. Nested Object
{
  "customer": {
    "id": 10001,
    "name": "Ahmed"
  }
}




4. Array inside Object
{
  "order_id": 50001,
  "items": [
    {
      "product_id": 101,
      "quantity": 2
    }
  ]
}





7. JSON Data Types
  
JSON-এর মূল data types:
JSON	          Example
String	        "Ahmed"
Number	         10001
Boolean	         true
Null	           null
Object	         {}
Array	           []

⚠️ SQL Server-এর JSON storage সাধারণত NVARCHAR(MAX)-এ করা হয়।








8. ISJSON() ⭐
JSON valid কিনা check করতে:
-- Check whether JSON is valid

SELECT
    CustomerID,
    ISJSON(CustomerProfile) AS IsValidJSON
FROM Sales.Customers;


Result:
CustomerID    IsValidJSON
-----------   -----------
10001         1
10002         1
10003         1
Invalid JSON
-- Test invalid JSON

SELECT ISJSON('{"name":"Ahmed"') AS IsValidJSON;
Result:
0








9. JSON_VALUE() ⭐⭐⭐
একটি scalar value বের করতে ব্যবহার হয়।
-- Extract customer phone number

SELECT
    CustomerID,
    JSON_VALUE(CustomerProfile, '$.phone') AS Phone
FROM Sales.Customers;
Nested value
-- Extract loyalty tier

SELECT
    CustomerID,
    JSON_VALUE(CustomerProfile, '$.loyalty.tier') AS LoyaltyTier
FROM Sales.Customers;
Loyalty points
-- Extract loyalty points

SELECT
    CustomerID,
    JSON_VALUE(CustomerProfile, '$.loyalty.points') AS LoyaltyPoints
FROM Sales.Customers;






10. JSON_QUERY() ⭐⭐⭐
JSON_VALUE() → scalar
JSON_QUERY() → object/array
-- Extract complete loyalty object

SELECT
    CustomerID,
    JSON_QUERY(CustomerProfile, '$.loyalty') AS LoyaltyJSON
FROM Sales.Customers;
Result conceptually:
{
  "tier": "Gold",
  "points": 4500
}





11. JSON_MODIFY() ⭐⭐⭐
JSON-এর ভিতরের value পরিবর্তন করতে:
-- Change loyalty tier

UPDATE Sales.Customers
SET CustomerProfile =
    JSON_MODIFY(
        CustomerProfile,
        '$.loyalty.tier',
        'Platinum'
    )
WHERE CustomerID = 10001;
Check:
-- Verify JSON modification

SELECT
    CustomerID,
    CustomerProfile
FROM Sales.Customers
WHERE CustomerID = 10001;






12. JSON Path
সবচেয়ে গুরুত্বপূর্ণ syntax:
$.phone
$.loyalty.tier
$.loyalty.points
$.preferences.language
$.orders[0].order_id
$.orders[*].order_id
$
Root
.
Property navigation
[0]
Array-এর first element






13. OPENJSON() ⭐⭐⭐
JSONকে rows-এ convert করে।
-- Parse a simple JSON object

DECLARE @JSON NVARCHAR(MAX) =
N'{
    "customer_id":10001,
    "customer_name":"Ahmed",
    "country":"Kuwait"
}';

SELECT *
FROM OPENJSON(@JSON);







14. OPENJSON() WITH ⭐⭐⭐
এটাই production JSON ETL-এর সবচেয়ে গুরুত্বপূর্ণ syntax-এর একটি।
-- Convert JSON properties into relational columns

DECLARE @JSON NVARCHAR(MAX) =
N'{
    "customer_id":10001,
    "customer_name":"Ahmed",
    "country":"Kuwait"
}';

SELECT *
FROM OPENJSON(@JSON)
WITH
(
    CustomerID INT '$.customer_id',
    CustomerName VARCHAR(100) '$.customer_name',
    Country VARCHAR(100) '$.country'
);
Result:
CustomerID | CustomerName | Country
-----------|--------------|--------
10001      | Ahmed        | Kuwait









15. Nested JSON
আমাদের Orders table ব্যবহার করুন।
-- Extract nested shipping address properties

SELECT
    OrderID,
    JSON_VALUE(ShippingAddress, '$.city') AS ShippingCity,
    JSON_VALUE(ShippingAddress, '$.country') AS ShippingCountry,
    JSON_VALUE(ShippingAddress, '$.postal_code') AS PostalCode
FROM Sales.Orders;







16. JSON Arrays
Products table-এর tags:
["keyboard","wireless","office"]
Extract:
-- Extract JSON array from product attributes

SELECT
    ProductID,
    JSON_QUERY(ProductAttributes, '$.tags') AS Tags
FROM Product.Products
WHERE ProductID = 101;








17. Array + Object Extraction
-- Extract individual tags from a JSON array

SELECT
    p.ProductID,
    j.value AS Tag
FROM Product.Products p
CROSS APPLY OPENJSON(
    JSON_QUERY(p.ProductAttributes, '$.tags')
) j
WHERE p.ProductID = 101;

Result:
ProductID | Tag
----------|---------
101       | keyboard
101       | wireless
101       | office







18. CROSS APPLY + OPENJSON() ⭐⭐⭐
এটি Data Engineer-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
-- Extract customer loyalty data using OPENJSON

SELECT
    c.CustomerID,
    j.Tier,
    j.Points
FROM Sales.Customers c
CROSS APPLY OPENJSON(c.CustomerProfile)
WITH
(
    Tier VARCHAR(30) '$.loyalty.tier',
    Points INT '$.loyalty.points'
) j;






19. OUTER APPLY + OPENJSON()
  
Difference:
CROSS APPLY	                OUTER APPLY
Matching JSON না থাকলে      row বাদ	Row রাখে
Inner-like	                Left-like
JSON parsing	              Optional JSON parsing



Example:
-- Preserve customer rows even if JSON section is missing

SELECT
    c.CustomerID,
    j.Tier,
    j.Points
FROM Sales.Customers c
OUTER APPLY OPENJSON(c.CustomerProfile)
WITH
(
    Tier VARCHAR(30) '$.loyalty.tier',
    Points INT '$.loyalty.points'
) j;






20. JSON → Relational Table ⭐⭐⭐
এটি বাস্তব ETL-এ খুব common।
-- Convert customer JSON attributes into relational columns

SELECT
    c.CustomerID,
    JSON_VALUE(c.CustomerProfile, '$.phone') AS Phone,
    JSON_VALUE(c.CustomerProfile, '$.preferences.language') AS Language,
    JSON_VALUE(c.CustomerProfile, '$.loyalty.tier') AS LoyaltyTier,
    TRY_CONVERT(
        INT,
        JSON_VALUE(c.CustomerProfile, '$.loyalty.points')
    ) AS LoyaltyPoints
FROM Sales.Customers c;





21. Product JSON → Relational
-- Extract product attributes

SELECT
    ProductID,
    ProductName,
    JSON_VALUE(ProductAttributes, '$.brand') AS Brand,
    JSON_VALUE(ProductAttributes, '$.color') AS Color,
    JSON_VALUE(ProductAttributes, '$.wireless') AS Wireless
FROM Product.Products;






22. Relational Table → JSON
এখন উল্টো direction।
-- Convert relational customer data into JSON

SELECT
    CustomerID,
    CustomerName,
    Country,
    City
FROM Sales.Customers
FOR JSON AUTO;






23. FOR JSON AUTO
SQL Server automatically hierarchy তৈরি করে।
-- Generate JSON automatically

SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderDate
FROM Sales.Customers c
INNER JOIN Sales.Orders o
    ON c.CustomerID = o.CustomerID
FOR JSON AUTO;





24. FOR JSON PATH ⭐⭐⭐
Production API response-এর জন্য সবচেয়ে flexible।
-- Generate controlled JSON using FOR JSON PATH

SELECT
    CustomerID AS [customer.id],
    CustomerName AS [customer.name],
    Country AS [customer.country]
FROM Sales.Customers
FOR JSON PATH;








25. WITHOUT_ARRAY_WRAPPER
Single JSON object:
-- Return a single JSON object instead of an array

SELECT
    CustomerID,
    CustomerName,
    Country
FROM Sales.Customers
WHERE CustomerID = 10001
FOR JSON PATH,
WITHOUT_ARRAY_WRAPPER;







26. INCLUDE_NULL_VALUES
-- Include NULL properties in JSON output

SELECT
    CustomerID,
    CustomerName,
    Email,
    Country
FROM Sales.Customers
FOR JSON PATH,
INCLUDE_NULL_VALUES;






27. ROOT()
-- Add a root element to JSON response

SELECT
    CustomerID,
    CustomerName,
    Country
FROM Sales.Customers
FOR JSON PATH,
ROOT('Customers');






28. Nested FOR JSON
এটি API development-এ অত্যন্ত গুরুত্বপূর্ণ।
-- Generate nested customer + orders JSON

SELECT
    c.CustomerID AS [customer_id],
    c.CustomerName AS [customer_name],

    (
        SELECT
            o.OrderID AS [order_id],
            o.OrderDate AS [order_date],
            o.OrderStatus AS [status]
        FROM Sales.Orders o
        WHERE o.CustomerID = c.CustomerID
        FOR JSON PATH
    ) AS [orders]

FROM Sales.Customers c
FOR JSON PATH;








29. JSON Aggregation
এক customer-এর সব orders একটি JSON array:
-- Aggregate customer orders into JSON arrays

SELECT
    c.CustomerID,
    c.CustomerName,

    (
        SELECT
            o.OrderID,
            o.OrderStatus,
            o.OrderDate
        FROM Sales.Orders o
        WHERE o.CustomerID = c.CustomerID
        FOR JSON PATH
    ) AS OrdersJSON

FROM Sales.Customers c;








30. JSON API Response ⭐⭐⭐
ধরুন website-এর API customer information চাইছে।
Expected response:
{
  "customer_id": 10001,
  "customer_name": "Ahmed Hassan",
  "country": "Kuwait",
  "orders": []
}
SQL:
-- Build customer API response

SELECT
    c.CustomerID AS [customer_id],
    c.CustomerName AS [customer_name],
    c.Country AS [country],

    JSON_QUERY
    (
        (
            SELECT
                o.OrderID AS [order_id],
                o.OrderStatus AS [status],
                o.OrderDate AS [order_date]
            FROM Sales.Orders o
            WHERE o.CustomerID = c.CustomerID
            FOR JSON PATH
        )
    ) AS [orders]

FROM Sales.Customers c
WHERE c.CustomerID = 10001
FOR JSON PATH,
WITHOUT_ARRAY_WRAPPER;








31. JSON API Request Data
ধরুন application SQL Server-এ এই JSON পাঠালো:
{
  "customer_id": 10001,
  "order_status": "Completed",
  "payment_method": "CreditCard"
}
SQL Server:
-- Simulate JSON API request

DECLARE @RequestJSON NVARCHAR(MAX) =
N'{
    "customer_id":10001,
    "order_status":"Completed",
    "payment_method":"CreditCard"
}';

SELECT *
FROM OPENJSON(@RequestJSON)
WITH
(
    CustomerID INT '$.customer_id',
    OrderStatus VARCHAR(30) '$.order_status',
    PaymentMethod VARCHAR(30) '$.payment_method'
);






32. JSON ETL ⭐⭐⭐
Real Data Engineering flow:
JSON API
   ↓
Staging
   ↓
Validation
   ↓
Parsing
   ↓
Cleaning
   ↓
Transformation
   ↓
Silver
   ↓
Gold






33. JSON Staging Table ⭐⭐⭐
আমরা ইতিমধ্যে:
Integration.JsonStaging
তৈরি করেছি।
JSON raw অবস্থায় রাখা:
-- Insert raw API JSON into staging

INSERT INTO Integration.JsonStaging
(
    SourceSystem,
    FileName,
    JsonPayload
)
VALUES
(
    'GlobalMart API',
    'orders_20260306.json',

    N'{
        "order_id":50006,
        "customer_id":10001,
        "status":"Completed",
        "payment_method":"KNET",
        "shipping":{
            "city":"Kuwait City",
            "country":"Kuwait"
        }
    }'
);








34. JSON Data Validation
-- Validate JSON staging records

SELECT
    StagingID,
    SourceSystem,
    FileName,
    ISJSON(JsonPayload) AS IsValidJSON
FROM Integration.JsonStaging;
আরও robust validation:
-- Validate required JSON fields

SELECT
    StagingID,
    JSON_VALUE(JsonPayload, '$.order_id') AS OrderID,
    JSON_VALUE(JsonPayload, '$.customer_id') AS CustomerID,
    JSON_VALUE(JsonPayload, '$.status') AS Status
FROM Integration.JsonStaging
WHERE
    JSON_VALUE(JsonPayload, '$.order_id') IS NULL
    OR JSON_VALUE(JsonPayload, '$.customer_id') IS NULL;







35. JSON Data Cleaning
-- Clean and standardize JSON-derived values

SELECT
    TRY_CONVERT
    (
        INT,
        JSON_VALUE(JsonPayload, '$.order_id')
    ) AS OrderID,

    TRY_CONVERT
    (
        INT,
        JSON_VALUE(JsonPayload, '$.customer_id')
    ) AS CustomerID,

    UPPER
    (
        LTRIM
        (
            RTRIM
            (
                JSON_VALUE(JsonPayload, '$.status')
            )
        )
    ) AS OrderStatus

FROM Integration.JsonStaging;






36. Error Handling
Production ETL:
-- Use TRY...CATCH for JSON ETL errors

BEGIN TRY

    BEGIN TRANSACTION;

    -- JSON transformation logic here

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;








37. JSON + Temp Table
-- Parse JSON into a temporary relational table

DECLARE @JSON NVARCHAR(MAX) =
N'[
    {"id":101,"quantity":2},
    {"id":102,"quantity":5}
]';

SELECT
    ProductID,
    Quantity
INTO #OrderItems
FROM OPENJSON(@JSON)
WITH
(
    ProductID INT '$.id',
    Quantity INT '$.quantity'
);

SELECT *
FROM #OrderItems;







38. JSON + CTE
-- Use a CTE to transform JSON data

DECLARE @JSON NVARCHAR(MAX) =
N'[
    {"product_id":101,"quantity":2,"price":45},
    {"product_id":102,"quantity":3,"price":25}
]';

WITH OrderData AS
(
    SELECT
        ProductID,
        Quantity,
        Price
    FROM OPENJSON(@JSON)
    WITH
    (
        ProductID INT '$.product_id',
        Quantity INT '$.quantity',
        Price DECIMAL(12,2) '$.price'
    )
)
SELECT
    ProductID,
    Quantity,
    Price,
    Quantity * Price AS SalesAmount
FROM OrderData;









39. JSON + Stored Procedure ⭐⭐⭐
API থেকে JSON গ্রহণ করে stored procedure:
-- Stored procedure that accepts JSON input

CREATE OR ALTER PROCEDURE Sales.usp_ProcessOrderJSON
    @OrderJSON NVARCHAR(MAX)
AS
BEGIN

    SET NOCOUNT ON;

    -- Validate JSON

    IF ISJSON(@OrderJSON) <> 1
    BEGIN
        THROW 50001, 'Invalid JSON payload.', 1;
    END;

    -- Parse JSON

    SELECT
        OrderID,
        CustomerID,
        OrderStatus,
        PaymentMethod
    FROM OPENJSON(@OrderJSON)
    WITH
    (
        OrderID INT '$.order_id',
        CustomerID INT '$.customer_id',
        OrderStatus VARCHAR(30) '$.status',
        PaymentMethod VARCHAR(30) '$.payment_method'
    );

END;
GO
Test:
-- Test JSON stored procedure

EXEC Sales.usp_ProcessOrderJSON
N'{
    "order_id":50007,
    "customer_id":10002,
    "status":"Completed",
    "payment_method":"KNET"
}';







40. JSON + Views
-- Create a reporting view from JSON attributes

CREATE OR ALTER VIEW Sales.vw_CustomerJSONProfile
AS
SELECT
    CustomerID,
    CustomerName,
    Country,

    JSON_VALUE(CustomerProfile, '$.phone') AS Phone,

    JSON_VALUE(
        CustomerProfile,
        '$.preferences.language'
    ) AS Language,

    JSON_VALUE(
        CustomerProfile,
        '$.loyalty.tier'
    ) AS LoyaltyTier,

    TRY_CONVERT
    (
        INT,
        JSON_VALUE(
            CustomerProfile,
            '$.loyalty.points'
        )
    ) AS LoyaltyPoints

FROM Sales.Customers;
GO





41. JSON + Dynamic SQL
Dynamic JSON path:
-- Dynamic JSON path example

DECLARE @Property VARCHAR(100) = 'brand';

DECLARE @SQL NVARCHAR(MAX);

SET @SQL = N'
SELECT
    ProductID,
    ProductName,
    JSON_VALUE(ProductAttributes, ''$.' +
    @Property + N''') AS PropertyValue
FROM Product.Products;';

EXEC sys.sp_executesql @SQL;
⚠️ User input directly concatenate করবেন না।








42. JSON + Transactions ⭐⭐⭐
JSON ETL transaction:
-- Process JSON within a transaction

BEGIN TRY

    BEGIN TRANSACTION;

    -- Validate
    -- Parse
    -- Transform
    -- Insert

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;







43. JSON Deduplication
ধরুন API একই order দুইবার পাঠিয়েছে।
-- Deduplicate JSON staging data using OrderID

WITH ParsedData AS
(
    SELECT
        StagingID,

        TRY_CONVERT
        (
            INT,
            JSON_VALUE(JsonPayload, '$.order_id')
        ) AS OrderID,

        LoadDateTime
    FROM Integration.JsonStaging
),
RankedData AS
(
    SELECT
        *,
        ROW_NUMBER() OVER
        (
            PARTITION BY OrderID
            ORDER BY LoadDateTime DESC
        ) AS RN
    FROM ParsedData
)
SELECT *
FROM RankedData
WHERE RN = 1;






44. JSON Incremental Loading
Real Data Engineering-এ:
Last Successful Load
        ↓
New JSON Files
        ↓
Staging
        ↓
Only New Records
        ↓
Silver
Example:
-- Identify records newer than the last successful load

SELECT
    StagingID,
    LoadDateTime,
    JSON_VALUE(JsonPayload, '$.order_id') AS OrderID
FROM Integration.JsonStaging
WHERE LoadDateTime >
(
    SELECT ISNULL(MAX(LoadDateTime), '19000101')
    FROM Silver.CleanOrders
);
Production implementation-এ অবশ্য আলাদা watermark/control table রাখা ভালো।








45. JSON → Bronze ⭐⭐⭐
Bronze-এর principle:
Raw data যতটা সম্ভব unchanged রাখুন।

-- Copy raw JSON payload into Bronze

INSERT INTO Bronze.JsonRawOrders
(
    SourceFile,
    JsonPayload
)
SELECT
    FileName,
    JsonPayload
FROM Integration.JsonStaging;








46. Bronze → Silver ⭐⭐⭐
এখানে:
- validation
- parsing
- cleaning
- type conversion
- standardization
হবে।
-- Transform Bronze JSON into clean Silver relational data

INSERT INTO Silver.CleanOrders
(
    OrderID,
    CustomerID,
    OrderDate,
    OrderStatus,
    PaymentMethod,
    ShippingCity,
    ShippingCountry,
    SalesChannel,
    Coupon,
    Priority
)
SELECT
    TRY_CONVERT
    (
        INT,
        JSON_VALUE(JsonPayload, '$.order_id')
    ),

    TRY_CONVERT
    (
        INT,
        JSON_VALUE(JsonPayload, '$.customer_id')
    ),

    TRY_CONVERT
    (
        DATETIME2,
        JSON_VALUE(JsonPayload, '$.order_date')
    ),

    UPPER(
        LTRIM(
            RTRIM(
                JSON_VALUE(JsonPayload, '$.status')
            )
        )
    ),

    JSON_VALUE(
        JsonPayload,
        '$.payment_method'
    ),

    JSON_VALUE(
        JsonPayload,
        '$.shipping.city'
    ),

    JSON_VALUE(
        JsonPayload,
        '$.shipping.country'
    ),

    JSON_VALUE(
        JsonPayload,
        '$.channel'
    ),

    JSON_VALUE(
        JsonPayload,
        '$.coupon'
    ),

    JSON_VALUE(
        JsonPayload,
        '$.priority'
    )

FROM Bronze.JsonRawOrders
WHERE ISJSON(JsonPayload) = 1;





47. Silver → Gold ⭐⭐⭐
Gold হলো analytics-ready layer।
-- Load analytics-ready sales data into Gold

INSERT INTO Gold.FactSales
(
    OrderID,
    CustomerID,
    ProductID,
    OrderDate,
    Quantity,
    UnitPrice
)
SELECT
    oi.OrderID,
    o.CustomerID,
    oi.ProductID,
    CAST(o.OrderDate AS DATE),
    oi.Quantity,
    oi.UnitPrice
FROM Sales.OrderItems oi
INNER JOIN Sales.Orders o
    ON oi.OrderID = o.OrderID;






48. JSON Indexing / Computed Columns ⭐⭐⭐
ধরুন আমরা বারবার loyalty tier filter করছি।
-- Create a persisted computed column from JSON

ALTER TABLE Sales.Customers
ADD LoyaltyTier AS
(
    JSON_VALUE(
        CustomerProfile,
        '$.loyalty.tier'
    )
) PERSISTED;
তারপর index:
-- Index the computed JSON property

CREATE INDEX IX_Customers_LoyaltyTier
ON Sales.Customers(LoyaltyTier);
Query:
-- Filter using the indexed computed column

SELECT *
FROM Sales.Customers
WHERE LoyaltyTier = 'Gold';








49. JSON Performance Optimization

  
❌ Bad
WHERE JSON_VALUE(CustomerProfile, '$.loyalty.tier') = 'Gold'
প্রতিটি query-তে JSON parse করতে হতে পারে।

  
✅ Better
ALTER TABLE Sales.Customers
ADD LoyaltyTier AS
(
    JSON_VALUE(CustomerProfile, '$.loyalty.tier')
) PERSISTED;



তারপর:
CREATE INDEX IX_Customers_LoyaltyTier
ON Sales.Customers(LoyaltyTier);



Performance principles
- 🚀 Frequently queried JSON properties → computed columns
- 🚀 Proper indexes
- 🚀 Avoid unnecessary NVARCHAR(MAX)
- 🚀 Parse once where possible
- 🚀 Stage raw JSON
- 🚀 Transform to relational structures for analytics
- 🚀 Don't repeatedly parse the same large payload







50. JSON Security
  
JSON security-এর গুরুত্বপূর্ণ বিষয়:
🔐 Never trust incoming JSON
IF ISJSON(@JSON) <> 1
    THROW 50001, 'Invalid JSON', 1;

  
🔐 Validate data types
TRY_CONVERT(INT, JSON_VALUE(@JSON, '$.customer_id'))

  
🔐 Avoid dynamic SQL injection
❌:
EXEC('SELECT ... ' + @UserInput);

  
✅:
EXEC sys.sp_executesql
    @SQL,
    N'@CustomerID INT',
    @CustomerID = @CustomerID;


🔐 Sensitive information
- API tokens JSON-এর মধ্যে plain text হিসেবে রাখবেন না
- passwords JSON column-এ রাখবেন না
- secrets database source code-এ hardcode করবেন না
- least-privilege access ব্যবহার করুন








51. JSON Data Warehouse
একটি modern architecture:
                 External APIs
                     │
                     ▼
                JSON Payload
                     │
                     ▼
              ┌─────────────┐
              │   Bronze    │
              │ Raw JSON    │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │   Silver    │
              │ Clean Data  │
              └──────┬──────┘
                     │
                     ▼
              ┌─────────────┐
              │    Gold     │
              │ Star Schema │
              └──────┬──────┘
                     │
             ┌───────┴────────┐
             ▼                ▼
          Power BI         Analytics





52. JSON Data Engineering Patterns
আপনার জন্য সবচেয়ে গুরুত্বপূর্ণ patterns:
Pattern 1 — API ingestion
API
 ↓
JSON
 ↓
Staging
 ↓
SQL
Pattern 2 — Raw preservation
JSON
 ↓
Bronze
Pattern 3 — Schema-on-read
Raw JSON
 ↓
OPENJSON
 ↓
Relational columns
Pattern 4 — Schema enforcement
JSON
 ↓
OPENJSON WITH
 ↓
Explicit SQL data types
Pattern 5 — Medallion
Bronze → Silver → Gold







53. Real-World JSON ETL Project ⭐⭐⭐
এখন আপনার সবচেয়ে গুরুত্বপূর্ণ hands-on project।
Scenario
GlobalMart-এর mobile application থেকে প্রতিদিন JSON order আসে।
একটি payload:
{
  "order_id": 60001,
  "customer_id": 10001,
  "order_date": "2026-08-23T10:30:00",
  "status": "Completed",
  "payment_method": "KNET",
  "channel": "MobileApp",
  "shipping": {
    "city": "Kuwait City",
    "country": "Kuwait"
  },
  "items": [
    {
      "product_id": 101,
      "quantity": 2,
      "unit_price": 45
    },
    {
      "product_id": 108,
      "quantity": 1,
      "unit_price": 40
    }
  ]
}







54. Step 1 — Store Raw JSON
-- Store complete API payload in staging

DECLARE @OrderJSON NVARCHAR(MAX) =
N'{
    "order_id":60001,
    "customer_id":10001,
    "order_date":"2026-08-23T10:30:00",
    "status":"Completed",
    "payment_method":"KNET",
    "channel":"MobileApp",

    "shipping":{
        "city":"Kuwait City",
        "country":"Kuwait"
    },

    "items":[
        {
            "product_id":101,
            "quantity":2,
            "unit_price":45
        },
        {
            "product_id":108,
            "quantity":1,
            "unit_price":40
        }
    ]
}';

INSERT INTO Integration.JsonStaging
(
    SourceSystem,
    FileName,
    JsonPayload
)
VALUES
(
    'Mobile API',
    'order_60001.json',
    @OrderJSON
);




  
55. Step 2 — Validate
-- Validate the incoming order JSON

SELECT
    ISJSON(@OrderJSON) AS IsValidJSON;



  
56. Step 3 — Extract Header
-- Extract order header from JSON

SELECT *
FROM OPENJSON(@OrderJSON)
WITH
(
    OrderID INT '$.order_id',
    CustomerID INT '$.customer_id',
    OrderDate DATETIME2 '$.order_date',
    OrderStatus VARCHAR(30) '$.status',
    PaymentMethod VARCHAR(30) '$.payment_method',
    Channel VARCHAR(50) '$.channel',
    ShippingCity VARCHAR(100) '$.shipping.city',
    ShippingCountry VARCHAR(100) '$.shipping.country'
);



  
57. Step 4 — Extract Order Items
-- Extract nested order items from JSON

SELECT *
FROM OPENJSON(@OrderJSON, '$.items')
WITH
(
    ProductID INT '$.product_id',
    Quantity INT '$.quantity',
    UnitPrice DECIMAL(12,2) '$.unit_price'
);



  
58. Step 5 — CROSS APPLY ⭐⭐⭐
একই JSON থেকে header + items:
-- Extract order header and nested items together

SELECT
    h.OrderID,
    h.CustomerID,
    h.OrderDate,
    h.OrderStatus,
    h.PaymentMethod,
    h.Channel,
    i.ProductID,
    i.Quantity,
    i.UnitPrice,

    i.Quantity * i.UnitPrice AS SalesAmount

FROM OPENJSON(@OrderJSON)
WITH
(
    OrderID INT '$.order_id',
    CustomerID INT '$.customer_id',
    OrderDate DATETIME2 '$.order_date',
    OrderStatus VARCHAR(30) '$.status',
    PaymentMethod VARCHAR(30) '$.payment_method',
    Channel VARCHAR(50) '$.channel'
) h

CROSS APPLY OPENJSON(@OrderJSON, '$.items')
WITH
(
    ProductID INT '$.product_id',
    Quantity INT '$.quantity',
    UnitPrice DECIMAL(12,2) '$.unit_price'
) i;

  
Result:
OrderID | CustomerID | ProductID | Qty | Price | Sales
--------|------------|-----------|-----|-------|------
60001   | 10001      | 101       | 2   | 45    | 90
60001   | 10001      | 108       | 1   | 40    | 40




  
59. Step 6 — JSON → Relational
এটাই মূল Data Engineering skill:
Nested JSON
     ↓
OPENJSON
     ↓
CROSS APPLY
     ↓
Relational Rows
     ↓
SQL Tables



  
60. Step 7 — Business Analysis
এখন JSON থেকে বের করা relational data দিয়ে normal SQL analytics:
Customer Sales
-- Calculate total sales by customer

SELECT
    c.CustomerID,
    c.CustomerName,
    SUM(fs.SalesAmount) AS TotalSales
FROM Gold.FactSales fs
INNER JOIN Sales.Customers c
    ON fs.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID,
    c.CustomerName
ORDER BY TotalSales DESC;
Product Sales
-- Calculate sales by product

SELECT
    p.ProductID,
    p.ProductName,
    SUM(fs.SalesAmount) AS TotalSales
FROM Gold.FactSales fs
INNER JOIN Product.Products p
    ON fs.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName
ORDER BY TotalSales DESC;

