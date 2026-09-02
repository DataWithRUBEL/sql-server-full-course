1. -- DDL-এর মূল কাজ হলো database structure তৈরি ও পরিবর্তন করা।
CREATE  → Structure তৈরি
ALTER   → Structure পরিবর্তন
DROP    → Structure মুছে ফেলা 





      
      
2. এখন CREATE-এর আসল বিষয়
CREATE TABLE দিয়ে আমরা শুধু table তৈরি করি না।
      
একটি production table-এর structure-এ সাধারণত থাকে:
CREATE TABLE
      ↓
Columns
      ↓
Data Types
      ↓
NULL / NOT NULL
      ↓
Primary Key
      ↓
Foreign Key
      ↓
Constraints


      
-- উদাহরণ:
CREATE TABLE Customers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    BirthDate DATE NULL,
    Phone VARCHAR(20) NOT NULL,

    CONSTRAINT PK_Customers
        PRIMARY KEY (CustomerID)
);



-- গুরুত্বপূর্ণ বিষয়
CustomerID INT
      
-- মানে:
CustomerID integer হবে।

CustomerName VARCHAR(100)
-- মানে:
সর্বোচ্চ 100 character-এর text।

      
-- NOT NULL
মানে:
value অবশ্যই দিতে হবে।


      
-- NULL
মানে:
value না থাকলেও চলবে।


      
-- PRIMARY KEY
মানে:
প্রতিটি row-কে uniquely identify করবে।






      

3. ALTER TABLE — Structure পরিবর্তন
এখন ধরা যাক business বলল:
"Customers table-এ Email দরকার।"

তখন existing table recreate না করে:

-- ============================================================
-- ALTER TABLE
-- Add Email column
-- ============================================================
ALTER TABLE Customers
ADD Email VARCHAR(100) NULL;




Data update
-- ============================================================
-- Update Email
-- ============================================================
UPDATE Customers
SET Email = 'rubel@gmail.com'
WHERE CustomerID = 1;


UPDATE Customers
SET Email = 'omar@gmail.com'
WHERE CustomerID = 2;








4. ALTER — একসাথে একাধিক Column
SQL Server-এ একাধিক column-ও add করা যায়।
      
-- ============================================================
-- Add multiple columns
-- ============================================================
ALTER TABLE Customers
ADD Gender VARCHAR(10) NULL,
    City VARCHAR(50) NULL;







5. ALTER — Column পরিবর্তন
ধরা যাক Phone এখন 20 character-এর বদলে 30 character প্রয়োজন।
      
-- ============================================================
-- Change column data type/size
-- ============================================================
ALTER TABLE Customers
ALTER COLUMN Phone VARCHAR(30) NOT NULL;



 ⚠️ Best Practice
-- ALTER COLUMN করার আগে existing data check করবেন।
SELECT
    CustomerID,
    Phone
FROM Customers;

কারণ existing data যদি নতুন datatype-এর সাথে compatible না হয়, 
তাহলে alteration fail করতে পারে।





      


6. ALTER — Column Rename
ধরা যাক:
CustomerName
এর নাম পরিবর্তন করে:
FullName
করতে হবে।

      
SQL Server-এ:
-- ============================================================
-- Rename column
-- ============================================================
EXEC sp_rename
    'Customers.CustomerName',
    'FullName',
    'COLUMN';


Check:
SELECT *
FROM Customers;







7.ALTER — Column DROP
ধরা যাক Phone আর দরকার নেই।
      
-- ============================================================
-- Remove Phone column
-- ============================================================
ALTER TABLE Customers
DROP COLUMN Phone;


এখন:
CustomerID
FullName
Country
BirthDate
Email
Gender
City
      
⚠️ খুব গুরুত্বপূর্ণ
DROP COLUMN করলে সেই column-এর data এবং structure চলে যাবে।
তাই production database-এ আগে dependency check করবেন।





      

8. ALTER — Constraint Add
ধরা যাক Email unique হওয়া উচিত।
      
-- ============================================================
-- Add UNIQUE constraint
-- ============================================================
ALTER TABLE Customers
ADD CONSTRAINT UQ_Customers_Email
UNIQUE (Email);

এখন একই email দুই customer-এর জন্য ব্যবহার করা যাবে না।







9. ALTER — Constraint Remove
যদি unique constraint আর প্রয়োজন না হয়:
      
-- ============================================================
-- Remove UNIQUE constraint
-- ============================================================
ALTER TABLE Customers
DROP CONSTRAINT UQ_Customers_Email;






10. DROP TABLE
এবার সবচেয়ে destructive DDL command।
      
DROP TABLE Customers;

এতে:
Customers table
      ↓
Structure ❌
Data ❌
Constraints ❌
Indexes ❌
সব চলে যাবে।






      

11. কিন্তু আমাদের ক্ষেত্রে DROP করা যাবে না ⚠️
কারণ অন্য table-গুলো Customers-এর ওপর foreign key দিয়ে নির্ভর করছে।
Orders
  ↓
Customers
তাই আগে dependency remove করতে হবে।

      
উদাহরণ:
-- ============================================================
-- Remove foreign key dependency
-- ============================================================
ALTER TABLE Orders
DROP CONSTRAINT FK_Orders_Customers;


তারপর:
DROP TABLE Customers;
তবে real production database-এ এভাবে table drop করা অত্যন্ত সতর্কতার বিষয়।






12. DROP বনাম DELETE বনাম TRUNCATE
      
এই তিনটি খুব গুরুত্বপূর্ণ:
      
Command	Data	                Structure	         WHERE
DELETE	❌ Data remove	    ✅ থাকে	         ✅
TRUNCATE	❌ সব data remove    ✅ থাকে	         ❌
DROP	      ❌ Data remove	    ❌ Structure remove    ❌



Example
-- নির্দিষ্ট customer delete
DELETE FROM Customers
WHERE CustomerID = 5;


-- সব customer data remove
TRUNCATE TABLE Customers;


-- পুরো table remove
DROP TABLE Customers;






13. Real Data Engineering Example
      
ধরুন আমরা একটি ETL pipeline তৈরি করেছি:
Source ERP
    ↓
Bronze
    ↓
Silver
    ↓
Gold
    ↓
Power BI


      
--Production-এ DDL-এর ব্যবহার হবে:
-- Bronze
CREATE TABLE bronze.Customers
(
    CustomerID INT,
    CustomerName VARCHAR(100),
    Country VARCHAR(50)
);



-- Silver
CREATE TABLE silver.Customers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL
);



-- Gold
CREATE TABLE gold.DimCustomer
(
    CustomerKey INT NOT NULL,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,

    CONSTRAINT PK_DimCustomer
        PRIMARY KEY (CustomerKey)
);

এখানে DDL হচ্ছে data architecture-এর foundation।






14. Data Analyst + Data Engineer Perspective
      
একসাথে পুরো workflow:
CREATE
  ↓
Database/Table তৈরি
  ↓
ALTER
  ↓
Structure পরিবর্তন
  ↓
INSERT
  ↓
Data Load
  ↓
SELECT
  ↓
Data Analysis
  ↓
UPDATE / DELETE
  ↓
Data Maintenance
  ↓
TRUNCATE
  ↓
Staging Data Refresh
  ↓
DROP
  ↓
Obsolete Object Remove






15. Best Practices ⭐
- 🏗️ CREATE: Table তৈরি করার সময় meaningful table/column name ব্যবহার করুন।
- 🔑 Primary Key: প্রতিটি গুরুত্বপূর্ণ entity table-এ primary key রাখুন।
- 🔗 Foreign Key: Relationship enforce করার প্রয়োজন হলে foreign key ব্যবহার করুন।
- 📏 Datatype: প্রয়োজন অনুযায়ী ছোট ও appropriate datatype নির্বাচন করুন।
- 🚫 NULL: NOT NULL শুধু যেখানে business rule অনুযায়ী value mandatory সেখানে ব্যবহার করুন।
- 🧱 ALTER: Production table পরিবর্তনের আগে dependency এবং existing data check করুন।
- ⚠️ DROP: DROP TABLE production-এ execute করার আগে অত্যন্ত সতর্ক থাকুন।
- 📝 Naming: PK_, FK_, UQ_ ইত্যাদি consistent constraint naming ব্যবহার করুন।
- 🧪 Testing: Production-এর আগে development/test environment-এ DDL test করুন।
- 📦 Version Control: গুরুত্বপূর্ণ DDL scripts Git-এ রাখুন।







16. এই Lesson-এর Core Concept
      
মনে রাখবেন:
CREATE
   ↓
"কিছু তৈরি করব"

ALTER
   ↓
"তৈরি করা জিনিসের structure পরিবর্তন করব"

DROP
   ↓
"তৈরি করা object পুরোপুরি মুছে ফেলব"



      
একটি Real Example
-- CREATE
CREATE TABLE TestCustomers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL
);


-- ALTER
ALTER TABLE TestCustomers
ADD Email VARCHAR(100) NULL;



-- ALTER
ALTER TABLE TestCustomers
ALTER COLUMN CustomerName VARCHAR(150) NOT NULL;



-- ALTER
ALTER TABLE TestCustomers
DROP COLUMN Email;



-- DROP
DROP TABLE TestCustomers;









More Practice

1. CREATE — Database/Table তৈরি
🎯 কী কাজ করে?
CREATE দিয়ে নতুন database, table, schema, view ইত্যাদি object তৈরি করা হয়।
Database তৈরি

      
-- নতুন database তৈরি
CREATE DATABASE SalesDB;
GO

     
USE SalesDB;
GO

    
এরপর table:
-- Customer table তৈরি
CREATE TABLE Customers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL,
    Email VARCHAR(100) NULL,

    CONSTRAINT PK_Customers
        PRIMARY KEY (CustomerID)
);


এখন:
SalesDB
   ↓
Customers
   ↓
CustomerID
CustomerName
Country
Email
      
Real Example
একটি e-commerce company নতুন customer system তৈরি করছে।
তাদের প্রথমে Customer table-এর structure তৈরি করতে হবে।







2. ALTER — Structure পরিবর্তন
🎯 কী কাজ করে?
আগে তৈরি করা table-এর structure পরিবর্তন করতে ALTER TABLE ব্যবহার করা হয়।

      
ধরুন business বলল:
Customer-এর phone number-ও রাখতে হবে।

-- Existing table-এ নতুন column যোগ
ALTER TABLE Customers
ADD Phone VARCHAR(20) NULL;


এখন:
Customers
├── CustomerID
├── CustomerName
├── Country
├── Email
└── Phone       ← নতুন
Column পরিবর্তন


      
-- CustomerName-এর size পরিবর্তন
ALTER TABLE Customers
ALTER COLUMN CustomerName VARCHAR(150) NOT NULL;


Column remove
-- Phone column remove
ALTER TABLE Customers
DROP COLUMN Phone;


সহজভাবে
CREATE → নতুন structure

ALTER → পুরোনো structure পরিবর্তন






3. INSERT — Data Load 📥
Table তৈরি হয়েছে, কিন্তু এখনো data নেই।

-- Customer data load
INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    Email
)
VALUES
(1, 'Rubel Ahmed', 'Bangladesh', 'rubel@gmail.com'),
(2, 'Omar Hasan', 'Kuwait', 'omar@gmail.com'),
(3, 'John Smith', 'USA', 'john@gmail.com'),
(4, 'David Lee', 'UK', 'david@gmail.com');



Data Engineering Example
ETL pipeline-এ:
CSV
 ↓
Python/PySpark
 ↓
SQL Server
 ↓
