1. Project Architecture 🏗️
আমাদের database:
NumberMathematicalNumericNullConversionDB
│
└── analytics
    ├── Customers
    ├── Products
    ├── Sales
    ├── Targets
    └── ETL_Source_Sales



Business calculations
- 💰 Revenue = Quantity × UnitPrice
- 💸 Cost = Quantity × UnitCost
- 📈 Profit = Revenue − Cost
- 📊 Margin % = Profit ÷ Revenue × 100
- 🎯 Variance = Actual − Target
- 📈 Growth % = Current − Previous ÷ Previous × 100
- 🧹 Data Quality = invalid/negative/zero numeric values
- 🔄 ETL = text → numeric safely convert
- 🏗️ Reconciliation = source vs warehouse totals





2. Numeric Data Types
  
INT
কাজ: সাধারণ whole number।
-- INT is suitable for normal quantities and identifiers
DECLARE @Quantity INT = 25;

SELECT @Quantity AS Quantity;
Typical use:
- CustomerID
- ProductID
- Quantity
- Status codes
- Employee count

  
BIGINT
কাজ: খুব বড় integer value।
-- BIGINT handles much larger integer values than INT
DECLARE @LifetimeTransactions BIGINT = 5000000000;

SELECT @LifetimeTransactions AS LifetimeTransactions;

INT vs BIGINT
Type	      Approximate range	      Typical use
INT	        ±2.1 billion	          IDs, quantity
BIGINT	    ±9.22 quintillion	      huge transaction IDs

Best practice: প্রয়োজনের চেয়ে বড় datatype blindly ব্যবহার করবেন না।








3. DECIMAL
Financial calculation-এর জন্য সবচেয়ে গুরুত্বপূর্ণ numeric type।
-- DECIMAL provides fixed precision for financial calculations
SELECT
    CAST(899.99 AS DECIMAL(12,2)) AS UnitPrice,
    CAST(1799.98 AS DECIMAL(14,2)) AS Revenue;

DECIMAL(12,2) অর্থ
12 = মোট digits
2  = decimal-এর পর digits

8999999999.99
💰 Money → DECIMAL ব্যবহার করুন।






4. NUMERIC
SQL Server-এ NUMERIC এবং DECIMAL practically equivalent।
-- NUMERIC is equivalent to DECIMAL in SQL Server
DECLARE @Amount NUMERIC(12,2) = 1250.75;


SELECT @Amount AS Amount;

Best Practice
Financial → DECIMAL / NUMERIC
Count     → INT / BIGINT
Scientific measurement → FLOAT / REAL






5.FLOAT
Approximate numeric value।
-- FLOAT is useful for approximate scientific measurements
DECLARE @Probability FLOAT = 0.123456789;

SELECT @Probability AS Probability;

Use cases:
- Probability
- Scientific calculations
- Statistical measurements
- Sensor data
⚠️ Financial money calculation-এ FLOAT avoid করুন।






6. REAL
REAL হলো lower-precision approximate numeric type।
-- REAL stores approximate numeric values with lower precision
DECLARE @RiskScore REAL = 0.123456;

SELECT @RiskScore AS RiskScore;





7. Arithmetic Operators ➕➖✖️➗%
+
-- Add revenue and shipping cost
SELECT
    1799.98 + 15.00 AS TotalValue;


-
-- Calculate profit before shipping
SELECT
    1799.98 - 1300.00 AS Profit;



*
-- Calculate gross sales revenue
SELECT
    Quantity * UnitPrice AS Revenue
FROM analytics.Sales;



/
⚠️ SQL Server integer division-এর ব্যাপারে সতর্ক থাকতে হবে।
-- Demonstrate integer division
SELECT
    5 / 2 AS IntegerDivision;

Result:
2


  
Decimal result চাইলে:
-- Force decimal division for accurate percentage calculations
SELECT
    CAST(5 AS DECIMAL(10,2)) / 2 AS DecimalDivision;

Result:
2.500000


  
%
Remainder বের করতে।
-- Find remainder after dividing quantity by 2
SELECT
    Quantity % 2 AS Remainder
FROM analytics.Sales;


Real business use
-- Identify even and odd quantities
SELECT
    SalesID,
    Quantity,
    CASE
        WHEN Quantity % 2 = 0 THEN 'Even'
        ELSE 'Odd'
    END AS QuantityType
FROM analytics.Sales;





8. ABS() 
Negative value-এর absolute value।
-- Convert negative variance into absolute variance
SELECT
    ABS(-250.75) AS AbsoluteVariance;
Real business example
-- Calculate absolute difference between actual and target
SELECT
    ABS(ActualSales - TargetSales) AS AbsoluteVariance
FROM
(
    VALUES
    (4800.00, 5000.00),
    (6200.00, 6000.00)
) AS X(ActualSales, TargetSales);

Use:
- Variance magnitude
- Distance
- Error size
- Reconciliation difference





9. ROUND()
নির্দিষ্ট decimal position-এ round করে।
-- Round revenue to two decimal places
SELECT
    ROUND(899.9876, 2) AS RoundedValue;


Sales example
-- Calculate and round revenue
SELECT
    SalesID,
    ROUND(Quantity * UnitPrice, 2) AS Revenue
FROM analytics.Sales;


Negative precision
-- Round to nearest hundred
SELECT
    ROUND(12567.89, -2) AS RoundedHundred;


⚠️ ROUND ≠ formatting.
Financial calculation-এর জন্য ROUND প্রয়োজন হতে পারে, কিন্তু display formatting-এর জন্য নয়।







10. CEILING()
উপরের পূর্ণ integer-এ নেয়।
-- Round a value upward to the next integer
SELECT
    CEILING(12.01) AS CeilingValue;
Result:
13

  
Warehouse example
-- Determine required number of boxes when each box holds 10 units
SELECT
    CEILING(CAST(Quantity AS DECIMAL(10,2)) / 10) AS RequiredBoxes
FROM analytics.Sales;







11. FLOOR()
নিচের পূর্ণ integer-এ নেয়।
-- Round a value downward to the previous integer
SELECT
    FLOOR(12.99) AS FloorValue;


Warehouse example
-- Calculate complete boxes only
SELECT
    FLOOR(CAST(Quantity AS DECIMAL(10,2)) / 10) AS CompleteBoxes
FROM analytics.Sales;


CEILING vs FLOOR
Function	       12.7
ROUND	           13
CEILING	         13
FLOOR	           12







12. POWER()
Power/exponent calculation।
-- Calculate 2 raised to the power of 3
SELECT
    POWER(2, 3) AS Result;


Business example
-- Calculate compound growth factor
SELECT
    POWER(1.05, 3) AS ThreeYearGrowthFactor;






13. SQRT()
Square root।
-- Calculate square root of a value
SELECT
    SQRT(144) AS SquareRootValue;


Analytics example
-- Calculate Euclidean distance component
SELECT
    SQRT(25 + 144) AS Distance;






14. SIGN()
Value positive, negative অথবা zero কিনা।
-- Return the sign of a number
SELECT
    SIGN(-150) AS NegativeValue,
    SIGN(0) AS ZeroValue,
    SIGN(150) AS PositiveValue;



Data Quality 🔍
-- Classify transaction values by their sign
SELECT
    SourceID,
    SourceAmount,
    CASE
        WHEN TRY_CAST(SourceAmount AS DECIMAL(12,2)) IS NULL
            THEN 'Invalid'
        WHEN SIGN(TRY_CAST(SourceAmount AS DECIMAL(12,2))) = -1
            THEN 'Negative'
        WHEN SIGN(TRY_CAST(SourceAmount AS DECIMAL(12,2))) = 0
            THEN 'Zero'
        ELSE 'Positive'
    END AS DataQualityStatus
FROM analytics.ETL_Source_Sales;





15. RAND()
Random floating-point value between 0 and 1।
-- Generate a random number between 0 and 1
SELECT
    RAND() AS RandomNumber;


Generate random integer
-- Generate a random integer between 1 and 100
SELECT
    FLOOR(RAND() * 100) + 1 AS RandomNumber;


Important ⚠️
RAND() is generally not appropriate for generating production transaction IDs or business data.
  
Useful for:
- Testing
- Simulation
- Sample data
- Randomized experiments





16. PI()
π value।
-- Return the mathematical constant PI
SELECT
    PI() AS PiValue;


Circle calculation
-- Calculate the area of a circular warehouse zone
SELECT
    PI() * POWER(10, 2) AS CircleArea;






17. EXP()
e^x
-- Calculate exponential growth
SELECT
    EXP(1) AS EulerNumber;


Growth model
-- Calculate exponential growth factor
SELECT
    EXP(0.05) AS GrowthFactor;




18. LOG()
Natural logarithm by default।
-- Calculate natural logarithm
SELECT
    LOG(10) AS NaturalLog;

SQL Server-এ নির্দিষ্ট base দিতে পারেন:
  
-- Calculate logarithm of 100 using base 10
SELECT
    LOG(100, 10) AS LogBase10;


Analytics use
- Growth modelling
- Statistical transformation
- Distribution analysis
- Scientific data






19. LOG10()
Base-10 logarithm।
-- Calculate base-10 logarithm
SELECT
    LOG10(1000) AS LogValue;

Result:
3





20. SIN()
Sine function।
-- Calculate sine using radians
SELECT
    SIN(RADIANS(30)) AS Sine30Degrees;

Result ≈
0.5




21. COS()
-- Calculate cosine of 60 degrees
SELECT
    COS(RADIANS(60)) AS Cosine60Degrees;

Result ≈
0.5



22. TAN()
-- Calculate tangent of 45 degrees
SELECT
    TAN(RADIANS(45)) AS Tangent45Degrees;
Result ≈
1






23. ASIN()
Inverse sine।
-- Calculate inverse sine and return radians
SELECT
    ASIN(0.5) AS ArcSine;

Degrees-এ চাইলে:
-- Convert inverse sine result from radians to degrees
SELECT
    DEGREES(ASIN(0.5)) AS ArcSineDegrees;

Result:
30





24. ACOS()
Inverse cosine।
-- Calculate inverse cosine
SELECT
    DEGREES(ACOS(0.5)) AS ArcCosineDegrees;

Result:
60





25. ATAN()
Inverse tangent।
-- Calculate inverse tangent
SELECT
    DEGREES(ATAN(1)) AS ArcTangentDegrees;

Result:
45





26. ATN2()
দুই coordinate ব্যবহার করে angle বের করতে useful।
-- Calculate the angle between X and Y coordinates
SELECT
    DEGREES(ATN2(1, 1)) AS AngleDegrees;

Real-world use
- GPS
- Coordinates
- Robotics
- Spatial calculations
- Direction/orientation





27. COT()
Cotangent।
-- Calculate cotangent of 45 degrees
SELECT
    COT(RADIANS(45)) AS Cotangent45Degrees;




28. DEGREES()
Radians → Degrees।
-- Convert PI radians into degrees
SELECT
    DEGREES(PI()) AS DegreesValue;

Result:
180





29. RADIANS()
Degrees → Radians।
-- Convert 180 degrees into radians
SELECT
    RADIANS(180) AS RadiansValue;

Result ≈
3.1415926535





30. Trigonometric Function Chain 📐
সবগুলো একসাথে বুঝুন:
Degrees
   ↓
RADIANS()
   ↓
SIN / COS / TAN
   ↓
ASIN / ACOS / ATAN
   ↓
DEGREES()
  
Example:
-- Convert 30 degrees to radians and calculate sine
SELECT
    SIN(RADIANS(30)) AS SinValue;





31. NULLIF()
এটি Data Analyst/Data Engineer-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
NULLIF(a,b):
যদি a = b হয় → NULL
না হলে → a

-- Return NULL when the first value equals zero
SELECT
    NULLIF(0, 0) AS Result;

Result:
NULL





32. NULLIF() দিয়ে Divide-by-Zero Prevent
ধরুন:
Profit / Revenue
Revenue যদি 0 হয়?
সাধারণ calculation:
  
-- This can produce a divide-by-zero error
SELECT
    100 / 0;
❌ Error.
  
Safe version:
-- Prevent divide-by-zero by converting zero revenue into NULL
SELECT
    100.00 / NULLIF(0, 0) AS Margin;

Result:
NULL





33. Real Margin Calculation 💰
-- Calculate profit margin safely
SELECT
    SalesID,

    -- Revenue = Quantity × UnitPrice
    Quantity * UnitPrice AS Revenue,

    -- Profit = Revenue - Cost
    Quantity * P.UnitCost AS Profit,

    -- Margin = Profit / Revenue
    (
        (Quantity * UnitPrice) -
        (Quantity * P.UnitCost)
    )
    /
    NULLIF(Quantity * UnitPrice, 0) * 100
    AS MarginPercent

FROM analytics.Sales AS S
INNER JOIN analytics.Products AS P
    ON S.ProductID = P.ProductID;


এটি একটি real production-style pattern:
Profit
   ÷
NULLIF(Revenue, 0)
   × 100






34. CAST()
Data type পরিবর্তনের সবচেয়ে common function।
-- Convert an integer into decimal
SELECT
    CAST(100 AS DECIMAL(10,2)) AS DecimalValue;

Integer division fix
-- Convert values to decimal before calculating percentage
SELECT
    CAST(25 AS DECIMAL(10,2))
    /
    CAST(100 AS DECIMAL(10,2))
    * 100 AS PercentageValue;






