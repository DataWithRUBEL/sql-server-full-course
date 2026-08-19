1. View-এর Basic Syntax
/* ============================================================
   CREATE VIEW Syntax
   ============================================================ */

CREATE VIEW Schema.ViewName
AS
SELECT
    column1,
    column2
FROM Schema.TableName;
GO

  
তারপর:
/* View থেকে data read করা */

SELECT *
FROM Schema.ViewName;








2. Basic View তৈরি করা
ধরুন আমরা customer information-এর একটি reusable view চাই।
/* ============================================================
   BASIC VIEW
   Customer information সহজভাবে দেখাবে
   ============================================================ */

CREATE VIEW Sales.V_Customers
AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Sales.Customers;
GO


ব্যবহার:
/* View থেকে data দেখতে */

SELECT *
FROM Sales.V_Customers;


View-এর সুবিধা
আগে:
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Sales.Customers;


বারবার লিখতে হচ্ছে।
এখন:
SELECT *
FROM Sales.V_Customers;








3. View-এ Filter ব্যবহার
/* ============================================================
   FILTERED VIEW
   শুধুমাত্র Kuwait customers
   ============================================================ */
CREATE VIEW Sales.V_Kuwait_Customers
AS
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Sales.Customers
WHERE Country = 'Kuwait';



GO
Query:
SELECT *
FROM Sales.V_Kuwait_Customers;



কোথায় ব্যবহার করবো?
    - Regional reporting
    - Country-wise dashboard
    - Department-specific reporting
    - Restricted business data






4. View দিয়ে Data Security 🔐
ধরুন Customers table-এ অনেক sensitive column আছে।
কিন্তু report user-এর শুধু এগুলো দরকার:
CustomerID
Customer Name
Country
তাহলে পুরো table access না দিয়ে View access দিতে পারি।
/* ============================================================
   SECURITY VIEW
   শুধুমাত্র প্রয়োজনীয় columns expose করা হচ্ছে
   ============================================================ */
CREATE VIEW Sales.V_Customer_Report
AS
SELECT
    CustomerID,
    FirstName + ' ' + LastName AS CustomerName,
    Country
FROM Sales.Customers;


GO
SELECT *
FROM Sales.V_Customer_Report;


বাস্তব Scenario
Base Table
    ↓
Sales.Customers
    ↓
Security View
    ↓
Sales.V_Customer_Report
    ↓
Power BI / Reporting User
এটি column-level abstraction তৈরি করতে সাহায্য করে।








5. View দিয়ে Complex JOIN Hide করা 🔥
এটি View-এর সবচেয়ে গুরুত্বপূর্ণ use case।
আমাদের:
Orders
Products
Customers
Employees
Departments
একসাথে JOIN করতে হবে।
Normal query:
/* ============================================================
   Complex JOIN
   ============================================================ */
SELECT
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    p.Category,
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Country,
    e.FirstName + ' ' + e.LastName AS SalesPerson,
    d.DepartmentName,
    o.Quantity,
    o.Sales
FROM Sales.Orders AS o

LEFT JOIN Sales.Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN HR.Employees AS e
    ON o.SalesPersonID = e.EmployeeID

LEFT JOIN HR.Departments AS d
    ON e.DepartmentID = d.DepartmentID;


Query অনেক বড়।
এটাকে View-এ রেখে দিতে পারি।









6. Order Details View
/* ============================================================
   VIEW USE CASE:
   HIDE COMPLEXITY

   একাধিক table-এর JOIN logic View-এর মধ্যে রাখা হচ্ছে।
   ============================================================ */
CREATE VIEW Sales.V_Order_Details
AS
SELECT
    o.OrderID,
    o.OrderDate,

    -- Product information
    p.ProductName,
    p.Category,

    -- Customer information
    c.FirstName + ' ' + c.LastName AS CustomerName,
    c.Country AS CustomerCountry,

    -- Employee information
    e.FirstName + ' ' + e.LastName AS SalesPerson,
    d.DepartmentName,

    -- Order metrics
    o.Quantity,
    o.Sales

FROM Sales.Orders AS o

LEFT JOIN Sales.Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN HR.Employees AS e
    ON o.SalesPersonID = e.EmployeeID

