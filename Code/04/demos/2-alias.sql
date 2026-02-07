/* -------------------------------------------------------------
   Clip 2: Demo – Structuring Queries for Clarity and Performance
   Prereq: Run Module 4 Base Script (app_core schema)
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema
-------------------------------------------------------------

SET search_path TO app_core, public;

-------------------------------------------------------------
-- 2. Poorly structured query
--    This query works, but intent and logic are hard to read.
-------------------------------------------------------------

SELECT a.customer_name,SUM(o.order_total),COUNT(o.order_id)
FROM customer_accounts a JOIN customer_orders o ON a.account_id=o.account_id
WHERE o.order_status='PAID' AND a.is_active=true
GROUP BY a.customer_name
ORDER BY SUM(o.order_total) DESC;

-------------------------------------------------------------
-- 3. Improve clarity with consistent aliasing
--    Short, meaningful aliases reduce visual noise.
-------------------------------------------------------------

SELECT
    ca.customer_name,	
    SUM(co.order_total) AS total_order_amount,
    COUNT(co.order_id)  AS order_count
FROM customer_accounts ca
JOIN customer_orders co
    ON ca.account_id = co.account_id
WHERE ca.is_active = true
  AND co.order_status = 'PAID'
GROUP BY
    ca.customer_name
ORDER BY
    total_order_amount DESC;
