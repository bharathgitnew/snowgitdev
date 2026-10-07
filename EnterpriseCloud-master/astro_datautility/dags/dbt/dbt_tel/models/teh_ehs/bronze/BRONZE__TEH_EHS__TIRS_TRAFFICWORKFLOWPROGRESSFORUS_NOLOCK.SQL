{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TIRS_TRAFFICWORKFLOWPROGRESSFORUS_NOLOCK'
) }}


WITH SOURCE_DATA AS 
(
    SELECT
        _FILEDATE,
        _FILENAME,
        JSONFIELD:"TIRSNo"::STRING as "TIRSNo",
        JSONFIELD:"TaskName"::STRING as "TaskName",
        JSONFIELD:"RecipientTo"::STRING as "RecipientTo",
        JSONFIELD:"RecipientCc"::STRING as "RecipientCc",
        JSONFIELD:"PerformedBy"::STRING as "PerformedBy",
        JSONFIELD:"ExecutionDate"::STRING as "ExecutionDate",
        JSONFIELD:"CompanyId"::STRING as "CompanyId"
    FROM  {{ source("TIRS", "TRAFFICWORKFLOWPROGRESSFORUS_NOLOCK") }} 
    WHERE _FILEDATE = (SELECT MAX(_FILEDATE) FROM {{ source('TIRS', 'TRAFFICWORKFLOWPROGRESSFORUS_NOLOCK') }})
)

,TRANSFORM_DATA AS 
(
    SELECT
        _FILEDATE as _FILEDATE,
        _FILENAME as _FILENAME,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        "TIRSNo" as TIRS_NO,
        "TaskName" as TASK_NAME,
        "RecipientTo" as RECIPIENT_TO,
        "RecipientCc" as RECIPIENT_CC,
        "PerformedBy" as PERFORMED_BY,
        "ExecutionDate" as EXECUTION_DATE,
        "CompanyId" as COMPANY_ID
    FROM source_data 
),
TYPE_DATA AS 
(
    SELECT
        _FILEDATE,
        _FILENAME,
        AUDIT_LOG_ID,
        _ROW_HASH,
        TIRS_NO,
        TASK_NAME,
        RECIPIENT_TO,
        RECIPIENT_CC,
        PERFORMED_BY,
        EXECUTION_DATE,
        COMPANY_ID
    FROM TRANSFORM_DATA 
)
SELECT * FROM TYPE_DATA