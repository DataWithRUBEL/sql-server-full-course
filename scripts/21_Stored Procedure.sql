1. Stored Procedure কী? 🧠
Stored Procedure হলো SQL Server database-এর ভিতরে সংরক্ষিত 
একটি precompiled/reusable T-SQL program, যেখানে এক বা একাধিক SQL statement রাখা যায়।

  
সহজভাবে:
একবার SQL logic লিখবেন → Database-এ save করবেন → প্রয়োজন অনুযায়ী parameter দিয়ে বারবার execute করবেন।

উদাহরণ:
EXEC Sales.usp_GetCustomerOrders
    @CustomerID = 101;
এখানে application, analyst বা ETL pipeline সরাসরি অনেক SQL statement না লিখে একটি procedure call করতে পারে।







2. কেন Stored Procedure ব্যবহার করবো? 🎯
👨‍💻 Data Analyst
- 📊 Reusable reporting logic
- 🔎 Parameterized reports
- 📈 Dashboard data extraction
- 🧮 Complex aggregation
- 🔐 Database access control
- ⚡ Repeated queries সহজ করা

  
🏗️ Data Engineer
- 🔄 ETL/ELT processing
- 🧹 Data cleansing
- 📥 Incremental loading
- 🔁 SCD Type 1 / Type 2
- 🏭 Bronze → Silver → Gold
- 📝 Error logging
- 🔐 Security
- ⏰ SQL Agent scheduling








3. Stored Procedure-এর প্রধান কাজ
Stored Procedure
       │
       ├── SELECT
       ├── INSERT
       ├── UPDATE
       ├── DELETE
       ├── JOIN
       ├── Aggregation
       ├── CTE
       ├── Window Functions
       ├── Transactions
       ├── Error Handling
       ├── Dynamic SQL
       ├── ETL
       ├── Security
       └── Performance Tuning








4. Stored Procedure Fundamentals
একটি procedure-এর basic structure:
CREATE PROCEDURE SchemaName.ProcedureName
    @Parameter1 DataType,
    @Parameter2 DataType
AS
BEGIN

    -- SQL statements

END;
GO






5. CREATE PROCEDURE
Simple Example
/* ============================================================
   SIMPLE STORED PROCEDURE
   Purpose: Return all customers
   ============================================================ */
CREATE PROCEDURE Sales.usp_GetCustomers
AS
BEGIN

    SELECT
        CustomerID,
        CustomerName,
        Email,
        Country
    FROM Sales.Customers;

END;
GO
Execute:
EXEC Sales.usp_GetCustomers;





6. ALTER PROCEDURE
Existing procedure পরিবর্তন করতে:
/* ============================================================
   MODIFY EXISTING PROCEDURE
   ============================================================ */
ALTER PROCEDURE Sales.usp_GetCustomers
AS
BEGIN

    SELECT
        CustomerID,
        CustomerName,
        Email,
        Country,
        RegistrationDate
    FROM Sales.Customers;

END;
GO







