/* -------------------------------------------------------------
   Clip 1: Demo – Applying Consistent Naming and Comment Standards
   Prereq: Run Module 4 Base Script (app_core schema)
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema
-------------------------------------------------------------

SET search_path TO app_core, public;

-------------------------------------------------------------
-- 2. Add clear and intentional database comments
--    These comments document purpose, not implementation.
-------------------------------------------------------------

COMMENT ON TABLE customer_accounts
IS 'Stores core customer information used across reporting and analytics.';

COMMENT ON TABLE customer_orders
IS 'Stores order records associated with customer accounts.';

COMMENT ON COLUMN customer_orders.order_status
IS 'Represents the lifecycle state of an order such as NEW, PAID, or CANCELED.';

-------------------------------------------------------------
-- 3. Retrieve table comments
--    This shows that documentation lives inside PostgreSQL.
-------------------------------------------------------------

SELECT
    c.relname     AS table_name,
    d.description AS table_comment
FROM pg_class c
JOIN pg_namespace n
  ON n.oid = c.relnamespace
JOIN pg_description d
  ON d.objoid = c.oid
WHERE n.nspname = 'app_core'
  AND c.relkind = 'r'
ORDER BY c.relname;

-------------------------------------------------------------
-- 4. Retrieve column comments
--    This confirms column-level documentation.
-------------------------------------------------------------

SELECT
    c.relname     AS table_name,
    a.attname     AS column_name,
    d.description AS column_comment
FROM pg_attribute a
JOIN pg_class c
  ON c.oid = a.attrelid
JOIN pg_namespace n
  ON n.oid = c.relnamespace
JOIN pg_description d
  ON d.objoid = a.attrelid
 AND d.objsubid = a.attnum
WHERE n.nspname = 'app_core'
ORDER BY
    c.relname,
    a.attname;