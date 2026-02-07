/* -------------------------------------------------------------
   Clip 1: Demo – SECURITY INVOKER vs SECURITY DEFINER
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO app_data, public;

-------------------------------------------------------------
-- 2. Create a low-privilege demo role if it does not exist
--    This role represents an application user without table access.
-------------------------------------------------------------

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'demo_user') THEN
        CREATE ROLE demo_user LOGIN;
    END IF;
END $$;

-------------------------------------------------------------
-- 3. Ensure the demo role has no direct access to the base table
-------------------------------------------------------------

REVOKE ALL ON TABLE app_data.customer_accounts FROM demo_user;

-------------------------------------------------------------
-- 4. Create a function using SECURITY INVOKER
--    Executes with the caller’s privileges.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION app_data.fn_invoker(
    p_account_id INTEGER
)
RETURNS TEXT
LANGUAGE sql
SECURITY INVOKER
AS $$
    SELECT customer_name
    FROM app_data.customer_accounts
    WHERE account_id = p_account_id;
$$;

-------------------------------------------------------------
-- 5. Create a function using SECURITY DEFINER
--    Executes with the function owner’s privileges.
--    The search_path is explicitly set for safety.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION app_data.fn_definer(
    p_account_id INTEGER
)
RETURNS TEXT
LANGUAGE sql
SECURITY DEFINER
SET search_path = app_data, pg_catalog
AS $$
    SELECT customer_name
    FROM app_data.customer_accounts
    WHERE account_id = p_account_id;
$$;

-------------------------------------------------------------
-- 6. Grant execution rights without granting table access
-------------------------------------------------------------

GRANT USAGE ON SCHEMA app_data TO demo_user;
GRANT EXECUTE ON FUNCTION app_data.fn_invoker(INTEGER) TO demo_user;
GRANT EXECUTE ON FUNCTION app_data.fn_definer(INTEGER) TO demo_user;

-------------------------------------------------------------
-- 7. Run the demo as the low-privilege user
--    Observe how execution context affects behavior.
-------------------------------------------------------------

SET ROLE demo_user;

-- Direct table access fails
SELECT
    customer_name
FROM app_data.customer_accounts
WHERE account_id = 1;

-- SECURITY INVOKER fails because it uses caller permissions
SELECT app_data.fn_invoker(1);

-- SECURITY DEFINER succeeds because it uses owner permissions
SELECT app_data.fn_definer(1);

RESET ROLE;

-------------------------------------------------------------
-- 8. Verify which function is SECURITY DEFINER
-------------------------------------------------------------

SELECT
    p.proname AS function_name,
    p.prosecdef AS is_security_definer
FROM pg_proc p
JOIN pg_namespace n
  ON n.oid = p.pronamespace
WHERE n.nspname = 'app_data'
  AND p.proname IN ('fn_invoker', 'fn_definer')
ORDER BY p.proname;