LEFT JOIN HR.Departments AS d
    ON e.DepartmentID = d.DepartmentID;



GO
এখন:
/* ============================================================
   Complex JOIN আর লিখতে হবে না
   ============================================================ */
SELECT *
FROM Sales.V_Order_Details;









7. View-এর উপর আবার Filter করা যায়
View নিজেই একটি query result হিসেবে কাজ করে।
/* ============================================================
   Kuwait-এর orders
   ============================================================ */
SELECT *
FROM Sales.V_Order_Details
WHERE CustomerCountry = 'Kuwait';



অথবা:
/* ============================================================
   Electronics sales
   ============================================================ */
SELECT *
FROM Sales.V_Order_Details
WHERE Category = 'Electronics';








8. View + GROUP BY 📊
View শুধু raw data দেখানোর জন্য নয়।
Aggregation-ও করা যায়।
/* ============================================================
   MONTHLY SALES SUMMARY VIEW

   প্রতিটি মাসের:
   - Total Sales
   - Total Orders
   - Total Quantity
   ============================================================ */
CREATE VIEW Sales.V_Monthly_Sales
AS
SELECT
    DATETRUNC(MONTH, OrderDate) AS OrderMonth,

    SUM(Sales) AS TotalSales,

    COUNT(OrderID) AS TotalOrders,

    SUM(Quantity) AS TotalQuantity

FROM Sales.Orders

GROUP BY
    DATETRUNC(MONTH, OrderDate);



GO
Query:
SELECT *
FROM Sales.V_Monthly_Sales
ORDER BY OrderMonth;









9. View + Aggregation + JOIN
এবার আরও realistic example।
/* ============================================================
   PRODUCT SALES SUMMARY VIEW

   Product অনুযায়ী:
   - Total Orders
   - Total Quantity
   - Total Sales
   ============================================================ */
CREATE VIEW Sales.V_Product_Sales_Summary
AS
SELECT
    p.ProductID,
    p.ProductName,
    p.Category,

    COUNT(o.OrderID) AS TotalOrders,

    SUM(o.Quantity) AS TotalQuantity,

    SUM(o.Sales) AS TotalSales

FROM Sales.Products AS p

LEFT JOIN Sales.Orders AS o
    ON p.ProductID = o.ProductID

GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category;


GO
ব্যবহার:
SELECT *
FROM Sales.V_Product_Sales_Summary
ORDER BY TotalSales DESC;

এটি Power BI-এর জন্য খুব useful reporting layer হতে পারে।










10. Data Security — Country Based View 🔐
ধরুন EU/International sales team-কে USA customer দেখানো যাবে না।
/* ============================================================
   DATA SECURITY VIEW

   USA customer বাদ দেওয়া হচ্ছে।

   NOTE:
   এটি logical filtering।
   প্রকৃত security implementation-এ
   permissions/Row-Level Security প্রয়োজন হতে পারে।
   ============================================================ */
CREATE VIEW Sales.V_International_Order_Details
AS
SELECT
    o.OrderID,
    o.OrderDate,
    p.ProductName,
    p.Category,

    c.FirstName + ' ' + c.LastName AS CustomerName,

    c.Country AS CustomerCountry,

    e.FirstName + ' ' + e.LastName AS SalesPerson,

    d.DepartmentName,

    o.Quantity,
    o.Sales

FROM Sales.Orders AS o

LEFT JOIN Sales.Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN HR.Employees AS e
    ON o.SalesPersonID = e.EmployeeID

LEFT JOIN HR.Departments AS d
    ON e.DepartmentID = d.DepartmentID

WHERE c.Country <> 'USA';



GO
Query:
SELECT *
FROM Sales.V_International_Order_Details;








11. View Modify করা
Existing View-এর logic পরিবর্তন করতে:
/* ============================================================
   ALTER VIEW
   ============================================================ */
ALTER VIEW Sales.V_Monthly_Sales
AS
SELECT
    DATETRUNC(MONTH, OrderDate) AS OrderMonth,

    SUM(Sales) AS TotalSales,

    COUNT(OrderID) AS TotalOrders,

    SUM(Quantity) AS TotalQuantity,

    AVG(Sales) AS AverageOrderValue