7. CREATE OR ALTER PROCEDURE ⭐
Modern SQL Server development-এ এটি খুব useful।
/* ============================================================
   CREATE OR ALTER
   Procedure না থাকলে CREATE
   থাকলে ALTER
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_GetCustomers
AS
BEGIN

    SELECT *
    FROM Sales.Customers;

END;


GO
কেন ভালো?
- Deployment সহজ
- Development script বারবার চালানো যায়
- আগে DROP করতে হয় না








8. EXEC / EXECUTE
দুটো একই কাজ করে।
EXEC Sales.usp_GetCustomers;


অথবা:
EXECUTE Sales.usp_GetCustomers;





9. Input Parameters 🎯
এখন customer অনুযায়ী orders বের করব।
/* ============================================================
   INPUT PARAMETER
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_GetCustomerOrders
    @CustomerID INT
AS
BEGIN
    SELECT
        o.OrderID,
        o.OrderDate,
        o.OrderStatus
    FROM Sales.Orders AS o
    WHERE o.CustomerID = @CustomerID;

END;


GO
Execute:
EXEC Sales.usp_GetCustomerOrders
    @CustomerID = 1;
এটাই reporting-এর জন্য খুব common pattern।








10. Multiple Parameters
/* ============================================================
   MULTIPLE PARAMETERS
   Customer + Order Status
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_GetCustomerOrdersByStatus
    @CustomerID INT,
    @OrderStatus VARCHAR(30)
AS
BEGIN

    SELECT
        OrderID,
        OrderDate,
        OrderStatus
    FROM Sales.Orders
    WHERE CustomerID = @CustomerID
      AND OrderStatus = @OrderStatus;

END;


GO
EXEC Sales.usp_GetCustomerOrdersByStatus
    @CustomerID = 1,
    @OrderStatus = 'Completed';








11. Default Parameters
Parameter না দিলে default value ব্যবহার হবে।
/* ============================================================
   DEFAULT PARAMETER
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_GetOrders
    @OrderStatus VARCHAR(30) = 'Completed'
AS
BEGIN
    SELECT
        OrderID,
        CustomerID,
        OrderDate,
        OrderStatus
    FROM Sales.Orders
    WHERE OrderStatus = @OrderStatus;
END;


GO
-- Default = Completed
EXEC Sales.usp_GetOrders;


অথবা:
EXEC Sales.usp_GetOrders
    @OrderStatus = 'Pending';






12. Optional Parameters
SQL Server-এ parameter technically "optional" হয় যখন default value দেওয়া থাকে।
/* ============================================================
   OPTIONAL FILTERS
   NULL means "don't filter"
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_SalesReport
    @CustomerID INT = NULL,
    @OrderStatus VARCHAR(30) = NULL
AS
BEGIN
    SELECT
        o.OrderID,
        o.CustomerID,
        o.OrderDate,
        o.OrderStatus
    FROM Sales.Orders AS o
    WHERE
        (@CustomerID IS NULL OR o.CustomerID = @CustomerID)
        AND
        (@OrderStatus IS NULL OR o.OrderStatus = @OrderStatus);
END;



GO
Examples:
-- সব order
EXEC Reporting.usp_SalesReport;

-- শুধু Customer 1
EXEC Reporting.usp_SalesReport
    @CustomerID = 1;

-- শুধু Completed
EXEC Reporting.usp_SalesReport
    @OrderStatus = 'Completed';







13. SELECT in Procedure
Stored procedure-এর ভিতরে সাধারণ SELECT সবচেয়ে বেশি ব্যবহৃত হয়।
/* ============================================================
   REPORTING PROCEDURE
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_ProductInventory
AS
BEGIN

    SELECT
        ProductID,
        ProductName,
        UnitPrice,
        StockQuantity
    FROM Product.Products
    ORDER BY StockQuantity ASC;

END;
GO







14. JOIN in Procedure 🔗
Real business reporting-এ JOIN খুব গুরুত্বপূর্ণ।
/* ============================================================
   CUSTOMER ORDER REPORT
   Multiple table JOIN
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_CustomerOrderDetails
    @CustomerID INT
AS
BEGIN

    SELECT
        c.CustomerID,
        c.CustomerName,
        o.OrderID,
        o.OrderDate,
        p.ProductName,
        oi.Quantity,
        oi.UnitPrice,
        oi.Quantity * oi.UnitPrice AS LineTotal
    FROM Sales.Customers AS c

    INNER JOIN Sales.Orders AS o
        ON c.CustomerID = o.CustomerID

    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID

    INNER JOIN Product.Products AS p
        ON oi.ProductID = p.ProductID

    WHERE c.CustomerID = @CustomerID;

END;


GO
EXEC Reporting.usp_CustomerOrderDetails
    @CustomerID = 1;







15. GROUP BY / HAVING
Customer-wise revenue:
/* ============================================================
   CUSTOMER REVENUE REPORT
   GROUP BY + HAVING
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_CustomerRevenue
    @MinimumRevenue DECIMAL(12,2) = 0
AS
BEGIN

    SELECT
        c.CustomerID,
        c.CustomerName,
        SUM(oi.Quantity * oi.UnitPrice) AS TotalRevenue
    FROM Sales.Customers AS c

    INNER JOIN Sales.Orders AS o
        ON c.CustomerID = o.CustomerID

    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY
        c.CustomerID,
        c.CustomerName

    HAVING
        SUM(oi.Quantity * oi.UnitPrice) >= @MinimumRevenue

    ORDER BY TotalRevenue DESC;

END;


GO
EXEC Reporting.usp_CustomerRevenue
    @MinimumRevenue = 500;








16. CASE inside Procedure
/* ============================================================
   CUSTOMER SEGMENTATION
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_CustomerSegments
AS
BEGIN

    SELECT
        c.CustomerID,
        c.CustomerName,

        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,

        CASE
            WHEN SUM(oi.Quantity * oi.UnitPrice) >= 2000
                THEN 'VIP'

            WHEN SUM(oi.Quantity * oi.UnitPrice) >= 1000
                THEN 'Regular'

            ELSE 'Low Value'
        END AS CustomerSegment

    FROM Sales.Customers AS c

    INNER JOIN Sales.Orders AS o
        ON c.CustomerID = o.CustomerID

    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY
        c.CustomerID,
        c.CustomerName;

END;
GO







17. CTE in Procedure
/* ============================================================
   CTE INSIDE STORED PROCEDURE
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_TopCustomers
AS
BEGIN

    ;WITH CustomerRevenue AS
    (
        SELECT
            c.CustomerID,
            c.CustomerName,
            SUM(oi.Quantity * oi.UnitPrice) AS Revenue

        FROM Sales.Customers AS c

        INNER JOIN Sales.Orders AS o
            ON c.CustomerID = o.CustomerID

        INNER JOIN Sales.OrderItems AS oi
            ON o.OrderID = oi.OrderID

        WHERE o.OrderStatus = 'Completed'

        GROUP BY
            c.CustomerID,
            c.CustomerName
    )

    SELECT *
    FROM CustomerRevenue
    WHERE Revenue >= 500
    ORDER BY Revenue DESC;

END;
GO






18. Subquery in Procedure
/* ============================================================
   SUBQUERY INSIDE PROCEDURE
   Find products whose price is above average
   ============================================================ */
CREATE OR ALTER PROCEDURE Product.usp_ExpensiveProducts
AS
BEGIN

    SELECT
        ProductID,
        ProductName,
        UnitPrice
    FROM Product.Products
    WHERE UnitPrice >
    (
        SELECT AVG(UnitPrice)
        FROM Product.Products
    );

END;
GO






19. Window Functions
/* ============================================================
   WINDOW FUNCTION INSIDE PROCEDURE
   Rank customers by revenue
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_CustomerRevenueRanking
AS
BEGIN

    SELECT
        c.CustomerID,
        c.CustomerName,

        SUM(oi.Quantity * oi.UnitPrice) AS Revenue,

        RANK() OVER
        (
            ORDER BY
                SUM(oi.Quantity * oi.UnitPrice) DESC
        ) AS RevenueRank

    FROM Sales.Customers AS c

    INNER JOIN Sales.Orders AS o
        ON c.CustomerID = o.CustomerID

    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID

    WHERE o.OrderStatus = 'Completed'

    GROUP BY
        c.CustomerID,
        c.CustomerName;

END;
GO








20. INSERT Procedure 📥
/* ============================================================
   INSERT PROCEDURE
   Add a new customer
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_InsertCustomer
    @CustomerID INT,
    @CustomerName VARCHAR(150),
    @Email VARCHAR(200),
    @Country VARCHAR(100)
AS
BEGIN

    INSERT INTO Sales.Customers
    (
        CustomerID,
        CustomerName,
        Email,
        Country,
        RegistrationDate
    )
    VALUES
    (
        @CustomerID,
        @CustomerName,
        @Email,
        @Country,
        CAST(GETDATE() AS DATE)
    );

END;


GO
Execute:
EXEC Sales.usp_InsertCustomer
    @CustomerID = 6,
    @CustomerName = 'Michael Scott',
    @Email = 'michael@example.com',
    @Country = 'USA';





21. UPDATE Procedure
/* ============================================================
   UPDATE PROCEDURE
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_UpdateCustomer
    @CustomerID INT,
    @CustomerName VARCHAR(150),
    @Email VARCHAR(200),
    @Country VARCHAR(100)
AS
BEGIN

    UPDATE Sales.Customers
    SET
        CustomerName = @CustomerName,
        Email = @Email,
        Country = @Country
    WHERE CustomerID = @CustomerID;

END;
GO







22. DELETE Procedure
/* ============================================================
   DELETE PROCEDURE
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_DeleteCustomer
    @CustomerID INT
AS
BEGIN

    DELETE FROM Sales.Customers
    WHERE CustomerID = @CustomerID;

END;
GO
⚠️ Production-এ DELETE procedure-এর আগে dependency check, authorization এবং transaction ব্যবহার করা উচিত।







23. CRUD Procedures
CRUD =
C → CREATE
R → READ
U → UPDATE
D → DELETE
  
একটি company application-এ:
Sales.usp_InsertCustomer
Sales.usp_GetCustomer
Sales.usp_UpdateCustomer
Sales.usp_DeleteCustomer
এই pattern খুব common।





24. OUTPUT Parameters
Procedure থেকে একটি value বাইরে ফেরত পাঠাতে OUTPUT ব্যবহার করা যায়।
/* ============================================================
   OUTPUT PARAMETER
   Return customer's total revenue
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_GetCustomerRevenue
    @CustomerID INT,
    @TotalRevenue DECIMAL(18,2) OUTPUT
AS
BEGIN

    SELECT
        @TotalRevenue =
            ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)

    FROM Sales.Orders AS o

    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID

    WHERE o.CustomerID = @CustomerID
      AND o.OrderStatus = 'Completed';

END;
GO
Execute:
DECLARE @Revenue DECIMAL(18,2);

EXEC Reporting.usp_GetCustomerRevenue
    @CustomerID = 1,
    @TotalRevenue = @Revenue OUTPUT;

SELECT @Revenue AS TotalRevenue;










25. RETURN Values
RETURN সাধারণত integer status code ফেরত দিতে ব্যবহৃত হয়।
/* ============================================================
   RETURN VALUE
   1 = Success
   0 = Customer not found
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_CheckCustomer
    @CustomerID INT
AS
BEGIN

    IF EXISTS
    (
        SELECT 1
        FROM Sales.Customers
        WHERE CustomerID = @CustomerID
    )
        RETURN 1;

    RETURN 0;

END;
GO
DECLARE @Result INT;

EXEC @Result = Sales.usp_CheckCustomer
    @CustomerID = 1;

SELECT @Result AS ResultCode;







26. SET NOCOUNT ON ⭐
Production stored procedure-এ সাধারণত এটি ব্যবহার করা হয়।
CREATE OR ALTER PROCEDURE Sales.usp_UpdateCustomer
    @CustomerID INT,
    @Country VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    UPDATE Sales.Customers
    SET Country = @Country
    WHERE CustomerID = @CustomerID;

END;


GO
কেন?
SET NOCOUNT ON unnecessary:
(1 row affected)
(5 rows affected)
...
messages কমায় এবং application/ETL workflow পরিষ্কার রাখে।








27. IF / ELSE
/* ============================================================
   IF / ELSE
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_CheckOrder
    @OrderID INT
AS
BEGIN

    SET NOCOUNT ON;

    IF EXISTS
    (
        SELECT 1
        FROM Sales.Orders
        WHERE OrderID = @OrderID
    )
    BEGIN

        SELECT
            'Order Found' AS Message;

    END
    ELSE
    BEGIN

        SELECT
            'Order Not Found' AS Message;

    END;

END;
GO








28. WHILE Loop
Stored procedure-এ loop ব্যবহার করা যায়, তবে set-based SQL সাধারণত loop-এর চেয়ে preferable।
/* ============================================================
   WHILE EXAMPLE
   ============================================================ */

CREATE OR ALTER PROCEDURE ETL.usp_ProcessNumbers
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @Counter INT = 1;

    WHILE @Counter <= 5
    BEGIN

        PRINT CONCAT('Processing: ', @Counter);

        SET @Counter = @Counter + 1;

    END;

END;


GO
Best Practice
Set-based SQL ⭐⭐⭐⭐⭐
WHILE          ⭐⭐
Cursor         ⭐
যেখানে সম্ভব:
Loop না করে set-based operation ব্যবহার করুন।






29. TRY / CATCH
Production procedure-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
/* ============================================================
   TRY / CATCH
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_SafeUpdateCustomer
    @CustomerID INT,
    @Country VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        UPDATE Sales.Customers
        SET Country = @Country
        WHERE CustomerID = @CustomerID;

    END TRY

    BEGIN CATCH

        SELECT
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_LINE() AS ErrorLine;

    END CATCH;

END;
GO







30. THROW ⭐
Modern SQL Server error handling-এ THROW খুব গুরুত্বপূর্ণ।
/* ============================================================
   THROW
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_UpdateCustomerSafe
    @CustomerID INT,
    @Country VARCHAR(100)
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        IF NOT EXISTS
        (
            SELECT 1
            FROM Sales.Customers
            WHERE CustomerID = @CustomerID
        )
        BEGIN
            THROW 50001,
                  'Customer does not exist.',
                  1;
        END;

        UPDATE Sales.Customers
        SET Country = @Country
        WHERE CustomerID = @CustomerID;

    END TRY

    BEGIN CATCH

        THROW;

    END CATCH;

END;
GO






31. Transactions 🔄
Transaction-এর basic flow:
BEGIN TRANSACTION
       ↓
    SQL Work
       ↓
    Success?
    /     \
  YES      NO
   ↓       ↓
COMMIT   ROLLBACK







32. COMMIT / ROLLBACK
Real example:
Order create করার সময়:
/* ============================================================
   TRANSACTION
   Create order + order item atomically
   ============================================================ */
