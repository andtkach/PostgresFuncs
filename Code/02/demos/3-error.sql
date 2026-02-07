/* -------------------------------------------------------------
   Clip 3: Implementing Error Handling and Exception Blocks
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Create a simple error log table
--    We will store errors here for debugging and visibility.
-------------------------------------------------------------

CREATE TABLE IF NOT EXISTS function_error_log (
    log_id        SERIAL PRIMARY KEY,
    function_name TEXT        NOT NULL,
    input_context TEXT        NOT NULL,
    error_message TEXT        NOT NULL,
    logged_at     TIMESTAMP   NOT NULL DEFAULT now()
);

TRUNCATE TABLE function_error_log RESTART IDENTITY;

-------------------------------------------------------------
-- 3. Quick baseline check
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    status
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 4. Create a function that raises custom exceptions
--    This enforces business rules with clear messages.
--
--    Rules:
--      - order must exist
--      - discount rate must be between 0 and 0.50
--      - cancelled orders cannot be discounted
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION apply_discount_strict(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
    v_status TEXT;
BEGIN
    SELECT order_amount, status
    INTO v_amount, v_status
    FROM orders
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;

    IF p_discount_rate IS NULL THEN
        RAISE EXCEPTION 'Discount rate cannot be NULL';
    END IF;

    IF p_discount_rate < 0 OR p_discount_rate > 0.50 THEN
        RAISE EXCEPTION 'Invalid discount rate: %. Allowed range is 0 to 0.50', p_discount_rate;
    END IF;

    IF v_status = 'cancelled' THEN
        RAISE EXCEPTION 'Cancelled orders cannot be discounted. Order % is cancelled', p_order_id;
    END IF;

    RETURN (v_amount * (1 - p_discount_rate))::NUMERIC(10,2);
END;
$$;

-------------------------------------------------------------
-- 5. Call the strict function (valid case)
-------------------------------------------------------------

SELECT apply_discount_strict(1, 0.10) AS discounted_amount;

-------------------------------------------------------------
-- 6. Create a function that catches errors with EXCEPTION
--    It logs the error and returns NULL instead of crashing.
--
--    This shows BEGIN ... EXCEPTION and safe fallback behavior.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION apply_discount_safe(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_result NUMERIC;
BEGIN
    BEGIN
        v_result := apply_discount_strict(p_order_id, p_discount_rate);
        RETURN v_result;

    EXCEPTION
        WHEN OTHERS THEN
            INSERT INTO function_error_log(function_name, input_context, error_message)
            VALUES (
                'apply_discount_safe',
                format('order_id=%s, discount_rate=%s', p_order_id, p_discount_rate),
                SQLERRM
            );

            RAISE WARNING 'Discount failed for order %, returning NULL. Error: %', p_order_id, SQLERRM;
            RETURN NULL;
    END;
END;
$$;

-------------------------------------------------------------
-- 7. Trigger a few controlled failures (safe function)
--    These should NOT stop execution.
-------------------------------------------------------------

-- Invalid rate (too high)
SELECT apply_discount_safe(1, 0.80) AS discounted_amount;

-- Missing order
SELECT apply_discount_safe(999, 0.10) AS discounted_amount;

-- Cancelled order (order_id = 4 in seed data)
SELECT apply_discount_safe(4, 0.10) AS discounted_amount;

-------------------------------------------------------------
-- 8. Review the captured error log
-------------------------------------------------------------

SELECT
    log_id,
    function_name,
    input_context,
    error_message,
    logged_at
FROM function_error_log
ORDER BY log_id;

