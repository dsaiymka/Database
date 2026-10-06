-- Laboratory Work #4

DROP TABLE IF EXISTS assignments CASCADE;
DROP TABLE IF EXISTS projects    CASCADE;
DROP TABLE IF EXISTS employees   CASCADE;

CREATE TABLE employees (
    employee_id SERIAL PRIMARY KEY,
    first_name  VARCHAR(50)    NOT NULL,
    last_name   VARCHAR(50)    NOT NULL,
    department  VARCHAR(50)    NOT NULL,
    salary      NUMERIC(10, 2) NOT NULL CHECK (salary >= 0),
    hire_date   DATE           NOT NULL,
    manager_id  INT            REFERENCES employees (employee_id),
    email       VARCHAR(100)
);

CREATE TABLE projects (
    project_id   SERIAL PRIMARY KEY,
    project_name VARCHAR(100)   NOT NULL,
    budget       NUMERIC(12, 2) NOT NULL CHECK (budget >= 0),
    start_date   DATE           NOT NULL,
    end_date     DATE,
    status       VARCHAR(20)    NOT NULL
);

CREATE TABLE assignments (
    assignment_id   SERIAL PRIMARY KEY,
    employee_id     INT            NOT NULL REFERENCES employees (employee_id),
    project_id      INT            NOT NULL REFERENCES projects (project_id),
    hours_worked    NUMERIC(6, 2)  NOT NULL CHECK (hours_worked >= 0),
    assignment_date DATE           NOT NULL
);


INSERT INTO employees (first_name, last_name, department, salary, hire_date, manager_id, email) VALUES
('Aidar',  'Sarsenov',  'IT',    85000, '2018-03-15', NULL, 'aidar.sarsenov@company.kz'),
('Aliya',  'Jumabekova','IT',    65000, '2021-07-01', 1,    NULL),
('Dana',   'Omarova',   'Sales', 62000, '2020-02-10', 1,    'dana.omarova@company.kz');


INSERT INTO projects (project_name, budget, start_date, end_date, status) VALUES
('Almaty Transport App',     180000, '2024-02-01', NULL,         'Active'),
('Astana Data Portal',       100000, '2023-09-01', '2024-03-31', 'Completed'),
('Shymkent Logistics Pilot',  40000, '2024-06-01', NULL,         'Planned');


INSERT INTO assignments (employee_id, project_id, hours_worked, assignment_date) VALUES
(1, 1, 90, '2024-02-10'),
(2, 1, 80, '2024-02-15'),
(1, 2, 40, '2023-09-10'),
(2, 2, 30, '2023-09-15');



-- Task 1.1
SELECT first_name || ' ' || last_name AS full_name,
       department,
       salary
FROM employees;

-- Task 1.2
SELECT DISTINCT department
FROM employees
ORDER BY department;

-- Task 1.3: 
SELECT project_name,
       budget,
       CASE
           WHEN budget > 150000                THEN 'Large'
           WHEN budget BETWEEN 100000 AND 150000 THEN 'Medium'
           ELSE 'Small'
       END AS budget_category
FROM projects;

-- Task 1.4
SELECT first_name || ' ' || last_name AS full_name,
       COALESCE(email, 'No email provided') AS email
FROM employees;


-- Task 2.1
SELECT *
FROM employees
WHERE hire_date > DATE '2020-01-01';

-- Task 2.2
SELECT *
FROM employees
WHERE salary BETWEEN 60000 AND 70000;

-- Task 2.3
SELECT *
FROM employees
WHERE last_name LIKE 'S%'
   OR last_name LIKE 'J%';

-- Task 2.4 
SELECT *
FROM employees
WHERE manager_id IS NOT NULL
  AND department = 'IT';




-- Task 3.1
SELECT UPPER(first_name || ' ' || last_name)          AS full_name_upper,
       LENGTH(last_name)                              AS last_name_length,
       LEFT(SPLIT_PART(email, '@', 1), 3)             AS email_prefix_3   
FROM employees;

-- Task 3.2
SELECT first_name || ' ' || last_name AS full_name,
       salary * 12                    AS annual_salary,
       ROUND(salary / 12, 2)          AS monthly_salary,
       ROUND(salary * 0.10, 2)        AS raise_amount_10_pct
