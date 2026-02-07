/* -------------------------------------------------------------
   Clip 1: Adding Conditional Logic with IF and CASE
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO business_logic, public;

-------------------------------------------------------------
-- 2. Quick baseline check
--    We confirm the data we will branch on.
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    status
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 3. Create a function using IF and ELSIF
--    Applies branching rules based on amount and status.
--
--    Rules:
--      - cancelled orders get 0 discount
--      - paid and high value orders get higher discount
--      - placed orders get a smaller discount
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_discount_rate_if(
    p_order_id INTEGER
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
    v_status TEXT;
    v_discount NUMERIC;
BEGIN
    SELECT order_amount, status
    INTO v_amount, v_status
    FROM orders
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;

    IF v_status = 'cancelled' THEN
        v_discount := 0.00;

    ELSIF v_status = 'paid' AND v_amount >= 200 THEN
        v_discount := 0.15;

    ELSIF v_status = 'paid' THEN
        v_discount := 0.10;

    ELSIF v_status = 'placed' AND v_amount >= 150 THEN
        v_discount := 0.07;

    ELSIF v_status = 'placed' THEN
        v_discount := 0.05;

    ELSE
        v_discount := 0.00;
    END IF;

    RETURN v_discount;
END;
$$;

-------------------------------------------------------------
-- 4. Call the IF based function
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    status,
    get_discount_rate_if(order_id) AS discount_rate_if
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 5. Create a function using CASE
--    Categorizes each order into a tier.
--
--    Tiers:
--      - cancelled orders become Cancelled
--      - high value paid orders become Premium
--      - other paid orders become Standard
--      - placed orders become Pending
--      - anything else becomes Other
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION get_order_tier_case(
    p_order_id INTEGER
)
RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
    v_status TEXT;
    v_tier   TEXT;
BEGIN
    SELECT order_amount, status
    INTO v_amount, v_status
    FROM orders
    WHERE order_id = p_order_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Order % not found', p_order_id;
    END IF;

    v_tier :=
        CASE
            WHEN v_status = 'cancelled' THEN 'Cancelled'
            WHEN v_status = 'paid' AND v_amount >= 200 THEN 'Premium'
            WHEN v_status = 'paid' THEN 'Standard'
            WHEN v_status = 'placed' THEN 'Pending'
            ELSE 'Other'
        END;

    RETURN v_tier;
END;
$$;

-------------------------------------------------------------
-- 6. Call the CASE based function
-------------------------------------------------------------

SELECT
    order_id,
    order_amount,
    status,
    get_order_tier_case(order_id) AS order_tier_case
FROM orders
ORDER BY order_id;

-------------------------------------------------------------
-- 7. Use IF and CASE together in one query
--    This shows adaptive logic that responds to data conditions.
-------------------------------------------------------------

SELECT
    o.order_id,
    o.order_amount,
    o.status,
    get_discount_rate_if(o.order_id) AS discount_rate,
    (o.order_amount * (1 - get_discount_rate_if(o.order_id)))::NUMERIC(10,2) AS discounted_amount,
    get_order_tier_case(o.order_id) AS order_tier
FROM orders o
ORDER BY o.order_id;
