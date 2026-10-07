{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='EMPLOYEE_HIERARCHY_IN_LEVELS',
    	  transient=false	
) }} 

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        EMPLOYEEID,
        concat(firstname,' ',lastname) as employee_name,
        SUPERVISORID,
        1 AS level, -- Level in the hierarchy
        CAST(concat(firstname,' ',lastname) AS VARCHAR(200)) AS hierarchy_path -- Path from the root
    FROM
        {{ ref('SILVER__TEH_INFOSEC__EMPLOYEE') }}
    WHERE
        supervisor_name IS NULL -- Starts with the top-level employee(s)
        and ACTIVE='true' and status_code='A'

    UNION ALL
    -- Recursive Clause: Joins back to the CTE to find subordinates
    SELECT
        e.EMPLOYEEID,
        concat(e.firstname,' ',e.lastname) as employee_name,
        e.SUPERVISORID,
        (eh.level + 1) AS level,
        eh.hierarchy_path || ' -> ' || concat(e.firstname,' ',e.lastname) AS hierarchy_path
    FROM
        {{ ref('SILVER__TEH_INFOSEC__EMPLOYEE') }} AS e
    JOIN
        EmployeeHierarchy AS eh ON e.SUPERVISORID = eh.EMPLOYEEID
    where e.ACTIVE='true' and e.status_code='A'
),
SOURCE_DATA AS
(
    SELECT
        EMPLOYEEID,
        employee_name,
        SUPERVISORID,
        level,
        hierarchy_path,
        split_part(hierarchy_path,' -> ',1) Level_1,
        split_part(hierarchy_path,' -> ',2) Level_2,
        split_part(hierarchy_path,' -> ',3) Level_3,
        split_part(hierarchy_path,' -> ',4) Level_4,
        split_part(hierarchy_path,' -> ',5) Level_5,
        split_part(hierarchy_path,' -> ',6) Level_6,
        split_part(hierarchy_path,' -> ',7) Level_7,
        split_part(hierarchy_path,' -> ',8) Level_8,
        split_part(hierarchy_path,' -> ',9) Level_9
    FROM
        EmployeeHierarchy
    ORDER BY
        hierarchy_path
),

TRANSFORM_DATA AS
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('HASH_ME') AS _ROW_HASH,
        EMPLOYEEID AS EMPLOYEE_ID,
        employee_name as EMPLOYEE_FULL_NAME,
        SUPERVISORID,
        LEVEL,
        HIERARCHY_PATH,
        LEVEL_1,
        LEVEL_2,
        LEVEL_3,
        LEVEL_4,
        LEVEL_5,
        LEVEL_6,
        LEVEL_7,
        LEVEL_8,
        LEVEL_9
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        EMPLOYEE_ID,
        EMPLOYEE_FULL_NAME,
        SUPERVISORID,
        LEVEL,
        HIERARCHY_PATH,
        LEVEL_1,
        LEVEL_2,
        LEVEL_3,
        LEVEL_4,
        LEVEL_5,
        LEVEL_6,
        LEVEL_7,
        LEVEL_8,
        LEVEL_9
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA