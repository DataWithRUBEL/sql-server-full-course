🟢 BEGINNER
1. Error Handling কী?
Error Handling হলো SQL Server-এ কোনো statement, query, transaction, stored procedure বা ETL process failure করলে সেই error:
- detect করা
- বুঝতে পারা
- log করা
- transaction rollback করা
- প্রয়োজন হলে error আবার caller-এর কাছে পাঠানো
- pipeline/process safely stop বা recover করা
—এই পুরো process।

  
Simple Example
-- =========================================================
-- Intentional runtime error
-- Division by zero
-- =========================================================

SELECT
    100 / 0 AS Result;
SQL Server error দেবে:
Divide by zero error encountered.
Error Handling ছাড়া application/ETL process হঠাৎ fail করতে পারে।







2. কেন Error Handling দরকার?
📊 Data Analyst
- Query failure বুঝতে
- Data quality issue detect করতে
- Reporting process reliable করতে
- Divide-by-zero handle করতে
- Conversion error handle করতে
  
⚙️ Data Engineer
- ETL failure handle করতে
- Transaction rollback করতে
- Batch failure log করতে
- Pipeline monitoring করতে
- Retry করতে
- Production incident troubleshoot করতে 
  
🏢 Real Business Example
একটি order processing system:
Customer
   ↓
Order
   ↓
OrderItem
   ↓
Payment
   ↓
Inventory Update
Inventory update fail করলে আগের order operation-এর কিছু অংশ commit হয়ে গেলে data inconsistency হতে পারে।

  
সেখানে:
TRY
 ↓
Process Order
 ↓
Error?
 ↓
CATCH
 ↓
ROLLBACK
 ↓
Log Error
 ↓
THROW








3. SQL Server Error Types
SQL Server-এ practicalভাবে নিচের error categories বুঝতে হবে:
  
Error	                          Example
Syntax Error	                  ভুল SQL syntax
Runtime Error	                  Divide by zero
Conversion Error	              'ABC' → INT
Constraint Error	              Duplicate PK
Foreign Key Error	              Invalid CustomerID
Logical Error	                  ভুল business calculation
Compile Error	                  Object/column resolution issue
Deadlock	                     দুই transaction একে অপরকে block
Timeout	                       Query নির্দিষ্ট সময়ে শেষ না হওয়া
Dynamic SQL Error	             Dynamic SQL execution failure







4. Syntax Error
Syntax ভুল হলে SQL Server query execute করতে পারে না।
-- =========================================================
-- Intentional syntax error
-- Missing FROM keyword
-- =========================================================

SELECT *
sales.Customers;


Correct:
-- =========================================================
-- Correct syntax
-- =========================================================

SELECT *
FROM sales.Customers;

গুরুত্বপূর্ণ
Syntax error সাধারণত TRY...CATCH দিয়ে catch করা যায় না, কারণ query compilation stage-এই সমস্যা হতে পারে।






5. Runtime Error
Query শুরু হওয়ার পর execution-এর সময় error হলে সেটি runtime error।
-- =========================================================
-- Runtime error example
-- Division by zero
-- =========================================================

SELECT 100 / 0;
এ ধরনের error TRY...CATCH দিয়ে handle করা যায়।







6. Logical Error
সব error SQL Server error message তৈরি করে না।
উদাহরণ:
-- =========================================================
-- Technically valid SQL
-- But business logic is incorrect
-- =========================================================
SELECT
    SUM(TotalAmount) / COUNT(CustomerID)
FROM sales.Orders;


ধরা যাক business requirement ছিল:
Average order value = Total Sales / Number of Orders

কিন্তু query-তে CustomerID count করা হয়েছে।
SQL Server error দেবে না।
কিন্তু result ভুল।

  
⭐ Important
Error Handling ≠ Business Logic Validation

দুটো আলাদা বিষয়।








7. Compile Error
SQL Server query execution-এর আগে query compile করে।
Compile/compilation-related সমস্যার উদাহরণ:
-- =========================================================
-- Invalid object reference
-- =========================================================
SELECT *
FROM sales.DoesNotExist;

এ ধরনের error-এর handling behavior execution context-এর ওপর নির্ভর করে।
বিশেষ করে একই scope-এ compilation error সাধারণ TRY...CATCH দিয়ে সবসময় ধরা যায় না।





8. System Errors
SQL Server-এর predefined error numbers আছে।
  
যেমন:
2627  → Duplicate key
547   → Constraint violation
1205  → Deadlock victim
8134  → Divide by zero
245   → Conversion failed
  
Error handling-এর সময় error number খুব গুরুত্বপূর্ণ।







