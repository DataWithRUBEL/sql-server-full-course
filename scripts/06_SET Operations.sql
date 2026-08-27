###  SET Operations-এর Rules
SQL Server-এ প্রধান ৪টি SET Operation:
  
Operation	                কাজ	                                 Duplicate
UNION	                    দুই result একত্র করে	                   ❌ Remove
UNION ALL	                দুই result একত্র করে	                   ✅ রাখে
EXCEPT	                  প্রথম query-তে আছে, দ্বিতীয়টিতে নেই	   ❌
INTERSECT	                দুই query-তেই আছে	                   ❌

  
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









More Practice
1. UNION — Duplicate বাদ দিয়ে Combine
- 🔹 কাজ: দুইটি query-এর result একত্র করে এবং duplicate row বাদ দেয়।
/* ============================================================
   UNION
   Customer এবং Employee-এর নাম একসাথে দেখানো
   Duplicate নাম একবারই থাকবে
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;


ধরুন দুই table-এই আছে:
John Smith
Sarah Wilson
  
UNION করলে:
John Smith
Sarah Wilson
একবারই থাকবে।
কখন ব্যবহার করবেন?
Customers
   +
Employees
   ↓
UNION
   ↓
Unique People
- 📊 Reporting: Unique customer + employee list
- 🧹 Deduplication: Duplicate row বাদ দেওয়া
- 🔎 Analysis: দুই source-এর unique data একত্র করা







2. UNION ALL — সব Record রাখা
- 🔹 কাজ: দুই query-এর সব row combine করে। Duplicate থাকলেও বাদ দেয় না।
/* ============================================================
   UNION ALL
   Customer এবং Employee-এর সব নাম দেখানো
   Duplicate থাকলেও রাখা হবে
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION ALL

SELECT
    FirstName,
    LastName
FROM Sales.Employees;


যদি John Smith দুই table-এই থাকে:
John Smith
John Smith
দুইবার থাকবে।
কেন ETL-এ UNION ALL বেশি ব্যবহার হয়?

  
ধরুন:
2025 Orders
      +
2026 Orders
      ↓
UNION ALL
      ↓
All Orders
Data Engineer হিসেবে আপনি সাধারণত source-এর প্রতিটি record রাখতে চান।

  
/* ============================================================
   Current এবং Archive Orders একত্র করা
   সব record রাখা হবে
   ============================================================ */
SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.Orders

UNION ALL

SELECT
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.OrdersArchive;







3. EXCEPT — প্রথমটিতে আছে, দ্বিতীয়টিতে নেই
- 🔹 কাজ: প্রথম query-এর মধ্যে আছে কিন্তু দ্বিতীয় query-তে নেই—এমন data বের করে।
সহজভাবে:
A EXCEPT B

A-এর data
   -
B-এর data
   =
A-তে আছে কিন্তু B-তে নেই

  
Example
/* ============================================================
   Employees যারা Customers নয়
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Employees

EXCEPT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;


ধরুন:
Employees:
John
Sarah
James
Peter

Customers:
John
Sarah
David
  
Result:
James
Peter
কারণ তারা Employee কিন্তু Customer নয়।
Real Business Use
Employees
    ↓
EXCEPT
    ↓
Customers
    ↓
Employees who are NOT Customers
এটি data reconciliation-এর জন্য খুব useful।







4. INTERSECT — দুই জায়গাতেই আছে
- 🔹 কাজ: দুই query-এর মধ্যে common row বের করে।
সহজভাবে:
A INTERSECT B

A-এর data
   ∩
B-এর data
   =
Common Data

  
Example
/* ============================================================
   Employee এবং Customer উভয়ই যারা
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Employees

INTERSECT

SELECT
    FirstName,
    LastName
FROM Sales.Customers;


ধরুন:
Employees:
John
Sarah
James
Peter

Customers:
John
Sarah
David

  
Result:
John
Sarah
Real Business Use
- 🔎 Overlap: দুই dataset-এর common customer
- 🧪 Validation: দুই source-এ একই data আছে কিনা
- 📊 Analysis: Common users/customers/employees






5. Columns — একই সংখ্যক Column
- 🔹 Rule: UNION, UNION ALL, EXCEPT, INTERSECT করার সময় দুই query-তে একই সংখ্যক column থাকতে হবে।
❌ ভুল:
/* ============================================================
   ভুল:
   প্রথম query = 3 columns
   দ্বিতীয় query = 2 columns
   ============================================================ */
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


এখানে:
Customers  → 3 columns
Employees  → 2 columns
তাই error হবে।

  
✅ সঠিক:
/* ============================================================
   সঠিক:
   দুই query-তেই 2টি column
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;







6. Types — Compatible Data Type
- 🔹 Rule: একই position-এর column-এর data type compatible হওয়া উচিত।

উদাহরণ:
/* ============================================================
   CustomerID এবং EmployeeID দুটিই INT
   তাই compatible
   ============================================================ */
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
তাই ঠিক আছে।






7. Meaning — Business Meaning Match করতে হবে
- 🔹 Rule: শুধু data type একই হলেই হবে না। Column-এর অর্থও একই হতে হবে।
  
ধরুন:
/* ============================================================
   Technically সম্ভব হতে পারে,
   কিন্তু business meaning ভুল
   ============================================================ */
SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    LastName,
    FirstName
FROM Sales.Employees;


এখানে দ্বিতীয় query-তে:
FirstName position → LastName
LastName position  → FirstName
ফলে output-এর meaning ভুল হবে।


  
✅ সঠিক:
/* ============================================================
   একই position-এ একই business meaning
   ============================================================ */

SELECT
    FirstName,
    LastName
FROM Sales.Customers

UNION

SELECT
    FirstName,
    LastName
FROM Sales.Employees;


সহজ নিয়ম
Column 1 → একই অর্থ
Column 2 → একই অর্থ
Column 3 → একই অর্থ





8. Order — Column Position একই
- 🔹 Rule: SQL Server column name দেখে matching করে না; position অনুযায়ী combine করে।
  
/* ============================================================
   Column position match করছে
   ============================================================ */
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
Column 1 → LastName
Column 1 → LastName

Column 2 → CustomerID
Column 2 → EmployeeID
সঠিক।





9. Alias — প্রথম SELECT-এর Name
- 🔹 Rule: Final result-এর column name প্রথম SELECT থেকে আসে।
  
/* ============================================================
   প্রথম SELECT-এর alias final column name হবে
   ============================================================ */
SELECT
    CustomerID AS ID,
    LastName AS CustomerName
FROM Sales.Customers

UNION

SELECT
    EmployeeID,
    LastName
FROM Sales.Employees;


Result column:
ID
CustomerName
দ্বিতীয় query-তে alias দিলেও final column name পরিবর্তন হবে না।

/* ============================================================
   দ্বিতীয় SELECT-এর alias final column name পরিবর্তন করবে না
   ============================================================ */
SELECT
    CustomerID AS ID,
    LastName AS CustomerName
FROM Sales.Customers

UNION

SELECT
    EmployeeID AS EmployeeID,
    LastName AS EmployeeName
FROM Sales.Employees;


Final output:
ID
CustomerName
Best Practice
প্রথম query-তেই meaningful alias দিন।






10. Performance — UNION বনাম UNION ALL
- 🔹 UNION: Duplicate remove করতে হয়।
- 🔹 UNION ALL: Duplicate remove করে না।
তাই বড় dataset-এ UNION অতিরিক্ত processing করতে পারে।
  
/* ============================================================
   Duplicate remove করার প্রয়োজন থাকলে UNION
   ============================================================ */
SELECT
    CustomerID
FROM Sales.Customers

UNION

SELECT
    CustomerID
FROM Sales.Orders;


আর duplicate রাখার প্রয়োজন হলে:
/* ============================================================
   সব records প্রয়োজন হলে UNION ALL
   ============================================================ */
SELECT
    CustomerID
FROM Sales.Customers

UNION ALL

SELECT
    CustomerID
FROM Sales.Orders;


সহজ সিদ্ধান্ত
Duplicate বাদ দিতে হবে?
        │
     YES ──→ UNION
        │
      NO ──→ UNION ALL







11. ETL — Current + Archive
- 🔹 Scenario: Current orders এবং historical orders আলাদা table-এ আছে।
  
/* ============================================================
   ETL:
   Current + Archive Orders
   ============================================================ */
SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    Quantity,
    Sales
FROM Sales.Orders

UNION ALL

