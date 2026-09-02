1. Transaction কী? 🟢
  
- 🔹 সংজ্ঞা: Transaction হলো এক বা একাধিক SQL statement-এর একটি logical unit, 
  যেগুলো সবগুলো সফল হলে COMMIT হবে, আর কোনো গুরুত্বপূর্ণ অংশ ব্যর্থ হলে ROLLBACK করা যাবে।
- 🔹 মূল ধারণা: ALL succeed → COMMIT এবং ANY critical failure → ROLLBACK
- 🔹 Real example: একজন customer-এর account থেকে $500 কমানো 
  এবং অন্য account-এ $500 যোগ করা—দুটি operation-ই একসাথে সফল হতে হবে।
  
-- ============================================================
-- Transaction-এর মূল ধারণা
-- ============================================================
BEGIN TRANSACTION;

    -- Step 1: টাকা কমানো
    UPDATE Banking.Accounts
    SET Balance = Balance - 500
    WHERE AccountID = 101;

    -- Step 2: টাকা যোগ করা
    UPDATE Banking.Accounts
    SET Balance = Balance + 500
    WHERE AccountID = 202;



COMMIT TRANSACTION;
যদি দ্বিতীয় UPDATE ব্যর্থ হয়, তাহলে প্রথম UPDATE-ও rollback করতে হবে।







2. কেন Transaction ব্যবহার করবো? 🎯
- 🔐 Data Integrity: অসম্পূর্ণ data change আটকায়।
- ⚛️ Atomic Operation: একাধিক operation-কে একটি unit হিসেবে চালায়।
- 🔄 Rollback: ভুল হলে আগের অবস্থায় ফিরতে পারি।
- 🔒 Concurrency: একই data নিয়ে multiple users কাজ করলে consistency বজায় রাখতে সাহায্য করে।
- 🧾 Auditability: Business operation-এর logical boundary তৈরি করা যায়।
- 🏗️ ETL Safety: ETL-এর critical data-loading operation failure হলে rollback করা যায়।







🟢 BEGINNER
3. BEGIN TRANSACTION
Transaction শুরু করার syntax:
-- ============================================================
-- Start a Transaction
-- ============================================================
BEGIN TRANSACTION;

-- SQL statements

COMMIT TRANSACTION;



Short form:
BEGIN TRAN;

-- statements

COMMIT;







4. COMMIT TRANSACTION
COMMIT transaction-এর changes permanently save করে।
-- ============================================================
-- COMMIT Example
-- ============================================================
BEGIN TRANSACTION;

UPDATE Banking.Accounts
SET Balance = Balance - 500
WHERE AccountID = 101;

COMMIT TRANSACTION;


Check:
SELECT *
FROM Banking.Accounts;







5. ROLLBACK TRANSACTION
ROLLBACK transaction-এর changes undo করে।
-- ============================================================
-- ROLLBACK Example
-- ============================================================
BEGIN TRANSACTION;

UPDATE Banking.Accounts
SET Balance = Balance - 500
WHERE AccountID = 101;

-- ভুল বুঝতে পেরেছি
ROLLBACK TRANSACTION;
ফলে balance আগের অবস্থায় ফিরে যাবে।








6. Basic Transaction Flow 🔄
BEGIN TRANSACTION
        ↓
SQL Statement 1
        ↓
SQL Statement 2
        ↓
SQL Statement 3
        ↓
Everything OK?
   ↓             ↓
 YES             NO
  ↓               ↓
COMMIT          ROLLBACK
  ↓               ↓
SAVE            UNDO






7. Multiple Statements in Transaction
এটাই Transaction-এর সবচেয়ে গুরুত্বপূর্ণ use case।
-- ============================================================
-- Multiple Business Operations
-- ============================================================
BEGIN TRANSACTION;

