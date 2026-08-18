-- ============================================================
-- VERIFY TABLES
-- ============================================================

SELECT * FROM Sales.Customers;

SELECT * FROM Sales.Products;

SELECT * FROM Sales.Orders;

SELECT * FROM Sales.Employees;


1️⃣ Subquery Fundamentals
সহজভাবে
-- Subquery = একটি query-এর ভিতরে আরেকটি query।
SELECT ...
FROM ...
WHERE column > 
(
    SELECT ...
);


এখানে:
(
    SELECT ...
)
হলো Subquery।

  
-- Real-world Example
-- Average product price-এর চেয়ে বেশি দামের products খুঁজব।
প্রথমে average বের করতে হবে:
SELECT AVG(Price)
FROM Sales.Products;


-- তারপর সেই result ব্যবহার করব:
SELECT *
FROM Sales.Products
WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);



Mental Model 🧠
Outer Query
     │
     └── Subquery
           │
           └── Result
                  │
                  ↓
             Outer Query






2️⃣ Subquery Result Types
Subquery কী ধরনের result return করছে—এটি বোঝা অত্যন্ত গুরুত্বপূর্ণ।

  
মূলত 3 ধরনের result:
Type	            Result	                 সাধারণ ব্যবহার
Scalar	          1 value	                 =, >, <
Row	              1 row	                   row comparison
Table	            multiple rows/columns	   IN, EXISTS, FROM, JOIN


1. Scalar Query
একটি মাত্র value।
-- ============================================================
-- SCALAR RESULT
-- ============================================================
SELECT AVG(Sales)
FROM Sales.Orders;


Result:
703.33...
এটি একটি value।

  
তাই:
SELECT *
FROM Sales.Orders
WHERE Sales >
(
    SELECT AVG(Sales)
    FROM Sales.Orders
);



2. Row Query
একটি বা একাধিক row-এর একটি column:
-- ============================================================
-- ROW RESULT
-- ============================================================
SELECT CustomerID
FROM Sales.Orders;
Result:
1
2
3
2
4


এটি সাধারণত IN-এর সাথে ব্যবহার করা যায়।
SELECT *
FROM Sales.Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Orders
);




3. Table Query
Multiple columns + multiple rows।
-- ============================================================
-- TABLE RESULT
-- ============================================================
SELECT
    OrderID,
    CustomerID,
    Sales
FROM Sales.Orders;

এটি FROM বা JOIN-এ ব্যবহার করা যায়।







3️⃣ Scalar Subquery
কখন ব্যবহার করব?
যখন subquery একটি মাত্র value return করবে।
Syntax
SELECT ...
FROM table
WHERE column > 
(
    SELECT aggregate_function(column)
    FROM table
);
Example
-- ============================================================
-- PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================
SELECT
    ProductID,
    Product,
    Price
FROM Sales.Products
WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);


কেন?
Business question:
কোন products-এর price overall average price-এর চেয়ে বেশি?







4️⃣ Subquery in WHERE
WHERE-এ subquery সবচেয়ে বেশি ব্যবহৃত হয়।
Example
Germany-এর customers-এর orders:
-- ============================================================
-- ORDERS FROM GERMAN CUSTOMERS
-- ============================================================
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);


Execution concept
প্রথমে:
SELECT CustomerID
FROM Sales.Customers
WHERE Country = 'Germany';


ধরা যাক result:
2
4
6
তারপর outer query:
WHERE CustomerID IN (2,4,6)








5️⃣ Comparison Operators
Subquery-এর সাথে সাধারণ comparison operators ব্যবহার করা যায়।
=
>
<
>=
<=
<>
> Example
-- ============================================================
-- PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================
SELECT
    ProductID,
    Product,
    Price
FROM Sales.Products
WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);


< Example
-- ============================================================
-- PRODUCTS BELOW AVERAGE PRICE
-- ============================================================
SELECT
    ProductID,
    Product,
    Price
FROM Sales.Products
WHERE Price <
(
    SELECT AVG(Price)
    FROM Sales.Products
);




= Example
-- ============================================================
-- PRODUCTS HAVING THE MAXIMUM PRICE
-- ============================================================
SELECT *
FROM Sales.Products
WHERE Price =
(
    SELECT MAX(Price)
    FROM Sales.Products
);








