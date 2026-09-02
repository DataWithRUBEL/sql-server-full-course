1.
/*
==============================================================================
SELECT ALL COLUMNS
==============================================================================
*/
-- Retrieve All Customer Data
SELECT *
FROM customers;

-- Retrieve All Order Data
SELECT *
FROM orders;




2. 
/*
==============================================================================
SELECT FEW COLUMNS
==============================================================================
*/

-- Retrieve each customer's name, country, and score.
SELECT
    first_name,
    country,
    score
FROM customers;




3. 
/*
==============================================================================
WHERE
==============================================================================
*/
-- Retrieve customers with a score not equal to 0
SELECT *
FROM customers
WHERE score != 0;

-- Retrieve customers from Germany
SELECT *
FROM customers
WHERE country = 'Germany';


-- Retrieve the name and country of customers from Germany
SELECT
    first_name,
    country
FROM customers
WHERE country = 'Germany';


4.
/*
==============================================================================
ORDER BY
==============================================================================
*/

/*
Retrieve all customers and sort the results
by the highest score first.
*/
SELECT *
FROM customers
ORDER BY score DESC;


/*
Retrieve all customers and sort the results
by the lowest score first.
*/
SELECT *
FROM customers
ORDER BY score ASC;


/*
Retrieve all customers and sort the results
by the country.
*/
SELECT *
FROM customers
ORDER BY country ASC;


/*
Retrieve all customers and sort the results
by the country and then by the highest score.
*/
SELECT *
FROM customers
ORDER BY
    country ASC,
    score DESC;


/*
Retrieve the name, country, and score of customers
whose score is not equal to 0 and sort the results
by the highest score first.
*/
SELECT
    first_name,
    country,
    score
FROM customers
WHERE score != 0
ORDER BY score DESC;





5.
/*
==============================================================================
GROUP BY
==============================================================================
*/
-- Find the total score for each country
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;


/*
This will not work because 'first_name'
is neither part of the GROUP BY
nor wrapped in an aggregate function.

SQL Server doesn't know which first_name
should represent the country.
*/
SELECT
    country,
    first_name,
    SUM(score) AS total_score
FROM customers
GROUP BY country;


/*
Find the total score and total number
of customers for each country.
*/
SELECT
    country,
    SUM(score) AS total_score,
    COUNT(id) AS total_customers
FROM customers
GROUP BY country;






6. 
/*
==============================================================================
HAVING
==============================================================================
*/
/*
Find the average score for each country
and return only those countries
with an average score greater than 430.
*/
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
GROUP BY country
HAVING AVG(score) > 430;



/*
Find the average score for each country
considering only customers with a score
not equal to 0.

Return only countries with
average score greater than 430.
*/
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 430;






7. 
/*
==============================================================================
DISTINCT
==============================================================================
*/
-- Return Unique list of all countries
SELECT DISTINCT
    country
FROM customers;







8. 
/*
==============================================================================
TOP
==============================================================================
*/
-- Retrieve only 3 Customers
SELECT TOP 3 *
FROM customers;


/*
Retrieve the Top 3 Customers
with the Highest Scores.
*/
SELECT TOP 3 *
FROM customers
ORDER BY score DESC;


/*
Retrieve the Lowest 2 Customers
based on the score.
*/
SELECT TOP 2 *
FROM customers
ORDER BY score ASC;


/*
Get the Two Most Recent Orders.
*/
SELECT TOP 2 *
FROM orders
ORDER BY order_date DESC;






9. 
/*
==============================================================================
ALL TOGETHER
==============================================================================
*/

/*
Calculate the average score for each country
considering only customers with a score
not equal to 0.

Return only countries with an average score
greater than 430.

Sort the results by the highest average score first.
*/
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
WHERE score != 0
GROUP BY country
HAVING AVG(score) > 430
ORDER BY AVG(score) DESC;






10.
/*
==============================================================================
COOL STUFF - ADDITIONAL SQL FEATURES
==============================================================================
*/
-- Execute multiple queries at once
SELECT *
FROM customers;

SELECT *
FROM orders;





11.
/*
------------------------------------------------------------------------------
Selecting Static Data
------------------------------------------------------------------------------
*/
-- Select a static or constant value
-- without accessing any table

SELECT
    123 AS static_number;


SELECT
    'Hello' AS static_string;





12.
/*
Assign a constant value to a column in a query.
*/
SELECT
    id,
    first_name,
    'New Customer' AS customer_type
FROM customers;






More practice
1. SELECT — Column/Data নির্বাচন 🎯
SELECT বলে কোন data/column দেখতে চাই।
    
উদাহরণ
SELECT
    first_name,
    country,
    score
FROM customers;






2. FROM — কোন Table থেকে Data নেব 📦
FROM বলে data কোথা থেকে আসবে।
SELECT
    first_name,
    country
FROM customers;


আরেকটি Example
SELECT *
FROM orders;

মানে orders table-এর সব column এবং row।





    
3. WHERE — Row Filter 🔎
WHERE নির্দিষ্ট row filter করে।
-- Germany-এর customers
    
SELECT
    first_name,
    country,
    score
FROM customers
WHERE country = 'Germany';

শুধু Germany-এর customer আসবে।



-- Score 800-এর বেশি
SELECT
    first_name,
    score
FROM customers
WHERE score > 800;



-- Multiple Conditions
SELECT
    first_name,
    country,
    score
FROM customers
WHERE country = 'Germany'
  AND score > 800;







4. ORDER BY — Result Sort 🔢
ORDER BY result-কে সাজায়।
    
-- Highest score → Lowest
SELECT
    first_name,
    score
FROM customers
ORDER BY score DESC;

DESC = বড় → ছোট



    

-- Lowest → Highest
SELECT
    first_name,
    score
FROM customers
ORDER BY score ASC;

ASC = ছোট → বড়।




-- Multiple Sorting
SELECT
    first_name,
    country,
    score
FROM customers
ORDER BY
    country ASC,
    score DESC;

এখানে প্রথমে country অনুযায়ী sort হবে।
তারপর একই country-এর মধ্যে highest score আগে আসবে।




    


5. GROUP BY — Data Group করা 📊
GROUP BY একই ধরনের data-কে group করে।
ধরুন:
USA
USA
USA
UK
UK
Germany
Germany
GROUP BY country করলে:
USA
UK
Germany
তারপর aggregate function ব্যবহার করে প্রতিটি group-এর calculation করতে পারেন।





-- Country অনুযায়ী customer count
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country;





-- Country অনুযায়ী total score
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;







6. HAVING — Group Filter 🎯
WHERE এবং HAVING-এর পার্থক্য খুব গুরুত্বপূর্ণ।

Example
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
GROUP BY country
HAVING AVG(score) > 700;

প্রথমে country অনুযায়ী group হবে:




    

7. DISTINCT — Duplicate Remove 🧹
একই country অনেকবার থাকতে পারে:
USA
USA
USA
UK
UK
Germany
Germany
আপনি যদি unique country চান:
    
SELECT DISTINCT
    country
FROM customers;





⚠️ গুরুত্বপূর্
ণ
--DISTINCT পুরো selected combination-এর duplicate remove করে।
SELECT DISTINCT
    country,
    city
FROM customers;

এখানে country + city combination unique হবে।





    



8. TOP — Limited Rows 🔝
    
-- শুধু প্রথম 3টি row:
SELECT TOP 3 *
FROM customers;





কিন্তু business analysis-এ সাধারণত ORDER BY সহ ব্যবহার করা উচিত।
-- Top 3 highest-score customers
SELECT TOP 3
    first_name,
    country,
    score
FROM customers
ORDER BY score DESC;





🔥 Best Practice
    
এটা:
SELECT TOP 3 *
FROM customers;


-- এর চেয়ে এটা meaningful:
SELECT TOP 3
    first_name,
    country,
    score
FROM customers
ORDER BY score DESC;

কারণ আপনি clearly define করেছেন কোন 3টি record চান।





    

9. SUM() — Total বের করা 💰
SUM() numeric column-এর total বের করে।

    
-- সব customer-এর total score
SELECT
    SUM(score) AS total_score
FROM customers;


-- Country অনুযায়ী total score
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;


-- Sales Example
SELECT
    SUM(sales_amount) AS total_sales
FROM orders;

এটা Data Analyst-এর খুব common calculation।






    

10. AVG() — Average বের করা 📈
AVG() average value বের করে।


-- Customer average score
SELECT
    AVG(score) AS average_score
FROM customers;


-- Country-wise average
SELECT
    country,
    AVG(score) AS average_score
FROM customers
GROUP BY country;



Real Business Question
-- কোন দেশের customers-এর average score সবচেয়ে বেশি?
SELECT
    country,
    AVG(score) AS average_score
FROM customers
GROUP BY country
ORDER BY average_score DESC;








11. COUNT() — কতগুলো Row আছে 🔢
COUNT() count করে।

    
-- Total customers
SELECT
    COUNT(*) AS total_customers
FROM customers;

Result:
50


    
-- Country-wise customer count
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country;



COUNT(*) vs COUNT(column)
দুটোর পার্থক্য গুরুত্বপূর্ণ।
    
-- COUNT(*)
SELECT COUNT(*)
FROM customers;

সব row count করে।


 
-- COUNT(score)
SELECT COUNT(score)
FROM customers;

score-এর মধ্যে NULL থাকলে সেগুলো count করবে না।





    


12. MIN() — Smallest Value ⬇️
    
-- MIN() সবচেয়ে ছোট value বের করে।
SELECT
    MIN(score) AS lowest_score
FROM customers;



-- Country-wise lowest score
SELECT
    country,
    MIN(score) AS lowest_score
FROM customers
GROUP BY country;


-- Orders-এর lowest sales
SELECT
    MIN(sales_amount) AS minimum_sales
FROM orders;






13. MAX() — Largest Value ⬆️
    
-- MAX() সবচেয়ে বড় value বের করে।
SELECT
    MAX(score) AS highest_score
FROM customers;



-- Country-wise highest score
SELECT
    country,
    MAX(score) AS highest_score
FROM customers
GROUP BY country;



-- Highest sales transaction
SELECT
    MAX(sales_amount) AS highest_sales
FROM orders;









14. AS — Alias / নতুন নাম 🏷️
    
-- AS দিয়ে output column-এর temporary নাম দেওয়া হয়।
SELECT
    first_name AS customer_name,
    country AS customer_country,
    score AS customer_score
FROM customers;


আগে:
first_name
country
score
    
এখন:
customer_name
customer_country
customer_score





15. Aggregate-এর সাথে AS
এটা খুব common:
SELECT
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS average_sales,
    COUNT(*) AS total_orders,
    MIN(sales_amount) AS minimum_sales,
    MAX(sales_amount) AS maximum_sales
FROM orders;






16. 🔥 সবগুলো একসাথে
-- এটাই সবচেয়ে গুরুত্বপূর্ণ real-world pattern:
SELECT
    country,
    COUNT(*) AS total_customers,
    SUM(score) AS total_score,
    AVG(score) AS average_score,
    MIN(score) AS minimum_score,
    MAX(score) AS maximum_score
FROM customers
WHERE score > 300
GROUP BY country
HAVING AVG(score) > 600
ORDER BY average_score DESC;










Extra Practice


1. SELECT — Column/Data নির্বাচন 🎯
    
/* SELECT বলে কোন data/column দেখতে চাই।
উদাহরণ */
SELECT
    first_name,
    country,
    score
FROM customers;








2. FROM — কোন Table থেকে Data নেব 📦

-- FROM বলে data কোথা থেকে আসবে।
SELECT
    first_name,
    country
FROM customers;

এখানে:
SELECT → কী দেখতে চাই
FROM   → কোথা থেকে নিতে চাই





    


3. WHERE — Row Filter 🔎
    
/* WHERE নির্দিষ্ট row filter করে।
Germany-এর customers */
SELECT
    first_name,
    country,
    score
FROM customers
WHERE country = 'Germany';



-- শুধু Germany-এর customer আসবে।
-- Score 800-এর বেশি 
SELECT
    first_name,
    score
FROM customers
WHERE score > 800;




-- Multiple Conditions
SELECT
    first_name,
    country,
    score
FROM customers
WHERE country = 'Germany'
  AND score > 800;

অর্থাৎ:  
Germany
   +
Score > 800
   ↓
Final Rows





    

4. ORDER BY — Result Sort 🔢
    
-- ORDER BY result-কে সাজায়।
-- Highest score → Lowest
SELECT
    first_name,
    score
FROM customers
ORDER BY score DESC;

DESC = বড় → ছোট



    
-- Lowest → Highest
SELECT
    first_name,
    score
FROM customers
ORDER BY score ASC;
ASC = ছোট → বড়।


    

-- Multiple Sorting
SELECT
    first_name,
    country,
    score
FROM customers
ORDER BY
    country ASC,
    score DESC;

এখানে প্রথমে country অনুযায়ী sort হবে।
তারপর একই country-এর মধ্যে highest score আগে আসবে।





    

5. GROUP BY — Data Group করা 📊
GROUP BY একই ধরনের data-কে group করে।
    
ধরুন:
USA
USA
USA
UK
UK
Germany
Germany
    
GROUP BY country করলে:
USA
UK
Germany
তারপর aggregate function ব্যবহার করে প্রতিটি group-এর calculation করতে পারেন।



-- Country অনুযায়ী customer count
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country;




-- Country অনুযায়ী total score
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;







6. HAVING — Group Filter 🎯
WHERE এবং HAVING-এর পার্থক্য খুব গুরুত্বপূর্ণ।
    
Feature	     কাজ
WHERE	     Individual row filter
HAVING	     Group filter


    
-- Example
SELECT
    country,
    AVG(score) AS avg_score
FROM customers
GROUP BY country
HAVING AVG(score) > 700;

প্রথমে country অনুযায়ী group হবে:
USA
UK
Germany
France

    
    
-- তারপর প্রতিটি country's average score বের হবে।
তারপর:
AVG(score) > 700 
    
যেসব country-এর average 700-এর বেশি, 
শুধু সেগুলো থাকবে।





    


7. DISTINCT — Duplicate Remove 🧹
    
একই country অনেকবার থাকতে পারে:
USA
USA
USA
UK
UK
Germany
Germany

    
-- আপনি যদি unique country চান:
SELECT DISTINCT
    country
FROM customers;

Result:
USA
UK
Germany
France
Canada
Kuwait
Bangladesh
India
Australia
Brazil


    
⚠️ গুরুত্বপূর্ণ
-- DISTINCT পুরো selected combination-এর duplicate remove করে।
SELECT DISTINCT
    country,
    city
FROM customers;

এখানে country + city combination unique হবে।





    


8. TOP — Limited Rows 🔝

--শুধু প্রথম 3টি row: 
SELECT TOP 3 *
FROM customers;



-- কিন্তু business analysis-এ সাধারণত ORDER BY সহ ব্যবহার করা উচিত।
-- Top 3 highest-score customers
SELECT TOP 3
    first_name,
    country,
    score
FROM customers
ORDER BY score DESC;


Result conceptually
Ananya    India      980
Sara      Kuwait     970
Ava       France     960

    
-- Best Practice
এটা: 
SELECT TOP 3 *
FROM customers;




-- এর চেয়ে এটা meaningful:
SELECT TOP 3
    first_name,
    country,
    score
FROM customers
ORDER BY score DESC;

কারণ আপনি clearly define করেছেন কোন 3টি record চান।






9. SUM() — Total বের করা 💰

-- SUM() numeric column-এর total বের করে।
-- সব customer-এর total score
SELECT
    SUM(score) AS total_score
FROM customers;



-- Country অনুযায়ী total score
SELECT
    country,
    SUM(score) AS total_score
FROM customers
GROUP BY country;




-- Sales Example
SELECT
    SUM(sales_amount) AS total_sales
FROM orders;

এটা Data Analyst-এর খুব common calculation।






    

10. AVG() — Average বের করা 📈
    
-- AVG() average value বের করে।
-- Customer average score
SELECT
    AVG(score) AS average_score
FROM customers;



-- Country-wise average
SELECT
    country,
    AVG(score) AS average_score
FROM customers
GROUP BY country;





-- Real Business Question
--কোন দেশের customers-এর average score সবচেয়ে বেশি?
SELECT
    country,
    AVG(score) AS average_score
FROM customers
GROUP BY country
ORDER BY average_score DESC;







11. COUNT() — কতগুলো Row আছে 🔢
    
-- COUNT() count করে।
-- Total customers
SELECT
    COUNT(*) AS total_customers
FROM customers;

Result:
50


    
-- Country-wise customer count
SELECT
    country,
    COUNT(*) AS total_customers
FROM customers
GROUP BY country;




COUNT(*) vs COUNT(column)
দুটোর পার্থক্য গুরুত্বপূর্ণ।
    
-- COUNT(*)
SELECT COUNT(*)
FROM customers;


-- সব row count করে।
-- COUNT(score)
SELECT COUNT(score)
FROM customers;

score-এর মধ্যে NULL থাকলে সেগুলো count করবে না।






    

12. MIN() — Smallest Value ⬇️
    
-- MIN() সবচেয়ে ছোট value বের করে।
SELECT
    MIN(score) AS lowest_score
FROM customers;



-- Country-wise lowest score
SELECT
    country,
    MIN(score) AS lowest_score
FROM customers
GROUP BY country;



-- Orders-এর lowest sales
SELECT
    MIN(sales_amount) AS minimum_sales
FROM orders;









13. MAX() — Largest Value ⬆️
    
-- MAX() সবচেয়ে বড় value বের করে।
SELECT
    MAX(score) AS highest_score
FROM customers;



-- Country-wise highest score
SELECT
    country,
    MAX(score) AS highest_score
FROM customers
GROUP BY country;



-- Highest sales transaction
SELECT
    MAX(sales_amount) AS highest_sales
FROM orders;








14. AS — Alias / নতুন নাম 🏷️
    
-- AS দিয়ে output column-এর temporary নাম দেওয়া হয়।
SELECT
    first_name AS customer_name,
    country AS customer_country,
    score AS customer_score
FROM customers;

আগে:
first_name
country
score
    
এখন:
customer_name
customer_country
customer_score



-- Aggregate-এর সাথে AS
এটা খুব common:
SELECT
    SUM(sales_amount) AS total_sales,
    AVG(sales_amount) AS average_sales,
    COUNT(*) AS total_orders,
    MIN(sales_amount) AS minimum_sales,
    MAX(sales_amount) AS maximum_sales
FROM orders;




15. সবগুলো একসাথে
    
-- এটাই সবচেয়ে গুরুত্বপূর্ণ real-world pattern:
SELECT
    country,
    COUNT(*) AS total_customers,
    SUM(score) AS total_score,
    AVG(score) AS average_score,
    MIN(score) AS minimum_score,
    MAX(score) AS maximum_score
FROM customers
WHERE score > 300
GROUP BY country
HAVING AVG(score) > 600
ORDER BY average_score DESC;


এখানে:
FROM
 ↓
customers table

WHERE
 ↓
score > 300

GROUP BY
 ↓
country

COUNT()
 ↓
কত customer

SUM()
 ↓
মোট score

AVG()
 ↓
average score

MIN()
 ↓
lowest score

MAX()
 ↓
highest score

HAVING
 ↓
average > 600

ORDER BY
 ↓
highest average first

SELECT
 ↓
Final columns





16. 🎯 Data Analyst + Data Engineer-এর জন্য সবচেয়ে গুরুত্বপূর্ণ Pattern
    
-- বাস্তব SQL কাজের সময় এই pattern বারবার দেখতে পাবেন:
SELECT
    dimension,
    COUNT(*) AS total_records,
    SUM(measure) AS total_value,
    AVG(measure) AS average_value,
    MIN(measure) AS minimum_value,
    MAX(measure) AS maximum_value
FROM table_name
WHERE condition
GROUP BY dimension
HAVING aggregate_condition
ORDER BY total_value DESC;