-- 1. Create Order
INSERT INTO Sales.Orders
(
    OrderID,
    CustomerID,
    OrderDate,
    OrderStatus,
    TotalAmount
)
VALUES
(
    1001,
    1,
    GETDATE(),
    'Confirmed',
    1280
);


-- 2. Add Order Item
INSERT INTO Sales.OrderItems
(
    OrderItemID,
    OrderID,
    ProductID,
    Quantity,
    UnitPrice
)
VALUES
(
    1,
    1001,
    101,
    1,
    1200
);


-- 3. Reduce Inventory
UPDATE Inventory.Stock
SET QuantityOnHand = QuantityOnHand - 1
WHERE ProductID = 101;


-- Everything successful
COMMIT TRANSACTION;

এখানে তিনটি operation-এর business relationship আছে:
Order
 ↓
OrderItem
 ↓
Inventory Reduction
একটি critical operation fail করলে পুরো transaction rollback করা যেতে পারে।







8. Transaction Scope
Transaction scope বলতে transaction-এর মধ্যে কোন statements অন্তর্ভুক্ত তা বোঝায়।
BEGIN TRANSACTION;

    -- Transaction scope শুরু

    UPDATE Banking.Accounts
    SET Balance = Balance - 100
    WHERE AccountID = 101;

    UPDATE Banking.Accounts
    SET Balance = Balance + 100
    WHERE AccountID = 102;

COMMIT TRANSACTION;

-- Transaction scope শেষ








9. Transaction Comments / Best Practices 📝
-- ============================================================
-- Best Practice Transaction Structure
-- ============================================================

BEGIN TRANSACTION;

    -- Step 1: Validate business conditions

    -- Step 2: Update primary data

    -- Step 3: Update related data

    -- Step 4: Record audit information

COMMIT TRANSACTION;

Rule:
- 🟢 Short: Transaction যত ছোট রাখা যায় তত ভালো।
- 🟢 Clear: Business operation অনুযায়ী transaction boundary করুন।
- 🟢 Validate: Transaction-এর আগে/ভিতরে প্রয়োজনীয় validation করুন।
- 🟢 Error: TRY...CATCH ব্যবহার করুন।
- 🟢 Rollback: Error হলে rollback করুন।







🟡 INTERMEDIATE
10. ACID Properties
SQL Server Transaction-এর foundation হলো ACID।
  
Property	           Meaning
A — Atomicity	       সব হবে অথবা কিছুই হবে না
C — Consistency	     Database valid state-এ থাকবে
I — Isolation	       Concurrent transaction একে অপরকে কীভাবে দেখবে
D — Durability	     Commit হওয়ার পর data survive করবে







11. Atomicity ⚛️
  
Bank transfer:
Account A
$5,000
   ↓
-$500
   ↓
$4,500

Account B
$3,000
   ↓
+$500
   ↓
$3,500
  
দুটি operation-এর একটি fail হলে:
ROLLBACK
ফলে partial transfer হবে না।









12. Consistency 🔒
Business rule:
Balance >= 0
Transaction যেন database constraint/business rule ভেঙে invalid state তৈরি না করে।
-- ============================================================
-- Example: Validate Balance Before Transfer
-- ============================================================
BEGIN TRANSACTION;

IF EXISTS
(
    SELECT 1
    FROM Banking.Accounts
    WHERE AccountID = 101
      AND Balance < 500
)
BEGIN
    ROLLBACK TRANSACTION;
    THROW 50001, 'Insufficient balance.', 1;

END;

UPDATE Banking.Accounts
SET Balance = Balance - 500
WHERE AccountID = 101;

COMMIT TRANSACTION;






13. Isolation 🔐
এক transaction অন্য concurrent transaction-এর পরিবর্তন কীভাবে দেখতে পাবে—এটাই Isolation।
এখান থেকে আসে:
- Dirty Read
- Non-Repeatable Read
- Phantom Read
- Blocking
- Locks








14. Durability 💾
BEGIN TRANSACTION;

