{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='SAP_DE_REFERENCE'
) }}

with source_data as 
(
    SELECT 
    DATA_EXCHANGE_NAME,
    SOURCE_DEPARTMENT_NAME,
    _FILEDATE
    FROM {{ source("FILE", "SAP_DE_REFERENCE") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("FILE", "SAP_DE_REFERENCE") }})
)


,transform_data as 
(
    SELECT 
        DATA_EXCHANGE_NAME,
        SOURCE_DEPARTMENT_NAME,
        _FILEDATE,
        '{{ invocation_id }}' AS AUDIT_LOG_ID
    FROM source_data 
)
,type_data as 
(
    select
        cast(DATA_EXCHANGE_NAME as VARCHAR(16777216)) as DATA_EXCHANGE_NAME,
        cast(SOURCE_DEPARTMENT_NAME as VARCHAR(16777216)) as SOURCE_DEPARTMENT_NAME,
        cast(_FILEDATE as TIMESTAMP_NTZ(9)) as _FILEDATE,
        cast(AUDIT_LOG_ID as varchar(128)) as AUDIT_LOG_ID
    from transform_data
    )
select * from type_data