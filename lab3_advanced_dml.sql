-- ============================================================
-- Laboratory Work #3 - Advanced DML Operations
-- Database Systems - KBTU
-- File: lab3_advanced_dml.sql
-- ============================================================


-- ============================================================
-- PART A: DATABASE AND TABLE SETUP
-- ============================================================

-- 1. Create database
CREATE DATABASE advanced_lab
    WITH
    ENCODING = 'UTF8'
    TEMPLATE = template0;

-- Connect to the new database
\c advanced_lab


-- ------------------------------------------------------------
-- Create employees table
-- ------------------------------------------------------------

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    department VARCHAR(50) DEFAULT 'Unassigned',
    salary INTEGER DEFAULT 50000,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);


-- ------------------------------------------------------------
-- Create departments table
-- ------------------------------------------------------------

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget INTEGER,
    manager_id INTEGER
);


-- ------------------------------------------------------------
-- Create projects table
-- ------------------------------------------------------------

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INTEGER,
    start_date DATE,
    end_date DATE,
    budget INTEGER,
    CONSTRAINT fk_project_department
        FOREIGN KEY (dept_id)
        REFERENCES departments(dept_id)
);


-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Additional departments used as sample data.
-- The main 3-department INSERT required by Task 4 is below.

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('Finance', 200000, NULL),
    ('Marketing', 80000, NULL),
    ('Legal', 70000, NULL);


-- Sample employees.
-- These rows allow the later UPDATE and DELETE queries
-- to actually affect data.

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Alice', 'Smith', 'IT', 70000, '2019-05-10', 'Active'),
    ('Bob', 'Johnson', 'Sales', 55000, '2021-03-15', 'Active'),
    ('Carol', 'Williams', 'HR', 85000, '2018-07-20', 'Active'),
    ('David', 'Brown', 'IT', 45000, '2022-11-01', 'Inactive'),
    ('Eva', 'Davis', 'Sales', 65000, '2024-02-12', 'Terminated'),
    ('Frank', 'Miller', 'Finance', 90000, '2017-01-25', 'Active'),
    ('Grace', 'Wilson', 'Marketing', 35000, '2024-06-10', 'Active'),
    ('Hank', 'Lee', 'IT', 75000, '2020-09-09', 'Active'),
    ('Ivy', 'Clark', 'Sales', 48000, '2022-04-18', 'Active'),
    ('Ian', 'Walker', 'IT', 60000, '2019-12-01', 'Active'),
    ('Nina', 'NullDept', NULL, 35000, '2024-05-01', 'Active');


-- ============================================================
-- PART B: ADVANCED INSERT OPERATIONS
-- ============================================================


-- ------------------------------------------------------------
-- 2. INSERT with column specification
-- ------------------------------------------------------------
-- Only the specified columns are inserted.
-- salary, hire_date and status are not specified.

INSERT INTO employees
    (emp_id, first_name, last_name, department)
VALUES
    (100, 'Liam', 'Taylor', 'IT');


-- ------------------------------------------------------------
-- 3. INSERT with DEFAULT values
-- ------------------------------------------------------------
-- salary uses DEFAULT = 50000
-- status uses DEFAULT = 'Active'

INSERT INTO employees
    (first_name, last_name, department, salary, status)
VALUES
    ('Mia', 'Anderson', 'HR', DEFAULT, DEFAULT);


-- ------------------------------------------------------------
-- 4. INSERT multiple rows in one statement
-- ------------------------------------------------------------
-- Three departments are inserted using one INSERT statement.

INSERT INTO departments
    (dept_name, budget, manager_id)
VALUES
    ('IT', 150000, NULL),
    ('Sales', 90000, NULL),
    ('HR', 120000, NULL);


-- ------------------------------------------------------------
-- 5. INSERT with expressions
-- ------------------------------------------------------------
-- hire_date is calculated using CURRENT_DATE.
-- salary is calculated as 50000 * 1.1.

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    (
        'Noah',
        'Martin',
        'IT',
        50000 * 1.1,
        CURRENT_DATE,
        DEFAULT
    );


-- ------------------------------------------------------------
-- 6. INSERT from SELECT (subquery)
-- ------------------------------------------------------------
-- Create a temporary table and copy all IT employees into it.

CREATE TEMP TABLE temp_employees (
    LIKE employees INCLUDING ALL
);

INSERT INTO temp_employees
SELECT *
FROM employees
WHERE department = 'IT';


-- ============================================================
-- PART C: COMPLEX UPDATE OPERATIONS
-- ============================================================


-- ------------------------------------------------------------
-- 7. UPDATE with arithmetic expression
-- ------------------------------------------------------------
-- Increase every employee salary by 10%.

UPDATE employees
SET salary = ROUND(salary * 1.10)::INTEGER;


-- ------------------------------------------------------------
-- 8. UPDATE with WHERE and multiple conditions
-- ------------------------------------------------------------
-- Employees with salary > 60000 and hire date before 2020
-- become Senior.

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000
  AND hire_date < '2020-01-01';


