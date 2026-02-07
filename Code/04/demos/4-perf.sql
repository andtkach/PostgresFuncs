/* -------------------------------------------------------------
   Clip 4: Demo – Optimizing Function Performance and Query Plans
   Prereq: Run Module 4 Base Script (app_core schema)
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema
-------------------------------------------------------------

SET search_path TO app_core, public;

-------------------------------------------------------------
-- 2. Inspect the query plan
--    This shows how PostgreSQL executes the aggregation.
-------------------------------------------------------------

EXPLAIN
SELECT
    SUM(order_total)
FROM customer_orders
WHERE account_id = 1;

-------------------------------------------------------------
-- 3. Compare with a less optimal pattern
--    Wrapping the column prevents index usage.
-------------------------------------------------------------

EXPLAIN
SELECT
    SUM(order_total)
FROM customer_orders
WHERE CAST(account_id AS TEXT) = '2';

-------------------------------------------------------------
-- 4. Measure actual execution cost
--    ANALYZE runs the query and reports real timing.
-------------------------------------------------------------

EXPLAIN ANALYZE
SELECT
    SUM(order_total)
FROM customer_orders
WHERE account_id = 2;
