/* -------------------------------------------------------------
   Clip 5: Organizing and Documenting Functions for Maintainability
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Create dedicated schemas
--    business_functions: production style logic
--    sandbox_functions : alternate logic for comparison/testing
-------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS business_functions;
CREATE SCHEMA IF NOT EXISTS sandbox_functions;

-------------------------------------------------------------
-- 2. Create two functions with the SAME name in different schemas
--    Both return a discounted amount, but with different rules.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION business_functions.calculate_discounted_amount(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
BEGIN
    SELECT order_amount
    INTO v_amount
    FROM business_logic.orders
    WHERE order_id = p_order_id;

    RETURN v_amount * (1 - p_discount_rate);
END;
$$;

CREATE OR REPLACE FUNCTION sandbox_functions.calculate_discounted_amount(
    p_order_id INTEGER,
    p_discount_rate NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
DECLARE
    v_amount NUMERIC;
    v_effective_rate NUMERIC;
BEGIN
    SELECT order_amount
    INTO v_amount
    FROM business_logic.orders
    WHERE order_id = p_order_id;

    -- Different rule on purpose:
    -- minimum 5% discount, maximum 30% discount
    v_effective_rate := GREATEST(p_discount_rate, 0.05);
    v_effective_rate := LEAST(v_effective_rate, 0.30);

    RETURN v_amount * (1 - v_effective_rate);
END;
$$;

-------------------------------------------------------------
-- 3. Add documentation using comments
--    Keep this part, but now document both versions.
-------------------------------------------------------------

COMMENT ON FUNCTION business_functions.calculate_discounted_amount(INTEGER, NUMERIC)
IS 'Production version. Returns discounted amount using the provided discount rate.';

COMMENT ON FUNCTION sandbox_functions.calculate_discounted_amount(INTEGER, NUMERIC)
IS 'Sandbox version. Returns discounted amount using a rate clamped between 5% and 30% to demonstrate schema-based behavior.';

-------------------------------------------------------------
-- 4. Call both functions in a single query
--    This proves that schema qualification matters:
--    same function name, different schema, different result.
-------------------------------------------------------------

SELECT
    o.order_id,
    o.order_amount,
    business_functions.calculate_discounted_amount(o.order_id, 0.02) AS prod_discounted_amount,
    sandbox_functions.calculate_discounted_amount(o.order_id, 0.02) AS sandbox_discounted_amount,
    (business_functions.calculate_discounted_amount(o.order_id, 0.02)
     - sandbox_functions.calculate_discounted_amount(o.order_id, 0.02)) AS difference
FROM business_logic.orders o
ORDER BY o.order_id;


-------------------------------------------------------------
-- 5. Review function documentation
--    Show docs for both schemas side by side.
-------------------------------------------------------------

SELECT
    n.nspname AS schema_name,
    p.proname AS function_name,
    pg_get_function_identity_arguments(p.oid) AS signature,
    obj_description(p.oid) AS documentation
FROM pg_proc p
JOIN pg_namespace n ON n.oid = p.pronamespace
WHERE n.nspname IN ('business_functions', 'sandbox_functions')
  AND p.proname = 'calculate_discounted_amount'
ORDER BY n.nspname, p.proname;
