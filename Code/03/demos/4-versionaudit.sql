/* -------------------------------------------------------------
   Clip 4: Demo – Auditing and Versioning Function Changes
------------------------------------------------------------- */

-------------------------------------------------------------
-- 1. Create a small audit table for function changes
--    This records what changed, when, and by whom.
-------------------------------------------------------------

CREATE TABLE IF NOT EXISTS app_data.function_audit_log (
    audit_id        SERIAL PRIMARY KEY,
    function_name   TEXT        NOT NULL,
    version_label   TEXT        NOT NULL,
    changed_by      TEXT        NOT NULL,
    changed_at      TIMESTAMP   NOT NULL DEFAULT now(),
    change_note     TEXT
);

-------------------------------------------------------------
-- 2. Create version 1 of a function
--    We include a clear version label in the comment.
-------------------------------------------------------------

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

COMMENT ON FUNCTION app_data.get_customer_name(INTEGER)
IS 'Version 1.0 – Initial implementation';

INSERT INTO app_data.function_audit_log (
    function_name,
    version_label,
    changed_by,
    change_note
)
VALUES (
    'app_data.get_customer_name(integer)',
    '1.0',
    current_user,
    'Initial version'
);

-------------------------------------------------------------
-- 3. Create version 2 of the same function
--    Logic change is small but intentional.
-------------------------------------------------------------

CREATE OR REPLACE FUNCTION app_data.get_customer_name(
    p_account_id INTEGER
)
RETURNS TEXT
LANGUAGE sql
AS $$
    SELECT customer_name || ' (verified)'
    FROM app_data.customer_accounts
    WHERE account_id = p_account_id;
$$;

COMMENT ON FUNCTION app_data.get_customer_name(INTEGER)
IS 'Version 2.0 – Appends verification label';

INSERT INTO app_data.function_audit_log (
    function_name,
    version_label,
    changed_by,
    change_note
)
VALUES (
    'app_data.get_customer_name(integer)',
    '2.0',
    current_user,
    'Added verification label to output'
);

-------------------------------------------------------------
-- 4. Call the function to observe the latest behavior
-------------------------------------------------------------

SELECT app_data.get_customer_name(1);

-------------------------------------------------------------
-- 5. Review the audit history
--    This shows how the function evolved over time.
-------------------------------------------------------------

SELECT
    function_name,
    version_label,
    changed_by,
    changed_at,
    change_note
FROM app_data.function_audit_log
ORDER BY changed_at;
