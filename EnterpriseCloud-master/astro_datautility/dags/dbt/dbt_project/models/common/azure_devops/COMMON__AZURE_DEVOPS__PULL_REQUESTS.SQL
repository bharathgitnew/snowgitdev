{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='PULL_REQUESTS'
) }}


with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        PULL_REQUEST_ID,
        TITLE,
        DESCRIPTION,
        MERGE_COMMIT_MESSAGE,
        CREATOR_USER_NAME,
        CREATION_DATE,
        REVIEWER_USER_NAME,
        APPROVED_FLAG,
        STATUS,
        CLOSED_DATE
    FROM {{ ref('ODS__AZURE_DEVOPS__PULL_REQUESTS') }}
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _FILENAME,
        _FILEDATE,
        PULL_REQUEST_ID,
        TITLE,
        DESCRIPTION,
        MERGE_COMMIT_MESSAGE,
        CREATOR_USER_NAME,
        CREATION_DATE,
        REVIEWER_USER_NAME,
        APPROVED_FLAG,
        STATUS,
        CLOSED_DATE
    FROM source_data
)
,type_data AS
(
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _Filename AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        PULL_REQUEST_ID,
        TITLE,
        DESCRIPTION,
        MERGE_COMMIT_MESSAGE,
        CREATOR_USER_NAME,
        CAST(CREATION_DATE AS TIMESTAMP_NTZ(9)) AS CREATION_DATE,
        REVIEWER_USER_NAME,
        APPROVED_FLAG,
        STATUS,
        CAST(CLOSED_DATE AS TIMESTAMP_NTZ(9)) AS CLOSED_DATE
    FROM transform_data
)
select
    *
from type_data