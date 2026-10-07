{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='CAMPAIGN'
) }}

with source_data as
(
    SELECT 
        EMPLOYEE_ID,
        NAME,
        COURSE_NUMBER,
        COURSE_TITLE,
        ASSIGNED_DATE,
        DUE_DATE,
        COMPLETION_DATE,
        EXPIRATION_DATE,
        REQUIREMENT_STATUS,
        CAMPAIGN_START_DATE,
        CAMPAIGN_END_DATE,
        WAIVED,
        TOPIC
    from {{ ref('BRONZE__TEH_HUMAN_RESOURCES__FILE_CAMPAIGN') }} 
),

transform_data as 
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        EMPLOYEE_ID,
        NAME,
        COURSE_NUMBER,
        COURSE_TITLE,
        ASSIGNED_DATE,
        DUE_DATE,
        COMPLETION_DATE,
        EXPIRATION_DATE,
        REQUIREMENT_STATUS,
        CAMPAIGN_START_DATE,
        CAMPAIGN_END_DATE,
        WAIVED,
        TOPIC
FROM source_data 
),
type_data as 
(
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        EMPLOYEE_ID,
        NAME,
        COURSE_NUMBER,
        COURSE_TITLE,
        ASSIGNED_DATE,
        DUE_DATE,
        COMPLETION_DATE,
        EXPIRATION_DATE,
        REQUIREMENT_STATUS,
        CAMPAIGN_START_DATE,
        CAMPAIGN_END_DATE,
        WAIVED,
        TOPIC
FROM transform_data 
)
select * from type_data