FROM employees;

-- Task 3.3
SELECT 'Project: ' || project_name ||
       ' - Budget: $' || budget ||
       ' - Status: ' || status AS project_summary
FROM projects;

-- Task 3.4
SELECT first_name || ' ' || last_name AS full_name,
       hire_date,
       EXTRACT(YEAR FROM AGE(CURRENT_DATE, hire_date))::INT AS tenure_years
FROM employees;



-- Task 4.1
SELECT department,
       ROUND(AVG(salary), 2) AS avg_salary
FROM employees
GROUP BY department
ORDER BY department;

-- Task 4.2
SELECT p.project_name,
       COALESCE(SUM(a.hours_worked), 0) AS total_hours
FROM projects p
LEFT JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
ORDER BY p.project_name;

-- Task 4.3
SELECT department,
       COUNT(*) AS headcount
FROM employees
GROUP BY department
HAVING COUNT(*) > 1
ORDER BY department;

-- Task 4.4
SELECT MIN(salary) AS lowest_salary,
       MAX(salary) AS highest_salary,
       SUM(salary) AS total_payroll
FROM employees;



-- Task 5.1
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000
UNION
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE hire_date > DATE '2020-01-01'
ORDER BY employee_id;

-- Task 5.2
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE department = 'IT'
INTERSECT
SELECT employee_id, first_name || ' ' || last_name AS full_name, salary
FROM employees
WHERE salary > 65000
ORDER BY employee_id;

-- Task 5.3
SELECT e.employee_id, e.first_name || ' ' || e.last_name AS full_name, e.department
FROM employees e
WHERE e.employee_id IN (
    SELECT employee_id FROM employees
    EXCEPT
    SELECT employee_id FROM assignments
)
ORDER BY e.employee_id;



-- Task 6.1
SELECT e.*
FROM employees e
WHERE EXISTS (
    SELECT 1
    FROM assignments a
    WHERE a.employee_id = e.employee_id
);

-- Task 6.2
SELECT e.*
FROM employees e
WHERE e.employee_id IN (
    SELECT a.employee_id
    FROM assignments a
    JOIN projects p ON p.project_id = a.project_id
    WHERE p.status = 'Active'
);

-- Task 6.3
SELECT *
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
);



-- Task 7.1
SELECT e.first_name || ' ' || e.last_name                      AS full_name,
       e.department,
       ROUND(AVG(a.hours_worked), 2)                           AS avg_hours_per_assignment,
       RANK() OVER (PARTITION BY e.department
                    ORDER BY e.salary DESC)                    AS salary_rank_in_department
FROM employees e
LEFT JOIN assignments a ON a.employee_id = e.employee_id
GROUP BY e.employee_id, e.first_name, e.last_name, e.department, e.salary
ORDER BY e.department, salary_rank_in_department;

-- Task 7.2
SELECT p.project_name,
       SUM(a.hours_worked)            AS total_hours,
       COUNT(DISTINCT a.employee_id)  AS distinct_employees
FROM projects p
JOIN assignments a ON a.project_id = p.project_id
GROUP BY p.project_id, p.project_name
HAVING SUM(a.hours_worked) > 150
ORDER BY total_hours DESC;

-- Task 7.3
WITH dept_stats AS (
    SELECT department,
           COUNT(*)                AS employee_count,
           ROUND(AVG(salary), 2)   AS avg_salary,
           MIN(salary)             AS min_salary,
           MAX(salary)             AS max_salary
    FROM employees
    GROUP BY department
),
ranked AS (
    SELECT department,
           first_name || ' ' || last_name AS full_name,
           ROW_NUMBER() OVER (PARTITION BY department
                              ORDER BY salary DESC, employee_id) AS rn
    FROM employees
)
SELECT d.department,
       d.employee_count,
       d.avg_salary,
       r.full_name                          AS highest_paid_employee,
       d.min_salary,
       d.max_salary,
       GREATEST(d.min_salary, 55000)        AS min_bounded_by_floor,
       LEAST(d.max_salary, 90000)           AS max_capped_by_ceiling
FROM dept_stats d
JOIN ranked r ON r.department = d.department AND r.rn = 1
ORDER BY d.department;