-- ------------------------------------------------------------
-- 9. UPDATE using CASE expression
-- ------------------------------------------------------------
-- Department is determined from salary.

UPDATE employees
SET department =
    CASE
        WHEN salary > 80000 THEN 'Management'
        WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
        ELSE 'Junior'
    END;


-- ------------------------------------------------------------
-- 10. UPDATE with DEFAULT
-- ------------------------------------------------------------
-- Employees with Inactive status receive the DEFAULT
-- department value ('Unassigned').

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';


-- ------------------------------------------------------------
-- Restore meaningful department names for the remaining
-- DML tests.
--
-- Task 9 intentionally changes departments using CASE.
-- The following setup restores department information so
-- that Tasks 11, 12, 21, 24 and 27 can also be tested.
-- ------------------------------------------------------------

UPDATE employees
SET department =
    CASE
        WHEN first_name = 'Alice' THEN 'IT'
        WHEN first_name = 'Bob' THEN 'Sales'
        WHEN first_name = 'Carol' THEN 'HR'
        WHEN first_name = 'David' THEN 'IT'
        WHEN first_name = 'Eva' THEN 'Sales'
        WHEN first_name = 'Frank' THEN 'Finance'
        WHEN first_name = 'Grace' THEN 'Marketing'
        WHEN first_name = 'Hank' THEN 'IT'
        WHEN first_name = 'Ivy' THEN 'Sales'
        WHEN first_name = 'Ian' THEN 'IT'
        WHEN first_name = 'Liam' THEN 'IT'
        WHEN first_name = 'Mia' THEN 'HR'
        WHEN first_name = 'Nina' THEN NULL
        WHEN first_name = 'Noah' THEN 'IT'
        ELSE department
    END;


-- ------------------------------------------------------------
-- 11. UPDATE using subquery
-- ------------------------------------------------------------
-- Increase each department budget by 20% of the average
-- salary of employees working in that department.

UPDATE departments d
SET budget =
    ROUND(
        (
            SELECT AVG(e.salary) * 1.20
            FROM employees e
            WHERE e.department = d.dept_name
        )
    )::INTEGER
WHERE EXISTS (
    SELECT 1
    FROM employees e
    WHERE e.department = d.dept_name
);


-- ------------------------------------------------------------
-- 12. UPDATE multiple columns
-- ------------------------------------------------------------
-- Sales employees receive a 15% salary increase
-- and their status becomes Promoted.

UPDATE employees
SET
    salary = ROUND(salary * 1.15)::INTEGER,
    status = 'Promoted'
WHERE department = 'Sales';


-- ============================================================
-- PART D: ADVANCED DELETE OPERATIONS
-- ============================================================


-- ------------------------------------------------------------
-- 13. DELETE with simple WHERE condition
-- ------------------------------------------------------------
-- Delete all terminated employees.

DELETE FROM employees
WHERE status = 'Terminated';


-- ------------------------------------------------------------
-- 14. DELETE with complex WHERE clause
-- ------------------------------------------------------------
-- Delete employees satisfying all three conditions.

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;


-- ------------------------------------------------------------
-- 15. DELETE with subquery
-- ------------------------------------------------------------
-- The assignment wording compares dept_id with department,
-- but dept_id is an integer and employee department is text.
-- Therefore we correctly compare dept_name with department.

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT department
    FROM employees
    WHERE department IS NOT NULL
);


-- ------------------------------------------------------------
-- 16. DELETE with RETURNING clause
-- ------------------------------------------------------------
-- Delete old projects and return all deleted columns.

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;


-- ============================================================
-- PROJECT SAMPLE DATA
-- ============================================================
-- Projects are inserted after the department cleanup.
-- Department IDs are obtained by subqueries rather than
-- hard-coded numeric IDs.

INSERT INTO projects
    (project_name, dept_id, start_date, end_date, budget)
VALUES
    (
        'Old Airport System',
        (SELECT dept_id FROM departments WHERE dept_name = 'IT'),
        '2020-01-01',
        '2022-12-01',
        40000
    ),
    (
        'Airport Expansion',
        (SELECT dept_id FROM departments WHERE dept_name = 'IT'),
        '2025-01-01',
        '2026-12-01',
        100000
    ),
    (
        'Sales Portal',
        (SELECT dept_id FROM departments WHERE dept_name = 'Sales'),
        '2025-02-01',
        '2026-10-15',
        70000
    ),
    (
        'HR Management System',
        (SELECT dept_id FROM departments WHERE dept_name = 'HR'),
        '2025-03-01',
        '2026-11-20',
        60000
    );


-- ============================================================
-- PART E: OPERATIONS WITH NULL VALUES
-- ============================================================


-- ------------------------------------------------------------
-- 17. INSERT with NULL values
-- ------------------------------------------------------------
-- salary and department are explicitly NULL.

