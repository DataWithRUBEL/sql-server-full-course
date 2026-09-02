1. Data Verify
প্রথমে data ঠিকমতো তৈরি হয়েছে কিনা দেখি।
    
/* ============================================================
   VERIFY TABLE DATA
   ============================================================ */
SELECT * FROM Customers;

SELECT * FROM Products;

SELECT * FROM Departments;

SELECT * FROM Employees;

SELECT * FROM Orders;

SELECT * FROM OrderDetails;

SELECT * FROM Payments;







2. SQL Filtering Data
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

SQL Server প্রথমে Customers table-এর rows দেখে 
এবং যেসব row-এর Country = Germany, শুধুমাত্র সেগুলো return করে।







    
3. Comparison Operators
Comparison operators:
Operator	          Meaning
=	                  Equal
<>	                  Not Equal
>	                  Greater Than
>=	                  Greater Than or Equal
<	                  Less Than
<=	                  Less Than or Equal



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

Expected customers:
Sarah
Daniel
Martin





    


4. <> Not Equal
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







5. > Greater Than
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
501+






    
  
6. >= Greater Than or Equal
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

এখানে:
500
501
502
...
সব included হবে।







    
7. < Less Than
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








8. <= Less Than or Equal
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








9. Logical Operator — AND
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

Country = USA
        AND
Score > 500
    
ফলে Michael, Robert এবং Christopher-এর মতো qualifying customers আসবে।







    

10. Logical Operator — OR
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







11. Logical Operator — NOT
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









12. BETWEEN
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







    

13. BETWEEN ছাড়া একই Query
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






14. Real Business Example — Product Price
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






15. IN
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









16. IN ছাড়া একই Query
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








17. Real Business Example — Product Category
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





18. LIKE
LIKE ব্যবহার করা হয় pattern matching করার জন্য।
এখানে সবচেয়ে গুরুত্বপূর্ণ wildcard:
%  = Zero or more characters

_  = Exactly one character






    

19. LIKE 'M%'
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
যেমন:
Michael
Martin
Maria





    


20. LIKE '%n'
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









21. LIKE '%r%'
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







22. LIKE '__r%'
    
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


Pattern:
    
Position:
1     2     3     4+
_     _     r     %








23. Real Business Example — Product Search
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








24. Real Business Example — Employee Filtering
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








25. Real Business Example — Orders
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









26. Multiple Filtering একসাথে
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









27. AND + OR
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







28. একই Logic আরও পরিষ্কারভাবে
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









29. সব Filtering Operator — একসাথে
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






30. Production Best Practice ⭐
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






31. Data Analyst + Data Engineer হিসেবে কোথায় ব্যবহার করবেন?
Filtering	       Real Business Use
=	               নির্দিষ্ট country/status/category
<>	               নির্দিষ্ট value বাদ দেওয়া
>	               High-value customers
>=	               Minimum threshold
<	               Low-value products
<=	               Maximum threshold
AND	               Multiple business conditions
OR	               Alternative business conditions
NOT	               Exclusion logic
BETWEEN	           Date/price/score range
IN	               Multiple category/country/status
LIKE	           Customer/product search


সবচেয়ে গুরুত্বপূর্ণ Pattern
WHERE
   ↓
Comparison
   ↓
AND / OR / NOT
   ↓
BETWEEN / IN
   ↓
LIKE
   ↓
Business Filtering






    


More practice


SQL Server Filtering — কেন ব্যবহার করবো? 🎯
WHERE হলো SQL Server-এর data filtering engine। 
আমরা যখন হাজার/লাখ row-এর মধ্যে শুধু প্রয়োজনীয় data বের করতে চাই, 
তখন filtering ব্যবহার করি।
    
সহজভাবে:
Table-এর সব Data
       ↓
     WHERE
       ↓
Business Condition
       ↓
শুধু প্রয়োজনীয় Data
নিচে আমাদের আগের RetailAnalyticsDB database-এর data দিয়েই প্রতিটি operator দেখানো হলো।





    
1. = — নির্দিষ্ট Value খুঁজতে
🎯 কেন ব্যবহার করবো?
    
