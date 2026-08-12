/* =============================================================================
   SQL SERVER STRING FUNCTIONS
   Real Business Scenario: Customer / CRM Data Cleaning

   Functions Covered:
   01. CONCAT()
   02. TRIM()
   03. LOWER()
   04. UPPER()
   05. REPLACE()
   06. LEN()
   07. LEFT()
   08. RIGHT()
   09. SUBSTRING()
   10. CHARINDEX()
   11. STRING_SPLIT()
   12. STRING_AGG()
   13. CONCAT_WS()
   14. NULLIF()
   15. COALESCE()
   16. PATINDEX()
   17. REVERSE()
   18. TRANSLATE()
   19. REPLICATE()
   20. STUFF()
   21. LTRIM()
   22. RTRIM()
   23. SPACE()
   24. FORMAT()

   ============================================================================ */


/* =============================================================================
   VERIFY DATA
   ============================================================================ */

SELECT *
FROM Customers;
GO


/* =============================================================================
   01. CONCAT()
   -----------------------------------------------------------------------------
   Multiple values একসাথে combine করে।
   ============================================================================ */

-- Customer name এবং country একসাথে তৈরি করা

SELECT
    CustomerID,
    CONCAT(FirstName, ' ', LastName, ' - ', Country) AS CustomerInfo
FROM Customers;
GO


/* =============================================================================
   02. LOWER()
   -----------------------------------------------------------------------------
   Text কে lowercase করে।
   ETL/Data Cleaning-এ standardization-এর জন্য useful।
   ============================================================================ */

SELECT
    CustomerID,
    Email,
    LOWER(Email) AS StandardEmail
FROM Customers;
GO


/* =============================================================================
   03. UPPER()
   -----------------------------------------------------------------------------
   Text কে uppercase করে।
   Reporting বা standardized category তৈরিতে useful।
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    UPPER(FirstName) AS UpperFirstName
FROM Customers;
GO


/* =============================================================================
   04. TRIM()
   -----------------------------------------------------------------------------
   Beginning এবং ending-এর unwanted spaces remove করে।
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LEN(FirstName) AS OriginalLength,
    LEN(TRIM(FirstName)) AS CleanLength
FROM Customers;
GO


/* =============================================================================
   Find customers যেখানে unwanted spaces আছে
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName
FROM Customers
WHERE FirstName <> TRIM(FirstName)
   OR LastName <> TRIM(LastName);
GO


/* =============================================================================
   Best Practice:
   Raw data overwrite না করে cleaned value SELECT/ETL layer-এ তৈরি করা।
   ============================================================================ */


/* =============================================================================
   05. REPLACE()
   -----------------------------------------------------------------------------
   কোনো character/value অন্য character/value দিয়ে replace করে।
   ============================================================================ */

-- Phone number থেকে - remove করা

SELECT
    Phone AS OriginalPhone,
    REPLACE(Phone, '-', '') AS CleanPhone
FROM Customers;
GO


-- Email domain পরিবর্তন করার example

SELECT
    Email,
    REPLACE(Email, '@EMAIL.COM', '@company.com') AS NewEmail
FROM Customers
WHERE Email IS NOT NULL;
GO


/* =============================================================================
   06. LEN()
   -----------------------------------------------------------------------------
   String-এর length বের করে।
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LEN(FirstName) AS NameLength
FROM Customers;
GO


/* =============================================================================
   Data Quality:
   Name unusually short/long কিনা check করা
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LEN(TRIM(FirstName)) AS NameLength
FROM Customers
WHERE LEN(TRIM(FirstName)) < 3;
GO


/* =============================================================================
   07. LEFT()
   -----------------------------------------------------------------------------
   String-এর left side থেকে নির্দিষ্ট সংখ্যক character নেয়।
   ============================================================================ */

-- First 2 characters

SELECT
    CustomerID,
    FirstName,
    LEFT(TRIM(FirstName), 2) AS FirstTwoCharacters
FROM Customers;
GO


-- Customer code-এর prefix

SELECT
    CustomerCode,
    LEFT(CustomerCode, 3) AS CodePrefix
