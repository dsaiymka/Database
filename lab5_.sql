DROP TABLE IF EXISTS
    order_details, ecom_orders, ecom_products, ecom_customers,
    order_items, products_fk, orders, categories,
    books, publishers, authors,
    employees_dept, student_courses, departments,
    course_enrollments, users,
    inventory, customers,
    bookings, products_catalog, employees
CASCADE;

-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name  TEXT,
    last_name   TEXT,
    age         INTEGER CONSTRAINT chk_employees_age    CHECK (age BETWEEN 18 AND 65),
    salary      NUMERIC CONSTRAINT chk_employees_salary CHECK (salary > 0)
);

-- Task 1.2
CREATE TABLE products_catalog (
    product_id     INTEGER,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price  > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);

-- Task 1.3
CREATE TABLE bookings (
    booking_id     INTEGER,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INTEGER,
    CONSTRAINT chk_bookings_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT chk_bookings_dates  CHECK (check_out_date > check_in_date)
);

-- Task 1.4
INSERT INTO employees (employee_id, first_name, last_name, age, salary) VALUES
    (1, 'Aigerim', 'Nurlanova', 28, 450000),
    (2, 'Daniyar', 'Serikov',   45, 620000.50);

INSERT INTO products_catalog (product_id, product_name, regular_price, discount_price) VALUES
    (1, 'Laptop', 1000,   850),
    (2, 'Phone',   500.00, 449.99);

INSERT INTO bookings (booking_id, check_in_date, check_out_date, num_guests) VALUES
    (1, '2025-03-01', '2025-03-05', 2),
    (2, '2025-04-10', '2025-04-12', 4);

SELECT * FROM employees;
SELECT * FROM products_catalog;
SELECT * FROM bookings;

-- Task 2.1
CREATE TABLE customers (
    customer_id       INTEGER NOT NULL,
    email             TEXT    NOT NULL,
    phone             TEXT,
    registration_date DATE    NOT NULL
);

-- Task 2.2
CREATE TABLE inventory (
    item_id      INTEGER   NOT NULL,
    item_name    TEXT      NOT NULL,
    quantity     INTEGER   NOT NULL CONSTRAINT chk_inventory_quantity   CHECK (quantity >= 0),
    unit_price   NUMERIC   NOT NULL CONSTRAINT chk_inventory_unit_price CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

-- Task 2.3
INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
    (1, 'aigerim@example.com', '+77011234567', '2025-01-10'),
    (2, 'daniyar@example.com', '+77079876543', '2025-02-15');

INSERT INTO inventory (item_id, item_name, quantity, unit_price, last_updated) VALUES
    (1, 'Notebook A5',   100, 2.50, '2025-03-01 10:00:00'),
    (2, 'Ballpoint Pen', 500, 0.75, '2025-03-02 14:30:00');

INSERT INTO customers (customer_id, email, phone, registration_date) VALUES
    (3, 'no.phone@example.com', NULL, '2025-03-20');
INSERT INTO customers (customer_id, email, registration_date) VALUES
    (4, 'omitted.phone@example.com', '2025-03-21');

SELECT * FROM customers;
SELECT * FROM inventory;

-- Task 3.1
CREATE TABLE users (
    user_id    INTEGER,
    username   TEXT UNIQUE,
    email      TEXT UNIQUE,
    created_at TIMESTAMP
);

INSERT INTO users (user_id, username, email, created_at) VALUES
    (1, 'alice', 'alice@example.com', '2025-01-10 09:00:00'),
    (2, 'bob',   'bob@example.com',   '2025-01-11 10:30:00');

-- Task 3.2
CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id    INTEGER,
    course_code   TEXT,
    semester      TEXT,
    CONSTRAINT uq_enrollment UNIQUE (student_id, course_code, semester)
);

INSERT INTO course_enrollments (enrollment_id, student_id, course_code, semester) VALUES
    (1, 101, 'CS101', 'Fall 2025'),
    (2, 101, 'CS102', 'Fall 2025'),
    (3, 102, 'CS101', 'Fall 2025'),
    (4, 101, 'CS101', 'Spring 2026');

-- Task 3.3
ALTER TABLE users DROP CONSTRAINT users_username_key;
ALTER TABLE users DROP CONSTRAINT users_email_key;

ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email    UNIQUE (email);

INSERT INTO users (user_id, username, email, created_at) VALUES
    (5, NULL, NULL, '2025-01-13 12:00:00'),
    (6, NULL, NULL, '2025-01-14 12:00:00');

SELECT * FROM users;
SELECT * FROM course_enrollments;

