1. GETDATE() — Current Server Date & Time
  
কী?
GETDATE() SQL Server server-এর current local date/time দেয়।
/* ============================================================
   TASK 1
   Current server date and time
   ============================================================ */

SELECT
    GETDATE() AS CurrentDateTime;


Real Business Use
SELECT
    OrderID,
    CreationTime,
    '2025-08-20' AS HardCodedDate,
    GETDATE() AS Today
FROM Sales.Orders;


📌 Use case:  
ETL execution timestamp
Last refresh time
Audit columns
Current reporting date





2. Date Values
Date এবং timestamp আলাদা করে বুঝতে হবে।
Data Type	Example
DATE	2025-08-20
DATETIME2	2025-08-20 14:30:25
DATETIMEOFFSET	2025-08-20 14:30:25 +03:00


SELECT
    OrderID,
    OrderDate,
    CreationTime,
    ShipDate
FROM Sales.Orders;








3. DATETRUNC()
DATETRUNC() একটি date/time value-কে নির্দিষ্ট period-এর শুরুতে নিয়ে আসে।
SQL Server 2022+

-- Year
SELECT
    OrderID,
    CreationTime,
    DATETRUNC(year, CreationTime) AS YearStart
FROM Sales.Orders;

2025-08-20 16:25:30
  
হবে:
2025-01-01 00:00:00

  
-- Month
SELECT
    OrderID,
    CreationTime,
    DATETRUNC(month, CreationTime) AS MonthStart
FROM Sales.Orders;


-- Day
SELECT
    OrderID,
    CreationTime,
    DATETRUNC(day, CreationTime) AS DayStart
FROM Sales.Orders;


-- Minute
SELECT
    OrderID,
    CreationTime,
    DATETRUNC(minute, CreationTime) AS MinuteStart
FROM Sales.Orders;







4. Date Part Extraction
DATENAME()
Date part-এর text name দেয়।
  
SELECT
    OrderID,
    CreationTime,

    DATENAME(month, CreationTime) AS MonthName,
    DATENAME(weekday, CreationTime) AS WeekdayName,
    DATENAME(day, CreationTime) AS DayName,
    DATENAME(year, CreationTime) AS YearName
FROM Sales.Orders;


Example:
August
Thursday
20
2025








5. DATEPART()
Numeric date part বের করে।

  
SELECT
    OrderID,
    CreationTime,

    DATEPART(year, CreationTime) AS OrderYear,
    DATEPART(month, CreationTime) AS OrderMonth,
    DATEPART(day, CreationTime) AS OrderDay,
    DATEPART(hour, CreationTime) AS OrderHour,
    DATEPART(quarter, CreationTime) AS OrderQuarter,
    DATEPART(week, CreationTime) AS OrderWeek
FROM Sales.Orders;







6. YEAR(), MONTH(), DAY()
সবচেয়ে সহজ date extraction।

  
SELECT
    OrderID,
    OrderDate,

    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    DAY(OrderDate) AS OrderDay
FROM Sales.Orders;


কখন কোনটা?
Function	           Result
YEAR()	             2025
MONTH()	             8
DAY()	               20
DATEPART()	         বিভিন্ন date part
DATENAME()	         Text name








7. DATETRUNC() দিয়ে Aggregation
-- Year-wise orders:
/* ============================================================
   YEAR-WISE ORDER COUNT
   ============================================================ */

SELECT
    DATETRUNC(year, CreationTime) AS OrderYear,
    COUNT(*) AS OrderCount
FROM Sales.Orders
GROUP BY
    DATETRUNC(year, CreationTime);



-- Month-wise:
SELECT
    DATETRUNC(month, CreationTime) AS OrderMonth,
    COUNT(*) AS OrderCount
FROM Sales.Orders
GROUP BY
    DATETRUNC(month, CreationTime);

Data Engineer Use
ETL partition বা monthly aggregation-এর জন্য DATETRUNC() খুব useful।







8. EOMONTH()
একটি date-এর শেষ দিন বের করে।
  
SELECT
    OrderID,
    OrderDate,
    EOMONTH(OrderDate) AS EndOfMonth
FROM Sales.Orders;

Example:
2025-02-14 → 2025-02-28
2025-08-20 → 2025-08-31







9. Date Parts — Business Analysis
  
-- Year-wise Orders
SELECT
    YEAR(OrderDate) AS OrderYear,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY YEAR(OrderDate);


-- Month-wise Orders
SELECT
    MONTH(OrderDate) AS OrderMonth,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY MONTH(OrderDate);


-- Month Name
SELECT
    DATENAME(month, OrderDate) AS OrderMonth,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY DATENAME(month, OrderDate);


⚠️ Best Practice: শুধু month name দিয়ে grouping করলে January 2025 এবং January 2026 একসাথে চলে আসবে।
  
ভালো:
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(*) AS TotalOrders
FROM Sales.Orders
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate);







10. February Orders
/* ============================================================
   FEBRUARY ORDERS
   ============================================================ */

SELECT *
FROM Sales.Orders
WHERE MONTH(OrderDate) = 2;

⚠️ Production reporting-এ বড় table হলে date range filtering সাধারণত বেশি ভালো।







11. FORMAT()
Date-কে presentation-friendly text বানাতে ব্যবহার করা যায়।
  
SELECT
    OrderID,
    CreationTime,

    FORMAT(CreationTime, 'MM-dd-yyyy') AS USA_Format,
    FORMAT(CreationTime, 'dd-MM-yyyy') AS EURO_Format,
    FORMAT(CreationTime, 'dd') AS DayNumber,
    FORMAT(CreationTime, 'ddd') AS ShortDay,
    FORMAT(CreationTime, 'dddd') AS FullDay,
    FORMAT(CreationTime, 'MM') AS MonthNumber,
    FORMAT(CreationTime, 'MMM') AS ShortMonth,
    FORMAT(CreationTime, 'MMMM') AS FullMonth
FROM Sales.Orders;

Example:
08-20-2025
20-08-2025
Wed
Wednesday
Aug
August



  
Custom Format
SELECT
    OrderID,
    CreationTime,

    'Day '
    + FORMAT(CreationTime, 'ddd MMM')
    + ' Q'
    + DATENAME(quarter, CreationTime)
    + ' '
    + FORMAT(CreationTime, 'yyyy hh:mm:ss tt')
    AS CustomFormat

FROM Sales.Orders;

⚠️ Best Practice
FORMAT() presentation-এর জন্য ভালো, কিন্তু বড় dataset-এ heavy query transformation-এর জন্য FORMAT() avoid করা ভালো।








12. CONVERT()
Data type conversion-এর জন্য খুব গুরুত্বপূর্ণ।
  
SELECT
    CONVERT(INT, '123') AS StringToInt,
    CONVERT(DATE, '2025-08-20') AS StringToDate,

    CreationTime,

    CONVERT(DATE, CreationTime) AS DateOnly,

    CONVERT(VARCHAR, CreationTime, 32) AS Style32,
    CONVERT(VARCHAR, CreationTime, 34) AS Style34
FROM Sales.Orders;

Data Engineering Use
Raw CSV/JSON/API data থেকে date conversion করার সময় খুব common।






13. CAST()
CAST() type conversion-এর standard syntax।

  
SELECT
    CAST('123' AS INT) AS StringToInt,

    CAST(123 AS VARCHAR(20)) AS IntToString,

    CAST('2025-08-20' AS DATE) AS StringToDate,

    CAST('2025-08-20' AS DATETIME2) AS StringToDatetime,

    CreationTime,

    CAST(CreationTime AS DATE) AS DateOnly
FROM Sales.Orders;


CAST বনাম CONVERT
  
বিষয়	                 CAST	                 CONVERT
Standard SQL	         ✅	                   ❌
SQL Server specific	   ❌	                   ✅
Style code	           ❌	                   ✅
Readability	           ⭐⭐⭐⭐⭐	         ⭐⭐⭐⭐
SQL Server ETL	       ⭐⭐⭐⭐⭐	         ⭐⭐⭐⭐⭐







14. DATEADD()
একটি date-এর সাথে date interval যোগ/বিয়োগ করে।
  
SELECT
    OrderID,
    OrderDate,

    DATEADD(day, -10, OrderDate) AS TenDaysBefore,

    DATEADD(month, 3, OrderDate) AS ThreeMonthsLater,

    DATEADD(year, 2, OrderDate) AS TwoYearsLater
FROM Sales.Orders;


Real Business Example
Expected delivery date:
  
SELECT
    OrderID,
    OrderDate,
    DATEADD(day, 3, OrderDate) AS ExpectedDeliveryDate
FROM Sales.Orders;







15. DATEDIFF()
দুই date-এর মধ্যে difference বের করে।
Shipping Duration
  
SELECT
    OrderID,
    OrderDate,
    ShipDate,

    DATEDIFF(day, OrderDate, ShipDate) AS ShippingDays