FROM Sales.Orders

GROUP BY
    DATETRUNC(MONTH, OrderDate);



GO
এখন:
SELECT *
FROM Sales.V_Monthly_Sales;


⭐ Best Practice
পুরো View delete করে আবার create করার চেয়ে সাধারণ modification-এর জন্য:
ALTER VIEW
ব্যবহার করা ভালো।










12. View Drop করা
/* ============================================================
   DROP VIEW
   ============================================================ */
DROP VIEW Sales.V_Kuwait_Customers;



GO
Modern SQL Server syntax:
/* View থাকলে Drop করবে */

DROP VIEW IF EXISTS Sales.V_Kuwait_Customers;
GO






13. View আছে কিনা Check করা
/* ============================================================
   Check View Exists
   ============================================================ */

IF OBJECT_ID('Sales.V_Customers', 'V') IS NOT NULL
    PRINT 'View Exists';
ELSE
    PRINT 'View Does Not Exist';






14. Database-এর সব Views দেখা
/* ============================================================
   Database-এর সব Views
   ============================================================ */
SELECT
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName
FROM sys.views
ORDER BY
    SchemaName,
    ViewName;







15. View-এর Definition দেখা 🔍
/* ============================================================
   View-এর SQL Definition দেখা
   ============================================================ */
SELECT
    OBJECT_SCHEMA_NAME(object_id) AS SchemaName,
    OBJECT_NAME(object_id) AS ViewName,
    definition
FROM sys.sql_modules
WHERE OBJECT_NAME(object_id) = 'V_Order_Details';
অথবা:
EXEC sp_helptext 'Sales.V_Order_Details';









16. View-এর Column Information
/* ============================================================
   View-এর columns সম্পর্কে information
   ============================================================ */
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sales'
  AND TABLE_NAME = 'V_Order_Details'
ORDER BY ORDINAL_POSITION;








17. View-এর উপর JOIN করা যায়
View থেকে data নিয়ে অন্য table-এর সাথে JOIN করা যায়।
/* ============================================================
   View + Table JOIN
   ============================================================ */
SELECT
    v.OrderID,
    v.CustomerName,
    v.ProductName,
    v.Sales
FROM Sales.V_Order_Details AS v
INNER JOIN Sales.Products AS p
    ON v.ProductName = p.ProductName;

তবে production code-এ সম্ভব হলে stable key দিয়ে JOIN করা ভালো; name-based JOIN সাধারণত দুর্বল design।







18. View + WHERE + GROUP BY
/* ============================================================
   Country-wise sales analysis

   View থেকে আবার aggregation করা হচ্ছে।
   ============================================================ */
SELECT
    CustomerCountry,
    SUM(Sales) AS TotalSales,
    COUNT(OrderID) AS TotalOrders
FROM Sales.V_Order_Details
GROUP BY
    CustomerCountry
ORDER BY
    TotalSales DESC;









19. View + Window Function
View-এর মধ্যে advanced analytics logic-ও রাখা যায়।
/* ============================================================
   CUSTOMER SALES RANKING VIEW

   Customer-এর total sales এবং ranking।
   ============================================================ */
CREATE VIEW Sales.V_Customer_Sales_Ranking
AS
SELECT
    CustomerID,
    CustomerName,
    CustomerCountry,

    SUM(Sales) AS TotalSales,

    RANK() OVER
    (
        ORDER BY SUM(Sales) DESC
    ) AS SalesRank

FROM Sales.V_Order_Details

GROUP BY
    CustomerID,
    CustomerName,
    CustomerCountry;


GO
⚠️ এখানে আমাদের current V_Order_Details-এ CustomerID নেই। তাই production-ready version করতে CustomerID view-তে include করা উচিত।
এটি গুরুত্বপূর্ণ lesson:
View design করার সময় future analytical requirements মাথায় রেখে প্রয়োজনীয় business keys রাখা উচিত।







20.View-এ ORDER BY কেন সাধারণত ব্যবহার করি না?
❌ এভাবে View বানানো উচিত নয়:
  
CREATE VIEW Sales.V_Test
AS
SELECT *
FROM Sales.Orders
ORDER BY OrderDate;