35. CAST() — Sales Example
-- Calculate margin using explicit decimal conversion
SELECT
    SalesID,
    CAST(
        (
            (Quantity * UnitPrice) -
            (Quantity * P.UnitCost)
        )
        /
        NULLIF(Quantity * UnitPrice, 0)
        * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent
FROM analytics.Sales AS S
INNER JOIN analytics.Products AS P
    ON S.ProductID = P.ProductID;






36. CONVERT() 
CAST()-এর মতো conversion করে, কিন্তু SQL Server-specific style option দেয়।
-- Convert a date into VARCHAR using SQL Server style
SELECT
    CONVERT(VARCHAR(10), GETDATE(), 120) AS FormattedDate;

Style 120:
YYYY-MM-DD
  
Date conversion
-- Convert SalesDate into a standard text representation
SELECT
    SalesID,
    CONVERT(VARCHAR(10), SalesDate, 120) AS SalesDateText
FROM analytics.Sales;







37. CAST vs CONVERT
  
Feature	                CAST	                   CONVERT
ANSI SQL	              ✅	                     ❌ SQL Server-specific
Data type conversion	  ✅	                     ✅
Date style	            ❌	                     ✅
Portability	           ⭐⭐⭐⭐⭐	           ⭐⭐⭐
SQL Server work	       ⭐⭐⭐⭐⭐	           ⭐⭐⭐⭐⭐


Practical rule
General conversion → CAST()
SQL Server date formatting/style → CONVERT()






38. TRY_CAST()
Bad data হলে error না দিয়ে NULL দেয়।
এটি ETL Data Engineering-এর জন্য অত্যন্ত গুরুত্বপূর্ণ।
-- Safely convert text into integer
SELECT
    TRY_CAST('100' AS INT) AS ConvertedValue;


Invalid data:

  
-- Return NULL instead of throwing a conversion error
SELECT
    TRY_CAST('ABC' AS INT) AS ConvertedValue;

Result:
NULL






39. TRY_CAST() — ETL Data Quality
-- Safely convert raw source quantity into an integer
SELECT
    SourceID,
    Quantity,
    TRY_CAST(Quantity AS INT) AS QuantityConverted
FROM analytics.ETL_Source_Sales;

এখানে:
'2'       → 2
'10'      → 10
'INVALID' → NULL
'-5'      → -5
'0'       → 0





40. TRY_CONVERT()
TRY_CONVERT()-ও invalid conversion হলে NULL দেয়।
-- Safely convert source price into DECIMAL
SELECT
    SourceID,
    UnitPrice,
    TRY_CONVERT(DECIMAL(12,2), UnitPrice) AS UnitPriceConverted
FROM analytics.ETL_Source_Sales;





41. TRY_CAST vs TRY_CONVERT
Function	           Best use
TRY_CAST	           Generic safe conversion
TRY_CONVERT	         SQL Server conversion + style
CAST	               Standard conversion
CONVERT	             SQL Server-specific conversion






42. ETL Data Quality Project 🧹
এখন আমাদের raw source data থেকে bad records identify করি।
-- Identify invalid numeric values in the source system
SELECT
    SourceID,
    SalesID,
    Quantity,
    UnitPrice,
    SourceAmount,

    CASE
        WHEN TRY_CAST(Quantity AS INT) IS NULL
            THEN 'Invalid Quantity'

        WHEN TRY_CAST(UnitPrice AS DECIMAL(12,2)) IS NULL
            THEN 'Invalid UnitPrice'

        WHEN TRY_CAST(SourceAmount AS DECIMAL(14,2)) IS NULL
            THEN 'Invalid Amount'

        ELSE 'Valid'
    END AS DataQualityStatus

FROM analytics.ETL_Source_Sales;






43. Negative Values Detect 🔍
-- Detect negative quantities and negative amounts
SELECT
    SourceID,
    SalesID,
    Quantity,
    SourceAmount
FROM analytics.ETL_Source_Sales
WHERE
    TRY_CAST(Quantity AS INT) < 0
    OR
    TRY_CAST(SourceAmount AS DECIMAL(14,2)) < 0;






44. Zero Values Detect
-- Detect zero quantity or zero amount transactions
SELECT
    SourceID,
    SalesID,
    Quantity,
    SourceAmount
FROM analytics.ETL_Source_Sales
WHERE
    TRY_CAST(Quantity AS INT) = 0
    OR
    TRY_CAST(SourceAmount AS DECIMAL(14,2)) = 0;






45. Production-style ETL Validation 🏗️
-- Validate raw records before loading them into a warehouse
SELECT
    SourceID,
    SalesID,
    Quantity,
    UnitPrice,
    SourceAmount,

    CASE
        WHEN TRY_CONVERT(BIGINT, SalesID) IS NULL
            THEN 'INVALID_SALES_ID'

        WHEN TRY_CONVERT(INT, Quantity) IS NULL
            THEN 'INVALID_QUANTITY'

        WHEN TRY_CONVERT(INT, Quantity) <= 0
            THEN 'INVALID_QUANTITY_VALUE'

        WHEN TRY_CONVERT(DECIMAL(12,2), UnitPrice) IS NULL
            THEN 'INVALID_UNIT_PRICE'

        WHEN TRY_CONVERT(DECIMAL(12,2), UnitPrice) <= 0
            THEN 'INVALID_UNIT_PRICE_VALUE'

        WHEN TRY_CONVERT(DECIMAL(14,2), SourceAmount) IS NULL
            THEN 'INVALID_AMOUNT'

        WHEN TRY_CONVERT(DECIMAL(14,2), SourceAmount) < 0
            THEN 'NEGATIVE_AMOUNT'

        ELSE 'VALID'
    END AS ValidationStatus

FROM analytics.ETL_Source_Sales;

এটি বাস্তবে Bronze → Silver validation-এর মতো কাজ করে।






46. Clean Records Load Pattern 🔄
-- Select only valid records for the next ETL layer
SELECT
    TRY_CONVERT(BIGINT, SalesID) AS SalesID,
    TRY_CONVERT(INT, Quantity) AS Quantity,
    TRY_CONVERT(DECIMAL(12,2), UnitPrice) AS UnitPrice,
    TRY_CONVERT(DECIMAL(5,2), Discount) AS Discount,
    TRY_CONVERT(DECIMAL(14,2), SourceAmount) AS SourceAmount
FROM analytics.ETL_Source_Sales
WHERE
    TRY_CONVERT(BIGINT, SalesID) IS NOT NULL
    AND TRY_CONVERT(INT, Quantity) > 0
    AND TRY_CONVERT(DECIMAL(12,2), UnitPrice) > 0
    AND TRY_CONVERT(DECIMAL(14,2), SourceAmount) >= 0;






47. Revenue Calculation 💰
এটি সবচেয়ে গুরুত্বপূর্ণ real business calculation।
-- Calculate gross revenue for every transaction
SELECT
    SalesID,
    Quantity,
    UnitPrice,

    -- Revenue = Quantity × UnitPrice
    CAST(
        Quantity * UnitPrice
        AS DECIMAL(14,2)
    ) AS Revenue

FROM analytics.Sales;







48. Discount Calculation 📉
-- Calculate discount amount for each transaction
SELECT
    SalesID,

    -- Gross revenue
    Quantity * UnitPrice AS GrossRevenue,

    -- Discount amount
    ROUND(
        Quantity * UnitPrice * DiscountPercent / 100.0,
        2
    ) AS DiscountAmount

FROM analytics.Sales;





49. Net Revenue
-- Calculate net revenue after discount
SELECT
    SalesID,

    -- Gross revenue
    Quantity * UnitPrice AS GrossRevenue,

    -- Discount amount
    ROUND(
        Quantity * UnitPrice * DiscountPercent / 100.0,
        2
    ) AS DiscountAmount,

    -- Net revenue
    ROUND(
        Quantity * UnitPrice
        -
        (Quantity * UnitPrice * DiscountPercent / 100.0),
        2
    ) AS NetRevenue

FROM analytics.Sales;






50. Profit Calculation 📈
-- Calculate revenue, cost and profit
SELECT
    S.SalesID,

    -- Revenue
    S.Quantity * S.UnitPrice AS Revenue,

    -- Cost
    S.Quantity * P.UnitCost AS Cost,

    -- Profit
    (S.Quantity * S.UnitPrice)
    -
    (S.Quantity * P.UnitCost) AS Profit

FROM analytics.Sales AS S
INNER JOIN analytics.Products AS P
    ON S.ProductID = P.ProductID;





51. Complete Profitability Analysis 📊
-- Calculate gross revenue, discount, net revenue, cost, profit and margin
SELECT
    S.SalesID,

    -- Gross Revenue
    ROUND(
        S.Quantity * S.UnitPrice,
        2
    ) AS GrossRevenue,

    -- Discount
    ROUND(
        S.Quantity * S.UnitPrice
        * S.DiscountPercent / 100.0,
        2
    ) AS DiscountAmount,

    -- Net Revenue
    ROUND(
        S.Quantity * S.UnitPrice
        -
        S.Quantity * S.UnitPrice
        * S.DiscountPercent / 100.0,
        2
    ) AS NetRevenue,

    -- Cost
    ROUND(
        S.Quantity * P.UnitCost,
        2
    ) AS Cost,

    -- Profit
    ROUND(
        (
            S.Quantity * S.UnitPrice
            -
            S.Quantity * S.UnitPrice
            * S.DiscountPercent / 100.0
        )
        -
        S.Quantity * P.UnitCost,
        2
    ) AS Profit,

    -- Margin %
    CAST(
        (
            (
                S.Quantity * S.UnitPrice
                -
                S.Quantity * S.UnitPrice
                * S.DiscountPercent / 100.0
            )
            -
            S.Quantity * P.UnitCost
        )
        /
        NULLIF(
            S.Quantity * S.UnitPrice
            -
            S.Quantity * S.UnitPrice
            * S.DiscountPercent / 100.0,
            0
        )
        * 100
        AS DECIMAL(10,2)
    ) AS MarginPercent

FROM analytics.Sales AS S
INNER JOIN analytics.Products AS P
    ON S.ProductID = P.ProductID;








52. Target vs Actual 🎯
-- Compare monthly actual sales against business targets
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(SalesDate),
            MONTH(SalesDate),
            1
        ) AS SalesMonth,

        SUM(
            Quantity * UnitPrice
        ) AS ActualSales

    FROM analytics.Sales

    GROUP BY
        DATEFROMPARTS(
            YEAR(SalesDate),
            MONTH(SalesDate),
            1
        )
)

SELECT
    M.SalesMonth,
    M.ActualSales,
    T.SalesTarget,

    -- Variance = Actual - Target
    M.ActualSales - T.SalesTarget AS Variance,

    -- Absolute variance
    ABS(M.ActualSales - T.SalesTarget) AS AbsoluteVariance,

    -- Achievement %
    CAST(
        M.ActualSales
        /
        NULLIF(T.SalesTarget, 0)
        * 100
        AS DECIMAL(10,2)
    ) AS AchievementPercent

FROM MonthlySales AS M
INNER JOIN analytics.Targets AS T
    ON M.SalesMonth = T.TargetMonth;





53. Growth Calculation 📈
-- Calculate month-over-month sales growth
WITH MonthlySales AS
(
    SELECT
        DATEFROMPARTS(
            YEAR(SalesDate),
            MONTH(SalesDate),
            1
        ) AS SalesMonth,

        SUM(Quantity * UnitPrice) AS Sales

    FROM analytics.Sales

    GROUP BY
        DATEFROMPARTS(
            YEAR(SalesDate),
            MONTH(SalesDate),
            1
        )
),
SalesWithPrevious AS
(
    SELECT
        SalesMonth,
        Sales,

        -- Get previous month's sales
        LAG(Sales) OVER
        (
            ORDER BY SalesMonth
        ) AS PreviousSales

    FROM MonthlySales
)