UPDATE Banking.Accounts
SET Balance = Balance + 500
WHERE AccountID = 102;

COMMIT TRANSACTION;
COMMIT হওয়ার পর SQL Server transaction-এর committed changes recover করার জন্য transaction log ব্যবহার করে।





15. @@TRANCOUNT
বর্তমানে কত transaction nesting level active আছে তা দেখতে:
-- ============================================================
-- Check Transaction Count
-- ============================================================
SELECT @@TRANCOUNT AS ActiveTransactionCount;
Example:
BEGIN TRANSACTION;


SELECT @@TRANCOUNT AS TransactionCount;

COMMIT TRANSACTION;

Expected:
1








16. Nested Transactions
-- ============================================================
-- Nested Transaction Example
-- ============================================================
BEGIN TRANSACTION;
    UPDATE Banking.Accounts
    SET Balance = Balance - 100
    WHERE AccountID = 101;

    BEGIN TRANSACTION;

        UPDATE Banking.Accounts
        SET Balance = Balance + 100
        WHERE AccountID = 102;

    COMMIT TRANSACTION;

COMMIT TRANSACTION;

⚠️ গুরুত্বপূর্ণ:
SQL Server-এর nested transaction independent transaction নয়।
ভেতরের COMMIT সাধারণত outer transaction-কে সম্পূর্ণ commit করে না।





17. SAVE TRANSACTION
SAVE TRANSACTION একটি savepoint তৈরি করে।
-- ============================================================
-- SAVE TRANSACTION Example
-- ============================================================
BEGIN TRANSACTION;
UPDATE Banking.Accounts
SET Balance = Balance - 100
WHERE AccountID = 101;

SAVE TRANSACTION AfterDebit;

UPDATE Banking.Accounts
SET Balance = Balance + 100
WHERE AccountID = 102;

-- প্রয়োজনে savepoint পর্যন্ত rollback
ROLLBACK TRANSACTION AfterDebit;

COMMIT TRANSACTION;


এখানে:
BEGIN
  ↓
Debit
  ↓
SAVEPOINT
  ↓
Credit
  ↓
ROLLBACK TO SAVEPOINT
  ↓
COMMIT






18. Partial Rollback
-- ============================================================
-- Partial Rollback Example
-- ============================================================
BEGIN TRANSACTION;

UPDATE Inventory.Stock
SET QuantityOnHand = QuantityOnHand - 2
WHERE ProductID = 101;

SAVE TRANSACTION InventoryUpdated;

UPDATE Sales.Customers
SET CreditLimit = CreditLimit + 500
WHERE CustomerID = 1;

-- Customer change undo
ROLLBACK TRANSACTION InventoryUpdated;

COMMIT TRANSACTION;
⚠️ বাস্তব production code-এ business logic অনুযায়ী savepoint design করতে হবে।








19. TRY...CATCH + Transaction 
Production SQL Server development-এ এটি অত্যন্ত গুরুত্বপূর্ণ।
-- ============================================================
-- TRY...CATCH Transaction Pattern
-- ============================================================
BEGIN TRY

    BEGIN TRANSACTION;

        UPDATE Banking.Accounts
        SET Balance = Balance - 500
        WHERE AccountID = 101;

        UPDATE Banking.Accounts
        SET Balance = Balance + 500
        WHERE AccountID = 102;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;







20. Better Production Pattern
-- ============================================================
-- Production-Friendly Transaction Pattern
-- ============================================================
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

        -- Validate source account
        IF NOT EXISTS
        (
            SELECT 1
            FROM Banking.Accounts
            WHERE AccountID = 101
              AND Balance >= 500
        )
        BEGIN
            THROW 50001, 'Insufficient balance.', 1;
        END;

        -- Debit
        UPDATE Banking.Accounts
        SET Balance = Balance - 500
        WHERE AccountID = 101;

        -- Credit
        UPDATE Banking.Accounts
        SET Balance = Balance + 500
        WHERE AccountID = 102;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;






