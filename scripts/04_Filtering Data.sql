SQL Filtering Data
এখন মূল বিষয় শুরু।
Filtering-এর মূল structure:
SELECT
    ↓
FROM
    ↓
WHERE
    ↓
Condition
    ↓
Filtered Rows

SELECT *
FROM Customers
WHERE Country = 'Germany';
SQL Server প্রথমে Customers table-এর rows দেখে এবং যেসব row-এর Country = Germany, শুধুমাত্র সেগুলো return করে।


10. Comparison Operators
Comparison operators:
Operator	          Meaning
=	                  Equal
<>	                Not Equal
>	                  Greater Than
>=	                Greater Than or Equal
<	                  Less Than
<=	                Less Than or Equal



= Equal
🎯 Business Question
Germany-এর customers খুঁজে বের করুন।

/* ============================================================
   = EQUAL
   Germany-এর customers
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'Germany';


<> Not Equal
🎯 Business Question
Germany ছাড়া অন্য দেশের customers খুঁজুন।

/* ============================================================
   <> NOT EQUAL
   Germany ছাড়া অন্য দেশের customers
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country <> 'Germany';



> Greater Than
🎯 Business Question
যেসব customer-এর score 500-এর বেশি তাদের খুঁজুন।
/* ============================================================
   > GREATER THAN
   Score 500-এর বেশি
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score > 500;
এখানে 500 নিজে included হবে না।



  
>= Greater Than or Equal
🎯 Business Question
যেসব customer-এর score 500 বা তার বেশি।
/* ============================================================
   >= GREATER THAN OR EQUAL
   Score 500 বা তার বেশি
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score >= 500;





< Less Than
🎯 Business Question
যেসব customer-এর score 500-এর কম।
/* ============================================================
   < LESS THAN
   Score 500-এর কম
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score < 500;




<= Less Than or Equal
🎯 Business Question
Score 500 বা তার কম।
/* ============================================================
   <= LESS THAN OR EQUAL
   Score 500 বা তার কম
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score <= 500;





Logical Operator — AND
AND ব্যবহার করলে সব condition TRUE হতে হবে।
Condition 1 = TRUE
AND
Condition 2 = TRUE
        ↓
      TRUE
🎯 Business Question
USA-এর customers যাদের score 500-এর বেশি।
/* ============================================================
   AND
   USA + Score > 500
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'USA'
  AND Score > 500;

এখানে দুইটি condition-ই সত্য হতে হবে:






Logical Operator — OR
OR ব্যবহার করলে যেকোনো একটি condition TRUE হলেই row return করবে।
🎯 Business Question
USA-এর customer অথবা যাদের score 500-এর বেশি।
/* ============================================================
   OR
   USA অথবা Score > 500
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'USA'
   OR Score > 500;





Logical Operator — NOT
NOT condition-এর বিপরীত result দেয়।
🎯 Business Question
যাদের score 500-এর কম নয়।
অর্থাৎ:
NOT Score < 500
মানে:
Score >= 500
/* ============================================================
   NOT
   Score 500-এর কম নয়
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE NOT Score < 500;



একই logic:
/* ============================================================
   NOT এর equivalent condition
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score >= 500;





BETWEEN
BETWEEN নির্দিষ্ট range-এর data filter করে।
🎯 Business Question
Score 100 থেকে 500-এর মধ্যে এমন customers খুঁজুন।
/* ============================================================
   BETWEEN
   Score 100 থেকে 500
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score BETWEEN 100 AND 500;

⚠️ গুরুত্বপূর্ণ
SQL Server-এ:
BETWEEN 100 AND 500

  
মানে:
100 <= Score <= 500
অর্থাৎ 100 এবং 500 দুটোই included।






BETWEEN ছাড়া একই Query
/* ============================================================
   BETWEEN-এর equivalent
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score >= 100
  AND Score <= 500;
দুইটি query একই result দেবে।






Real Business Example — Product Price
Filtering শুধু Customer-এর জন্য নয়।
🎯 Business Question
যেসব product-এর price 20 থেকে 100-এর মধ্যে।
/* ============================================================
   REAL BUSINESS EXAMPLE
   Product price 20 থেকে 100
   ============================================================ */

SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM Products
WHERE Price BETWEEN 20 AND 100;
এটি Data Analyst-এর জন্য খুব common:
Price Range Analysis
Product Segmentation
Sales Analysis
Inventory Analysis






IN
IN একাধিক নির্দিষ্ট value-এর মধ্যে match করার জন্য ব্যবহৃত হয়।
🎯 Business Question
Germany অথবা USA-এর customers।

/* ============================================================
   IN
   Germany অথবা USA
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country IN ('Germany', 'USA');







IN ছাড়া একই Query
/* ============================================================
   IN-এর equivalent
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'Germany'
   OR Country = 'USA';
দুই query-এর result একই।








Real Business Example — Product Category
🎯 Business Question
Electronics অথবা Furniture category-এর products।
/* ============================================================
   IN - PRODUCT CATEGORY
   ============================================================ */

SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM Products
WHERE Category IN
(
    'Electronics',
    'Furniture'
);





LIKE
LIKE ব্যবহার করা হয় pattern matching করার জন্য।
এখানে সবচেয়ে গুরুত্বপূর্ণ wildcard:
%  = Zero or more characters

_  = Exactly one character




LIKE 'M%'
🎯 Business Question
FirstName M দিয়ে শুরু এমন customers।
/* ============================================================
   LIKE
   M দিয়ে শুরু
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE 'M%';
% মানে M-এর পরে যেকোনো সংখ্যক character থাকতে পারে।






LIKE '%n'
🎯 Business Question
যাদের FirstName n দিয়ে শেষ।
/* ============================================================
   LIKE
   n দিয়ে শেষ
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '%n';







LIKE '%r%'
🎯 Business Question
FirstName-এর যেকোনো জায়গায় r আছে।
/* ============================================================
   LIKE
   যেকোনো জায়গায় r আছে
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '%r%';







LIKE '__r%'
এখানে:
_ = ১টি character

_ = ১টি character

r = তৃতীয় character

% = এরপর যেকোনো character







🎯 Business Question
FirstName-এর ৩ নম্বর position-এ r আছে।
/* ============================================================
   LIKE
   Third position = r
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '__r%';









Real Business Example — Product Search
ধরুন Business Team বলল:
"যেসব product name-এ Mouse আছে সেগুলো দেখাও।"

/* ============================================================
   REAL PRODUCT SEARCH
   Product name-এর মধ্যে Mouse
   ============================================================ */

SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM Products
WHERE ProductName LIKE '%Mouse%';







Real Business Example — Employee Filtering
Data Analyst হিসেবে employee data-ও filter করতে হবে।
🎯 Business Question
Data Engineering department-এর employees যাদের salary 70,000-এর বেশি।
/* ============================================================
   REAL BUSINESS FILTER
   Salary > 70000
   DepartmentID = 2
   ============================================================ */

SELECT
    EmployeeID,
    FirstName,
    LastName,
    DepartmentID,
    JobTitle,
    Salary
FROM Employees
WHERE DepartmentID = 2
  AND Salary > 70000;
এখানে একই filtering concept অন্য table-এও কাজ করছে।








Real Business Example — Orders
🎯 Business Question
Completed orders খুঁজুন।
/* ============================================================
   ORDER FILTER
   Completed orders
   ============================================================ */

SELECT
    OrderID,
    CustomerID,
    EmployeeID,
    OrderDate,
    OrderStatus
FROM Orders
WHERE OrderStatus = 'Completed';









Multiple Filtering একসাথে
বাস্তব কাজে সাধারণত একটি condition নয়, একাধিক condition থাকে।
🎯 Business Question
USA customer + Score 500-এর বেশি + CustomerID 1001-এর পরে

