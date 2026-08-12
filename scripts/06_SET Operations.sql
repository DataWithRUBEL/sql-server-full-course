1. SET Operations-এর Rules
SQL Server-এ প্রধান ৪টি SET Operation:
  
Operation	                কাজ	                               Duplicate
UNION	                    দুই result একত্র করে	                 ❌ Remove
UNION ALL	                দুই result একত্র করে	                 ✅ রাখে
EXCEPT	                  প্রথম query-তে আছে, দ্বিতীয়টিতে নেই	   ❌
INTERSECT	                দুই query-তেই আছে	                   ❌

  

গুরুত্বপূর্ণ Rule
  
দুই SELECT-এর:
একই সংখ্যক column থাকতে হবে
Corresponding column-এর data type compatible হতে হবে
Column order একই logical meaning-এর হতে হবে
Result-এর column name প্রথম SELECT থেকে আসবে 



2. ❌ ভুল — Column সংখ্যা আলাদা
-- Customers থেকে 3টি column
SELECT
    FirstName,
    LastName,
    Country
FROM Customers

UNION

-- Employees থেকে মাত্র 2টি column
SELECT
    FirstName,
    LastName
FROM Employees;


❌ Error হবে।
কারণ:
Customers  → 3 columns
Employees  → 2 columns






Correct
-- দুই query-তেই 2টি column
SELECT
    FirstName,
    LastName
FROM Customers

UNION

SELECT
    FirstName,
    LastName
FROM Employees;