SELECT
    SalesMonth,
    Sales,
    PreviousSales,

    -- Calculate MoM growth safely
    CAST(
        (Sales - PreviousSales)
        /
        NULLIF(PreviousSales, 0)
        * 100
        AS DECIMAL(10,2)
    ) AS MoMGrowthPercent

FROM SalesWithPrevious;






54. Source vs Calculated Amount Reconciliation 🏗️
এটি Data Engineering-এর খুব গুরুত্বপূর্ণ বাস্তব কাজ।
-- Compare source amount against independently calculated amount
SELECT
    S.SourceID,
    S.SalesID,

    TRY_CONVERT(INT, S.Quantity) AS SourceQuantity,

    TRY_CONVERT(
        DECIMAL(12,2),
        S.UnitPrice
    ) AS SourceUnitPrice,

    TRY_CONVERT(
        DECIMAL(14,2),
        S.SourceAmount
    ) AS SourceAmount,

    -- Recalculate amount independently
    TRY_CONVERT(INT, S.Quantity)
    *
    TRY_CONVERT(DECIMAL(12,2), S.UnitPrice)
    AS CalculatedAmount,

    -- Calculate reconciliation difference
    ABS(
        TRY_CONVERT(DECIMAL(14,2), S.SourceAmount)
        -
        (
            TRY_CONVERT(INT, S.Quantity)
            *
            TRY_CONVERT(DECIMAL(12,2), S.UnitPrice)
        )
    ) AS Difference