INSERT
 ↓
Table
INSERT হলো database-এ নতুন row load করার একটি fundamental operation।







4. SELECT — Data Analysis 🔎
Data load হয়ে গেছে।
এখন data দেখতে এবং analyze করতে SELECT ব্যবহার করি।

      
-- সব customer
SELECT *
FROM Customers;


-- শুধু নির্দিষ্ট column:
SELECT
    CustomerID,
    CustomerName,
    Country
FROM Customers;


-- Filter
-- Bangladesh-এর customer
SELECT
    CustomerID,
    CustomerName,
    Country
FROM Customers
WHERE Country = 'Bangladesh';



-- Data Analysis Example
-- ধরুন আমাদের Orders table আছে।
SELECT
    CustomerID,
    COUNT(*) AS TotalOrders
FROM Orders
GROUP BY CustomerID;


এখানে:
SELECT
   ↓
Data retrieve

WHERE
   ↓
Filter

GROUP BY
   ↓
Group

COUNT()
   ↓
Measure
এটাই Data Analyst-এর সবচেয়ে গুরুত্বপূর্ণ কাজগুলোর একটি।






5. UPDATE — Existing Data পরিবর্তন ✏️
ধরুন Rubel-এর email পরিবর্তন হয়েছে।

      
-- Existing customer data update
UPDATE Customers
SET Email = 'rubel.ahmed@gmail.com'
WHERE CustomerID = 1;

আগে:
rubel@gmail.com
      
পরে:
rubel.ahmed@gmail.com


      
⚠️ খুব গুরুত্বপূর্ণ
WHERE ভুলে গেলে:
UPDATE Customers
SET Country = 'Kuwait';

তাহলে সব customer-এর country Kuwait হয়ে যাবে।


      
-- তাই production-এ আগে:
SELECT *
FROM Customers
WHERE CustomerID = 1;


তারপর:
UPDATE Customers
SET Email = 'newemail@gmail.com'
WHERE CustomerID = 1;






6. DELETE — Data Remove

ধরুন CustomerID = 4-এর customer record remove করতে হবে।
DELETE FROM Customers
WHERE CustomerID = 4;

শুধু:
CustomerID = 4
এর row delete হবে।


      
⚠️ Dangerous
DELETE FROM Customers;
WHERE নেই।
ফলে সব rows delete হয়ে যাবে।
      
Table থাকবে:
Customers
   ↓
Structure থাকবে ✅
Data থাকবে না ❌






7. UPDATE vs DELETE
Command	কাজ
UPDATE	Existing data পরিবর্তন
DELETE	Existing row remove
INSERT	New row add
SELECT	Data retrieve/analyze

      
সহজ formula:
INSERT
→ নতুন data

SELECT
→ data দেখুন

UPDATE
→ data পরিবর্তন করুন

DELETE
→ data remove করুন






8. TRUNCATE — পুরো Table Empty করা 

      
ধরুন আমাদের ETL-এর staging table:
stg.Sales
প্রতিদিন নতুন source file load করার আগে পুরোনো staging data remove করতে হবে।

      
TRUNCATE TABLE StagingSales;
এতে:
Rows        → ❌ Remove
Table       → ✅ থাকবে
Columns     → ✅ থাকবে
Structure   → ✅ থাকবে 

      
অর্থাৎ:
TRUNCATE
    ↓
Table থাকবে
    ↓
সব rows চলে যাবে







9. TRUNCATE কেন Staging-এ বেশি ব্যবহার হয়?
      
ধরুন:
Day 1 CSV
   ↓
StagingSales
   ↓
ETL
   ↓
Production

      
পরের দিন:
Day 2 CSV
   ↓
StagingSales
      
Day 1-এর staging data আগে remove করতে পারি:
TRUNCATE TABLE StagingSales;


তারপর:
INSERT INTO StagingSales
...

      
Flow:
Old Staging Data
       ↓
   TRUNCATE
       ↓
