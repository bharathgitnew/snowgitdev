{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KNOWBE4_REPORTING_GROUPS'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:current_risk_score::string as CURRENT_RISK_SCORE,
        jsonfield:group_type::string as GROUP_TYPE,
        jsonfield:id::string as ID,
        jsonfield:member_count::string as MEMBER_COUNT,
        jsonfield:name::string as NAME,
        jsonfield:status::string as STATUS
    FROM {{ source("KNOWBE4", "REPORTING_GROUPS") }}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:id,
                                    JSONFIELD:group_type,
                                    JSONFIELD:NAME,
                                    JSONFIELD:STATUS,
                                    JSONFIELD:member_count,
                                    JSONFIELD:current_risk_score
                                ORDER BY _filedate DESC) = 1)
)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ID,
        NAME,
        STATUS,
        GROUP_TYPE,
        CURRENT_RISK_SCORE
    FROM source_data
)
,type_data as 
(
    select
        _FILENAME,
        _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ID,
        NAME,
        STATUS,
        GROUP_TYPE,
        CURRENT_RISK_SCORE
    from transform_data
    )
select * from type_data