SQL Server সাধারণ View-এ ORDER BY allow করে না, যদি না TOP, OFFSET ইত্যাদি নির্দিষ্ট construct থাকে।
সঠিক approach:

  
SELECT *
FROM Sales.V_Order_Details
ORDER BY OrderDate DESC;


কারণ
View = Data definition
SELECT query = Presentation/order
তাই sorting consumer query-তে রাখাই ভালো।








21. View কি Data Store করে? 🤔
সাধারণ View:
View
 ↓
SELECT Query
 ↓
Underlying Tables
 ↓
Data
View সাধারণত আলাদা করে result data store করে না।
  
উদাহরণ:
CREATE VIEW Sales.V_Customers
AS
SELECT *
FROM Sales.Customers;


Customer table-এ নতুন row insert করলে:
INSERT INTO Sales.Customers
VALUES
(9, 'RUBEL', 'Ahmed', 'Kuwait');

তারপর:
SELECT *
FROM Sales.V_Customers;

নতুন customer-ও View-তে দেখা যাবে।







22. View vs Table
  
বিষয়	                              Table	                   View
Data store	                        ✅ হ্যাঁ	                   ❌ সাধারণত না
Physical storage	                  ✅	                     ❌
Query save	                        ❌	                     ✅
JOIN hide	                          ❌	                     ✅
Security layer	                    সীমিত	                   ✅
Reusable query	                    ❌	                     ✅
Reporting	                          ✅	                     ⭐⭐⭐⭐⭐
Power BI source	                    ✅	                     ✅
Aggregation logic	                  সম্ভব	                   ✅
Business logic abstraction	        সীমিত	                   ✅









23. View vs Stored Procedure
  
এটি খুব গুরুত্বপূর্ণ।
বিষয়	                       View	                          Stored Procedure
মূল উদ্দেশ্য	                   Reusable query	                Reusable process
Parameters	                 ❌ সাধারণ View-এ নেই	          ✅
SELECT	                     ✅	                            ✅
INSERT/UPDATE/DELETE	       সাধারণ View-এর মূল উদ্দেশ্য নয়	  ✅
JOIN	                       ✅	                            ✅
GROUP BY	                   ✅	                            ✅
Power BI	                   ⭐⭐⭐⭐⭐	                  ⭐⭐⭐
Data abstraction	           ⭐⭐⭐⭐⭐	                  ⭐⭐⭐⭐
ETL process	                 ❌	                            ✅



সহজভাবে:
View
→ "আমাকে একটা reusable dataset দাও"

Stored Procedure
→ "এই কাজগুলো execute করো"








24. View-এর গুরুত্বপূর্ণ Use Cases 🎯
① Reporting View
Tables
  ↓
View
  ↓
Power BI

  
② Security View
Sensitive Table
      ↓
Restricted View
      ↓
User

  
③ Complexity Hiding
5 Tables
   ↓
Multiple JOINs
   ↓
Business Logic
   ↓
One View
   ↓
Simple SELECT

  
④ Business Logic
/* Example:
   Customer classification
*/
CREATE VIEW Sales.V_Customer_Segment
AS
SELECT
    CustomerID,
    FirstName + ' ' + LastName AS CustomerName,

    CASE
        WHEN Country = 'Kuwait'
            THEN 'Local'
        ELSE 'International'
    END AS CustomerSegment
FROM Sales.Customers;
GO








25. Real Data Analyst Workflow 📊
একজন Data Analyst সরাসরি অনেক complicated table JOIN না করে:
Raw Tables
    ↓
Business View
    ↓
Analysis
    ↓
Power BI / Excel

  
উদাহরণ:
SELECT
    CustomerCountry,
    SUM(Sales) AS TotalSales
FROM Sales.V_Order_Details
GROUP BY CustomerCountry
ORDER BY TotalSales DESC;









26. Real Data Engineer Workflow ⚙️
Data Engineering environment-এ View একটি logical/semantic layer হিসেবে ব্যবহার করা যায়:
Source Tables
     ↓
Staging / Transformation
     ↓
Business View
     ↓