9.Error Message পড়া
Error message-এ সাধারণত পাওয়া যায়:
Msg 8134
Level 16
State 1
Line 5
Divide by zero error encountered.

  
এখানে:
Part	           Meaning
Msg	             Error Number
Level	           Severity
State	           Error State
Line	           Error Line
Message	         বিস্তারিত description







10. TRY...CATCH Fundamentals
SQL Server-এর primary error handling mechanism:
BEGIN TRY

    -- Risky code

END TRY
BEGIN CATCH

    -- Error handling code

END CATCH;
Basic Example
-- =========================================================
-- Basic TRY...CATCH example
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;








🟡 INTERMEDIATE
11. BEGIN TRY
BEGIN TRY block-এর ভিতরে risky SQL রাখা হয়।
-- =========================================================
-- BEGIN TRY contains statements that may fail
-- =========================================================
BEGIN TRY

    INSERT INTO sales.Customers
    (
        CustomerName,
        Email,
        Country
    )
    VALUES
    (
        'New Customer',
        'new@example.com',
        'Kuwait'
    );

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS ErrorMessage;

END CATCH;







12. BEGIN CATCH
Error হলে control CATCH block-এ যায়।
-- =========================================================
-- CATCH handles the error
-- =========================================================
BEGIN TRY

    SELECT 10 / 0;

END TRY
BEGIN CATCH

    SELECT
        'An error occurred' AS Status,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;





13. ERROR_NUMBER()
কোন error হয়েছে সেটা identify করতে ব্যবহার হয়।
-- =========================================================
-- Return SQL Server error number
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT ERROR_NUMBER() AS ErrorNumber;

END CATCH;
Expected:
  
8134






14. ERROR_MESSAGE()
Human-readable error message।
-- =========================================================
-- Return detailed error message
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT ERROR_MESSAGE() AS ErrorMessage;

END CATCH;




15. ERROR_SEVERITY()
Error-এর severity level।
-- =========================================================
-- Return error severity
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT ERROR_SEVERITY() AS ErrorSeverity;

END CATCH;







16. ERROR_STATE()
Error-এর state information।
-- =========================================================
-- Return error state
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT ERROR_STATE() AS ErrorState;

END CATCH;





17. ERROR_LINE()
কোন line-এ error হয়েছে।
-- =========================================================
-- Return line number where error occurred
-- =========================================================
BEGIN TRY

    SELECT 1 AS Step1;

    SELECT 100 / 0 AS Step2;

END TRY
BEGIN CATCH

    SELECT ERROR_LINE() AS ErrorLine;

END CATCH;






18. ERROR_PROCEDURE()
কোন stored procedure থেকে error এসেছে।
-- =========================================================
-- Return stored procedure name
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT ERROR_PROCEDURE() AS ErrorProcedure;

END CATCH;
Ad-hoc query হলে এটি NULL হতে পারে।






19. Error Functions Together
Production logging-এর জন্য একসাথে ব্যবহার করা হয়।
-- =========================================================
-- Capture all important error information
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_LINE() AS ErrorLine,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;






20. THROW
Modern SQL Server error handling-এর জন্য THROW অত্যন্ত গুরুত্বপূর্ণ।
Basic Syntax
-- =========================================================
-- THROW syntax
-- =========================================================

THROW;
Existing error rethrow করার ক্ষেত্রে:
-- =========================================================
-- Rethrow the original error
-- =========================================================
BEGIN TRY

    SELECT 100 / 0;

END TRY
BEGIN CATCH

    SELECT
        ERROR_MESSAGE() AS LoggedMessage;

    THROW;

END CATCH;


এখানে:
TRY
 ↓
Error
 ↓
CATCH
 ↓
Log
 ↓
THROW
 ↓
Caller gets original error





21. RAISERROR
RAISERROR custom error message generate করতে পারে।
-- =========================================================
-- Generate a custom application error
-- =========================================================
RAISERROR
(
    'Customer validation failed.',
    16,
    1
);
আরও practical:
-- =========================================================
-- Validate order amount
-- =========================================================

DECLARE @TotalAmount DECIMAL(12,2) = -100;

IF @TotalAmount < 0
BEGIN

    RAISERROR
    (
        'Order amount cannot be negative.',
        16,
        1
    );

END;







22. THROW vs RAISERROR
  
Feature	                              THROW	            RAISERROR
Modern approach	                      ✅	              ⚠️ Legacy
Rethrow original error                ✅                ❌
Custom error	                        ✅	              ✅
Preserves original error	            ✅	              ❌
Recommended for new code	            ⭐⭐⭐⭐⭐	     ⭐⭐⭐
Formatting flexibility	              Limited	          More
Transaction-friendly modern pattern	  ✅	              ⚠️


Production Recommendation
নতুন SQL Server development-এ সাধারণত:
TRY
 ↓
CATCH
 ↓
Log
 ↓
THROW
pattern ব্যবহার করুন।









🔴 ADVANCED
23. TRY...CATCH + Transactions
এটি Data Engineer-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
ধরি order creation-এর সময়:
  
1. Order insert
2. OrderItem insert
3. Inventory update
এর মধ্যে #3 fail করল।
  
তাহলে #1 এবং #2 commit হয়ে যাওয়া উচিত নয়।
-- =========================================================
-- TRY...CATCH with transaction
-- =========================================================

BEGIN TRY

    BEGIN TRANSACTION;

    -- Insert order
    INSERT INTO sales.Orders
    (
        CustomerID,
        OrderDate,
        OrderStatus,
        TotalAmount
    )
    VALUES
    (
        1,
        CAST(GETDATE() AS DATE),
        'Pending',
        850
    );

    -- Get generated OrderID
    DECLARE @OrderID INT = SCOPE_IDENTITY();

    -- Insert order item
    INSERT INTO sales.OrderItems
    (
        OrderID,
        ProductID,
        Quantity,
        UnitPrice
    )
    VALUES
    (
        @OrderID,
        1,
        1,
        850
    );

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;








24. XACT_STATE()
  
XACT_STATE() transaction-এর বর্তমান অবস্থা জানায়।
Value	          Meaning
1	              Transaction active এবং committable
0	              কোনো transaction নেই
-1	            Transaction active কিন্তু uncommittable


Practical Pattern
-- =========================================================
-- Check transaction state before rollback
-- =========================================================

IF XACT_STATE() <> 0
BEGIN
    ROLLBACK TRANSACTION;
END;






25. @@TRANCOUNT
কতটি active transaction nesting level আছে সেটা দেখতে:
-- =========================================================
-- Check transaction count
-- =========================================================

SELECT @@TRANCOUNT AS TransactionCount;
Example:
-- =========================================================
-- Demonstrate transaction nesting count
-- =========================================================

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS AfterFirstTransaction;

BEGIN TRANSACTION;

SELECT @@TRANCOUNT AS AfterSecondTransaction;

ROLLBACK TRANSACTION;

SELECT @@TRANCOUNT AS AfterRollback;
⭐ Important
SQL Server-এর nested transactions বাস্তবে independent transaction নয়।
COMMIT outer transaction-এর পুরো কাজ শেষ না হওয়া পর্যন্ত transaction পুরোপুরি শেষ হয় না।






26. XACT_ABORT
XACT_ABORT ON দিলে অনেক runtime error হলে পুরো transaction automatically rollback করার behavior পাওয়া যায়।
-- =========================================================
-- Automatically abort transaction on qualifying runtime errors
-- =========================================================

SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO sales.Orders
    (
        CustomerID,
        OrderDate,
        OrderStatus,
        TotalAmount
    )
    VALUES
    (
        1,
        GETDATE(),
        'Pending',
        500
    );

    SELECT 100 / 0;

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    THROW;

END CATCH;


⭐ Production Pattern
অনেক transactional stored procedure-এ:
SET NOCOUNT ON;
SET XACT_ABORT ON;
এর সাথে:
BEGIN TRY
    BEGIN TRANSACTION;

    -- business operations

    COMMIT;
END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;
খুব কার্যকর pattern।






27. Rollback Strategy
Error হলে সবসময় blind ROLLBACK না করে transaction state বুঝে কাজ করা ভালো।
-- =========================================================
-- Safe rollback strategy
-- =========================================================

IF XACT_STATE() = -1
BEGIN
    -- Transaction is uncommittable
    ROLLBACK TRANSACTION;
END
ELSE IF XACT_STATE() = 1
BEGIN
    -- Transaction is still committable
    ROLLBACK TRANSACTION;
END;
Simplified:
IF XACT_STATE() <> 0
    ROLLBACK TRANSACTION;







28. Nested Transactions + Errors
-- =========================================================
-- Demonstrate nested transaction behavior
-- =========================================================

BEGIN TRY

    BEGIN TRANSACTION;

    INSERT INTO sales.Orders
    (
        CustomerID,
        OrderDate,
        OrderStatus,
        TotalAmount
    )
    VALUES
    (
        1,
        GETDATE(),
        'Pending',
        100
    );

    BEGIN TRANSACTION;

    INSERT INTO sales.OrderItems
    (
        OrderID,
        ProductID,
        Quantity,
        UnitPrice
    )
    VALUES
    (
        999999,
        1,
        1,
        850
    );

    COMMIT;
    COMMIT;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    THROW;

