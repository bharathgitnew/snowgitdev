{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='BUSINESSUNIT',
    unique_key= ['BU_CODE']
) }}

with source_data as 
(
    SELECT 
    BU_CODE,
    BU_NAME,
    _FILEDATE
    FROM {{ source("FILE", "BUSINESSUNIT") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("FILE", "BUSINESSUNIT") }})
)


,transform_data as 
(
    SELECT 
        BU_CODE,
        BU_NAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM source_data 
)
,type_data as 
(
    select
        cast(BU_CODE as VARCHAR(16777216)) as BU_CODE,
        cast(BU_NAME as VARCHAR(16777216)) as BU_NAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH
    from transform_data
    )
select * from type_data