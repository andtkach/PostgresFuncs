/* -------------------------------------------------------------
   Clip 2: Demo – Restricting Access and Managing Permissions
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Set the working schema for this demo
-------------------------------------------------------------

SET search_path TO app_data, public;

-------------------------------------------------------------
-- 2. Create a simple function we will secure
--    The function is intentionally small so permission changes
--    are easy to observe.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION app_data.get_customer_name(
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
-- 3. Remove default execution access
--    By default, functions are executable by PUBLIC.
-------------------------------------------------------------

REVOKE ALL ON FUNCTION app_data.get_customer_name(INTEGER) FROM PUBLIC;

-------------------------------------------------------------
-- 4. Ensure the demo role has schema access
--    Without USAGE on the schema, the function call will fail.
-------------------------------------------------------------

GRANT USAGE ON SCHEMA app_data TO demo_user;

-------------------------------------------------------------
-- 5. Test before granting EXECUTE
--    The function call fails due to missing EXECUTE privilege.
-------------------------------------------------------------

SET ROLE demo_user;

SELECT app_data.get_customer_name(1);

RESET ROLE;

-------------------------------------------------------------
-- 6. Grant EXECUTE on the function
--    This allows the role to run the function.
-------------------------------------------------------------

GRANT EXECUTE ON FUNCTION app_data.get_customer_name(INTEGER) TO demo_user;

-------------------------------------------------------------
-- 7. Test after granting EXECUTE
--    The function still fails because it is SECURITY INVOKER
--    and the role does not have table access.
-------------------------------------------------------------

SET ROLE demo_user;

SELECT app_data.get_customer_name(1);

RESET ROLE;

-------------------------------------------------------------
-- 8. Grant the minimum required table access
--    The function references account_id (filter) and customer_name (result).
--    After this, the function succeeds.
-------------------------------------------------------------

GRANT SELECT (account_id, customer_name)
ON TABLE app_data.customer_accounts
TO demo_user;

SET ROLE demo_user;

SELECT app_data.get_customer_name(1);

RESET ROLE;
