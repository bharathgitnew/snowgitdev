{{ config(
    	  materialized='incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='EMPLOYEE_HIERARCHY_IN_LEVELS',
    	  transient=false
) }}

WITH RECURSIVE EmployeeHierarchy AS (
    SELECT
        EMPLOYEEID,
        concat(firstname,' ',lastname) as employee_name,
        jobtitle as JOB_TITLE,
        email as EMAIL_ADDRESS,
        SUPERVISORID,
        1 AS level, -- Level in the hierarchy
        CAST(concat(firstname,' ',lastname) AS VARCHAR(200)) AS hierarchy_path,-- Path from the root
        jobtitle as hierarchy_path_job_titles-- Path from the root
    FROM
        {{ ref('COMMON__TEACOMMON__EMPLOYEE') }}
    WHERE
        supervisor_name IS NULL -- Starts with the top-level employee(s)
        and ACTIVE='true' and status_code='A'

    UNION ALL
    -- Recursive Clause: Joins back to the CTE to find subordinates
    SELECT
        e.EMPLOYEEID,
        concat(e.firstname,' ',e.lastname) as employee_name,
        jobtitle as JOB_TITLE,
        email as EMAIL_ADDRESS,
        e.SUPERVISORID,
        --e.jobtitle as SUP_JOB_TITLE,
        eh.level + 1 AS level,
        eh.hierarchy_path || ' -> ' || concat(e.firstname,' ',e.lastname) AS hierarchy_path,
        eh.hierarchy_path_job_titles || ' -> ' || e.jobtitle AS hierarchy_path_job_titles
    FROM
        {{ ref('COMMON__TEACOMMON__EMPLOYEE') }}  AS e
    JOIN
        EmployeeHierarchy AS eh ON e.SUPERVISORID = eh.EMPLOYEEID
    where e.ACTIVE='true' and e.status_code='A'
),
SOURCE_DATA AS
(
    SELECT
        EMPLOYEEID,
        employee_name,
        JOB_TITLE,
        EMAIL_ADDRESS,
        SUPERVISORID,
        level,
        hierarchy_path,
        split_part(hierarchy_path,' -> ',1) Level_1,
        split_part(hierarchy_path_job_titles,' -> ',1) Level_1_JOB_TITLE,
        split_part(hierarchy_path,' -> ',2) Level_2,
        split_part(hierarchy_path_job_titles,' -> ',2) Level_2_JOB_TITLE,
        split_part(hierarchy_path,' -> ',3) Level_3,
        split_part(hierarchy_path_job_titles,' -> ',3) Level_3_JOB_TITLE,
        split_part(hierarchy_path,' -> ',4) Level_4,
        split_part(hierarchy_path_job_titles,' -> ',4) Level_4_JOB_TITLE,
        split_part(hierarchy_path,' -> ',5) Level_5,
        split_part(hierarchy_path_job_titles,' -> ',5) Level_5_JOB_TITLE,
        split_part(hierarchy_path,' -> ',6) Level_6,
        split_part(hierarchy_path_job_titles,' -> ',6) Level_6_JOB_TITLE,
        split_part(hierarchy_path,' -> ',7) Level_7,
        split_part(hierarchy_path_job_titles,' -> ',7) Level_7_JOB_TITLE,
        split_part(hierarchy_path,' -> ',8) Level_8,
        split_part(hierarchy_path_job_titles,' -> ',8) Level_8_JOB_TITLE,
        split_part(hierarchy_path,' -> ',9) Level_9,
        split_part(hierarchy_path_job_titles,' -> ',9) Level_9_JOB_TITLE,
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
        JOB_TITLE,
        EMAIL_ADDRESS,
        SUPERVISORID,
        LEVEL,
        HIERARCHY_PATH,
        LEVEL_1,
        LEVEL_1_JOB_TITLE,
        LEVEL_2,
        LEVEL_2_JOB_TITLE,
        LEVEL_3,
        LEVEL_3_JOB_TITLE,
        LEVEL_4,
        LEVEL_4_JOB_TITLE,
        LEVEL_5,
        LEVEL_5_JOB_TITLE,
        LEVEL_6,
        LEVEL_6_JOB_TITLE,
        LEVEL_7,
        LEVEL_7_JOB_TITLE,
        LEVEL_8,
        LEVEL_8_JOB_TITLE,
        LEVEL_9,
        LEVEL_9_JOB_TITLE
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        EMPLOYEE_ID,
        EMPLOYEE_FULL_NAME,
        JOB_TITLE,
        EMAIL_ADDRESS,
        SUPERVISORID,
        LEVEL,
        HIERARCHY_PATH,
        LEVEL_1,
        LEVEL_1_JOB_TITLE,
        LEVEL_2,
        LEVEL_2_JOB_TITLE,
        LEVEL_3,
        LEVEL_3_JOB_TITLE,
        LEVEL_4,
        LEVEL_4_JOB_TITLE,
        LEVEL_5,
        LEVEL_5_JOB_TITLE,
        LEVEL_6,
        LEVEL_6_JOB_TITLE,
        LEVEL_7,
        LEVEL_7_JOB_TITLE,
        LEVEL_8,
        LEVEL_8_JOB_TITLE,
        LEVEL_9,
        LEVEL_9_JOB_TITLE
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA