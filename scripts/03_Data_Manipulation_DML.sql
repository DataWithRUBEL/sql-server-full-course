💡 DML মূলত table-এর data পরিবর্তন করে। Table structure পরিবর্তন করে না।

DML Flow
INSERT
  ↓
নতুন Data যোগ

UPDATE
  ↓
Existing Data পরিবর্তন

DELETE
  ↓
Data মুছে ফেলা

SELECT
  ↓
পরিবর্তন Verify




আগের ৭টি table-ই ব্যবহার করছি:
Customers
   ↓
Orders
   ↓
OrderItems
   ↓
Products
   ↓
Categories
   ↓
Employees
   ↓
Departments
এখানে নতুন table তৈরি করার প্রয়োজন নেই। নিচের উদাহরণগুলোতে মূলত Customers table ব্যবহার করছি,
কারণ আপনার দেওয়া schema অনুযায়ী এর columns নিশ্চিতভাবে জানা আছে।



/*
===============================================================================
SQL SERVER DATA MANIPULATION LANGUAGE (DML)
===============================================================================

DML = Database-এর existing data নিয়ে কাজ করার language.

মূল DML Commands:

INSERT   → নতুন data যোগ করা
UPDATE   → existing data পরিবর্তন করা
DELETE   → নির্দিষ্ট data মুছে ফেলা

Important:
DML সাধারণত table-এর structure পরিবর্তন করে না।
এটি table-এর ভিতরের data পরিবর্তন করে।

Existing Tables:
Customers
Orders
OrderItems
Products
Categories
Employees
Departments

===============================================================================
*/






1. INSERT
INSERT ব্যবহার করা হয় নতুন row/table data যোগ করার জন্য।
বাস্তব business scenario:
নতুন customer আমাদের কোম্পানিতে registration করেছে।

INSERT ... VALUES
সবচেয়ে common এবং সহজ method।
-- নতুন customer যোগ করা

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    101,
    'Rahim Ahmed',
    'Bangladesh',
    '1995-05-15',
    '+8801712345678'
);
কী হচ্ছে?
CustomerID  → 101
CustomerName → Rahim Ahmed
Country      → Bangladesh
BirthDate    → 1995-05-15
Phone        → +8801712345678







Multiple Rows INSERT
একসাথে অনেক customer insert করা যায়।
-- একসাথে একাধিক customer যোগ করা

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
    (102, 'Karim Hassan', 'Bangladesh', '1992-08-20', '+8801812345678'),
    (103, 'John Smith', 'USA', '1988-03-10', '+12125551234'),
    (104, 'Emma Wilson', 'UK', '1996-11-25', '+447700900123'),
    (105, 'Omar Ali', 'Kuwait', '1990-01-12', '+96550001234');
Real-world use
ETL pipeline-এ source থেকে batch data পাওয়ার পর ছোট dataset হলে এই ধরনের insert ব্যবহার করা যায়।




2. INSERT-এর Column Order
Column order ভুল হলে problem হতে পারে।
❌ ভুল পদ্ধতি
-- Column-এর order-এর সাথে value-এর meaning match করছে না

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    106,
    'Bangladesh',
    'Rahim Ahmed',
    '1995-05-15',
    '+8801712345678'
);
এখানে:
CustomerName → Bangladesh
Country      → Rahim Ahmed
অর্থাৎ SQL syntax valid হলেও business data ভুল হতে পারে।





Best Practice
-- সবসময় column name explicitly লিখুন

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    106,
    'Rahim Ahmed',
    'Bangladesh',
    '1995-05-15',
    '+8801712345678'
);





3. Data Type ভুল হলে
-- CustomerID INT
-- কিন্তু এখানে VARCHAR value দেওয়া হয়েছে

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    'Rahim',
    'Rahim Ahmed',
    'Bangladesh',
    '1995-05-15',
    '+8801712345678'
);
এখানে SQL Server error দেবে।
কারণ:
CustomerID → INT
'Rahim'    → VARCHAR
Best Practice
INT      → numeric value
DATE     → valid date
VARCHAR  → text









4. NULL ব্যবহার
আপনার table-এ:
BirthDate DATE NULL
অর্থাৎ BirthDate না থাকলেও customer insert করা যাবে।
-- Customer-এর জন্মতারিখ জানা নেই

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    107,
    'Sakib Hasan',
    'Bangladesh',
    NULL,
    '+8801912345678'
);
এখানে:
BirthDate = NULL
মানে জন্মতারিখ unknown/missing।
⚠️ NULL মানে 0 বা empty string নয়।