CREATE OR ALTER PROCEDURE Sales.usp_CreateOrder
    @OrderID INT,
    @CustomerID INT,
    @EmployeeID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Create order
        INSERT INTO Sales.Orders
        (
            OrderID,
            CustomerID,
            EmployeeID,
            OrderDate,
            OrderStatus
        )
        VALUES
        (
            @OrderID,
            @CustomerID,
            @EmployeeID,
            CAST(GETDATE() AS DATE),
            'Completed'
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
        SELECT
            ISNULL(MAX(OrderItemID), 0) + 1,
            @OrderID,
            ProductID,
            @Quantity,
            UnitPrice
        FROM Sales.OrderItems
        CROSS JOIN Product.Products
        WHERE ProductID = @ProductID
        GROUP BY ProductID, UnitPrice;

        -- Everything succeeded
        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        -- Undo everything
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
GO






33. @@TRANCOUNT
বর্তমানে কত transaction level active আছে সেটা বুঝতে:
SELECT @@TRANCOUNT;


Procedure-এর error handling:
IF @@TRANCOUNT > 0
    ROLLBACK TRANSACTION;
এটি production transaction handling-এ খুব useful।





34. Temp Tables
Stored procedure-এর ভিতরে temporary table খুব common।
/* ============================================================
   TEMP TABLE
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_CustomerRevenueTemp
AS
BEGIN

    SET NOCOUNT ON;

    CREATE TABLE #CustomerRevenue
    (
        CustomerID INT,
        Revenue DECIMAL(18,2)
    );

    INSERT INTO #CustomerRevenue
    SELECT
        o.CustomerID,
        SUM(oi.Quantity * oi.UnitPrice)
    FROM Sales.Orders AS o
    INNER JOIN Sales.OrderItems AS oi
        ON o.OrderID = oi.OrderID
    WHERE o.OrderStatus = 'Completed'
    GROUP BY o.CustomerID;

    SELECT *
    FROM #CustomerRevenue
    ORDER BY Revenue DESC;

END;
GO








35. Table Variables
/* ============================================================
   TABLE VARIABLE
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_ProductSummary
AS
BEGIN

    DECLARE @Products TABLE
    (
        ProductID INT,
        ProductName VARCHAR(200),
        UnitPrice DECIMAL(12,2)
    );

    INSERT INTO @Products
    SELECT
        ProductID,
        ProductName,
        UnitPrice
    FROM Product.Products;

    SELECT *
    FROM @Products;

END;
GO






36. Dynamic SQL
যখন SQL structure runtime-এ পরিবর্তিত হয় তখন Dynamic SQL ব্যবহার করা হয়।
/* ============================================================
   DYNAMIC SQL
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_GetData
    @TableName SYSNAME
AS
BEGIN

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL =
        N'SELECT * FROM '
        + QUOTENAME(@TableName);

    EXEC sp_executesql @SQL;

END;
GO






37. sp_executesql ⭐⭐⭐⭐⭐
Dynamic SQL-এ EXEC() এর চেয়ে parameterized sp_executesql সাধারণত বেশি নিরাপদ ও flexible।
/* ============================================================
   PARAMETERIZED DYNAMIC SQL
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_SearchCustomer
    @CustomerName VARCHAR(150)
AS
BEGIN

    DECLARE @SQL NVARCHAR(MAX);

    SET @SQL = N'
        SELECT
            CustomerID,
            CustomerName,
            Email,
            Country
        FROM Sales.Customers
        WHERE CustomerName LIKE @Name;
    ';

    EXEC sys.sp_executesql
        @SQL,
        N'@Name VARCHAR(150)',
        @Name = '%' + @CustomerName + '%';

END;
GO







38. QUOTENAME
Object name safely quote করার জন্য:
SELECT QUOTENAME('Customers');


Result:
[Customers]
Dynamic table/schema names handle করতে এটি গুরুত্বপূর্ণ।






39. SQL Injection Prevention 🔐
❌ Dangerous:
SET @SQL =
    'SELECT * FROM Sales.Customers
     WHERE CustomerName = ''' + @CustomerName + '''';
User input directly SQL string-এর মধ্যে concatenate করা risky।

  
✅ Better:
EXEC sys.sp_executesql
    N'
      SELECT *
      FROM Sales.Customers
      WHERE CustomerName = @Name
    ',
    N'@Name VARCHAR(150)',
    @Name = @CustomerName;


Rule
Values → parameters
Object names → QUOTENAME








40. Pagination
Large reporting dataset-এর জন্য pagination useful।
/* ============================================================
   PAGINATION
   ============================================================ */
CREATE OR ALTER PROCEDURE Reporting.usp_GetCustomersPaged
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN

    SET NOCOUNT ON;

    SELECT
        CustomerID,
        CustomerName,
        Email,
        Country
    FROM Sales.Customers

    ORDER BY CustomerID

    OFFSET (@PageNumber - 1) * @PageSize ROWS

    FETCH NEXT @PageSize ROWS ONLY;

END;


GO
EXEC Reporting.usp_GetCustomersPaged
    @PageNumber = 2,
    @PageSize = 10;







41. Error Logging 📝
Production ETL-এ error log table রাখা গুরুত্বপূর্ণ।
/* ============================================================
   ERROR LOG TABLE
   ============================================================ */
CREATE TABLE Audit.ErrorLog
(
    ErrorLogID INT IDENTITY(1,1) PRIMARY KEY,
    ProcedureName SYSNAME,
    ErrorNumber INT,
    ErrorMessage NVARCHAR(4000),
    ErrorLine INT,
    ErrorDateTime DATETIME2 DEFAULT SYSDATETIME()
);



GO
Procedure:
/* ============================================================
   ERROR LOGGING PROCEDURE
   ============================================================ */
CREATE OR ALTER PROCEDURE Audit.usp_LogError
AS
BEGIN

    INSERT INTO Audit.ErrorLog
    (
        ProcedureName,
        ErrorNumber,
        ErrorMessage,
        ErrorLine
    )
    VALUES
    (
        ERROR_PROCEDURE(),
        ERROR_NUMBER(),
        ERROR_MESSAGE(),
        ERROR_LINE()
    );

END;



GO
TRY/CATCH:
BEGIN TRY

    -- ETL operation

END TRY

BEGIN CATCH

    EXEC Audit.usp_LogError;

    THROW;

END CATCH;







42. Security — GRANT EXECUTE 🔐
ধরুন analyst user procedure execute করতে পারবে কিন্তু underlying table সরাসরি access করবে না।
/* ============================================================
   GRANT EXECUTE
   ============================================================ */
GRANT EXECUTE
ON OBJECT::Reporting.usp_CustomerRevenue
TO AnalystUser;
Concept:
Analyst
   │
   │ EXECUTE
   ↓
Stored Procedure
   │
   ↓
Tables
এটি database security architecture-এ অত্যন্ত গুরুত্বপূর্ণ।








43. Execution Plans ⚡
Stored Procedure performance বোঝার জন্য execution plan জানতে হবে।
/* ============================================================
   ACTUAL EXECUTION PLAN
   SSMS:
   Ctrl + M
   তারপর procedure execute করুন
   ============================================================ */
EXEC Reporting.usp_CustomerRevenue
    @MinimumRevenue = 500;
Execution plan-এ দেখতে পারেন:
- Index Seek
- Index Scan
- Table Scan
- Key Lookup
- Hash Match
- Nested Loops
- Sort
- Aggregate








44. Parameter Sniffing
Stored Procedure-এ parameter sniffing একটি advanced performance topic।
  
ধরুন:
EXEC Reporting.usp_SalesReport
    @CustomerID = 1;


SQL Server execution plan তৈরি করার সময় parameter value-এর distribution বিবেচনা করতে পারে।
পরে:
EXEC Reporting.usp_SalesReport
    @CustomerID = 999999;


একই cached plan সব parameter-এর জন্য optimal নাও হতে পারে।
Symptoms
Parameter A → খুব fast
Parameter B → খুব slow








45. RECOMPILE
কিছু ক্ষেত্রে:
OPTION (RECOMPILE)
ব্যবহার করা যায়।
CREATE OR ALTER PROCEDURE Reporting.usp_SalesReport
    @CustomerID INT
AS
BEGIN

    SELECT
        o.OrderID,
        o.OrderDate,
        o.OrderStatus
    FROM Sales.Orders AS o
    WHERE o.CustomerID = @CustomerID
    OPTION (RECOMPILE);

END;
GO
⚠️ সব procedure-এ RECOMPILE ব্যবহার করবেন না। এটি প্রতিবার compilation overhead তৈরি করতে পারে।






46. Indexing
Stored Procedure নিজে index তৈরি করে না।
Procedure যেসব columns দিয়ে:
WHERE
JOIN
ORDER BY
GROUP BY
করে, সেগুলোর workload অনুযায়ী indexing করতে হয়।
উদাহরণ:
/* ============================================================
   INDEX FOR CUSTOMER FILTER
   ============================================================ */
CREATE INDEX IX_Orders_CustomerID
ON Sales.Orders(CustomerID);


GO
আরেকটি:
CREATE INDEX IX_OrderItems_OrderID
ON Sales.OrderItems(OrderID);
GO






47. Performance Tuning Checklist 🚀
Stored Procedure slow হলে:
1. Execution Plan
        ↓
2. Logical Reads
        ↓
3. CPU Time
        ↓
4. Indexes
        ↓
5. JOIN conditions
        ↓
6. WHERE predicates
        ↓
7. Statistics
        ↓
8. Parameter Sniffing
        ↓
9. Temp Tables
        ↓
10. Query Rewrite






48. ETL Stored Procedures 🏗️
এখান থেকে Stored Procedure Data Engineering-এর core অংশে ঢুকে যায়।
Typical architecture:
Source
  ↓
Bronze
  ↓
Silver
  ↓
Gold
  ↓
Power BI / Reporting
Stored Procedures:
ETL.usp_Load_Bronze
        ↓
ETL.usp_Load_Silver
        ↓
ETL.usp_Load_Gold
        ↓
ETL.usp_Master_Load





49. Bronze → Silver
ধরি Bronze table:
CREATE SCHEMA Bronze;
GO

CREATE TABLE Bronze.Customers
(
    CustomerID INT,
    CustomerName VARCHAR(150),
    Email VARCHAR(200),
    Country VARCHAR(100)
);
GO
Silver table:
CREATE SCHEMA Silver;
GO

CREATE TABLE Silver.Customers
(
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(150),
    Email VARCHAR(200),
    Country VARCHAR(100),
    LoadDate DATETIME2 DEFAULT SYSDATETIME()
);
GO
Procedure:
/* ============================================================
   BRONZE → SILVER
   Clean and load customer data
   ============================================================ */
CREATE OR ALTER PROCEDURE ETL.usp_Load_Silver_Customers
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO Silver.Customers
    (
        CustomerID,
        CustomerName,
        Email,
        Country
    )
    SELECT
        CustomerID,
        TRIM(CustomerName),
        LOWER(TRIM(Email)),
        TRIM(Country)
    FROM Bronze.Customers;

END;
GO









50. Silver → Gold ⭐
Gold সাধারণত analytics-ready layer।
CREATE SCHEMA Gold;
GO

CREATE TABLE Gold.DimCustomer
(
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    CustomerName VARCHAR(150),
    Email VARCHAR(200),
    Country VARCHAR(100)
);
GO
Procedure:
/* ============================================================
   SILVER → GOLD
   Load customer dimension
   ============================================================ */
CREATE OR ALTER PROCEDURE ETL.usp_Load_Gold_DimCustomer
AS
BEGIN

    SET NOCOUNT ON;

    INSERT INTO Gold.DimCustomer
    (
        CustomerID,
        CustomerName,
        Email,
        Country
    )
    SELECT
        CustomerID,
        CustomerName,
        Email,
        Country
    FROM Silver.Customers;

END;
GO





51. SCD Type 1
SCD Type 1 = old value overwrite।
উদাহরণ:
Before:
Customer 101 → Kuwait

After:
Customer 101 → UAE
Old value রাখব না।
Procedure pattern:
/* ============================================================
   SCD TYPE 1
   UPDATE existing records
   INSERT new records
   ============================================================ */
CREATE OR ALTER PROCEDURE ETL.usp_SCD1_Customer
AS
BEGIN

    SET NOCOUNT ON;

    -- UPDATE existing customers
    UPDATE g
    SET
        g.CustomerName = s.CustomerName,
        g.Email = s.Email,
        g.Country = s.Country
    FROM Gold.DimCustomer AS g
    INNER JOIN Silver.Customers AS s
        ON g.CustomerID = s.CustomerID;

    -- INSERT new customers
    INSERT INTO Gold.DimCustomer
    (
        CustomerID,
        CustomerName,
        Email,
        Country
    )
    SELECT
        s.CustomerID,
        s.CustomerName,
        s.Email,
        s.Country
    FROM Silver.Customers AS s
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM Gold.DimCustomer AS g
        WHERE g.CustomerID = s.CustomerID
    );

