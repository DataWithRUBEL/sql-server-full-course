1. আমরা একটি Retail & E-Commerce Company ধরে নিচ্ছি।
আমাদের data model:
dt.Departments
      │
      └── dt.Employees
              │
              ├── dt.EmployeeAttendance
              │
              └── dt.Orders
                       │
                       └── dt.OrderItems
                                │
                                └── dt.Products

dt.Customers
      │
      └── dt.Orders

dt.SystemEvents
এতে আমরা বাস্তব কাজের মতো প্রশ্ন করতে পারব:
- কোন মাসে সবচেয়ে বেশি sales?
- Employee কত বছর ধরে কাজ করছে?
- Order delivery কতদিন নিয়েছে?
- Last 30 days-এর orders?
- Month-end sales?
- UTC থেকে Kuwait time?
- বিভিন্ন timezone-এর order time?
- Invalid date validation?
- NULL date handling?
- Daily/monthly aggregation?
- Incremental ETL watermark?




2. Verify All Data
-- =========================================================
-- Verify the tables and sample records
-- =========================================================

SELECT * FROM dt.Departments;
SELECT * FROM dt.Employees;
SELECT * FROM dt.Customers;
SELECT * FROM dt.Products;
SELECT * FROM dt.Orders;
SELECT * FROM dt.OrderItems;
SELECT * FROM dt.EmployeeAttendance;
SELECT * FROM dt.SystemEvents;
GO




-- Date/Time Data Types 🕒  
3. DATE
শুধু date দরকার হলে DATE।
Syntax
-- =========================================================
-- DATE stores date only
-- Format: YYYY-MM-DD
-- =========================================================
DECLARE @MyDate DATE = '2026-08-29';

SELECT @MyDate AS MyDate;


ব্যবহার
-- =========================================================
-- Find orders placed on a specific business date
-- =========================================================
SELECT *
FROM dt.Orders
WHERE OrderDate = '2026-08-10';

Best Practice
- Business date হলে DATE
- BirthDate → DATE
- HireDate → DATE
- Holiday → DATE






4. TIME
শুধু সময় দরকার হলে।
-- =========================================================
-- TIME stores time without date
-- =========================================================
DECLARE @CurrentTime TIME(0) = '14:30:00';

SELECT @CurrentTime AS CurrentTime;


Real Example
-- =========================================================
-- Find orders placed during business hours
-- =========================================================
SELECT
    OrderID,
    OrderTime
FROM dt.Orders
WHERE OrderTime >= '09:00:00'
  AND OrderTime <  '18:00:00';




5. DATETIME
পুরনো/common date + time type।
-- =========================================================
-- DATETIME stores date and time
-- Precision is lower than DATETIME2
-- =========================================================
DECLARE @LegacyDateTime DATETIME =
    '2026-08-29 14:30:15';


SELECT @LegacyDateTime;


⚠️ Best Practice
নতুন system-এ সাধারণত:
DATETIME2 > DATETIME
ব্যবহার করা ভালো।






6. DATETIME2
SQL Server-এ high precision date/time-এর জন্য সাধারণত preferred।
-- =========================================================
-- DATETIME2 supports higher precision
-- =========================================================
DECLARE @PreciseDateTime DATETIME2(7) =
    '2026-08-29 14:30:15.1234567';

SELECT @PreciseDateTime;


কেন?
- বেশি precision
- ANSI-friendly
- DATETIME-এর চেয়ে flexible
- নতুন application/database-এর জন্য preferred






7. SMALLDATETIME
কম precision-এর পুরনো type।
-- =========================================================
-- SMALLDATETIME stores date and time
-- Seconds are not preserved
-- =========================================================
DECLARE @SmallDateTime SMALLDATETIME =
    '2026-08-29 14:30:45';


SELECT @SmallDateTime;

⚠️ SMALLDATETIME সাধারণত নতুন design-এ avoid করা ভালো 
যদি minute-level legacy compatibility প্রয়োজন না হয়।






8. DATETIMEOFFSET
Date + time + timezone offset।
-- =========================================================
-- DATETIMEOFFSET stores date/time with timezone offset
-- =========================================================
DECLARE @OffsetTime DATETIMEOFFSET =
    '2026-08-29 14:30:15 +03:00';

SELECT @OffsetTime;

Real-world
2026-08-29 14:30:15 +03:00
                         ↑
                    UTC offset
Multi-country application-এ অত্যন্ত useful।






-- Current Date/Time Functions 🕐
9. GETDATE()
বর্তমান server local date/time।
Syntax
-- =========================================================
-- GETDATE returns current server local date/time
-- =========================================================
SELECT GETDATE() AS CurrentServerDateTime;






10. CURRENT_TIMESTAMP
GETDATE()-এর ANSI SQL equivalent।
-- =========================================================
-- CURRENT_TIMESTAMP returns current server date/time
-- Function-style syntax is not required
-- =========================================================
SELECT CURRENT_TIMESTAMP AS CurrentDateTime;


Compare
-- =========================================================
-- Compare GETDATE and CURRENT_TIMESTAMP
-- =========================================================
SELECT
    GETDATE() AS GETDATE_Value,
    CURRENT_TIMESTAMP AS CURRENT_TIMESTAMP_Value;






11. GETUTCDATE()
UTC current time।
-- =========================================================
-- GETUTCDATE returns current UTC date/time
-- =========================================================
SELECT GETUTCDATE() AS CurrentUTCDateTime;





12. SYSDATETIME()
Higher precision local server time।
-- =========================================================
-- SYSDATETIME returns high precision local server time
-- =========================================================
SELECT SYSDATETIME() AS CurrentSystemDateTime;







13. SYSUTCDATETIME()
High precision UTC।
-- =========================================================
-- SYSUTCDATETIME returns high precision UTC date/time
-- =========================================================
SELECT SYSUTCDATETIME() AS CurrentUTCDateTime;







