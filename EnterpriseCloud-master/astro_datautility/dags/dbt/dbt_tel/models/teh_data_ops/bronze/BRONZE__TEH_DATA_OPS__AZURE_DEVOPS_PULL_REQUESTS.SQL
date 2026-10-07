{{ config(
    alias='AZURE_DEVOPS_PULL_REQUESTS',
    materialized='tel_incremental',
    incremental_strategy='merge',
    unique_key = ['PULLREQUESTID'],
) }}


with source_data as (
    SELECT
        _FILENAME as _FILENAME,
        _FILEDATE as _FILEDATE,
        JSONFIELD:repository as REPOSITORY,
        JSONFIELD:pullRequestId as PULLREQUESTID,
        JSONFIELD:codeReviewId as CODEREVIEWID,
        JSONFIELD:status as STATUS,
        JSONFIELD:createdBy as CREATEDBY,
        JSONFIELD:creationDate as CREATIONDATE,
        JSONFIELD:closedDate as CLOSEDDATE,
        JSONFIELD:title as TITLE,
        JSONFIELD:description as DESCRIPTION,
        JSONFIELD:sourceRefName as SOURCEREFNAME,
        JSONFIELD:targetRefName as TARGETREFNAME,
        JSONFIELD:mergeStatus as MERGESTATUS,
        JSONFIELD:isDraft as ISDRAFT,
        JSONFIELD:mergeId as MERGEID,
        JSONFIELD:lastMergeSourceCommit as LASTMERGESOURCECOMMIT,
        JSONFIELD:lastMergeTargetCommit as LASTMERGETARGETCOMMIT,
        JSONFIELD:lastMergeCommit as LASTMERGECOMMIT,
        JSONFIELD:reviewers as REVIEWERS,
        JSONFIELD:url as URL,
        JSONFIELD:_links as _LINKS,
        JSONFIELD:completionOptions as COMPLETIONOPTIONS,
        JSONFIELD:supportsIterations as SUPPORTSITERATIONS,
        JSONFIELD:completionQueueTime as COMPLETIONQUEUETIME,
        JSONFIELD:closedBy as CLOSEDBY,
        JSONFIELD:artifactId as ARTIFACTID,
    FROM {{ source("AZURE_DEVOPS", "PULL_REQUESTS") }}
    WHERE _Filedate>(SELECT COALESCE(MAX(_Filedate),'1900-01-01') from {{this}})
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY PULLREQUESTID ORDER BY _FILEDATE DESC )) = 1  
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        sha2('hash_me') as _ROW_HASH,
        *,
    from source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        REPOSITORY::object as REPOSITORY,
        PULLREQUESTID::int as PULLREQUESTID,
        CODEREVIEWID::int as CODEREVIEWID,
        STATUS::string as STATUS,
        CREATEDBY::object as CREATEDBY,
        CREATIONDATE::string as CREATIONDATE,
        CLOSEDDATE::string as CLOSEDDATE,
        TITLE::string as TITLE,
        DESCRIPTION::string as DESCRIPTION,
        SOURCEREFNAME::string as SOURCEREFNAME,
        TARGETREFNAME::string as TARGETREFNAME,
        MERGESTATUS::string as MERGESTATUS,
        ISDRAFT::boolean as ISDRAFT,
        MERGEID::string as MERGEID,
        LASTMERGESOURCECOMMIT::object as LASTMERGESOURCECOMMIT,
        LASTMERGETARGETCOMMIT::object as LASTMERGETARGETCOMMIT,
        LASTMERGECOMMIT::object as LASTMERGECOMMIT,
        REVIEWERS::array as REVIEWERS,
        URL::string as URL,
        _LINKS::object as _LINKS,
        COMPLETIONOPTIONS::object as COMPLETIONOPTIONS,
        SUPPORTSITERATIONS::boolean as SUPPORTSITERATIONS,
        COMPLETIONQUEUETIME::string as COMPLETIONQUEUETIME,
        CLOSEDBY::object as CLOSEDBY,
        ARTIFACTID::string as ARTIFACTID,
    from transform_data
)

select * from type_data