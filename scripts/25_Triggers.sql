-- Project Architecture
/* TriggerDB
│
├── dbo
│   ├── Customers
│   ├── Categories
│   ├── Products
│   ├── Departments
│   ├── Employees
│   ├── Orders
│   ├── OrderItems
│   └── Inventory
│
├── audit
│   ├── CustomerAudit
│   ├── ProductPriceHistory
│   ├── InventoryAudit
│   ├── EmployeeAudit
│   └── DDLAudit
│
└── Trigger Examples
    ├── DML Trigger
    ├── DDL Trigger
    └── LOGON Trigger concepts */



🟢 BEGINNER
1. Trigger কী?
Trigger হলো SQL Server-এর একটি special database object, 
যেটি কোনো নির্দিষ্ট database event ঘটলে automatically execute হয়।
  
উদাহরণ:
Customer UPDATE
       ↓
SQL Server automatically detects UPDATE
       ↓
Customer Audit Trigger
       ↓
Old/New data Audit Table-এ save
  
আপনাকে আলাদাভাবে:
EXEC SaveAudit;
করতে হবে না।






2. কেন Trigger ব্যবহার করবো?
🎯 প্রধান কারণ
- 🔐 Security: গুরুত্বপূর্ণ পরিবর্তন track করা
- 📝 Auditing: কে কী পরিবর্তন করেছে
- 🕒 History: পুরনো এবং নতুন value রাখা
- 🚨 Validation: কিছু business rule enforce করা
- 📦 Inventory: stock পরিবর্তন track করা
- 💰 Price History: product price change রাখা
- 🏢 Compliance: database activity record করা
- ⚙️ Automation: DML event-এর পরে automatic কাজ


Example
একজন employee:
Product price
100 → 120
করলো।
  
Trigger automatically:
ProductPriceHistory

ProductID | OldPrice | NewPrice | ChangedAt
----------|----------|----------|----------
101       | 100      | 120      | 2026...
তৈরি করতে পারে।







3. Trigger-এর কাজ
Trigger দিয়ে সাধারণত:
- INSERT audit
- UPDATE audit
- DELETE audit
- Change history
- Business rule validation
- Inventory tracking
- Price history
- Security auditing
- DDL change tracking
- Schema change tracking
- Database activity monitoring
করা যায়।






4. Trigger Types
  
SQL Server-এ গুরুত্বপূর্ণ Trigger:
  
Type	                 কাজ
DML                    Trigger	INSERT/UPDATE/DELETE
DDL                    Trigger	CREATE/ALTER/DROP
LOGON                  Trigger	Login event
AFTER Trigger	         Event সফল হওয়ার পরে
INSTEAD OF Trigger	   Event-এর পরিবর্তে নিজের logic
Nested Trigger	       Trigger → Trigger
Recursive Trigger	     Trigger নিজেকে invoke করা



Update Order Totals
/* ---------------------------------------------------------
   Calculate Order Total
   --------------------------------------------------------- */

UPDATE o
SET TotalAmount =
(
    SELECT SUM(oi.LineTotal)
    FROM dbo.OrderItems oi
    WHERE oi.OrderID = o.OrderID
);
GO
Inventory — 100 rows
/* ---------------------------------------------------------
   Generate Inventory for all Products
   --------------------------------------------------------- */

INSERT INTO dbo.Inventory
(
    ProductID,
    Warehouse,
    StockQuantity,
    ReorderLevel
)
SELECT
    ProductID,
    CASE
        WHEN ProductID % 3 = 0 THEN 'Kuwait Warehouse'
        WHEN ProductID % 3 = 1 THEN 'Dubai Warehouse'
        ELSE 'Riyadh Warehouse'
    END,
    50 + (ProductID * 3),
    20
FROM dbo.Products;
GO






5. DML Trigger
DML Trigger fires for:
INSERT
UPDATE
DELETE

  
Basic syntax:
CREATE TRIGGER TriggerName
ON dbo.TableName
AFTER INSERT, UPDATE, DELETE
AS
BEGIN

    -- Trigger logic
END;
GO






6. AFTER Trigger
AFTER trigger runs after the DML operation passes its normal checks.
CREATE TRIGGER trg_Customers_AfterInsert
ON dbo.Customers
AFTER INSERT
AS
BEGIN

    -- Logic executes after INSERT
END;
GO







