/* -------------------------------------------------------------
   Clip 4: Reusing Logic and Calling Functions within Queries
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Review order data
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    status
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 3. Create a base function for order amount
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_order_amount(
    p_order_id INTEGER
)
RETURNS NUMERIC
LANGUAGE sql
AS $$
    SELECT order_amount
    FROM orders
    WHERE order_id = p_order_id;
$$;

-------------------------------------------------------------
-- 4. Create a function that uses variables and expressions
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_discounted_amount(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
BEGIN
    v_amount := get_order_amount(p_order_id);

    RETURN v_amount * (1 - p_discount_rate);
END;
$$;

-------------------------------------------------------------
-- 5. Create a function that reuses existing functions
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION calculate_tax_amount(
    p_order_id INTEGER,
    p_tax_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_discounted_amount NUMERIC;
BEGIN
    v_discounted_amount := calculate_discounted_amount(p_order_id, 0.10);

    RETURN v_discounted_amount * p_tax_rate;
END;
$$;

-------------------------------------------------------------
-- 6. Call the reusable functions directly
-------------------------------------------------------------

SELECT get_order_amount(1);
SELECT calculate_discounted_amount(1, 0.10);
SELECT calculate_tax_amount(1, 0.08);

-------------------------------------------------------------
-- 7. Use layered reusable logic inside a query
-------------------------------------------------------------

SELECT
    order_id,
    get_order_amount(order_id) AS order_amount,
    calculate_discounted_amount(order_id, 0.10) AS discounted_amount,
    calculate_tax_amount(order_id, 0.08) AS tax_amount
FROM orders
ORDER BY order_id;
