-- Arithmetic Operators
SQL Server-এ basic mathematical calculation-এর foundation হলো:
+, -, *, /, %


  

+ Addition
/* ============================================================
   + ADDITION
   Business Example:
   Product Price + Discount
   ============================================================ */

SELECT
    SaleID,
    UnitPrice,
    DiscountAmount,
    UnitPrice + DiscountAmount AS PricePlusDiscount
FROM Sales;







- Subtraction
/* ============================================================
   - SUBTRACTION
   Business Example:
   Sales Amount - Target Amount
   ============================================================ */

SELECT
    SaleID,
    Quantity * UnitPrice AS SalesAmount,
    TargetAmount,
    (Quantity * UnitPrice) - TargetAmount AS Variance
FROM Sales;







* Multiplication
/* ============================================================
   * MULTIPLICATION
   Business Example:
   Quantity × Unit Price = Sales Amount
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    UnitPrice,
    Quantity * UnitPrice AS SalesAmount
FROM Sales;






/ Division
/* ============================================================
   / DIVISION
   Business Example:
   Sales Amount / Quantity = Average Unit Revenue
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    Quantity * UnitPrice AS SalesAmount,
    (Quantity * UnitPrice) / Quantity AS AverageUnitRevenue
FROM Sales
WHERE Quantity <> 0;






-- % Modulo
% division-এর remainder বের করে।
Real Business Example
কোন sales quantity even না odd তা বের করা যায়।
/* ============================================================
   % MODULO
   Business Example:
   Quantity-এর remainder বের করা
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    Quantity % 2 AS Remainder
FROM Sales;
যেমন:
10 % 2 = 0
7  % 2 = 1
15 % 2 = 1







-- ROUND()
Decimal value নির্দিষ্ট decimal places পর্যন্ত round করতে ব্যবহার করা হয়।
/* ============================================================
   ROUND()
   Business Example:
   Sales Amount-কে 2 decimal পর্যন্ত round করা
   ============================================================ */

SELECT
    SaleID,
    Quantity * UnitPrice AS OriginalSalesAmount,
    ROUND(Quantity * UnitPrice, 2) AS RoundedSalesAmount
FROM Sales;
Basic Example
SELECT
    3.516 AS OriginalNumber,
    ROUND(3.516, 2) AS Round_2,
    ROUND(3.516, 1) AS Round_1,
    ROUND(3.516, 0) AS Round_0;







-- ABS()
Negative value-কে positive magnitude-এ convert করে।
Real Business Example
Target থেকে actual sales কতটা difference হয়েছে তা দেখতে:
/* ============================================================
   ABS()
   Business Example:
   Target variance-এর absolute value
   ============================================================ */

SELECT
    SaleID,
    Quantity * UnitPrice AS SalesAmount,
    TargetAmount,

    (Quantity * UnitPrice) - TargetAmount AS Variance,

    ABS(
        (Quantity * UnitPrice) - TargetAmount
    ) AS AbsoluteVariance

FROM Sales;








-- CEILING()
Value-কে উপরের পূর্ণসংখ্যায় নিয়ে যায়।
/* ============================================================
   CEILING()
   Business Example:
   Price-এর next whole number
   ============================================================ */

SELECT
    ProductID,
    UnitPrice,
    CEILING(UnitPrice) AS CeilingPrice
FROM Sales;
Example:
10.20 → 11
10.01 → 11
10.00 → 10






-- FLOOR()
Value-কে নিচের পূর্ণসংখ্যায় নিয়ে যায়।
/* ============================================================
   FLOOR()
   Business Example:
   Price-এর lower whole number
   ============================================================ */

SELECT
    ProductID,
    UnitPrice,
    FLOOR(UnitPrice) AS FloorPrice
FROM Sales;







-- POWER()
একটি number-এর power বের করে।
Real Business Example
Compound growth বা mathematical calculation:
/* ============================================================
   POWER()
   Business Example:
   10% growth 3 years পরে multiplier
   ============================================================ */

SELECT
    POWER(1.10, 3) AS GrowthMultiplier;
