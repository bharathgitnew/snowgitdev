{{ config(
    alias='FILE_FAB21_EHS_AUDIT_ETC',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite'
) }}

with source_data as (
    SELECT 
        _FILENAME, 
        _UPLOADDATE, 
        _FILEDATE,
        jsonfield : "Unnamed: 0" :: STRING as HEADER1, 
        jsonfield : "Unnamed: 1" :: STRING as HEADER2,
        jsonfield : "Unnamed: 2" :: STRING as HEADER3, 
        jsonfield : "Unnamed: 3" :: STRING as HEADER4, 
        jsonfield : "Unnamed: 4" :: STRING as HEADER5, 
        jsonfield : "Unnamed: 5" :: STRING as HEADER6,
        jsonfield : "Unnamed: 6" :: STRING as HEADER7, 
        jsonfield : "Unnamed: 7" :: STRING as HEADER8
    FROM 
        {{ source('FILE', 'FAB21_EHS_AUDIT_ETC') }}
    WHERE _FILEDATE =  (SELECT MAX(_FILEDATE) FROM {{ source('FILE', 'FAB21_EHS_AUDIT_ETC') }})
), 
transform_data as (
    select 
        _filedate,
        _UPLOADDATE,
        _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        HEADER1,
        HEADER2,
        HEADER3,
        HEADER4,
        HEADER5,
        HEADER6,
        HEADER7,
        HEADER8
    from 
        source_data 

),
type_data as (
    select 
        cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        cast(_UPLOADDATE AS TIMESTAMP_NTZ(9)) AS _UPLOADDATE,
        cast(_FILENAME as varchar(128)) as _FILENAME,
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,     
        HEADER1,
        HEADER2,
        HEADER3,
        HEADER4,
        HEADER5,
        HEADER6,
        HEADER7,
        HEADER8
    from 
        transform_data
)
    select 
        * 
    from type_data