FROM Sales.Orders;


Average Shipping Days  
SELECT
    MONTH(OrderDate) AS OrderMonth,

    AVG(
        DATEDIFF(day, OrderDate, ShipDate)
    ) AS AvgShippingDays

FROM Sales.Orders
GROUP BY MONTH(OrderDate);








16. Employee Age
  
SELECT
    EmployeeID,
    EmployeeName,
    BirthDate,

    DATEDIFF(
        year,
        BirthDate,
        GETDATE()
    ) AS ApproxAge
FROM Sales.Employees;

⚠️ এটি birthday হয়েছে কিনা account করে না। Exact age calculation দরকার হলে business logic অনুযায়ী date comparison করতে হবে।







17. Order-to-Order Time Gap
এখানে LAG() supporting window function হিসেবে ব্যবহার হচ্ছে।
/* ============================================================
   TIME GAP ANALYSIS
   ============================================================ */

SELECT
    OrderID,
    OrderDate AS CurrentOrderDate,

    LAG(OrderDate)
        OVER (ORDER BY OrderDate) AS PreviousOrderDate,

    DATEDIFF
    (
        day,
        LAG(OrderDate)
            OVER (ORDER BY OrderDate),
        OrderDate
    ) AS DaysBetweenOrders

FROM Sales.Orders;

Business Use
Customer/order frequency
Operational monitoring
Sales activity gap
Pipeline analysis








18. ISDATE()
কোনো value valid date হিসেবে interpret করা যায় কিনা পরীক্ষা করে।
  
SELECT
    OrderDate,
    ISDATE(OrderDate) AS IsValidDate
FROM
(
    SELECT '2025-08-20' AS OrderDate
    UNION
    SELECT '2025-08-21'
    UNION
    SELECT '2025-08-23'
    UNION
    SELECT '2025-08'
) AS T;


⚠️ Important
ISDATE() validation করার সময় target data type-এর বিষয়টিও মাথায় রাখতে হবে।
Modern ETL pipeline-এ invalid raw date safely convert করার জন্য TRY_CONVERT() / TRY_CAST() বেশি practical।









19. GETUTCDATE()
UTC current datetime দেয়।
  
SELECT
    GETUTCDATE() AS CurrentUTCDateTime;

Data Engineering Use
Distributed system-এ UTC timestamp রাখা useful।








20. SYSDATETIME()
GETDATE()-এর তুলনায় বেশি precision দেয়।
  
SELECT
    SYSDATETIME() AS SystemDateTime;


Difference
SELECT
    GETDATE() AS GETDATE_Value,
    SYSDATETIME() AS SYSDATETIME_Value;









21. SYSUTCDATETIME()
UTC + high precision।
  
SELECT
    SYSUTCDATETIME() AS CurrentUTCDateTime;

Data warehouse audit columns-এর জন্য useful।







22.CURRENT_TIMESTAMP
SQL standard-style current timestamp।
  
SELECT
    CURRENT_TIMESTAMP AS CurrentDateTime;

SQL Server-এ এটি GETDATE()-এর equivalent হিসেবে কাজ করে।





23. DATEFROMPARTS()
Year, Month, Day থেকে DATE তৈরি করে।
SELECT
    DATEFROMPARTS
    (
        2025,
        8,
        20
    ) AS OrderDate;


Dynamic Example
SELECT
    DATEFROMPARTS
    (
        YEAR(OrderDate),
        MONTH(OrderDate),
        1
    ) AS MonthStart

FROM Sales.Orders;





24. DATETIMEFROMPARTS()
Year → Month → Day → Hour → Minute → Second → Fraction তৈরি করে।
  
SELECT
    DATETIMEFROMPARTS
    (
        2025,       -- Year
        8,          -- Month
        20,         -- Day
        14,         -- Hour
        30,         -- Minute
        25,         -- Second
        0,          -- Millisecond
        0           -- Precision
    ) AS CreatedDateTime;







25. TIMEFROMPARTS()
শুধু time তৈরি করে।
  
SELECT
    TIMEFROMPARTS
    (
        14,     -- Hour
        30,     -- Minute
        25,     -- Seconds
        0,      -- Fraction
        0       -- Precision
    ) AS OrderTime;







26.EOMONTH() + DATEADD()
এটি অত্যন্ত গুরুত্বপূর্ণ business pattern।
Month Start
SELECT
    OrderDate,

    DATEADD
    (
        day,
        1,
        EOMONTH(OrderDate, -1)
    ) AS MonthStart

FROM Sales.Orders;


Month End
SELECT
    OrderDate,
    EOMONTH(OrderDate) AS MonthEnd
FROM Sales.Orders;


Next Month End
SELECT
    OrderDate,
    EOMONTH(OrderDate, 1) AS NextMonthEnd
FROM Sales.Orders;






27. DATE_BUCKET()
DATE_BUCKET() date/time data-কে fixed-size bucket-এ group করতে সাহায্য করে।
SQL Server 2022+

প্রতি 3 মাসে bucket
SELECT
    DATE_BUCKET
    (
        quarter,
        1,
        OrderDate
    ) AS OrderQuarter,

    COUNT(*) AS TotalOrders

FROM Sales.Orders

GROUP BY
    DATE_BUCKET
    (
        quarter,
        1,
        OrderDate
    );



Monthly Bucket
SELECT
    DATE_BUCKET
    (
        month,
        1,
        OrderDate
    ) AS MonthBucket,

    COUNT(*) AS TotalOrders

FROM Sales.Orders

GROUP BY
    DATE_BUCKET
    (
        month,
        1,
        OrderDate
    );
📌 Use case: Time-series aggregation এবং evenly sized time buckets।










28. AT TIME ZONE
Time zone conversion-এর জন্য গুরুত্বপূর্ণ।
SELECT
    CreationTime,

    CreationTime
        AT TIME ZONE 'Arab Standard Time'
        AS KuwaitTime

FROM Sales.Orders;

Kuwait-এর Windows time-zone ID:
Arab Standard Time





29. SWITCHOFFSET()
datetimeoffset value-এর offset পরিবর্তন করে।
SELECT
    SWITCHOFFSET
    (
        '2025-08-20 14:30:00 +03:00',
        '+00:00'
    ) AS UTCDateTime;


আরেকটি:
SELECT
    SWITCHOFFSET
    (
        '2025-08-20 14:30:00 +00:00',
        '+03:00'
    ) AS KuwaitDateTime;







30. TODATETIMEOFFSET()
একটি datetime value-কে specified offset সহ datetimeoffset বানায়।
SELECT
    TODATETIMEOFFSET
    (
        CAST('2025-08-20 14:30:00' AS DATETIME2),
        '+03:00'
    ) AS KuwaitDateTime;






31. TRY_CONVERT()
Invalid conversion হলে query fail না করে NULL দেয়।
SELECT
    TRY_CONVERT(INT, '123') AS ValidNumber,

    TRY_CONVERT(INT, 'ABC') AS InvalidNumber,

    TRY_CONVERT(DATE, '2025-08-20') AS ValidDate,

    TRY_CONVERT(DATE, '2025-99-99') AS InvalidDate;


Result:
123
NULL
2025-08-20
NULL
ETL Use
  
SELECT
    TRY_CONVERT(DATE, '2025-08-20') AS CleanOrderDate;

Raw data cleaning-এর জন্য খুব গুরুত্বপূর্ণ।





32. TRY_CAST()
CAST()-এর safe version।
  
SELECT
    TRY_CAST('123' AS INT) AS ValidNumber,

    TRY_CAST('ABC' AS INT) AS InvalidNumber,

    TRY_CAST('2025-08-20' AS DATE) AS ValidDate,

    TRY_CAST('WrongDate' AS DATE) AS InvalidDate;


CAST বনাম TRY_CAST
CAST       → Conversion fail হলে error
TRY_CAST   → Conversion fail হলে NULL

  
Data Engineering Best Practice
  
Raw → Clean transformation:
SELECT
    TRY_CAST('2025-08-20' AS DATE) AS CleanDate;







33.datetime2
datetime2 হলো SQL Server-এ modern date-time data type।
  
CREATE TABLE Sales.OrderAudit
(
    OrderID INT,
    CreatedAt DATETIME2(7)
);

Insert:
INSERT INTO Sales.OrderAudit
(
    OrderID,
    CreatedAt
)
VALUES
(
    1001,
    SYSDATETIME()
);


দেখুন:
SELECT *
FROM Sales.OrderAudit;


কেন datetime2?
বেশি precision
পুরনো datetime-এর চেয়ে ভালো range
modern SQL Server design-এর জন্য preferred







34. datetimeoffset
Date + Time + UTC Offset সংরক্ষণ করে।
CREATE TABLE Sales.OrderTimeZone
(
    OrderID INT,
    OrderCreatedAt DATETIMEOFFSET(7)
);


