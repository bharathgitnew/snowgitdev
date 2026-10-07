{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='PULL_REQUESTS',
    unique_key = ['PULL_REQUEST_ID']
) }}


with source_data as
(
    SELECT
        _Filename as _Filename,
        _Filedate as _Filedate,
        JSONFIELD:pullRequestId::STRING as PULL_REQUEST_ID,
        JSONFIELD:title::STRING as TITLE,
        JSONFIELD:description::STRING as DESCRIPTION,
        JSONFIELD:completionOptions.mergeCommitMessage::STRING as MERGE_COMMIT_MESSAGE,
        JSONFIELD:createdBy.displayName::STRING as CREATOR_USER_NAME,
        JSONFIELD:creationDate::STRING as CREATION_DATE,
        review.value:displayName::STRING as REVIEWER_USER_NAME,
        review.value:hasDeclined::STRING as APPROVED_FLAG,
        JSONFIELD:status::STRING as STATUS,
        JSONFIELD:closedDate::STRING as CLOSED_DATE
    FROM {{ source("AZURE_DEVOPS", "PULL_REQUESTS") }}
        ,lateral flatten( input => JsonField:reviewers::VARIANT ) review
        ,lateral flatten( input => review.value::VARIANT ) review1
    WHERE _Filedate>(SELECT COALESCE(MAX(_Filedate),'1900-01-01') from {{this}})
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY PULL_REQUEST_ID ORDER BY REGEXP_REPLACE(_Filedate, '\/Date\\(|\\)\/', '')::TIMESTAMP DESC )) = 1  
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _Filename AS _FILENAME,
        _Filedate AS _FILEDATE,
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
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
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