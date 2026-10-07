{{ config(
    alias='FAB21_EHS_AUDIT_USER_DETAILS',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['_FILENAME', 'AUDIT_DATE', 'REGION']
) }}
with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        HEADER1,
        HEADER2,
        HEADER3,
        HEADER5,
        split_part(_filename,'_',1) AS REGION
    from {{ ref('BRONZE__TEH_EHS__FILE_FAB21_EHS_AUDIT_ETC') }}
    where HEADER1 IS NOT NULL
        or HEADER3 IS NOT NULL
    -- {% if is_tel_incremental() %}
    --     and _FILEDATE > (select max(_FILEDATE) from {{ this }})
    -- {% endif %}
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY _FILENAME, HEADER1, HEADER2
        ORDER BY _FILEDATE DESC
    ) = 1
),
aggregated as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        REGION,
        MAX(CASE
            WHEN HEADER1::STRING = 'Tool ID: '
            THEN HEADER2::STRING
        END) AS TOOL_ID,
        MAX(CASE
            WHEN HEADER1::STRING = 'Tool ID: '
            THEN HEADER5::STRING
        END) AS FAB,
        MAX(CASE
            WHEN HEADER1::STRING = 'BU: '
            THEN HEADER2::STRING
        END) AS BU,
        MAX(CASE
            WHEN HEADER1::STRING = 'BU: '
            THEN HEADER5::STRING
        END) AS SIDE,
        MAX(CASE
            WHEN HEADER1::STRING = 'Work Task: '
            THEN HEADER2::STRING
        END) AS WORK_TASK,
        MAX(CASE
            WHEN HEADER1::STRING = 'Work Task: '
            THEN HEADER5::STRING
        END) AS LEVEL,
        MAX(CASE
            WHEN HEADER1::STRING = 'High Risk Work:  Y  /  N'
            THEN HEADER2::STRING
        END) AS HIGH_RISK_WORK,
        MAX(CASE
            WHEN HEADER3::STRING = 'Date'
            THEN TRY_TO_DATE(HEADER5::STRING)
        END) AS AUDIT_DATE,
        MAX(CASE
            WHEN HEADER1::STRING = 'Sustaining/Start-up'
            THEN HEADER2::STRING
        END) AS SUSTAINING_STARTUP,
        MAX(CASE
            WHEN HEADER3::STRING = 'Auditor'
            THEN HEADER5::STRING
        END) AS AUDITOR
    from source_data
    group by _FILENAME, _FILEDATE, _UPLOADDATE, REGION
),
transform_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        '{{ invocation_id }}'  AS _AUDIT_LOG_ID,
       SHA2('hash_me') as _ROW_HASH,
        REGION,
        TOOL_ID,
        FAB,
        BU,
        SIDE,
        WORK_TASK,
        LEVEL,
        HIGH_RISK_WORK,
        AUDIT_DATE,
        SUSTAINING_STARTUP,
        AUDITOR
    from aggregated
    -- where TOOL_ID IS NOT NULL
),
type_data as (
    select
        CAST(_FILENAME      AS VARCHAR)             AS _FILENAME,
        CAST(_FILEDATE      AS TIMESTAMP_NTZ(9))    AS _FILEDATE,
        CAST(_UPLOADDATE    AS TIMESTAMP_NTZ(9))    AS _UPLOADDATE,
        CAST(_AUDIT_LOG_ID  AS VARCHAR(128))        AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH      AS VARCHAR(128))        AS _ROW_HASH,
        CAST(REGION         AS VARCHAR)             AS REGION,
        CAST(TOOL_ID        AS VARCHAR)             AS TOOL_ID,
        CAST(FAB            AS VARCHAR)             AS FAB,
        CAST(BU             AS VARCHAR)             AS BU,
        CAST(SIDE           AS VARCHAR)             AS SIDE,
        CAST(WORK_TASK      AS VARCHAR)             AS WORK_TASK,
        CAST(LEVEL          AS VARCHAR)             AS LEVEL,
        CAST(HIGH_RISK_WORK AS VARCHAR)             AS HIGH_RISK_WORK,
        CAST(AUDIT_DATE     AS DATE)                AS AUDIT_DATE,
        CAST(SUSTAINING_STARTUP AS VARCHAR)         AS SUSTAINING_STARTUP,
        CAST(AUDITOR        AS VARCHAR)             AS AUDITOR
    from transform_data
)
select * from type_data