5. NOT NULL Constraint
আপনার table:
CustomerID INT NOT NULL,
CustomerName VARCHAR(100) NOT NULL,
Country VARCHAR(50) NOT NULL,
Phone VARCHAR(20) NOT NULL
তাই এগুলো বাদ দিয়ে INSERT করা যাবে না।
-- ❌ Country এবং Phone দেওয়া হয়নি

INSERT INTO Customers
(
    CustomerID,
    CustomerName
)
VALUES
(
    108,
    'David'
);
SQL Server error দেবে।
কারণ:
Country → NOT NULL
Phone   → NOT NULL






6. Primary Key-এর কারণে Duplicate INSERT
আপনার:
CustomerID INT NOT NULL

PRIMARY KEY (CustomerID)
তাই একই CustomerID দুইবার দেওয়া যাবে না।
-- প্রথমবার

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    109,
    'Hasan Ali',
    'Bangladesh',
    '1994-02-10',
    '+8801612345678'
);
আবার:
-- ❌ একই CustomerID

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    109,
    'Another Customer',
    'Kuwait',
    '1990-01-01',
    '+96551112233'
);
Error হবে।
কারণ
PK_Customers
     ↓
CustomerID must be UNIQUE








7. INSERT ... SELECT
এটি Data Analyst এবং Data Engineer-এর জন্য খুব গুরুত্বপূর্ণ।
এখানে একটি table-এর existing data থেকে data নিয়ে অন্য জায়গায় insert করা হয়।
আপনার existing Customers table দিয়েই demonstration করছি।
-- Existing customers থেকে নতুন customer records তৈরি করা
-- CustomerID + 1000 করা হচ্ছে যাতে Primary Key duplicate না হয়

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
SELECT
    CustomerID + 1000,
    CustomerName + ' - Copy',
    Country,
    BirthDate,
    Phone
FROM Customers
WHERE CustomerID BETWEEN 101 AND 105;
কী হচ্ছে?
ধরা যাক source:
101  Rahim Ahmed
102  Karim Hassan
103  John Smith
নতুন data হবে:
1101  Rahim Ahmed - Copy
1102  Karim Hassan - Copy
1103  John Smith - Copy
Data Engineering-এ কেন গুরুত্বপূর্ণ?
ETL process-এ প্রায়ই:
Source
   ↓
SELECT
   ↓
Transformation
   ↓
INSERT
   ↓
Target
এই pattern ব্যবহার করা হয়।






8. INSERT ... SELECT-এর Transformation
শুধু copy না করে data transform করেও insert করা যায়।
-- Existing customer data থেকে transformed data insert

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
SELECT
    CustomerID + 2000,
    UPPER(CustomerName),
    UPPER(Country),
    BirthDate,
    Phone
FROM Customers
WHERE Country = 'Bangladesh';
এখানে:
CustomerID → +2000
CustomerName → UPPER()
Country → UPPER()
অর্থাৎ:
Raw Data
   ↓
Transformation
   ↓
INSERT
এটাই ETL-এর basic ধারণা।





9. INSERT Without Column Names
এভাবে লেখা যায়:
-- ❌ Recommended নয়

INSERT INTO Customers
VALUES
(
    110,
    'Rashed',
    'Bangladesh',
    '1993-06-15',
    '+8801711111111'
);
এটি কাজ করতে পারে।
কিন্তু production environment-এ avoid করা ভালো।
কেন?
Table structure পরে পরিবর্তন হলে query break করতে পারে।
Best Practice
-- ✅ সবসময় column explicitly specify করুন

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    110,
    'Rashed',
    'Bangladesh',
    '1993-06-15',
    '+8801711111111'
);








10. UPDATE
UPDATE existing data পরিবর্তন করে।
Real business scenario:
Customer-এর phone number পরিবর্তন হয়েছে।

-- Customer 101-এর phone number পরিবর্তন

UPDATE Customers
SET Phone = '+8801999999999'
WHERE CustomerID = 101;









11. UPDATE Multiple Columns
এক query-তে একাধিক column update করা যায়।
-- Customer information update

UPDATE Customers
SET
    CustomerName = 'Rahim Ahmed Khan',
    Country = 'Kuwait',
    Phone = '+96560001234'
