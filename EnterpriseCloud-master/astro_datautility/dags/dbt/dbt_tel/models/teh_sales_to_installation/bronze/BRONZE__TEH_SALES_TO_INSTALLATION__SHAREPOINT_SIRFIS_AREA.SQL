{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='SHAREPOINT_SIRFIS_AREA',
    transient = false
) }}

with source_data as
(
    SELECT
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        jsonfield:fields.Title::STRING AS SITE,
        jsonfield:fields.field_1::STRING as AREA
    FROM {{ source("SHAREPOINT", "SIRFIS_AREA") }}
    WHERE _FILEDATE = (select max(_FILEDATE) from {{ source('SHAREPOINT', 'SIRFIS_AREA') }})
)
,transform_data as
(
    SELECT        
         '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SITE,
        AREA
        FROM source_data
)
,type_data as
(
    select
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        SITE,
        AREA
    from transform_data
)

select * from type_data