FROM analytics.ETL_Source_Sales AS S
WHERE
    TRY_CONVERT(INT, S.Quantity) IS NOT NULL
    AND TRY_CONVERT(DECIMAL(12,2), S.UnitPrice) IS NOT NULL
    AND TRY_CONVERT(DECIMAL(14,2), S.SourceAmount) IS NOT NULL;





55. Reconciliation Status ✅❌
-- Classify source records as matched or mismatched
SELECT
    SourceID,
    SalesID,

    TRY_CONVERT(DECIMAL(14,2), SourceAmount) AS SourceAmount,

    TRY_CONVERT(INT, Quantity)
    *
    TRY_CONVERT(DECIMAL(12,2), UnitPrice)
    AS CalculatedAmount,

    CASE
        WHEN ABS(
            TRY_CONVERT(DECIMAL(14,2), SourceAmount)
            -
            (
                TRY_CONVERT(INT, Quantity)
                *
                TRY_CONVERT(DECIMAL(12,2), UnitPrice)
            )
        ) <= 0.01
        THEN 'MATCHED'

        ELSE 'MISMATCHED'
    END AS ReconciliationStatus

FROM analytics.ETL_Source_Sales;

0.01 tolerance রাখা হয়েছে floating/rounding difference-এর জন্য।






56. Data Quality Dashboard Query 📊
একটি production-style summary:
-- Summarize source data quality issues
SELECT
    COUNT(*) AS TotalRecords,

    SUM(
        CASE
            WHEN TRY_CONVERT(BIGINT, SalesID) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidSalesID,

    SUM(
        CASE
            WHEN TRY_CONVERT(INT, Quantity) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidQuantity,

    SUM(
        CASE
            WHEN TRY_CONVERT(INT, Quantity) <= 0
            THEN 1 ELSE 0
        END
    ) AS InvalidQuantityValue,

    SUM(
        CASE
            WHEN TRY_CONVERT(DECIMAL(12,2), UnitPrice) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidUnitPrice,

    SUM(
        CASE
            WHEN TRY_CONVERT(DECIMAL(14,2), SourceAmount) IS NULL
            THEN 1 ELSE 0
        END
    ) AS InvalidAmount

FROM analytics.ETL_Source_Sales;







57. সব Functions — Quick Reference
  
Function	          মূল কাজ	                      Real Business Use
ABS()	              absolute value	                Variance
ROUND()	            rounding	                      Money
CEILING()	          round up	                      Boxes/capacity
FLOOR()	            round down	                    Complete units
POWER()	            exponent	                      Growth
SQRT()	            square root	                    Distance/statistics
SIGN()	            sign detect	                    Data quality
RAND()	            random value	                  Testing
PI()	              π	                              Geometry
EXP()	              exponential	                    Growth models
LOG()	              logarithm	                      Analytics
LOG10()	            base-10 log	                    Scale analysis
SIN()	              sine	                          Trigonometry
COS()	              cosine	                        Trigonometry
TAN()	              tangent	                        Angle
ASIN()	            inverse sine	                  Angle
ACOS()	            inverse cosine	                Angle
ATAN()	            inverse tangent	                Angle
ATN2()	            coordinate angle	              Direction
COT()	              cotangent	                      Trigonometry
DEGREES()	          radians → degrees	              Angle
RADIANS()	          degrees → radians	              Trigonometry
NULLIF()	          value → NULL	                  Divide-by-zero
CAST()	            type conversion	                ETL
CONVERT()	          SQL Server conversion	          Date/style
TRY_CAST()	        safe conversion	                Bad source data
TRY_CONVERT()	      safe conversion	                ETL






58. Numeric Data Types — Quick Reference
  
Type	             Category	             Recommended Use
INT	               Exact integer	       Quantity, ID
BIGINT	           Large integer	       Huge transaction ID
DECIMAL	           Exact numeric	      💰 Money
NUMERIC	           Exact numeric	      💰 Money
FLOAT	             Approximate	         Scientific/statistical
REAL	             Approximate	         Lower-precision measurements


সবচেয়ে গুরুত্বপূর্ণ rule
Money
  ↓
DECIMAL(p,s)

Quantity
  ↓
INT

Huge ID / transaction count
  ↓
BIGINT

Scientific approximation
  ↓
FLOAT / REAL






59. Production Best Practices ⭐
  
💰 Financial Data
- DECIMAL/NUMERIC ব্যবহার করুন।
- Money-এর জন্য FLOAT ব্যবহার করবেন না।
- Precision/scale আগে থেকেই design করুন।

  
🧮 Calculation
- Percentage calculation-এ integer division avoid করুন।
- প্রয়োজনে CAST() করুন।
- Divide করার আগে NULLIF() ব্যবহার করুন।

  
🔄 ETL
- Raw source-এ numeric data VARCHAR হলে blindly CAST() করবেন না।
- TRY_CAST() / TRY_CONVERT() ব্যবহার করুন।
- Invalid data আলাদা করুন।
- Source এবং calculated amount reconcile করুন।

  
🧹 Data Quality
- Negative quantity detect করুন।
- Zero quantity detect করুন।
- Invalid numeric values detect করুন।
- NULL বনাম 0 business meaning আলাদা রাখুন।

  
🏗️ Warehouse
Source
  ↓
Bronze
  ↓
TRY_CONVERT()
  ↓
Data Quality Validation
  ↓
Silver
  ↓
Business Calculations
  ↓
Gold
  ↓
Power BI







60. Common Mistakes ❌
❌ Mistake 1 — Money-তে FLOAT
-- Avoid approximate FLOAT for financial values
DECLARE @Price FLOAT = 899.99;


✅ Prefer:
-- Use exact DECIMAL for financial values
DECLARE @Price DECIMAL(12,2) = 899.99;


❌ Mistake 2 — Divide by Zero
-- Unsafe division
SELECT Profit / Revenue;


✅ Use:
-- Safe division
SELECT Profit / NULLIF(Revenue, 0);
❌ Mistake 3 — ETL-এ CAST()
-- Invalid source data can cause the ETL to fail
SELECT CAST('INVALID' AS INT);


✅ Use:
-- Safely handle invalid source values
SELECT TRY_CAST('INVALID' AS INT);


❌ Mistake 4 — Integer Division
-- Integer division loses the decimal portion
SELECT 25 / 100;

Result:
0


✅ Use:
-- Convert to decimal before division
SELECT
    CAST(25 AS DECIMAL(10,2)) / 100;


❌ Mistake 5 — ROUND দিয়ে Formatting
ROUND() calculation-এর জন্য।
Date/string presentation-এর জন্য ROUND() ব্যবহার করা উচিত নয়।







61. Final Real-World Mini Project 🚀
এখন এই database দিয়ে আপনি একটি সম্পূর্ণ Retail Sales Analytics + ETL Data Quality Project practice করতে পারবেন।
                  RAW SOURCE
                      │
                      ▼
          ETL_Source_Sales
                      │
             TRY_CAST / TRY_CONVERT
                      │
                      ▼
               DATA QUALITY
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Invalid     Negative      Zero
          │           │           │
          └───────────┼───────────┘
                      ▼
                  CLEAN DATA
                      │
                      ▼
                SALES ANALYSIS
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Revenue      Profit      Margin
          │           │           │
          └───────────┼───────────┘
                      ▼
              TARGET ANALYSIS
                      │
          ┌───────────┼───────────┐
          ▼           ▼           ▼
       Variance     Growth    Achievement
                      │
                      ▼
                RECONCILIATION
                      │
                      ▼
              SOURCE vs TARGET
                      │
                      ▼
                  GOLD LAYER
                      │
                      ▼
                 POWER BI




🎯 আপনার Master Practice Checklist
- ✅ ABS() → Actual vs Target variance
- ✅ ROUND() → Revenue/Profit rounding
- ✅ CEILING() → Warehouse box calculation
- ✅ FLOOR() → Complete box calculation
- ✅ POWER() → Growth model
- ✅ SQRT() → Distance/statistical calculation
- ✅ SIGN() → Negative/zero/positive validation
- ✅ RAND() → Test data generation
- ✅ PI() → Geometry calculation
- ✅ EXP() → Exponential growth
- ✅ LOG() / LOG10() → Analytical transformations
- ✅ SIN/COS/TAN → Angle calculations
- ✅ ASIN/ACOS/ATAN/ATN2 → Reverse angle calculations
- ✅ COT() → Trigonometry
- ✅ DEGREES/RADIANS → Angle conversion
- ✅ INT/BIGINT → IDs and quantities
- ✅ DECIMAL/NUMERIC → Financial data
- ✅ FLOAT/REAL → Approximate scientific data
- ✅ + - * / % → Business calculations
- ✅ NULLIF() → Safe division
- ✅ CAST() → Standard conversion
- ✅ CONVERT() → SQL Server conversion/style
- ✅ TRY_CAST() → Safe ETL conversion
- ✅ TRY_CONVERT() → Safe ETL conversion
- ✅ Revenue
- ✅ Cost
- ✅ Profit
- ✅ Margin
- ✅ Growth
- ✅ Variance
- ✅ Data Quality
- ✅ ETL validation
- ✅ Source-to-target reconciliation