END CATCH;
এখানে invalid OrderID foreign key error তৈরি করবে।






29. SAVE TRANSACTION
Partial rollback-এর জন্য savepoint ব্যবহার করা যায়।
-- =========================================================
-- SAVE TRANSACTION creates a rollback point
-- =========================================================

BEGIN TRANSACTION;

INSERT INTO sales.Orders
(
    CustomerID,
    OrderDate,
    OrderStatus,
    TotalAmount
)
VALUES
(
    1,
    GETDATE(),
    'Pending',
    500
);

SAVE TRANSACTION OrderCreated;

-- More operations...

-- Roll back only to savepoint
ROLLBACK TRANSACTION OrderCreated;

COMMIT TRANSACTION;
Important
যদি transaction uncommittable (XACT_STATE() = -1) হয়, 
savepoint rollback করা যায় না; তখন পুরো transaction rollback করতে হয়।








30. Constraint Errors
Primary Key
-- =========================================================
-- Duplicate primary key example
-- =========================================================

INSERT INTO sales.Customers
(
    CustomerID,
    CustomerName,
    Country
)
VALUES
(
    1,
    'Duplicate Customer',
    'Kuwait'
);
কারণ CustomerID = 1 already exists।



Foreign Key
-- =========================================================
-- Foreign key violation
-- CustomerID 999999 does not exist
-- =========================================================

BEGIN TRY

    INSERT INTO sales.Orders
    (
        CustomerID,
        OrderDate,
        OrderStatus,
        TotalAmount
    )
    VALUES
    (
        999999,
        GETDATE(),
        'Pending',
        500
    );

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;


CHECK Constraint
-- =========================================================
-- CHECK constraint violation
-- Quantity must be greater than zero
-- =========================================================

BEGIN TRY

    INSERT INTO sales.OrderItems
    (
        OrderID,
        ProductID,
        Quantity,
        UnitPrice
    )
    VALUES
    (
        1001,
        1,
        -5,
        850
    );

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;







31. Conversion Errors
-- =========================================================
-- Conversion error example
-- =========================================================
BEGIN TRY

    DECLARE @Quantity INT;

    SET @Quantity = CAST('ABC' AS INT);

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

END CATCH;
Better Data Engineering Approach
ETL-এ raw data থাকলে:
-- =========================================================
-- TRY_CAST prevents conversion failure
-- =========================================================

SELECT
    TRY_CAST(Quantity AS INT) AS Quantity
FROM etl.StagingOrders;
TRY_CAST() conversion failure হলে NULL দেয়।






32. Divide-by-Zero
❌ Dangerous
-- =========================================================
-- Division by zero
-- =========================================================

SELECT
    SUM(TotalAmount) / COUNT(CustomerID)
FROM sales.Orders;
যদি denominator zero হয় সমস্যা হতে পারে।


  
✅ NULLIF
-- =========================================================
-- Safely prevent divide-by-zero
-- =========================================================

SELECT
    SUM(TotalAmount)
    / NULLIF(COUNT(CustomerID), 0) AS AverageValue
FROM sales.Orders;


Important
সব error-এর জন্য TRY...CATCH দরকার হয় না।
Data analysis-এর ক্ষেত্রে preventive SQL design অনেক সময় ভালো:
NULLIF()
TRY_CAST()
TRY_CONVERT()
CASE
COALESCE()







33. Deadlock Errors
SQL Server deadlock example:
Transaction A
    ↓
Locks Customer
    ↓
Wants Order

Transaction B
    ↓
Locks Order
    ↓
Wants Customer
দুই transaction একে অপরের resource-এর জন্য অপেক্ষা করলে deadlock হতে পারে।
SQL Server সাধারণত একজন transaction-কে victim হিসেবে terminate করে।

  
Deadlock error number:
1205


Catch
-- =========================================================
-- Catch deadlock victim error
-- =========================================================

BEGIN TRY

    -- Transactional work

END TRY
BEGIN CATCH

    IF ERROR_NUMBER() = 1205
    BEGIN

        -- Deadlock detected
        PRINT 'Deadlock occurred. Retry may be required.';

    END;

    THROW;

END CATCH;








34. Timeout Errors
Timeout অনেক সময় SQL Server engine error হিসেবে নয়, client/application/driver-side timeout হিসেবে দেখা যায়।

  
যেমন:
Application
   ↓
Execute SQL
   ↓
Query running too long
   ↓
Client timeout


  
Data Engineer-এর করণীয়
- Query plan check
- Missing/inefficient indexes
- Blocking check
- Long-running transaction check
- Query optimization
- Batch size reduce
- Appropriate command timeout configuration
  
⭐ Important
Timeout handling শুধু TRY...CATCH দিয়ে solve হয় না।







35. Dynamic SQL Errors
Dynamic SQL-এর জন্য sp_executesql ব্যবহার করা ভালো।
-- =========================================================
-- Dynamic SQL with TRY...CATCH
-- =========================================================

BEGIN TRY

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        SELECT *
        FROM sales.Customers
        WHERE CustomerID = @CustomerID;
    ';

    EXEC sys.sp_executesql
        @SQL,
        N'@CustomerID INT',
        @CustomerID = 1;

END TRY
BEGIN CATCH

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

    THROW;

END CATCH;


⭐ Best Practice
Dynamic SQL-এ user input directly concatenate না করে parameterization ব্যবহার করুন।





  


36. 🟣 EXPERT
Stored Procedure Error Handling
Production SQL Server development-এ একটি standard pattern:
-- =========================================================
-- Production-style stored procedure
-- Create a customer safely
-- =========================================================

CREATE OR ALTER PROCEDURE sales.usp_CreateCustomer
(
    @CustomerName VARCHAR(100),
    @Email VARCHAR(150),
    @Country VARCHAR(50)
)
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        INSERT INTO sales.Customers
        (
            CustomerName,
            Email,
            Country
        )
        VALUES
        (
            @CustomerName,
            @Email,
            @Country
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
-- =========================================================
-- Execute stored procedure
-- =========================================================

EXEC sales.usp_CreateCustomer
    @CustomerName = 'New Retailer',
    @Email = 'retailer@example.com',
    @Country = 'Kuwait';








37. Centralized Error Logging
Production system-এ শুধু:
PRINT ERROR_MESSAGE();
যথেষ্ট নয়।


আমাদের:
ErrorLog
table-এ error save করতে হবে।






38. Error Log Table
আমরা আগে তৈরি করেছি:
etl.ErrorLog
এখন manually error log করি।
  
-- =========================================================
-- Insert error information into centralized error log
-- =========================================================

INSERT INTO etl.ErrorLog
(
    ErrorNumber,
    ErrorSeverity,
    ErrorState,
    ErrorProcedure,
    ErrorLine,
    ErrorMessage,
    ErrorCategory,
    ErrorSource
)
VALUES
(
    ERROR_NUMBER(),
    ERROR_SEVERITY(),
    ERROR_STATE(),
    ERROR_PROCEDURE(),
    ERROR_LINE(),
    ERROR_MESSAGE(),
    'DATABASE',
    'Sales Process'
);
⚠️ এই statement অবশ্যই CATCH block-এর ভিতরে থাকা উচিত, কারণ ERROR_*() functions error context-এর সাথে কাজ করে।








39. Error ID / Batch ID
ETL system-এ শুধু error message যথেষ্ট নয়।
আমাদের দরকার:
BatchID
ErrorLogID
PipelineName
Timestamp
ErrorNumber
ErrorMessage
Example
BatchID = 20260820001

ErrorLogID = 55
ErrorNumber = 245
ErrorCategory = DATA_CONVERSION
এতে একটি পুরো ETL run-এর সব error trace করা যায়।









40. ETL Error Handling
একটি realistic ETL flow:
Source CSV/API
      ↓
Staging
      ↓
Validation
      ↓
Transformation
      ↓
Target
      ↓
Batch Log
      ↓
Error Log







41. Data Quality Errors
সব data issue SQL Server runtime error নয়।
Example:
CustomerID = NULL
Quantity = -5
UnitPrice = 'ABC'
OrderDate = '2026-99-99'
এসব data quality errors।
  
Data Validation
-- =========================================================
-- Identify invalid quantity values
-- =========================================================

SELECT *
FROM etl.StagingOrders
WHERE TRY_CAST(Quantity AS INT) IS NULL;
Negative quantity:
  
-- =========================================================
-- Identify negative quantities
-- =========================================================

SELECT *
FROM etl.StagingOrders
WHERE TRY_CAST(Quantity AS INT) <= 0;






42. Error Classification
  
Production framework-এ error category রাখা ভালো।
  
উদাহরণ:
  
Category	                     Meaning
DATA_QUALITY	                 Invalid source data
CONVERSION	                   Data type conversion
CONSTRAINT	                   PK/FK/Check
BUSINESS	                     Business rule
DATABASE	                     SQL Server error
DEADLOCK	                     Transaction deadlock
TIMEOUT	                       Execution timeout
SYSTEM	                       Infrastructure/system
UNKNOWN	                       Unclassified







43. Retry Strategy
সব error retry করা যাবে না।

  
Retry করা যেতে পারে
- Deadlock
- Temporary network issue
- Temporary resource issue
- Transient infrastructure failure

  
Retry করা উচিত নয়
- Invalid CustomerID
- Duplicate business key
- Invalid date
- Invalid data type
- Business rule violation

  
Pattern
Attempt 1
   ↓
Failed
   ↓
Retry
   ↓
Attempt 2
   ↓
Failed
   ↓
Retry
   ↓
Attempt 3
   ↓
Failed
   ↓
Log + Fail








44. Deadlock Retry
Deadlock-এর জন্য application/ETL layer-এ limited retry করা যায়।
Concept:
TRY
 ↓
Execute transaction
 ↓
Error 1205?
 ↓ YES
Wait
 ↓
Retry


  
SQL Server-side loop-এর একটি simplified example:
-- =========================================================
-- Simple deadlock retry pattern
-- Production systems should use controlled retry limits
-- =========================================================

DECLARE @RetryCount INT = 0;
DECLARE @MaxRetries INT = 3;

WHILE @RetryCount < @MaxRetries
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Transactional work goes here

        COMMIT TRANSACTION;

        BREAK;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        IF ERROR_NUMBER() = 1205
        BEGIN

            SET @RetryCount += 1;

            WAITFOR DELAY '00:00:02';

        END
        ELSE
        BEGIN

            THROW;

        END;

    END CATCH;

END;
⚠️ Production-এ retry count, delay, idempotency এবং observability carefully design করতে হবে।





45. Transaction Recovery
Transaction failure হলে লক্ষ্য:
Consistency
+
Atomicity
+
Recoverability

  
Example:
-- =========================================================
-- Transaction recovery pattern
-- =========================================================

CREATE OR ALTER PROCEDURE sales.usp_CreateOrder
(
    @CustomerID INT,
    @ProductID INT,
    @Quantity INT
)
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Create order
        INSERT INTO sales.Orders
        (
            CustomerID,
            OrderDate,
            OrderStatus,
            TotalAmount
        )
        VALUES
        (
            @CustomerID,
            CAST(GETDATE() AS DATE),
            'Pending',
            0
        );

        DECLARE @OrderID INT = SCOPE_IDENTITY();

        -- Create order item
        INSERT INTO sales.OrderItems
        (
            OrderID,
            ProductID,
            Quantity,
            UnitPrice
        )
        SELECT
            @OrderID,
            ProductID,
            @Quantity,
            UnitPrice
        FROM sales.Products
        WHERE ProductID = @ProductID;

        -- Update order total
        UPDATE O
        SET TotalAmount =
        (
            SELECT SUM(Quantity * UnitPrice)
            FROM sales.OrderItems
            WHERE OrderID = @OrderID
        )
        FROM sales.Orders AS O
        WHERE O.OrderID = @OrderID;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
GO






46. Error Monitoring
Error log থেকে monitoring report তৈরি করা যায়।
  
  
-- =========================================================
-- Monitor errors by category
-- =========================================================

SELECT
    ErrorCategory,
    COUNT(*) AS ErrorCount
FROM etl.ErrorLog
GROUP BY ErrorCategory
ORDER BY ErrorCount DESC;
Error trend

  
-- =========================================================
-- Daily error trend
-- =========================================================

SELECT
    CAST(ErrorDateTime AS DATE) AS ErrorDate,
    COUNT(*) AS ErrorCount
FROM etl.ErrorLog
GROUP BY CAST(ErrorDateTime AS DATE)
ORDER BY ErrorDate;



Most common errors
-- =========================================================
-- Find most frequent SQL Server errors
-- =========================================================

SELECT
    ErrorNumber,
    ErrorMessage,
    COUNT(*) AS ErrorCount
FROM etl.ErrorLog
GROUP BY
    ErrorNumber,
    ErrorMessage
ORDER BY ErrorCount DESC;










47. Production Standards 🏆
Production SQL Server Error Handling-এর জন্য এই pattern খুব গুরুত্বপূর্ণ:
  
-- =========================================================
-- Production-standard transaction/error-handling template
-- =========================================================

CREATE OR ALTER PROCEDURE dbo.usp_ProductionTemplate
AS
BEGIN

    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- ================================================
        -- Business logic
        -- ================================================

        -- INSERT
        -- UPDATE
        -- DELETE
        -- MERGE carefully where appropriate

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        -- ================================================
        -- Rollback failed transaction
        -- ================================================

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        -- ================================================
        -- Log error
        -- ================================================

        INSERT INTO etl.ErrorLog
        (
            ErrorNumber,
            ErrorSeverity,
            ErrorState,
            ErrorProcedure,
            ErrorLine,
            ErrorMessage,
            ErrorCategory,
            ErrorSource
        )
        VALUES
        (
            ERROR_NUMBER(),
            ERROR_SEVERITY(),
            ERROR_STATE(),
            ERROR_PROCEDURE(),
            ERROR_LINE(),
            ERROR_MESSAGE(),
            'DATABASE',
            'ProductionProcedure'
        );

        -- ================================================
        -- Return original error to caller
        -- ================================================

        THROW;

    END CATCH;

END;
GO





48. Basic Error Project
Project: Customer Registration
Requirement
  
Customer insert করার সময়:
- CustomerName required
- Country required
- Email validation
- Duplicate customer detect
- Error log
- Original error return


Flow
Input
 ↓
Validation
 ↓
TRY
 ↓
INSERT
 ↓
Success



Error:
INSERT
 ↓
Error
 ↓
CATCH
 ↓
ErrorLog
 ↓
THROW







49. Transaction Error Project
Project: Order Processing
একটি order process করবে:
Create Order
      ↓
Create OrderItem
      ↓
Calculate Total
      ↓
Update Inventory
      ↓
COMMIT
যেকোনো operation fail হলে:
ROLLBACK
   ↓
ErrorLog
   ↓
THROW
Practice
-- =========================================================
-- Test transaction failure
-- Invalid CustomerID intentionally used
-- =========================================================

BEGIN TRY

    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    INSERT INTO sales.Orders
    (
        CustomerID,
        OrderDate,
        OrderStatus,
        TotalAmount
    )
    VALUES
    (
        999999,
        GETDATE(),
        'Pending',
        500
    );

    COMMIT;

END TRY
BEGIN CATCH

    IF XACT_STATE() <> 0
        ROLLBACK;

    SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_MESSAGE() AS ErrorMessage;

    THROW;

END CATCH;







50. Stored Procedure Project
Project: Production Order API
  
Stored procedure:
sales.usp_CreateOrder
Parameters:
CustomerID
ProductID
Quantity

  
Process:
Validate Customer
       ↓
Validate Product
       ↓
Validate Quantity
       ↓
BEGIN TRANSACTION
       ↓
Create Order
       ↓
Create OrderItem
       ↓
Calculate Total
       ↓
Commit
       ↓
Success

  
Failure:
CATCH
 ↓
Rollback
 ↓
Log
 ↓
THROW







51. 51. ETL Error Logging Project
এটি Data Engineer-এর জন্য সবচেয়ে গুরুত্বপূর্ণ project।

  
ETL Architecture
CSV / API
    ↓
etl.StagingOrders
    ↓
Data Validation
    ↓
TRY_CAST / TRY_CONVERT
    ↓
Valid Data
    ↓
Production Tables


  
Invalid data:
Invalid Record
      ↓
Error Classification
      ↓
etl.ErrorLog
      ↓
Batch Monitoring


  
Batch শুরু
-- =========================================================
-- Start ETL batch
-- =========================================================

INSERT INTO etl.BatchLog
(
    PipelineName,
    StartTime,
    Status
)
VALUES
(
    'SalesOrderPipeline',
    SYSDATETIME(),
    'RUNNING'
);

DECLARE @BatchID BIGINT = SCOPE_IDENTITY();




ETL Error Capture
-- =========================================================
-- ETL error handling example
-- =========================================================

BEGIN TRY

    -- ================================================
    -- Transform and load valid records
    -- ================================================

    INSERT INTO sales.OrderItems
    (
        OrderID,
        ProductID,
        Quantity,
        UnitPrice
    )
    SELECT
        TRY_CAST(CustomerID AS INT),
        TRY_CAST(ProductID AS INT),
        TRY_CAST(Quantity AS INT),
        TRY_CAST(UnitPrice AS DECIMAL(12,2))
    FROM etl.StagingOrders;

END TRY
BEGIN CATCH

    -- ================================================
    -- Log ETL failure
    -- ================================================

    INSERT INTO etl.ErrorLog
    (
        BatchID,
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage,
        ErrorCategory,
        ErrorSource
    )
    VALUES
    (
        @BatchID,
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        'ETL',
        'SalesOrderPipeline'
    );

    -- ================================================
    -- Mark batch as failed
    -- ================================================

    UPDATE etl.BatchLog
    SET
        EndTime = SYSDATETIME(),
        Status = 'FAILED',
        ErrorCount = ErrorCount + 1
    WHERE BatchID = @BatchID;

    THROW;

END CATCH;








52. Production Error Framework
এটাই পুরো Error Handling-এর capstone project।
🏢 Architecture
                    SOURCE
                      │
              CSV / API / Database
                      │
                      ▼
               ┌───────────────┐
               │   STAGING     │
               └───────┬───────┘
                       │
                       ▼
                DATA VALIDATION
                       │
             ┌─────────┴─────────┐
             │                   │
          VALID               INVALID
             │                   │
             ▼                   ▼
       TRANSFORMATION       ERROR LOG
             │                   │
             ▼                   │
       BUSINESS LOGIC            │
             │                   │
             ▼                   │
       TRANSACTION               │
             │                   │
       ┌─────┴─────┐             │
       │           │             │
    SUCCESS       ERROR          │
       │           │             │
       ▼           ▼             │
    COMMIT       ROLLBACK         │
       │           │             │
       │           └──────┬──────┘
       │                  │
       ▼                  ▼
   BATCH LOG          MONITORING







53. Complete Error Handling Flow
একজন SQL Server Data Analyst + Data Engineer হিসেবে পুরো বিষয়টি এভাবে চিন্তা করবেন:
                    ERROR
                      │
          ┌───────────┴───────────┐
          │                       │
      Preventable             Unexpected
          │                       │
          ▼                       ▼
 NULLIF()                  TRY...CATCH
 TRY_CAST()                    │
 CASE                          ▼
 Validation                 CATCH
                                  │
                  ┌───────────────┼───────────────┐
                  │               │               │
               Capture          Log            Recover
                  │               │               │
             ERROR_*()       ErrorLog        ROLLBACK
                                                  │
                                                  ▼
                                                THROW









54. সবচেয়ে গুরুত্বপূর্ণ Production Rules
1️⃣ Error Prevent করুন
-- Instead of allowing division by zero
SELECT
    TotalAmount / NULLIF(OrderCount, 0)
FROM ...

  
2️⃣ Unexpected Error Catch করুন
BEGIN TRY
    -- risky operation
END TRY
BEGIN CATCH
    -- handle error
END CATCH;


3️⃣ Transaction থাকলে State Check করুন
IF XACT_STATE() <> 0
    ROLLBACK;


4️⃣ Original Error হারাবেন না
THROW;


5️⃣ Production-এ Error Log রাখুন
ErrorLogID
BatchID
ErrorNumber
ErrorMessage
ErrorProcedure
ErrorLine
ErrorDateTime
ErrorCategory
ErrorSource

  
6️⃣ সব Error Retry করবেন না
Deadlock        → Retry possible
Transient error → Retry possible

Bad data        → Fix data
FK violation    → Fix source/business logic
Conversion      → Fix data
Business error  → Fix business rule

  
7️⃣ Error Handling ≠ Error Hiding
❌ খারাপ:
BEGIN CATCH

    PRINT 'Something went wrong';

END CATCH;
কারণ production system জানতে পারবে না আসলে কী হয়েছে।
✅ ভালো:
BEGIN CATCH

    -- Log detailed error
    INSERT INTO etl.ErrorLog (...);

    -- Return original error
    THROW;

END CATCH;








55. Final Mental Model
SQL Server Error Handling-এর মূল বিষয়গুলো মনে রাখার সবচেয়ে সহজ formula:
PREVENT
   ↓
DETECT
   ↓
CAPTURE
   ↓
CLASSIFY
   ↓
LOG
   ↓
ROLLBACK / RECOVER
   ↓
RETRY WHEN APPROPRIATE
   ↓
THROW
   ↓
MONITOR


  
আর Production SQL Server Data Engineering-এ সবচেয়ে গুরুত্বপূর্ণ core pattern:
-- =========================================================
-- MASTER ERROR HANDLING PATTERN
-- =========================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- ================================================
    -- Business / ETL operations
    -- ================================================

    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    -- ================================================
    -- Recover transaction
    -- ================================================

    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    -- ================================================
    -- Capture and log error
    -- ================================================

    INSERT INTO etl.ErrorLog
    (
        ErrorNumber,
        ErrorSeverity,
        ErrorState,
        ErrorProcedure,
        ErrorLine,
        ErrorMessage,
        ErrorCategory,
        ErrorSource
    )
    VALUES
    (
        ERROR_NUMBER(),
        ERROR_SEVERITY(),
        ERROR_STATE(),
        ERROR_PROCEDURE(),
        ERROR_LINE(),
        ERROR_MESSAGE(),
        'DATABASE',
        'ProductionProcess'
    );

    -- ================================================
    -- Re-throw original error
    -- ================================================

    THROW;

END CATCH;