WHERE CustomerID = 101;






12. UPDATE with Condition
Real business scenario:
USA-এর customer-এর country classification পরিবর্তন করতে হবে।

-- USA customers-এর country value পরিবর্তন

UPDATE Customers
SET Country = 'United States'
WHERE Country = 'USA';
⚠️ এটি একাধিক row update করতে পারে।
তাই আগে check করা উচিত:
-- আগে দেখতে হবে কতগুলো row affected হবে

SELECT *
FROM Customers
WHERE Country = 'USA';
তারপর:
-- তারপর UPDATE

UPDATE Customers
SET Country = 'United States'
WHERE Country = 'USA';

⭐ Best Practice
SELECT
  ↓
Verify rows
  ↓
UPDATE
Production environment-এ এটি খুব গুরুত্বপূর্ণ।





13. UPDATE NULL Data
ধরা যাক কিছু customer-এর BirthDate নেই।
-- যাদের BirthDate নেই তাদের identify করা

SELECT *
FROM Customers
WHERE BirthDate IS NULL;
তারপর যদি trusted source থেকে date পাওয়া যায়:
-- নির্দিষ্ট customer-এর BirthDate update

UPDATE Customers
SET BirthDate = '1995-05-15'
WHERE CustomerID = 107;
⚠️ Missing data অনুমান করে update করা উচিত নয়।







14. UPDATE Without WHERE
এটি খুব dangerous।
-- ❌ খুব সতর্ক থাকতে হবে

UPDATE Customers
SET Country = 'Kuwait';
এতে সব customer-এর Country Kuwait হয়ে যাবে।
এটি production database-এ বড় data-quality problem তৈরি করতে পারে।
সাধারণ rule
UPDATE
    ↓
SET
    ↓
WHERE
প্রায় সবসময় WHERE verify করুন।









15. DELETE
DELETE নির্দিষ্ট row মুছে ফেলে।
Real business scenario:
ভুলভাবে তৈরি করা customer record remove করতে হবে।

প্রথমে:
-- আগে data যাচাই

SELECT *
FROM Customers
WHERE CustomerID = 110;
তারপর:
-- নির্দিষ্ট customer delete

DELETE FROM Customers
WHERE CustomerID = 110;






16. DELETE Multiple Rows
-- নির্দিষ্ট দেশের customer delete করার আগে check

SELECT *
FROM Customers
WHERE Country = 'TestCountry';
তারপর:
-- TestCountry-এর customer delete

DELETE FROM Customers
WHERE Country = 'TestCountry';







17. DELETE Without WHERE
-- ❌ সব rows delete হয়ে যাবে

DELETE FROM Customers;
এটি:
Customers
   ↓
All Rows Deleted
কিন্তু table structure থাকবে।
অর্থাৎ:
Table      → থাকবে
Columns    → থাকবে
Primary Key → থাকবে
Indexes    → থাকবে
Data       → থাকবে না






18. DELETE বনাম TRUNCATE
দুটিই data remove করতে পারে, কিন্তু behavior আলাদা।

  
Feature	                  DELETE	                             TRUNCATE
Row delete	              ✅	                                  ✅
WHERE	                    ✅	                                  ❌
Table structure	          থাকে	                                থাকে
Selective delete	        ✅	                                  ❌
সাধারণত faster	          ❌	                                  ✅
Identity reset	সাধারণত   ❌	                                  ✅
Trigger behavior	        DELETE trigger fire করতে পারে	      DELETE trigger নয়
FK restrictions	          প্রযোজ্য	                              আরও restrictive







19. TRUNCATE TABLE
যদি পুরো table-এর সব data remove করতে হয়:
-- Customers table-এর সব data remove

TRUNCATE TABLE Customers;
এর পর:
Customers
   ↓
Empty Table
কিন্তু:
Table
Columns
Constraints
Indexes
থাকে।






20. DELETE vs TRUNCATE — Real Data Engineering Example
ধরা যাক ETL pipeline-এর staging table আছে।
Source CSV
    ↓
Staging Table
    ↓
Transform
    ↓
Final Table
প্রতিদিন staging data refresh করতে হবে।
তখন সাধারণ pattern:
-- পুরোনো staging data remove

TRUNCATE TABLE Customers;