যখন একটি নির্দিষ্ট value-এর সাথে exact match করতে চাই।
💼 Real Business Use
নির্দিষ্ট Country
নির্দিষ্ট Order Status
নির্দিষ্ট Product Category
নির্দিষ্ট Customer
নির্দিষ্ট Employee
Example: Germany-এর Customers

/* ============================================================
   = EQUAL
   Germany-এর customers খুঁজছি
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country = 'Germany';



Example: Completed Orders
/* ============================================================
   = EQUAL
   শুধুমাত্র Completed orders
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    OrderStatus
FROM Orders
WHERE OrderStatus = 'Completed';

👉 মূল কথা: Exact match দরকার হলে =।






2. <> — নির্দিষ্ট Value বাদ দিতে
🎯 কেন ব্যবহার করবো?
যখন কোনো নির্দিষ্ট value বাদ দিয়ে বাকি data দেখতে চাই।
💼 Real Business Use
- Germany বাদ দিতে
- Cancelled orders বাদ দিতে
- একটি category বাদ দিতে
- একটি employee বাদ দিতে

    
Example
/* ============================================================
   <> NOT EQUAL
   Germany-এর customers বাদ দিচ্ছি
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Customers
WHERE Country <> 'Germany';


Order Example
/* ============================================================
   Cancelled orders বাদ দিচ্ছি
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    OrderStatus
FROM Orders
WHERE OrderStatus <> 'Cancelled';

👉 মূল কথা: কোনো value exclude করতে <>।





    


3. > — Threshold-এর উপরে Data
🎯 কেন ব্যবহার করবো?
যখন কোনো value একটি নির্দিষ্ট threshold-এর চেয়ে বেশি কিনা দেখতে চাই।
💼 Real Business Use
- High-value customers
- Expensive products
- High salary employees
- Large orders
- High sales transactions


Example: High-Score Customers
/* ============================================================
   > GREATER THAN
   Score 500-এর বেশি customers
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score > 500;


Product Example
/* ============================================================
   Price 100-এর বেশি products
   ============================================================ */
SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM Products
WHERE Price > 100;

👉 মূল কথা: > = Above threshold






    


4. >= — Minimum Threshold
🎯 কেন ব্যবহার করবো?
যখন একটি minimum acceptable value নির্ধারণ করতে চাই এবং threshold-টিও include করতে চাই।
💼 Real Business Use
ধরুন:
VIP Customer = Score 500 বা তার বেশি

তাহলে >= ব্যবহার করবো।
/* ============================================================
   >= GREATER THAN OR EQUAL
   VIP customers:
   Score 500 বা তার বেশি
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score >= 500;



Salary Example
/* ============================================================
   Salary 60000 বা তার বেশি employees
   ============================================================ */
SELECT
    EmployeeID,
    FirstName,
    LastName,
    JobTitle,
    Salary
FROM Employees
WHERE Salary >= 60000;

👉 মূল কথা: >= = Minimum threshold সহ।








5. < — Threshold-এর নিচের Data
🎯 কেন ব্যবহার করবো?
যখন কোনো value নির্দিষ্ট threshold-এর চেয়ে কম এমন data খুঁজতে চাই।
💼 Real Business Use
- Low-score customers
- Low-price products
- Low-stock products
- Low-value orders

    
Example
/* ============================================================
   < LESS THAN
   Score 500-এর কম customers
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score < 500;



Stock Example
/* ============================================================
   Stock 100-এর কম products
   Inventory monitoring
   ============================================================ */
SELECT
    ProductID,
    ProductName,
    StockQuantity
FROM Products
WHERE StockQuantity < 100;

👉 মূল কথা: < = Below threshold




    


6. <= — Maximum Threshold
🎯 কেন ব্যবহার করবো?
যখন একটি maximum limit নির্ধারণ করতে চাই এবং সেই limit-টিও include করতে চাই।
💼 Real Business Use
যেমন:
Low-price product = Price 50 বা তার কম

/* ============================================================
   <= LESS THAN OR EQUAL
   Price 50 বা তার কম products
   ============================================================ */