Empty Staging Table
       ↓
New Data
       ↓
INSERT
এটি Data Engineering-এ খুব common pattern।




      


10. DELETE বনাম TRUNCATE
      
বিষয়	                         DELETE	      TRUNCATE
Rows remove	                   ✅	            ✅
WHERE	                         ✅	            ❌
Table থাকে	                   ✅	            ✅
Structure থাকে	             ✅	            ✅
সব rows দ্রুত empty করার জন্য	 কম উপযোগী	বেশি উপযোগী
Typical staging refresh	কখনো	 ✅              খুব common



উদাহরণ:
-- নির্দিষ্ট data
DELETE FROM Customers
WHERE Country = 'USA';


অন্যদিকে:
-- সব staging data
TRUNCATE TABLE StagingSales;






11. DROP — Object পুরোপুরি Remove
      
এখন ধরুন একটি temporary/obsolete table আর প্রয়োজন নেই:
      
DROP TABLE StagingSales;


এতে:
Table structure ❌
Rows ❌
Columns ❌
Constraints ❌
Indexes ❌
সব চলে যায়।







12. DROP বনাম TRUNCATE
      
এটা খুব ভালোভাবে মনে রাখবেন:
TRUNCATE
TRUNCATE TABLE StagingSales;


মানে:
Table রাখুন, data সরান।

Table → ✅
Data  → ❌
DROP

      
DROP TABLE StagingSales;
মানে:
Table-টাই সরান।
Table → ❌
Data  → ❌






13. পুরো Lifecycle একসাথে 🔥
একটি real-world customer system ধরুন।

      
Step 1 — Database
CREATE DATABASE SalesDB;


↓
Step 2 — Table
CREATE TABLE Customers
(
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL
);


↓
Step 3 — Structure change
ALTER TABLE Customers
ADD Email VARCHAR(100);


↓
Step 4 — Data load
INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    Email
)
VALUES
(1, 'Rubel Ahmed', 'Bangladesh', 'rubel@gmail.com'),
(2, 'Omar Hasan', 'Kuwait', 'omar@gmail.com');



↓
Step 5 — Analysis
SELECT
    CustomerID,
    CustomerName,
    Country
FROM Customers
WHERE Country = 'Bangladesh';



↓
Step 6 — Maintenance
UPDATE Customers
SET Email = 'rubel.ahmed@gmail.com'
WHERE CustomerID = 1;



↓
Step 7 — Remove specific data
DELETE FROM Customers
WHERE CustomerID = 2;



↓
Step 8 — Staging refresh
TRUNCATE TABLE StagingSales;



↓
Step 9 — Obsolete object
DROP TABLE StagingSales;








14. সবচেয়ে গুরুত্বপূর্ণ Mental Model 🧠
                SQL SERVER
                    │
                    ▼
                CREATE
                    │
             Structure তৈরি
                    │
                    ▼
                 ALTER
                    │
          Structure পরিবর্তন
                    │
                    ▼
                 INSERT
                    │
              Data Load
                    │
                    ▼
                 SELECT
                    │
          Data Analysis / Reporting
                    │
                    ▼
            UPDATE / DELETE
                    │
             Data Maintenance
                    │
                    ▼
                TRUNCATE
                    │
          Staging Data Refresh
                    │
                    ▼
                  DROP
                    │
           Object Remove

      
⭐ এক লাইনে মনে রাখুন
- 🏗️ CREATE: নতুন object তৈরি করি।
- 🔧 ALTER: existing object-এর structure পরিবর্তন করি।
- 📥 INSERT: নতুন data load করি।
- 🔎 SELECT: data retrieve/analyze করি।
- ✏️ UPDATE: existing data পরিবর্তন করি।
- 🗑️ DELETE: নির্দিষ্ট row/data remove করি।
- 🧹 TRUNCATE: table রেখে সব rows empty করি।
- 💣 DROP: object-সহ তার structure পুরোপুরি remove করি।
