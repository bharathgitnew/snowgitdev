{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias='SHAREPOINT_SERVICE_B_CODE_MAPPING'
) }}

with source_data as (
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield :fields.Title :: STRING as B_CODE,
        jsonfield :fields.field_1 :: STRING as LEGACY_OFFICE,
        jsonfield :fields.field_2 :: STRING as LEGACY_OFFICE_CODE,
        jsonfield :fields.field_3 :: STRING as SAP_DESCRIPTION,
        jsonfield :fields.field_4 :: STRING as SAP_CODE,
        jsonfield :fields.field_5 :: STRING as B_CODE_LOCATION,
        jsonfield :fields.field_6 :: STRING as SAP_TECHNICAL_ID
    FROM {{source("SHAREPOINT", "SERVICE_B_CODE_MAPPING")}}
    where _UPLOADDATE = (select max(_UPLOADDATE) from {{source("SHAREPOINT", "SERVICE_B_CODE_MAPPING")}} )
        and B_CODE is not null
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID
    FROM
        source_data
),
type_data as (
    select

        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        B_CODE,
        LEGACY_OFFICE,
        LEGACY_OFFICE_CODE,
        SAP_DESCRIPTION,
        SAP_CODE,
        B_CODE_LOCATION,
        SAP_TECHNICAL_ID,
        cast(_AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
    from
        transform_data
)
select
    *
from
    type_data