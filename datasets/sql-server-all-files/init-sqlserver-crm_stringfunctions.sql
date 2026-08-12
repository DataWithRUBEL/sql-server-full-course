/* =============================================================================
   STEP 01: CREATE DATABASE
   ============================================================================ */

CREATE DATABASE CRM_StringFunctions;
GO

USE CRM_StringFunctions;
GO


/* =============================================================================
   STEP 02: CREATE CUSTOMER TABLE
   Real CRM Customer Data
   ============================================================================ */

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    Phone VARCHAR(30),
    Email VARCHAR(100),
    Address VARCHAR(200),
    Skills VARCHAR(200),
    CustomerCode VARCHAR(30),
    JoinDate DATE
);
GO


/* =============================================================================
   STEP 03: INSERT REALISTIC BUSINESS DATA

   Intentionally রাখা হয়েছে:
   - Leading spaces
   - Trailing spaces
   - Mixed Case
   - Phone numbers with -
   - Email data
   - Multiple skills
   - NULL values
   - Customer codes
   ============================================================================ */

INSERT INTO Customers
(
    CustomerID,
    FirstName,
    LastName,
    Country,
    City,
    Phone,
    Email,
    Address,
    Skills,
    CustomerCode,
    JoinDate
)
VALUES
(1, '  John', 'Smith  ', 'USA', 'New York',
 '123-456-7890', 'JOHN.SMITH@EMAIL.COM',
 '25 Main Street', 'SQL,Power BI,Excel',
 'CUS-1001', '2025-01-15'),

(2, 'Sarah ', 'Johnson', 'UK', 'London',
 '020-555-7890', 'Sarah.Johnson@Email.com',
 '18 Oxford Road', 'Excel,Power BI',
 'CUS-1002', '2025-02-20'),

(3, ' Michael', 'Brown ', 'Canada', 'Toronto',
 '416-555-1234', 'MICHAEL.BROWN@EMAIL.COM',
 '72 King Street', 'SQL,Python,PySpark',
 'CUS-1003', '2025-03-10'),

(4, 'Emma', 'Wilson', 'Australia', 'Sydney',
 '02-555-9876', 'emma.wilson@email.com',
 '44 George Street', 'Power BI,SQL',
 'CUS-1004', '2025-04-05'),

(5, 'David ', 'Miller', 'Germany', 'Berlin',
 '030-555-4567', NULL,
 '10 Berlin Street', 'SQL,Excel,Python',
 'CUS-1005', '2025-05-12'),

(6, ' Olivia', 'Taylor ', 'France', 'Paris',
 '01-555-8888', 'OLIVIA.TAYLOR@EMAIL.COM',
 '90 Paris Avenue', 'Excel,Power BI,SQL',
 'CUS-1006', '2025-06-18'),

(7, 'James', 'Anderson', 'USA', 'Chicago',
 '312-555-9999', 'james.anderson@email.com',
 '55 Lake Drive', 'Python,SQL',
 'CUS-1007', '2025-07-22'),

(8, 'Sophia ', 'Thomas', 'India', 'Mumbai',
 '022-555-7777', 'sophia.thomas@email.com',
 '12 Marine Road', 'SQL,PySpark,Databricks',
 'CUS-1008', '2025-08-11'),

(9, ' Daniel', 'Jackson ', 'Kuwait', 'Kuwait City',
 '555-123-456', 'DANIEL.JACKSON@EMAIL.COM',
 'Block 5 Street 10', 'SQL,Power BI,Azure',
 'CUS-1009', '2025-09-25'),

(10, '  Lisa  ', 'White', 'USA', 'Boston',
 '617-555-3333', '',
 '80 Boston Road', 'Excel,SQL',
 'CUS-1010', '2025-10-30');
GO
