1. SET Operations-এর Rules
SQL Server-এ প্রধান ৪টি SET Operation:
  
Operation	                কাজ	                                 Duplicate
UNION	                    দুই result একত্র করে	                   ❌ Remove
UNION ALL	                দুই result একত্র করে	                   ✅ রাখে
EXCEPT	                  প্রথম query-তে আছে, দ্বিতীয়টিতে নেই	     ❌
INTERSECT	                দুই query-তেই আছে	                     ❌

  
গুরুত্বপূর্ণ Rule
  
দুই SELECT-এর:
একই সংখ্যক column থাকতে হবে
Corresponding column-এর data type compatible হতে হবে
Column order একই logical meaning-এর হতে হবে
Result-এর column name প্রথম SELECT থেকে আসবে 



  

1. SET OPERATIONS-এর মূল Rules
Rule 1 — Column Count
দুই SELECT-এ একই সংখ্যক columns থাকতে হবে।
❌ ভুল:
/* দুই পাশে column সংখ্যা আলাদা */

SELECT
    FirstName,
    LastName,
    Country
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;


✅ সঠিক:
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;




Rule 2 — Compatible Data Types
একই position-এর columns-এর data type compatible হওয়া উচিত।
/* CustomerID এবং EmployeeID উভয়ই INT */

SELECT
    CustomerID,
    LastName
FROM Sales.Customers

UNION

SELECT
    EmployeeID,
    LastName
FROM Sales.Employees;


এখানে:
CustomerID  → INT
EmployeeID  → INT
LastName    → VARCHAR
LastName    → VARCHAR
তাই এটি valid।








2. Column Order
Column-এর position গুরুত্বপূর্ণ।
/* প্রথম column-এর সাথে প্রথম column
   দ্বিতীয় column-এর সাথে দ্বিতীয় column match করবে */

SELECT
    LastName,
    CustomerID
FROM Sales.Customers

UNION

SELECT
    LastName,
    EmployeeID
FROM Sales.Employees;


এখানে:
LastName   ↔ LastName
CustomerID ↔ EmployeeID
সঠিক।







3. Column Alias Rule
Final result-এর column name সাধারণত প্রথম SELECT থেকে আসে।
SELECT
    CustomerID AS ID,
    LastName AS Last_Name
FROM Sales.Customers

UNION

SELECT
    EmployeeID,
    LastName
FROM Sales.Employees;
Result:
ID
Last_Name
কারণ alias প্রথম query-তে দেওয়া হয়েছে।







4. Correct Column Meaning
Data type match করলেই হবে না।
Business meaning-ও match করতে হবে।
❌ ভুল design:
/* FirstName এবং LastName উল্টো হয়ে গেছে */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    LastName,
    FirstName
FROM Sales.Employees;
এতে data technically return করবে, কিন্তু business meaning ভুল হবে। 

  
✅ সঠিক:
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;






5. UNION
কাজ
UNION দুই বা তার বেশি result set combine করে এবং duplicate remove করে।
/* ==============================================================================
   UNION
   Customers এবং Employees-এর নাম একত্রে আনা
   Duplicate নাম remove হবে
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;
এখানে:
Customer
   +
Employee
   ↓
UNION
   ↓
Duplicate Removed
Real Business Use
/* Customer এবং Employee উভয় তালিকায় থাকা unique people */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;
📊 ব্যবহার হতে পারে:
👥 People List: সব customer + employee
📧 Contact List: combined contact population
📈 Reporting: multiple sources থেকে unique records







6. UNION ALL
কাজ
UNION ALL duplicate remove করে না।
/* ==============================================================================
   UNION ALL
   সব records রাখবে
   Duplicate থাকলেও remove করবে না
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION ALL

SELECT
    FirstName,
    LastName
FROM Sales.Employees;

যেমন John Smith দুই জায়গায় থাকলে:
John Smith
John Smith
দুইবার থাকবে।









7. UNION vs UNION ALL
  
Feature	                 UNION	                  UNION ALL
Duplicate	               Remove	                  Keep
Performance	             তুলনামূলক কম	            তুলনামূলক বেশি
Deduplication	           Yes	                    No
ETL	                     কম প্রয়োজনীয় ক্ষেত্রে	      খুব common
Reporting	               Unique list	            Full data



Best Practice
/* Duplicate দরকার নেই */