Insert:
INSERT INTO Sales.OrderTimeZone
(
    OrderID,
    OrderCreatedAt
)
VALUES
(
    1001,
    TODATETIMEOFFSET
    (
        CAST('2025-08-20 14:30:00' AS DATETIME2),
        '+03:00'
    )
);


Check:
SELECT *
FROM Sales.OrderTimeZone;


Example:
2025-08-20 14:30:00 +03:00
কখন ব্যবহার করবেন?
🌍 Global applications
🌍 Multi-country data
🌍 Event timestamps
🌍 Distributed data pipelines








35. Date Range Filtering
এটি Data Analyst এবং Data Engineer—দুই ক্ষেত্রেই অত্যন্ত গুরুত্বপূর্ণ।
নির্দিষ্ট Date Range
  
SELECT
    *
FROM Sales.Orders
WHERE OrderDate >= '2025-08-01'
  AND OrderDate <  '2025-09-01';


এটি August 2025-এর সব order দেবে।
Best Practice
এভাবে না:
WHERE MONTH(OrderDate) = 8

  
বরং:
WHERE OrderDate >= '2025-08-01'
  AND OrderDate <  '2025-09-01'
কারণ column-এর উপর function প্রয়োগ না করলে index ব্যবহার করার সুযোগ বেশি থাকে।









36. Year Filtering
SELECT
    *
FROM Sales.Orders
WHERE OrderDate >= '2025-01-01'
  AND OrderDate <  '2026-01-01';





37. Month/Year Analysis
SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,

    COUNT(*) AS TotalOrders,

    SUM(OrderAmount) AS TotalSales
FROM Sales.Orders
GROUP BY
    YEAR(OrderDate),
    MONTH(OrderDate)
ORDER BY
    OrderYear,
    OrderMonth;

এটাই বাস্তব Sales Dashboard-এর অন্যতম basic query pattern।








38. Fiscal Year Calculation
ধরি company-এর fiscal year July → June।
July 2025 থেকে FY2026 শুরু।
SELECT
    OrderID,
    OrderDate,

    YEAR
    (
        DATEADD
        (
            month,
            6,
            OrderDate
        )
    ) AS FiscalYear

FROM Sales.Orders;


-- Fiscal Month
SELECT
    OrderID,
    OrderDate,

    MONTH
    (
        DATEADD
        (
            month,
            6,
            OrderDate
        )
    ) AS FiscalMonth

FROM Sales.Orders;







39. Date Dimension
Data Warehouse-এ একটি dedicated Date Dimension থাকা industry-standard approach।
/* ============================================================
   DATE DIMENSION
   ============================================================ */

CREATE TABLE Sales.DateDimension
(
    DateKey        INT PRIMARY KEY,
    FullDate       DATE,
    YearNumber     INT,
    QuarterNumber  INT,
    MonthNumber    INT,
    MonthName      VARCHAR(20),
    DayNumber      INT,
    WeekNumber     INT
);


GO
Sample date dimension data:
INSERT INTO Sales.DateDimension
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    DayNumber,
    WeekNumber
)
VALUES
(20250101, '2025-01-01', 2025, 1, 1,  'January',  1, 1),
(20250102, '2025-01-02', 2025, 1, 1,  'January',  2, 1),
(20250103, '2025-01-03', 2025, 1, 1,  'January',  3, 1),
(20250104, '2025-01-04', 2025, 1, 1,  'January',  4, 1),
(20250105, '2025-01-05', 2025, 1, 1,  'January',  5, 1),

(20250201, '2025-02-01', 2025, 1, 2,  'February', 1, 5),
(20250202, '2025-02-02', 2025, 1, 2,  'February', 2, 5),
(20250203, '2025-02-03', 2025, 1, 2,  'February', 3, 6),

(20250301, '2025-03-01', 2025, 1, 3,  'March',    1, 9),
(20250302, '2025-03-02', 2025, 1, 3,  'March',    2, 9),

(20250401, '2025-04-01', 2025, 2, 4,  'April',    1, 14),
(20250501, '2025-05-01', 2025, 2, 5,  'May',      1, 18),
(20250601, '2025-06-01', 2025, 2, 6,  'June',     1, 22),

(20250701, '2025-07-01', 2025, 3, 7,  'July',     1, 27),
(20250801, '2025-08-01', 2025, 3, 8,  'August',   1, 31),
(20250901, '2025-09-01', 2025, 3, 9,  'September',1, 36),

