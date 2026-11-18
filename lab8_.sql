-- Part 2
CREATE INDEX emp_salary_idx ON employees(salary);
SELECT indexname, indexdef FROM pg_indexes WHERE tablename = 'employees';

CREATE INDEX emp_dept_idx ON employees(dept_id);
SELECT * FROM employees WHERE dept_id = 101;

SELECT tablename, indexname, indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

-- Part 3
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary FROM employees WHERE dept_id = 101 AND salary > 52000;

CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;

-- Part 4
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;
CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- this should fail with a unique violation
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Part 5
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary FROM employees ORDER BY salary DESC;

CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget FROM projects ORDER BY budget NULLS FIRST;

-- Part 6
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));
SELECT emp_name, hire_date FROM employees WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- Part 7
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
DROP INDEX emp_salary_dept_idx;
REINDEX INDEX employees_salary_index;

-- Part 8
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

CREATE INDEX proj_high_budget_idx ON projects(budget) WHERE budget > 80000;
SELECT proj_name, budget FROM projects WHERE budget > 80000;

EXPLAIN SELECT * FROM employees WHERE salary > 52000;

-- Part 9
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT';

CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';

-- Part 10
SELECT schemaname, tablename, indexname,
       pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;

DROP INDEX IF EXISTS proj_name_hash_idx;

CREATE VIEW index_documentation AS
SELECT tablename, indexname, indexdef, 'Improves salary-based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public' AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;

-- Additional challenges
CREATE INDEX emp_hire_month_idx ON employees(EXTRACT(MONTH FROM hire_date));
CREATE UNIQUE INDEX emp_dept_email_idx ON employees(dept_id, email);
EXPLAIN ANALYZE SELECT * FROM employees WHERE salary > 52000;
CREATE INDEX emp_cover_idx ON employees(dept_id) INCLUDE (emp_name, salary);





Answers to questions
2.1. At that point there are two indexes on employees: employees_pkey (created automatically for the PRIMARY KEY) and emp_salary_idx.
2.2. PostgreSQL does not index foreign keys automatically. An index on a foreign key column speeds up JOINs on that column. It also speeds up the foreign key check when rows are deleted or updated in the parent table, because otherwise the whole child table has to be scanned.
2.3. The indexes are departments_pkey, employees_pkey, projects_pkey, emp_salary_idx and emp_dept_idx. The three *_pkey indexes were created automatically for the primary keys. The other two I created manually.
3.1. Mostly not useful. A B-tree on (dept_id, salary) is sorted by dept_id first and by salary only within each dept_id. Without a condition on the leading column, PostgreSQL can’t jump to the right part of the index, so it will usually choose another index or a sequential scan.
3.2. The order of columns in the index matters, but the order of conditions in WHERE does not. Query 1 and Query 2 are the same for the planner, which reorders conditions itself. The index (dept_id, salary) is better for an equality on dept_id plus a range on salary, because it goes straight to the department and reads only the matching salary range. The index (salary, dept_id) has to scan a big range of salaries and filter by dept_id inside it.
4.1. The error is: ERROR: duplicate key value violates unique constraint "emp_email_unique_idx" with DETAIL: Key (email)=(john.smith@company.com) already exists.
4.2. Yes. PostgreSQL automatically created a unique B-tree index named employees_phone_key, because a UNIQUE constraint is implemented with a unique index.
5.1. The index stores salaries already in descending order, so for ORDER BY salary DESC the database can read rows in the index order and skip the separate sort step. For a single column a B-tree can also be scanned backwards, so the DESC option matters most in multicolumn indexes with mixed sort directions.
6.1. Without the index PostgreSQL does a sequential scan: it reads every row, calculates LOWER(emp_name) for each one and compares it with ‘john smith’. A normal index on emp_name wouldn’t help, because it stores the original values, not the lowercased ones.
7.2. You may want to drop an index if it duplicates another index, is never used, or slows down writes more than it speeds up reads. Every index takes disk space and has to be updated on each INSERT, UPDATE and DELETE.
7.3. REINDEX is useful after bulk inserts, when an index becomes bloated, and after many changes to the data.
8.2. A partial index is smaller, faster to search and cheaper to maintain. It contains only the rows that match the condition, so other rows don’t affect it.
8.3. On a table with only 5 rows the output will most likely show a Seq Scan, something like Seq Scan on employees (cost=0.00..1.06 rows=2 width=...) with Filter: (salary > 52000::numeric). This means the planner thinks reading the whole table (a single page) is cheaper than using the index. On large tables with a selective condition it would show an Index Scan or Bitmap Index Scan. To force the index for testing, run SET enable_seqscan = off; first.
9.1. Use a HASH index only when you need equality comparisons (=), for example on long values. It doesn’t support ranges (<, >) or ORDER BY. In all other cases B-tree is the better choice.
9.2. The equality query can use either index. The query proj_name > 'Database' can only use the B-tree, because hash indexes don’t support range searches.
10.1. On such small tables the sizes are almost the same, with B-tree indexes around 16 kB each. The hash indexes (dept_name_hash_idx, proj_name_hash_idx) are probably the largest, because a hash index allocates several service pages and bucket pages even when it holds almost no data. Check your actual query result for exact numbers.
10.2. proj_name_hash_idx is redundant, because proj_name_btree_idx already handles both equality and range queries.
Summary questions
B-tree.
Create an index on columns often used in WHERE, on columns used in JOIN conditions (including foreign keys) and ORDER BY, and when you need to enforce uniqueness.
Don’t create an index on very small tables, where a sequential scan is already fast. Also avoid it on columns with very few distinct values (for example a boolean) and on tables with heavy writes and rare reads.
Indexes are updated on every INSERT, UPDATE and DELETE, so writes become slower. The more indexes a table has, the more expensive writes are.
Use EXPLAIN or EXPLAIN ANALYZE. If an index is used, the plan shows Index Scan, Index Only Scan or Bitmap Index Scan. If not, it shows Seq Scan.
Reflection
Indexes should be created on columns that are searched, joined and sorted often, especially in large tables. On small tables like the ones in this lab, the planner will still choose a Seq Scan, so the benefit of indexes is only visible with larger amounts of data. It’s important not to create too many indexes, because they slow down writes and use disk space. EXPLAIN should be used to check whether indexes are really used, and duplicate or unused ones should be removed. Partial and expression indexes are helpful when queries are repetitive, for example searching by LOWER(name) or working with a specific subset of rows.