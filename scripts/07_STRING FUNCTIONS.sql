1. Project Architecture 🏗️
আমরা একটি ছোট Retail Analytics System তৈরি করব:
StringFunctionsDB
│
├── dbo.Customers
├── dbo.Products
├── dbo.Orders
├── dbo.OrderItems
├── dbo.Employees
├── dbo.CustomerContacts
│
└── dbo.CustomerTags


   
বাস্তব scenario
ধরুন একটি retail company-এর বিভিন্ন source system থেকে data আসছে:
CRM
 └── Customers

ERP
 └── Products
 └── Employees

POS / E-Commerce
 └── Orders
 └── OrderItems
Source data-তে সমস্যা আছে:
'  john smith  '
'JOHN.SMITH@GMAIL.COM'
'Dhaka   '
'+880-1711-123456'
'Electronics|Laptop|Dell'
'Customer,VIP,Online'


   
String functions ব্যবহার করে আমরা এগুলোকে:
Clean
Normalize
Extract
Search
Split
Combine
Aggregate
Validate
Transform
করব।




   


2. String Functions 🔥
আমাদের পুরো learning map:
STRING FUNCTIONS
│
├── 🔤 Case
│   ├── LOWER()
│   └── UPPER()
│
├── 🧹 Cleaning
│   ├── TRIM()
│   ├── LTRIM()
│   ├── RTRIM()
│   ├── REPLACE()
│   └── TRANSLATE()
│
├── ✂️ Extraction
│   ├── LEFT()
│   ├── RIGHT()
│   ├── SUBSTRING()
│   ├── STUFF()
│   └── REVERSE()
│
├── 🔎 Searching
│   ├── CHARINDEX()
│   └── PATINDEX()
│
├── 🔗 Combining
│   ├── CONCAT()
│   ├── CONCAT_WS()
│   └── STRING_AGG()
│
├── ✂️ Splitting
│   └── STRING_SPLIT()
│
├── 📏 Length / Formatting
│   ├── LEN()
│   ├── FORMAT()
│   ├── REPLICATE()
│   └── SPACE()
│
├── 🚫 NULL Handling
│   ├── NULLIF()
│   └── COALESCE()
│
└── 🔢 Character / Unicode
    ├── ASCII()
    ├── CHAR()
    ├── UNICODE()
    └── NCHAR()





   


3.LOWER() 🔤
কী জন্য?
সব character lowercase করার জন্য।
   
Syntax
-- Syntax
SELECT LOWER(string_value);


Real business example
Email standardize করতে:
-- =========================================================
-- Convert customer email to lowercase
-- Useful for email normalization and matching
-- =========================================================
SELECT
    customer_id,
    email,
    LOWER(email) AS normalized_email
FROM dbo.Customers;


Result:
JOHN.SMITH@GMAIL.COM
↓
john.smith@gmail.com
ETL use
-- =========================================================
-- Standardize email before loading into Silver layer
-- =========================================================
SELECT
    customer_id,
    LOWER(TRIM(email)) AS clean_email
FROM dbo.Customers;








4. UPPER() 🔤
সব character uppercase করে।
-- =========================================================
-- Convert customer status to uppercase
-- Useful for standardizing categorical values
-- =========================================================
SELECT
    customer_id,
    customer_status,
    UPPER(TRIM(customer_status)) AS standardized_status
FROM dbo.Customers;


এতে:
Active
ACTIVE
active
সব হবে:
ACTIVE
Best Practice ⭐
Business category/status normalize করতে:
UPPER(TRIM(customer_status))




   


5. TRIM() 🧹
TRIM() string-এর শুরু এবং শেষের unwanted spaces remove করে।
-- =========================================================
-- Remove leading and trailing spaces from customer names
-- =========================================================
SELECT
    customer_id,
    first_name,
    TRIM(first_name) AS clean_first_name
FROM dbo.Customers;


সবচেয়ে common ETL pattern
-- =========================================================
-- Clean customer name
-- =========================================================
SELECT
    TRIM(first_name) AS first_name,
    TRIM(last_name) AS last_name
FROM dbo.Customers;







6. LTRIM()
Left-side spaces remove করে।
-- =========================================================
-- Remove spaces from the left side
-- =========================================================
SELECT
    first_name,
    LTRIM(first_name) AS left_clean_name
FROM dbo.Customers;








7. RTRIM()
Right-side spaces remove করে।
-- =========================================================
-- Remove spaces from the right side
-- =========================================================
SELECT
    last_name,
    RTRIM(last_name) AS right_clean_name
FROM dbo.Customers;


TRIM বনাম LTRIM/RTRIM
Function	    কাজ
TRIM()	    দুই পাশ
LTRIM()	    বাম পাশ
RTRIM()	    ডান পাশ





   


8. REPLACE() 🔄
একটি substring অন্য substring দিয়ে replace করে।
Syntax
-- Syntax
SELECT REPLACE(string, old_value, new_value);
Phone cleaning
-- =========================================================
-- Remove hyphens from phone numbers
-- Useful for phone normalization
-- =========================================================
SELECT
    customer_id,
    phone,
    REPLACE(phone, '-', '') AS clean_phone
FROM dbo.Customers;


Example:
+880-1711-123456
↓
+8801711123456
Multiple cleaning
-- =========================================================
-- Remove spaces and hyphens from phone numbers
-- =========================================================
SELECT
    customer_id,
    phone,
    REPLACE(
        REPLACE(phone, '-', ''),
        ' ',
        ''
    ) AS normalized_phone
FROM dbo.Customers;


Email cleaning
-- =========================================================
-- Remove accidental spaces from email values
-- =========================================================
SELECT
    email,
    REPLACE(email, ' ', '') AS clean_email
FROM dbo.Customers;








9. TRANSLATE() 🔤
একাধিক character একসাথে অন্য character দিয়ে translate করে।
Syntax
-- Syntax
SELECT TRANSLATE(string, characters, translations);
Example
-- =========================================================
-- Replace multiple phone separators
-- '-' and '/' are converted to spaces
-- =========================================================
SELECT
    TRANSLATE(
        '+880-1711/123456',
        '-/',
        '  '
    ) AS translated_phone;


Result:
+880 1711 123456

   
REPLACE vs TRANSLATE
REPLACE	                   TRANSLATE
substring replace	          character mapping
one replacement at a time	 multiple characters
text transformation	       character transformation




   



10. LEFT() ✂️
String-এর বাম দিক থেকে নির্দিষ্ট number of characters নেয়।
-- =========================================================
-- Extract product prefix from product code
-- =========================================================
SELECT
    product_code,
    LEFT(TRIM(product_code), 3) AS product_prefix
FROM dbo.Products;


Example:
LAP-001
↓
LAP
Business use
LAP = Laptop
PHN = Phone
MON = Monitor





   

11. RIGHT()
ডান দিক থেকে characters নেয়।
-- =========================================================
-- Extract last 3 characters from product code
-- Useful for suffix analysis
-- =========================================================
SELECT
    product_code,
    RIGHT(TRIM(product_code), 3) AS product_number
FROM dbo.Products;








12. SUBSTRING() ✂️
String-এর মাঝখান থেকে নির্দিষ্ট অংশ বের করে।
Syntax
-- Syntax
SELECT SUBSTRING(string, start_position, length);


Order reference
-- =========================================================
-- Extract year from order reference
-- ORD-2026-0001
-- Position 5 = 2026
-- =========================================================
SELECT
    order_reference,
    SUBSTRING(TRIM(order_reference), 5, 4) AS order_year
FROM dbo.Orders;

Result:
ORD-2026-0001
     ↑
    2026

   
Extract order number
-- =========================================================
-- Extract numeric order sequence
-- =========================================================
SELECT
    order_reference,
    SUBSTRING(
        TRIM(order_reference),
        10,
        4
    ) AS order_number
FROM dbo.Orders;









13. STUFF() 🛠️
একটি string-এর নির্দিষ্ট position থেকে characters remove করে নতুন text insert করে।
Syntax
-- Syntax
SELECT STUFF(string, start, length, replacement);


Example
-- =========================================================
-- Mask part of a phone number
-- Useful for privacy-safe reporting
-- =========================================================
SELECT
    phone,
    STUFF(phone, 6, 4, 'XXXX') AS masked_phone
FROM dbo.Customers
WHERE phone IS NOT NULL;


Example concept:
01711 987654
↓
01711XXXX654

   
Email masking
-- =========================================================
-- Mask part of email username
-- Demonstration of STUFF()
-- =========================================================
SELECT
    email,
    STUFF(email, 2, 4, '****') AS masked_email
FROM dbo.Customers
WHERE email IS NOT NULL;









14. REVERSE() 🔄
String reverse করে।
-- =========================================================
-- Reverse customer last name
-- Useful in string parsing techniques
-- =========================================================
SELECT
    last_name,
    REVERSE(last_name) AS reversed_name
