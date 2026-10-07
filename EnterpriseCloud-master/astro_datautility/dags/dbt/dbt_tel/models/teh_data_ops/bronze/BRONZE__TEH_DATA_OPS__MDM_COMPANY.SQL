-- copied from ODS__MDM__COMPANY
{{ config(
    alias = 'MDM_COMPANY',
    materialized = 'tel_incremental',
    incremental_strategy = 'merge',
    unique_key = ['COMPANYCODE'],
) }}


with source_data as (
    SELECT
          _Filename as _Filename
         ,_Filedate as _Filedate
         ,JSonField:Code::STRING AS CompanyCode
         ,JSonField:Name::STRING AS CompanyName
         ,JSonField:CompanyLongName::STRING AS LongName
         ,JSonField:CompanyActiveIndicator::STRING AS ActiveIndicator
    FROM {{ source("MDM", "COMPANY") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("MDM", "COMPANY") }})
)

,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILEDATE,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        source_data.COMPANYCODE AS COMPANYCODE,
        source_data.COMPANYNAME AS COMPANYNAME,
        source_data.LONGNAME AS LONGNAME,
        source_data.ACTIVEINDICATOR AS ACTIVEINDICATOR,
    FROM source_data
)

,type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILEDATE,
        _REFRESHDATE,
        COMPANYCODE,
        COMPANYNAME,
        LONGNAME,
        ACTIVEINDICATOR,
    from transform_data
)
select * from type_data