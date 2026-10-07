{{ config(
    alias='FILE_CAMPAIGN',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['EMPLOYEE_ID', 'COURSE_NUMBER'],
    tags = ['workday'],
) }}

with source_data as (
    select
        _FILENAME, 
        _FILEDATE,
        _UPLOADDATE,
        "EMPLOYEE ID" as EMPLOYEE_ID,
        "NAME" as NAME,
        "COURSE NUMBER" as COURSE_NUMBER,
        "COURSE TITLE" as COURSE_TITLE,
        "ASSIGNED DATE" as ASSIGNED_DATE,
        "DUE DATE" as DUE_DATE,
        "COMPLETION DATE" as COMPLETION_DATE,
        "EXPIRATION DATE" as EXPIRATION_DATE,
        "REQUIREMENT STATUS" as REQUIREMENT_STATUS,
        "CAMPAIGN START DATE" AS CAMPAIGN_START_DATE,
        "CAMPAIGN END DATE" AS CAMPAIGN_END_DATE,
        "MANUALLY WAIVED?" AS WAIVED,
        "LEARNING TOPIC" AS TOPIC
    from {{ source('FILE', 'CAMPAIGN') }}
    qualify row_number() over(partition by EMPLOYEE_ID, COURSE_NUMBER order by _FILEDATE desc, _UPLOADDATE desc) = 1
),

transform_data as (
    select 
        _FILEDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        _UPLOADDATE,
        EMPLOYEE_ID,
        NAME,
        COURSE_NUMBER,
        COURSE_TITLE,
        try_to_timestamp_tz(ASSIGNED_DATE) as ASSIGNED_DATE,
        to_varchar(to_date(try_to_timestamp_tz(DUE_DATE, 'YYYY-MM-DDTZH:TZM')), 'MM/DD/YYYY') as DUE_DATE,
        try_to_timestamp_tz(COMPLETION_DATE) as COMPLETION_DATE,
        to_varchar(to_date(try_to_timestamp_tz(EXPIRATION_DATE, 'YYYY-MM-DDTZH:TZM')), 'MM/DD/YYYY') as EXPIRATION_DATE,
        REQUIREMENT_STATUS,
        to_varchar(to_date(try_to_timestamp_tz(CAMPAIGN_START_DATE, 'YYYY-MM-DDTZH:TZM')), 'MM/DD/YYYY') as CAMPAIGN_START_DATE,
        to_varchar(to_date(try_to_timestamp_tz(CAMPAIGN_END_DATE, 'YYYY-MM-DDTZH:TZM')), 'MM/DD/YYYY') as CAMPAIGN_END_DATE,
        WAIVED,
        TOPIC
    from source_data
),

type_data as (
    select 
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		cast(_FILENAME as varchar(128)) as _FILENAME,
		cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as varchar(128)) as _ROW_HASH,            
        _UPLOADDATE,
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
    from transform_data
)

select * from type_data