FROM dbo.Customers;

Advanced use
শেষ occurrence খুঁজতে REVERSE() + CHARINDEX() ব্যবহার করা যায়।



   





15. CHARINDEX() 🔎
একটি string-এর মধ্যে অন্য string কোথায় আছে সেটা খুঁজে।
Syntax
-- Syntax
SELECT CHARINDEX(search_expression, expression);


Email domain খুঁজে বের করা
-- =========================================================
-- Find position of @ in customer email
-- Useful for email parsing
-- =========================================================
SELECT
    email,
    CHARINDEX('@', email) AS at_position
FROM dbo.Customers
WHERE email IS NOT NULL;








16. CHARINDEX() + LEFT() — Email Username 📧
-- =========================================================
-- Extract username from email address
-- Example:
-- john.smith@gmail.com -> john.smith
-- =========================================================
SELECT
    email,
    LEFT(
        TRIM(email),
        CHARINDEX('@', TRIM(email)) - 1
    ) AS email_username
FROM dbo.Customers
WHERE email IS NOT NULL;








17. CHARINDEX() + SUBSTRING() — Email Domain
-- =========================================================
-- Extract email domain
-- Example:
-- john.smith@gmail.com -> gmail.com
-- =========================================================
SELECT
    email,
    SUBSTRING(
        TRIM(email),
        CHARINDEX('@', TRIM(email)) + 1,
        LEN(TRIM(email))
    ) AS email_domain
FROM dbo.Customers
WHERE email IS NOT NULL;









18. PATINDEX() 🔎
Pattern-based search করার জন্য।
CHARINDEX() exact text search-এর জন্য বেশি suitable।
PATINDEX() wildcard pattern search করতে পারে।
Syntax
-- Syntax
SELECT PATINDEX('%pattern%', string);


Email-এ digit আছে কিনা
-- =========================================================
-- Find the first numeric character in customer phone
-- =========================================================
SELECT
    phone,
    PATINDEX('%[0-9]%', phone) AS first_digit_position
FROM dbo.Customers
WHERE phone IS NOT NULL;


Name-এ number আছে কিনা
-- =========================================================
-- Detect names containing numeric characters
-- Useful for data quality validation
-- =========================================================
SELECT
    customer_id,
    first_name
FROM dbo.Customers
WHERE PATINDEX('%[0-9]%', first_name) > 0;


Expected result ideally:
0 rows
এটাই Data Quality Check হিসেবে খুব useful।






   


19. CONCAT() 🔗
Multiple values combine করে।
সবচেয়ে বড় সুবিধা: NULL handling।
-- =========================================================
-- Combine first name and last name
-- CONCAT() safely handles NULL values
-- =========================================================
SELECT
    customer_id,
    CONCAT(
        TRIM(first_name),
        ' ',
        TRIM(last_name)
    ) AS full_name
FROM dbo.Customers;









20. CONCAT_WS() 🔗
WS = With Separator
-- =========================================================
-- Combine customer location using comma separator
-- =========================================================
SELECT
    customer_id,
    CONCAT_WS(
        ', ',
        TRIM(city),
        TRIM(country)
    ) AS location
FROM dbo.Customers;

Result:
Dhaka, Bangladesh
New York, USA
London, UK







   

21. CONCAT() বনাম CONCAT_WS()
Function	      Best use
CONCAT()	      arbitrary values combine
CONCAT_WS()	   separator সহ combine


Real-world:
-- =========================================================
-- Build customer display name and location
-- =========================================================
SELECT
    CONCAT(TRIM(first_name), ' ', TRIM(last_name)) AS full_name,
    CONCAT_WS(', ', TRIM(city), TRIM(country)) AS location
FROM dbo.Customers;










22. STRING_AGG() 🔗🔥
একাধিক row-এর string value একটি string-এ combine করে।
এটি reporting-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
   
Customer tags
আমাদের tags comma-separated হওয়ায় পরে normalized table হলে:
Customer 1
VIP
Online
Newsletter
   
একটি report-এ:
VIP, Online, Newsletter
করতে পারি।
   
Example
-- =========================================================
-- Combine product names by category
-- Useful for grouped reporting
-- =========================================================
SELECT
    category,
    STRING_AGG(product_name, ', ') AS products
FROM dbo.Products
GROUP BY category;


Possible output:
Accessories
    Mechanical Keyboard, Wireless Mouse, Business Laptop Bag

Electronics
    Dell Latitude 5520, iPhone 15 Pro, Samsung 27 Inch Monitor

   
Ordered STRING_AGG
-- =========================================================
-- Aggregate products alphabetically within each category
-- SQL Server supports WITHIN GROUP ordering
-- =========================================================
SELECT
    category,
    STRING_AGG(product_name, ', ')
        WITHIN GROUP (ORDER BY product_name) AS products
FROM dbo.Products
GROUP BY category;










23. STRING_SPLIT() ✂️🔥
একটি delimited stringকে multiple rows-এ split করে।
   
আমাদের:
VIP,Online,Newsletter

   
থেকে:
VIP
Online
Newsletter
করতে পারি।
-- =========================================================
-- Split customer tags into individual rows
-- Useful for normalization and analysis
-- =========================================================
SELECT
    customer_id,
    TRIM(value) AS tag
FROM dbo.Customers
CROSS APPLY STRING_SPLIT(tags, ',')
WHERE tags IS NOT NULL;


Real analytics
-- =========================================================
-- Count customers by individual tag
-- =========================================================
SELECT
    TRIM(value) AS tag,
    COUNT(*) AS customer_count
FROM dbo.Customers
CROSS APPLY STRING_SPLIT(tags, ',')
WHERE tags IS NOT NULL
GROUP BY TRIM(value)
ORDER BY customer_count DESC;









24. STRING_SPLIT() — Data Engineering Use 🔥
   
Source system থেকে এভাবে data আসতে পারে:
Customer_ID | Tags
1           | VIP,Online,Newsletter
2           | Online,Newsletter
3           | VIP,Wholesale

   
ETL-এর সময় এটিকে normalized structure করা যায়:
customer_id | tag
------------|------------
1           | VIP
1           | Online
1           | Newsletter
2           | Online
2           | Newsletter
3           | VIP
3           | Wholesale
এটি অনেক বেশি analytical-friendly।





   



25. LEN() 📏
String-এর character length বের করে।
-- =========================================================
-- Calculate customer name length
-- Useful for profiling and data quality
-- =========================================================
SELECT
    customer_id,
    first_name,
    LEN(first_name) AS name_length
FROM dbo.Customers;


Data quality
-- =========================================================
-- Find suspiciously short customer names
-- =========================================================
SELECT
    customer_id,
    first_name
FROM dbo.Customers
WHERE LEN(TRIM(first_name)) < 2;








26. LEN() Important Detail ⚠️
LEN() trailing spaces count করে না।
   
উদাহরণ:
-- =========================================================
-- Demonstrate LEN behavior with trailing spaces
-- =========================================================
SELECT
    LEN('ABC   ') AS len_result;

Result:
3
তাই raw data profiling-এর সময় এই behavior মনে রাখতে হবে।







   



27. FORMAT() 📊
Number/date human-readable format করতে।
Date
-- =========================================================
-- Format order date as Month-Year
-- Useful for presentation/reporting
-- =========================================================
SELECT
    order_id,
    FORMAT(
        CAST('2026-08-28' AS DATE),
        'MMMM yyyy'
    ) AS month_year
FROM dbo.Orders;


Result:
August 2026

   
Number
-- =========================================================
-- Format sales amount with comma separators
-- Presentation-oriented example
-- =========================================================
SELECT
    FORMAT(1250000.50, 'N2') AS formatted_amount;


Result:
1,250,000.50

⚠️ Best Practice
FORMAT() presentation-এর জন্য ভালো, কিন্তু huge dataset ETL/query performance-এর জন্য সাধারণত avoid করা ভালো।
Power BI/reporting layer-এ formatting করা বেশি appropriate।





   




28. REPLICATE() 🔁
একটি string নির্দিষ্ট সংখ্যক বার repeat করে।
-- =========================================================
-- Repeat a character
-- Useful for report formatting and masking
-- =========================================================
SELECT
    REPLICATE('*', 10) AS separator;

Result:
**********

   
Account masking
-- =========================================================
-- Create a masked representation
-- =========================================================
SELECT
    CONCAT(
        REPLICATE('*', 4),
        RIGHT(TRIM(phone), 4)
    ) AS masked_phone
FROM dbo.Customers
WHERE phone IS NOT NULL;

Concept:
********3456







   


29. SPACE() ␠
Specified number of spaces তৈরি করে।
-- =========================================================
-- Generate spaces between report columns
-- Useful for simple text formatting
-- =========================================================
SELECT
    CONCAT(
        'Customer',
        SPACE(5),
        'Status'
    ) AS formatted_text;










30. NULLIF() 🚫
দুটি expression equal হলে NULL return করে।
Zero → NULL
Data Engineering-এ এটি খুব গুরুত্বপূর্ণ।
-- =========================================================
-- Convert zero quantity into NULL
-- Useful when zero means "missing / invalid"
-- =========================================================
SELECT
    order_item_id,
    quantity,
    NULLIF(quantity, 0) AS cleaned_quantity
FROM dbo.OrderItems;


Division by zero protection
-- =========================================================
-- Avoid division-by-zero errors
-- NULLIF converts zero denominator into NULL
-- =========================================================
SELECT
    order_item_id,
    unit_price,
    quantity,
    unit_price / NULLIF(quantity, 0) AS price_per_unit
FROM dbo.OrderItems;









31. COALESCE() 🚫
প্রথম non-NULL value return করে।
Customer status
-- =========================================================
-- Replace missing customer status with Unknown
-- =========================================================
SELECT
    customer_id,
    COALESCE(
        customer_status,
        'Unknown'
    ) AS customer_status
FROM dbo.Customers;


Email fallback
-- =========================================================
-- Use phone as fallback when email is NULL
-- Demonstrates multiple expressions in COALESCE
-- =========================================================
SELECT
    customer_id,
    COALESCE(
        email,
        phone,
        'No Contact Information'
    ) AS contact_information
FROM dbo.Customers;









32. NULLIF() বনাম COALESCE()
   
Function	       Purpose
NULLIF()	       কিছু value → NULL
COALESCE()	    NULL → fallback value


সহজভাবে:
NULLIF
Value → NULL

COALESCE
NULL → Value






   


33. ASCII() 🔢
Character-এর ASCII numeric code return করে।
-- =========================================================
-- Return ASCII code of first character
-- Useful for character-level data investigation
-- =========================================================
SELECT
    ASCII('A') AS ascii_code;

Result:
65
আর:
-- =========================================================
-- Check ASCII value of first character of customer name
-- =========================================================
SELECT
    customer_id,
    first_name,
    ASCII(first_name) AS first_character_ascii
FROM dbo.Customers;










34. CHAR() 🔢
ASCII number থেকে character তৈরি করে।
-- =========================================================
-- Convert ASCII number into a character
-- =========================================================
SELECT
    CHAR(65) AS character_value;


Result:
A
Line break
-- =========================================================
-- Demonstrate CHAR(13) + CHAR(10)
-- Common Windows line-break combination
-- =========================================================
SELECT
    CONCAT(
        'Customer Report',
        CHAR(13),
        CHAR(10),
        'Generated by SQL Server'
    ) AS report_text;










35. UNICODE() 🌍
Unicode character-এর numeric code return করে।
বিশেষ করে multilingual data-এর জন্য useful।
-- =========================================================
-- Return Unicode code point of a character
-- =========================================================
SELECT
    UNICODE(N'অ') AS unicode_code;











36. NCHAR() 🌍
Unicode number থেকে Unicode character তৈরি করে।
-- =========================================================
-- Convert Unicode code into a Unicode character
-- =========================================================
SELECT
    NCHAR(65) AS unicode_character;


Result:
A

   
Bengali example
-- =========================================================
-- Demonstrate Unicode character handling
-- N prefix is important for Unicode string literals
-- =========================================================

SELECT
    NCHAR(2437) AS unicode_character;











37. ASCII বনাম UNICODE
   
Function	     Use
ASCII()	     SCII character
CHAR()	     ASCII code → character
UNICODE()	  Unicode character
NCHAR()	     Unicode code → character


International customer data-এর জন্য:
NVARCHAR
NCHAR
UNICODE()
NCHAR()
বিষয়গুলো গুরুত্বপূর্ণ।







   


38. একটি Complete Customer Cleaning Query 🧹🔥
এখন বাস্তব Data Analyst/Data Engineer কাজের মতো একটি query বানাই।
-- =========================================================
-- Complete customer data cleaning example
-- Steps:
-- 1. Trim spaces
-- 2. Standardize name casing
-- 3. Normalize email
-- 4. Normalize phone
-- 5. Standardize status
-- 6. Handle NULL values
-- =========================================================
SELECT
    customer_id,

    -- Clean and standardize first name
    UPPER(LEFT(TRIM(first_name), 1))
        + LOWER(SUBSTRING(TRIM(first_name), 2, LEN(TRIM(first_name))))
        AS clean_first_name,

    -- Clean and standardize last name
    UPPER(LEFT(TRIM(last_name), 1))
        + LOWER(SUBSTRING(TRIM(last_name), 2, LEN(TRIM(last_name))))
        AS clean_last_name,

    -- Normalize email
    LOWER(TRIM(email)) AS clean_email,

    -- Remove common phone separators
    REPLACE(
        REPLACE(
            REPLACE(TRIM(phone), '-', ''),
            ' ',
            ''
        ),
        '(',
        ''
    ) AS clean_phone,

    -- Standardize status
    COALESCE(
        UPPER(TRIM(customer_status)),
        'UNKNOWN'
    ) AS clean_status,

    -- Clean location
    CONCAT_WS(
        ', ',
        TRIM(city),
        TRIM(country)
    ) AS location

FROM dbo.Customers;

এখানে একসাথে আমরা ব্যবহার করেছি:
TRIM
UPPER
LOWER
LEFT
SUBSTRING
LEN
REPLACE
COALESCE
CONCAT_WS
এটাই real-world SQL transformation।







   


39. Email Validation Project 📧
Data quality-এর জন্য খুব useful।
-- =========================================================
-- Validate customer email addresses
-- Checks:
-- 1. Email exists
-- 2. Contains @
-- 3. Contains dot after @
-- =========================================================
SELECT
    customer_id,
    email,

    CASE
        WHEN email IS NULL THEN 'Missing Email'

        WHEN CHARINDEX('@', TRIM(email)) = 0
            THEN 'Invalid - Missing @'

        WHEN CHARINDEX(
                '.',
                TRIM(email),
                CHARINDEX('@', TRIM(email)) + 1
             ) = 0
            THEN 'Invalid - Missing Domain'

        ELSE 'Valid'
    END AS email_status

FROM dbo.Customers;









40. Phone Data Quality Project 📱
-- =========================================================
-- Detect phone numbers containing unexpected characters
-- PATINDEX searches for characters outside digits and
-- common phone symbols
-- =========================================================
SELECT
    customer_id,
    phone
FROM dbo.Customers
WHERE phone IS NOT NULL
AND PATINDEX('%[^0-9 +()-]%', phone) > 0;


এখানে:
[0-9]
মানে digit।
আর:
[^0-9]
মানে digit ছাড়া অন্য character।









   


41. Product Code Validation 📦
-- =========================================================
-- Validate product codes
-- Expected format:
-- ABC-123
-- =========================================================
SELECT
    product_id,
    product_code
FROM dbo.Products
WHERE PATINDEX(
    '%[^A-Z0-9 -]%',
    UPPER(TRIM(product_code))
) > 0;












42. Extract Product Prefix
-- =========================================================
-- Extract product category prefix
-- Example:
-- LAP-001 -> LAP
-- PHN-002 -> PHN
-- =========================================================
SELECT
    product_id,
    product_code,
    LEFT(
        TRIM(product_code),
        CHARINDEX('-', TRIM(product_code)) - 1
    ) AS product_prefix
FROM dbo.Products;












43. Build a Customer Master View 🏆
Real project-এ cleaning query-কে view হিসেবে রাখা যেতে পারে।
-- =========================================================
-- Create cleaned customer analytical view
-- Provides standardized customer attributes
-- =========================================================
CREATE OR ALTER VIEW dbo.vw_CleanCustomers
AS
SELECT
    customer_id,

    CONCAT(
        UPPER(LEFT(TRIM(first_name), 1)),
        LOWER(SUBSTRING(TRIM(first_name), 2, LEN(TRIM(first_name)))),
        ' ',
        UPPER(LEFT(TRIM(last_name), 1)),
        LOWER(SUBSTRING(TRIM(last_name), 2, LEN(TRIM(last_name))))
    ) AS full_name,

    LOWER(TRIM(email)) AS email,

    REPLACE(
        REPLACE(TRIM(phone), '-', ''),
        ' ',
        ''
    ) AS phone,

    CONCAT_WS(
        ', ',
        TRIM(city),
        TRIM(country)
    ) AS location,

    COALESCE(
        UPPER(TRIM(customer_status)),
        'UNKNOWN'
    ) AS customer_status

FROM dbo.Customers;


GO
তারপর:
-- =========================================================
-- Analyze cleaned customer master data
-- =========================================================
SELECT *
FROM dbo.vw_CleanCustomers;










44. Customer Tags Analysis 📊
-- =========================================================
-- Split customer tags into individual rows
-- Then count customers by tag
-- =========================================================
SELECT
    TRIM(value) AS tag,
    COUNT(DISTINCT customer_id) AS customers
FROM dbo.Customers
CROSS APPLY STRING_SPLIT(tags, ',')
WHERE tags IS NOT NULL
GROUP BY TRIM(value)
ORDER BY customers DESC;


Business question:
কতজন customer VIP?

-- =========================================================
-- Count customers having VIP tag
-- =========================================================
SELECT
    COUNT(DISTINCT customer_id) AS vip_customers
FROM dbo.Customers
CROSS APPLY STRING_SPLIT(tags, ',')
WHERE TRIM(value) = 'VIP';










45. STRING_AGG + STRING_SPLIT 🔥
এটি real reporting-এ খুব powerful combination।
প্রথমে split:
VIP
Online
Newsletter
   
তারপর আবার aggregate:
VIP, Online, Newsletter

   
উদাহরণ:
-- =========================================================
-- Rebuild customer tags into a standardized comma-separated
-- representation
-- =========================================================
SELECT
    customer_id,
    STRING_AGG(
        TRIM(value),
        ', '
    ) AS standardized_tags
FROM dbo.Customers
CROSS APPLY STRING_SPLIT(tags, ',')
GROUP BY customer_id;











46. Real Sales Analysis Project 💰
এখন String functions + JOIN ব্যবহার করি।
-- =========================================================
-- Build a sales analysis dataset
-- Combines customers, orders, order items and products
-- Also applies string standardization
-- =========================================================
SELECT
    o.order_id,

    CONCAT(
        TRIM(c.first_name),
        ' ',
        TRIM(c.last_name)
    ) AS customer_name,

    LOWER(TRIM(c.email)) AS customer_email,

    UPPER(TRIM(o.sales_channel)) AS sales_channel,

    TRIM(p.product_name) AS product_name,

    TRIM(p.category) AS category,

    oi.quantity,

    oi.unit_price,

    oi.quantity * oi.unit_price AS sales_amount

FROM dbo.Orders AS o

INNER JOIN dbo.Customers AS c
    ON o.customer_id = c.customer_id

INNER JOIN dbo.OrderItems AS oi
    ON o.order_id = oi.order_id

INNER JOIN dbo.Products AS p
    ON oi.product_id = p.product_id;

এখানে string functions শুধুমাত্র cleaning-এর জন্য নয়—analytical dataset তৈরির অংশ হিসেবেও কাজ করছে।





   




47. Data Engineering ETL Pattern 🏭
Real-world pipeline:
SOURCE
  ↓
Raw Data
  ↓
TRIM
  ↓
UPPER / LOWER
  ↓
REPLACE / TRANSLATE
  ↓
Validation
  ↓
NULLIF / COALESCE
  ↓
Extraction
  ↓
Split / Normalize
  ↓
Silver
  ↓
Gold
  ↓
Power BI
   
Example Silver transformation
-- =========================================================
-- Example Silver-layer customer transformation
-- Standardizes source data before analytical loading
-- =========================================================
SELECT
    customer_id,

    TRIM(first_name) AS first_name,

    TRIM(last_name) AS last_name,

    LOWER(
        NULLIF(TRIM(email), '')
    ) AS email,

    REPLACE(
        REPLACE(
            TRIM(phone),
            '-',
            ''
        ),
        ' ',
        ''
    ) AS phone,

    UPPER(
        TRIM(customer_status)
    ) AS customer_status,

    TRIM(city) AS city,

    TRIM(country) AS country

FROM dbo.Customers;









48. Important String Function Cheat Sheet 📚
   
Function	           মূল কাজ	               Real-world use
LOWER()	           lowercase	               Email normalization
UPPER()	           uppercase	               Status/category standardization
TRIM()	           দুই পাশের space	         Data cleaning
LTRIM()	           left space	            Source cleanup
RTRIM()	           right space	            Source cleanup
REPLACE()	        text replace	            Phone/email cleaning
TRANSLATE()	        character mapping	      Multi-character cleanup
LEFT()	           left extraction	         Product prefix
RIGHT()	           right extraction	      Code suffix
SUBSTRING()	        middle extraction	      ID/date/code parsing
STUFF()	           replace section	         Masking/transformation
REVERSE()	        reverse string	         Advanced parsing
CHARINDEX()	        exact search	            Email parsing
PATINDEX()	        pattern search	         Data validation
CONCAT()	           combine	               Full name
CONCAT_WS()	        separator + combine	   Address/location
STRING_AGG()	     rows → string	         Reporting
STRING_SPLIT()	     string → rows	         Tags/categories
LEN()	              length	                  Data quality
FORMAT()	           presentation formatting	Reports
REPLICATE()	        repeat string	         Masking/formatting
SPACE()	           spaces generate	         Text formatting
NULLIF()	           value → NULL	            Divide-by-zero/data cleanup
COALESCE()	        NULL → fallback	         Missing data
ASCII()	           char → ASCII	            Character analysis
CHAR()	           ASCII → char	            Control characters
UNICODE()	        char → Unicode	         International data
NCHAR()	           Unicode → char	         Unicode generation






   




49. সবচেয়ে গুরুত্বপূর্ণ Real-World Pattern 🔥
শুধু function আলাদাভাবে মুখস্থ করবেন না।
এই ধরনের combination আয়ত্ত করুন:
-- =========================================================
-- Pattern 1: Clean + Normalize
-- =========================================================

LOWER(TRIM(email))
-- =========================================================
-- Pattern 2: Clean + Standardize
-- =========================================================

UPPER(TRIM(customer_status))
-- =========================================================
-- Pattern 3: Extract
-- =========================================================

LEFT(
    TRIM(product_code),
    CHARINDEX('-', TRIM(product_code)) - 1
)
-- =========================================================
-- Pattern 4: Email parsing
-- =========================================================

SUBSTRING(
    email,
    CHARINDEX('@', email) + 1,
    LEN(email)
)
-- =========================================================
-- Pattern 5: NULL handling
-- =========================================================

COALESCE(
    NULLIF(TRIM(email), ''),
    'NO EMAIL'
)
-- =========================================================
-- Pattern 6: Data cleaning
-- =========================================================

REPLACE(
    REPLACE(
        TRIM(phone),
        '-',
        ''
    ),
    ' ',
    ''
)
-- =========================================================
-- Pattern 7: Split + Analyze
-- =========================================================

CROSS APPLY STRING_SPLIT(tags, ',')
-- =========================================================
-- Pattern 8: Aggregate strings
-- =========================================================

STRING_AGG(product_name, ', ')







   


50. Final Practice Project 🎯
এই database দিয়ে আপনার hands-on project এমন হবে:
                 StringFunctionsDB
                        │
          ┌─────────────┼─────────────┐
          ↓             ↓             ↓
      Customers      Products       Employees
          │             │
          ↓             ↓
        Orders ───→ OrderItems
          │
          ↓
   String Transformation
          │
 ┌────────┼─────────┐
 ↓        ↓         ↓
Clean   Extract   Validate
 ↓        ↓         ↓
Normalize Parse    DQ Checks
 └────────┼─────────┘
          ↓
       Analytics
          ↓
      Reporting
          ↓
       Power BI


   
   
🎯 Practice Tasks
1. সব customer name clean করুন
2. সব email lowercase করুন
3. email username বের করুন
4. email domain বের করুন
5. phone number normalize করুন
6. invalid phone detect করুন
7. customer status standardize করুন
8. NULL status handle করুন
9. customer full name তৈরি করুন
10. city + country combine করুন
11. product prefix বের করুন
12. product suffix বের করুন
13. order year extract করুন
14. order number extract করুন
15. customer tags split করুন
16. tag অনুযায়ী customer count করুন
17. category অনুযায়ী product STRING_AGG করুন
18. email validation করুন
19. name-এ number আছে কিনা check করুন
20. product code validation করুন
21. phone masking করুন
22. sales dataset তৈরি করুন
23. cleaned customer view তৈরি করুন
24. Silver-layer transformation তৈরি করুন
25. Data Quality report তৈরি করুন








🧠 সবচেয়ে গুরুত্বপূর্ণ takeaway
String Functions শুধু text manipulation নয়।
SQL Server-এর real job-এ এগুলো মূলত:
Raw Data
   ↓
🧹 Cleaning
   ↓
🔤 Standardization
   ↓
✂️ Parsing
   ↓
🔎 Validation
   ↓
🔗 Transformation
   ↓
📊 Analytics
   ↓
🏭 ETL / Data Warehouse
   ↓
📈 Reporting


