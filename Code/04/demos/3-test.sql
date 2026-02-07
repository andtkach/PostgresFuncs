/* -------------------------------------------------------------
   Clip 3: Demo – Testing Functions Using Sample Datasets
   Prereq: Run Module 4 Base Script (app_core schema)
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema
-------------------------------------------------------------

SET search_path TO app_core, public;

-------------------------------------------------------------
-- 2. Create version 1 of the function (intentionally flawed)
--    The bug: it counts only PAID orders.
--    This will make one test pass and one test fail.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_customer_total_spend(
    p_account_id INTEGER
)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(order_total), 0)
    FROM customer_orders
    WHERE account_id = p_account_id
      AND order_status = 'PAID';
$$;

-------------------------------------------------------------
-- 3. Run the test case grid
--    This makes the mismatch obvious in one result set.
-------------------------------------------------------------

SELECT
    p_account_id,
    get_customer_total_spend(p_account_id) AS actual_result,
    expected_result,
    get_customer_total_spend(p_account_id) = expected_result AS test_passed
FROM (
    VALUES
        (1, 200.00),
        (2, 280.00),
        (3, 0.00)
) AS test_cases(p_account_id, expected_result);

-------------------------------------------------------------
-- 4. Fix the function (version 2)
--    Updated logic: include all orders for the account.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_customer_total_spend(
    p_account_id INTEGER
)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT COALESCE(SUM(order_total), 0)
    FROM customer_orders
    WHERE account_id = p_account_id;
$$;

-------------------------------------------------------------
-- 5. Re-run the same tests (all should pass now)
-------------------------------------------------------------

SELECT
    p_account_id,
    get_customer_total_spend(p_account_id) AS actual_result,
    expected_result,
    get_customer_total_spend(p_account_id) = expected_result AS test_passed
FROM (
    VALUES
        (1, 200.00),
        (2, 280.00),
        (3, 0.00)
) AS test_cases(p_account_id, expected_result);
