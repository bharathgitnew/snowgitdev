{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KNOWBE4_REPORTING_USERS'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:aliases::string as ALIASES,
        jsonfield:archived_at::string as ARCHIVED_AT,
        jsonfield:comment::string as COMMENT,
        jsonfield:current_risk_score::string as CURRENT_RISK_SCORE,
        jsonfield:custom_field_1::string as CUSTOM_FIELD1,
        jsonfield:custom_field_2::string as CUSTOM_FIELD2,
        jsonfield:department::string as DEPARTMENT,
        jsonfield:division::string as DIVISION,
        jsonfield:email::string as EMAIL,
        jsonfield:employee_number::string as EMPLOYEE_NUMBER,
        jsonfield:employee_start_date::string as EMPLOYMENT_START_DATE,
        jsonfield:first_name::string as FIRST_NAME,
        jsonfield:groups::string as GROUPS,
        jsonfield:id::string as ID,
        jsonfield:job_title::string as JOB_TITLE,
        jsonfield:joined_on::string as JOINED_ON,
        jsonfield:last_name::string as LAST_NAME,
        jsonfield:location::string as LOCATION,
        jsonfield:manager_email::string as MANAGER_EMAIL,
        jsonfield:manager_name::string as MANAGER_NAME,
        jsonfield:mobile_phone_number::string as MOBILE_PHONE_NUMBER,
        jsonfield:organization::string as ORGANIZATION,
        jsonfield:phish_prone_percentage::string as PHISH_PRONE_PERCENTAGE,
        jsonfield:phone_number::string as PHONE_NUMBER,
        jsonfield:provisioning_guid::string as PROVISIONING_GUID,
        jsonfield:provisioning_managed::string as PROVISIONING_MANAGED,
        jsonfield:status::string as STATUS
    FROM {{ source("KNOWBE4", "REPORTING_USERS") }}
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:id,
                                    JSONFIELD:id,
                                    JSONFIELD:EMPLOYEE_NUMBER,
                                    JSONFIELD:FIRST_NAME,
                                    JSONFIELD:LAST_NAME,
                                    JSONFIELD:DEPARTMENT,
                                    JSONFIELD:DIVISION,
                                    JSONFIELD:JOB_TITLE,
                                    JSONFIELD:MANAGER_NAME,
                                    JSONFIELD:MANAGER_EMAIL,
                                    JSONFIELD:MOBILE_PHONE_NUMBER,
                                    JSONFIELD:CURRENT_RISK_SCORE,
                                    JSONFIELD:PHISH_PRONE_PERCENTAGE
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
        EMPLOYEE_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        JOB_TITLE,
        DEPARTMENT,
        DIVISION,
        EMPLOYMENT_START_DATE,
        ORGANIZATION,
        LOCATION,
        MOBILE_PHONE_NUMBER,
        GROUPS,
        JOINED_ON,
        MANAGER_NAME,
        MANAGER_EMAIL,
        CURRENT_RISK_SCORE,
        COMMENT,
        ARCHIVED_AT,
        ALIASES,
        PHISH_PRONE_PERCENTAGE,
        PHONE_NUMBER,
        PROVISIONING_GUID,
        PROVISIONING_MANAGED,
        STATUS,
        CUSTOM_FIELD1,
        CUSTOM_FIELD2
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
        EMPLOYEE_NUMBER,
        FIRST_NAME,
        LAST_NAME,
        EMAIL,
        JOB_TITLE,
        DEPARTMENT,
        DIVISION,
        EMPLOYMENT_START_DATE,
        ORGANIZATION,
        LOCATION,
        MOBILE_PHONE_NUMBER,
        GROUPS,
        JOINED_ON,
        MANAGER_NAME,
        MANAGER_EMAIL,
        CURRENT_RISK_SCORE,
        COMMENT,
        ARCHIVED_AT,
        ALIASES,
        PHISH_PRONE_PERCENTAGE,
        PHONE_NUMBER,
        PROVISIONING_GUID,
        PROVISIONING_MANAGED,
        STATUS,
        CUSTOM_FIELD1,
        CUSTOM_FIELD2 
    from transform_data
    )
select * from type_data