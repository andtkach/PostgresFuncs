/* -------------------------------------------------------------
   Clip 3: Demo – Controlling Function Visibility with Schema and Search Path
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Create a dedicated schema for published functions
-------------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS app_api;

-------------------------------------------------------------
-- 2. Create the same function name in two schemas
--    This sets up a controlled naming conflict.
-------------------------------------------------------------

-- Function in the application schema
CREATE OR REPLACE FUNCTION app_data.get_customer_name(
    p_account_id INTEGER
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT customer_name
    FROM app_data.customer_accounts
    WHERE account_id = p_account_id;
$$;

-- Function in the API schema
CREATE OR REPLACE FUNCTION app_api.get_customer_name(
    p_account_id INTEGER
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT 'API version'::TEXT;
$$;

-------------------------------------------------------------
-- 3. Allow the demo role to access both schemas
-------------------------------------------------------------

GRANT USAGE ON SCHEMA app_data, app_api TO demo_user;
GRANT EXECUTE ON FUNCTION app_data.get_customer_name(INTEGER) TO demo_user;
GRANT EXECUTE ON FUNCTION app_api.get_customer_name(INTEGER) TO demo_user;

-------------------------------------------------------------
-- 4. search_path chooses which function runs
--    app_api comes first, so its version is resolved.
-------------------------------------------------------------

SET search_path TO app_api, app_data, public;

SET ROLE demo_user;

SELECT get_customer_name(1) AS result_with_app_api_first;

RESET ROLE;

-------------------------------------------------------------
-- 5. Change search_path order
--    app_data comes first, so a different function runs.
-------------------------------------------------------------

SET search_path TO app_data, app_api, public;

SET ROLE demo_user;

SELECT get_customer_name(1) AS result_with_app_data_first;

RESET ROLE;

-------------------------------------------------------------
-- 6. Best practice: schema-qualify the function you intend to call
-------------------------------------------------------------

SET ROLE demo_user;

SELECT app_api.get_customer_name(1)  AS api_call;
SELECT app_data.get_customer_name(1) AS data_call;

RESET ROLE;