-- নতুন batch load
INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    201,
    'New Customer',
    'Bangladesh',
    '1995-01-01',
    '+8801700000000'
);
⚠️ বাস্তব production system-এ অবশ্যই table relationship, FK এবং transaction strategy আগে যাচাই করতে হবে।







21. DELETE + Transaction
Production database-এ accidental delete থেকে protection-এর জন্য transaction খুব useful।
-- Transaction শুরু

BEGIN TRANSACTION;

-- প্রথমে verify করা

SELECT *
FROM Customers
WHERE CustomerID = 105;

-- Delete

DELETE FROM Customers
WHERE CustomerID = 105;

-- পরিবর্তন পরীক্ষা

SELECT *
FROM Customers
WHERE CustomerID = 105;

-- ঠিক থাকলে
COMMIT TRANSACTION;

-- ভুল হলে COMMIT-এর পরিবর্তে:
-- ROLLBACK TRANSACTION;



গুরুত্বপূর্ণ ধারণা
BEGIN TRANSACTION
        ↓
DELETE / UPDATE
        ↓
VERIFY
        ↓
   ┌────┴────┐
   ↓         ↓
 COMMIT    ROLLBACK
   ↓         ↓
 Save       Undo
এটি production data maintenance-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।






22. DML Best Practices ⭐
  
🟢 INSERT
Column List: সবসময় column names explicitly লিখুন।
Validation: Primary Key ও data type আগে verify করুন।
Batch Load: বড় dataset-এর ক্ষেত্রে appropriate bulk-loading approach ব্যবহার করুন।
ETL: INSERT ... SELECT বুঝে ব্যবহার করুন।
  
  
🟡 UPDATE
WHERE: Production-এ update করার আগে WHERE verify করুন।
Preview: আগে একই condition দিয়ে SELECT চালান।
Transaction: গুরুত্বপূর্ণ update-এর ক্ষেত্রে transaction ব্যবহার করুন।
Audit: গুরুত্বপূর্ণ business data change হলে audit/history strategy রাখুন।
  
  
🔴 DELETE
Preview: আগে SELECT করুন।
WHERE: selective delete-এর জন্য অবশ্যই condition ব্যবহার করুন।
Transaction: গুরুত্বপূর্ণ deletion transaction-এর মধ্যে করুন।
FK: Customers → Orders → OrderItems relationship থাকলে parent row delete করার আগে dependency বুঝুন।

  
🔵 TRUNCATE
Staging: staging/raw refresh scenario-তে খুব useful।
Production: খুব সতর্ক হয়ে ব্যবহার করুন।
FK: table relationship থাকলে আগে dependency check করুন।
Recovery: destructive operation-এর আগে backup/recovery strategy বুঝুন।





23. সবচেয়ে গুরুত্বপূর্ণ DML Pattern
আপনার SQL Server শেখার সময় এই pattern মাথায় রাখুন:
-- INSERT
INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    301,
    'Noman Ahmed',
    'Bangladesh',
    '1997-04-20',
    '+8801700000001'
);
-- UPDATE

UPDATE Customers
SET
    Phone = '+8801700000002'
WHERE CustomerID = 301;
-- DELETE

DELETE FROM Customers
WHERE CustomerID = 301;
-- TRUNCATE

TRUNCATE TABLE Customers;




🧠 এক লাইনে মনে রাখুন
INSERT   → Data ঢুকায়
UPDATE   → Data পরিবর্তন করে
DELETE   → নির্দিষ্ট Data মুছে
TRUNCATE → পুরো Table-এর Data খালি করে








More practice
1. SELECT → প্রথমে কী পরিবর্তন করবো তা খুঁজে বের করা
ধরা যাক CustomerID = 101 customer-এর phone number পরিবর্তন করতে হবে।
প্রথমে কখনোই সরাসরি UPDATE করবেন না। 

-- ============================================================
-- STEP 1: SELECT
-- যে customer-এর data পরিবর্তন করবো তাকে আগে খুঁজে বের করা
-- ============================================================

SELECT
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
FROM Customers
WHERE CustomerID = 101;

এখন আমরা নিশ্চিত হলাম যে CustomerID 101-ই সঠিক customer।







2. VERIFY → কতগুলো row পরিবর্তন হবে যাচাই করা
এখন ধরুন আমরা Bangladesh দেশের customer-দের phone format update করতে চাই।
সরাসরি UPDATE না করে আগে:
-- ============================================================
-- STEP 2: VERIFY
-- UPDATE করার আগে কোন কোন rows affected হবে তা দেখা
-- ============================================================

