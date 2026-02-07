/* ============================================================
   Module 4 Base Script
   Applying Best Practices for Writing Maintainable SQL Code
   ============================================================ */

-------------------------------------------------------------
-- 1. Clean start for this module
-------------------------------------------------------------

DROP SCHEMA IF EXISTS app_core CASCADE;

-------------------------------------------------------------
-- 2. Create application schema
-------------------------------------------------------------

CREATE SCHEMA app_core;
SET search_path TO app_core, public;

-------------------------------------------------------------
-- 3. Create two bare-bones tables
-------------------------------------------------------------

CREATE TABLE customer_accounts (
    account_id     SERIAL PRIMARY KEY,
    customer_name  TEXT      NOT NULL,
    email          TEXT      NOT NULL,
    is_active      BOOLEAN   NOT NULL DEFAULT true,
    created_at     TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE customer_orders (
    order_id     SERIAL PRIMARY KEY,
    account_id   INTEGER       NOT NULL,
    order_total  NUMERIC(10,2) NOT NULL,
    order_status TEXT          NOT NULL,
    created_at   TIMESTAMP     NOT NULL DEFAULT now()
);

-------------------------------------------------------------
-- 4. Add supporting indexes
-------------------------------------------------------------

CREATE INDEX customer_orders_account_id_idx
ON customer_orders(account_id);

CREATE INDEX customer_orders_status_idx
ON customer_orders(order_status);

-------------------------------------------------------------
-- 5. Reset data for repeatable demos
-------------------------------------------------------------

TRUNCATE TABLE customer_orders RESTART IDENTITY;
TRUNCATE TABLE customer_accounts RESTART IDENTITY;

-------------------------------------------------------------
-- 6. Seed a small, intentional dataset
-------------------------------------------------------------

INSERT INTO customer_accounts (customer_name, email, is_active)
VALUES
('John Doe',   'john.doe@example.com',   true),
('Jane Smith', 'jane.smith@example.com', true),
('Mike Brown', 'mike.brown@example.com', false),
('Emily Davis','emily.davis@example.com', true);

INSERT INTO customer_orders (account_id, order_total, order_status)
VALUES
(1, 120.00, 'NEW'),
(1,  80.00, 'PAID'),
(2, 250.00, 'PAID'),
(2,  30.00, 'CANCELED'),
(4, 500.00, 'NEW');

-------------------------------------------------------------
-- 7. Sanity checks
--    Verify that the base data is loaded correctly.
-------------------------------------------------------------

SELECT
    account_id,
    customer_name,
    email,
    is_active,
    created_at
FROM customer_accounts
ORDER BY account_id;

SELECT
    order_id,
    account_id,
    order_total,
    order_status,
    created_at
FROM customer_orders
ORDER BY order_id;