INSERT INTO employees
    (first_name, last_name, salary, department, hire_date, status)
VALUES
    ('Olivia', 'Moore', NULL, NULL, CURRENT_DATE, 'Active');


-- ------------------------------------------------------------
-- 18. UPDATE NULL handling
-- ------------------------------------------------------------
-- Replace NULL departments with 'Unassigned'.

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;


-- ------------------------------------------------------------
-- 19. DELETE with NULL conditions
-- ------------------------------------------------------------
-- Delete employees whose salary is NULL or department is NULL.

DELETE FROM employees
WHERE salary IS NULL
   OR department IS NULL;


-- ============================================================
-- PART F: RETURNING CLAUSE OPERATIONS
-- ============================================================


-- ------------------------------------------------------------
-- 20. INSERT with RETURNING
-- ------------------------------------------------------------
-- Return generated emp_id and concatenated full name.

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Peter', 'Jackson', 'IT', 65000, CURRENT_DATE, 'Active')
RETURNING
    emp_id,
    first_name || ' ' || last_name AS full_name;


-- ------------------------------------------------------------
-- 21. UPDATE with RETURNING
-- ------------------------------------------------------------
-- Increase IT salaries by 5000.
-- The CTE stores old salaries so that both old and new
-- values can be returned.

WITH old_values AS (
    SELECT emp_id, salary
    FROM employees
    WHERE department = 'IT'
)
UPDATE employees e
SET salary = e.salary + 5000
FROM old_values o
WHERE e.emp_id = o.emp_id
RETURNING
    e.emp_id,
    o.salary AS old_salary,
    e.salary AS new_salary;


-- ------------------------------------------------------------
-- 22. DELETE with RETURNING all columns
-- ------------------------------------------------------------
-- Delete employees hired before 2020 and return all columns.

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;


-- ============================================================
-- PART G: ADVANCED DML PATTERNS
-- ============================================================


-- ------------------------------------------------------------
-- 23. Conditional INSERT
-- ------------------------------------------------------------
-- Insert the employee only if the same first and last name
-- does not already exist.

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
SELECT
    'Nora',
    'King',
    'Finance',
    62000,
    CURRENT_DATE,
    'Active'
WHERE NOT EXISTS (
    SELECT 1
    FROM employees
    WHERE first_name = 'Nora'
      AND last_name = 'King'
);


-- ------------------------------------------------------------
-- 24. UPDATE with JOIN logic using subqueries
-- ------------------------------------------------------------
-- If the employee's department budget is greater than
-- 100000, increase salary by 10%.
-- Otherwise, increase salary by 5%.

UPDATE employees e
SET salary =
    ROUND(
        e.salary *
        CASE
            WHEN (
                SELECT d.budget
                FROM departments d
                WHERE d.dept_name = e.department
            ) > 100000
            THEN 1.10
            ELSE 1.05
        END
    )::INTEGER
WHERE department IS NOT NULL;


-- ------------------------------------------------------------
-- 25. Bulk operations
-- ------------------------------------------------------------
-- Insert five employees in one INSERT statement.

INSERT INTO employees
    (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Bulk1', 'Employee', 'IT', 50000, CURRENT_DATE, 'BulkTest'),
    ('Bulk2', 'Employee', 'IT', 52000, CURRENT_DATE, 'BulkTest'),
    ('Bulk3', 'Employee', 'IT', 54000, CURRENT_DATE, 'BulkTest'),
    ('Bulk4', 'Employee', 'Sales', 56000, CURRENT_DATE, 'BulkTest'),
    ('Bulk5', 'Employee', 'HR', 58000, CURRENT_DATE, 'BulkTest');


-- Increase salaries of all five bulk employees by 10%.

UPDATE employees
SET salary = ROUND(salary * 1.10)::INTEGER
WHERE status = 'BulkTest';


-- ------------------------------------------------------------
-- 26. Data migration simulation
-- ------------------------------------------------------------
-- Create an archive table with the same structure as employees.

CREATE TABLE employee_archive (
    LIKE employees INCLUDING ALL
);


-- Move all inactive employees into the archive table.

INSERT INTO employee_archive
SELECT *
FROM employees
WHERE status = 'Inactive';


-- Delete the migrated employees from the original table.

DELETE FROM employees
WHERE status = 'Inactive';


-- ------------------------------------------------------------
-- 27. Complex business logic
-- ------------------------------------------------------------
-- Extend project end_date by 30 days if:
-- 1. project budget > 50000
-- 2. the associated department has more than 3 employees.

UPDATE projects p
SET end_date = p.end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
      SELECT COUNT(*)
      FROM employees e
      WHERE e.department = (
          SELECT d.dept_name
          FROM departments d
          WHERE d.dept_id = p.dept_id
      )
  ) > 3;


-- ============================================================
-- END OF LABORATORY WORK #3
-- ============================================================