SELECT FirstName, LastName
FROM Sales.Customers

UNION

SELECT FirstName, LastName
FROM Sales.Employees;


আর data warehouse / ETL-এ যখন প্রতিটি source record রাখতে হবে:
/* সমস্ত source record preserve করা হচ্ছে */

SELECT FirstName, LastName
FROM Sales.Customers

UNION ALL

SELECT FirstName, LastName
FROM Sales.Employees;






8. EXCEPT
কাজ
প্রথম query-তে আছে কিন্তু দ্বিতীয় query-তে নেই—এমন data বের করে।
A EXCEPT B

A-এর data
   -
B-এর matching data
   ↓
A-তে আছে কিন্তু B-তে নেই
Employees যারা Customers নয়
/* ==============================================================================
   EXCEPT
   Employees-এর মধ্যে যারা Customer নয়
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Employees

EXCEPT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;


Business Meaning
Employees
   -
Customers
   =
Employees who are NOT Customers
Data Quality Use
/* Employee master এবং customer master-এর মধ্যে unmatched people খুঁজে বের করা */

SELECT
    FirstName,
    LastName
FROM Sales.Employees

EXCEPT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;

এটি data reconciliation-এ useful।






9. INTERSECT
কাজ
দুই result set-এর common records বের করে।
A INTERSECT B

A
∩
B
↓
Common Records
Employees যারা Customers-ও
/* ==============================================================================
   INTERSECT
   Employees এবং Customers-এর common people
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Employees

INTERSECT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;


Result-এর মধ্যে যেমন থাকতে পারে:
John Smith
Sarah Wilson
Robert Miller
Emma Davis
Daniel Moore
Business Use
/* একই ব্যক্তি Employee এবং Customer দুই role-এ আছে কিনা */

SELECT
    FirstName,
    LastName
FROM Sales.Employees

INTERSECT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;






10. UNION — Orders + Archive
এটি Data Engineering-এ খুব গুরুত্বপূর্ণ pattern।
/* ==============================================================================
   CURRENT ORDERS + ARCHIVED ORDERS
   Duplicate records remove করবে
   ============================================================================== */

SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
FROM Sales.Orders

UNION

SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
FROM Sales.OrdersArchive;

এটি একটি combined order dataset তৈরি করবে।







11. UNION ALL — Orders + Archive
ETL-এর ক্ষেত্রে সাধারণত UNION ALL বেশি practical।
/* ==============================================================================
   CURRENT + ARCHIVE
   সমস্ত records preserve করা হচ্ছে
   ============================================================================== */

SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
FROM Sales.Orders

UNION ALL

SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    ShipDate,
    OrderStatus,
    Quantity,
    Sales,
    CreationTime
FROM Sales.OrdersArchive;

কেন UNION ALL?
কারণ ETL-এ:
Current Orders
      +
Archive Orders
      ↓
UNION ALL
      ↓
Complete Order Dataset
প্রতিটি source record preserve করা যায়।







12. SourceTable যোগ করা
কোন source থেকে data এসেছে সেটিও রাখা যায়।
/* ==============================================================================
   SOURCE TRACKING
   কোন table থেকে record এসেছে তা identify করা
   ============================================================================== */

SELECT
    'Current Orders' AS SourceTable,
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.Orders

UNION ALL

SELECT
    'Orders Archive' AS SourceTable,
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.OrdersArchive

ORDER BY OrderID;






13. EXCEPT দিয়ে Order Reconciliation
ধরা যাক current এবং archive table-এর মধ্যে একই order আছে কিনা check করতে চাই।
/* ==============================================================================
   CURRENT ORDERS বনাম ARCHIVE ORDERS
   Archive-এ নেই এমন current orders
   ============================================================================== */

SELECT
    OrderID
FROM Sales.Orders

EXCEPT

SELECT
    OrderID
FROM Sales.OrdersArchive;

Business question:
কোন current order archive-এ নেই?







14. INTERSECT দিয়ে Common Orders
/* ==============================================================================
   CURRENT এবং ARCHIVE উভয় table-এ থাকা OrderID
   ============================================================================== */

