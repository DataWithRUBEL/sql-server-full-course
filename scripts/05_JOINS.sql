/* ================================================================
   VERIFY TABLE DATA
================================================================ */

SELECT * FROM Countries;

SELECT * FROM Categories;

SELECT * FROM Departments;

SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Employees;

SELECT * FROM Orders;


1. NO JOIN
প্রথমে আলাদা আলাদা table থেকে data দেখি।
/* ================================================================
   NO JOIN
   Customers এবং Orders আলাদাভাবে দেখা হচ্ছে
================================================================ */

SELECT *
FROM Customers;

SELECT *
FROM Orders;

🎯 Real Business Use
Customer master দেখতে
Sales transactions দেখতে
Data profiling করতে
JOIN করার আগে source data বুঝতে



  


2. INNER JOIN
Customer + Order
/* ================================================================
   INNER JOIN

   শুধুমাত্র যেসব customer-এর matching order আছে
   সেগুলো দেখাবে।
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    o.Sales
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


🧠 কী হচ্ছে?
Customers
    +
Orders
    ↓
Matching CustomerID
    ↓
Only matched rows
CustomerID = 107 দেখাবে না।

  
কারণ:
Customer 107
     ↓
No Order
     ↓
INNER JOIN বাদ দেবে 

  
একইভাবে:
Order 5010
CustomerID = 999
     ↓
Customer 999 নেই
     ↓
INNER JOIN বাদ দেবে 
  
📊 Real Business Question
"কোন customer কী কী order করেছে?"

এটাই INNER JOIN-এর সবচেয়ে common ব্যবহার।






3. LEFT JOIN
/* ================================================================
   LEFT JOIN

   সব customer দেখাবে।
   Order থাকলে order information দেখাবে।
   Order না থাকলে NULL দেখাবে।
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.OrderDate,
    o.Sales
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


এখানে:
Customer 107
     ↓
No Order
     ↓
OrderID = NULL
Sales   = NULL
🎯 Real Business Use
Customer retention / customer activity analysis:
Customer
   ↓
Has Order?
   ↓
Yes / No





4. RIGHT JOIN
/* ================================================================
   RIGHT JOIN

   Orders table-এর সব record দেখাবে।
   Matching customer থাকলে customer information দেখাবে।
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


এখানে OrderID = 5010 থাকবে।
  
কিন্তু:
CustomerID = 999
Customer Name = NULL
কারণ customer 999 নেই।






5. RIGHT JOIN-এর Better Alternative — LEFT JOIN
SQL Server development-এ অনেক developer LEFT JOIN prefer করেন, কারণ query পড়া সহজ হয়।
/* ================================================================
   RIGHT JOIN-এর LEFT JOIN alternative

   Orders-কে LEFT side-এ রাখছি।
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Orders AS o
LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID;


💡 Best Practice
RIGHT JOIN
    ↓
প্রয়োজন হলে ব্যবহার করা যায়

LEFT JOIN
    ↓
সাধারণত বেশি readable









6. FULL JOIN
/* ================================================================
   FULL JOIN

   Customers-এর সব record
   +
   Orders-এর সব record

   Matching থাকলে একসাথে
   Matching না থাকলে NULL
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
FULL JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


এখানে দুই ধরনের unmatched data পাওয়া যাবে:
Customer side
Customer 107
No Order
Order side
Order 5010
Customer 999







7. LEFT ANTI JOIN
SQL Server-এ আলাদা LEFT ANTI JOIN keyword নেই।
আমরা ব্যবহার করি:
LEFT JOIN
+
WHERE right_table.key IS NULL
Customers যারা কোনো order করেনি
/* ================================================================
   LEFT ANTI JOIN

   যেসব customer-এর কোনো order নেই
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;


Result:
CustomerID = 107
🎯 Real Business Use
এটা খুব গুরুত্বপূর্ণ:
Inactive customers
Customers without purchase
Missing transactions
Customer engagement analysis







8. RIGHT ANTI JOIN
/* ================================================================
   RIGHT ANTI JOIN

   যেসব order-এর matching customer নেই
================================================================ */

SELECT
    o.OrderID,
    o.CustomerID,
    o.Sales
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL;


Result:
OrderID = 5010
CustomerID = 999
🎯 Real Data Engineering Use
এটি Data Quality Check হিসেবে অত্যন্ত গুরুত্বপূর্ণ।
Orders
   ↓
Customer Master
   ↓
Matching Customer আছে?
   ↓
NO
   ↓
Data Quality Issue








9. RIGHT ANTI JOIN — LEFT JOIN Alternative
/* ================================================================
   RIGHT ANTI JOIN-এর LEFT JOIN alternative
================================================================ */

SELECT
    o.OrderID,
    o.CustomerID,
    o.Sales
FROM Orders AS o
LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

এটি সাধারণত বেশি readable।







10. LEFT JOIN দিয়ে INNER JOIN-এর Alternative
/* ================================================================
   INNER JOIN-এর LEFT JOIN alternative

   Matching records রাখছি
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.Sales
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NOT NULL;


এখানে:
LEFT JOIN
   ↓
সব Customer
   ↓
WHERE matched Order
   ↓
শুধু matched rows
ফলে INNER JOIN-এর মতো result পাওয়া যায়।
⚠️ Best Practice
সাধারণ matching data-এর জন্য সরাসরি:
INNER JOIN
ব্যবহার করাই পরিষ্কার।







11. FULL ANTI JOIN
এটি খুব গুরুত্বপূর্ণ Data Quality pattern।
উদ্দেশ্য
Customer without Order
        OR
Order without Customer
/* ================================================================
   FULL ANTI JOIN

   দুই পাশের unmatched records খুঁজে বের করা
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
FULL JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL
   OR c.CustomerID IS NULL;


এখানে আমরা পাব:
Customer 107 → No Order

Order 5010 → Customer 999 does not exist
🎯 Real Data Engineering
ETL pipeline-এ:
Source Customer
       ↓
Source Orders
       ↓
FULL JOIN
       ↓
Data Quality Check
       ↓
Unmatched Records






12. CROSS JOIN
CROSS JOIN কোনো matching condition ব্যবহার করে না।
/* ================================================================
   CROSS JOIN

   প্রত্যেক customer-এর সাথে প্রত্যেক order-এর combination
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.Sales
FROM Customers AS c
CROSS JOIN Orders AS o;


আমাদের:
7 Customers
×
10 Orders
=
70 Rows
🎯 Real Business Use
CROSS JOIN ব্যবহার করা যায়:
Scenario generation
Date × Product matrix
Customer × Product analysis
Sales target planning
⚠️ Common Mistake
  
SELECT *
FROM Customers
CROSS JOIN Orders;

বড় table হলে:
1,000,000 Customers
×
10,000,000 Orders
অত্যন্ত বিশাল result তৈরি হতে পারে।
তাই CROSS JOIN খুব সতর্কভাবে ব্যবহার করতে হবে।










13. Multiple Table JOIN — 4 Tables
এখন সবচেয়ে গুরুত্বপূর্ণ real-world query।
আমরা:
Orders
   ↓
Customers
   ↓
Products
   ↓
Employees
join করব।
/* ================================================================
   MULTIPLE TABLE JOIN

   Business Question:
   প্রতিটি order-এর জন্য customer,
   product এবং salesperson-এর information দেখাও।
================================================================ */

SELECT
    o.OrderID,
    o.OrderDate,

    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,

    p.ProductID,
    p.ProductName,
    p.Price,

    o.Quantity,
    o.Sales,

    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPersonName

FROM Orders AS o

LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Employees AS e
    ON o.SalesPersonID = e.EmployeeID;


🎯 Business Output
একটি order এখন এমন meaningful information হবে:
Order
  ↓
Customer
  ↓
Product
  ↓
Salesperson
অর্থাৎ raw transaction:
  
5001 | 101 | 201 | 301 | 750
  
এর পরিবর্তে:
Order 5001
Ahmed Hassan
Laptop
John Smith
$750







14. 5 Tables JOIN
আমাদের ৭টি table তৈরি করা হয়েছে। এখন সেই relational structure ব্যবহার করি।
Orders
   ↓
Customers
   ↓
Countries

Orders
   ↓
Products
   ↓
Categories

Orders
   ↓
Employees
   ↓
Departments
এক query-তে সবগুলো আনা যায়।
/* ================================================================
   MULTI-TABLE BUSINESS REPORT

   Orders
   + Customers
   + Countries
   + Products
   + Categories
   + Employees
   + Departments
================================================================ */

SELECT
    o.OrderID,
    o.OrderDate,

    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    co.CountryName,

    p.ProductName,
    ca.CategoryName,
    p.Price,

    o.Quantity,
    o.Sales,

    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPersonName,
    d.DepartmentName

FROM Orders AS o

LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN Countries AS co
    ON c.CountryID = co.CountryID

LEFT JOIN Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Categories AS ca
    ON p.CategoryID = ca.CategoryID

LEFT JOIN Employees AS e
    ON o.SalesPersonID = e.EmployeeID

LEFT JOIN Departments AS d
    ON e.DepartmentID = d.DepartmentID;


এটাই বাস্তব-world relational SQL-এর একটি গুরুত্বপূর্ণ pattern।






15. JOIN + WHERE
JOIN করে তারপর business filter করা যায়।
/* ================================================================
   Business Question:
   $500-এর বেশি sales-এর orders দেখাও
================================================================ */

SELECT
    o.OrderID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    p.ProductName,
    o.Sales
FROM Orders AS o

INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID

INNER JOIN Products AS p
    ON o.ProductID = p.ProductID

WHERE o.Sales > 500;








16. JOIN + GROUP BY
এখন customer-wise total sales।
/* ================================================================
   Business Question:
   প্রত্যেক customer কত sales করেছে?
================================================================ */

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    SUM(o.Sales) AS TotalSales
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName;






17. JOIN + GROUP BY + HAVING
/* ================================================================
   Business Question:
   যেসব customer $500-এর বেশি sales করেছে
================================================================ */

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    SUM(o.Sales) AS TotalSales
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
HAVING SUM(o.Sales) > 500;


এখানে গুরুত্বপূর্ণ:
WHERE
 ↓
Individual Rows filter

GROUP BY
 ↓
Groups তৈরি

HAVING
 ↓
Groups filter








18. JOIN + ORDER BY
/* ================================================================
   Customer-wise Sales Ranking
================================================================ */

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    SUM(o.Sales) AS TotalSales
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY
    TotalSales DESC;








19. JOIN + COUNT
Customer কতটি order করেছে?
/* ================================================================
   Number of Orders per Customer
================================================================ */

SELECT
    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    COUNT(o.OrderID) AS NumberOfOrders
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
GROUP BY
    c.CustomerID,
    c.FirstName,
    c.LastName
ORDER BY
    NumberOfOrders DESC;


এখানে LEFT JOIN গুরুত্বপূর্ণ।
কারণ আমরা order না করা customer-ও দেখতে চাই।









20. JOIN + NULL Data Quality Check
/* ================================================================
   DATA QUALITY CHECK

   Orders-এর customer master-এ matching customer আছে কিনা
================================================================ */

SELECT
    o.OrderID,
    o.CustomerID,
    o.Sales
FROM Orders AS o
LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;


Result:
5010 | 999 | 750
এটা Data Engineering-এ একটি referential integrity issue।







21. Product-এর কোনগুলো বিক্রি হয়নি?
/* ================================================================
   DATA QUALITY / PRODUCT ANALYSIS

   যেসব product-এর কোনো order নেই
================================================================ */

SELECT
    p.ProductID,
    p.ProductName,
    p.Price
FROM Products AS p
LEFT JOIN Orders AS o
    ON p.ProductID = o.ProductID
WHERE o.ProductID IS NULL;


Result:
ProductID = 205
Printer
🎯 Business Meaning
Printer inventory-তে আছে কিন্তু এখনো বিক্রি হয়নি।
এটি inventory/sales analysis-এ useful।








22. Employee-এর Sales Performance
/* ================================================================
   Salesperson-wise Sales
================================================================ */

SELECT
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPersonName,
    SUM(o.Sales) AS TotalSales
FROM Employees AS e
LEFT JOIN Orders AS o
    ON e.EmployeeID = o.SalesPersonID
GROUP BY
    e.EmployeeID,
    e.FirstName,
    e.LastName
ORDER BY
    TotalSales DESC;









23. Category-wise Sales
এখানে 3-table JOIN:
Orders
 ↓
Products
 ↓
Categories
/* ================================================================
   CATEGORY-WISE SALES
================================================================ */

SELECT
    ca.CategoryID,
    ca.CategoryName,
    SUM(o.Sales) AS TotalSales
FROM Orders AS o
INNER JOIN Products AS p
    ON o.ProductID = p.ProductID
INNER JOIN Categories AS ca
    ON p.CategoryID = ca.CategoryID
GROUP BY
    ca.CategoryID,
    ca.CategoryName
ORDER BY
    TotalSales DESC;







24. Country-wise Sales
/* ================================================================
   COUNTRY-WISE SALES
================================================================ */

SELECT
    co.CountryName,
    SUM(o.Sales) AS TotalSales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
INNER JOIN Countries AS co
    ON c.CountryID = co.CountryID
GROUP BY
    co.CountryName
ORDER BY
    TotalSales DESC;







25. কোন JOIN কখন ব্যবহার করবেন?
JOIN	             কাজ	                           Real Business Use
INNER JOIN	       Matching data	                 Customer + Orders
LEFT JOIN	         Left-এর সব data	               All Customers + Orders
RIGHT JOIN	       Right-এর সব data	             All Orders + Customers
FULL JOIN	         দুই পাশের সব                    data	Data reconciliation
LEFT ANTI	         Left-এর unmatched	             Customers without orders
RIGHT ANTI	       Right-এর unmatched	             Orders without customers
FULL ANTI	         দুই পাশের unmatched	             Data quality
CROSS JOIN	       Every combination	             Scenario/matrix
Multiple JOIN	     Multiple tables combine	       Business reporting







26. সবচেয়ে গুরুত্বপূর্ণ Best Practices ⭐
✅ 1. Always use table aliases
FROM Orders AS o
LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID
o, c, p, e query readable করে।


✅ 2. JOIN condition পরিষ্কার রাখুন
ON o.CustomerID = c.CustomerID
অপ্রয়োজনীয় condition দিয়ে JOIN করবেন না।


✅ 3. SELECT * production query-তে avoid করুন
❌
SELECT *
FROM Orders AS o
JOIN Customers AS c
    ON o.CustomerID = c.CustomerID;
✅
SELECT
    o.OrderID,
    o.OrderDate,
    c.CustomerID,
    c.FirstName,
    o.Sales
FROM Orders AS o
INNER JOIN Customers AS c
    ON o.CustomerID = c.CustomerID;




✅ 4. Data Quality-এর জন্য Anti JOIN অত্যন্ত গুরুত্বপূর্ণ
LEFT ANTI JOIN
      ↓
Missing Master Data

RIGHT ANTI JOIN
      ↓
Invalid Transaction

FULL ANTI JOIN
      ↓
Reconciliation




✅ 5. RIGHT JOIN-এর বদলে LEFT JOIN অনেক সময় সহজ
-- RIGHT JOIN
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
এর পরিবর্তে:
-- LEFT JOIN
FROM Orders AS o
LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID




27. Data Analyst + Data Engineer-এর জন্য JOIN-এর আসল ব্যবহার
                 SQL JOIN
                    │
       ┌────────────┼────────────┐
       ↓            ↓            ↓
   Reporting    Analysis     Data Quality
       │            │            │
       ↓            ↓            ↓
 Customer       Sales         Anti JOIN
 Product        Revenue       Reconciliation
 Employee       Ranking       Missing Data
 Country        Category      Orphan Records







More Practice
1️⃣ INNER JOIN — Matching Data
🎯 কাজ
শুধু যেসব Customer-এর Order আছে, তাদের দেখাবে।
/* ================================================================
   INNER JOIN
   Customer + Orders
   শুধু matching data দেখাবে
================================================================ */

SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.Sales
FROM Customers AS c
INNER JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;

সহজভাবে
Customers        Orders
   101     ←→      101   ✅
   102     ←→      102   ✅
   103     ←→      103   ✅
   107             নেই   ❌

   
CustomerID = 107 দেখাবে না।
কারণ তার কোনো Order নেই।
💼 Business Example
"যেসব customer purchase করেছে তাদের sales দেখাও।"