END;
GO





52. SCD Type 2 🔥
SCD Type 2 history preserve করে।
Typical columns:
CustomerKey
CustomerID
CustomerName
Country
ValidFrom
ValidTo
IsCurrent
Example:
CustomerID = 101

Row 1:
Kuwait
2025-01-01
2026-06-30
0

Row 2:
UAE
2026-07-01
9999-12-31
1
Procedure-এ সাধারণত:
Detect Change
     ↓
Expire Old Row
     ↓
Insert New Row






53. Fact / Dimension Loading
Data Warehouse:
              DimCustomer
                   │
                   │
DimProduct ─── FactSales ─── DimDate
                   │
              DimEmployee


  
Stored Procedures:
ETL.usp_Load_DimCustomer
ETL.usp_Load_DimProduct
ETL.usp_Load_DimDate
ETL.usp_Load_FactSales
এগুলো dependency অনুযায়ী execute করা হয়।







54. Master ETL Procedure 🏭
সব procedure একসাথে চালানোর জন্য master procedure:
/* ============================================================
   MASTER ETL PROCEDURE
   Orchestrates complete ETL pipeline
   ============================================================ */
CREATE OR ALTER PROCEDURE ETL.usp_MasterETL
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Step 1
        EXEC ETL.usp_Load_Silver_Customers;

        -- Step 2
        EXEC ETL.usp_Load_Gold_DimCustomer;

        -- More ETL procedures
        -- EXEC ETL.usp_Load_Silver_Products;
        -- EXEC ETL.usp_Load_Gold_DimProduct;
        -- EXEC ETL.usp_Load_Gold_FactSales;

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH;