6️⃣ IN
কখন?
Subquery যখন multiple values return করবে।
Syntax
WHERE column IN
(
    SELECT column
    FROM table
    WHERE condition
);
Example
-- ============================================================
-- ORDERS FROM CUSTOMERS IN GERMANY
-- ============================================================
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);



IN মানে
CustomerID = 2
OR CustomerID = 4
OR CustomerID = 6


  
Real Business Example
Germany বা France-এর customers-এর orders।
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country IN ('Germany', 'France')
);







7️⃣ NOT IN
IN-এর বিপরীত।
-- ============================================================
-- ORDERS FROM CUSTOMERS NOT IN GERMANY
-- ============================================================
SELECT *
FROM Sales.Orders
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);



⚠️ খুব গুরুত্বপূর্ণ: NULL সমস্যা
NOT IN এবং NULL dangerous combination।
যদি subquery result হয়:
2
4
6
NULL
তাহলে:
WHERE CustomerID NOT IN (...)
  
unexpected result দিতে পারে।
Production SQL-এ এই কারণে NOT EXISTS অনেক সময় safer choice।






8️⃣ ANY
ANY মানে:
Subquery-এর কমপক্ষে একটি value-এর সাথে condition true হলেই হবে।

SQL Server-এ:
ANY
এবং
SOME
একই অর্থে ব্যবহার করা যায়।
Syntax
WHERE column > ANY
(
    SELECT column
    FROM table
);


Example
-- ============================================================
-- FEMALE EMPLOYEES WHO EARN MORE THAN ANY MALE EMPLOYEE
-- ============================================================
SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary > ANY
(
    SELECT Salary
    FROM Sales.Employees
    WHERE Gender = 'M'
);



Male salaries:
50000
55000
60000
70000
95000

  
Female salary যদি:
65000
তাহলে 65000 > 50000 true।
তাই row qualify করবে।

  
গুরুত্বপূর্ণ ধারণা
> ANY
প্রায়শই minimum-এর সাথে সম্পর্কিত:
x > ANY(values)
≈ x > MIN(values)






9️⃣ ALL
ALL মানে:
Subquery-এর সব value-এর সাথে condition true হতে হবে।

Syntax
WHERE column > ALL
(
    SELECT column
    FROM table
);


Example
-- ============================================================
-- FEMALE EMPLOYEES WHO EARN MORE THAN ALL MALE EMPLOYEES
-- ============================================================

  
SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary > ALL
(
    SELECT Salary
    FROM Sales.Employees
    WHERE Gender = 'M'
);


Male maximum:
95000
তাই female salary-কে 95000-এর চেয়েও বেশি হতে হবে।

  
Mental Model
Operator	   Meaning
> ANY	       at least one
> ALL	       every value
< ANY	       at least one
< ALL	       every value









🔟 Subquery in SELECT
Subquery SELECT list-এর ভিতরেও ব্যবহার করা যায়।
Example
প্রতিটি product-এর পাশে total orders দেখাব।

-- ============================================================
-- SHOW PRODUCTS AND TOTAL NUMBER OF ORDERS
-- ============================================================
SELECT
    ProductID,
    Product,
    Price,
    (
        SELECT COUNT(*)
        FROM Sales.Orders
    ) AS TotalOrders
FROM Sales.Products;


এখানে TotalOrders সব product row-এর জন্য একই হবে।

  
আরেকটি useful example
প্রতিটি customer-এর পাশে total sales:
-- ============================================================
-- CUSTOMER TOTAL SALES USING CORRELATED SUBQUERY
-- ============================================================

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    (
        SELECT SUM(o.Sales)
        FROM Sales.Orders AS o
        WHERE o.CustomerID = c.CustomerID
    ) AS TotalSales
FROM Sales.Customers AS c;

এটি correlated subquery-এর example-ও।






1️⃣1️⃣ Subquery in FROM
FROM-এর ভিতরে subquery ব্যবহার করলে সেটিকে একটি temporary result set হিসেবে ব্যবহার করা যায়।
Syntax
SELECT ...
FROM
(
    SELECT ...
    FROM ...
) AS t;
⚠️ SQL Server-এ derived table-এর জন্য alias বাধ্যতামূলক।

  
Example
-- ============================================================
-- PRODUCTS ABOVE AVERAGE PRICE
-- USING SUBQUERY IN FROM
-- ============================================================
SELECT
    ProductID,
    Product,
    Price,
    AvgPrice
