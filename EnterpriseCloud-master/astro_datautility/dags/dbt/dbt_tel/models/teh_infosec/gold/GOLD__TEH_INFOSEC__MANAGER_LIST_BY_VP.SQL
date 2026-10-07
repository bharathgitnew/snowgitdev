{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='MANAGER_LIST_BY_VP',
    	  transient=false	
) }} 

WITH SOURCE_DATA AS 
(
    SELECT 
        EMPLOYEE_ID as MANAGER_ID,
        EMPLOYEE_EMAIL as MANAGER_EMAIL,
        EMPLOYEE_FULL_NAME as MANAGER_FULL_NAME,
        EMPLOYEE_JOB_TITLE AS MANAGER_JOB_TITLE,
        VP_EMPLOYEE_ID,
        VP_EMAIL,
        VP_FULL_NAME,
        VP_JOB_TITLE
    FROM {{ ref('GOLD__TEH_INFOSEC__EMPLOYEE_HIERARCHY') }} employees
    WHERE EMPLOYEE_JOB_TITLE iLIKE '%MGR%' OR EMPLOYEE_JOB_TITLE iLIKE '%DIR%'
    ORDER BY VP_EMPLOYEE_ID
),
TRANSFORM_DATA AS
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('HASH_ME') AS _ROW_HASH,
        MANAGER_ID,
        MANAGER_EMAIL,
        MANAGER_FULL_NAME,
        MANAGER_JOB_TITLE,
        VP_EMPLOYEE_ID,
        VP_EMAIL,
        VP_FULL_NAME,
        VP_JOB_TITLE
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        MANAGER_ID,
        MANAGER_EMAIL,
        MANAGER_FULL_NAME,
        MANAGER_JOB_TITLE,
        VP_EMPLOYEE_ID,
        VP_EMAIL,
        VP_FULL_NAME,
        VP_JOB_TITLE,
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA