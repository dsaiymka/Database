
-- ============================================
-- LABORATORY WORK 7: SQL VIEWS AND ROLES
-- Database Systems
-- ============================================


-- PART 1: DATABASE SETUP
-- Use the employees, departments and projects tables from Lab 6.

SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM projects;


-- ============================================
-- PART 2: CREATING BASIC VIEWS
-- ============================================

-- Exercise 2.1: Simple View Creation

CREATE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 2.2: View with Aggregation

CREATE VIEW dept_statistics AS
SELECT d.dept_name,
       COUNT(e.emp_id) AS employee_count,
       AVG(e.salary) AS average_salary,
       MAX(e.salary) AS max_salary,
       MIN(e.salary) AS min_salary
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;

SELECT * FROM dept_statistics
ORDER BY employee_count DESC;


-- Exercise 2.3: View with Multiple Joins

CREATE VIEW project_overview AS
SELECT p.project_name, p.budget, d.dept_name, d.location,
       COUNT(DISTINCT e.emp_id) AS team_size
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget,
         d.dept_name, d.location;

SELECT * FROM project_overview;


-- Exercise 2.4: View with Filtering

CREATE VIEW high_earners AS
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;


-- ============================================
-- PART 3: MODIFYING AND MANAGING VIEWS
-- ============================================

-- Exercise 3.1: Replace a View

CREATE OR REPLACE VIEW employee_details AS
SELECT e.emp_name, e.salary, d.dept_name, d.location,
       CASE
           WHEN e.salary > 60000 THEN 'High'
           WHEN e.salary > 50000 THEN 'Medium'
           ELSE 'Standard'
       END AS salary_grade
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

SELECT * FROM employee_details;


-- Exercise 3.2: Rename a View

ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;


-- Exercise 3.3: Drop a View

CREATE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;


-- ============================================
-- PART 4: UPDATABLE VIEWS
-- ============================================

-- Exercise 4.1: Create an Updatable View

CREATE VIEW employee_salaries AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees;


-- Exercise 4.2: Update Through a View

UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees
WHERE emp_name = 'John Smith';


-- Exercise 4.3: Insert Through a View

