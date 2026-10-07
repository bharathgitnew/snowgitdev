{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KNOWBE4_REPORTING_PHISHING_CAMPAIGNS'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:campaign_id::string as CAMPAIGN_ID,
        jsonfield:create_date::string as CREATE_DATE,
        jsonfield:difficulty_filter::string as DIFFICULTY_FILTER,
        jsonfield:frequency::string as FREQUENCY,
        groups_data.value:group_id::string as GROUP_ID,
        groups_data.value:name::string as GROUP_NAME,        
        jsonfield:hidden::string as HIDDEN,
        jsonfield:last_phish_prone_percentage::string as LAST_PHISH_PRONE_PERCENTAGE,
        jsonfield:last_run::string as LAST_RUN,
        jsonfield:name::string as NAME,
        psts_data.value:phish_prone_percentage::string as PST_PHISH_PRONE_PERCENTAGE,
        psts_data.value:pst_id::string as PST_ID,
        psts_data.value:start_date::string as PST_START_DATE,
        psts_data.value:status::string as PST_STATUS,
        psts_data.value:users_count::string as PST_USER_COUNT,
        jsonfield:psts_count::string as PSTS_COUNT,
        jsonfield:send_duration::string as SEND_DURATION,
        jsonfield:status::string as STATUS,      
        jsonfield:track_duration::string as TRACK_DURATION 
    FROM {{ source("KNOWBE4", "REPORTING_PHISHING_CAMPAIGNS") }} Campaigns,
        LATERAL FLATTEN (input => Campaigns.jsonfield:groups) groups_data,
        LATERAL FLATTEN (input => Campaigns.jsonfield:psts) psts_data
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:campaign_id,
                                    JSONFIELD:create_date,
                                    JSONFIELD:campaign_id,
                                    JSONFIELD:name,
                                    JSONFIELD:phish_prone_percentage,
                                    groups_data.value:group_id,
                                    groups_data.value:name,
                                    JSONFIELD:last_run,
                                    psts_data.value:PST_ID,
                                    psts_data.value:phish_prone_percentage
                                ORDER BY _filedate DESC) = 1)
)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CAMPAIGN_ID,
        NAME,
        CREATE_DATE,
        DIFFICULTY_FILTER,
        FREQUENCY,
        HIDDEN,
        GROUP_ID,
        GROUP_NAME,
        LAST_RUN,
        LAST_PHISH_PRONE_PERCENTAGE,
        STATUS,
        SEND_DURATION,
        TRACK_DURATION,
        PST_ID,
        PST_START_DATE,
        PST_STATUS,
        PST_PHISH_PRONE_PERCENTAGE,
        PSTS_COUNT
    FROM source_data
)
,type_data as 
(
    select
        _FILENAME,
        _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAMPAIGN_ID,
        NAME,
        CREATE_DATE,
        DIFFICULTY_FILTER,
        FREQUENCY,
        HIDDEN,
        GROUP_ID,
        GROUP_NAME,
        LAST_RUN,
        LAST_PHISH_PRONE_PERCENTAGE,
        STATUS,
        SEND_DURATION,
        TRACK_DURATION,
        PST_ID,
        PST_START_DATE,
        PST_STATUS,
        PST_PHISH_PRONE_PERCENTAGE,
        PSTS_COUNT    
    from transform_data
    )
select * from type_data