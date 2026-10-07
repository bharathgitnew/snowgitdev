{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KNOWBE4_REPORTING_PHISHING_SECURITY_TESTS_RECIPIENTS'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:delivered_at::string as DELIVERED_AT,
        jsonfield:opened_at::string as OPENED_AT,
        jsonfield:pst_id::string as PST_ID,
        jsonfield:recipient_id::string as RECIPIENT_ID,
        jsonfield:reported_at::string as REPORTED_AT,
        jsonfield:scheduled_at::string as SCHEDULED_AT,
        jsonfield:"template.difficulty"::string as TEMPLATE_DIFFICULTY,
        jsonfield:"template.id"::string as TEMPLATE_ID,
        jsonfield:"template.name"::string as TEMPLATE_NAME,
        jsonfield:"template.type"::string as TEMPLATE_TYPE,
        jsonfield:"user.email"::string as USER_EMAIL,
        jsonfield:"user.first_name"::string as USER_FIRST_NAME,
        jsonfield:"user.id"::string as USER_ID,
        jsonfield:"user.last_name"::string as USER_LAST_NAME,
        jsonfield:"user.provisioning_guid"::string as USER_PROVISIONING_GUID,
        jsonfield:browser::string as BROWSER,
        jsonfield:browser_version::string as BROWSER_VERSION,
        jsonfield:clicked_at::string as CLICKED_AT,
        jsonfield:ip::string as IP,
        jsonfield:ip_location::string as IP_LOCATION,
        jsonfield:os::string as OPERATING_SYSTEM
    FROM {{ source("KNOWBE4", "REPORTING_PHISHING_SECURITY_TESTS_RECIPIENTS") }}
    WHERE JSONFIELD not like '%Resource not found%'
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:pst_id,
                                    JSONFIELD:recipient_id,
                                    JSONFIELD:"user.id",
                                    JSONFIELD:"user.first_name",
                                    JSONFIELD:"user.last_name",
                                    JSONFIELD:"user.provisioning_guid",
                                    JSONFIELD:"user.email",
                                    JSONFIELD:"template.id",
                                    JSONFIELD:"template.name",
                                    JSONFIELD:"template.type",
                                    JSONFIELD:scheduled_at                               
                                ORDER BY _filedate DESC) = 1)
)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        PST_ID,
        RECIPIENT_ID,
        TEMPLATE_ID,
        TEMPLATE_NAME,
        TEMPLATE_TYPE,
        TEMPLATE_DIFFICULTY,
        SCHEDULED_AT,
        USER_PROVISIONING_GUID,
        USER_ID,
        USER_FIRST_NAME,
        USER_LAST_NAME,
        USER_EMAIL,
        DELIVERED_AT,
        OPENED_AT,
        REPORTED_AT,
        BROWSER,
        BROWSER_VERSION,
        CLICKED_AT,
        IP,
        IP_LOCATION,
        OPERATING_SYSTEM
    FROM source_data
)
,type_data as 
(
    select
        _FILENAME,
        _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        PST_ID,
        RECIPIENT_ID,
        TEMPLATE_ID,
        TEMPLATE_NAME,
        TEMPLATE_TYPE,
        TEMPLATE_DIFFICULTY,
        SCHEDULED_AT,
        USER_PROVISIONING_GUID,
        USER_ID,
        USER_FIRST_NAME,
        USER_LAST_NAME,
        USER_EMAIL,
        DELIVERED_AT,
        OPENED_AT,
        REPORTED_AT,
        BROWSER,
        BROWSER_VERSION,
        CLICKED_AT,
        IP,
        IP_LOCATION,
        OPERATING_SYSTEM
    from transform_data
    )
select * from type_data