🔴 ADVANCED
21. Isolation Levels
SQL Server-এর প্রধান isolation levels:
READ UNCOMMITTED
       ↓
READ COMMITTED
       ↓
REPEATABLE READ
       ↓
SNAPSHOT
       ↓
SERIALIZABLE



Isolation	             Dirty Read	             Non-Repeatable	       Phantom
READ UNCOMMITTED	     ✅	                     ✅	                    ✅
READ COMMITTED	       ❌	                     ✅	                    ✅
REPEATABLE READ	       ❌	                     ❌	                    ✅
SNAPSHOT	             ❌	                     ❌	                    ❌*
SERIALIZABLE	         ❌	                     ❌	                    ❌


SNAPSHOT row versioning ব্যবহার করে এবং database configuration-এর উপর নির্ভর করে।






22. READ UNCOMMITTED
সবচেয়ে কম restrictive isolation level।
-- ============================================================
-- READ UNCOMMITTED
-- ============================================================
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

SELECT *
FROM Banking.Accounts;


অথবা:
SELECT *
FROM Banking.Accounts WITH (NOLOCK);
⚠️ NOLOCK blindly ব্যবহার করা উচিত নয়।








23. Dirty Read
এক transaction data update করেছে কিন্তু এখনও commit করেনি।
অন্য transaction সেই uncommitted data পড়ে ফেললে:
Transaction A
UPDATE
   ↓
Uncommitted
   ↓
Transaction B reads it
   ↓
ROLLBACK
Transaction B এমন data দেখেছে যা শেষ পর্যন্ত database-এ থাকলই না।
এটাই Dirty Read।








24. READ COMMITTED
SQL Server-এর default isolation level সাধারণত READ COMMITTED।
-- ============================================================
-- READ COMMITTED
-- ============================================================
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

SELECT *
FROM Banking.Accounts;
Uncommitted data সাধারণত read করতে দেয় না।






25. Non-Repeatable Read
এক transaction একই row দুইবার পড়ল:
First Read
Balance = 5000

Another Transaction
UPDATE Balance = 4000
COMMIT

Second Read
Balance = 4000
এক transaction-এর মধ্যে একই row-এর value পরিবর্তিত হয়েছে।
এটাই Non-Repeatable Read।







26. REPEATABLE READ
-- ============================================================
-- REPEATABLE READ
-- ============================================================
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

BEGIN TRANSACTION;

SELECT *
FROM Banking.Accounts
WHERE AccountID = 101;

-- Business processing

SELECT *
FROM Banking.Accounts
WHERE AccountID = 101;

COMMIT TRANSACTION;
এক transaction-এর মধ্যে previously read row পরিবর্তন হওয়া prevent করতে stronger locking ব্যবহার করে।







27. SNAPSHOT
-- ============================================================
-- SNAPSHOT Isolation
-- ============================================================
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;

BEGIN TRANSACTION;

SELECT *
FROM Banking.Accounts;

COMMIT TRANSACTION;


এটি row versioning ব্যবহার করে।
Database-এ snapshot isolation enable করতে হতে পারে:
-- ============================================================
-- Enable SNAPSHOT Isolation
-- Run with appropriate administrative permissions
-- ============================================================
ALTER DATABASE TransactionsDB
SET ALLOW_SNAPSHOT_ISOLATION ON;
GO







28. SERIALIZABLE
সবচেয়ে restrictive standard isolation level।
-- ============================================================
-- SERIALIZABLE
-- ============================================================
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

BEGIN TRANSACTION;

SELECT *
FROM Inventory.Stock
WHERE ProductID = 101;

COMMIT TRANSACTION;
এটি concurrency কমাতে পারে এবং blocking বেশি তৈরি করতে পারে।







29. Phantom Read 👻
Transaction:
SELECT *
FROM Sales.Orders
WHERE CustomerID = 1;


