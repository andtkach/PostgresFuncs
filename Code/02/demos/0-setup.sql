/* ============================================================
   Module 2 Base Script
   Enhancing Functionality with Control Structures
   and Conditional Logic
   ============================================================ */

-------------------------------------------------------------
-- Clip 1: Environment setup (fresh start)
-------------------------------------------------------------

-- Clean up schemas used in earlier demos
DROP SCHEMA IF EXISTS business_functions CASCADE;
DROP SCHEMA IF EXISTS sandbox_functions CASCADE;
DROP SCHEMA IF EXISTS business_logic CASCADE;

-------------------------------------------------------------
-- Create base schema for Module 2 demos
-------------------------------------------------------------

CREATE SCHEMA business_logic;
SET search_path TO business_logic, public;

-------------------------------------------------------------
-- Base tables (kept simple on purpose)
-------------------------------------------------------------

-- Customers
CREATE TABLE customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     TEXT        NOT NULL,
    email         TEXT        UNIQUE NOT NULL
);

-- Orders
CREATE TABLE orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INTEGER     NOT NULL,
    order_date    DATE        NOT NULL DEFAULT current_date,
    order_amount  NUMERIC(10,2) NOT NULL CHECK (order_amount >= 0),
    status        TEXT        NOT NULL
);

-------------------------------------------------------------
-- Reset data (clean slate for every run)
-------------------------------------------------------------

TRUNCATE TABLE customers RESTART IDENTITY;
TRUNCATE TABLE orders RESTART IDENTITY;

-------------------------------------------------------------
-- Seed data: Customers
-------------------------------------------------------------

INSERT INTO customers (full_name, email)
VALUES
('John Doe',        'john.doe@example.com'),
('Jane Smith',      'jane.smith@example.com'),
('Mike Johnson',    'mike.johnson@example.com'),
('Emily Davis',     'emily.davis@example.com'),
('Robert Brown',    'robert.brown@example.com');

-------------------------------------------------------------
-- Seed data: Orders
-- Designed to support IF, CASE, loops, and exceptions
-------------------------------------------------------------

INSERT INTO orders (customer_id, order_date, order_amount, status)
VALUES
(1, '2025-01-10', 120.00, 'paid'),
(2, '2025-01-12',  75.50, 'placed'),
(3, '2025-01-15', 240.00, 'paid'),
(4, '2025-01-18',  50.00, 'cancelled'),
(5, '2025-01-20', 180.75, 'placed');

-------------------------------------------------------------
-- Sanity checks
-------------------------------------------------------------

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM orders ORDER BY order_id;
