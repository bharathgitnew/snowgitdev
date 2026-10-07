{{ config(
    materialized = 'tel_incremental',
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
        FROM {{ ref('BRONZE__TEH_APPLICATIONS__MYSKILLS_KSMN_TABLE') }} KSMN_TABLE    
    )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        CompanyId,
        Name,
        ShortName,
        CountryCode-- Adds column to table on full refresh.
        FROM source_data
        )
,type_data as 
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        COMPANYID,
        NAME,
        SHORTNAME,
        COUNTRYCODE
    from transform_data
    )
select * from type_data