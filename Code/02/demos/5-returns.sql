/* -------------------------------------------------------------
   Clip 5: Returning Records and Sets from Functions
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Quick baseline check
--    We confirm the data we will return as records and sets.
-------------------------------------------------------------

SELECT
    c.customer_id,
    c.full_name,
    o.order_id,
    o.order_amount,
    o.status
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

-------------------------------------------------------------
-- 3. Return a single structured record (one row)
--    We use RETURNS TABLE so the output shape is explicit.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_order_details(
    p_order_id INTEGER
)
RETURNS TABLE (
    order_id     INTEGER,
    customer_id  INTEGER,
    customer_name TEXT,
    order_date   DATE,
    order_amount NUMERIC,
    status       TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.customer_id,
        c.full_name AS customer_name,
        o.order_date,
        o.order_amount,
        o.status
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE o.order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;
END;
$$;

-------------------------------------------------------------
-- 4. Call the single-record function
--    Returns exactly one row for a valid order_id.
-------------------------------------------------------------

SELECT * FROM get_order_details(1);

-------------------------------------------------------------
-- 5. Return a set of rows (dataset)
--    This function behaves like a reusable query for apps/reports.
--
--    Features:
--      - Filters orders by status
--      - Always returns a dataset when multiple rows exist
--      - Uses RETURN QUERY to return multiple rows
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_orders_by_status(
    p_status TEXT
)
RETURNS TABLE (
    order_id     INTEGER,
    customer_id  INTEGER,
    order_date   DATE,
    order_amount NUMERIC,
    status       TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    RETURN QUERY
    SELECT
        o.order_id,
        o.customer_id,
        o.order_date,
        o.order_amount,
        o.status
    FROM orders o
    WHERE o.status = p_status
    ORDER BY o.order_id;

    IF NOT FOUND THEN
        RAISE NOTICE 'No orders found with status %', p_status;
    END IF;
END;
$$;

-------------------------------------------------------------
-- 6. Query the set-returning function like a table
-------------------------------------------------------------

-- Returns multiple rows (paid appears twice in seed data)
SELECT * FROM get_orders_by_status('paid');

-- Returns multiple rows (placed appears twice in seed data)
SELECT * FROM get_orders_by_status('placed');

-- Returns one row (cancelled appears once)
SELECT * FROM get_orders_by_status('cancelled');
