{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Company',
    unique_key = ['CompanyId']
) }}

with source_data as
(   SELECT
        KSMN_TABLE.TELKAICD AS CompanyId,
        KSMN_TABLE.SEISNE AS Name,
        KSMN_TABLE.SSRYNE AS ShortName,
        KSMN_TABLE.KUNICD AS CountryCode
        FROM {{ ref('ODS__MYSKILLS__KSMN_TABLE') }} KSMN_TABLE    
    )
,transform_data as
(
    SELECT 
        CompanyId,
        Name,
        ShortName,
        CountryCode,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        cast(COMPANYID as VARCHAR(16777216)) as COMPANYID,
        cast(NAME as VARCHAR(16777216)) as NAME,
        cast(SHORTNAME as VARCHAR(16777216)) as SHORTNAME,
        cast(COUNTRYCODE as VARCHAR(16777216)) as COUNTRYCODE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data