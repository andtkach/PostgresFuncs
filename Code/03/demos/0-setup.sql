/* ============================================================
   Module 3 Base Script
   Securing and Managing Functions in Multi-user Environments
   ============================================================ */

-------------------------------------------------------------
-- 1. Start with a clean environment for this module
--    We remove only what this module owns.
-------------------------------------------------------------

DROP SCHEMA IF EXISTS app_data CASCADE;

-------------------------------------------------------------
-- 2. Create a simple and meaningful application schema
--    All demos in this module will build on this schema.
-------------------------------------------------------------

CREATE SCHEMA app_data;
SET search_path TO app_data, public;

-------------------------------------------------------------
-- 3. Create a single core table for demonstrations
--    This table is intentionally simple and realistic.
--    It supports security, visibility, and auditing examples.
-------------------------------------------------------------

CREATE TABLE customer_accounts (
    account_id     SERIAL PRIMARY KEY,
    customer_name  TEXT           NOT NULL,
    email          TEXT           UNIQUE NOT NULL,
    credit_limit   NUMERIC(10,2)  NOT NULL CHECK (credit_limit >= 0),
    is_vip         BOOLEAN        NOT NULL DEFAULT false,
    created_at     TIMESTAMP      NOT NULL DEFAULT now()
);

-------------------------------------------------------------
-- 4. Reset data to keep demos repeatable
--    This ensures predictable results every time.
-------------------------------------------------------------

TRUNCATE TABLE customer_accounts RESTART IDENTITY;

-------------------------------------------------------------
-- 5. Seed sample data
--    Small dataset with varied values for demos.
-------------------------------------------------------------

INSERT INTO customer_accounts (customer_name, email, credit_limit, is_vip)
VALUES
('John Doe',     'john.doe@example.com',     1000.00, false),
('Jane Smith',   'jane.smith@example.com',   5000.00, true),
('Mike Johnson', 'mike.johnson@example.com', 1500.00, false),
('Emily Davis',  'emily.davis@example.com',  2500.00, true),
('Robert Brown', 'robert.brown@example.com',  750.00, false);

-------------------------------------------------------------
-- 6. Sanity check
--    Verify that the base data is loaded correctly.
-------------------------------------------------------------

SELECT
    account_id,
    customer_name,
    email,
    credit_limit,
    is_vip,
    created_at
FROM customer_accounts
ORDER BY account_id;
