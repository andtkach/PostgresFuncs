/* -------------------------------------------------------------
   Clip 2: Understanding and Creating User-defined Functions
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Run a simple query to retrieve order data
-------------------------------------------------------------

SELECT order_amount
FROM orders
WHERE order_id = 1;

-------------------------------------------------------------
-- 3. Create a simple SQL function
--    Defines parameters and a return value
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
-- 4. Call the SQL function
-------------------------------------------------------------

SELECT get_order_amount(1);

-------------------------------------------------------------
-- 5. Create a simple PL/pgSQL function
--    Uses procedural syntax with a return statement
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_order_status(
    p_order_id INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN (
        SELECT status
        FROM orders
        WHERE order_id = p_order_id
    );
END;
$$;

-------------------------------------------------------------
-- 6. Call the PL/pgSQL function
-------------------------------------------------------------

SELECT get_order_status(1);

-------------------------------------------------------------
-- 7. Use both functions together in a query
-------------------------------------------------------------

SELECT
    order_id,
    get_order_amount(order_id) AS order_amount,
    get_order_status(order_id) AS order_status
FROM orders
ORDER BY order_id;