7. inserted Table
inserted হলো SQL Server-এর special logical table।
INSERT হলে:
inserted
   ↓
New rows
UPDATE হলে:
inserted = New values
deleted  = Old values







8. deleted Table
DELETE হলে:
  
deleted
   ↓
Deleted rows
  
UPDATE হলে:
deleted = Old values
inserted = New values

  
সবচেয়ে গুরুত্বপূর্ণ rule
  
Operation	          inserted	         deleted
INSERT	            New	               Empty
UPDATE	            New	               Old
DELETE	            Empty	             Old








9. INSERT Trigger
প্রথমে audit table:
/* ---------------------------------------------------------
   Customer Audit Table
   --------------------------------------------------------- */
CREATE TABLE audit.CustomerAudit
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    CustomerID INT,
    ActionType VARCHAR(20),
    CustomerName VARCHAR(150),
    Email VARCHAR(200),
    AuditDate DATETIME2 DEFAULT SYSDATETIME(),
    SQLLogin SYSNAME DEFAULT SUSER_SNAME()
);
GO


  
Trigger:
/* ---------------------------------------------------------
   Audit Customer INSERT
   --------------------------------------------------------- */
CREATE TRIGGER trg_Customers_InsertAudit
ON dbo.Customers
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        CustomerID,
        'INSERT',
        CustomerName,
        Email
    FROM inserted;
END;




GO
Test:
INSERT INTO dbo.Customers
(
    CustomerName,
    Email,
    Phone,
    Country
)
VALUES
(
    'New Corporate Customer',
    'corporate@company.com',
    '+96599999999',
    'Kuwait'
);



Check:
SELECT *
FROM audit.CustomerAudit
ORDER BY AuditID DESC;









10. UPDATE Trigger
/* ---------------------------------------------------------
   Customer UPDATE Audit
   --------------------------------------------------------- */
CREATE TRIGGER trg_Customers_UpdateAudit
ON dbo.Customers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        CustomerID,
        'UPDATE',
        CustomerName,
        Email
    FROM inserted;
END;
GO




  



11. DELETE Trigger
/* ---------------------------------------------------------
   Customer DELETE Audit
   --------------------------------------------------------- */

CREATE TRIGGER trg_Customers_DeleteAudit
ON dbo.Customers
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        CustomerID,
        'DELETE',
        CustomerName,
        Email
    FROM deleted;
END;
GO


  




12–14. INSERT + UPDATE + DELETE
Production-এ একটি trigger-এর মধ্যে তিনটি event handle করা যায়।
/* ---------------------------------------------------------
   One Trigger Handling INSERT, UPDATE and DELETE
   --------------------------------------------------------- */

CREATE TRIGGER trg_Customers_AllChanges
ON dbo.Customers
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    /* INSERT */
    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        CustomerID,
        'INSERT',
        CustomerName,
        Email
    FROM inserted
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM deleted d
        WHERE d.CustomerID = inserted.CustomerID
    );

    /* UPDATE */
    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        i.CustomerID,
        'UPDATE',
        i.CustomerName,
        i.Email
    FROM inserted i
    INNER JOIN deleted d
        ON d.CustomerID = i.CustomerID;

    /* DELETE */
    INSERT INTO audit.CustomerAudit
    (
        CustomerID,
        ActionType,
        CustomerName,
        Email
    )
    SELECT
        CustomerID,
        'DELETE',
        CustomerName,
        Email
    FROM deleted
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM inserted i
        WHERE i.CustomerID = deleted.CustomerID
    );
END;
GO
⚠️ Important: একই table-এ আগের individual triggers 
এবং এই combined trigger একসাথে রাখবেন না। নাহলে duplicate audit হতে পারে।





  


15. Multi-row Trigger
এটি Trigger শেখার সবচেয়ে গুরুত্বপূর্ণ বিষয়গুলোর একটি।
  
এই ভুল করবেন না:
SELECT @CustomerID = CustomerID
FROM inserted;
কারণ inserted-এ 1 row নয়, 1000 rows থাকতে পারে।

  
সঠিক:
INSERT INTO audit.CustomerAudit
(
    CustomerID,
    ActionType
)
SELECT
    CustomerID,
    'INSERT'
FROM inserted;


Rule
Trigger সবসময় set-based লিখুন।




  



16. Audit Table
Audit table-এর সাধারণ structure:
AuditID
BusinessKey
ActionType
OldValue
NewValue
ChangedBy
ChangedAt


  
Example:
CREATE TABLE audit.ProductAudit
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    ProductID INT,
    ActionType VARCHAR(20),
    OldPrice DECIMAL(12,2),
    NewPrice DECIMAL(12,2),
    ChangedBy SYSNAME,
    ChangedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO





  


17. Change History
Product price history-এর জন্য:
/* ---------------------------------------------------------
   Product Price History
   --------------------------------------------------------- */

CREATE TABLE audit.ProductPriceHistory
(
    HistoryID BIGINT IDENTITY PRIMARY KEY,
    ProductID INT NOT NULL,
    OldPrice DECIMAL(12,2),
    NewPrice DECIMAL(12,2),
    ChangedBy SYSNAME,
    ChangedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO




Trigger:
/* ---------------------------------------------------------
   Capture Product Price Changes
   --------------------------------------------------------- */
CREATE TRIGGER trg_Products_PriceHistory
ON dbo.Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.ProductPriceHistory
    (
        ProductID,
        OldPrice,
        NewPrice,
        ChangedBy
    )
    SELECT
        i.ProductID,
        d.UnitPrice,
        i.UnitPrice,
        SUSER_SNAME()
    FROM inserted i
    INNER JOIN deleted d
        ON i.ProductID = d.ProductID
    WHERE ISNULL(i.UnitPrice, 0)
       <> ISNULL(d.UnitPrice, 0);
END;
GO


  
Test:
UPDATE dbo.Products
SET UnitPrice = UnitPrice + 10
WHERE ProductID = 10;









18. Business Rule Validation
ধরুন:
Product price কখনো negative হতে পারবে না।

/* ---------------------------------------------------------
   Validate Product Price
   --------------------------------------------------------- */
CREATE TRIGGER trg_Products_ValidatePrice
ON dbo.Products
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM inserted
        WHERE UnitPrice <= 0
    )
    BEGIN
        THROW 50001,
              'Product price must be greater than zero.',
              1;
    END;
END;



GO
তবে এই ধরনের simple rule-এর জন্য CHECK constraint সাধারণত Trigger-এর চেয়ে ভালো:
ALTER TABLE dbo.Products
ADD CONSTRAINT CK_Products_UnitPrice
CHECK (UnitPrice > 0);









19. Trigger + Transaction
Trigger সাধারণত যে DML statement-এর অংশ হিসেবে fire করে, তার transaction-এর মধ্যেই থাকে।
UPDATE
   ↓
Trigger
   ↓
Audit
   ↓
Error
   ↓
Transaction rollback
   ↓
UPDATE rollback
এটি Trigger-এর অত্যন্ত গুরুত্বপূর্ণ behavior।




  


20. Trigger + TRY/CATCH
/* ---------------------------------------------------------
   Trigger Error Handling
   --------------------------------------------------------- */
CREATE TRIGGER trg_Example_ErrorHandling
ON dbo.Products
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        -- Trigger business logic
        INSERT INTO audit.ProductPriceHistory
        (
            ProductID,
            OldPrice,
            NewPrice,
            ChangedBy
        )
        SELECT
            i.ProductID,
            d.UnitPrice,
            i.UnitPrice,
            SUSER_SNAME()
        FROM inserted i
        JOIN deleted d
            ON i.ProductID = d.ProductID;

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH
END;
GO



  




21. INSTEAD OF Trigger
INSTEAD OF অর্থ:
Original operation-এর পরিবর্তে Trigger-এর logic execute হবে।

বিশেষভাবে useful:
- Views
- Complex insert/update
- Controlled delete
Example:
/* ---------------------------------------------------------
   Example View
   --------------------------------------------------------- */

CREATE VIEW dbo.vCustomerOrders
AS
SELECT
    c.CustomerID,
    c.CustomerName,
    o.OrderID,
    o.OrderDate,
    o.TotalAmount
FROM dbo.Customers c
JOIN dbo.Orders o
    ON c.CustomerID = o.CustomerID;
GO
View-এর উপর:
CREATE TRIGGER trg_vCustomerOrders_Insert
ON dbo.vCustomerOrders
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    /* Custom insert logic */
    INSERT INTO dbo.Orders
    (
        CustomerID,
        EmployeeID,
        OrderDate
    )
    SELECT
        CustomerID,
        1,
        OrderDate
    FROM inserted;
END;
GO





  


22. DML Trigger Architecture
Production architecture:
Application
    ↓
INSERT / UPDATE / DELETE
    ↓
Business Table
    ↓
DML Trigger
    ↓
├── Audit
├── Validation
├── History
└── Business Automation







23. 23. Statement-level Behavior
SQL Server Trigger row-level নয়, statement-level।
  
যেমন:
UPDATE dbo.Products
SET UnitPrice = UnitPrice * 1.10;

এটি যদি 100 rows update করে:
UPDATE statement = 1
Trigger execution = 1
inserted = 100 rows
❌ Trigger 100 বার execute হবে না।










24. inserted/deleted Set Logic
Advanced Trigger-এর core:
  
SELECT *
FROM inserted;

SELECT *
FROM deleted;


UPDATE:
deleted → Before
inserted → After
তাই change detection:
WHERE i.UnitPrice <> d.UnitPrice







25. Multi-row Processing
  
❌ Bad:
DECLARE @ID INT;

SELECT @ID = ProductID
FROM inserted;


✅ Good:
INSERT INTO audit.ProductPriceHistory
(
    ProductID,
    OldPrice,
    NewPrice
)
SELECT
    i.ProductID,
    d.UnitPrice,
    i.UnitPrice
FROM inserted i
JOIN deleted d
    ON i.ProductID = d.ProductID;







26. Recursive Trigger

  
Recursive trigger:
Trigger
  ↓
same table UPDATE
  ↓
same Trigger
  ↓
same table UPDATE
  ↓
...
এটি dangerous হতে পারে।

  
SQL Server configuration:
SELECT
    name,
    is_recursive_triggers_on
FROM sys.databases
WHERE name = 'TriggerDB';





27. Nested Trigger
  
Nested:
Customer Trigger
      ↓
Audit Table Trigger
      ↓
Another Trigger
অর্থাৎ একটি trigger-এর DML operation অন্য trigger fire করতে পারে।







28. Trigger Order
একই event-এর জন্য multiple AFTER triggers থাকতে পারে।

  
Metadata:
EXEC sp_helptrigger 'dbo.Customers';



Specific trigger-এর first/last order:
EXEC sp_settriggerorder
    @triggername = 'trg_Customers_AllChanges',
    @order = 'First',
    @stmttype = 'INSERT';
⚠️ Multiple trigger-এর execution order design-এর গুরুত্বপূর্ণ অংশ।







29. DISABLE Trigger
/* ---------------------------------------------------------
   Disable Trigger
   --------------------------------------------------------- */
DISABLE TRIGGER trg_Customers_AllChanges
ON dbo.Customers;


সব trigger:
DISABLE TRIGGER ALL
ON dbo.Customers;






30. ENABLE Trigger
/* ---------------------------------------------------------
   Enable Trigger
   --------------------------------------------------------- */

ENABLE TRIGGER trg_Customers_AllChanges
ON dbo.Customers;







31. DROP Trigger
/* ---------------------------------------------------------
   Remove Trigger
   --------------------------------------------------------- */

DROP TRIGGER IF EXISTS trg_Customers_AllChanges;
GO








32. Trigger Metadata
SQL Server catalog views:
/* ---------------------------------------------------------
   Find Database Triggers
   --------------------------------------------------------- */
SELECT
    name,
    parent_class_desc,
    is_disabled,
    create_date,
    modify_date
FROM sys.triggers;



-- Table-specific:
SELECT
    t.name AS TriggerName,
    t.is_disabled,
    OBJECT_NAME(t.parent_id) AS TableName
FROM sys.triggers t;



-- Trigger definition:
SELECT
    OBJECT_NAME(object_id) AS TriggerName,
    definition
FROM sys.sql_modules
WHERE object_id IN
(
    SELECT object_id
    FROM sys.triggers
);







33. Trigger Dependencies
Trigger কোন table/object-এর উপর dependent তা দেখতে:
SELECT
    referencing_entity_name,
    referenced_entity_name
FROM sys.sql_expression_dependencies
WHERE referencing_id IN
(
    SELECT object_id
    FROM sys.triggers
);






🟣 EXPERT
34. DDL Trigger
DML:
INSERT
UPDATE
DELETE


  
DDL:
CREATE
ALTER
DROP


  
Example:
CREATE TRIGGER trg_Database_DDL_Audit
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE
AS
BEGIN
    SET NOCOUNT ON;

    -- Capture schema changes