FROM
(
    SELECT
        ProductID,
        Product,
        Price,
        AVG(Price) OVER () AS AvgPrice
    FROM Sales.Products
) AS t
WHERE Price > AvgPrice;






12. 1️⃣2️⃣ Derived Table
FROM-এর subquery-কে সাধারণত Derived Table বলা হয়।
-- ============================================================
-- DERIVED TABLE
-- ============================================================
SELECT
    CustomerID,
    TotalSales
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t;



তারপর ranking করা যায়:
-- ============================================================
-- RANK CUSTOMERS BY TOTAL SALES
-- ============================================================
SELECT
    CustomerID,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS CustomerRank
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t;



কেন useful?
প্রথম ধাপে:
Customer → TotalSales
  
তারপর:
TotalSales → Rank
অর্থাৎ complex transformation-কে stages-এ ভাঙতে পারবেন।






1️⃣3️⃣ Subquery in JOIN
Subquery-এর result-কে JOIN করা যায়।
Example
-- ============================================================
-- CUSTOMER DETAILS + TOTAL SALES
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    t.TotalSales
FROM Sales.Customers AS c
LEFT JOIN
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
    ON c.CustomerID = t.CustomerID;



Real-world use
এটি খুব common analytical pattern:
Customer
    ↓
Aggregate Orders
    ↓
JOIN
    ↓
Customer + KPI
Total Orders
-- ============================================================
-- CUSTOMER DETAILS + TOTAL ORDERS
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ISNULL(o.TotalOrders, 0) AS TotalOrders
FROM Sales.Customers AS c
LEFT JOIN
(
    SELECT
        CustomerID,
        COUNT(*) AS TotalOrders
    FROM Sales.Orders
    GROUP BY CustomerID
) AS o
    ON c.CustomerID = o.CustomerID;






1️⃣4️⃣ Nested Subquery
Subquery-এর ভিতরে আবার subquery থাকলে Nested Subquery।
Example
Average price-এর চেয়ে বেশি price-এর products বের করব, যেখানে average calculation-ও একটি nested query structure-এর অংশ।

আরেকটি clearer example:
-- ============================================================
-- NESTED SUBQUERY
-- CUSTOMERS WHOSE SALES ARE ABOVE AVERAGE CUSTOMER SALES
-- ============================================================
SELECT
    CustomerID,
    TotalSales
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales
WHERE TotalSales >
(
    SELECT AVG(TotalSales)
    FROM
    (
        SELECT
            CustomerID,
            SUM(Sales) AS TotalSales
        FROM Sales.Orders
        GROUP BY CustomerID
    ) AS x
);



Structure
Outer Query
   │
   ├── Derived Table
   │
   └── Subquery
          │
          └── Derived Table


  
⚠️ Best Practice
Nested subquery বেশি গভীর হলে readability কমে।
সেক্ষেত্রে CTE অনেক ভালো:
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT *
FROM CustomerSales
WHERE TotalSales >
(
    SELECT AVG(TotalSales)
    FROM CustomerSales
);






1️⃣5️⃣ Correlated Subquery
এটি Subquery-এর সবচেয়ে গুরুত্বপূর্ণ concept-গুলোর একটি।
সহজভাবে
Normal subquery:
Subquery → একবার logically evaluate → outer query ব্যবহার করে
Correlated subquery:
Outer row
   ↓
Subquery
   ↓
Outer row
   ↓
Subquery
   ↓
...
Subquery outer query-এর column reference করে।


  
Example
প্রতিটি customer-এর total orders:
-- ============================================================
-- CORRELATED SUBQUERY
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,

    (
        SELECT COUNT(*)
        FROM Sales.Orders AS o
        WHERE o.CustomerID = c.CustomerID
    ) AS TotalOrders

FROM Sales.Customers AS c;


এখানে:
o.CustomerID = c.CustomerID
এর কারণে subquery outer query-এর c.CustomerID-এর উপর নির্ভর করছে।









1️⃣6️⃣ Correlated EXISTS
EXISTS + correlation = অত্যন্ত powerful pattern।
Example
Germany-এর customer যাদের অন্তত একটি order আছে:
-- ============================================================
-- CORRELATED EXISTS
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Country
FROM Sales.Customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);