SELECT
    OrderID,
    ProductID,
    CustomerID,
    SalesPersonID,
    OrderDate,
    Quantity,
    Sales
FROM Sales.OrdersArchive;


এতে:
Current Orders
      +
Archive Orders
      ↓
UNION ALL
      ↓
Complete Orders Dataset
এটি Data Engineering pipeline-এ খুব common pattern।







12. ETL — Source Tracking
- 🔹 কাজ: কোন table/source থেকে record এসেছে তা রাখা।
  
/* ============================================================
   Source Tracking
   প্রতিটি record-এর source রাখা হচ্ছে
   ============================================================ */
SELECT
    'CURRENT' AS SourceTable,
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.Orders

UNION ALL

SELECT
    'ARCHIVE' AS SourceTable,
    OrderID,
    CustomerID,
    OrderDate,
    Sales
FROM Sales.OrdersArchive;


Result:
SourceTable   OrderID   CustomerID   Sales
------------------------------------------
CURRENT       1001      1            20
CURRENT       1002      2            45
ARCHIVE       9001      6            20
ARCHIVE       9002      7            45
  
এতে পরে সহজে জানা যায়:
Record → কোথা থেকে এসেছে?
এটি data lineage এবং troubleshooting-এ useful।







13. EXCEPT — Data Reconciliation
- 🔹 কাজ: দুই source-এর মধ্যে missing record খুঁজে বের করা।
ধরুন Current Orders-এর সব OrderID Archive-এ আছে কিনা check করতে চাই।
  
/* ============================================================
   Current Orders-এ আছে
   কিন্তু Archive-এ নেই
   ============================================================ */
SELECT
    OrderID
FROM Sales.Orders

EXCEPT

SELECT
    OrderID
FROM Sales.OrdersArchive;


Result যদি হয়:
1001
1002
1003
1004
1005
তার অর্থ:
এই OrderIDগুলো Current Orders-এ আছে, কিন্তু Archive-এ নেই।

এটি data reconciliation-এর একটি simple example।






14. INTERSECT — Common Records Validation
- 🔹 কাজ: দুই table-এ একই record আছে কিনা check করা।
  
/* ============================================================
   Current এবং Archive উভয় table-এ থাকা OrderID
   ============================================================ */
SELECT
    OrderID
FROM Sales.Orders

INTERSECT

SELECT
    OrderID
FROM Sales.OrdersArchive;


যদি result আসে:
1003
তাহলে 1003 দুই dataset-এই আছে।







15. চারটি Operation একসাথে মনে রাখুন
/* ============================================================
   SET OPERATIONS CHEAT SHEET
   ============================================================ */
UNION
    → Combine + Duplicate Remove

UNION ALL
    → Combine + Keep Everything

EXCEPT
    → First-এর মধ্যে আছে
      Second-এর মধ্যে নেই

INTERSECT
    → দুই জায়গাতেই আছে


  
সবচেয়ে সহজ Mental Model
A = Customers
B = Employees

A UNION B
→ A + B
→ Duplicate বাদ


A UNION ALL B
→ A + B
→ Duplicate রাখে


A EXCEPT B
→ A-তে আছে
→ B-তে নেই


A INTERSECT B
→ A এবং B
→ দুই জায়গাতেই আছে 



  
Final Best Practice
/* ============================================================
   SET OPERATIONS - BEST PRACTICE
   ============================================================ */
1. দুই query-তে একই সংখ্যক column রাখুন।

2. Corresponding column-এর data type compatible রাখুন।

3. Column position একই রাখুন।

4. শুধু data type নয়,
   business meaning-ও একই রাখুন।

5. Final column name-এর জন্য
   প্রথম SELECT-এ alias ব্যবহার করুন।

6. Duplicate বাদ দিতে হলে UNION ব্যবহার করুন।

7. সব records রাখতে হলে UNION ALL ব্যবহার করুন।

8. ETL-এ Current + Archive combine করতে
   সাধারণত UNION ALL ব্যবহার করুন।

9. Missing/unmatched data খুঁজতে EXCEPT ব্যবহার করুন।

10. Common/overlapping data খুঁজতে INTERSECT ব্যবহার করুন।

11. বড় dataset-এ অপ্রয়োজনে UNION ব্যবহার করবেন না।

12. ETL pipeline-এ SourceTable রাখলে
    data lineage ও troubleshooting সহজ হয়।