আর Sales dataset-এ:
/* ============================================================
   POWER()
   Quantity-এর square
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    POWER(Quantity, 2) AS QuantitySquared
FROM Sales;









-- SQRT()
Square root বের করে।
/* ============================================================
   SQRT()
   Business Example:
   Quantity-এর square root
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    SQRT(Quantity) AS QuantitySquareRoot
FROM Sales;







-- SIGN()
Number positive, negative অথবা zero কিনা তা identify করে।
/* ============================================================
   SIGN()
   Business Example:
   Sales variance positive/negative/zero কিনা
   ============================================================ */

SELECT
    SaleID,

    (Quantity * UnitPrice) - TargetAmount AS Variance,

    SIGN(
        (Quantity * UnitPrice) - TargetAmount
    ) AS VarianceSign

FROM Sales;
Result-এর অর্থ:
 1  = Positive
 0  = Zero
-1  = Negative







-- RAND()
Random decimal value generate করে।
/* ============================================================
   RAND()
   Business Example:
   Random test value তৈরি
   ============================================================ */

SELECT
    RAND() AS RandomNumber;
একাধিক row-এর জন্য:
/* ============================================================
   RAND()
   Test / Simulation
   ============================================================ */

SELECT
    SaleID,
    RAND(CHECKSUM(NEWID())) AS RandomValue
FROM Sales;
Production business logic-এ random value ব্যবহার করার আগে deterministic requirement বিবেচনা করতে হবে।







-- PI()
π-এর value return করে।
/* ============================================================
   PI()
   ============================================================ */

SELECT
    PI() AS PiValue;
Real calculation:
/* ============================================================
   PI()
   Business Example:
   Circle Area = π × radius²
   ============================================================ */

SELECT
    PI() * POWER(10, 2) AS CircleArea;








-- EXP()
e raised to a power।
/* ============================================================
   EXP()
   ============================================================ */

SELECT
    EXP(1) AS E_Value,
    EXP(2) AS E_Power_2;







-- LOG()
Natural logarithm বের করে।
/* ============================================================
   LOG()
   ============================================================ */

SELECT
    LOG(10) AS NaturalLog;







-- COS()
Cosine calculation করে।
SQL Server-এর trigonometric functions radian ব্যবহার করে।
/* ============================================================
   COS()
   Business Example:
   Latitude-এর cosine
   Degrees → Radians:
   Latitude × PI() / 180
   ============================================================ */

SELECT
    StoreID,
    StoreName,
    Latitude,

    COS(
        Latitude * PI() / 180
    ) AS LatitudeCosine

FROM StoreLocations;







-- TAN()
Tangent calculation।
/* ============================================================
   TAN()
   Latitude থেকে tangent calculation
   ============================================================ */

SELECT
    StoreID,
    StoreName,
    Latitude,

    TAN(
        Latitude * PI() / 180
    ) AS LatitudeTangent

FROM StoreLocations;








-- ASIN()
Inverse sine calculation করে।
/* ============================================================
   ASIN()
   ============================================================ */

SELECT
    ASIN(0.5) AS ArcSine;










-- ACOS()
Inverse cosine calculation করে।
/* ============================================================
   ACOS()
   ============================================================ */

SELECT
    ACOS(0.5) AS ArcCosine;





-- ATAN()
Inverse tangent calculation করে।
/* ============================================================
   ATAN()
   ============================================================ */

SELECT
    ATAN(1) AS ArcTangent;








-- NULLIF() দিয়ে Division-by-Zero Handling
এটি খুব গুরুত্বপূর্ণ SQL Server best practice।
আমাদের Sales table-এ SaleID = 10-এর Quantity = 0।
সরাসরি:
/* ============================================================
   WRONG:
   Quantity = 0 হলে division-by-zero error হতে পারে
   ============================================================ */

SELECT
    SaleID,
    (Quantity * UnitPrice) / Quantity AS RevenuePerUnit
FROM Sales;


এখানে Quantity = 0 হলে error হবে।
Correct Approach
/* ============================================================
   NULLIF()
   Division-by-zero handling
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    Quantity * UnitPrice AS SalesAmount,

    (Quantity * UnitPrice)
        / NULLIF(Quantity, 0) AS RevenuePerUnit

FROM Sales;
এখন:
Quantity = 0
        ↓
NULLIF(Quantity, 0)
        ↓
NULL
        ↓
Division safely returns NULL








-- CAST() দিয়ে Numeric Conversion
Data Engineering-এ source data থেকে আসা numeric value-এর datatype control করা খুব গুরুত্বপূর্ণ।
/* ============================================================
   CAST()
   Numeric conversion
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    UnitPrice,

    CAST(
        Quantity * UnitPrice
        AS DECIMAL(12,2)
    ) AS SalesAmount

FROM Sales;







-- DECIMAL Precision Control
SQL Server-এ DECIMAL(p,s):
p = Total digits
s = Decimal digits
Example:
/* ============================================================
   DECIMAL(12,2)
   মোট 12 digit
   এর মধ্যে 2 digit decimal
   ============================================================ */

SELECT
    CAST(123456.789 AS DECIMAL(12,2))
        AS ConvertedValue;
Result:
123456.79








-- সব গুরুত্বপূর্ণ Number Functions একসাথে
/* ============================================================
   SQL NUMBER FUNCTIONS
   Real Sales Analysis
   ============================================================ */

SELECT
    SaleID,
    Quantity,
    UnitPrice,

    /* Arithmetic */
    Quantity * UnitPrice AS SalesAmount,

    /* ROUND */
    ROUND(
        Quantity * UnitPrice,
        2
    ) AS RoundedSalesAmount,

    /* ABS */
    ABS(
        (Quantity * UnitPrice) - TargetAmount
    ) AS AbsoluteVariance,

    /* CEILING */
    CEILING(UnitPrice) AS CeilingPrice,

    /* FLOOR */
    FLOOR(UnitPrice) AS FloorPrice,

    /* POWER */
    POWER(Quantity, 2) AS QuantitySquared,

    /* SQRT */
    SQRT(Quantity) AS QuantitySquareRoot,

    /* SIGN */
    SIGN(
        (Quantity * UnitPrice) - TargetAmount
    ) AS VarianceSign,

    /* MODULO */
    Quantity % 2 AS QuantityRemainder,

    /* Division by zero handling */
    (Quantity * UnitPrice)
        / NULLIF(Quantity, 0) AS RevenuePerUnit,

    /* Numeric conversion */
    CAST(
        Quantity * UnitPrice
        AS DECIMAL(12,2)
    ) AS DecimalSalesAmount

FROM Sales;






-- Data Analyst + Data Engineer Real Query
শেষে একটি বাস্তব analytical calculation:
/* ============================================================
   REAL BUSINESS ANALYSIS
   Product-wise Sales Calculation
   ============================================================ */

SELECT
    P.ProductID,
    P.ProductName,
    P.Category,

    S.Quantity,
    S.UnitPrice,

    /* Total Revenue */
    S.Quantity * S.UnitPrice AS SalesAmount,

    /* Discount */
    S.DiscountAmount,

    /* Net Revenue */
    (S.Quantity * S.UnitPrice)
        - S.DiscountAmount AS NetSalesAmount,

    /* Target Variance */
    (
        (S.Quantity * S.UnitPrice)
        - S.DiscountAmount
    ) - S.TargetAmount AS TargetVariance,

    /* Absolute Variance */
    ABS(
        (
            (S.Quantity * S.UnitPrice)
            - S.DiscountAmount
        ) - S.TargetAmount
    ) AS AbsoluteTargetVariance,

    /* Rounded Revenue */
    ROUND(
        (
            (S.Quantity * S.UnitPrice)
            - S.DiscountAmount
        ),
        2
    ) AS RoundedNetSales,

    /* Decimal Conversion */
    CAST(
        (
            (S.Quantity * S.UnitPrice)
            - S.DiscountAmount
        )
        AS DECIMAL(12,2)
    ) AS DecimalNetSales

FROM Sales AS S

INNER JOIN Products AS P
    ON S.ProductID = P.ProductID;