এটি শুধু সেই customers return করবে যাদের order আছে।






1️⃣7️⃣ EXISTS
EXISTS কী করে?
EXISTS দেখে:
Subquery অন্তত একটি row return করে কি না।

এটি subquery-এর actual selected value নিয়ে interested নয়।
তাই:
SELECT 1
খুব common।


  
Example
Germany customers-এর orders:
-- ============================================================
-- ORDERS FROM GERMAN CUSTOMERS USING EXISTS
-- ============================================================
SELECT
    o.*
FROM Sales.Orders AS o
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);



SELECT 1 কেন?
কারণ EXISTS শুধু existence check করে।
এগুলো logically equivalent:
SELECT 1
SELECT *
SELECT CustomerID
EXISTS-এর জন্য actual selected column গুরুত্বপূর্ণ নয়।







1️⃣8️⃣ NOT EXISTS
EXISTS-এর বিপরীত।
যেখানে matching row নেই।

Example
যেসব customer-এর কোনো order নেই:
-- ============================================================
-- CUSTOMERS WITHOUT ORDERS
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName
FROM Sales.Customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);



এটি খুব গুরুত্বপূর্ণ Data Engineering pattern
এটি ব্যবহার করে orphan / missing relationship খুঁজে পাওয়া যায়।
Germany ছাড়া customers-এর orders
-- ============================================================
-- ORDERS NOT BELONGING TO GERMAN CUSTOMERS
-- ============================================================
SELECT
    o.*
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);






1️⃣9️⃣ Subquery in HAVING
HAVING aggregate result filter করে।
Example
যেসব customer-এর total sales overall average customer sales-এর চেয়ে বেশি।

-- ============================================================
-- CUSTOMERS ABOVE AVERAGE CUSTOMER SALES
-- ============================================================
SELECT
    CustomerID,
    SUM(Sales) AS TotalSales
FROM Sales.Orders
GROUP BY CustomerID
HAVING SUM(Sales) >
(
    SELECT AVG(TotalSales)
    FROM
    (
        SELECT
            CustomerID,
            SUM(Sales) AS TotalSales
        FROM Sales.Orders
        GROUP BY CustomerID
    ) AS x
);



Important distinction
WHERE
→ row filter

HAVING
→ group/aggregate filter






2️⃣0️⃣ Subquery in UPDATE
Subquery দিয়ে data update করা যায়।
Example
Customer country অনুযায়ী কোনো value update করার pattern:
-- ============================================================
-- UPDATE PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================
UPDATE Sales.Products
SET Category = 'Premium'
WHERE ProductID IN
(
    SELECT ProductID
    FROM Sales.Products
    WHERE Price >
    (
        SELECT AVG(Price)
        FROM Sales.Products
    )


  
⚠️ এটি example হিসেবে দিলাম; production table-এ category overwrite করার আগে অবশ্যই business rule verify করতে হবে।


  
UPDATE + EXISTS
আরও বাস্তব pattern:
যেসব customer-এর order আছে তাদের country-এর data update।

-- ============================================================
-- UPDATE USING EXISTS
-- ============================================================
UPDATE c
SET Gender = UPPER(Gender)
FROM Sales.Customers AS c
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);







2️⃣1️⃣ Subquery in DELETE
Subquery দিয়ে matching records delete করা যায়।
Example
যেসব customers-এর কোনো order নেই তাদের delete করার pattern।

-- ============================================================
-- DELETE CUSTOMERS WITHOUT ORDERS
-- ============================================================
DELETE FROM Sales.Customers
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = Sales.Customers.CustomerID
);



⚠️ আমাদের table-এ FK relationship থাকায় parent customer delete করার আগে 
related records না থাকা নিশ্চিত করতে হবে। এখানে NOT EXISTS সেই logic তৈরি করে।


  
Production Best Practice
Delete-এর আগে:
SELECT *
FROM Sales.Customers
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = Sales.Customers.CustomerID
);


প্রথমে SELECT দিয়ে validate করুন।
তারপর DELETE।