SELECT
    CustomerID,
    CustomerName,
    Country,
    Phone
FROM Customers
WHERE Country = 'Bangladesh';

ধরা যাক 10টি row পাওয়া গেল।
তাহলে আমরা বুঝলাম:
WHERE Country = 'Bangladesh'
             ↓
10 rows affected
এখন business requirement-এর সাথে মিলিয়ে দেখতে হবে:
সত্যিই কি 10 জন customer-এর data পরিবর্তন করা উচিত?

যদি হ্যাঁ → UPDATE।
যদি না → query modify করতে হবে।









3. UPDATE → Transaction-এর মধ্যে পরিবর্তন করা
এখন আমরা safe way-তে update করবো।

-- ============================================================
-- STEP 3: BEGIN TRANSACTION
-- UPDATE-এর পরিবর্তন temporary transaction-এর মধ্যে রাখা
-- ============================================================

BEGIN TRANSACTION;


-- ============================================================
-- UPDATE
-- CustomerID 101-এর phone number পরিবর্তন করা
-- ============================================================

UPDATE Customers
SET Phone = '+8801999999999'
WHERE CustomerID = 101;
এখনও পরিবর্তনটি permanently commit করিনি।



4. VERIFY → UPDATE ঠিক হয়েছে কিনা পরীক্ষা
UPDATE করার পর আবার SELECT করুন।
-- ============================================================
-- STEP 4: VERIFY
-- UPDATE-এর পরে data সঠিক হয়েছে কিনা পরীক্ষা
-- ============================================================

SELECT
    CustomerID,
    CustomerName,
    Country,
    Phone
FROM Customers
WHERE CustomerID = 101;





-- ============================================================
-- STEP 4: VERIFY
-- UPDATE-এর পরে data সঠিক হয়েছে কিনা পরীক্ষা
-- ============================================================

SELECT
    CustomerID,
    CustomerName,
    Country,
    Phone
FROM Customers
WHERE CustomerID = 101;

এখন change permanently save হয়েছে।





6. ROLLBACK → ভুল হলে Undo
ধরা যাক UPDATE করার পরে দেখলেন ভুল customer update হয়েছে।
তাহলে COMMIT না করে:
-- ============================================================
-- ভুল UPDATE হলে পরিবর্তন বাতিল করা
-- ============================================================

ROLLBACK TRANSACTION;
তাহলে transaction শুরু করার আগের অবস্থায় ফিরে যাবে।






7. Complete UPDATE Workflow
এখন পুরো process একসাথে:
-- ============================================================
-- SAFE UPDATE WORKFLOW
-- ============================================================


-- STEP 1: SELECT
-- প্রথমে target customer খুঁজে বের করা

SELECT
    CustomerID,
    CustomerName,
    Country,
    Phone
FROM Customers
WHERE CustomerID = 101;


-- STEP 2: VERIFY
-- কয়টি row update হবে তা যাচাই করা

SELECT COUNT(*) AS RowsToUpdate
FROM Customers
WHERE CustomerID = 101;


-- STEP 3: BEGIN TRANSACTION
-- পরিবর্তন transaction-এর মধ্যে রাখা

BEGIN TRANSACTION;


-- STEP 4: UPDATE
-- Customer-এর phone number পরিবর্তন করা

UPDATE Customers
SET Phone = '+8801999999999'
WHERE CustomerID = 101;


-- STEP 5: VERIFY
-- UPDATE-এর পরে result পরীক্ষা করা

SELECT
    CustomerID,
    CustomerName,
    Country,
    Phone
FROM Customers
WHERE CustomerID = 101;


-- STEP 6: COMMIT অথবা ROLLBACK
-- সব ঠিক থাকলে COMMIT
-- ভুল হলে ROLLBACK

COMMIT TRANSACTION;

-- ROLLBACK TRANSACTION;




8. DELETE-এর ক্ষেত্রে একই Workflow
ধরা যাক CustomerID = 105 একটি ভুল/test customer এবং তাকে delete করতে হবে।
Step 1 → SELECT
-- ============================================================
-- STEP 1: SELECT
-- Delete করার আগে customer-এর data দেখা
-- ============================================================

SELECT *
FROM Customers
WHERE CustomerID = 105;