-- Task 4.1
CREATE TABLE departments (
    dept_id   INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location  TEXT
);

INSERT INTO departments (dept_id, dept_name, location) VALUES
    (10, 'Engineering', 'Almaty'),
    (20, 'Marketing',   'Astana'),
    (30, 'Finance',     'Shymkent'),
    (40, 'HR',          NULL);

-- Task 4.2
CREATE TABLE student_courses (
    student_id      INTEGER,
    course_id       INTEGER,
    enrollment_date DATE,
    grade           TEXT,
    CONSTRAINT pk_student_courses PRIMARY KEY (student_id, course_id)
);

INSERT INTO student_courses (student_id, course_id, enrollment_date, grade) VALUES
    (1, 1, '2025-09-01', 'A'),
    (1, 2, '2025-09-01', 'B+'),
    (2, 1, '2025-09-02', NULL);

SELECT * FROM departments;
SELECT * FROM student_courses;

-- Task 5.1
CREATE TABLE employees_dept (
    emp_id    INTEGER PRIMARY KEY,
    emp_name  TEXT NOT NULL,
    dept_id   INTEGER REFERENCES departments (dept_id),
    hire_date DATE
);

INSERT INTO employees_dept (emp_id, emp_name, dept_id, hire_date) VALUES
    (1, 'Aigerim Nurlanova', 10,   '2024-06-01'),
    (2, 'Daniyar Serikov',   20,   '2024-07-15'),
    (3, 'Madina Akhmetova',  10,   '2025-01-20'),
    (4, 'Timur Bekov',       NULL, '2025-02-10');

-- Task 5.2
CREATE TABLE authors (
    author_id   INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country     TEXT
);

CREATE TABLE publishers (
    publisher_id   INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city           TEXT
);

CREATE TABLE books (
    book_id          INTEGER PRIMARY KEY,
    title            TEXT NOT NULL,
    author_id        INTEGER REFERENCES authors (author_id),
    publisher_id     INTEGER REFERENCES publishers (publisher_id),
    publication_year INTEGER,
    isbn             TEXT UNIQUE
);

INSERT INTO authors (author_id, author_name, country) VALUES
    (1, 'Abai Kunanbayuly',   'Kazakhstan'),
    (2, 'Mukhtar Auezov',     'Kazakhstan'),
    (3, 'Chinghiz Aitmatov',  'Kyrgyzstan'),
    (4, 'Leo Tolstoy',        'Russia'),
    (5, 'Fyodor Dostoevsky',  'Russia');

INSERT INTO publishers (publisher_id, publisher_name, city) VALUES
    (1, 'Zhazushy Publishing',  'Almaty'),
    (2, 'Eurasia Press',        'Astana'),
    (3, 'Classic Books House',  'Moscow'),
    (4, 'Silk Road Editions',   'Bishkek');

INSERT INTO books (book_id, title, author_id, publisher_id, publication_year, isbn) VALUES
    (1, 'Book of Words',        1, 1, 1995, '978-0-00-000001-1'),
    (2, 'The Path of Abai',     2, 1, 1942, '978-0-00-000002-2'),
    (3, 'The Day Lasts More',   3, 4, 1980, '978-0-00-000003-3'),
    (4, 'War and Peace',        4, 3, 1869, '978-0-00-000004-4'),
    (5, 'Crime and Punishment', 5, 3, 1866, '978-0-00-000005-5');

