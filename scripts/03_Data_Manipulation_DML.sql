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




Manual INSERT using VALUES
নতুন Customer যোগ করা
-- নতুন customer যোগ করছি
INSERT INTO Customers
    (id, first_name, country, score)
VALUES
    (6, 'Alo', 'USA', NULL);

-- আরেকজন customer যোগ করছি
INSERT INTO Customers
    (id, first_name, country, score)
VALUES
    (7, 'Sami', NULL, 100);


কী হচ্ছে?
INSERT INTO
      ↓
Table নির্বাচন
      ↓
Column নির্বাচন
      ↓
VALUES
      ↓
নতুন Row যোগ

















