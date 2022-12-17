-- =============================================
-- SaveToDB Framework Extension for PostgreSQL
-- Version 10.6, December 13, 2022
--
-- This script updates SaveToDB Framework 9 to the latest version
--
-- Copyright 2022 Gartle LLC
--
-- License: MIT
-- =============================================

SELECT CASE WHEN 1004 <= cast(substr(handler_code, 1, strpos(handler_code, '.') - 1) AS int) * 100 + cast(substr(handler_code, strpos(handler_code, '.') + 1) AS decimal) THEN 'SaveToDB Framework is up-to-date. Update skipped' ELSE handler_code END AS check_version FROM xls.handlers WHERE table_schema = 'xls' AND table_name = 'savetodb_framework_extension' AND column_name = 'version' AND event_name = 'Information' LIMIT 1;

DELETE FROM xls.handlers WHERE table_schema = 'xls' AND event_name = 'Actions' AND handler_name IN ('xl_actions_set_framework_10_mode', 'xl_actions_set_framework_9_mode');

UPDATE xls.handlers t
SET
    handler_code = s.handler_code
    , target_worksheet = s.target_worksheet
    , menu_order = s.menu_order
    , edit_parameters = s.edit_parameters
FROM
    (
    SELECT
        NULL AS table_schema
        , NULL AS table_name
        , NULL AS column_name
        , NULL AS event_name
        , NULL AS handler_schema
        , NULL AS handler_name
        , NULL AS handler_type
        , NULL AS handler_code
        , NULL AS target_worksheet
        , CAST(NULL AS integer) AS menu_order
        , CAST(NULL AS boolean) AS edit_parameters

    UNION ALL SELECT 'xls', 'savetodb_framework_extension', 'version', 'Information', NULL, NULL, 'ATTRIBUTE', '10.4', NULL, NULL, NULL
    UNION ALL SELECT 'xls', 'users', NULL, 'Actions', 'xls', 'xl_actions_set_extended_role_permissions', 'PROCEDURE', NULL, '_MsgBox', 22, true
    UNION ALL SELECT 'xls', 'users', NULL, 'Actions', 'xls', 'xl_actions_revoke_extended_role_permissions', 'PROCEDURE', NULL, '_MsgBox', 23, true

    ) s
WHERE
    s.table_name IS NOT NULL
    AND t.table_schema = s.table_schema
    AND t.table_name = s.table_name
    AND COALESCE(t.column_name, '') = COALESCE(s.column_name, '')
    AND t.event_name = s.event_name
    AND COALESCE(t.handler_schema, '') = COALESCE(s.handler_schema, '')
    AND COALESCE(t.handler_name, '') = COALESCE(s.handler_name, '')
    AND COALESCE(t.handler_type, '') = COALESCE(s.handler_type, '')
    AND (
    NOT COALESCE(t.handler_code, '') = COALESCE(s.handler_code, '')
    OR NOT COALESCE(t.target_worksheet, '') = COALESCE(s.target_worksheet, '')
    OR NOT COALESCE(t.menu_order, -1) = COALESCE(s.menu_order, -1)
    OR NOT COALESCE(t.edit_parameters, false) = COALESCE(s.edit_parameters, false)
    );

INSERT INTO xls.handlers
    ( table_schema
    , table_name
    , column_name
    , event_name
    , handler_schema
    , handler_name
    , handler_type
    , handler_code
    , target_worksheet
    , menu_order
    , edit_parameters
    )
SELECT
    s.table_schema
    , s.table_name
    , s.column_name
    , s.event_name
    , s.handler_schema
    , s.handler_name
    , s.handler_type
    , s.handler_code
    , s.target_worksheet
    , s.menu_order
    , s.edit_parameters