2️⃣ LEFT JOIN — Left-এর সব Data
🎯 কাজ
Customers-এর সবাইকে দেখাবে।
Order থাকলে Order information দেখাবে।
Order না থাকলে NULL দেখাবে।
/* ================================================================
   LEFT JOIN
   সব Customer দেখাবে
   Order থাকলে Order দেখাবে
   Order না থাকলে NULL
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.Sales
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


এখানে গুরুত্বপূর্ণ
Customer 101 → Order আছে → Sales আছে
Customer 102 → Order আছে → Sales আছে
Customer 107 → Order নেই  → NULL
💼 Business Example
"আমাদের সব customer দেখাও এবং তারা purchase করেছে কিনা দেখাও।"

এটি customer analysis-এ খুব common।






3️⃣ RIGHT JOIN — Right-এর সব Data
🎯 কাজ
Orders-এর সব record দেখাবে।
Customer matching থাকলে customer information দেখাবে।
/* ================================================================
   RIGHT JOIN
   সব Order দেখাবে
   Customer না থাকলেও Order দেখাবে
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


আমাদের data-তে:
Order 5001 → Customer 101 → Match ✅

Order 5010 → Customer 999 → No Match ❌
   
তাই 5010 থাকবে।
কিন্তু Customer information হবে:
   
CustomerID = NULL
FirstName  = NULL
LastName   = NULL
💼 Business Example
"আমাদের সব order দেখাও, এমনকি customer master-এ customer না থাকলেও।"

এটি Data Quality check-এর জন্য useful।






4️⃣ FULL JOIN — দুই পাশের সব Data
🎯 কাজ
Customers-এর সব data + Orders-এর সব data।
/* ================================================================
   FULL JOIN
   Customer-এর সব record
   +
   Order-এর সব record

   Matching হলে একসাথে
   Matching না হলে NULL
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
FULL JOIN Orders AS o
    ON c.CustomerID = o.CustomerID;


এখানে:
Customer 101 + Order 5001 → Match

Customer 107 + NULL       → Customer-এর Order নেই

NULL + Order 5010         → Order-এর Customer নেই
💼 Business Example
"Customer master এবং Orders-এর মধ্যে কোন data missing বা unmatched আছে?"

এটি Data Reconciliation-এ খুব useful।






5️⃣ LEFT ANTI JOIN — Left-এর Unmatched
SQL Server-এ LEFT ANTI JOIN নামে আলাদা keyword নেই।
আমরা:
LEFT JOIN
+
WHERE RightTable.Key IS NULL
ব্যবহার করি।
🎯 Customer যাদের কোনো Order নেই
/* ================================================================
   LEFT ANTI JOIN
   যেসব Customer কোনো Order করেনি
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    c.LastName
FROM Customers AS c
LEFT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE o.CustomerID IS NULL;


Result
107 | Nadia | Islam
কারণ Nadia-এর কোনো order নেই।
   
💼 Business Example
"কোন customer এখনো purchase করেনি?"
এটা customer activation / marketing analysis-এ useful।






6️⃣ RIGHT ANTI JOIN — Right-এর Unmatched
এবার খুঁজব:
কোন Order-এর Customer master-এ customer নেই?

/* ================================================================
   RIGHT ANTI JOIN
   যেসব Order-এর matching Customer নেই
================================================================ */
SELECT
    o.OrderID,
    o.CustomerID,
    o.Sales
FROM Customers AS c
RIGHT JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL;


Result
5010 | 999 | 750.00
কারণ:
Orders.CustomerID = 999
             ↓
Customers.CustomerID = 999 নেই
💼 Data Engineering Example
এটি একটি orphan transaction।
Order
  ↓
Customer Master
  ↓
Match নেই
  ↓
Data Quality Issue ⚠️







7️⃣ FULL ANTI JOIN — দুই পাশের Unmatched
🎯 কাজ
দুই পাশের unmatched data খুঁজব:
Customer without Order
        +
Order without Customer
/* ================================================================
   FULL ANTI JOIN
   দুই পাশের unmatched records
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    o.OrderID,
    o.CustomerID AS OrderCustomerID,
    o.Sales
FROM Customers AS c
FULL JOIN Orders AS o
    ON c.CustomerID = o.CustomerID
WHERE c.CustomerID IS NULL
   OR o.CustomerID IS NULL;


এখানে পাব:
Customer 107 → কোনো Order নেই

Order 5010 → Customer 999 নেই
💼 Business Example
"Customer master এবং transaction table-এর সব mismatch বের করো।"

এটি ETL/Data Warehouse validation-এ খুব useful।






8️⃣ CROSS JOIN — Every Combination
🎯 কাজ
প্রত্যেক Customer-এর সাথে প্রত্যেক Product-এর combination তৈরি করবে।
এখানে Orders ব্যবহার না করে Customers + Products ব্যবহার করলে business example আরও পরিষ্কার।
/* ================================================================
   CROSS JOIN
   প্রত্যেক Customer-এর সাথে প্রত্যেক Product-এর combination
================================================================ */
SELECT
    c.CustomerID,
    c.FirstName,
    p.ProductID,
    p.ProductName,
    p.Price
FROM Customers AS c
CROSS JOIN Products AS p;


আমাদের data:
7 Customers
×
6 Products
=
42 Rows
💼 Business Example
ধরুন:
"প্রত্যেক customer-কে প্রত্যেক product-এর জন্য sales offer তৈরি করতে হবে।"

তাহলে:
Customer
   +
Product
   ↓
Possible Combination
⚠️ সাবধান
CROSS JOIN খুব দ্রুত huge dataset তৈরি করতে পারে।






9️⃣ Multiple JOIN — Multiple Tables Combine
এখন আসল Business Reporting।
একটি Order-এর সাথে:
Orders
  ↓
Customers
  ↓
Products
  ↓
Employees
সব combine করব।
/* ================================================================
   MULTIPLE JOIN
   Orders + Customers + Products + Employees

   Business Question:
   প্রতিটি Order কে করেছে,
   কোন Customer করেছে,
   কোন Product কিনেছে,
   এবং কোন Salesperson sale করেছে?
================================================================ */
SELECT
    o.OrderID,
    o.OrderDate,

    c.CustomerID,
    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,

    p.ProductID,
    p.ProductName,
    p.Price,

    o.Quantity,
    o.Sales,

    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPersonName

FROM Orders AS o

LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Employees AS e
    ON o.SalesPersonID = e.EmployeeID;



🧠 এখানে কী হচ্ছে?
                 Customers
                     ↑
                     │
Orders ──────────────┼──────── Products
  │                  │
  │                  │
  └────────────── Employees
   
একটি Order থেকে আমরা পাচ্ছি:
Order ID
Customer
Product
Quantity
Sales
Salesperson
💼 Real Business Question
"কোন customer কোন product কিনেছে, কত quantity কিনেছে, 
কত sales হয়েছে এবং কোন salesperson sale করেছে?"

এটাই বাস্তব-world business reporting query।






🔟 আরও Real — 7 Tables একসাথে
এবার আমাদের তৈরি করা সব related tables ব্যবহার করি।
/* ================================================================
   COMPLETE BUSINESS REPORT
   Orders
   + Customers
   + Countries
   + Products
   + Categories
   + Employees
   + Departments
================================================================ */
SELECT
    o.OrderID,
    o.OrderDate,

    CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
    co.CountryName,

    p.ProductName,
    ca.CategoryName,
    p.Price,

    o.Quantity,
    o.Sales,

    CONCAT(e.FirstName, ' ', e.LastName) AS SalesPersonName,
    d.DepartmentName

FROM Orders AS o

LEFT JOIN Customers AS c
    ON o.CustomerID = c.CustomerID

LEFT JOIN Countries AS co
    ON c.CountryID = co.CountryID

LEFT JOIN Products AS p
    ON o.ProductID = p.ProductID

LEFT JOIN Categories AS ca
    ON p.CategoryID = ca.CategoryID

LEFT JOIN Employees AS e
    ON o.SalesPersonID = e.EmployeeID

LEFT JOIN Departments AS d
    ON e.DepartmentID = d.DepartmentID;


এখন একটি raw order:
5001 | 101 | 201 | 301 | 750
   
এর business meaning বের হয়ে যাবে:
Order 5001
   ↓
Ahmed Hassan
   ↓
Kuwait
   ↓
Laptop
   ↓
Electronics
   ↓
Quantity = 1
   ↓
Sales = 750
   ↓
John Smith
   ↓
Sales Department






🧠 JOIN মনে রাখার সবচেয়ে সহজ Formula
INNER JOIN
↓
শুধু Match

LEFT JOIN
↓
Left-এর সব

RIGHT JOIN
↓
Right-এর সব

FULL JOIN
↓
দুই পাশের সব

LEFT ANTI
↓
Left আছে
Right নেই

RIGHT ANTI
↓
Right আছে
Left নেই

FULL ANTI
↓
দুই পাশের যেগুলোর Match নেই

CROSS JOIN
↓
সব Possible Combination

MULTIPLE JOIN
↓
অনেক Table → একটি Business Result




-- Tables Joins best Roadmap

🏆 সর্বপ্রধান টেবিল: Orders Table
আপনার এনালিটিক্স ও রিপোর্টিংয়ের কেন্দ্রবিন্দু হবে Orders টেবিল।

🎯 কারণ: ব্যবসার সব আয়, বিক্রয়ের পরিমাণ এবং ট্রানজেকশন এই টেবিলে জমা হয়।

🔑 কাজ: এই একটি টেবিলের সাথে বাকি সব টেবিলকে JOIN করে ব্যবসার সম্পূর্ণ চিত্র বের করা যায়।

🔗 অর্ডারের সাথে রিলেশনশিপের সঠিক ক্রমানুসার (Step-by-Step)
রিপোর্ট তৈরির সময় Orders টেবিলকে সেন্টারে রেখে নিচের ধারাবাহিকতায় রিলেশনশিপ (JOIN) স্থাপন করা সবচেয়ে যুক্তিযুক্ত:

১. Orders ➔ Products (প্রথম এবং সবচেয়ে গুরুত্বপূর্ণ রিলেশন)
💡 কেন আগে? ব্যবসা বা রেস্টুরেন্টে কোনো কাস্টমার অর্ডার করার সময় সর্বাগ্রে নির্ধারণ করা হয় সে কী কিনছে বা কী খাচ্ছে।

🔗 কীভাবে যুক্ত করবেন: Orders.product_id = Products.product_id

📈 উপকারিতা: কত পিস বিক্রি হলো, মোট সেলস অ্যামাউন্ট এবং সবচেয়ে বেশি বিক্রি হওয়া আইটেম বের করা যায়।

২. Products ➔ Categories
💡 কেন? প্রোডাক্টের সাথে ক্যাটালগ যোগ করতে হবে যেন বোঝা যায় প্রোডাক্টটি কোনো নির্দিষ্ট ক্যাটাগরির (যেমন: Food, Beverage, Electronics)।

🔗 কীভাবে যুক্ত করবেন: Products.category_id = Categories.category_id

📈 উপকারিতা: কোন ক্যাটাগরি থেকে সবচেয়ে বেশি লাভ আসছে তা বিশ্লেষণ করা যায়।

৩. Orders ➔ Customers
💡 কেন? সেলস নিশ্চিত হওয়ার পর জানা প্রয়োজন কে অর্ডারটি করেছে।

🔗 কীভাবে যুক্ত করবেন: Orders.customer_id = Customers.customer_id

📈 উপকারিতা: কাস্টমার রিটার্ন রেট, VIP কাস্টমার সনাক্তকরণ এবং LTV (Lifetime Value) ট্র্যাক করা যায়।

৪. Customers ➔ Countries
💡 কেন? কাস্টমারের ভৌগোলিক অবস্থান বের করার জন্য কাস্টমার টেবিলের সাথে কান্ট্রি যুক্ত করা হয়।

🔗 কীভাবে যুক্ত করবেন: Customers.country_id = Countries.country_id

📈 উপকারিতা: অঞ্চলভিত্তিক সেলস বা ভৌগোলিক চাহিদা অ্যানালিসিস করা সহজ হয়।

৫. Orders ➔ Employees
💡 কেন? অর্ডারটি কোন সেলস পার্সন বা ওয়েটার সম্পন্ন করেছে তা জানা ট্র্যাকিংয়ের জন্য দরকার।

🔗 কীভাবে যুক্ত করবেন: Orders.employee_id = Employees.employee_id

📈 উপকারিতা: কর্মীদের পারফরম্যান্স, কমিশন এবং কাজের দক্ষতা পরিমাপ করা যায়।

৬. Employees ➔ Departments
💡 কেন? কর্মীটি কোন ডিপার্টমেন্টের (যেমন: Sales, Delivery, Kitchen) অধীনে কাজ করে তা স্পষ্ট করার জন্য।

🔗 কীভাবে যুক্ত করবেন: Employees.department_id = Departments.department_id

📈 উপকারিতা: ডিপার্টমেন্ট অনুসারে স্টাফের খরচ ও অবদান মূল্যায়ন করা সম্ভব হয়।