2️⃣2️⃣ Data Quality Subqueries
এখানেই Subquery বাস্তব Data Engineering/Data Quality কাজের জন্য খুব গুরুত্বপূর্ণ।
1. Duplicate Detection
-- ============================================================
-- FIND DUPLICATE CUSTOMER IDs
-- ============================================================
SELECT CustomerID
FROM Sales.Customers
GROUP BY CustomerID
HAVING COUNT(*) > 1;



আর subquery দিয়ে duplicate records:

  
-- ============================================================
-- FIND DUPLICATE CUSTOMERS
-- ============================================================
SELECT *
FROM Sales.Customers
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    GROUP BY CustomerID
    HAVING COUNT(*) > 1
);


2. Orphan Orders
এমন order আছে কি যার customer নেই?

-- ============================================================
-- FIND ORPHAN ORDERS
-- ============================================================
SELECT *
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
);


3. Orders with Invalid Products
-- ============================================================
-- FIND ORDERS WITH INVALID PRODUCT IDs
-- ============================================================
SELECT *
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Products AS p
    WHERE p.ProductID = o.ProductID
);


4. Customers Without Orders
-- ============================================================
-- CUSTOMERS WITH NO ORDERS
-- ============================================================
SELECT *
FROM Sales.Customers AS c
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);




5. Products Never Sold
-- ============================================================
-- PRODUCTS THAT HAVE NEVER BEEN SOLD
-- ============================================================

SELECT *
FROM Sales.Products AS p
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.ProductID = p.ProductID
);

🔥 এটি real-world data quality/analytics-এ অত্যন্ত useful।









2️⃣3️⃣ Subquery vs JOIN
দুটো দিয়েই অনেক সময় একই problem solve করা যায়।
Subquery
Germany customers-এর orders:
-- ============================================================
-- USING SUBQUERY
-- ============================================================
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);
JOIN
-- ============================================================
-- USING JOIN
-- ============================================================
SELECT
    o.*
FROM Sales.Orders AS o
INNER JOIN Sales.Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.Country = 'Germany';


কোনটা কখন?
Situation	                     Preferred
Existence check	               EXISTS
Missing records	               NOT EXISTS
Need columns from both tables	 JOIN
Simple membership	             IN
Aggregate then combine	       JOIN / Derived Table
Scalar calculation	           Scalar Subquery
Complex reusable transformation CTE
Anti-match	                    NOT EXISTS


গুরুত্বপূর্ণ
"Subquery সবসময় slower" — এটি ভুল ধারণা।
SQL Server query optimizer অনেক ক্ষেত্রে logically equivalent JOIN, EXISTS, IN-কে similar execution plan-এ transform করতে পারে।
তাই শুধু syntax দেখে performance সিদ্ধান্ত নেওয়া উচিত নয়।








2️⃣4️⃣ Subquery vs CTE
একই logic CTE দিয়েও লেখা যায়।
Subquery
-- ============================================================
-- SUBQUERY VERSION
-- ============================================================
SELECT *
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS CustomerSales
WHERE TotalSales > 1000;
CTE
-- ============================================================
-- CTE VERSION
-- ============================================================
WITH CustomerSales AS
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
)
SELECT *
FROM CustomerSales
WHERE TotalSales > 1000;

Rule of Thumb
Simple → Subquery
Complex → CTE
Need JOIN columns → JOIN
Existence → EXISTS








2️⃣5️⃣ NULL Behavior & Three-Valued Logic
এটি Subquery-এর সবচেয়ে important advanced topicগুলোর একটি। ⚠️
SQL-এর logical result শুধু:
TRUE
FALSE
নয়।


  
SQL-এ আছে:
TRUE
FALSE
UNKNOWN

  
এটাকে বলে:
Three-Valued Logic


  
NULL + comparison
ধরা যাক:
SELECT *
FROM Sales.Products
WHERE Price = NULL;


এটি কাজ করবে না।

সঠিক:
SELECT *
FROM Sales.Products
WHERE Price IS NULL;
NULL + NOT IN

  
এটি বিশেষভাবে গুরুত্বপূর্ণ।
ধরা যাক:
Subquery result:

2
4
6
NULL

  
তারপর:
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    ...
);



NULL থাকার কারণে comparison UNKNOWN হতে পারে এবং expected rows পাওয়া যাবে না।



  
Safer Pattern
NOT IN-এর পরিবর্তে:
-- ============================================================
-- SAFER ANTI-JOIN PATTERN
-- ============================================================