14. SYSDATETIMEOFFSET()
Local server date/time + offset।
-- =========================================================
-- SYSDATETIMEOFFSET returns current date/time with offset
-- =========================================================
SELECT SYSDATETIMEOFFSET() AS CurrentDateTimeWithOffset;






15. Practical Comparison
  
Function	             Local/UTC	        Precision	        Offset
GETDATE()	             Local	            Lower	            ❌
CURRENT_TIMESTAMP	     Local	            Lower	            ❌
GETUTCDATE()	         UTC	              Lower	            ❌
SYSDATETIME()	         Local	            High	            ❌
SYSUTCDATETIME()	     UTC	              High	            ❌
SYSDATETIMEOFFSET()	   Local	            High	            ✅





16. Data Engineering Best Practice
ETL/audit systems-এ অনেক ক্ষেত্রে:
-- =========================================================
-- Preferred high-precision UTC audit timestamp
-- =========================================================
SELECT SYSUTCDATETIME() AS ETL_LoadTimeUTC;






-- Date Part Extraction 📅
17. YEAR()
-- =========================================================
-- Extract year from order date
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    YEAR(OrderDate) AS OrderYear
FROM dt.Orders;





18. MONTH()
-- =========================================================
-- Extract month number from order date
-- =========================================================
SELECT
    OrderID,
    MONTH(OrderDate) AS OrderMonth
FROM dt.Orders;





19. DAY()
-- =========================================================
-- Extract day number from order date
-- =========================================================
SELECT
    OrderID,
    DAY(OrderDate) AS OrderDay
FROM dt.Orders;






20. DATEPART()
একটি date-এর নির্দিষ্ট অংশ numeric হিসেবে বের করে।
Syntax
-- =========================================================
-- DATEPART syntax
-- =========================================================

DATEPART(datepart, date)
Example
-- =========================================================
-- Extract multiple date parts
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATEPART(YEAR, OrderDate) AS OrderYear,
    DATEPART(MONTH, OrderDate) AS OrderMonth,
    DATEPART(DAY, OrderDate) AS OrderDay,
    DATEPART(QUARTER, OrderDate) AS OrderQuarter,
    DATEPART(WEEK, OrderDate) AS OrderWeek,
    DATEPART(WEEKDAY, OrderDate) AS OrderWeekDay
FROM dt.Orders;



Useful dateparts
YEAR
QUARTER
MONTH
DAY
WEEK
WEEKDAY
HOUR
MINUTE
SECOND
MILLISECOND
MICROSECOND
NANOSECOND





21. DATENAME()
Date part-এর name return করে।
Syntax
-- =========================================================
-- DATENAME syntax
-- =========================================================

DATENAME(datepart, date)
Example
-- =========================================================
-- Get month and weekday names
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATENAME(MONTH, OrderDate) AS MonthName,
    DATENAME(WEEKDAY, OrderDate) AS WeekdayName
FROM dt.Orders;

DATEPART vs DATENAME
Function	               Result
DATEPART(MONTH, date)	   8
DATENAME(MONTH, date)	   August




-- Date Calculation 🔢
22. DATEADD()
Date-এর সাথে interval যোগ/বিয়োগ করে।
Syntax
-- =========================================================
-- DATEADD syntax
-- =========================================================

DATEADD(datepart, number, date)
30 days later
-- =========================================================
-- Calculate expected date 30 days after order
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATEADD(DAY, 30, OrderDate) AS DateAfter30Days
FROM dt.Orders;



7 days before
-- =========================================================
-- Calculate date seven days before order
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATEADD(DAY, -7, OrderDate) AS SevenDaysBefore
FROM dt.Orders;



Add month
-- =========================================================
-- Calculate one month after order
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATEADD(MONTH, 1, OrderDate) AS NextMonthDate
FROM dt.Orders;



Data Engineering Example
Incremental ETL window:
-- =========================================================
-- Calculate ETL extraction window
-- =========================================================
DECLARE @ETLStartDate DATE = '2026-08-01';

SELECT
    @ETLStartDate AS StartDate,
    DATEADD(DAY, 1, @ETLStartDate) AS NextDate;







23. DATEDIFF()
দুই date-এর boundary difference গণনা করে।
Syntax
-- =========================================================
-- DATEDIFF syntax
-- =========================================================

DATEDIFF(datepart, startdate, enddate)
Delivery days
-- =========================================================
-- Calculate delivery duration in days
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    ShipDate,
    DATEDIFF(DAY, OrderDate, ShipDate) AS DaysToShip
FROM dt.Orders;



Employee tenure
-- =========================================================
-- Calculate employee tenure in years
-- =========================================================
SELECT
    EmployeeID,
    EmployeeName,
    HireDate,
    DATEDIFF(YEAR, HireDate, GETDATE()) AS ApproxYears
FROM dt.Employees;



⚠️ এখানে একটি গুরুত্বপূর্ণ বিষয়:
DATEDIFF(YEAR, ...) exact completed years নয়; এটি year boundary count করে।
Exact birthday/anniversary logic-এর জন্য additional logic দরকার।






24. DATEDIFF_BIG()
DATEDIFF()-এর মতো, কিন্তু বড় BIGINT result দেয়।
Syntax
-- =========================================================
-- DATEDIFF_BIG syntax
-- =========================================================

DATEDIFF_BIG(datepart, startdate, enddate)
High precision example
-- =========================================================
-- Calculate microseconds between two timestamps
-- BIGINT is useful for very large intervals
-- =========================================================
SELECT
    DATEDIFF_BIG(
        MICROSECOND,
        '2000-01-01 00:00:00',
        '2026-08-29 00:00:00'
    ) AS TotalMicroseconds;


কোথায় useful?
- Large event logs
- Telemetry
- IoT
- Big time intervals
- High precision ETL/event processing





-- Date Boundary Functions 📆
25. EOMONTH()
একটি month-এর শেষ দিন return করে।
Syntax
-- =========================================================
-- EOMONTH syntax
-- =========================================================

EOMONTH(start_date [, month_to_add])
Example
-- =========================================================
-- Find month-end for each order
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    EOMONTH(OrderDate) AS MonthEnd
FROM dt.Orders;



Next month-end
-- =========================================================
-- Find end of next month
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    EOMONTH(OrderDate, 1) AS NextMonthEnd
FROM dt.Orders;



Month-start
EOMONTH() সরাসরি month-start দেয় না।
-- =========================================================
-- Calculate first day of the order month
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DATEADD(
        DAY,
        1,
        EOMONTH(OrderDate, -1)
    ) AS MonthStart
FROM dt.Orders;





26. DATETRUNC()
একটি date/time-এর নির্দিষ্ট অংশ truncate করে।
SQL Server 2022+
Syntax
-- =========================================================
-- DATETRUNC syntax
-- =========================================================

DATETRUNC(datepart, date)
Month
-- =========================================================
-- Truncate order date to month
-- Returns first moment of the month
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    DATETRUNC(MONTH, OrderDateTime) AS MonthStart
FROM dt.Orders;


Day
-- =========================================================
-- Truncate timestamp to day
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    DATETRUNC(DAY, OrderDateTime) AS DayStart
FROM dt.Orders;


Year
-- =========================================================
-- Truncate timestamp to year
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    DATETRUNC(YEAR, OrderDateTime) AS YearStart
FROM dt.Orders;


Week
-- =========================================================
-- Truncate timestamp to week
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    DATETRUNC(WEEK, OrderDateTime) AS WeekStart
FROM dt.Orders;





27. EOMONTH vs DATETRUNC
  
Function	             Purpose
EOMONTH()	             Month-এর শেষ দিন
DATETRUNC(MONTH,...)	 Month-এর শুরু
DATETRUNC(YEAR,...)	   Year-এর শুরু
DATETRUNC(DAY,...)	   Day-এর শুরু




  

-- Date/Time Construction 🏗️
28. DATEFROMPARTS()
Syntax
-- =========================================================
-- DATEFROMPARTS syntax
-- =========================================================

DATEFROMPARTS(year, month, day)
Example
-- =========================================================
-- Construct a date from year/month/day
-- =========================================================
SELECT
    DATEFROMPARTS(2026, 8, 29) AS ConstructedDate;


Real Data Example
-- =========================================================
-- Build a business date from separate date columns
-- =========================================================
SELECT
    DATEFROMPARTS(2026, 8, 29) AS BusinessDate;






29. TIMEFROMPARTS()
Syntax
-- =========================================================
-- TIMEFROMPARTS syntax
-- =========================================================

TIMEFROMPARTS(
    hour,
    minute,
    seconds,
    fractions,
    precision
)

  
Example
-- =========================================================
-- Construct high precision time
-- =========================================================
SELECT
    TIMEFROMPARTS(
        14,
        30,
        15,
        1234567,
        7
    ) AS ConstructedTime;






30. DATETIMEFROMPARTS()
Syntax
-- =========================================================
-- DATETIMEFROMPARTS syntax
-- =========================================================
DATETIMEFROMPARTS(
    year,
    month,
    day,
    hour,
    minute,
    seconds,
    milliseconds
)

  
Example
-- =========================================================
-- Construct DATETIME value
-- =========================================================
SELECT
    DATETIMEFROMPARTS(
        2026,
        8,
        29,
        14,
        30,
        15,
        123
    ) AS ConstructedDateTime;







31. DATETIME2FROMPARTS()
Syntax
-- =========================================================
-- DATETIME2FROMPARTS syntax
-- =========================================================
DATETIME2FROMPARTS(
    year,
    month,
    day,
    hour,
    minute,
    seconds,
    fractions,
    precision
)

  
Example
-- =========================================================
-- Construct high precision DATETIME2
-- =========================================================
SELECT
    DATETIME2FROMPARTS(
        2026,
        8,
        29,
        14,
        30,
        15,
        1234567,
        7
    ) AS ConstructedDateTime2;








32. DATETIMEOFFSETFROMPARTS()
Timezone-aware timestamp তৈরি করতে।
Syntax
-- =========================================================
-- DATETIMEOFFSETFROMPARTS syntax
-- =========================================================
DATETIMEOFFSETFROMPARTS(
    year,
    month,
    day,
    hour,
    minute,
    seconds,
    fractions,
    hour_offset,
    minute_offset,
    precision
)


  
Example
-- =========================================================
-- Construct timestamp with Kuwait UTC+03:00 offset
-- =========================================================
SELECT
    DATETIMEOFFSETFROMPARTS(
        2026,
        8,
        29,
        14,
        30,
        15,
        1234567,
        3,
        0,
        7
    ) AS KuwaitTimestamp;






33. SMALLDATETIMEFROMPARTS()
Syntax
-- =========================================================
-- SMALLDATETIMEFROMPARTS syntax
-- =========================================================
SMALLDATETIMEFROMPARTS(
    year,
    month,
    day,
    hour,
    minute
)

  
Example
-- =========================================================
-- Construct SMALLDATETIME
-- =========================================================
SELECT
    SMALLDATETIMEFROMPARTS(
        2026,
        8,
        29,
        14,
        30
    ) AS ConstructedSmallDateTime;






-- Conversion 🔄
34. CAST()
এক data type থেকে অন্য data type-এ convert করে।
Syntax
-- =========================================================
-- CAST syntax
-- =========================================================

CAST(expression AS data_type)
DATETIME → DATE
-- =========================================================
-- Convert timestamp into date only
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    CAST(OrderDateTime AS DATE) AS OrderDateOnly
FROM dt.Orders;



DATETIME2 → TIME
-- =========================================================
-- Extract time using CAST
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,
    CAST(OrderDateTime AS TIME) AS OrderTimeOnly
FROM dt.Orders;






35. CONVERT()
CAST()-এর মতো conversion করে এবং style parameter support করে।
Syntax
-- =========================================================
-- CONVERT syntax
-- =========================================================
CONVERT(data_type, expression [, style])



Date formatting
-- =========================================================
-- Convert date to different string representations
-- Style 23 = YYYY-MM-DD
-- =========================================================
SELECT
    OrderID,
    CONVERT(VARCHAR(10), OrderDate, 23) AS ISODate
FROM dt.Orders;


Style example
-- =========================================================
-- Convert date into common formats
-- =========================================================
SELECT
    OrderDate,
    CONVERT(VARCHAR(10), OrderDate, 23) AS ISO_Format,
    CONVERT(VARCHAR(10), OrderDate, 103) AS British_Format,
    CONVERT(VARCHAR(10), OrderDate, 101) AS US_Format
FROM dt.Orders;






36. TRY_CAST()
Invalid conversion হলে error না দিয়ে NULL return করে।
Syntax
-- =========================================================
-- TRY_CAST syntax
-- =========================================================

TRY_CAST(expression AS data_type)
Example
-- =========================================================
-- Test safe date conversion
-- Invalid date becomes NULL instead of an error
-- =========================================================
SELECT
    TRY_CAST('2026-08-29' AS DATE) AS ValidDate,
    TRY_CAST('ABC' AS DATE) AS InvalidDate;



ETL Example ⭐
-- =========================================================
-- Safely convert staging data
-- Bad records become NULL for later data-quality handling
-- =========================================================
SELECT
    TRY_CAST('2026-08-29' AS DATE) AS CleanDate,
    TRY_CAST('NotARealDate' AS DATE) AS BadDate;





37. TRY_CONVERT()
CONVERT()-এর safe version।
Syntax
-- =========================================================
-- TRY_CONVERT syntax
-- =========================================================
TRY_CONVERT(data_type, expression [, style])


  
Example
-- =========================================================
-- Safely convert string into DATE
-- =========================================================
SELECT
    TRY_CONVERT(DATE, '2026-08-29', 23) AS ValidDate,
    TRY_CONVERT(DATE, 'ABC', 23) AS InvalidDate;


CAST vs CONVERT vs TRY_CAST vs TRY_CONVERT
  
Function	      Error on bad data	         Style
CAST()	        ✅	                       ❌
CONVERT()	      ✅	                       ✅
TRY_CAST()	    ❌ → NULL	               ❌
TRY_CONVERT()	  ❌ → NULL	               ✅


ETL Best Practice
Raw/staging data clean করার সময়:
TRY_CAST / TRY_CONVERT
        ↓
Data Quality Check
        ↓
Silver






-- ISDATE() 🔍
38. ISDATE()
কোন expression valid datetime value হিসেবে interpret করা যায় কি না তা check করে।
Syntax
-- =========================================================
-- ISDATE syntax
-- =========================================================
ISDATE(expression)

  
Example
-- =========================================================
-- Validate possible date values
-- =========================================================
SELECT
    ISDATE('2026-08-29') AS ValidDate,
    ISDATE('2026-02-31') AS InvalidDate,
    ISDATE('ABC') AS InvalidText;


Data Quality Example
-- =========================================================
-- Identify rows containing invalid date text
-- =========================================================
DECLARE @RawDate VARCHAR(50) = '2026-08-29';

SELECT
    @RawDate AS RawValue,
    ISDATE(@RawDate) AS IsValidDate;


⚠️ Important
Modern ETL validation-এ শুধু ISDATE()-এর ওপর নির্ভর না করে:
-- =========================================================
-- Preferred modern safe-conversion validation pattern
-- =========================================================
SELECT
    TRY_CONVERT(DATE, '2026-08-29', 23) AS ParsedDate;
ব্যবহার করা বেশি practical।






-- Time Zone 🌍
39. AT TIME ZONE
এটি SQL Server-এর সবচেয়ে গুরুত্বপূর্ণ timezone functionality-এর একটি।
Syntax
-- =========================================================
-- AT TIME ZONE syntax
-- =========================================================
inputdate AT TIME ZONE timezone


  
Kuwait time
-- =========================================================
-- Convert a datetime value into Kuwait local timezone
-- Kuwait timezone uses Arabian Standard Time
-- =========================================================
SELECT
    OrderDateTime,
    OrderDateTime AT TIME ZONE 'Arabian Standard Time'
        AS KuwaitDateTime
FROM dt.Orders;



UTC → Kuwait
-- =========================================================
-- Convert UTC timestamp into Kuwait local time
-- =========================================================
SELECT
    EventTimeUTC,
    EventTimeUTC AT TIME ZONE 'UTC'
                  AT TIME ZONE 'Arabian Standard Time'
        AS KuwaitTime
FROM dt.SystemEvents;



UTC → US Eastern
-- =========================================================
-- Convert UTC timestamp into US Eastern time
-- SQL Server timezone rules handle daylight-saving changes
-- =========================================================
SELECT
    EventTimeUTC,
    EventTimeUTC AT TIME ZONE 'UTC'
                  AT TIME ZONE 'Eastern Standard Time'
        AS EasternTime
FROM dt.SystemEvents;





40. SWITCHOFFSET()
DATETIMEOFFSET-এর offset change করে।
Syntax
-- =========================================================
-- SWITCHOFFSET syntax
-- =========================================================
SWITCHOFFSET(datetimeoffset_expression, timezoneoffset_expression)

  
Example
-- =========================================================
-- Change timestamp offset to UTC
-- The actual instant remains the same
-- =========================================================
SELECT
    OrderID,
    OrderDateTimeOffset,
    SWITCHOFFSET(
        OrderDateTimeOffset,
        '+00:00'
    ) AS UTCDateTime
FROM dt.Orders;



Kuwait offset
-- =========================================================
-- Change displayed offset to Kuwait UTC+03:00
-- =========================================================
SELECT
    OrderID,
    SWITCHOFFSET(
        OrderDateTimeOffset,
        '+03:00'
    ) AS KuwaitTime
FROM dt.Orders;


Key concept
SWITCHOFFSET() মূলত:
Same instant
     ↓
Different offset representation






41. TODATETIMEOFFSET()
একটি datetime2/date-time value-কে specified offset দিয়ে datetimeoffset বানায়।
Syntax
-- =========================================================
-- TODATETIMEOFFSET syntax
-- =========================================================
TODATETIMEOFFSET(expression, timezoneoffset_expression)

  
Example
-- =========================================================
-- Attach Kuwait UTC+03:00 offset to a datetime2 value
-- =========================================================
SELECT
    OrderDateTime,
    TODATETIMEOFFSET(
        OrderDateTime,
        '+03:00'
    ) AS KuwaitDateTimeOffset
FROM dt.Orders;


AT TIME ZONE vs TODATETIMEOFFSET
  
Function	         Main purpose
AT TIME ZONE	     Timezone rules/name ব্যবহার
SWITCHOFFSET	     Existing offset change
TODATETIMEOFFSET	 Date/time-এর সাথে offset attach






-- NULL & Logic 🧠
42. ISNULL()
NULL-এর জায়গায় replacement value।
Syntax
-- =========================================================
-- ISNULL syntax
-- =========================================================
ISNULL(expression, replacement_value)

  
Real Example
আমাদের Order 5007 এখনো delivered হয়নি।
-- =========================================================
-- Replace NULL delivery timestamp with a readable status
-- =========================================================
SELECT
    OrderID,
    ISNULL(
        CONVERT(VARCHAR(30), DeliveryDateTime, 120),
        'Not Delivered'
    ) AS DeliveryStatus
FROM dt.Orders;







43. COALESCE()
একাধিক expression থেকে প্রথম non-NULL value নেয়।
Syntax
-- =========================================================
-- COALESCE syntax
-- =========================================================
COALESCE(expression1, expression2, expression3, ...)

  
Example
-- =========================================================
-- Use the first available date
-- DeliveryDateTime → ShipDate → OrderDate
-- =========================================================
SELECT
    OrderID,
    COALESCE(
        DeliveryDateTime,
        CAST(ShipDate AS DATETIME2),
        CAST(OrderDate AS DATETIME2)
    ) AS BestAvailableDate
FROM dt.Orders;


ISNULL vs COALESCE
  
Feature	           ISNULL	                COALESCE
Arguments	          2	                    2+
Standard	          SQL Server specific	  ANSI SQL
Simple replacement	⭐⭐⭐⭐⭐	        ⭐⭐⭐⭐
Multiple fallback	   ❌	                ✅






44. NULLIF()
দুই expression equal হলে NULL return করে।
Syntax
-- =========================================================
-- NULLIF syntax
-- =========================================================
NULLIF(expression1, expression2)

  
Division by zero protection
-- =========================================================
-- NULLIF prevents division-by-zero errors
-- =========================================================
SELECT
    100.0 / NULLIF(0, 0) AS SafeDivision;

Result:
NULL


  
Real Data Example
-- =========================================================
-- Safely calculate average unit price
-- NULLIF protects against zero quantity
-- =========================================================
SELECT
    OrderID,
    SUM(Quantity * UnitPrice) AS TotalSales,
    SUM(Quantity) AS TotalQuantity,

    SUM(Quantity * UnitPrice)
        / NULLIF(SUM(Quantity), 0) AS AverageUnitPrice
FROM dt.OrderItems
GROUP BY OrderID;







45. CASE
Business logic তৈরি করার জন্য অত্যন্ত গুরুত্বপূর্ণ।
Syntax
-- =========================================================
-- CASE syntax
-- =========================================================
CASE
    WHEN condition THEN result
    WHEN condition THEN result
    ELSE result
END


  
Delivery status
-- =========================================================
-- Classify orders based on delivery status
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DeliveryDateTime,

    CASE
        WHEN DeliveryDateTime IS NULL
            THEN 'Pending'

        WHEN DATEDIFF(
                DAY,
                OrderDate,
                CAST(DeliveryDateTime AS DATE)
             ) <= 3
            THEN 'Fast Delivery'

        ELSE 'Delayed'
    END AS DeliveryStatus
FROM dt.Orders;








46. Real Business Analysis 📊
এখন আমরা সব functions একসাথে ব্যবহার করব।

Monthly Sales Analysis
-- =========================================================
-- Monthly sales analysis
-- DATETRUNC groups orders by month
-- =========================================================
SELECT
    DATETRUNC(MONTH, o.OrderDate) AS MonthStart,
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    SUM(oi.Quantity) AS TotalQuantity,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
FROM dt.Orders AS o
INNER JOIN dt.OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    DATETRUNC(MONTH, o.OrderDate)
ORDER BY
    MonthStart;






47. Year + Quarter + Month Analysis
-- =========================================================
-- Business calendar analysis
-- Extract year, quarter and month
-- =========================================================
SELECT
    YEAR(o.OrderDate) AS OrderYear,
    DATEPART(QUARTER, o.OrderDate) AS OrderQuarter,
    MONTH(o.OrderDate) AS OrderMonth,
    DATENAME(MONTH, o.OrderDate) AS MonthName,

    COUNT(DISTINCT o.OrderID) AS Orders,
    SUM(oi.Quantity * oi.UnitPrice) AS Sales