অন্য transaction একই condition-এর মধ্যে নতুন row insert করল।
দ্বিতীয়বার SELECT করলে নতুন row দেখা গেল।
এটাই Phantom Read।
SERIALIZABLE range locking-এর মাধ্যমে এটি prevent করতে পারে।





30. Blocking 🔒
এক transaction lock ধরে রেখেছে:
  
Transaction A
UPDATE
   ↓
Lock
   ↓
Long Transaction
অন্য transaction একই resource access করতে চাইলে:
  
Transaction B
   ↓
WAIT
   ↓
BLOCKED


Example

Session 1:
BEGIN TRANSACTION;

UPDATE Banking.Accounts
SET Balance = Balance + 100
WHERE AccountID = 101;



-- Transaction open রেখে দিন
Session 2:
UPDATE Banking.Accounts
SET Balance = Balance - 50
WHERE AccountID = 101;
Session 2 অপেক্ষা করতে পারে।








31. Locks 🔐
SQL Server বিভিন্ন ধরনের locks ব্যবহার করে।
Common concepts:
- 🔹 Shared Lock — Read
- 🔹 Exclusive Lock — Write
- 🔹 Update Lock — Update preparation
- 🔹 Intent Locks — Hierarchical locking intention

মূল principle:
READ  → Shared
WRITE → Exclusive






32. Deadlock ☠️
দুটি transaction একে অপরের lock-এর জন্য অপেক্ষা করলে deadlock হতে পারে।
Transaction A
Lock Account 101
      ↓
Wait for Account 102

Transaction B
Lock Account 102
      ↓
Wait for Account 101

        ↓

      DEADLOCK
SQL Server সাধারণত একটি transaction-কে victim হিসেবে rollback করে।







33. Deadlock Prevention
-- ============================================================
-- Always access resources in a consistent order
-- ============================================================
BEGIN TRANSACTION;

-- Always update smaller AccountID first
UPDATE Banking.Accounts
SET Balance = Balance - 100
WHERE AccountID = 101;

UPDATE Banking.Accounts
SET Balance = Balance + 100
WHERE AccountID = 102;

COMMIT;

দুই transaction যদি resource একই order-এ access করে, deadlock risk কমে।







34. Transaction Log 🧾
SQL Server transaction-এর changes transaction log-এ record করে।
Concept:
SQL Statement
     ↓
Transaction Log
     ↓
COMMIT
     ↓
Data becomes durable
  
Transaction log গুরুত্বপূর্ণ:
- Recovery
- Rollback
- Crash recovery
- Point-in-time restore
- HA/DR architecture








35. Implicit Transactions
SQL Server implicit transaction mode ব্যবহার করতে পারে।
-- ============================================================
-- Enable Implicit Transactions
-- ============================================================
SET IMPLICIT_TRANSACTIONS ON;
এরপর কিছু statement automatically transaction শুরু করতে পারে।
UPDATE Banking.Accounts
SET Balance = Balance + 100
WHERE AccountID = 101;

-- Explicitly commit
COMMIT;
⚠️ Production application-এ transaction behavior পরিষ্কার রাখা গুরুত্বপূর্ণ।








🟣 EXPERT
36. XACT_ABORT
Runtime error হলে transaction-এর behavior আরও predictable করতে সাহায্য করে।
-- ============================================================
-- XACT_ABORT
-- ============================================================
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

        UPDATE Banking.Accounts
        SET Balance = Balance - 500
        WHERE AccountID = 101;

        -- Other statements

    COMMIT;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;







37. XACT_STATE()
Transaction-এর বর্তমান state জানতে:
SELECT XACT_STATE();

মূল values:
 0  → No active transaction

 1  → Active and committable transaction

-1  → Active but uncommittable transaction
Production error handling-এ খুব useful।