Reporting / Analytics
বিশেষ করে:
- 🔹 Business logic abstraction
- 🔹 Data access layer
- 🔹 Reporting layer
- 🔹 Semantic layer
- 🔹 Compatibility layer
- 🔹 Complex joins encapsulation





27. Important Best Practices ⭐
- 🟢 Naming: schema.V_EntityPurpose ব্যবহার করুন।
- 🟢 Schema: View-এর জন্য meaningful schema ব্যবহার করুন।
- 🟢 Keys: প্রয়োজনীয় business keys View-তে রাখুন।
- 🟢 Explicit Columns: SELECT * production View-এ এড়িয়ে চলুন।
- 🟢 Security: Sensitive columns View-তে expose করবেন না।
- 🟢 Performance: View নিজে performance magic তৈরি করে না।
- 🟢 Indexing: বড় workload হলে indexed view আলাদা বিষয় হিসেবে বিবেচনা করুন।
- 🟢 Logic: Reusable business logic View-তে রাখা যায়।
- 🟢 Naming: V_Monthly_Sales, V_Order_Details ধরনের descriptive নাম দিন।
- 🟢 Testing: View তৈরি করার পর row count, NULL, duplicate এবং business logic validate করুন।








28. Common Mistakes ❌
❌ Mistake 1 — View-এ SELECT *
CREATE VIEW Sales.V_Test
AS
SELECT *
FROM Sales.Orders;


Better:
CREATE VIEW Sales.V_Test
AS
SELECT
    OrderID,
    OrderDate,
    CustomerID,
    ProductID,
    Quantity,
    Sales
FROM Sales.Orders;



❌ Mistake 2 — View-কে Security-এর একমাত্র মাধ্যম ভাবা
View Filter
≠
Complete Database Security
Sensitive enterprise environment-এ permissions, roles এবং প্রয়োজনে Row-Level Security (RLS) ব্যবহার করতে হয়।


  
❌ Mistake 3 — অতিরিক্ত nested views
View A
 ↓
View B
 ↓
View C
 ↓
View D
 ↓
View E
এতে dependency এবং debugging complexity বাড়তে পারে।


  
❌ Mistake 4 — View-এ unnecessary complexity
View-এর উদ্দেশ্য query-কে reusable এবং understandable করা।
অপ্রয়োজনীয় nested logic দিয়ে View-কে giant query বানানো উচিত নয়।








29. Practice — Beginner 🟢
Practice 1
Sales.V_Products তৈরি করুন যেখানে থাকবে:
ProductID
ProductName
Category
Price


  
Practice 2
Sales.V_Expensive_Products তৈরি করুন যেখানে:
Price > 300
Practice 3
Sales.V_Kuwait_Customers তৈরি করুন যেখানে:
Country = 'Kuwait'






30. Practice — Intermediate 🟡
Practice 4
Sales.V_Order_Details-এর মতো একটি View তৈরি করুন যেখানে থাকবে:
OrderID
OrderDate
ProductName
CustomerName
Country
SalesPerson
Department
Quantity
Sales



  
Practice 5
Monthly sales View তৈরি করুন:
OrderMonth
TotalSales
TotalOrders
TotalQuantity
AverageSales




Practice 6
Country-wise sales summary View তৈরি করুন:
Country
TotalOrders
TotalQuantity
TotalSales







31. Practice — Advanced 🔴
Practice 7
Customer sales summary View তৈরি করুন:
CustomerID
CustomerName
Country
TotalOrders
TotalQuantity
TotalSales
AverageOrderValue


  
Practice 8
Product performance View:
ProductID
ProductName
Category
TotalOrders
TotalQuantity
TotalSales
তারপর:
SELECT TOP 5 *
FROM Sales.V_Product_Sales_Summary
ORDER BY TotalSales DESC;



Practice 9 — Security
একটি View তৈরি করুন যেখানে:
USA customer বাদ
Sales > 500
শুধুমাত্র international high-value orders দেখাবে।








32. Complete View Lifecycle 🔄
CREATE VIEW
     ↓
VIEW তৈরি
     ↓
SELECT FROM VIEW
     ↓
Business Analysis
     ↓
ALTER VIEW
     ↓
Logic পরিবর্তন
     ↓
DROP VIEW
     ↓
View remove






