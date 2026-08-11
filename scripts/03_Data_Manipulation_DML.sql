💡 DML মূলত table-এর data পরিবর্তন করে। Table structure পরিবর্তন করে না।

DML Flow
INSERT
  ↓
নতুন Data যোগ

UPDATE
  ↓
Existing Data পরিবর্তন

DELETE
  ↓
Data মুছে ফেলা

SELECT
  ↓
পরিবর্তন Verify




আগের ৭টি table-ই ব্যবহার করছি:
Customers
   ↓
Orders
   ↓
OrderItems
   ↓
Products
   ↓
Categories
   ↓
Employees
   ↓
Departments
এখানে নতুন table তৈরি করার প্রয়োজন নেই। নিচের উদাহরণগুলোতে মূলত Customers table ব্যবহার করছি,
কারণ আপনার দেওয়া schema অনুযায়ী এর columns নিশ্চিতভাবে জানা আছে।



/*
===============================================================================
SQL SERVER DATA MANIPULATION LANGUAGE (DML)
===============================================================================

DML = Database-এর existing data নিয়ে কাজ করার language.

মূল DML Commands:

INSERT   → নতুন data যোগ করা
UPDATE   → existing data পরিবর্তন করা
DELETE   → নির্দিষ্ট data মুছে ফেলা

Important:
DML সাধারণত table-এর structure পরিবর্তন করে না।
এটি table-এর ভিতরের data পরিবর্তন করে।

Existing Tables:
Customers
Orders
OrderItems
Products
Categories
Employees
Departments

===============================================================================
*/






1. INSERT
INSERT ব্যবহার করা হয় নতুন row/table data যোগ করার জন্য।
বাস্তব business scenario:
নতুন customer আমাদের কোম্পানিতে registration করেছে।

INSERT ... VALUES
সবচেয়ে common এবং সহজ method।
-- নতুন customer যোগ করা

INSERT INTO Customers
(
    CustomerID,
    CustomerName,
    Country,
    BirthDate,
    Phone
)
VALUES
(
    101,
    'Rahim Ahmed',
    'Bangladesh',
    '1995-05-15',
    '+8801712345678'
);
কী হচ্ছে?
CustomerID  → 101
CustomerName → Rahim Ahmed
Country      → Bangladesh
BirthDate    → 1995-05-15
Phone        → +8801712345678




