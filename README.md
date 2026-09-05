# 🛢️ Complete SQL Server Masterclass: Zero to Data Engineer

Welcome to the ultimate **SQL Server Full Course** repository! This project provides a production-grade, end-to-end curriculum designed to take you from foundational querying to complex enterprise Data Engineering and ETL architecture.

---

## 📂 Repository Structure

The repository is divided into 35 modules, each containing hands-on datasets and corresponding executable SQL scripts.

```text
sql-server-full-course/
├── datasets/
│   └── sql-server-all-files/
│       ├── 01_SELECT_Dataset.sql
│       ├── ...
│       └── 35_ETL_Dataset.sql
├── scripts/
│   ├── 01_SELECT.sql
│   ├── ...
│   └── 35_ETL.sql
├── LICENSE
└── README.md


🗺️ Course Curriculum & Modules
🟢 Phase 1 — SQL Fundamentals
🔹 Module 01: SELECT Statement & Basics

🔹 Module 02: Data Definition Language (DDL) — CREATE, ALTER, DROP

🔹 Module 03: Data Manipulation Language (DML) — INSERT, UPDATE, DELETE

🔹 Module 04: Filtering Data — WHERE, LIKE, IN, BETWEEN

🔹 Module 05: SQL Joins — INNER, LEFT, RIGHT, FULL, CROSS

🔹 Module 06: SET Operators — UNION, UNION ALL, INTERSECT, EXCEPT

🟡 Phase 2 — SQL Functions & Business Logic
🔹 Module 07: String Functions (LEN, SUBSTRING, REPLACE, CONCAT)

🔹 Module 08: Number & Mathematical Functions

🔹 Module 09: Date & Time Functions (GETDATE, DATEDIFF, DATEADD)

🔹 Module 10: Date & Time Formats (FORMAT, CONVERT, CAST)

🔹 Module 11: Handling NULL Values (ISNULL, COALESCE, NULLIF)

🔹 Module 12: Conditional Logic with CASE Statements

🔹 Module 13: Aggregate Functions & Grouping (GROUP BY, HAVING)

🔵 Phase 3 — Advanced Querying
🔹 Module 14: Introduction to Window Functions (OVER Clause)

🔹 Module 15: Window Aggregate Functions (SUM, AVG, COUNT over partitions)

🔹 Module 16: Window Ranking Functions (ROW_NUMBER, RANK, DENSE_RANK, NTILE)

🔹 Module 17: Window Value Functions (LAG, LEAD, FIRST_VALUE, LAST_VALUE)

🔹 Module 18: Subqueries & Correlated Subqueries

🔹 Module 19: Common Table Expressions (CTE) & Recursive CTEs

🟣 Phase 4 — SQL Objects & Programming
🔹 Module 20: Views & Indexed Views

🔹 Module 21: Temporary Tables (#temp, ##global) vs Table Variables

🔹 Module 22: Stored Procedures (Parameters, Output Parameters)

🔹 Module 23: User-Defined Functions (Scalar, Inline Table-Valued, Multi-Statement)

🔹 Module 24: Transactions Management (BEGIN, COMMIT, ROLLBACK, Isolation Levels)

🔹 Module 25: Error Handling (TRY...CATCH, RAISERROR, THROW)

🔹 Module 26: Database Triggers (AFTER, INSTEAD OF)

🔴 Phase 5 — Performance & Database Optimization
🔹 Module 27: Indexing Strategies (Clustered, Non-Clustered, Filtered, Included Columns)

🔹 Module 28: Table Partitioning & Partition Switches

🔹 Module 29: Query Performance Optimization Techniques

🔹 Module 30: Execution Plans Analysis & Index Tuning

🟠 Phase 6 — Advanced SQL
🔹 Module 31: Data Transformation — PIVOT & UNPIVOT

🔹 Module 32: Dynamic SQL & SQL Injection Prevention

🔹 Module 33: JSON Processing in SQL Server (OPENJSON, FOR JSON)

🟤 Phase 7 — Data Engineering & ETL Architecture
🔹 Module 34: Data Warehouse Architecture & Design
🔸 Architecture: OLTP vs OLAP, Data Warehouse Design, Staging Layer, Medallion Architecture (Bronze / Silver / Gold)

🔸 Dimensional Modeling: Star Schema, Fact Tables, Dimension Tables, Relationships, Grain & Measures

🔸 Keys & Schema: Surrogate Keys vs Natural Keys, Date Dimension, Conformed Dimensions

🔸 Advanced Warehouse Patterns: Slowly Changing Dimensions (SCD Type 1, SCD Type 2), Historical vs Incremental Data Tracking

🔸 Enterprise Scaling: Data Quality & Validation Rules, Large-Table Optimization, Columnstore Index Concepts

🔹 Module 35: Enterprise ETL Engine & Automation
🔸 Pipeline Flow: Extract, Staging, Transform, Load Patterns

🔸 Loading Mechanics: Full Load vs Incremental Load (Upsert / Merge), Deduplication & Data Cleansing

🔸 Enterprise Audit & Control: ETL Logging, Audit Columns, Metadata Management, Reject/Error Handling

🔸 Resilience & Safety: Transaction Control, Retry Logic, Source-to-Target Mapping (STTM), Dependency Management

🔸 Scheduling & Monitoring: SQL Server Agent, Job Scheduling, Monitoring, Troubleshooting, and Performance Tuning

⚡ Getting Started
Clone the repository:

Bash
git clone https://github.com/DataWithRUBEL/sql-server-full-course.git
Setup Database:
Execute the dataset script located inside datasets/sql-server-all-files/ for the specific module.

Run Exercises:
Execute the corresponding module script inside the scripts/ folder on SQL Server Management Studio (SSMS) or Azure Data Studio.

📜 License
This project is licensed under the MIT License — feel free to use it for personal learning and teaching purposes.
