/* -------------------------------------------------------------
   Clip 3: Managing Variables and Expressions within Functions
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Create a function using variables and expressions
--    Calculates a discounted order amount
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_discounted_amount(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_amount NUMERIC;
    v_discounted_amount NUMERIC;
BEGIN
    SELECT order_amount
    INTO v_order_amount
    FROM orders
    WHERE order_id = p_order_id;

    v_discounted_amount := v_order_amount * (1 - p_discount_rate);

    RETURN v_discounted_amount;
END;
$$;

-------------------------------------------------------------
-- 3. Call the function with different discount values
-------------------------------------------------------------

SELECT calculate_discounted_amount(1, 0.10);
SELECT calculate_discounted_amount(1, 0.25);

-------------------------------------------------------------
-- 4. Use the function inside a query
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    calculate_discounted_amount(order_id, 0.15) AS discounted_amount
FROM orders
ORDER BY order_id;
