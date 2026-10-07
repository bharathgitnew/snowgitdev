{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='GLOBAL_EMPLOYEE_SALES_SUPPORTING',
    transient=false
) }}

WITH
SOURCE_DATA AS (
select
    null            as COST_CENTER,
    null            as SALES_LEADER,
    null            as JOB_FUNCTION,
    case when startswith(ACTIVEDIRECTORYDISPLAYNAME, 'TML PDC') then 'Others'
        else concat(split_part(ACTIVEDIRECTORYDISPLAYNAME, ' ', 1), ' ', split_part(ACTIVEDIRECTORYDISPLAYNAME, ' ', 2))
    end             as JOB_GROUP,
    null            as SALES_ACCOUNT,
    null            as BU,
    null            as ACCOUNT_BU,
    EMPLOYEE_ID,
    FULL_NAME,
    --initcap(FULL_NAME)  as FULLNAME,
    LAST_NAME,
    --initcap(LAST_NAME)  as LASTNAME,
    FULL_NAME       as FULL_NAME_MICROSOFT,
    EMAILADDRESS    as EMAIL,
    JOB_TITLE
    --JOB_FAMILY_GROUPNAME
    FROM {{ ref('GOLD__TEH_EQUIPMENT_SALES__GLOBAL_EMPLOYEE') }}
where IS_IN_TEACOMMON ilike 'No'
and ACTIVEDIRECTORYDISPLAYNAME ilike any ('TEL ATS%', 'TEL AS%', 'TEL CTSPS%', 'TEL TFF%', 'TEL ES%')
and EMPLOYEE_STATUS ilike 'Active'
or
(IS_IN_TEACOMMON ilike 'No'
and startswith(ACTIVEDIRECTORYDISPLAYNAME, 'TML')
and EMPLOYEE_STATUS ilike 'Active'
and FULL_NAME ilike any ('chiba, yusuke')))
,
TRANSFORM_DATA AS (
SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        COST_CENTER,
        SALES_LEADER,
        JOB_FUNCTION,
        JOB_GROUP,
        SALES_ACCOUNT,
        BU,
        ACCOUNT_BU,
        EMPLOYEE_ID,
        FULL_NAME,
        LAST_NAME,
        FULL_NAME_MICROSOFT,
        EMAIL,
        JOB_TITLE
FROM SOURCE_DATA

)

,
TYPE_DATA AS (
select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        COST_CENTER,
        SALES_LEADER,
        JOB_FUNCTION,
        JOB_GROUP,
        SALES_ACCOUNT,
        BU,
        ACCOUNT_BU,
        EMPLOYEE_ID,
        FULL_NAME,
        LAST_NAME,
        FULL_NAME_MICROSOFT,
        EMAIL,
        JOB_TITLE
from transform_data
)
SELECT * FROM TYPE_DATA