END;
GO






35. LOGON Trigger
LOGON Trigger login event-এর সময় execute হয়।
Architecture:
User Login
    ↓
LOGON Trigger
    ↓
Allow / Reject / Audit


  
Basic syntax:
CREATE TRIGGER trg_Server_LogonAudit
ON ALL SERVER
FOR LOGON
AS
BEGIN

    -- Security logic

END;
GO
⚠️ Production warning: ভুল LOGON Trigger administrator-কে server-এ ঢুকতে বাধা দিতে পারে। 
তাই development environment ছাড়া সরাসরি production-এ experiment করা উচিত নয়।







36. EVENTDATA()
DDL event-এর XML information পাওয়ার জন্য:
SELECT EVENTDATA();


এর মধ্যে পাওয়া যেতে পারে:
EventType
PostTime
SPID
ServerName
LoginName
DatabaseName
SchemaName
ObjectName
ObjectType







37. Security Auditing
Audit framework:
User
 ↓
DML
 ↓
Trigger
 ↓
Audit Table
 ↓
ChangedBy
ChangedAt
OldValue
NewValue
Action
এটি financial, ERP, CRM এবং enterprise systems-এ গুরুত্বপূর্ণ।





  



38. Schema Change Tracking
DDL Audit table:
/* ---------------------------------------------------------
   DDL Audit Table
   --------------------------------------------------------- */

CREATE TABLE audit.DDLAudit
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    EventType VARCHAR(100),
    DatabaseName SYSNAME,
    SchemaName SYSNAME,
    ObjectName SYSNAME,
    ObjectType VARCHAR(100),
    LoginName SYSNAME,
    HostName VARCHAR(200),
    EventDate DATETIME2 DEFAULT SYSDATETIME(),
    EventXML XML
);
GO


DDL Trigger:
/* ---------------------------------------------------------
   Capture CREATE / ALTER / DROP events
   --------------------------------------------------------- */

CREATE TRIGGER trg_Database_DDLAudit
ON DATABASE
FOR CREATE_TABLE, ALTER_TABLE, DROP_TABLE,
    CREATE_VIEW, ALTER_VIEW, DROP_VIEW
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Event XML = EVENTDATA();

    INSERT INTO audit.DDLAudit
    (
        EventType,
        DatabaseName,
        SchemaName,
        ObjectName,
        ObjectType,
        LoginName,
        HostName,
        EventXML
    )
    SELECT
        @Event.value('(/EVENT_INSTANCE/EventType)[1]', 'VARCHAR(100)'),
        @Event.value('(/EVENT_INSTANCE/DatabaseName)[1]', 'SYSNAME'),
        @Event.value('(/EVENT_INSTANCE/SchemaName)[1]', 'SYSNAME'),
        @Event.value('(/EVENT_INSTANCE/ObjectName)[1]', 'SYSNAME'),
        @Event.value('(/EVENT_INSTANCE/ObjectType)[1]', 'VARCHAR(100)'),
        @Event.value('(/EVENT_INSTANCE/LoginName)[1]', 'SYSNAME'),
        HOST_NAME(),
        @Event;
END;
GO





  



39. Trigger Performance
Trigger-এর সবচেয়ে বড় production concern:
DML Performance
যেমন:
UPDATE dbo.Products
SET UnitPrice = UnitPrice * 1.10;



100,000 rows update করলে Trigger-ও 100,000 rows নিয়ে কাজ করতে পারে।
Best practices
- ⚡ Set-based logic
- ⚡ Proper indexes
- ⚡ Small audit operations
- ⚡ Avoid cursors
- ⚡ Avoid loops
- ⚡ Avoid unnecessary joins
- ⚡ Avoid external calls
- ⚡ Avoid long-running queries







  

40. Blocking
Trigger একই transaction-এর অংশ।
UPDATE
 ↓
Trigger
 ↓
Audit
 ↓
Transaction remains open
Trigger বেশি সময় নিলে locks বেশি সময় ধরে রাখতে পারে।


  
ফলে:
Session A
   ↓
UPDATE
   ↓
Trigger
   ↓
Long operation
   ↓
Session B waits





  




41. Deadlocks
Trigger deadlock তৈরি করতে পারে।
Example:
Transaction A
Customer → Audit

Transaction B
Audit → Customer
দুই session একে অপরের resource-এর জন্য অপেক্ষা করলে:
Deadlock
Production trigger design-এ transaction ordering consistent রাখা গুরুত্বপূর্ণ।





  



42. Transaction Impact
সবচেয়ে গুরুত্বপূর্ণ concept:
Trigger-এর error original DML statement-কে rollback করাতে পারে।

Example:
UPDATE dbo.Products
SET UnitPrice = -100
WHERE ProductID = 1;



Trigger:
THROW 50001, 'Invalid price', 1;
ফল:
UPDATE
 ↓
Trigger
 ↓
Error
 ↓
Transaction rollback
 ↓
UPDATE cancelled






  



43. Error Handling
Production trigger-এ:
BEGIN TRY

    -- Trigger logic

END TRY
BEGIN CATCH

    -- Preserve original error

    THROW;

END CATCH;
THROW সাধারণত modern SQL Server code-এ preferred।



  





44. Production Architecture
Enterprise Trigger architecture:
                Application
                    │
                    ▼
             Business Table
                    │
                    ▼
              DML Trigger
                    │
        ┌───────────┼───────────┐
        ▼           ▼           ▼
      Audit      History     Validation
        │           │           │
        ▼           ▼           ▼
    Audit DB     History DB   Rollback


  
Production rules
- 🔒 Trigger ছোট রাখুন
- 📊 Set-based করুন
- 🧪 Test multi-row DML
- 🚨 Error handling করুন
- 📈 Performance monitor করুন
- 📝 Documentation রাখুন
- 🔍 Dependency track করুন





  



45. Trigger Alternatives
Trigger সবসময় best solution নয়।

  
Requirement	                         Better Option
Simple validation	                   CHECK
Relationship	                       FOREIGN KEY
Unique value	                       UNIQUE
Default value	                       DEFAULT
Audit	                               Temporal Table / CDC
ETL	                                 SSIS / ADF / Databricks
Complex business process	           Stored Procedure
Event-driven architecture	           Queue/Event system
Analytical history	                 CDC
Simple automation	                   Application logic


-- Trigger কখন ব্যবহার করবেন?
✅ Strong database-level audit
✅ Critical business rule
✅ Legacy application
✅ Automatic change history
✅ Security/compliance requirement  


  
-- কখন avoid করবেন?
❌ Complex ETL
❌ Long-running operations
❌ External API call
❌ Hidden business logic
❌ Heavy analytical calculation







  

🏆 PROJECT
46. Customer Audit Project
Business requirement:
Customer-এর INSERT, UPDATE এবং DELETE track করতে হবে।

Audit:
SELECT *
FROM audit.CustomerAudit
ORDER BY AuditID DESC;


Practice:
/* ---------------------------------------------------------
   Update Customer
   --------------------------------------------------------- */

UPDATE dbo.Customers
SET CustomerName = 'Updated Customer'
WHERE CustomerID = 10;


তারপর:
SELECT *
FROM audit.CustomerAudit
WHERE CustomerID = 10;








47. Product Price History
Business requirement:
  
Product price কখনো change হলে old/new price রাখতে হবে।

Query:
SELECT
    ProductID,
    OldPrice,
    NewPrice,
    NewPrice - OldPrice AS PriceDifference,
    ChangedBy,
    ChangedAt
FROM audit.ProductPriceHistory
ORDER BY ChangedAt DESC;

এটি Data Analyst-এর জন্য খুব useful।






  

48. Inventory Audit
Inventory audit table:
  
/* ---------------------------------------------------------
   Inventory Audit
   --------------------------------------------------------- */

CREATE TABLE audit.InventoryAudit
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    ProductID INT,
    OldQuantity INT,
    NewQuantity INT,
    ChangeQuantity INT,
    ChangedBy SYSNAME,
    ChangedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO


Trigger:
/* ---------------------------------------------------------
   Inventory Change Audit
   --------------------------------------------------------- */

CREATE TRIGGER trg_Inventory_Audit
ON dbo.Inventory
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.InventoryAudit
    (
        ProductID,
        OldQuantity,
        NewQuantity,
        ChangeQuantity,
        ChangedBy
    )
    SELECT
        i.ProductID,
        d.StockQuantity,
        i.StockQuantity,
        i.StockQuantity - d.StockQuantity,
        SUSER_SNAME()
    FROM inserted i
    INNER JOIN deleted d
        ON i.InventoryID = d.InventoryID
    WHERE i.StockQuantity <> d.StockQuantity;
END;
GO


Test:
UPDATE dbo.Inventory
SET StockQuantity = StockQuantity - 5
WHERE ProductID = 10;


Analysis:
SELECT
    ProductID,
    SUM(ChangeQuantity) AS NetStockChange
FROM audit.InventoryAudit
GROUP BY ProductID;








49. Employee Audit
/* ---------------------------------------------------------
   Employee Audit Table
   --------------------------------------------------------- */

CREATE TABLE audit.EmployeeAudit
(
    AuditID BIGINT IDENTITY PRIMARY KEY,
    EmployeeID INT,
    OldSalary DECIMAL(12,2),
    NewSalary DECIMAL(12,2),
    OldDepartmentID INT,
    NewDepartmentID INT,
    ChangedBy SYSNAME,
    ChangedAt DATETIME2 DEFAULT SYSDATETIME()
);
GO



  
Trigger:
/* ---------------------------------------------------------
   Employee Salary / Department Change Audit
   --------------------------------------------------------- */

CREATE TRIGGER trg_Employees_Audit
ON dbo.Employees
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO audit.EmployeeAudit
    (
        EmployeeID,
        OldSalary,
        NewSalary,
        OldDepartmentID,
        NewDepartmentID,
        ChangedBy
    )
    SELECT
        i.EmployeeID,
        d.Salary,
        i.Salary,
        d.DepartmentID,
        i.DepartmentID,
        SUSER_SNAME()
    FROM inserted i
    INNER JOIN deleted d
        ON i.EmployeeID = d.EmployeeID
    WHERE
        ISNULL(i.Salary, 0) <> ISNULL(d.Salary, 0)
        OR i.DepartmentID <> d.DepartmentID;
END;
GO





  


50. DDL Audit
Test:
/* ---------------------------------------------------------
   Test DDL Audit
   --------------------------------------------------------- */

CREATE TABLE dbo.TestTriggerTable
(
    ID INT
);
GO

ALTER TABLE dbo.TestTriggerTable
ADD CreatedAt DATETIME2;
GO

DROP TABLE dbo.TestTriggerTable;
GO


  
তারপর:
SELECT
    EventType,
    DatabaseName,
    SchemaName,
    ObjectName,
    ObjectType,
    LoginName,
    EventDate
FROM audit.DDLAudit
ORDER BY AuditID DESC;


আপনি দেখতে পাবেন:
CREATE_TABLE
ALTER_TABLE
DROP_TABLE






  


51. Production Trigger Framework
শেষে একটি practical enterprise framework:
                    Trigger Framework
                           │
          ┌────────────────┼────────────────┐
          │                │                │
          ▼                ▼                ▼
       DML Audit        Validation       History
          │                │                │
          ▼                ▼                ▼
     INSERT/UPDATE/     CHECK Rules      Old/New
       DELETE
          │
          ▼
     Audit Tables
          │
          ▼
    Reporting Layer
          │
          ▼
    Power BI / Analytics




🔥 সবচেয়ে গুরুত্বপূর্ণ Trigger Rules
- 🧠 Rule 1: Trigger হলো automatic database logic।
- 🧠 Rule 2: DML Trigger = INSERT, UPDATE, DELETE
- 🧠 Rule 3: inserted = নতুন data
- 🧠 Rule 4: deleted = পুরনো/deleted data
- 🧠 Rule 5: UPDATE-তে inserted + deleted দুটোই থাকে।
- 🧠 Rule 6: Trigger statement-level, row-level নয়।
- 🧠 Rule 7: inserted/deleted সবসময় multiple rows ধরে design করবেন।
- 🧠 Rule 8: Cursor/loop এড়িয়ে set-based SQL লিখবেন।
- 🧠 Rule 9: Trigger transaction-এর অংশ।
- 🧠 Rule 10: Trigger error হলে original DML rollback হতে পারে।
- 🧠 Rule 11: AFTER এবং INSTEAD OF behavior আলাদা।
- 🧠 Rule 12: DDL Trigger schema changes audit করতে পারে।
- 🧠 Rule 13: LOGON Trigger security-sensitive।
- 🧠 Rule 14: Trigger বেশি complex হলে maintenance ও performance সমস্যা হয়।
- 🧠 Rule 15: Simple validation-এর জন্য Constraint অনেক সময় Trigger-এর চেয়ে ভালো।