-- Task 5.3
CREATE TABLE categories (
    category_id   INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id   INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id  INTEGER REFERENCES categories (category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id   INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id    INTEGER PRIMARY KEY,
    order_id   INTEGER REFERENCES orders (order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk (product_id),
    quantity   INTEGER CHECK (quantity > 0)
);

INSERT INTO categories (category_id, category_name) VALUES
    (1, 'Electronics'),
    (2, 'Books'),
    (3, 'Clothing');

INSERT INTO products_fk (product_id, product_name, category_id) VALUES
    (1, 'Laptop',     1),
    (2, 'Headphones', 1),
    (3, 'Novel',      2);

INSERT INTO orders (order_id, order_date) VALUES
    (1, '2025-05-01'),
    (2, '2025-05-02'),
    (3, '2025-05-03');

INSERT INTO order_items (item_id, order_id, product_id, quantity) VALUES
    (1, 1, 1, 2),
    (2, 1, 2, 1),
    (3, 2, 3, 5),
    (4, 3, 1, 1);

DELETE FROM categories WHERE category_id = 3;

SELECT * FROM order_items WHERE order_id = 1;

DELETE FROM orders WHERE order_id = 1;

SELECT * FROM order_items WHERE order_id = 1;

SELECT * FROM order_items ORDER BY item_id;

-- Task 6.1
CREATE TABLE ecom_customers (
    customer_id       INTEGER PRIMARY KEY,
    name              TEXT NOT NULL,
    email             TEXT NOT NULL UNIQUE,
    phone             TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE ecom_products (
    product_id     INTEGER PRIMARY KEY,
    name           TEXT NOT NULL,
    description    TEXT,
    price          NUMERIC(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE ecom_orders (
    order_id     INTEGER PRIMARY KEY,
    customer_id  INTEGER NOT NULL REFERENCES ecom_customers (customer_id) ON DELETE RESTRICT,
    order_date   DATE NOT NULL,
    total_amount NUMERIC(12,2) NOT NULL CHECK (total_amount >= 0),
    status       TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
    order_detail_id INTEGER PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES ecom_orders (order_id) ON DELETE CASCADE,
    product_id      INTEGER NOT NULL REFERENCES ecom_products (product_id) ON DELETE RESTRICT,
    quantity        INTEGER NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO ecom_customers (customer_id, name, email, phone, registration_date) VALUES
    (1, 'Aigerim Nurlanova', 'aigerim@shop.example', '+77011112233', '2025-01-05'),
    (2, 'Daniyar Serikov',   'daniyar@shop.example', '+77022223344', '2025-01-18'),
    (3, 'Madina Akhmetova',  'madina@shop.example',  NULL,           '2025-02-02'),
    (4, 'Timur Bekov',       'timur@shop.example',   '+77044445566', '2025-02-20'),
    (5, 'Alina Karimova',    'alina@shop.example',   '+77055556677', '2025-03-11');

INSERT INTO ecom_products (product_id, name, description, price, stock_quantity) VALUES
    (1, 'Wireless Mouse',      'Ergonomic 2.4 GHz mouse',          25.00, 150),
    (2, 'Mechanical Keyboard', 'Tenkeyless, blue switches',        80.00,  75),
    (3, 'USB-C Hub',           '7-in-1 hub with HDMI',             45.50, 200),
    (4, '27-inch Monitor',     'QHD IPS display',                 320.00,  40),
    (5, 'Laptop Stand',        'Adjustable aluminium stand',       35.00, 120);

INSERT INTO ecom_orders (order_id, customer_id, order_date, total_amount, status) VALUES
    (1, 1, '2025-05-01', 130.00, 'delivered'),
    (2, 2, '2025-05-03', 320.00, 'shipped'),
    (3, 3, '2025-05-07', 126.00, 'processing'),
    (4, 4, '2025-05-10',  95.00, 'pending'),
    (5, 5, '2025-05-12',  80.00, 'cancelled');

INSERT INTO order_details (order_detail_id, order_id, product_id, quantity, unit_price) VALUES
    (1, 1, 1, 2,  25.00),
    (2, 1, 2, 1,  80.00),
    (3, 2, 4, 1, 320.00),
    (4, 3, 3, 2,  45.50),
    (5, 3, 5, 1,  35.00),
    (6, 4, 1, 1,  25.00),
    (7, 4, 5, 2,  35.00),
    (8, 5, 2, 1,  80.00);

SELECT 'ecom_customers' AS tbl, COUNT(*) FROM ecom_customers
UNION ALL SELECT 'ecom_products', COUNT(*) FROM ecom_products
UNION ALL SELECT 'ecom_orders',   COUNT(*) FROM ecom_orders
UNION ALL SELECT 'order_details', COUNT(*) FROM order_details;

SELECT o.order_id, o.total_amount, SUM(d.quantity * d.unit_price) AS computed_total
FROM ecom_orders o
JOIN order_details d ON d.order_id = o.order_id
GROUP BY o.order_id, o.total_amount
HAVING o.total_amount <> SUM(d.quantity * d.unit_price);

SELECT o.order_id, c.name AS customer, o.order_date, o.status, o.total_amount
FROM ecom_orders o
JOIN ecom_customers c ON c.customer_id = o.customer_id
ORDER BY o.order_id;

BEGIN;
    SELECT COUNT(*) AS lines_before FROM order_details WHERE order_id = 3;
    DELETE FROM ecom_orders WHERE order_id = 3;
    SELECT COUNT(*) AS lines_after  FROM order_details WHERE order_id = 3;
ROLLBACK;

SELECT COUNT(*) AS lines_restored FROM order_details WHERE order_id = 3;
