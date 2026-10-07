{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='MYSKILLS_COMPANY',
    unique_key = ['CompanyId']
) }}

with source_data as
(   SELECT
        KSMN_TABLE.TELKAICD AS CompanyId,
        KSMN_TABLE.SEISNE AS Name,
        KSMN_TABLE.SSRYNE AS ShortName,
        KSMN_TABLE.KUNICD AS CountryCode
        FROM {{ ref('BRONZE__TEA_STRATEGIC_BUSINESS_OPERATIONS__MYSKILLS_KSMN_TABLE') }} KSMN_TABLE    
    )
,transform_data as
(
    SELECT
        CompanyId,
        Name,
        ShortName,
        CountryCode,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH -- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        COMPANYID as COMPANYID,
        NAME as NAME,
        SHORTNAME as SHORTNAME,
        COUNTRYCODE as COUNTRYCODE
    from transform_data
    )
select * from type_data