FROM
    (
    SELECT
        NULL AS table_schema
        , NULL AS table_name
        , NULL AS column_name
        , NULL AS event_name
        , NULL AS handler_schema
        , NULL AS handler_name
        , NULL AS handler_type
        , NULL AS handler_code
        , NULL AS target_worksheet
        , CAST(NULL AS integer) AS menu_order
        , CAST(NULL AS boolean) AS edit_parameters

    UNION ALL SELECT 'xls', 'savetodb_framework_extension', 'version', 'Information', NULL, NULL, 'ATTRIBUTE', '10.4', NULL, NULL, NULL
    UNION ALL SELECT 'xls', 'users', NULL, 'Actions', 'xls', 'xl_actions_set_extended_role_permissions', 'PROCEDURE', NULL, '_MsgBox', 22, true
    UNION ALL SELECT 'xls', 'users', NULL, 'Actions', 'xls', 'xl_actions_revoke_extended_role_permissions', 'PROCEDURE', NULL, '_MsgBox', 23, true

    ) s
    LEFT OUTER JOIN xls.handlers t ON
        t.table_schema = s.table_schema
        AND t.table_name = s.table_name
        AND COALESCE(t.column_name, '') = COALESCE(s.column_name, '')
        AND t.event_name = s.event_name
        AND COALESCE(t.handler_schema, '') = COALESCE(s.handler_schema, '')
        AND COALESCE(t.handler_name, '') = COALESCE(s.handler_name, '')
        AND COALESCE(t.handler_type, '') = COALESCE(s.handler_type, '')
WHERE
    t.table_name IS NULL
    AND s.table_name IS NOT NULL;

CREATE OR REPLACE FUNCTION xls.xl_actions_set_extended_role_permissions (
    )
    RETURNS void
    LANGUAGE plpgsql
AS $$
BEGIN

GRANT SELECT ON xls.view_columns        TO xls_users;
GRANT SELECT ON xls.view_formats        TO xls_users;
GRANT SELECT ON xls.view_handlers       TO xls_users;
GRANT SELECT ON xls.view_objects        TO xls_users;
GRANT SELECT ON xls.view_translations   TO xls_users;
GRANT SELECT ON xls.view_workbooks      TO xls_users;
GRANT SELECT ON xls.view_queries        TO xls_users;

REVOKE SELECT ON xls.columns            FROM xls_users;
REVOKE SELECT ON xls.formats            FROM xls_users;
REVOKE SELECT ON xls.handlers           FROM xls_users;
REVOKE SELECT ON xls.objects            FROM xls_users;
REVOKE SELECT ON xls.translations       FROM xls_users;
REVOKE SELECT ON xls.workbooks          FROM xls_users;
REVOKE SELECT ON xls.queries            FROM xls_users;

GRANT EXECUTE ON FUNCTION xls.xl_update_table_format TO xls_formats;

REVOKE SELECT, INSERT, UPDATE, DELETE ON xls.formats FROM xls_formats;

END
$$;

CREATE OR REPLACE FUNCTION xls.xl_actions_revoke_extended_role_permissions (
    )
    RETURNS void
    LANGUAGE plpgsql
AS $$
BEGIN

GRANT SELECT ON xls.columns             TO xls_users;
GRANT SELECT ON xls.formats             TO xls_users;
GRANT SELECT ON xls.handlers            TO xls_users;
GRANT SELECT ON xls.objects             TO xls_users;
GRANT SELECT ON xls.translations        TO xls_users;
GRANT SELECT ON xls.workbooks           TO xls_users;
GRANT SELECT ON xls.queries             TO xls_users;

REVOKE SELECT ON xls.view_columns       FROM xls_users;
REVOKE SELECT ON xls.view_formats       FROM xls_users;
REVOKE SELECT ON xls.view_handlers      FROM xls_users;
REVOKE SELECT ON xls.view_objects       FROM xls_users;
REVOKE SELECT ON xls.view_translations  FROM xls_users;
REVOKE SELECT ON xls.view_workbooks     FROM xls_users;
REVOKE SELECT ON xls.view_queries       FROM xls_users;

REVOKE EXECUTE ON FUNCTION xls.xl_update_table_format FROM xls_formats;

GRANT SELECT, INSERT, UPDATE, DELETE ON xls.formats TO xls_formats;

END
$$;

-- print SaveToDB Framework Extension updated