END;
GO







55. SQL Agent Scheduling ⏰
Production ETL-এ:
SQL Agent Job
      ↓
ETL.usp_MasterETL
      ↓
Bronze
      ↓
Silver
      ↓
Gold
      ↓
Power BI

  
Typical schedule:
01:00 AM → Bronze Load
01:30 AM → Silver Load
02:00 AM → Gold Load
02:30 AM → Data Quality Checks
03:00 AM → Power BI Refresh









56. Monitoring 📊
Production Stored Procedure monitoring-এর জন্য track করা যায়:
Procedure Name
Start Time
End Time
Duration
Status
Rows Processed
Error Message
উদাহরণ:
CREATE TABLE Audit.ETLLog
(
    ETLLogID BIGINT IDENTITY(1,1) PRIMARY KEY,
    ProcedureName SYSNAME,
    StartTime DATETIME2,
    EndTime DATETIME2,
    Status VARCHAR(20),
    RowsProcessed INT NULL,
    ErrorMessage NVARCHAR(4000) NULL
);
GO







57. Logging Architecture
Production architecture:
                 SQL Agent
                     │
                     ▼
             Master Procedure
                     │
        ┌────────────┼────────────┐
        ▼            ▼            ▼
      Bronze       Silver        Gold
        │            │            │
        └────────────┼────────────┘
                     ▼
                 Audit Log
                     │
          ┌──────────┴──────────┐
          ▼                     ▼
       ETL Log               Error Log