SELECT
    OrderID
FROM Sales.Orders

INTERSECT

SELECT
    OrderID
FROM Sales.OrdersArchive;

এটি duplicate বা unexpected overlap detect করতে সাহায্য করে।










15. UNION + ORDER BY
ORDER BY সাধারণত পুরো combined result-এর শেষে দেওয়া হয়।
/* ==============================================================================
   COMBINED CUSTOMER + EMPLOYEE LIST
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees

ORDER BY
    LastName,
    FirstName;






16. Real Analytics Example
Customer এবং Employee দুই জায়গায় থাকা people বের করা:
/* ==============================================================================
   CUSTOMER + EMPLOYEE OVERLAP
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

INTERSECT

SELECT
    FirstName,
    LastName
FROM Sales.Employees

ORDER BY
    LastName,
    FirstName;



Employees কিন্তু customers নয়:
/* ==============================================================================
   EMPLOYEES WHO ARE NOT CUSTOMERS
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Employees

EXCEPT

SELECT
    FirstName,
    LastName
FROM Sales.Customers

ORDER BY
    LastName,
    FirstName;



Customers কিন্তু employees নয়:
/* ==============================================================================
   CUSTOMERS WHO ARE NOT EMPLOYEES
   ============================================================================== */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

EXCEPT

SELECT
    FirstName,
    LastName
FROM Sales.Employees

ORDER BY
    LastName,
    FirstName;









17. চারটি SET Operation একসাথে
/* ==============================================================================
   UNION
   দুই dataset-এর unique records
   ============================================================================== */

SELECT FirstName, LastName
FROM Sales.Customers

UNION

SELECT FirstName, LastName
FROM Sales.Employees;


/* ==============================================================================
   UNION ALL
   দুই dataset-এর সব records
   ============================================================================== */

SELECT FirstName, LastName
FROM Sales.Customers

UNION ALL

SELECT FirstName, LastName
FROM Sales.Employees;


/* ==============================================================================
   EXCEPT
   Employees যারা Customers নয়
   ============================================================================== */

SELECT FirstName, LastName
FROM Sales.Employees

EXCEPT

SELECT FirstName, LastName
FROM Sales.Customers;


/* ==============================================================================
   INTERSECT
   Employees যারা Customers-ও
   ============================================================================== */

SELECT FirstName, LastName
FROM Sales.Employees

INTERSECT

SELECT FirstName, LastName
FROM Sales.Customers;








18. Data Analyst + Data Engineer Best Practice
🔹 UNION: যখন duplicate বাদ দিয়ে combined dataset দরকার।
🔹 UNION ALL: যখন সব source records রাখতে হবে; ETL-এ সাধারণত preferred।
🔹 EXCEPT: unmatched records ও reconciliation-এর জন্য।
🔹 INTERSECT: common records ও overlap analysis-এর জন্য।
🔹 Columns: একই সংখ্যক column ব্যবহার করুন।
🔹 Types: corresponding columns-এর compatible data type রাখুন।
🔹 Meaning: শুধু data type match নয়, business meaning-ও match করুন।
🔹 Order: column position একই রাখুন।
🔹 Alias: প্রথম SELECT-এর alias final output column name নির্ধারণ করে।
🔹 Performance: বড় dataset-এ অপ্রয়োজনে UNION ব্যবহার না করে প্রয়োজন অনুযায়ী UNION ALL ব্যবহার করুন।
🔹 ETL: Current + Archive/Sales source combine করার সময় source tracking রাখা ভালো।
🔹 Reconciliation: EXCEPT এবং INTERSECT data quality validation-এ অত্যন্ত useful।


  
SET Operations-এর Mental Model
                    SET OPERATIONS
                          │
          ┌───────────────┼────────────────┐
          │               │                │
       UNION          UNION ALL          EXCEPT
          │               │                │
     Unique Data       All Data        Difference
          │               │                │
          └───────────────┼────────────────┘
                          │
                     INTERSECT
                          │
                     Common Data
মূল কথা: UNION/UNION ALL দিয়ে dataset combine, আর EXCEPT/INTERSECT দিয়ে dataset-এর difference ও overlap বিশ্লেষণ করা হয়।