(20251001, '2025-10-01', 2025, 4, 10, 'October',  1, 40),
(20251101, '2025-11-01', 2025, 4, 11, 'November', 1, 44),
(20251201, '2025-12-01', 2025, 4, 12, 'December', 1, 48),

(20260101, '2026-01-01', 2026, 1, 1,  'January',  1, 1),
(20260201, '2026-02-01', 2026, 1, 2,  'February', 1, 5);
GO

  
তারপর Orders-এর সাথে date dimension ব্যবহার:
SELECT
    D.YearNumber,
    D.MonthNumber,
    D.MonthName,
    COUNT(O.OrderID) AS TotalOrders,
    SUM(O.OrderAmount) AS TotalSales

FROM Sales.Orders AS O

INNER JOIN Sales.DateDimension AS D
    ON O.OrderDate = D.FullDate

GROUP BY
    D.YearNumber,
    D.MonthNumber,
    D.MonthName;






40. Date Dimension দিয়ে Fiscal Analysis
SELECT
    FullDate,

    YearNumber,

    MonthNumber,

    CASE
        WHEN MonthNumber >= 7
            THEN YearNumber + 1
        ELSE YearNumber
    END AS FiscalYear

FROM Sales.DateDimension;
এখানে CASE শুধু business classification-এর জন্য supporting SQL syntax হিসেবে ব্যবহৃত হয়েছে।










41. সব গুরুত্বপূর্ণ Function একসাথে Revision
  
#	               Function / Feature	              প্রধান কাজ
1	               GETDATE()	                      Current local datetime
2	               DATETRUNC()	                    Period-এর শুরু
3	               DATENAME()	                      Date part-এর name
4	               DATEPART()	                      Numeric date part
5	               YEAR()	                          Year
6	               MONTH()	                        Month
7	               DAY()	                          Day
8	               EOMONTH()	                      Month end
9	               FORMAT()	                        Presentation formatting
10	             CONVERT()	                      Type conversion + style
11	             CAST()	                          Type conversion
12	             DATEADD()	                      Date add/subtract
13	             DATEDIFF()	                      Date difference
14	             ISDATE()	                        Date validation
15	             GETUTCDATE()	                    Current UTC
16	             SYSDATETIME()	                  High precision local datetime
17	             SYSUTCDATETIME()	                High precision UTC
18	             CURRENT_TIMESTAMP	              Current datetime
19	             DATEFROMPARTS()	                DATE তৈরি
20	             DATETIMEFROMPARTS()	            DATETIME তৈরি
21	             TIMEFROMPARTS()	                TIME তৈরি
22	             EOMONTH()+DATEADD()	            Month boundary
23	             DATE_BUCKET()	                  Time bucket
24	             AT TIME ZONE	                    Time-zone conversion
25	             SWITCHOFFSET()	                  Offset পরিবর্তন
26	             TODATETIMEOFFSET()	              datetime → offset datetime
27	             TRY_CONVERT()	                  Safe conversion
28	            TRY_CAST()	                      Safe CAST
29	            datetime2	                        Modern datetime datatype
30	            datetimeoffset	                  Date + time + offset
31	            Date Range	                      Period filtering
32	            Fiscal Calculation	              Financial calendar
33	            Date Dimension	                  Data warehouse calendar






🎯 সবচেয়ে গুরুত্বপূর্ণ Best Practices
🟢 1. Storage
ভালো:
OrderDate DATE
CreationTime DATETIME2(7)
OrderCreatedAt DATETIMEOFFSET(7)

  
🟢 2. Date Filtering
Preferred:
WHERE OrderDate >= '2025-08-01'
  AND OrderDate <  '2025-09-01'

  
🟢 3. ETL Conversion
Raw data:
TRY_CONVERT(DATE, RawDate)
Invalid data হলে NULL পাওয়া যাবে, pipeline অযথা fail করবে না।

  
🟢 4. Presentation
FORMAT() ব্যবহার করুন presentation/reporting layer-এ।
FORMAT(OrderDate, 'MMM yyyy')
কিন্তু database filtering/large-scale transformation-এ অপ্রয়োজনীয় FORMAT() এড়িয়ে চলুন।

  
🟢 5. Data Warehouse
Production Data Warehouse-এ:
Fact Sales
     ↓
Date Dimension
     ↓
Year / Quarter / Month / Week / Day
     ↓
Fiscal Calendar
অর্থাৎ প্রতিটি fact table-এ date dimension-এর সাথে relationship রাখা অত্যন্ত গুরুত্বপূর্ণ।