38. Distributed Transactions
একাধিক database/server/resource-এর মধ্যে একটি transaction coordinate করতে distributed transaction প্রয়োজন হতে পারে।
  
Concept:
SQL Server A
      ↕
Distributed Transaction
      ↕
SQL Server B
এখানে complexity:
- Network failure
- Coordination
- Performance
- Recovery
- Distributed transaction infrastructure
⚠️ যেখানে সম্ভব architecture এমনভাবে design করা ভালো যাতে distributed transaction dependency কমে।









39. Transaction + Stored Procedure 
Production SQL Server application-এ খুব common pattern।
-- ============================================================
-- Transfer Stored Procedure
-- ============================================================

CREATE OR ALTER PROCEDURE Banking.TransferMoney
    @FromAccountID INT,
    @ToAccountID INT,
    @Amount DECIMAL(18,2)
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Validate amount
        IF @Amount <= 0
        BEGIN
            THROW 50001, 'Transfer amount must be greater than zero.', 1;
        END;

        -- Validate source balance
        IF NOT EXISTS
        (
            SELECT 1
            FROM Banking.Accounts
            WHERE AccountID = @FromAccountID
              AND Balance >= @Amount
        )
        BEGIN
            THROW 50002, 'Insufficient balance.', 1;
        END;

        -- Debit
        UPDATE Banking.Accounts
        SET Balance = Balance - @Amount
        WHERE AccountID = @FromAccountID;

        -- Credit
        UPDATE Banking.Accounts
        SET Balance = Balance + @Amount
        WHERE AccountID = @ToAccountID;

        -- Audit
        INSERT INTO Banking.Transfers
        (
            FromAccountID,
            ToAccountID,
            Amount,
            TransferStatus
        )
        VALUES
        (
            @FromAccountID,
            @ToAccountID,
            @Amount,
            'Completed'
        );

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;

GO
Execute:
EXEC Banking.TransferMoney
    @FromAccountID = 101,
    @ToAccountID = 102,
    @Amount = 500;







40. Transaction + Trigger
Trigger নিজে একটি independent transaction নয়; trigger সাধারণত
যে statement তাকে fire করেছে সেই transaction-এর অংশ হিসেবে execute করে।
Example:
-- ============================================================
-- Order Audit Table
-- ============================================================

CREATE TABLE Sales.OrderAudit
(
    AuditID INT IDENTITY PRIMARY KEY,
    OrderID INT,
    ActionName VARCHAR(50),
    AuditDate DATETIME2 DEFAULT SYSDATETIME()
);
GO
Trigger:
-- ============================================================
-- Audit Trigger
-- ============================================================

CREATE TRIGGER Sales.trg_Orders_Audit
ON Sales.Orders
AFTER INSERT
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO Sales.OrderAudit
    (
        OrderID,
        ActionName
    )
    SELECT
        OrderID,
        'ORDER_CREATED'
    FROM inserted;

END;
GO
যদি outer transaction rollback হয়, trigger-এর data change-ও rollback হবে।





41. Transaction + Temp Table
Temp table transaction-এর মধ্যে ব্যবহার করা যায়।
-- ============================================================
-- Transaction + Temporary Table
-- ============================================================
CREATE TABLE #OrderCalculation
(
    OrderID INT,
    TotalAmount DECIMAL(18,2)
);

BEGIN TRANSACTION;

INSERT INTO #OrderCalculation
VALUES
(1001, 1280);

UPDATE Sales.Orders
SET TotalAmount =
(
    SELECT TotalAmount
    FROM #OrderCalculation
    WHERE #OrderCalculation.OrderID = Sales.Orders.OrderID
)
WHERE OrderID = 1001;

COMMIT TRANSACTION;

DROP TABLE #OrderCalculation;





42. Transaction + ETL
Data Engineering-এ এটি অত্যন্ত গুরুত্বপূর্ণ।
ধরি:
Source
   ↓
Staging
   ↓
Validation
   ↓
Target
   ↓
Audit
Target-এর critical load transaction-এর মধ্যে রাখা যায়।
-- ============================================================
-- ETL Transaction Pattern
-- ============================================================

BEGIN TRY

    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

        -- Step 1: Load target
        INSERT INTO Sales.Orders
        (
            OrderID,
            CustomerID,
            OrderDate,
            OrderStatus,
            TotalAmount
        )
        SELECT
            OrderID,
            CustomerID,
            OrderDate,
            OrderStatus,
            TotalAmount
        FROM ETL.StagingOrders;

        -- Step 2: Audit

        -- Step 3: Validation

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;








43. Transaction Design Patterns 🏗️

  
Pattern 1 — Simple Transaction
BEGIN TRAN;

UPDATE ...;
UPDATE ...;



COMMIT;
Pattern 2 — TRY/CATCH
BEGIN TRY
    BEGIN TRAN;

    -- Work

    COMMIT;
END TRY
BEGIN CATCH

    IF @@TRANCOUNT > 0
        ROLLBACK;

    THROW;

END CATCH;



Pattern 3 — XACT_ABORT
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    -- Critical work

    COMMIT;
END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;






44. Concurrency Control
  
একই সময়ে:
User A → UPDATE Customer
User B → UPDATE Customer
User C → SELECT Customer
SQL Server-কে determine করতে হয়:
  
Who reads?
Who writes?
Who waits?
Who gets blocked?
  
এখানে গুরুত্বপূর্ণ:
- Isolation Level
- Locks
- Blocking
- Row Versioning
- Deadlock
- Indexing
- Transaction Duration








45. Deadlock Troubleshooting 🔎
Production environment-এ দেখবেন:
Deadlock Graph
     ↓
Victim
     ↓
Resources
     ↓
SQL Statements
     ↓
Indexes
     ↓
Transaction Order
Common root causes:
- 🔴 Long transactions
- 🔴 Different resource access order
- 🔴 Missing indexes
- 🔴 Excessive locking
- 🔴 Large batch updates
- 🔴 Poor transaction design





46. Performance Optimization ⚡
ভালো:
BEGIN TRAN;

UPDATE Inventory.Stock
SET QuantityOnHand = QuantityOnHand - 1
WHERE ProductID = 101;

COMMIT;



খারাপ:
BEGIN TRAN;

-- Thousands of unrelated operations

-- API call

-- User interaction

-- Complex reporting query

-- Large processing

COMMIT;


Transaction যত দীর্ঘ হবে:
Long Transaction
      ↓
Longer Locks
      ↓
More Blocking
      ↓
Higher Deadlock Risk
      ↓
Poor Performance






47. Production Best Practices ⭐⭐⭐⭐⭐
- 🟢 Short Transactions: Transaction যত ছোট সম্ভব রাখুন।
- 🟢 Clear Boundary: কোন business operation transaction হবে তা পরিষ্কার করুন।
- 🟢 TRY/CATCH: Production code-এ proper error handling রাখুন।
- 🟢 XACT_ABORT: Critical transaction-এ ব্যবহার বিবেচনা করুন।
- 🟢 XACT_STATE: Error-এর পর transaction state যাচাই করুন।
- 🟢 Consistent Order: একই resources consistent order-এ access করুন।
- 🟢 Indexes: Proper indexing blocking কমাতে সাহায্য করে।
- 🟢 No User Wait: Transaction-এর মধ্যে user input/API call রাখবেন না।
- 🟢 No Reporting: Large analytical query-এর জন্য unnecessary transaction রাখবেন না।
- 🟢 Isolation: Business requirement অনুযায়ী isolation level নির্বাচন করুন।
- 🟢 Logging: গুরুত্বপূর্ণ transaction audit করুন।
- 🟢 Testing: Blocking/deadlock/concurrency test করুন।









48. 🏆 PROJECT 47 — Bank Transfer
Business Requirement
Customer A:
Account 101 = $5,000
  