FROM Customers;
GO


/* =============================================================================
   08. RIGHT()
   -----------------------------------------------------------------------------
   String-এর right side থেকে নির্দিষ্ট character নেয়।
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    RIGHT(TRIM(FirstName), 2) AS LastTwoCharacters
FROM Customers;
GO


-- Customer code-এর last 4 digits

SELECT
    CustomerCode,
    RIGHT(CustomerCode, 4) AS CustomerNumber
FROM Customers;
GO


/* =============================================================================
   09. SUBSTRING()
   -----------------------------------------------------------------------------
   String-এর মাঝখান থেকে নির্দিষ্ট অংশ extract করে।
   Syntax:
   SUBSTRING(expression, start, length)
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    SUBSTRING(TRIM(FirstName), 2, 3) AS ExtractedName
FROM Customers;
GO


-- Customer code থেকে numeric part বের করা

SELECT
    CustomerCode,
    SUBSTRING(CustomerCode, 5, 4) AS CustomerNumber
FROM Customers;
GO


/* =============================================================================
   10. CHARINDEX()
   -----------------------------------------------------------------------------
   কোনো character/string কোথায় আছে তার position return করে।
   ============================================================================ */

-- Email-এ @ কোথায় আছে

SELECT
    CustomerID,
    Email,
    CHARINDEX('@', Email) AS AtPosition
FROM Customers
WHERE Email IS NOT NULL;
GO


-- Email-এর username অংশ বের করা

SELECT
    CustomerID,
    Email,
    LEFT(Email, CHARINDEX('@', Email) - 1) AS EmailUserName
FROM Customers
WHERE Email IS NOT NULL
  AND CHARINDEX('@', Email) > 0;
GO


/* =============================================================================
   Email domain বের করা
   ============================================================================ */

SELECT
    CustomerID,
    Email,
    SUBSTRING(
        Email,
        CHARINDEX('@', Email) + 1,
        LEN(Email)
    ) AS EmailDomain
FROM Customers
WHERE Email IS NOT NULL
  AND CHARINDEX('@', Email) > 0;
GO


/* =============================================================================
   11. STRING_SPLIT()
   -----------------------------------------------------------------------------
   একটি delimited string-কে multiple rows-এ split করে।

   Example:
   SQL,Power BI,Excel
   ↓
   SQL
   Power BI
   Excel
   ============================================================================ */

SELECT
    CustomerID,
    TRIM(value) AS Skill
FROM Customers
CROSS APPLY STRING_SPLIT(Skills, ',');
GO


/* =============================================================================
   কোন customer কোন skill জানে
   ============================================================================ */

SELECT
    C.CustomerID,
    CONCAT(C.FirstName, ' ', C.LastName) AS CustomerName,
    TRIM(S.value) AS Skill
FROM Customers AS C
CROSS APPLY STRING_SPLIT(C.Skills, ',') AS S;
GO


/* =============================================================================
   12. STRING_AGG()
   -----------------------------------------------------------------------------
   Multiple rows-এর text একসাথে একটি string বানায়।

   STRING_SPLIT() = One string → Multiple rows
   STRING_AGG()   = Multiple rows → One string
   ============================================================================ */

SELECT
    C.CustomerID,
    CONCAT(TRIM(C.FirstName), ' ', TRIM(C.LastName)) AS CustomerName,
    STRING_AGG(TRIM(S.value), ', ') AS Skills
FROM Customers AS C
CROSS APPLY STRING_SPLIT(C.Skills, ',') AS S
GROUP BY
    C.CustomerID,
    C.FirstName,
    C.LastName;
GO


/* =============================================================================
   13. CONCAT_WS()
   -----------------------------------------------------------------------------
   CONCAT + separator।

   WS = With Separator
   ============================================================================ */

SELECT
    CustomerID,
    CONCAT_WS(
        ', ',
        TRIM(FirstName),
        TRIM(LastName),
        City,
        Country
    ) AS CustomerAddressInfo
FROM Customers;
GO


/* =============================================================================
   14. NULLIF()
   -----------------------------------------------------------------------------
   দুটি value equal হলে NULL return করে।

   Empty string-কে NULL হিসেবে treat করতে ETL/Data Cleaning-এ খুব useful।
   ============================================================================ */

SELECT
    CustomerID,
    Email,
    NULLIF(Email, '') AS CleanEmail
FROM Customers;
GO


/* =============================================================================
   Empty string → NULL
   ============================================================================ */

SELECT
    CustomerID,
    NULLIF(TRIM(Email), '') AS CleanEmail
FROM Customers;
GO


/* =============================================================================
   15. COALESCE()
   -----------------------------------------------------------------------------
   প্রথম non-NULL value return করে।

   বাস্তব ক্ষেত্রে missing customer data-এর fallback তৈরি করতে useful।
   ============================================================================ */

SELECT
    CustomerID,
    COALESCE(NULLIF(TRIM(Email), ''), 'No Email Available') AS CustomerEmail
FROM Customers;
GO


/* =============================================================================
   Multiple fallback values
   ============================================================================ */

SELECT
    CustomerID,
    COALESCE(
        NULLIF(TRIM(Email), ''),
        NULLIF(TRIM(Phone), ''),
        'No Contact Information'
    ) AS ContactInformation
FROM Customers;
GO


/* =============================================================================
   16. PATINDEX()
   -----------------------------------------------------------------------------
   Pattern-এর position খুঁজে বের করে।

   LIKE-এর মতো pattern matching করতে পারে এবং position return করে।
   ============================================================================ */

-- Name-এর মধ্যে 'a' আছে কিনা এবং কোথায় আছে

SELECT
    CustomerID,
    FirstName,
    PATINDEX('%a%', LOWER(FirstName)) AS A_Position
FROM Customers;
GO


-- Email-এ @ আছে কিনা

SELECT
    CustomerID,
    Email,
    PATINDEX('%@%', Email) AS AtPosition
FROM Customers
WHERE Email IS NOT NULL;
GO


/* =============================================================================
   Data Quality:
   Email-এ @ নেই এমন records খুঁজে বের করা
   ============================================================================ */

SELECT
    CustomerID,
    Email
FROM Customers
WHERE Email IS NOT NULL
  AND PATINDEX('%@%', Email) = 0;
GO


/* =============================================================================
   17. REVERSE()
   -----------------------------------------------------------------------------
   String-এর character order reverse করে।
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    REVERSE(TRIM(FirstName)) AS ReversedName
FROM Customers;
GO


-- CustomerCode reverse

SELECT
    CustomerCode,
    REVERSE(CustomerCode) AS ReversedCode
FROM Customers;
GO


/* =============================================================================
   18. TRANSLATE()
   -----------------------------------------------------------------------------
   Multiple characters একবারে অন্য characters-এ translate করে।

   REPLACE() সাধারণত এক value replace করতে ভালো।
   TRANSLATE() character-to-character transformation-এর জন্য ভালো।
   ============================================================================ */

SELECT
    Phone,
    TRANSLATE(Phone, '-()', '   ') AS TranslatedPhone
FROM Customers;
GO


-- Business code transformation

SELECT
    CustomerCode,
    TRANSLATE(CustomerCode, '-CUS', '_ABC') AS TranslatedCode
FROM Customers;
GO


/* =============================================================================
   19. REPLICATE()
   -----------------------------------------------------------------------------
   একটি character/string নির্দিষ্ট সংখ্যক বার repeat করে।
   ============================================================================ */

-- Customer ID-এর আগে zero যোগ করা

SELECT
    CustomerID,
    REPLICATE('0', 5 - LEN(CustomerID))
        + CAST(CustomerID AS VARCHAR(10)) AS FormattedCustomerID
FROM Customers;
GO


-- Separator তৈরি

SELECT
    CONCAT(
        REPLICATE('-', 10),
        ' CUSTOMER ',
        REPLICATE('-', 10)
    ) AS ReportHeader;
GO


/* =============================================================================
   20. STUFF()
   -----------------------------------------------------------------------------
   String-এর নির্দিষ্ট position-এর character remove করে
   নতুন text insert করে।

   Syntax:
   STUFF(character_expression, start, length, replaceWith)
   ============================================================================ */

-- Phone number-এর মাঝখানে নতুন separator বসানো

SELECT
    Phone,
    STUFF(
        REPLACE(Phone, '-', ''),
        4,
        0,
        '-'
    ) AS FormattedPhone
FROM Customers;
GO


-- CustomerCode-এর একটি অংশ replace করা

SELECT
    CustomerCode,
    STUFF(CustomerCode, 5, 4, '9999') AS ModifiedCode
FROM Customers;
GO


/* =============================================================================
   21. LTRIM()
   -----------------------------------------------------------------------------
   Left/Beginning-এর spaces remove করে।
   ============================================================================ */

SELECT
    FirstName,
    LTRIM(FirstName) AS LeftTrimmedName
FROM Customers;
GO


/* =============================================================================
   22. RTRIM()
   -----------------------------------------------------------------------------
   Right/Ending-এর spaces remove করে।
   ============================================================================ */

SELECT
    LastName,
    RTRIM(LastName) AS RightTrimmedName
FROM Customers;
GO


/* =============================================================================
   LTRIM + RTRIM
   Older SQL Server compatible cleaning approach
   ============================================================================ */

SELECT
    FirstName,
    LTRIM(RTRIM(FirstName)) AS CleanFirstName
FROM Customers;
GO


/* =============================================================================
   TRIM বনাম LTRIM/RTRIM

   TRIM()       → দুই পাশের space
   LTRIM()      → বাম পাশের space
   RTRIM()      → ডান পাশের space
   ============================================================================ */


/* =============================================================================
   23. SPACE()
   -----------------------------------------------------------------------------
   নির্দিষ্ট সংখ্যক blank space তৈরি করে।
   ============================================================================ */

SELECT
    CONCAT(
        TRIM(FirstName),
        SPACE(1),
        TRIM(LastName)
    ) AS CustomerName
FROM Customers;
GO


-- Report formatting

SELECT
    CONCAT(
        'Customer:',
        SPACE(5),
        CustomerID,
        SPACE(5),
        TRIM(FirstName),
        SPACE(2),
        TRIM(LastName)
    ) AS CustomerReportLine
FROM Customers;
GO


/* =============================================================================
   24. FORMAT()
   -----------------------------------------------------------------------------
   SQL Server value-কে নির্দিষ্ট format-এ display করার জন্য ব্যবহার করা হয়।

   String function নয়, কিন্তু presentation/report formatting-এর জন্য
   SQL Server-এ অত্যন্ত useful।
   ============================================================================ */

-- Date format

SELECT
    CustomerID,
    JoinDate,
    FORMAT(JoinDate, 'dd-MM-yyyy') AS FormattedJoinDate
FROM Customers;
GO


-- Month name

SELECT
    CustomerID,
    JoinDate,
    FORMAT(JoinDate, 'MMMM yyyy') AS MonthYear
FROM Customers;
GO


/* =============================================================================
   FORMAT() দিয়ে currency formatting
   ============================================================================ */

SELECT
    FORMAT(125000.50, 'N2') AS FormattedNumber,
    FORMAT(125000.50, 'C2', 'en-US') AS USCurrency;
GO


/* =============================================================================
   NESTING FUNCTIONS
   -----------------------------------------------------------------------------
   এক function-এর output অন্য function-এর input হিসেবে ব্যবহার করা।
   ============================================================================ */

SELECT
    CustomerID,

    -- প্রথমে TRIM → তারপর LOWER
    LOWER(TRIM(FirstName)) AS CleanLowerName,

    -- প্রথমে TRIM → তারপর UPPER
    UPPER(TRIM(FirstName)) AS CleanUpperName,

    -- TRIM → UPPER → CONCAT
    CONCAT(
        UPPER(TRIM(FirstName)),
        ' ',
        UPPER(TRIM(LastName))
    ) AS StandardCustomerName

FROM Customers;
GO


/* =============================================================================
   REAL DATA CLEANING PIPELINE
   -----------------------------------------------------------------------------
   Raw CRM data
        ↓
   TRIM
        ↓
   LOWER / UPPER
        ↓
   REPLACE
        ↓
   NULLIF
        ↓
   COALESCE
        ↓
   Standardized Data
   ============================================================================ */

SELECT
    CustomerID,

    -- Remove unwanted spaces
    TRIM(FirstName) AS FirstName,

    TRIM(LastName) AS LastName,

    -- Standardize country
    UPPER(TRIM(Country)) AS Country,

    -- Clean phone
    REPLACE(
        TRIM(Phone),
        '-',
        ''
    ) AS CleanPhone,

    -- Standardize email
    LOWER(
        NULLIF(
            TRIM(Email),
            ''
        )
    ) AS CleanEmail,

    -- Handle missing email
    COALESCE(
        LOWER(NULLIF(TRIM(Email), '')),
        'no-email'
    ) AS FinalEmail

FROM Customers;
GO


/* =============================================================================
   REAL BUSINESS EXAMPLE
   Customer Display Name + Email Domain + Customer Number
   ============================================================================ */

SELECT
    CustomerID,

    -- Clean customer name
    CONCAT_WS(
        ' ',
        TRIM(FirstName),
        TRIM(LastName)
    ) AS CustomerName,

    -- Email domain
    CASE
        WHEN CHARINDEX('@', Email) > 0
        THEN SUBSTRING(
                Email,
                CHARINDEX('@', Email) + 1,
                LEN(Email)
             )
        ELSE NULL
    END AS EmailDomain,

    -- Customer number
    RIGHT(CustomerCode, 4) AS CustomerNumber

FROM Customers;
GO


/* =============================================================================
   REAL BUSINESS EXAMPLE
   Customer Skills Analysis
   ============================================================================ */

SELECT
    TRIM(S.value) AS Skill,
    COUNT(*) AS CustomerCount
FROM Customers AS C
CROSS APPLY STRING_SPLIT(C.Skills, ',') AS S
GROUP BY
    TRIM(S.value)
ORDER BY
    CustomerCount DESC;
GO


/* =============================================================================
   REAL BUSINESS EXAMPLE
   Data Quality Check

   Check:
   1. Leading/trailing spaces
   2. Empty email
   3. Invalid email
   4. Missing phone
   ============================================================================ */

SELECT
    CustomerID,
    FirstName,
    LastName,
    Email,
    Phone,

    CASE
        WHEN FirstName <> TRIM(FirstName)
          OR LastName <> TRIM(LastName)
        THEN 'Space Issue'

        WHEN NULLIF(TRIM(Email), '') IS NULL
        THEN 'Missing Email'

        WHEN PATINDEX('%@%', Email) = 0
        THEN 'Invalid Email'

        WHEN NULLIF(TRIM(Phone), '') IS NULL
        THEN 'Missing Phone'

        ELSE 'Valid'
    END AS DataQualityStatus

FROM Customers;
GO


/* =============================================================================
   FINAL CLEAN CUSTOMER VIEW
   -----------------------------------------------------------------------------
   Production-style approach:
   Raw source data পরিবর্তন না করে cleaned layer তৈরি করা।
   ============================================================================ */

CREATE VIEW dbo.vw_CleanCustomers
AS
SELECT
    CustomerID,

    CONCAT_WS(
        ' ',
        TRIM(FirstName),
        TRIM(LastName)
    ) AS CustomerName,

    UPPER(TRIM(Country)) AS Country,

    TRIM(City) AS City,

    REPLACE(
        TRIM(Phone),
        '-',
        ''
    ) AS CleanPhone,

    LOWER(
        NULLIF(
            TRIM(Email),
            ''
        )
    ) AS CleanEmail,

    TRIM(Address) AS Address,

    CustomerCode,

    JoinDate

FROM Customers;
GO


/* =============================================================================
   VERIFY FINAL CLEAN DATA
   ============================================================================ */

SELECT *
FROM dbo.vw_CleanCustomers;
GO
