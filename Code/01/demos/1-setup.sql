/* ============================================================
   Module 1 Base Script
   Encapsulating Business Logic with User-defined Functions
   ============================================================ */

-------------------------------------------------------------
-- Clip 1: Environment setup
-------------------------------------------------------------

-- Create a dedicated schema for function demos
CREATE SCHEMA IF NOT EXISTS business_logic;
SET search_path TO business_logic, public;

-------------------------------------------------------------
-- Base tables (no foreign keys by design)
-------------------------------------------------------------

-- Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id   SERIAL PRIMARY KEY,
    full_name     TEXT        NOT NULL,
    email         TEXT        UNIQUE NOT NULL
);

-- Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id      SERIAL PRIMARY KEY,
    customer_id   INTEGER     NOT NULL,
    order_date    DATE        NOT NULL DEFAULT current_date,
    order_amount  NUMERIC(10,2) NOT NULL CHECK (order_amount >= 0),
    status        TEXT        NOT NULL DEFAULT 'placed'
);

-------------------------------------------------------------
-- Reset data (clean slate for demos)
-------------------------------------------------------------

TRUNCATE TABLE customers RESTART IDENTITY;
TRUNCATE TABLE orders RESTART IDENTITY;

-------------------------------------------------------------
-- Seed data: Customers (5 rows)
-------------------------------------------------------------

INSERT INTO customers (full_name, email)
VALUES
('John Doe',        'john.doe@example.com'),
('Jane Smith',      'jane.smith@example.com'),
('Mike Johnson',    'mike.johnson@example.com'),
('Emily Davis',     'emily.davis@example.com'),
('Robert Brown',    'robert.brown@example.com');

-------------------------------------------------------------
-- Seed data: Orders (5 rows)
-------------------------------------------------------------

INSERT INTO orders (customer_id, order_date, order_amount, status)
VALUES
(1, '2025-01-10', 120.00, 'paid'),
(2, '2025-01-12',  75.50, 'placed'),
(3, '2025-01-15', 240.00, 'paid'),
(4, '2025-01-18',  50.00, 'cancelled'),
(5, '2025-01-20', 180.75, 'paid');

-------------------------------------------------------------
-- Sanity checks
-------------------------------------------------------------

SELECT * FROM customers ORDER BY customer_id;
SELECT * FROM orders ORDER BY order_id;