Step 2 → VERIFY
-- ============================================================
-- STEP 2: VERIFY
-- কয়টি row delete হবে তা পরীক্ষা
-- ============================================================

SELECT COUNT(*) AS RowsToDelete
FROM Customers
WHERE CustomerID = 105;





Step 3 → BEGIN TRANSACTION + DELETE
-- ============================================================
-- STEP 3: TRANSACTION
-- Delete operation নিরাপদ transaction-এর মধ্যে করা
-- ============================================================

BEGIN TRANSACTION;


-- ============================================================
-- DELETE
-- CustomerID 105 delete করা
-- ============================================================

DELETE FROM Customers
WHERE CustomerID = 105;







Step 4 → VERIFY
-- ============================================================
-- STEP 4: VERIFY
-- DELETE-এর পরে customer আর আছে কিনা পরীক্ষা
-- ============================================================

SELECT *
FROM Customers
WHERE CustomerID = 105;







Step 5 → COMMIT
সবকিছু ঠিক থাকলে:
-- ============================================================
-- STEP 5: COMMIT
-- DELETE permanently save করা
-- ============================================================

COMMIT TRANSACTION;






9. DELETE ভুল হলে ROLLBACK
ধরা যাক আপনি ভুল করে:
-- ============================================================
-- ভুল condition-এর উদাহরণ
-- ============================================================

DELETE FROM Customers
WHERE Country = 'Bangladesh';
ধরা যাক 500 customer delete হয়ে গেল।
যদি এটি transaction-এর মধ্যে করা হয় এবং এখনও COMMIT না করা হয়:
-- ============================================================
-- ভুল DELETE বাতিল করা
-- ============================================================

ROLLBACK TRANSACTION;
তাহলে delete করা rows ফিরে আসবে।








10. INSERT-এর ক্ষেত্রেও একই Pattern
নতুন customer যোগ করার সময়:
-- ============================================================
-- STEP 1: SELECT
-- CustomerID আগে থেকেই আছে কিনা পরীক্ষা
-- ============================================================

SELECT *
FROM Customers
WHERE CustomerID = 200;
যদি result 0 rows হয়:
-- ============================================================
-- STEP 2: BEGIN TRANSACTION
-- ============================================================

BEGIN TRANSACTION;


-- ============================================================
-- STEP 3: INSERT
-- নতুন customer যোগ করা
-- ============================================================

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    200,
    'Mahmud Hasan',
    'Bangladesh',
    '1994-09-15',
    '+8801711111111'
);


-- ============================================================
-- STEP 4: VERIFY
-- INSERT সঠিক হয়েছে কিনা পরীক্ষা
-- ============================================================

SELECT *
FROM Customers
WHERE CustomerID = 200;


-- ============================================================
-- STEP 5: COMMIT
-- সব ঠিক থাকলে permanently save
-- ============================================================

COMMIT TRANSACTION;

-- ভুল হলে:
-- ROLLBACK TRANSACTION;









11. সবচেয়ে গুরুত্বপূর্ণ Pattern 🧠
তিনটি DML operation-এর জন্য basic workflow একই:
INSERT
SELECT
   ↓
VERIFY
   ↓
BEGIN TRANSACTION
   ↓
INSERT
   ↓
VERIFY
   ↓
COMMIT / ROLLBACK
UPDATE
SELECT
   ↓
VERIFY
   ↓
BEGIN TRANSACTION
   ↓
UPDATE
   ↓
VERIFY
   ↓
COMMIT / ROLLBACK
DELETE
SELECT
   ↓
VERIFY
   ↓
BEGIN TRANSACTION
   ↓
DELETE
   ↓
VERIFY
   ↓
COMMIT / ROLLBACK




12. Production Best Practice ⭐
-- ============================================================
-- SAFE DML GOLDEN RULE
-- ============================================================

-- 1. আগে SELECT করুন
-- 2. কতগুলো rows affected হবে VERIFY করুন
-- 3. BEGIN TRANSACTION করুন
-- 4. INSERT / UPDATE / DELETE করুন
-- 5. আবার SELECT করে VERIFY করুন
-- 6. ঠিক হলে COMMIT
-- 7. ভুল হলে ROLLBACK
বিশেষ করে এই নিয়মটি মনে রাখবেন:
                 ┌── ভুল ──→ ROLLBACK
                 │
SELECT → VERIFY → DML → VERIFY
                         │
                         └── ঠিক ──→ COMMIT




















