{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='FILE_BUSINESSUNIT',
    unique_key= ['BU_CODE']
) }}

with source_data as 
(
    SELECT 
    BU_CODE,
    BU_NAME,
    _FILEDATE
    FROM {{ source("FILE", "BUSINESSUNIT") }}
    WHERE _Filedate = (SELECT COALESCE(MAX(_FileDate),'1900-01-01') FROM {{ source("FILE", "BUSINESSUNIT") }})
)


,transform_data as 
(
    SELECT 
        _FILEDATE,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        BU_CODE,
        BU_NAME,
    FROM source_data 
)
,type_data as 
(
    select
        _FILEDATE,
        _AUDIT_LOG_ID,
        _ROW_HASH,
        BU_CODE,
        BU_NAME
    from transform_data
    )
select * from type_data