SELECT
    ProductID,
    ProductName,
    Category,
    Price
FROM Products
WHERE Price <= 50;



Salary Example
/* ============================================================
   Salary 60000 বা তার কম employees
   ============================================================ */
SELECT
    EmployeeID,
    FirstName,
    JobTitle,
    Salary
FROM Employees
WHERE Salary <= 60000;

👉 মূল কথা: <= = Maximum threshold সহ।




    



7. AND — একাধিক Condition একসাথে
🎯 কেন ব্যবহার করবো?
যখন একটি row-কে qualify করতে একাধিক condition একই সাথে TRUE হতে হবে।
Condition 1 = TRUE
       AND
Condition 2 = TRUE
       ↓
     Result
💼 Real Business Use
    
ধরুন Business বললো:
USA-এর এমন customers চাই যাদের score 500-এর বেশি।

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


এখানে:
USA হতে হবে
     AND
Score > 500 হতে হব
    ে
দুটিই TRUE না হলে customer আসবে না।
    
👉 মূল কথা: AND = সব শর্ত পূরণ করতে হবে।






    


8. OR — Alternative Conditions
🎯 কেন ব্যবহার করবো?
যখন একাধিক alternative condition-এর যেকোনো একটি সত্য হলেই data দরকার।
💼 Real Business Use
ধরুন:
USA অথবা Germany-এর customers চাই।

/* ============================================================
   OR
   USA অথবা Germany
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Customers
WHERE Country = 'USA'
   OR Country = 'Germany';

এখানে:
USA
 OR
Germany
যেকোনো একটি match করলেই row আসবে।
    
👉 মূল কথা: OR = এইটা অথবা ওইটা।





    



9. NOT — Exclusion Logic
🎯 কেন ব্যবহার করবো?
যখন কোনো condition-এর বিপরীত data দরকার।
Example
Score 500-এর কম নয়।

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


এর equivalent:
/* ============================================================
   একই Logic
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score >= 500;


আরেকটি বাস্তব Example
/* ============================================================
   Cancelled orders বাদ দেওয়া
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    OrderStatus
FROM Orders
WHERE NOT OrderStatus = 'Cancelled';

👉 মূল কথা: NOT = condition-এর বিপরীত।





    


10. BETWEEN — Range Filtering
🎯 কেন ব্যবহার করবো?
যখন data একটি range-এর মধ্যে আছে কিনা দেখতে চাই।
বিশেষ করে:
- Date
- Price
- Score
- Salary
- Quantity

    
Example: Customer Score
/* ============================================================
   BETWEEN
   Score 300 থেকে 600-এর মধ্যে
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Score
FROM Customers
WHERE Score BETWEEN 300 AND 600;


BETWEEN inclusive:
300 <= Score <= 600
অর্থাৎ 300 এবং 600 দুটোই included।


Product Price
/* ============================================================
   Product price 50 থেকে 200
   ============================================================ */
SELECT
    ProductID,
    ProductName,
    Price
FROM Products
WHERE Price BETWEEN 50 AND 200;

👉 মূল কথা: BETWEEN = একটি range-এর মধ্যে data।






    


11. IN — Multiple Exact Values
🎯 কেন ব্যবহার করবো?
যখন একই column-এর জন্য অনেকগুলো নির্দিষ্ট value check করতে হবে।
❌ এভাবে লিখলে বড় হয়ে যায়

    
/* ============================================================
   OR দিয়ে multiple country
   ============================================================ */
SELECT *
FROM Customers
WHERE Country = 'USA'
   OR Country = 'Germany'
   OR Country = 'Canada';



