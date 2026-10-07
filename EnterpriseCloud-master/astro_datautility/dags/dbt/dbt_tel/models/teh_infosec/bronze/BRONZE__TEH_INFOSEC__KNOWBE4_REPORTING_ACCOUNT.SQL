{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='KNOWBE4_REPORTING_ACCOUNT'
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        jsonfield:name::string as ACCOUNT_NAME,
        jsonfield:number_of_seats::string as NUMBER_OF_SEATS,
        jsonfield:subscription_end_date::string as SUBSCRIPTION_END_DATE,
        jsonfield:subscription_level::string as SUBSCRIPTION_LEVEL,
        jsonfield:type::string as ACCOUNT_TYPE,
        jsonfield:domains::string as ACCOUNT_DOMAINS,
        jsonfield:current_risk_score::string as CURRENT_RISK_SCORE,
        admin_data.value:email::string as EMAIL,
        admin_data.value:first_name::string as FIRST_NAME,
        admin_data.value:id::string as ID,
        admin_data.value:last_name::string as LAST_NAME
    FROM {{ source("KNOWBE4", "REPORTING_ACCOUNT") }} Account,
        LATERAL FLATTEN (input => account.jsonfield:admins) admin_data
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:name,
                                    admin_data.value:first_name,
                                    admin_data.value:id,
                                    admin_data.value:last_name
                                ORDER BY _filedate DESC) = 1)
)

,transform_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        ACCOUNT_NAME,
        NUMBER_OF_SEATS,
        SUBSCRIPTION_END_DATE,
        SUBSCRIPTION_LEVEL,
        ACCOUNT_TYPE,
        ACCOUNT_DOMAINS,
        CURRENT_RISK_SCORE,
        EMAIL,
        FIRST_NAME,
        ID,
        LAST_NAME
    FROM source_data
)
,type_data as 
(
    select
        _FILENAME,
        _FILEDATE,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        ACCOUNT_NAME,
        NUMBER_OF_SEATS,
        CAST(SUBSCRIPTION_END_DATE AS DATE) AS SUBSCRIPTION_END_DATE,
        SUBSCRIPTION_LEVEL,
        ACCOUNT_TYPE,
        ACCOUNT_DOMAINS,
        CAST(CURRENT_RISK_SCORE AS NUMBER(38,3)) AS CURRENT_RISK_SCORE,
        EMAIL,
        FIRST_NAME,
        ID,
        LAST_NAME        
    from transform_data
    )
select * from type_data