Customer B:
Account 102 = $3,000
Transfer:
$500
  
Expected:
101 → $4,500
102 → $3,500
-- ============================================================
-- PROJECT 47
-- Production-Style Bank Transfer
-- ============================================================

EXEC Banking.TransferMoney
    @FromAccountID = 101,
    @ToAccountID = 102,
    @Amount = 500;
Verify:
SELECT
    AccountID,
    AccountNumber,
    Balance
FROM Banking.Accounts;






49. PROJECT 48 — E-Commerce Order
একটি order-এর জন্য:
Create Order
     ↓
Create Order Items
     ↓
Calculate Total
     ↓
Reduce Inventory
     ↓
Commit
-- ============================================================
-- E-Commerce Order Transaction
-- ============================================================

BEGIN TRY

    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

        -- Create order
        INSERT INTO Sales.Orders
        (
            OrderID,
            CustomerID,
            OrderDate,
            OrderStatus,
            TotalAmount
        )
        VALUES
        (
            1002,
            1,
            GETDATE(),
            'Confirmed',
            1280
        );

        -- Create order item
        INSERT INTO Sales.OrderItems
        (
            OrderItemID,
            OrderID,
            ProductID,
            Quantity,
            UnitPrice
        )
        VALUES
        (
            2,
            1002,
            101,
            1,
            1200
        );

        -- Reduce inventory
        UPDATE Inventory.Stock
        SET QuantityOnHand = QuantityOnHand - 1
        WHERE ProductID = 101
          AND QuantityOnHand >= 1;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;


PROJECT 49 — Inventory Update
-- ============================================================
-- Inventory Transaction
-- ============================================================

BEGIN TRY

    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

        -- Check available stock
        IF NOT EXISTS
        (
            SELECT 1
            FROM Inventory.Stock
            WHERE ProductID = 101
              AND QuantityOnHand >= 5
        )
        BEGIN
            THROW 50010, 'Insufficient inventory.', 1;
        END;

        -- Reduce stock
        UPDATE Inventory.Stock
        SET QuantityOnHand = QuantityOnHand - 5
        WHERE ProductID = 101;

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;





PROJECT 50 — ETL Transaction
Real-world ETL:
CSV/API
  ↓
Staging
  ↓
Validation
  ↓
Target
  ↓
Audit
Critical target loading:
-- ============================================================
-- ETL Transaction
-- ============================================================

BEGIN TRY

    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

        -- Load validated data
        -- Update target tables
        -- Insert ETL audit record

    COMMIT TRANSACTION;

END TRY

BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    -- Log error if required

    THROW;

END CATCH;



PROJECT 51 — Production Transaction Project
শেষ project-এ সব concept একসাথে:
                    TransactionsDB
                          │
          ┌───────────────┼────────────────┐
          ↓               ↓                ↓
       Banking          Sales          Inventory
          │               │                │
      Accounts          Orders          Products
          │               │                │
      Transfers       OrderItems         Stock
          │               │                │
          └───────────────┼────────────────┘
                          ↓
                    TRANSACTION
                          ↓
             ┌────────────┴────────────┐
             ↓                         ↓
          SUCCESS                    ERROR
             ↓                         ↓
          COMMIT                   ROLLBACK
             │                         │
             ↓                         ↓
        Data Saved                Changes Undone
Production Scenario
Customer order করলে:
1. Validate Customer
        ↓
2. Validate Product
        ↓
3. Check Inventory
        ↓
4. Create Order
        ↓
5. Create Order Items
        ↓
6. Reduce Inventory
        ↓
7. Update Customer/Payment Status
        ↓
8. Insert Audit Record
        ↓
9. COMMIT


  
যেকোনো critical step fail:
ERROR
  ↓
CATCH
  ↓
XACT_STATE()
  ↓
ROLLBACK
  ↓
THROW








