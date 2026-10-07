-- copied from COMMON__MYSKILLS__COMPANY
{{ config(
    alias = 'MYSKILLS_COMPANY',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['CompanyId'],
) }}

with source_data as (
    SELECT
        KSMN_TABLE.TELKAICD AS CompanyId,
        KSMN_TABLE.SEISNE AS Name,
        KSMN_TABLE.SSRYNE AS ShortName,
        KSMN_TABLE.KUNICD AS CountryCode
    FROM {{ ref('BRONZE__TEH_DATA_OPS__MYSKILLS_KSMN_TABLE') }} KSMN_TABLE    
)

,transform_data as (
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        CompanyId,
        Name,
        ShortName,
        CountryCode,
    FROM source_data
)

,type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _REFRESHDATE,
        COMPANYID,
        NAME,
        SHORTNAME,
        COUNTRYCODE,
    from transform_data
)

select * from type_data