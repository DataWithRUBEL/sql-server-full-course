/* =============================================================================
   সম্পূর্ণ Orders data দেখুন
============================================================================= */

SELECT *
FROM Sales.Orders;
GO




1. NUMERIC FORMAT SPECIFIERS
FORMAT() দিয়ে report/output-এর জন্য number format করা যায়।
N, P, C, E, F, N0, N1, N2
/* =============================================================================
   NUMERIC FORMAT SPECIFIERS
============================================================================= */

SELECT
    'N' AS FormatType,
    FORMAT(OrderAmount, 'N') AS FormattedValue
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'P',
    FORMAT(OrderAmount, 'P')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'C',
    FORMAT(OrderAmount, 'C')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'E',
    FORMAT(OrderAmount, 'E')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'F',
    FORMAT(OrderAmount, 'F')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'N0',
    FORMAT(OrderAmount, 'N0')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'N1',
    FORMAT(OrderAmount, 'N1')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'N2',
    FORMAT(OrderAmount, 'N2')
FROM Sales.Orders
WHERE OrderID = 1001;
GO

কী কাজ করে?
  
Format	        কাজ
N	              Number
P	              Percentage
C	              Currency
E	              Scientific notation
F	              Fixed decimal
N0	            Decimal ছাড়া
N1	            1 decimal
N2	            2 decimal







2. Culture-Specific Number Formatting
/* =============================================================================
   CULTURE-SPECIFIC NUMBER FORMAT

   একই number বিভিন্ন country's formatting অনুযায়ী দেখানো হচ্ছে।
============================================================================= */

