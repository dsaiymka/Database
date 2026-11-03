-- Laboratory Work 6: SQL JOINs

-- Part 1: Database Setup

-- Step 1.1: Create Sample Tables

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10, 2)
);

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(50),
    dept_id INT,
    budget DECIMAL(10, 2)
);


-- Step 1.2: Insert Sample Data

INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);


-- Part 2: CROSS JOIN Exercises

-- Exercise 2.1: Basic CROSS JOIN

SELECT e.emp_name, d.dept_name
FROM employees e
CROSS JOIN departments d;

-- Answer: 20 rows (5 employees * 4 departments).


-- Exercise 2.2: Alternative CROSS JOIN Syntax

-- a) Comma notation

SELECT e.emp_name, d.dept_name
FROM employees e, departments d;

-- b) INNER JOIN with TRUE condition

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON TRUE;


-- Exercise 2.3: Practical CROSS JOIN

SELECT e.emp_name, p.project_name
FROM employees e
CROSS JOIN projects p
ORDER BY e.emp_name, p.project_name;


-- Part 3: INNER JOIN Exercises

-- Exercise 3.1: Basic INNER JOIN with ON

SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

-- Answer: 4 rows. Tom Brown is not included because his dept_id is NULL.


-- Exercise 3.2: INNER JOIN with USING

SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);

-- Answer: USING displays the common dept_id column only once.


-- Exercise 3.3: NATURAL INNER JOIN

SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;


-- Exercise 3.4: Multi-table INNER JOIN

SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;


-- Part 4: LEFT JOIN Exercises

-- Exercise 4.1: Basic LEFT JOIN

SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;

-- Answer: Tom Brown is included with NULL department values.


-- Exercise 4.2: LEFT JOIN with USING

SELECT emp_name, dept_id, dept_name, location
FROM employees
LEFT JOIN departments USING (dept_id);


-- Exercise 4.3: Find Unmatched Records

SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;


-- Exercise 4.4: LEFT JOIN with Aggregation

SELECT
    d.dept_name,
    COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;


-- Part 5: RIGHT JOIN Exercises

-- Exercise 5.1: Basic RIGHT JOIN

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- Exercise 5.2: Convert to LEFT JOIN

SELECT e.emp_name, d.dept_name
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id;


-- Exercise 5.3: Find Departments Without Employees

SELECT d.dept_name, d.location
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL;


-- Part 6: FULL JOIN Exercises

-- Exercise 6.1: Basic FULL JOIN

SELECT
    e.emp_name,
    e.dept_id AS emp_dept,
    d.dept_id AS dept_dept,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;

-- Answer:
-- NULL on the left side: departments without employees.
-- NULL on the right side: employees without departments.


-- Exercise 6.2: FULL JOIN with Projects

SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;


-- Exercise 6.3: Find Orphaned Records

SELECT
    CASE
        WHEN e.emp_id IS NULL THEN 'Department without employees'
        WHEN d.dept_id IS NULL THEN 'Employee without department'
        ELSE 'Matched'
    END AS record_status,
    e.emp_name,
    d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;


-- Part 7: ON vs WHERE Clause

-- Exercise 7.1: Filtering in ON Clause

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';


-- Exercise 7.2: Filtering in WHERE Clause

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Answer:
-- ON keeps all employees but matches only departments in Building A.
-- WHERE returns only employees from departments in Building A.


-- Exercise 7.3: ON vs WHERE with INNER JOIN

-- Query 1

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d
ON e.dept_id = d.dept_id
AND d.location = 'Building A';

-- Query 2

SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';

-- Answer:
-- Both queries return the same results because INNER JOIN
-- returns only matching rows.


-- Part 8: Complex JOIN Scenarios

-- Exercise 8.1: Multiple Joins with Different Types

SELECT
    d.dept_name,
    e.emp_name,
    e.salary,
    p.project_name,
    p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;


-- Exercise 8.2: Self Join

-- Add manager_id column

ALTER TABLE employees ADD COLUMN manager_id INT;

-- Update sample data

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Self JOIN query

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;


-- Exercise 8.3: Join with Subquery

SELECT
    d.dept_name,
    AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;


-- Lab Questions

-- 1. INNER JOIN returns only matching rows.
-- LEFT JOIN returns all rows from the left table and matching rows
-- from the right table.

-- 2. CROSS JOIN is used to create all possible combinations,
-- for example, employees and projects.

-- 3. In outer joins, ON preserves unmatched rows, while WHERE
-- filters the final result. In INNER JOIN, both usually give
-- the same result.

-- 4. 5 * 10 = 50 rows.

-- 5. NATURAL JOIN automatically joins columns with the same names.

-- 6. NATURAL JOIN can produce unexpected results if new columns
-- with identical names are added to both tables.

-- 7. RIGHT JOIN version:

SELECT *
FROM B
RIGHT JOIN A ON A.id = B.id;

-- 8. FULL OUTER JOIN is used when we need all records from both
-- tables, including matching and unmatched records.


-- Additional Challenges (Optional)

-- Challenge 1: Simulate FULL OUTER JOIN using UNION

SELECT e.emp_name, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id

UNION

SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;


-- Challenge 2: Find Employees Working in Departments
-- with More Than One Project

SELECT e.emp_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    GROUP BY dept_id
    HAVING COUNT(project_id) > 1
);


-- Challenge 3: Show the Organizational Structure

SELECT
    e.emp_name AS employee,
    m.emp_name AS manager,
    mm.emp_name AS manager_of_manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id
LEFT JOIN employees mm ON m.manager_id = mm.emp_id;


-- Challenge 4: Find All Pairs of Employees
-- Working in the Same Department

SELECT
    e1.emp_name AS employee1,
    e2.emp_name AS employee2,
    e1.dept_id
FROM employees e1
INNER JOIN employees e2
ON e1.dept_id = e2.dept_id
AND e1.emp_id < e2.emp_id
WHERE e1.dept_id IS NOT NULL;