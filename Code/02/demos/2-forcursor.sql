/* -------------------------------------------------------------
   Clip 2: Iterating Through Data with FOR and Cursor Loops
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Quick baseline check
--    We confirm we have multiple rows to iterate over.
-------------------------------------------------------------

SELECT
    order_id,
    customer_id,
    order_amount,
    status
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 3. Create a simple log table for loop output
--    This makes row-by-row processing visible and easy to verify.
-------------------------------------------------------------

CREATE TABLE IF NOT EXISTS order_processing_log (
    log_id     SERIAL PRIMARY KEY,
    method     TEXT        NOT NULL,
    order_id   INTEGER     NOT NULL,
    note       TEXT        NOT NULL,
    created_at TIMESTAMP   NOT NULL DEFAULT now()
);

TRUNCATE TABLE order_processing_log RESTART IDENTITY;

-------------------------------------------------------------
-- 4. FOR loop function
--    Iterates through query results automatically.
--
--    Goal:
--      - Process each order with a given status
--      - Log a row per order
--      - Return summary metrics (count and total amount)
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION process_orders_for_loop(
    p_status TEXT
)
RETURNS TABLE (
    processed_count INTEGER,
    processed_total NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    r_order RECORD;
    v_count INTEGER := 0;
    v_total NUMERIC := 0;
BEGIN
    FOR r_order IN
        SELECT order_id, order_amount
        FROM orders
        WHERE status = p_status
        ORDER BY order_id
    LOOP
        v_count := v_count + 1;
        v_total := v_total + r_order.order_amount;

        INSERT INTO order_processing_log(method, order_id, note)
        VALUES ('FOR', r_order.order_id, 'Processed in FOR loop');
    END LOOP;

    processed_count := v_count;
    processed_total := v_total;

    RETURN NEXT;
END;
$$;

-------------------------------------------------------------
-- 5. Run the FOR loop function
-------------------------------------------------------------

SELECT * FROM process_orders_for_loop('paid');

-------------------------------------------------------------
-- 6. Review the row-by-row log for FOR loop processing
-------------------------------------------------------------

SELECT
    log_id,
    method,
    order_id,
    note,
    created_at
FROM order_processing_log
ORDER BY log_id;

-------------------------------------------------------------
-- 7. Cursor loop function
--    Uses OPEN, FETCH, and CLOSE for explicit control.
--
--    Goal:
--      - Same business result as the FOR loop function
--      - Show cursor mechanics clearly
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION process_orders_cursor_loop(
    p_status TEXT
)
RETURNS TABLE (
    processed_count INTEGER,
    processed_total NUMERIC
)
LANGUAGE plpgsql
AS $$
DECLARE
    c_orders CURSOR FOR
        SELECT order_id, order_amount
        FROM orders
        WHERE status = p_status
        ORDER BY order_id;

    v_order_id INTEGER;
    v_amount   NUMERIC;

    v_count INTEGER := 0;
    v_total NUMERIC := 0;
BEGIN
    OPEN c_orders;

    LOOP
        FETCH c_orders INTO v_order_id, v_amount;
        EXIT WHEN NOT FOUND;

        v_count := v_count + 1;
        v_total := v_total + v_amount;

        INSERT INTO order_processing_log(method, order_id, note)
        VALUES ('CURSOR', v_order_id, 'Processed in CURSOR loop');
    END LOOP;

    CLOSE c_orders;

    processed_count := v_count;
    processed_total := v_total;

    RETURN QUERY
	SELECT v_count, v_total;
END;
$$;

-------------------------------------------------------------
-- 8. Run the CURSOR loop function
-------------------------------------------------------------

SELECT * FROM process_orders_cursor_loop('paid');

-------------------------------------------------------------
-- 9. Review the row-by-row log for CURSOR loop processing
-------------------------------------------------------------

SELECT
    log_id,
    method,
    order_id,
    note,
    created_at
FROM order_processing_log
ORDER BY log_id;