FROM dt.Orders AS o
INNER JOIN dt.OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    YEAR(o.OrderDate),
    DATEPART(QUARTER, o.OrderDate),
    MONTH(o.OrderDate),
    DATENAME(MONTH, o.OrderDate)
ORDER BY
    OrderYear,
    OrderMonth;








48. Month-End Reporting
-- =========================================================
-- Month-end sales reporting
-- EOMONTH identifies the reporting month end
-- =========================================================
SELECT
    EOMONTH(o.OrderDate) AS MonthEnd,
    SUM(oi.Quantity * oi.UnitPrice) AS TotalSales
FROM dt.Orders AS o
INNER JOIN dt.OrderItems AS oi
    ON o.OrderID = oi.OrderID
GROUP BY
    EOMONTH(o.OrderDate)
ORDER BY
    MonthEnd;






49. Order Delivery Duration
-- =========================================================
-- Calculate order-to-delivery duration
-- NULL delivery dates are handled separately
-- =========================================================
SELECT
    OrderID,
    OrderDate,
    DeliveryDateTime,

    CASE
        WHEN DeliveryDateTime IS NULL
            THEN 'Pending'

        ELSE
            CAST(
                DATEDIFF(
                    DAY,
                    OrderDate,
                    CAST(DeliveryDateTime AS DATE)
                )
                AS VARCHAR(10)
            ) + ' Days'
    END AS DeliveryDuration
FROM dt.Orders;






50. Employee Working Hours
-- =========================================================
-- Calculate employee working duration
-- DATEDIFF_BIG gives large integer precision
-- =========================================================
SELECT
    AttendanceID,
    EmployeeID,
    AttendanceDate,
    CheckInTime,
    CheckOutTime,

    CASE
        WHEN CheckOutTime IS NULL
            THEN 'Still Working'

        ELSE
            CAST(
                DATEDIFF(
                    MINUTE,
                    CheckInTime,
                    CheckOutTime
                ) / 60.0
                AS DECIMAL(10,2)
            )
    END AS WorkingHours
FROM dt.EmployeeAttendance;






51. Orders During Business Hours
-- =========================================================
-- Identify orders placed during business hours
-- Demonstrates TIME conversion
-- =========================================================
SELECT
    OrderID,
    OrderDateTime,

    CASE
        WHEN CAST(OrderDateTime AS TIME) >= '09:00:00'
         AND CAST(OrderDateTime AS TIME) < '18:00:00'
            THEN 'Business Hours'

        ELSE 'Outside Business Hours'
    END AS TimeCategory
FROM dt.Orders;






52. Weekend vs Weekday
-- =========================================================
-- Classify orders as weekday/weekend
-- DATENAME returns weekday name
-- =========================================================

SELECT
    OrderID,
    OrderDate,
    DATENAME(WEEKDAY, OrderDate) AS WeekdayName,

    CASE
        WHEN DATENAME(WEEKDAY, OrderDate)
             IN ('Saturday', 'Sunday')
            THEN 'Weekend'

        ELSE 'Weekday'
    END AS DayType
FROM dt.Orders;
⚠️ এখানে LANGUAGE/server language-এর কারণে weekday names পরিবর্তিত হতে পারে। 
Production logic-এ DATEPART(WEEKDAY)-এর ওপর নির্ভর করার সময় DATEFIRST setting বিবেচনা করতে হবে।






53. Current Month Orders
-- =========================================================
-- Find orders from the current month
-- Uses DATETRUNC for a clean date boundary
-- =========================================================
SELECT *
FROM dt.Orders
WHERE OrderDate >= DATETRUNC(
        MONTH,
        CAST(GETDATE() AS DATE)
      )
  AND OrderDate < DATEADD(
        MONTH,
        1,
        DATETRUNC(
            MONTH,
            CAST(GETDATE() AS DATE)
        )
      );

⭐ SARGable pattern
এটি ভালো কারণ column-এর ওপর function না দিয়ে boundary calculation করা হয়েছে।






54. Last 30 Days
-- =========================================================
-- Find records from the last 30 days
-- Useful for operational reporting
-- =========================================================
SELECT *
FROM dt.Orders
WHERE OrderDate >= DATEADD(
        DAY,
        -30,
        CAST(GETDATE() AS DATE)
      );





55. Employee Tenure
-- =========================================================
-- Employee tenure analysis
-- Calculate years and months since joining
-- =========================================================
SELECT
    EmployeeID,
    EmployeeName,
    HireDate,

    DATEDIFF(
        YEAR,
        HireDate,
        CAST(GETDATE() AS DATE)
    ) AS YearBoundaryCount,

    DATEDIFF(
        MONTH,
        HireDate,
        CAST(GETDATE() AS DATE)
    ) AS MonthBoundaryCount

FROM dt.Employees;






56. Employee Age Analysis
-- =========================================================
-- Calculate approximate age using year difference
-- =========================================================
SELECT
    EmployeeID,
    EmployeeName,
    BirthDate,

    DATEDIFF(
        YEAR,
        BirthDate,
        CAST(GETDATE() AS DATE)
    ) AS ApproxAge

FROM dt.Employees;

⚠️ Exact age চাইলে birthday already occurred কি না check করতে হবে।





-- Data Engineering Examples ⚙️
57. Incremental ETL Watermark
Data Engineering-এ খুব common pattern।
-- =========================================================
-- Define ETL watermark
-- We only want records after the previous successful load
-- =========================================================
DECLARE @LastLoadTime DATETIME2(7)
    = '2026-08-20 00:00:00.0000000';

SELECT
    OrderID,
    OrderDateTime,
    CustomerID,
    EmployeeID
FROM dt.Orders
WHERE OrderDateTime > @LastLoadTime;


Concept
Previous Load
     ↓
@LastLoadTime
     ↓
WHERE OrderDateTime > @LastLoadTime
     ↓
New Records
     ↓
Silver / Gold





58. ETL Daily Window
-- =========================================================
-- Create a one-day ETL extraction window
-- Start is inclusive, end is exclusive
-- =========================================================
DECLARE @StartDate DATETIME2(7)
    = '2026-08-24 00:00:00';

DECLARE @EndDate DATETIME2(7)
    = DATEADD(DAY, 1, @StartDate);

SELECT
    OrderID,
    OrderDateTime
FROM dt.Orders
WHERE OrderDateTime >= @StartDate
  AND OrderDateTime < @EndDate;


⭐ Best Practice
Production ETL-এ:
>= StartDate
<  EndDate
pattern ব্যবহার করা ভালো।





59. UTC Audit Time
-- =========================================================
-- Create an audit timestamp in UTC
-- Recommended for globally consistent ETL audit data
-- =========================================================
SELECT
    SYSUTCDATETIME() AS LoadDateTimeUTC;





60. Convert UTC Events to Kuwait
-- =========================================================
-- Convert centralized UTC event timestamps
-- into Kuwait local time for business users
-- =========================================================
SELECT
    EventID,
    EventType,
    EventTimeUTC,

    EventTimeUTC
        AT TIME ZONE 'UTC'
        AT TIME ZONE 'Arabian Standard Time'
        AS KuwaitTime

FROM dt.SystemEvents;






61. ETL Duration
-- =========================================================
-- Calculate ETL execution duration
-- This is a realistic pipeline monitoring query
-- =========================================================
WITH ETLEvents AS
(
    SELECT
        MIN(
            CASE
                WHEN EventType = 'ETL_START'
                    THEN EventTimeUTC
            END
        ) AS StartTime,

        MAX(
            CASE
                WHEN EventType = 'ETL_END'
                    THEN EventTimeUTC
            END
        ) AS EndTime
    FROM dt.SystemEvents
    WHERE EventType IN ('ETL_START', 'ETL_END')
)
SELECT
    StartTime,
    EndTime,

    DATEDIFF_BIG(
        MILLISECOND,
        StartTime,
        EndTime
    ) AS DurationMilliseconds

FROM ETLEvents;






62. Date Dimension Thinking 🏆
Data Analyst/Data Engineer হিসেবে Date Dimension খুব গুরুত্বপূর্ণ।
আমরা একটি Date Dimension তৈরি করতে পারি।
-- =========================================================
-- Create a reusable Date Dimension
-- Useful for Power BI, reporting and data warehouse analysis
-- =========================================================
CREATE TABLE dt.DimDate
(
    DateKey INT PRIMARY KEY,
    FullDate DATE NOT NULL,
    YearNumber INT NOT NULL,
    QuarterNumber INT NOT NULL,
    MonthNumber INT NOT NULL,
    MonthName VARCHAR(20) NOT NULL,
    DayNumber INT NOT NULL,
    DayName VARCHAR(20) NOT NULL,
    WeekNumber INT NOT NULL
);
GO






63. Generate Date Dimension
-- =========================================================
-- Generate calendar dates for 2026-2030
-- Uses DATEADD and DATEPART
-- =========================================================
DECLARE @StartDate DATE = '2026-01-01';
DECLARE @EndDate   DATE = '2030-12-31';

;WITH Calendar AS
(
    SELECT @StartDate AS FullDate

    UNION ALL

    SELECT DATEADD(DAY, 1, FullDate)
    FROM Calendar
    WHERE FullDate < @EndDate
)
INSERT INTO dt.DimDate
(
    DateKey,
    FullDate,
    YearNumber,
    QuarterNumber,
    MonthNumber,
    MonthName,
    DayNumber,
    DayName,
    WeekNumber
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), FullDate, 112)) AS DateKey,

    FullDate,

    YEAR(FullDate) AS YearNumber,

    DATEPART(
        QUARTER,
        FullDate
    ) AS QuarterNumber,

    MONTH(FullDate) AS MonthNumber,

    DATENAME(
        MONTH,
        FullDate
    ) AS MonthName,

    DAY(FullDate) AS DayNumber,

    DATENAME(
        WEEKDAY,
        FullDate
    ) AS DayName,

    DATEPART(
        WEEK,
        FullDate
    ) AS WeekNumber

FROM Calendar
OPTION (MAXRECURSION 0);
GO





64. Date Dimension ব্যবহার করে Sales
-- =========================================================
-- Join sales with Date Dimension
-- This is a standard data warehouse reporting pattern
-- =========================================================
SELECT
    d.YearNumber,
    d.MonthNumber,
    d.MonthName,

    COUNT(DISTINCT o.OrderID) AS TotalOrders,

    SUM(
        oi.Quantity * oi.UnitPrice
    ) AS TotalSales

FROM dt.Orders AS o

INNER JOIN dt.DimDate AS d
    ON o.OrderDate = d.FullDate

INNER JOIN dt.OrderItems AS oi
    ON o.OrderID = oi.OrderID

GROUP BY
    d.YearNumber,
    d.MonthNumber,
    d.MonthName

ORDER BY
    d.YearNumber,
    d.MonthNumber;






65. Important Real-World Patterns ⭐
    Date Filtering — Bad vs Good

  
❌ Avoid when possible
-- =========================================================
-- Avoid applying a function directly to the indexed column
-- This can reduce index seek opportunities
-- =========================================================
SELECT *
FROM dt.Orders
WHERE CAST(OrderDateTime AS DATE) = '2026-08-10';


✅ Better
-- =========================================================
-- Use a half-open date range
-- This is generally more index-friendly
-- =========================================================
SELECT *
FROM dt.Orders
WHERE OrderDateTime >= '2026-08-10 00:00:00'
  AND OrderDateTime <  '2026-08-11 00:00:00';





66. -- Don't Use FORMAT() for Heavy ETL
আপনার এই Date/Time list-এ FORMAT() নেই, কারণ এটি Date/Time function-এর core analytical function নয়।
Reporting display-এর জন্য ব্যবহার করা যায়, কিন্তু large dataset-এর ETL/query transformation-এ সাধারণত CONVERT()/CAST() বেশি performant।





67. Avoid Ambiguous Date Strings
❌ Avoid
-- =========================================================
-- Ambiguous date representation
-- =========================================================
SELECT CAST('08/09/2026' AS DATE);


এখানে month/day interpretation context-এর ওপর নির্ভর করতে পারে।
✅ Better
-- =========================================================
-- ISO-style date representation
-- =========================================================
SELECT CAST('2026-08-09' AS DATE);

আর strict ETL conversion-এর জন্য TRY_CONVERT() ব্যবহার করুন।






68. Complete Function Checklist ✅
আপনার দেওয়া সব functions এখন covered:
🕒 Data Types
- ✅ DATE
- ✅ TIME
- ✅ DATETIME
- ✅ DATETIME2
- ✅ SMALLDATETIME
- ✅ DATETIMEOFFSET
🕐 Current Date/Time
- ✅ GETDATE()
- ✅ CURRENT_TIMESTAMP
- ✅ GETUTCDATE()
- ✅ SYSDATETIME()
- ✅ SYSUTCDATETIME()
- ✅ SYSDATETIMEOFFSET()
📅 Date Part
- ✅ YEAR()
- ✅ MONTH()
- ✅ DAY()
- ✅ DATEPART()
- ✅ DATENAME()
➕ Date Calculation
- ✅ DATEADD()
- ✅ DATEDIFF()
- ✅ DATEDIFF_BIG()
📆 Boundary
- ✅ EOMONTH()
- ✅ DATETRUNC()
🏗️ Construction
- ✅ DATEFROMPARTS()
- ✅ TIMEFROMPARTS()
- ✅ DATETIMEFROMPARTS()
- ✅ DATETIME2FROMPARTS()
- ✅ DATETIMEOFFSETFROMPARTS()
- ✅ SMALLDATETIMEFROMPARTS()
🔄 Conversion
- ✅ CAST()
- ✅ CONVERT()
- ✅ TRY_CAST()
- ✅ TRY_CONVERT()
🔍 Validation
- ✅ ISDATE()
🌍 Time Zone
- ✅ AT TIME ZONE
- ✅ SWITCHOFFSET()
- ✅ TODATETIMEOFFSET()
🧠 NULL & Logic
- ✅ ISNULL()
- ✅ COALESCE()
- ✅ NULLIF()
- ✅ CASE





69. Industry Best Practices 🏆
🗄️ Data Types
- 🥇 New systems: DATETIME2
- 🌍 Global timestamp: DATETIMEOFFSET বা UTC DATETIME2
- 📅 Date only: DATE
- ⏰ Time only: TIME
- ⚠️ Legacy: SMALLDATETIME/DATETIME
  
⚙️  Data Engineering
- 🌎 Store: UTC where appropriate
- 🕒 Display:-- Convert to user's/business timezone
- 🔄 Incremental ETL: Watermark + DATEADD()
- 🧹 Bad raw dates: TRY_CAST() / TRY_CONVERT()
- 🚫 Avoid: ambiguous date strings
- ⚡ Performance: indexed datetime column-এর ওপর unnecessary function avoid করুন
  
📊  Data Analytics
- 📅 Month: DATETRUNC(MONTH, Date)
- 📆 Month End: EOMONTH(Date)
- 📈 Year: YEAR(Date)
- 📊 Quarter: DATEPART(QUARTER, Date)
- 🗓️ Month Name: DATENAME(MONTH, Date)
- ⏱️ Duration: DATEDIFF()
- 🌍 Timezone: AT TIME ZONE






70. Hands-on Project 🎯
Project: E-Commerce Sales & ETL Date-Time Analytics
এই database-এর ওপর নিচের project নিজে solve করুন।

  
Level 1 — Beginner 🟢
- 📅 প্রতিটি order-এর Year, Month, Day বের করুন।
- 📆 প্রতিটি order-এর MonthName বের করুন।
- 🗓️ কোন order weekend-এ হয়েছে?
- ⏰ কোন order business hours-এর মধ্যে হয়েছে?
- 📅 প্রতিটি order-এর month-end বের করুন।

  
Level 2 — Intermediate 🟡
- 📊 Month-wise total sales বের করুন।
- 📈 Quarter-wise sales বের করুন।
- 🚚 Average delivery days বের করুন।
- 👨‍💼 Employee-wise order count বের করুন।
- 🏆 কোন employee সবচেয়ে বেশি sales generate করেছে?
- 📅 Last 30 days orders বের করুন।

  
Level 3 — Advanced 🔴
- 🌍 UTC event time → Kuwait time conversion করুন।
- 🌍 UTC → US Eastern conversion করুন।
- ⚙️ ETL start/end duration calculate করুন।
- 🔄 Incremental ETL watermark query তৈরি করুন।
- 🧹 Invalid date staging data identify করুন।
- 🕒 Employee working hours calculate করুন।
- 📊 Monthly sales Date Dimension-এর মাধ্যমে তৈরি করুন।


  
Level 4 — Data Engineering 🧠
একটি ETL architecture design করুন:
                 SOURCE
                   │
                   ▼
          Raw/Staging Tables
                   │
                   ▼
          TRY_CONVERT / TRY_CAST
                   │
                   ▼
              BRONZE
                   │
                   ▼
       Date/Time Data Quality
                   │
                   ▼
               SILVER
                   │
                   ▼
       Date Dimension + Facts
                   │
                   ▼
                GOLD
                   │
                   ▼
              Power BI

















  