/* ============================================================
   MULTIPLE FILTERING
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'USA'
  AND Score > 500
  AND CustomerID > 1001;









AND + OR
এখানে একটু সতর্ক থাকতে হবে।
🎯 Business Question
USA-এর customer যাদের score 500-এর বেশি, অথবা Germany-এর customer যাদের score 500-এর বেশি।

Best practice:
/* ============================================================
   AND + OR
   Parentheses ব্যবহার করে logic পরিষ্কার রাখা
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE
(
    Country = 'USA'
    AND Score > 500
)
OR
(
    Country = 'Germany'
    AND Score > 500
);







একই Logic আরও পরিষ্কারভাবে
এই business rule-এর জন্য IN ব্যবহার করলে query আরও সহজ:
/* ============================================================
   একই Business Rule
   IN + AND
   ============================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country IN ('USA', 'Germany')
  AND Score > 500;
এটি production SQL-এ অনেক বেশি readable।









সব Filtering Operator — একসাথে
/* ============================================================
   SQL SERVER FILTERING CHEAT SHEET
   ============================================================ */

-- Equal
SELECT *
FROM Customers
WHERE Country = 'Germany';


-- Not Equal
SELECT *
FROM Customers
WHERE Country <> 'Germany';


-- Greater Than
SELECT *
FROM Customers
WHERE Score > 500;


-- Greater Than or Equal
SELECT *
FROM Customers
WHERE Score >= 500;


-- Less Than
SELECT *
FROM Customers
WHERE Score < 500;


-- Less Than or Equal
SELECT *
FROM Customers
WHERE Score <= 500;


-- AND
SELECT *
FROM Customers
WHERE Country = 'USA'
  AND Score > 500;


-- OR
SELECT *
FROM Customers
WHERE Country = 'USA'
   OR Score > 500;


-- NOT
SELECT *
FROM Customers
WHERE NOT Score < 500;


-- BETWEEN
SELECT *
FROM Customers
WHERE Score BETWEEN 100 AND 500;


-- IN
SELECT *
FROM Customers
WHERE Country IN ('Germany', 'USA');


-- LIKE - Starts With
SELECT *
FROM Customers
WHERE FirstName LIKE 'M%';


-- LIKE - Ends With
SELECT *
FROM Customers
WHERE FirstName LIKE '%n';


-- LIKE - Contains
SELECT *
FROM Customers
WHERE FirstName LIKE '%r%';


-- LIKE - Third Character
SELECT *
FROM Customers
WHERE FirstName LIKE '__r%';






Production Best Practice ⭐
/* ============================================================
   BEST PRACTICES
   ============================================================ */

-- 1. প্রয়োজনীয় column নির্বাচন করুন
-- SELECT * production reporting-এ avoid করুন

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'Germany';


-- 2. Multiple condition হলে indentation ব্যবহার করুন

SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country IN ('USA', 'Germany')
  AND Score >= 500;


-- 3. Range filtering-এর জন্য BETWEEN ব্যবহার করুন

SELECT
    CustomerID,
    FirstName,
    Score
FROM Customers
WHERE Score BETWEEN 500 AND 800;


-- 4. Multiple exact values হলে IN ব্যবহার করুন

SELECT
    CustomerID,
    FirstName,
    Country
FROM Customers
WHERE Country IN ('USA', 'Germany', 'Canada');


-- 5. AND + OR থাকলে parentheses ব্যবহার করুন

SELECT
    CustomerID,
    FirstName,
    Country,
    Score
FROM Customers
WHERE
(
    Country = 'USA'
    AND Score > 500
)
OR
(
    Country = 'Germany'
    AND Score > 500
);








Data Analyst + Data Engineer হিসেবে কোথায় ব্যবহার করবেন?
Filtering	Real Business Use
=	নির্দিষ্ট country/status/category
<>	নির্দিষ্ট value বাদ দেওয়া
>	High-value customers
>=	Minimum threshold
<	Low-value products
<=	Maximum threshold
AND	Multiple business conditions
OR	Alternative business conditions
NOT	Exclusion logic
BETWEEN	Date/price/score range
IN	Multiple category/country/status
LIKE	Customer/product search