SELECT *
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);




Golden Rule 🏆
IN
    → membership

NOT IN
    → beware NULL

EXISTS
    → existence

NOT EXISTS
    → non-existence / anti-match







2️⃣6️⃣ Performance & Best Practices
Subquery শেখার পর সবচেয়ে গুরুত্বপূর্ণ বিষয় হলো কীভাবে production-quality SQL লিখবেন।
🥇 1. SELECT * Avoid করুন
❌
SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);


Production-এ প্রয়োজনীয় columns লিখুন:
-- ============================================================
-- BEST PRACTICE: SELECT ONLY REQUIRED COLUMNS
-- ============================================================
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);



🥈 2. EXISTS-এর ভিতরে SELECT 1 ব্যবহার করুন
-- ============================================================
-- EXISTENCE CHECK
-- ============================================================

WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);
কারণ এখানে actual columns দরকার নেই।




🥉 3. NOT IN + NULL সাবধানে
❌
WHERE CustomerID NOT IN
(
    SELECT CustomerID
    FROM SomeTable
);


যদি subquery-তে NULL থাকতে পারে, unexpected result হতে পারে।
প্রয়োজনে:
WHERE NOT EXISTS
(
    SELECT 1
    FROM SomeTable AS x
    WHERE x.CustomerID = c.CustomerID
);





4. Correlated Subquery অতিরিক্ত ব্যবহার করবেন না
এই pattern:
SELECT
    c.CustomerID,

    (
        SELECT SUM(o.Sales)
        FROM Sales.Orders AS o
        WHERE o.CustomerID = c.CustomerID
    ) AS TotalSales

FROM Sales.Customers AS c;



খুব readable।
কিন্তু বড় dataset-এ performance test করা উচিত।
Alternative:
-- ============================================================
-- AGGREGATE FIRST, THEN JOIN
-- ============================================================
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ISNULL(x.TotalSales, 0) AS TotalSales
FROM Sales.Customers AS c
LEFT JOIN
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS x
    ON c.CustomerID = x.CustomerID;




5. Index গুরুত্বপূর্ণ
Subquery performance improve করার জন্য join/filter columns-এ index গুরুত্বপূর্ণ।
যেমন:
-- ============================================================
-- INDEX FOR CUSTOMER LOOKUP
-- ============================================================

CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);
-- ============================================================
-- INDEX FOR PRODUCT LOOKUP
-- ============================================================

CREATE INDEX IX_Orders_ProductID
ON Sales.Orders(ProductID);
-- ============================================================
-- INDEX FOR COUNTRY FILTER
-- ============================================================

CREATE INDEX IX_Customers_Country
ON Sales.Customers(Country);






6. Execution Plan দেখুন
Performance-এর ক্ষেত্রে অনুমান করবেন না।
SQL Server Management Studio-তে:
Ctrl + M
দিয়ে Actual Execution Plan enable করে query execute করতে পারেন।
তারপর দেখবেন:
Index Seek
Index Scan
Table Scan
Nested Loops
Hash Match
Sort
Aggregate




7. SARGability বজায় রাখুন
Filter column-এর উপর unnecessary function ব্যবহার না করাই ভালো।
❌
WHERE YEAR(OrderDate) = 2026
অনেক ক্ষেত্রে index usage কমে যেতে পারে।
Better:
WHERE OrderDate >= '2026-01-01'
  AND OrderDate <  '2027-01-01';
Subquery-এর ক্ষেত্রেও একই principle প্রযোজ্য।










-- 12টি Original Tasks — Corrected & Organized
এখন আপনার original script-এর tasks-গুলো এক জায়গায়।

  
Task 1 — Products Above Average Price
-- ============================================================
-- PRODUCTS ABOVE AVERAGE PRICE
-- ============================================================

SELECT
    ProductID,
    Product,
    Price
FROM Sales.Products
WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);



Task 2 — Customer Sales Ranking
-- ============================================================
-- RANK CUSTOMERS BY TOTAL SALES
-- ============================================================

SELECT
    CustomerID,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS CustomerRank

FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t;



Task 3 — Product + Total Orders
-- ============================================================
-- PRODUCT DETAILS + TOTAL NUMBER OF ORDERS
-- ============================================================

