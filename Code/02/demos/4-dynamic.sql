/* -------------------------------------------------------------
   Clip 4: Executing Dynamic SQL Safely
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Quick baseline check
-------------------------------------------------------------

SELECT
    order_id,
    customer_id,
    order_amount,
    status
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 3. Unsafe pattern (do not run)
--    This shows what NOT to do: string concatenation with inputs.
-------------------------------------------------------------

-- CREATE OR REPLACE FUNCTION unsafe_orders_by_status(p_status TEXT)
-- RETURNS SETOF business_logic.orders
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
--     v_sql TEXT;
-- BEGIN
--     v_sql := 'SELECT * FROM business_logic.orders WHERE status = ''' || p_status || '''';
--     RETURN QUERY EXECUTE v_sql;
-- END;
-- $$;

-------------------------------------------------------------
-- 4. Safe dynamic filtering with parameterization
--    We build the SQL string, but pass values using USING.
--
--    Features:
--      - Optional status filter
--      - Optional minimum amount filter
--      - Safe ORDER BY using validated identifiers
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_orders_dynamic_safe(
    p_status      TEXT    DEFAULT NULL,
    p_min_amount  NUMERIC DEFAULT NULL,
    p_sort_col    TEXT    DEFAULT 'order_id',
    p_sort_dir    TEXT    DEFAULT 'ASC'
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
DECLARE
    v_sql        TEXT;
    v_where      TEXT := ' WHERE 1=1 ';
    v_sort_col   TEXT;
    v_sort_dir   TEXT;
BEGIN
    ---------------------------------------------------------
    -- Validate and normalize ORDER BY inputs (identifiers)
    ---------------------------------------------------------

    IF p_sort_dir IS NULL THEN
        v_sort_dir := 'ASC';
    ELSE
        v_sort_dir := UPPER(p_sort_dir);
    END IF;

    IF v_sort_dir NOT IN ('ASC', 'DESC') THEN
        RAISE EXCEPTION 'Invalid sort direction: %. Use ASC or DESC.', p_sort_dir;
    END IF;

    -- Whitelist allowed sort columns to avoid unsafe identifiers
    IF p_sort_col IN ('order_id', 'customer_id', 'order_date', 'order_amount', 'status') THEN
        v_sort_col := p_sort_col;
    ELSE
        RAISE EXCEPTION 'Invalid sort column: %', p_sort_col;
    END IF;

    ---------------------------------------------------------
    -- Build WHERE clause with placeholders
    -- We will supply values using USING (safe)
    ---------------------------------------------------------

    IF p_status IS NOT NULL THEN
        v_where := v_where || ' AND status = $1 ';
    END IF;

    IF p_min_amount IS NOT NULL THEN
        IF p_status IS NULL THEN
            v_where := v_where || ' AND order_amount >= $1 ';
        ELSE
            v_where := v_where || ' AND order_amount >= $2 ';
        END IF;
    END IF;

    ---------------------------------------------------------
    -- Build full SQL with safe identifier formatting for ORDER BY
    ---------------------------------------------------------

    v_sql := 'SELECT order_id, customer_id, order_date, order_amount, status
              FROM business_logic.orders'
             || v_where
             || format(' ORDER BY %I %s', v_sort_col, v_sort_dir);

    ---------------------------------------------------------
    -- Execute with USING values (safe parameterization)
    ---------------------------------------------------------

    IF p_status IS NOT NULL AND p_min_amount IS NOT NULL THEN
        RETURN QUERY EXECUTE v_sql USING p_status, p_min_amount;

    ELSIF p_status IS NOT NULL AND p_min_amount IS NULL THEN
        RETURN QUERY EXECUTE v_sql USING p_status;

    ELSIF p_status IS NULL AND p_min_amount IS NOT NULL THEN
        RETURN QUERY EXECUTE v_sql USING p_min_amount;

    ELSE
        RETURN QUERY EXECUTE v_sql;
    END IF;
END;
$$;

-------------------------------------------------------------
-- 5. Call the safe dynamic function (different scenarios)
-------------------------------------------------------------

-- Filter by status only
SELECT * FROM get_orders_dynamic_safe('paid', NULL, 'order_id', 'ASC');

-- Filter by minimum amount only
SELECT * FROM get_orders_dynamic_safe(NULL, 100, 'order_amount', 'DESC');

-- Filter by both status and minimum amount
SELECT * FROM get_orders_dynamic_safe('placed', 100, 'order_id', 'ASC');

-- No filters, different ordering
SELECT * FROM get_orders_dynamic_safe(NULL, NULL, 'status', 'ASC');

-- Should fail (by design) due to whitelist validation
-- SELECT * FROM get_orders_dynamic_safe(NULL, NULL, 'drop table orders', 'ASC');