SELECT
    'en-US' AS CultureCode,
    FORMAT(OrderAmount, 'N', 'en-US') AS FormattedNumber
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'en-GB',
    FORMAT(OrderAmount, 'N', 'en-GB')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'fr-FR',
    FORMAT(OrderAmount, 'N', 'fr-FR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'de-DE',
    FORMAT(OrderAmount, 'N', 'de-DE')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'es-ES',
    FORMAT(OrderAmount, 'N', 'es-ES')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'zh-CN',
    FORMAT(OrderAmount, 'N', 'zh-CN')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ja-JP',
    FORMAT(OrderAmount, 'N', 'ja-JP')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ko-KR',
    FORMAT(OrderAmount, 'N', 'ko-KR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'pt-BR',
    FORMAT(OrderAmount, 'N', 'pt-BR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'it-IT',
    FORMAT(OrderAmount, 'N', 'it-IT')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'nl-NL',
    FORMAT(OrderAmount, 'N', 'nl-NL')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ru-RU',
    FORMAT(OrderAmount, 'N', 'ru-RU')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ar-SA',
    FORMAT(OrderAmount, 'N', 'ar-SA')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'el-GR',
    FORMAT(OrderAmount, 'N', 'el-GR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'tr-TR',
    FORMAT(OrderAmount, 'N', 'tr-TR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'he-IL',
    FORMAT(OrderAmount, 'N', 'he-IL')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'hi-IN',
    FORMAT(OrderAmount, 'N', 'hi-IN')
FROM Sales.Orders
WHERE OrderID = 1001;
GO






3.DATE FORMAT SPECIFIERS
/* =============================================================================
   DATE FORMAT SPECIFIERS

   GETDATE() বর্তমান date/time দেয়।
============================================================================= */

SELECT
    OrderID,

    FORMAT(OrderDateTime, 'D')    AS FullDate,
    FORMAT(OrderDateTime, 'd')    AS ShortDate,

    FORMAT(OrderDateTime, 'dd')   AS DayNumber,
    FORMAT(OrderDateTime, 'ddd')  AS ShortDayName,
    FORMAT(OrderDateTime, 'dddd') AS FullDayName,

    FORMAT(OrderDateTime, 'M')    AS MonthShortPattern,
    FORMAT(OrderDateTime, 'MM')   AS MonthNumber,
    FORMAT(OrderDateTime, 'MMM')  AS ShortMonthName,
    FORMAT(OrderDateTime, 'MMMM') AS FullMonthName,

    FORMAT(OrderDateTime, 'yy')   AS TwoDigitYear,
    FORMAT(OrderDateTime, 'yyyy') AS FourDigitYear,

    FORMAT(OrderDateTime, 'hh')   AS Hour12,
    FORMAT(OrderDateTime, 'HH')   AS Hour24,

    FORMAT(OrderDateTime, 'm')    AS MinuteShort,
    FORMAT(OrderDateTime, 'mm')   AS Minute,

    FORMAT(OrderDateTime, 's')    AS SecondShort,
    FORMAT(OrderDateTime, 'ss')   AS Second,

    FORMAT(OrderDateTime, 'f')    AS TenthsSecond,
    FORMAT(OrderDateTime, 'ff')   AS HundredthsSecond,
    FORMAT(OrderDateTime, 'fff')  AS Milliseconds,

    FORMAT(OrderDateTime, 'T')    AS FullTime,
    FORMAT(OrderDateTime, 't')    AS ShortTime,
    FORMAT(OrderDateTime, 'tt')   AS AM_PM

FROM Sales.Orders;
GO

Real Business Use
/* =============================================================================
   Customer-facing sales report
============================================================================= */

SELECT
    OrderID,
    FORMAT(OrderDateTime, 'dd MMMM yyyy') AS OrderDate,
    FORMAT(OrderDateTime, 'hh:mm tt') AS OrderTime,
    FORMAT(OrderAmount, 'N2', 'en-US') AS SalesAmount
FROM Sales.Orders;
GO







4. DATEPART()
DATEPART() একটি date/time থেকে নির্দিষ্ট অংশের numeric value বের করে।
/* =============================================================================
   DATEPART()
============================================================================= */

SELECT
    OrderID,

    DATEPART(year, OrderDateTime) AS OrderYear,
    DATEPART(quarter, OrderDateTime) AS OrderQuarter,
    DATEPART(month, OrderDateTime) AS OrderMonth,
    DATEPART(dayofyear, OrderDateTime) AS OrderDayOfYear,
    DATEPART(day, OrderDateTime) AS OrderDay,
    DATEPART(week, OrderDateTime) AS OrderWeek,
    DATEPART(weekday, OrderDateTime) AS OrderWeekday,

    DATEPART(hour, OrderDateTime) AS OrderHour,
    DATEPART(minute, OrderDateTime) AS OrderMinute,
    DATEPART(second, OrderDateTime) AS OrderSecond,

    DATEPART(millisecond, OrderDateTime) AS OrderMillisecond,
    DATEPART(microsecond, OrderDateTime) AS OrderMicrosecond,
    DATEPART(nanosecond, OrderDateTime) AS OrderNanosecond,

    DATEPART(iso_week, OrderDateTime) AS ISOWeek

FROM Sales.Orders;
GO





5. DATEPART-এর Alias
/* =============================================================================
   DATEPART-এর বিভিন্ন equivalent abbreviation

   year      = yy = yyyy
   quarter   = qq = q
   month     = mm = m
   day       = dd = d
   week      = wk = ww
   weekday   = dw
   hour      = hh
   minute    = mi = n
   second    = ss = s
   millisecond = ms
   microsecond = mcs
   nanosecond  = ns
============================================================================= */

SELECT
    OrderID,

    DATEPART(year, OrderDateTime) AS Year1,
    DATEPART(yy, OrderDateTime) AS Year2,
    DATEPART(yyyy, OrderDateTime) AS Year3,

    DATEPART(month, OrderDateTime) AS Month1,
    DATEPART(mm, OrderDateTime) AS Month2,
    DATEPART(m, OrderDateTime) AS Month3,

    DATEPART(day, OrderDateTime) AS Day1,
    DATEPART(dd, OrderDateTime) AS Day2,
    DATEPART(d, OrderDateTime) AS Day3,

    DATEPART(week, OrderDateTime) AS Week1,
    DATEPART(wk, OrderDateTime) AS Week2,
    DATEPART(ww, OrderDateTime) AS Week3

FROM Sales.Orders;
GO





6. DATENAME()
DATENAME() একই date part-এর text representation দেয়।
/* =============================================================================
   DATENAME()
============================================================================= */

SELECT
    OrderID,

    DATENAME(year, OrderDateTime) AS OrderYear,
    DATENAME(quarter, OrderDateTime) AS OrderQuarter,
    DATENAME(month, OrderDateTime) AS OrderMonth,
    DATENAME(dayofyear, OrderDateTime) AS DayOfYear,
    DATENAME(day, OrderDateTime) AS DayNumber,
    DATENAME(weekday, OrderDateTime) AS WeekdayName,
    DATENAME(week, OrderDateTime) AS WeekNumber,

    DATENAME(hour, OrderDateTime) AS Hour,
    DATENAME(minute, OrderDateTime) AS Minute,
    DATENAME(second, OrderDateTime) AS Second,

    DATENAME(millisecond, OrderDateTime) AS Millisecond,
    DATENAME(microsecond, OrderDateTime) AS Microsecond,
    DATENAME(nanosecond, OrderDateTime) AS Nanosecond,

    DATENAME(iso_week, OrderDateTime) AS ISOWeek

FROM Sales.Orders;
GO

পার্থক্য
/* =============================================================================
   DATEPART  -> সাধারণত numeric value
   DATENAME  -> character value
============================================================================= */

SELECT
    OrderID,

    DATEPART(month, OrderDateTime) AS MonthNumber,
    DATENAME(month, OrderDateTime) AS MonthName,

    DATEPART(weekday, OrderDateTime) AS WeekdayNumber,
    DATENAME(weekday, OrderDateTime) AS WeekdayName

FROM Sales.Orders;
GO






7. DATETRUNC()
DATETRUNC() date/time-কে নির্দিষ্ট level-এর শুরুতে নিয়ে যায়।
/* =============================================================================
   DATETRUNC()
   SQL Server 2022+
============================================================================= */

SELECT
    OrderID,

    DATETRUNC(year, OrderDateTime) AS YearStart,

    DATETRUNC(quarter, OrderDateTime) AS QuarterStart,

    DATETRUNC(month, OrderDateTime) AS MonthStart,

    DATETRUNC(week, OrderDateTime) AS WeekStart,

    DATETRUNC(hour, OrderDateTime) AS HourStart,

    DATETRUNC(minute, OrderDateTime) AS MinuteStart,

    DATETRUNC(second, OrderDateTime) AS SecondStart,

    DATETRUNC(millisecond, OrderDateTime) AS MillisecondStart,

    DATETRUNC(microsecond, OrderDateTime) AS MicrosecondStart,

    DATETRUNC(nanosecond, OrderDateTime) AS NanosecondStart,

    DATETRUNC(iso_week, OrderDateTime) AS ISOWeekStart

FROM Sales.Orders;
GO

Business Example — Monthly Sales
/* =============================================================================
   প্রতি মাসের Sales Analysis

   DATETRUNC(month, OrderDateTime)
   একই মাসের সব order-কে একই MonthStart value-তে নিয়ে আসে।
============================================================================= */

SELECT
    DATETRUNC(month, OrderDateTime) AS SalesMonth,
    SUM(OrderAmount) AS TotalSales
FROM Sales.Orders
GROUP BY DATETRUNC(month, OrderDateTime)
ORDER BY SalesMonth;
GO







8. DATEPART + DATENAME + DATETRUNC একসাথে
/* =============================================================================
   তিনটি function-এর practical comparison
============================================================================= */

SELECT
    OrderID,
    OrderDateTime,

    DATEPART(month, OrderDateTime) AS MonthNumber,

    DATENAME(month, OrderDateTime) AS MonthName,

    DATETRUNC(month, OrderDateTime) AS MonthStart

FROM Sales.Orders;
GO





9. DATEDIFF_BIG()
DATEDIFF_BIG() দুই date/time-এর মধ্যে difference দেয় এবং বড় range-এর জন্য DATEDIFF()-এর তুলনায় বড় integer range support করে।
/* =============================================================================
   ORDER PROCESSING TIME

   Order থেকে Delivery পর্যন্ত কত:
   - Day
   - Hour
   - Minute
   - Second

   লেগেছে তা বের করা হচ্ছে।
============================================================================= */

SELECT
    OrderID,

    DATEDIFF_BIG(
        day,
        OrderDateTime,
        DeliveryDateTime
    ) AS DeliveryDays,

    DATEDIFF_BIG(
        hour,
        OrderDateTime,
        DeliveryDateTime
    ) AS DeliveryHours,

    DATEDIFF_BIG(
        minute,
        OrderDateTime,
        DeliveryDateTime
    ) AS DeliveryMinutes,

    DATEDIFF_BIG(
        second,
        OrderDateTime,
        DeliveryDateTime
    ) AS DeliverySeconds

FROM Sales.Orders;
GO

Business Use
/* =============================================================================
   Delivery SLA analysis

   3 দিনের বেশি delivery হয়েছে কিনা দেখা হচ্ছে।
============================================================================= */

SELECT
    OrderID,
    OrderDateTime,
    DeliveryDateTime,
    DATEDIFF_BIG(
        day,
        OrderDateTime,
        DeliveryDateTime
    ) AS DeliveryDays
FROM Sales.Orders
WHERE DATEDIFF_BIG(
        day,
        OrderDateTime,
        DeliveryDateTime
      ) > 3;
GO






10. SMALLDATETIME
SMALLDATETIME minute-level date/time storage-এর জন্য ব্যবহার করা যায়।
/* =============================================================================
   SMALLDATETIME

   এটি DATETIME2-এর মতো high precision রাখে না।
   Minute-level data-এর ক্ষেত্রে ব্যবহার করা যায়।
============================================================================= */

CREATE TABLE Sales.OrderSchedule
(
    ScheduleID INT PRIMARY KEY,
    OrderID INT,
    ScheduleDateTime SMALLDATETIME
);
GO
/* =============================================================================
   SMALLDATETIME data
============================================================================= */

INSERT INTO Sales.OrderSchedule
(
    ScheduleID,
    OrderID,
    ScheduleDateTime
)
VALUES
(1, 1001, '2025-01-05 09:15'),
(2, 1002, '2025-02-14 11:25'),
(3, 1003, '2025-03-21 15:40');
GO
SELECT *
FROM Sales.OrderSchedule;
GO



11. DATEFIRST
DATEFIRST দিয়ে সপ্তাহের প্রথম দিন নির্ধারণ করা যায়।
/* =============================================================================
   DATEFIRST

   1 = Monday
   7 = Sunday
============================================================================= */

SET DATEFIRST 1;
GO

SELECT
    OrderID,
    OrderDateTime,
    DATEPART(weekday, OrderDateTime) AS WeekdayNumber,
    DATENAME(weekday, OrderDateTime) AS WeekdayName
FROM Sales.Orders;


GO
আবার Sunday-কে প্রথম দিন করতে:
/* =============================================================================
   Sunday = First Day
============================================================================= */

SET DATEFIRST 7;
GO

SELECT
    OrderID,
    OrderDateTime,
    DATEPART(weekday, OrderDateTime) AS WeekdayNumber,
    DATENAME(weekday, OrderDateTime) AS WeekdayName
FROM Sales.Orders;
GO
⚠️ DATEPART(weekday, ...) ব্যবহার করলে DATEFIRST result পরিবর্তন করতে পারে।







11. SET LANGUAGE
DATENAME()-এর output language পরিবর্তন করা যায়।
/* =============================================================================
   LANGUAGE = English
============================================================================= */

SET LANGUAGE English;
GO

SELECT
    OrderID,
    DATENAME(month, OrderDateTime) AS MonthName,
    DATENAME(weekday, OrderDateTime) AS WeekdayName
FROM Sales.Orders;
GO
/* =============================================================================
   LANGUAGE = French
============================================================================= */

SET LANGUAGE French;
GO

SELECT
    OrderID,
    DATENAME(month, OrderDateTime) AS MonthName,
    DATENAME(weekday, OrderDateTime) AS WeekdayName
FROM Sales.Orders;
GO
/* =============================================================================
   আবার English
============================================================================= */

SET LANGUAGE English;
GO







12. ISO Week
ISO week analysis-এর জন্য:
/* =============================================================================
   ISO WEEK

   DATEPART(isowk, ...)
   DATENAME(isowk, ...)
   DATETRUNC(iso_week, ...)

============================================================================= */

SELECT
    OrderID,
    OrderDateTime,

    DATEPART(iso_week, OrderDateTime) AS ISOWeekNumber,

    DATENAME(iso_week, OrderDateTime) AS ISOWeekName,

    DATETRUNC(iso_week, OrderDateTime) AS ISOWeekStart

FROM Sales.Orders;
GO
Business Example
/* =============================================================================
   Weekly Sales Analysis
============================================================================= */

SELECT
    DATETRUNC(iso_week, OrderDateTime) AS ISOWeekStart,
    SUM(OrderAmount) AS TotalSales
FROM Sales.Orders
GROUP BY DATETRUNC(iso_week, OrderDateTime)
ORDER BY ISOWeekStart;
GO





13. Culture Formatting — Date + Number
/* =============================================================================
   CULTURE-SPECIFIC REPORT

   Number এবং Date একই culture অনুযায়ী format করা হচ্ছে।
============================================================================= */

SELECT
    'en-US' AS CultureCode,
    FORMAT(OrderAmount, 'N', 'en-US') AS FormattedNumber,
    FORMAT(OrderDateTime, 'D', 'en-US') AS FormattedDate
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'en-GB',
    FORMAT(OrderAmount, 'N', 'en-GB'),
    FORMAT(OrderDateTime, 'D', 'en-GB')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'fr-FR',
    FORMAT(OrderAmount, 'N', 'fr-FR'),
    FORMAT(OrderDateTime, 'D', 'fr-FR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'de-DE',
    FORMAT(OrderAmount, 'N', 'de-DE'),
    FORMAT(OrderDateTime, 'D', 'de-DE')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'es-ES',
    FORMAT(OrderAmount, 'N', 'es-ES'),
    FORMAT(OrderDateTime, 'D', 'es-ES')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'zh-CN',
    FORMAT(OrderAmount, 'N', 'zh-CN'),
    FORMAT(OrderDateTime, 'D', 'zh-CN')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ja-JP',
    FORMAT(OrderAmount, 'N', 'ja-JP'),
    FORMAT(OrderDateTime, 'D', 'ja-JP')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ko-KR',
    FORMAT(OrderAmount, 'N', 'ko-KR'),
    FORMAT(OrderDateTime, 'D', 'ko-KR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'pt-BR',
    FORMAT(OrderAmount, 'N', 'pt-BR'),
    FORMAT(OrderDateTime, 'D', 'pt-BR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'it-IT',
    FORMAT(OrderAmount, 'N', 'it-IT'),
    FORMAT(OrderDateTime, 'D', 'it-IT')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'nl-NL',
    FORMAT(OrderAmount, 'N', 'nl-NL'),
    FORMAT(OrderDateTime, 'D', 'nl-NL')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ru-RU',
    FORMAT(OrderAmount, 'N', 'ru-RU'),
    FORMAT(OrderDateTime, 'D', 'ru-RU')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'ar-SA',
    FORMAT(OrderAmount, 'N', 'ar-SA'),
    FORMAT(OrderDateTime, 'D', 'ar-SA')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'el-GR',
    FORMAT(OrderAmount, 'N', 'el-GR'),
    FORMAT(OrderDateTime, 'D', 'el-GR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'tr-TR',
    FORMAT(OrderAmount, 'N', 'tr-TR'),
    FORMAT(OrderDateTime, 'D', 'tr-TR')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'he-IL',
    FORMAT(OrderAmount, 'N', 'he-IL'),
    FORMAT(OrderDateTime, 'D', 'he-IL')
FROM Sales.Orders
WHERE OrderID = 1001

UNION ALL

SELECT
    'hi-IN',
    FORMAT(OrderAmount, 'N', 'hi-IN'),
    FORMAT(OrderDateTime, 'D', 'hi-IN')
FROM Sales.Orders
WHERE OrderID = 1001;
GO





14. Date Filtering
নির্দিষ্ট Date
/* =============================================================================
   নির্দিষ্ট দিনের Order
============================================================================= */

SELECT *
FROM Sales.Orders
WHERE OrderDateTime >= '2025-08-16'
  AND OrderDateTime <  '2025-08-17';
GO




15. Month Filtering
/* =============================================================================
   August 2025-এর সব Order

   এখানে column-এর উপর function ব্যবহার করা হয়নি।
============================================================================= */

SELECT
    OrderID,
    CustomerID,
    OrderDateTime,
    OrderAmount
FROM Sales.Orders
WHERE OrderDateTime >= '2025-08-01'
  AND OrderDateTime <  '2025-09-01';
GO




16.SARGability
❌ Non-SARGable
/* =============================================================================
   BAD PRACTICE

   Column-এর উপর function প্রয়োগ করা হয়েছে।
============================================================================= */

SELECT *
FROM Sales.Orders
WHERE DATENAME(month, OrderDateTime) = 'August';
GO
❌ আরেকটি Non-SARGable example
SELECT *
FROM Sales.Orders
WHERE DATEPART(year, OrderDateTime) = 2025;



GO
✅ SARGable
/* =============================================================================
   BEST PRACTICE

   Date column সরাসরি comparison করা হচ্ছে।
   Index থাকলে SQL Server efficiently seek করতে পারে।
============================================================================= */

SELECT *
FROM Sales.Orders
WHERE OrderDateTime >= '2025-01-01'
  AND OrderDateTime <  '2026-01-01';



GO
Month-এর জন্য:
/* =============================================================================
   BEST PRACTICE: MONTH FILTER
============================================================================= */

SELECT *
FROM Sales.Orders
WHERE OrderDateTime >= '2025-05-01'
  AND OrderDateTime <  '2025-06-01';
GO







17. Date Indexing
/* =============================================================================
   DATE INDEX

   OrderDateTime দিয়ে:
   - Date filtering
   - Range filtering
   - Reporting
   - ETL extraction

   দ্রুত করার জন্য index তৈরি করা হচ্ছে।
============================================================================= */

CREATE INDEX IX_Orders_OrderDateTime
ON Sales.Orders(OrderDateTime);


GO
এখন:
/* =============================================================================
   Index-friendly query
============================================================================= */

SELECT
    OrderID,
    CustomerID,
    OrderDateTime,
    OrderAmount
FROM Sales.Orders
WHERE OrderDateTime >= '2025-01-01'
  AND OrderDateTime <  '2025-04-01';
GO





18.Business Calendar Table
বাস্তব Data Warehouse / Analytics environment-এ Business Calendar অত্যন্ত গুরুত্বপূর্ণ।
/* =============================================================================
   BUSINESS CALENDAR

   কোম্পানির reporting-এর জন্য business day এবং holiday information
   সংরক্ষণ করা হবে।
============================================================================= */

CREATE TABLE Sales.BusinessCalendar
(
    CalendarDate DATE PRIMARY KEY,
    CalendarYear INT,
    CalendarQuarter INT,
    CalendarMonth INT,
    CalendarWeek INT,
    ISOWeek INT,
    MonthName NVARCHAR(20),
    WeekdayName NVARCHAR(20),
    IsBusinessDay BIT,
    IsHoliday BIT
);
GO

Business Calendar Data
/* =============================================================================
   BUSINESS CALENDAR SAMPLE DATA
============================================================================= */

INSERT INTO Sales.BusinessCalendar
(
    CalendarDate,
    CalendarYear,
    CalendarQuarter,
    CalendarMonth,
    CalendarWeek,
    ISOWeek,
    MonthName,
    WeekdayName,
    IsBusinessDay,
    IsHoliday
)
VALUES
('2025-01-01', 2025, 1, 1, 1, 1, 'January', 'Wednesday', 0, 1),
('2025-01-02', 2025, 1, 1, 1, 1, 'January', 'Thursday', 1, 0),
('2025-01-03', 2025, 1, 1, 1, 1, 'January', 'Friday', 1, 0),
('2025-01-04', 2025, 1, 1, 1, 1, 'January', 'Saturday', 0, 0),
('2025-01-05', 2025, 1, 1, 2, 1, 'January', 'Sunday', 0, 0),
('2025-01-06', 2025, 1, 1, 2, 2, 'January', 'Monday', 1, 0),
('2025-01-07', 2025, 1, 1, 2, 2, 'January', 'Tuesday', 1, 0);
GO
/* =============================================================================
   Business Calendar দেখুন
============================================================================= */

SELECT *
FROM Sales.BusinessCalendar;
GO




19. Business Day Filtering
/* =============================================================================
   শুধু Business Day
============================================================================= */

SELECT
    CalendarDate,
    CalendarYear,
    CalendarMonth,
    MonthName,
    WeekdayName
FROM Sales.BusinessCalendar
WHERE IsBusinessDay = 1;
GO






20. Business Calendar + Orders
/* =============================================================================
   Order কোন business day-তে হয়েছে তা বিশ্লেষণ

   OrderDateTime-এর date অংশের সাথে CalendarDate match করা হচ্ছে।
============================================================================= */

SELECT
    O.OrderID,
    O.OrderDateTime,
    O.OrderAmount,
    C.IsBusinessDay,
    C.IsHoliday
FROM Sales.Orders AS O
INNER JOIN Sales.BusinessCalendar AS C
    ON O.OrderDateTime >= C.CalendarDate
   AND O.OrderDateTime < DATEADD(day, 1, C.CalendarDate);
GO








21. Date & Time Functions — Practical Summary

  
Function / Code	            মূল কাজ	                        Real Business Use
FORMAT()	                  Presentation formatting	        Report
DATEPART()	                Numeric date part	              Grouping/Analysis
DATENAME()	                Text date part	                Month/Day name
DATETRUNC()	                Date period-এর শুরু	            Monthly/Weekly reporting
DATEDIFF_BIG()	            Date difference	                SLA/Delivery time
SMALLDATETIME	              Minute-level date/time	        Schedule
SET DATEFIRST	              Week-এর প্রথম দিন	              Weekly analysis
SET LANGUAGE	              Date-name language	            Localization
ISO_WEEK	                  ISO week number	                International reporting
FORMAT(... culture)	        Country-specific format	        International report
SARGable filtering	        Efficient date filtering	      Production query
Date Index	                Date query দ্রুত করা	            OLTP/Reporting
Business Calendar	          Business-day logic	            Enterprise analytics
 





22. সবচেয়ে গুরুত্বপূর্ণ Best Practices
/* =============================================================================
   DATE & TIME BEST PRACTICES
============================================================================= */

/*
1. নতুন application/database-এ সাধারণত DATETIME2 ব্যবহার করুন।

2. Date filtering-এর সময়:

   GOOD:
   WHERE OrderDateTime >= '2025-01-01'
     AND OrderDateTime <  '2026-01-01'

3. BAD:
   WHERE DATEPART(year, OrderDateTime) = 2025

4. BAD:
   WHERE FORMAT(OrderDateTime, 'yyyy') = '2025'

5. FORMAT() মূলত presentation/reporting-এর জন্য ব্যবহার করুন।

6. ETL, filtering এবং joining-এর জন্য FORMAT() ব্যবহার করা এড়িয়ে চলুন।

7. Monthly analysis-এর জন্য DATETRUNC(month, OrderDateTime)
   খুব useful।

8. International weekly reporting-এর জন্য ISO_WEEK ব্যবহার করুন।

9. Business-day analysis-এর জন্য Business Calendar রাখুন।

10. Frequently filtered date column-এর উপর appropriate index রাখুন।
============================================================================= */






23. একটি Complete Real-World Sales Analysis
/* =============================================================================
   FINAL PRACTICAL QUERY

   প্রতি মাসে:
   - Sales
   - Order Count
   - Month Number
   - Month Name

   বের করা হচ্ছে।
============================================================================= */

SELECT
    DATETRUNC(month, OrderDateTime) AS SalesMonth,

    DATEPART(year, OrderDateTime) AS SalesYear,

    DATEPART(month, OrderDateTime) AS MonthNumber,

    DATENAME(month, OrderDateTime) AS MonthName,

    COUNT(OrderID) AS TotalOrders,

    SUM(OrderAmount) AS TotalSales

FROM Sales.Orders

GROUP BY
    DATETRUNC(month, OrderDateTime),
    DATEPART(year, OrderDateTime),
    DATEPART(month, OrderDateTime),
    DATENAME(month, OrderDateTime)

ORDER BY
    SalesMonth;
GO