SELECT
    ProductID,
    Product,
    Price,

    (
        SELECT COUNT(*)
        FROM Sales.Orders
    ) AS TotalOrders

FROM Sales.Products;



Task 4 — Customer + Total Sales
-- ============================================================
-- CUSTOMER DETAILS + TOTAL SALES
-- ============================================================

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    c.Country,
    ISNULL(t.TotalSales, 0) AS TotalSales

FROM Sales.Customers AS c

LEFT JOIN
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
    ON c.CustomerID = t.CustomerID;




Task 5 — Customer + Total Orders
-- ============================================================
-- CUSTOMER DETAILS + TOTAL ORDERS
-- ============================================================

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    ISNULL(o.TotalOrders, 0) AS TotalOrders

FROM Sales.Customers AS c

LEFT JOIN
(
    SELECT
        CustomerID,
        COUNT(*) AS TotalOrders
    FROM Sales.Orders
    GROUP BY CustomerID
) AS o
    ON c.CustomerID = o.CustomerID;



Task 6 — Price > Average
-- ============================================================
-- PRICE GREATER THAN AVERAGE
-- ============================================================

SELECT
    ProductID,
    Product,
    Price,

    (
        SELECT AVG(Price)
        FROM Sales.Products
    ) AS AvgPrice

FROM Sales.Products

WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);




Task 7 — Orders from Germany
-- ============================================================
-- ORDERS FROM GERMAN CUSTOMERS
-- ============================================================

SELECT *
FROM Sales.Orders
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);




Task 8 — Orders Not from Germany
Safer production pattern:
-- ============================================================
-- ORDERS NOT FROM GERMAN CUSTOMERS
-- USING NOT EXISTS
-- ============================================================

SELECT
    o.*
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);




Task 9 — Female Salary > ANY Male Salary
-- ============================================================
-- FEMALE SALARY GREATER THAN ANY MALE SALARY
-- ============================================================

SELECT
    EmployeeID,
    FirstName,
    Salary
FROM Sales.Employees
WHERE Gender = 'F'
AND Salary > ANY
(
    SELECT Salary
    FROM Sales.Employees
    WHERE Gender = 'M'
);




Task 10 — Correlated Total Orders
-- ============================================================
-- CORRELATED SUBQUERY
-- TOTAL ORDERS PER CUSTOMER
-- ============================================================

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,

    (
        SELECT COUNT(*)
        FROM Sales.Orders AS o
        WHERE o.CustomerID = c.CustomerID
    ) AS TotalOrders

FROM Sales.Customers AS c;




Task 11 — EXISTS
-- ============================================================
-- ORDERS FROM GERMAN CUSTOMERS USING EXISTS
-- ============================================================

SELECT
    o.*
FROM Sales.Orders AS o
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);





Task 12 — NOT EXISTS
-- ============================================================
-- ORDERS NOT FROM GERMAN CUSTOMERS
-- ============================================================

SELECT
    o.*
FROM Sales.Orders AS o
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Customers AS c
    WHERE c.CustomerID = o.CustomerID
      AND c.Country = 'Germany'
);






🎯 Real Job-এ সবচেয়ে বেশি মনে রাখবেন
1. Average/Maximum/Minimum comparison
WHERE Price >
(
    SELECT AVG(Price)
    FROM Sales.Products
);



2. Membership
WHERE CustomerID IN
(
    SELECT CustomerID
    FROM Sales.Customers
    WHERE Country = 'Germany'
);
3. Existence
WHERE EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);



4. Missing data
WHERE NOT EXISTS
(
    SELECT 1
    FROM Sales.Orders AS o
    WHERE o.CustomerID = c.CustomerID
);



5. Aggregate → Derived Table
FROM
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t



  
6. Aggregate → JOIN
LEFT JOIN
(
    SELECT
        CustomerID,
        SUM(Sales) AS TotalSales
    FROM Sales.Orders
    GROUP BY CustomerID
) AS t
ON c.CustomerID = t.CustomerID;



7. Correlated Subquery
SELECT
    c.CustomerID,

    (
        SELECT COUNT(*)
        FROM Sales.Orders AS o
        WHERE o.CustomerID = c.CustomerID
    ) AS TotalOrders

FROM Sales.Customers AS c;










