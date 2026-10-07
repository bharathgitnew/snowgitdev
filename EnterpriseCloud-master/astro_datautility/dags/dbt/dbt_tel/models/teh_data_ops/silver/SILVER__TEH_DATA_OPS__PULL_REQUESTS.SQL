{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='PULL_REQUESTS',
    unique_key = ['PULL_REQUEST_ID']
) }}


with source_data as
(
    SELECT
        _Filedate as _Filedate,
        pullRequestId as PULL_REQUEST_ID,
        title as TITLE,
        description as DESCRIPTION,
        completionOptions:mergeCommitMessage as MERGE_COMMIT_MESSAGE,
        createdBy:displayName as CREATOR_USER_NAME,
        creationDate as CREATION_DATE,
        review.value:displayName as REVIEWER_USER_NAME,
        review.value:hasDeclined as APPROVED_FLAG,
        status as STATUS,
        closedDate as CLOSED_DATE
    FROM {{ ref("BRONZE__TEH_DATA_OPS__AZURE_DEVOPS_PULL_REQUESTS") }}
        ,lateral flatten( input => reviewers ) review
        ,lateral flatten( input => review.value ) review1
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _Filedate AS _FILEDATE,
        PULL_REQUEST_ID::string as PULL_REQUEST_ID,
        TITLE,
        DESCRIPTION,
        MERGE_COMMIT_MESSAGE::string as MERGE_COMMIT_MESSAGE,
        CREATOR_USER_NAME::string as CREATOR_USER_NAME,
        CREATION_DATE,
        REVIEWER_USER_NAME::string as REVIEWER_USER_NAME,
        APPROVED_FLAG::string as APPROVED_FLAG,
        STATUS,
        CLOSED_DATE
    FROM source_data
)
,type_data AS
(
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
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