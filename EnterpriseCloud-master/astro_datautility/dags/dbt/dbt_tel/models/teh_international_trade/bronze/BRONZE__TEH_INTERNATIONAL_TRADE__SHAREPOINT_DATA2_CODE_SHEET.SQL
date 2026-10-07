{{ config(
    alias = 'SHAREPOINT_DATA2_CODE_SHEET',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}

with source_data as (
    select
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        JSONFIELD:"D2L Service Type Code"::string as D2L_SERVICE_TYPE_CODE,
        JSONFIELD:"Description"::string as DESCRIPTION
    from {{ source('SHAREPOINT', 'DATA2_CODE_SHEET') }} 
 where _FILEDATE LIKE (select try_to_timestamp(max(MAX_FILE_DATE), 'YYYY-MM-DD_HH24_MI_SS_FF6') from {{ source('SHAREPOINT', 'CONTROLTABLE') }} where TABLE_NAME = 'DATA2_CODE_SHEET')
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        *
    from source_data
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _FILENAME,
        _FILEDATE,
        _UPLOADDATE,
        D2L_SERVICE_TYPE_CODE,
        DESCRIPTION
    from transform_data
)

select * from type_data