58. Production Deployment 🚀
Development environment:
DEV
 ↓
TEST / QA
 ↓
UAT
 ↓
PRODUCTION
Production deployment-এর সময়:

  
✅ Version Control
Stored Procedure scripts Git-এ রাখুন।
/sql
   /stored-procedures
      usp_GetCustomers.sql
      usp_CustomerRevenue.sql
      usp_Load_Silver.sql
      usp_Load_Gold.sql
      usp_MasterETL.sql

  
✅ Naming Convention
আমি recommend করব:
usp_GetCustomers
usp_GetCustomerOrders
usp_InsertCustomer
usp_UpdateCustomer
usp_DeleteCustomer

usp_Load_Silver_Customers
usp_Load_Gold_DimCustomer
usp_Load_Gold_FactSales

usp_MasterETL
sp_ prefix দিয়ে নিজের procedure নাম না দেওয়াই ভালো; SQL Server-এর system procedures-এর সঙ্গে naming collision হতে পারে।








59. Complete Stored Procedure Architecture 🧩
আপনার পুরো roadmap-টাকে বাস্তব project হিসেবে দেখলে:
                     STORED PROCEDURE
                            │
       ┌────────────────────┼────────────────────┐
       │                    │                    │
   Reporting              CRUD                 ETL
       │                    │                    │
       ▼                    ▼                    ▼
 SELECT/JOIN            INSERT                Bronze
 GROUP BY               UPDATE                   ↓
 CTE                    DELETE                Silver
 CASE                                            ↓
 Window                                      Gold
       │                                         │
       └──────────────┬──────────────────────────┘
                      │
                Error Handling
                      │
                TRY / CATCH
                      │
                    THROW
                      │
                Transactions
                      │
                COMMIT/ROLLBACK
                      │
                Performance
                      │
          Execution Plan / Index
                      │
              Parameter Sniffing
                      │
                  Security
                      │
              GRANT EXECUTE
                      │
               SQL Agent
                      │
                 Monitoring
                      │
                Production






60. সবচেয়ে গুরুত্বপূর্ণ Production Pattern ⭐⭐⭐⭐⭐
একজন SQL Server Data Engineer হিসেবে এই pattern অবশ্যই আয়ত্ত করুন:
CREATE OR ALTER PROCEDURE ETL.usp_Load_Data
AS
BEGIN

    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        /* ================================================
           1. Extract
           ================================================ */

        /* ================================================
           2. Transform
           ================================================ */

        /* ================================================
           3. Validate
           ================================================ */

        /* ================================================
           4. Load
           ================================================ */

        /* ================================================
           5. Logging
           ================================================ */

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        /* ================================================
           Error Logging
           ================================================ */

        THROW;

    END CATCH;

END;
GO
এটাই আপনার production-grade Stored Procedure skeleton।