INSERT INTO employee_salaries
VALUES (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees;


-- Exercise 4.4: View with CHECK OPTION

CREATE VIEW it_employees AS
SELECT emp_id, emp_name, dept_id, salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

-- Test separately (expected error):
-- INSERT INTO it_employees
-- VALUES (7, 'Bob Wilson', 103, 60000);


-- ============================================
-- PART 5: MATERIALIZED VIEWS
-- ============================================

-- Exercise 5.1: Create a Materialized View

CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT d.dept_id,
       d.dept_name,
       COUNT(e.emp_id) AS total_employees,
       COALESCE(SUM(e.salary), 0) AS total_salaries,
       (SELECT COUNT(*)
        FROM projects p
        WHERE p.dept_id = d.dept_id) AS total_projects,
       COALESCE(
           (SELECT SUM(p.budget)
            FROM projects p
            WHERE p.dept_id = d.dept_id), 0
       ) AS total_budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
WITH DATA;

SELECT * FROM dept_summary_mv
ORDER BY total_employees DESC;


-- Exercise 5.2: Refresh Materialized View

INSERT INTO employees
VALUES (8, 'Charlie Brown', 101, 54000);

SELECT * FROM dept_summary_mv;

REFRESH MATERIALIZED VIEW dept_summary_mv;

SELECT * FROM dept_summary_mv;


-- Exercise 5.3: Concurrent Refresh

CREATE UNIQUE INDEX dept_summary_idx
ON dept_summary_mv(dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;


-- Exercise 5.4: Materialized View with NO DATA

CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT p.project_name, p.budget, d.dept_name,
       COUNT(e.emp_id) AS employee_count
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY p.project_id, p.project_name, p.budget, d.dept_name
WITH NO DATA;

-- Test separately (expected error):
-- SELECT * FROM project_stats_mv;

REFRESH MATERIALIZED VIEW project_stats_mv;


-- ============================================
-- PART 6: DATABASE ROLES
-- ============================================

-- Exercise 6.1: Create Basic Roles

CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';


-- Exercise 6.2: Role with Specific Attributes

CREATE ROLE db_creator
CREATEDB LOGIN PASSWORD 'creator789';

CREATE ROLE user_manager
CREATEROLE LOGIN PASSWORD 'manager101';

CREATE ROLE admin_user
SUPERUSER LOGIN PASSWORD 'admin999';


-- Exercise 6.3: Grant Privileges to Roles

GRANT SELECT ON employees, departments, projects TO analyst;

GRANT ALL PRIVILEGES ON employee_details TO data_viewer;

GRANT SELECT, INSERT ON employees TO report_user;


-- Exercise 6.4: Create Group Roles

CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;

GRANT SELECT ON dept_statistics TO finance_team;


-- Exercise 6.5: Revoke Privileges

REVOKE UPDATE ON employees FROM hr_team;

REVOKE hr_team FROM hr_user2;

REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;


-- Exercise 6.6: Modify Role Attributes

ALTER ROLE analyst LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager SUPERUSER;

ALTER ROLE analyst PASSWORD NULL;

ALTER ROLE data_viewer CONNECTION LIMIT 5;


-- ============================================
-- PART 7: ADVANCED ROLE MANAGEMENT
-- ============================================

-- Exercise 7.1: Role Hierarchies

CREATE ROLE read_only;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst LOGIN PASSWORD 'junior123';

CREATE ROLE senior_analyst LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;

GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;


-- Exercise 7.2: Object Ownership

CREATE ROLE project_manager LOGIN PASSWORD 'pm123';

GRANT CREATE ON SCHEMA public TO project_manager;

GRANT SELECT ON employees, departments TO project_manager;

GRANT project_manager TO CURRENT_USER;

ALTER VIEW dept_statistics OWNER TO project_manager;

ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';


-- Exercise 7.3: Reassign and Drop Roles

CREATE ROLE temp_owner LOGIN;

CREATE TABLE temp_table (
    id INT
);

ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;


-- Exercise 7.4: Row-Level Security with Views

CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;


-- ============================================
-- PART 8: PRACTICAL SCENARIOS
-- ============================================

-- Exercise 8.1: Department Dashboard View

CREATE VIEW dept_dashboard AS
SELECT d.dept_name,
       d.location,
       COALESCE(e.employee_count, 0) AS employee_count,
       ROUND(COALESCE(e.average_salary, 0), 2) AS average_salary,
       COALESCE(p.active_projects, 0) AS active_projects,
       COALESCE(p.total_project_budget, 0) AS total_project_budget,
       COALESCE(
           ROUND(
               p.total_project_budget /
               NULLIF(e.employee_count, 0), 2
           ), 0
       ) AS budget_per_employee
FROM departments d
LEFT JOIN (
    SELECT dept_id,
           COUNT(*) AS employee_count,
           AVG(salary) AS average_salary
    FROM employees
    GROUP BY dept_id
) e ON d.dept_id = e.dept_id
LEFT JOIN (
    SELECT dept_id,
           COUNT(*) AS active_projects,
           SUM(budget) AS total_project_budget
    FROM projects
    GROUP BY dept_id
) p ON d.dept_id = p.dept_id;

SELECT * FROM dept_dashboard;


-- Exercise 8.2: Audit View

ALTER TABLE projects
ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT p.project_name,
       p.budget,
       d.dept_name,
       p.created_date,
       CASE
           WHEN p.budget > 150000 THEN 'Critical Review Required'
           WHEN p.budget > 100000 THEN 'Management Approval Needed'
           ELSE 'Standard Process'
       END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

SELECT * FROM high_budget_projects;


-- Exercise 8.3: Create Access Control System

-- Level 1: Viewer Role

CREATE ROLE viewer_role;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;


-- Level 2: Entry Role

CREATE ROLE entry_role;

GRANT viewer_role TO entry_role;

GRANT INSERT ON employees, projects TO entry_role;


-- Level 3: Analyst Role

CREATE ROLE analyst_role;

GRANT entry_role TO analyst_role;

GRANT UPDATE ON employees, projects TO analyst_role;


-- Level 4: Manager Role

CREATE ROLE manager_role;

GRANT analyst_role TO manager_role;

GRANT DELETE ON employees, projects TO manager_role;


-- Create Users

CREATE USER alice WITH PASSWORD 'alice123';

CREATE USER bob WITH PASSWORD 'bob123';

CREATE USER charlie WITH PASSWORD 'charlie123';


-- Assign Roles

GRANT viewer_role TO alice;

GRANT analyst_role TO bob;

GRANT manager_role TO charlie;