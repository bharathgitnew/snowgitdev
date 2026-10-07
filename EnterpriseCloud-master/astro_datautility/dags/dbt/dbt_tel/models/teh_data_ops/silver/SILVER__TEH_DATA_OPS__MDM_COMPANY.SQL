-- copied from COMMON__MDM__COMPANY
{{ config(
    alias = 'MDM_COMPANY',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['CompanyId'],
) }}

with source_data as (
    SELECT
        SourceCompany.COMPANYCODE AS CompanyId,
        SourceCompany.LONGNAME AS Name,
        SourceCompany.COMPANYNAME AS ShortName,
        SourceCompany.ACTIVEINDICATOR AS ActiveIndicator
    FROM {{ ref('BRONZE__TEH_DATA_OPS__MDM_COMPANY') }} SourceCompany
)

,transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        CompanyId,
        Name,
        ShortName,
        ActiveIndicator,
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
        ACTIVEINDICATOR,
    from transform_data
)

select * from type_data