✅ IN দিয়ে পরিষ্কার
/* ============================================================
   IN
   Multiple countries
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country
FROM Customers
WHERE Country IN
(
    'USA',
    'Germany',
    'Canada'
);



Product Category
/* ============================================================
   Multiple product categories
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

👉 মূল কথা: IN = একাধিক exact value-এর মধ্যে match।






    

12. LIKE — Pattern Search 🔎
🎯 কেন ব্যবহার করবো?
যখন exact value জানা নেই, কিন্তু কোনো pattern জানা আছে।
বিশেষ করে:
- Customer search
- Product search
- Employee search
- Name search
- Email search


    
M% — Starts With
/* ============================================================
   LIKE
   FirstName M দিয়ে শুরু
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE 'M%';


M%
↓
M দিয়ে শুরু
তারপর যেকোনো character
%n — Ends With
/* ============================================================
   LIKE
   FirstName n দিয়ে শেষ
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '%n';



%r% — Contains
/* ============================================================
   LIKE
   FirstName-এর যেকোনো জায়গায় r
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '%r%';


__r% — Third Character
/* ============================================================
   LIKE
   Third character = r
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName LIKE '__r%';


Pattern:
_   _   r   %
↓   ↓   ↓   ↓
1   2   3   4+
    
👉 মূল কথা: LIKE = exact value নয়, pattern খোঁজা।






13. সবগুলো এক নজরে 🎯
Operator	     সহজ অর্থ	           কেন ব্যবহার করবো?	         Real Example
=	             Equal	               Exact value	                 Germany customers
<>	             Not Equal	           Value বাদ দিতে	             Germany বাদ
>	             Greater	           Threshold-এর উপরে	         Score > 500
>=	             Greater/Equal	       Minimum limit	             Score ≥ 500
<	             Less	               Threshold-এর নিচে	         Price < 50
<=	             Less/Equal	           Maximum limit	             Price ≤ 50
AND	             সব শর্ত	               Multiple conditions	         USA + Score > 500
OR	             যেকোনো একটি	       Alternative conditions	     USA অথবা Germany
NOT	             বিপরীত	               Exclusion	                 Cancelled বাদ
BETWEEN	         Range	               সীমার মধ্যে	                 Price 50–200
IN	             Multiple values	   অনেক exact value	         USA/Germany/Canada
LIKE	         Pattern	           Search	                     Name starts with M







14. কোন Situation-এ কোনটা? 🧠
Exact Value?
    ↓
   =

Value বাদ?
    ↓
   <>

বেশি?
    ↓
   >

বেশি বা সমান?
    ↓
   >=

কম?
    ↓
   <

কম বা সমান?
    ↓
   <=

সব condition দরকার?
    ↓
   AND

যেকোনো condition?
    ↓
   OR

Condition-এর বিপরীত?
    ↓
   NOT

Range?
    ↓
 BETWEEN

অনেকগুলো নির্দিষ্ট value?
    ↓
   IN

Pattern/Search?
    ↓
  LIKE





    

15. সবচেয়ে গুরুত্বপূর্ণ Real Business Query 🔥
বাস্তবে একটি query-তে একাধিক filtering একসাথে থাকবে।
ধরুন Management বললো:
USA অথবা Germany-এর customers, যাদের score 500 বা তার বেশি।

/* ============================================================
   REAL BUSINESS FILTER
   USA অথবা Germany
   AND Score 500 বা তার বেশি
   ============================================================ */
SELECT
    CustomerID,
    FirstName,
    LastName,
    Country,
    Score
FROM Customers
WHERE Country IN ('USA', 'Germany')
  AND Score >= 500;


এখানে আমরা একসাথে ব্যবহার করেছি:
IN
 ↓
USA / Germany select

AND
 ↓
আরেকটি condition যোগ

>=
 ↓
Minimum Score 500

    
এটাই বাস্তব SQL-এর মূল শক্তি:
Business Question
       ↓
WHERE
       ↓
Filtering Operators
       ↓
Relevant Rows
       ↓
Analysis / Report / ETL


    
⭐ মনে রাখার সহজ নিয়ম
- 🎯 = → এটাই চাই
- 🚫 <> → এটা চাই না
- 📈 > / >= → উচ্চ value
- 📉 < / <= → নিম্ন value
- 🔗 AND → সব শর্ত
- 🔀 OR → যেকোনো শর্ত
- 🚫 NOT → উল্টো / বাদ
- 📏 BETWEEN → range
- 📦 IN → multiple exact values
- 🔎 LIKE → pattern/search




