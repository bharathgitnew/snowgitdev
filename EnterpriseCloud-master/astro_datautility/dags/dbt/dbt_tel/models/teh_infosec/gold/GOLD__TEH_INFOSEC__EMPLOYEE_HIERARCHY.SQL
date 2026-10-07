{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='EMPLOYEE_HIERARCHY',
    	  transient=false	
) }} 

WITH SOURCE_DATA AS 
(
    SELECT 
        employeeID as EMPLOYEE_ID,
        firstname as EMPLOYEE_FIRSTNAME,
        lastname as EMPLOYEE_LASTNAME,
        email as EMPLOYEE_EMAIL,
        SUPERVISORID AS SUPERVISOR_ID, 
        JOBTITLE AS EMPLOYEE_JOB_TITLE,
        CONNECT_BY_ROOT employeeid AS VP_EMPLOYEE_ID,
        CONNECT_BY_ROOT JOBTITLE AS VP_JOB_TITLE,
        CONNECT_BY_ROOT firstname as VP_FIRST_NAME,
        CONNECT_BY_ROOT lastname as VP_LAST_NAME,
        CONNECT_BY_ROOT email as VP_EMAIL
    FROM {{ ref('SILVER__TEH_INFOSEC__EMPLOYEE') }} employees
    WHERE ACTIVE='true'
        START WITH JOBTITLE ilike '%VP%' OR JOBTITLE ilike '%President%' OR JOBTITLE ilike '%Deputy%' OR JOBTITLE ilike '%Fellow%' OR JOBTITLE ilike '%Collaborative%'
        OR JOBTITLE ilike '%Project Leader (Dept)%' OR JOBTITLE ilike '%Sr Dir, Technology%' OR JOBTITLE ilike '%Dir, Stategic Planning%'
        OR JOBTITLE ilike '%Sr Dir, Strategic Planning%' OR JOBTITLE ilike '%Mgr, Venture Capital Programs%'
        CONNECT BY
        SUPERVISORID = PRIOR employeeID
    ORDER BY employeeID
),
TRANSFORM_DATA AS
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('HASH_ME') AS _ROW_HASH,
        EMPLOYEE_ID,
        EMPLOYEE_EMAIL,
        concat(EMPLOYEE_FIRSTNAME,' ',EMPLOYEE_LASTNAME) as EMPLOYEE_FULL_NAME,
        EMPLOYEE_JOB_TITLE,
        VP_EMPLOYEE_ID,
        VP_EMAIL,
        concat(VP_FIRST_NAME,' ',VP_LAST_NAME) as VP_FULL_NAME,
        VP_JOB_TITLE
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        EMPLOYEE_ID,
        EMPLOYEE_EMAIL,
        EMPLOYEE_FULL_NAME,
        EMPLOYEE_JOB_TITLE,
        VP_EMPLOYEE_ID,
        VP_EMAIL,
        VP_FULL_NAME,
        VP_JOB_TITLE
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA