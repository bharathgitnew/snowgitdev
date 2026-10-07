{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='Flow'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,ID AS ID
        ,NAME AS NAME
        ,DESCRIPTION AS DESCRIPTION
        ,PARAMETERS AS PARAMETERS
        ,RUN_CONFIG AS RUN_CONFIG
        ,ENVIRONMENT AS ENVIRONMENT
        ,UPDATED AS UPDATED
    FROM {{ ref('BRONZE__TEH_EQUIPMENT_SALES__PREFECT_FLOW') }}
    where _Filedate not in (select _Filedate from {{ this }})
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILENAME as _FILENAME
        ,_FILEDATE as _FILEDATE
        ,ID AS ID
        ,NAME AS NAME
        ,DESCRIPTION AS DESCRIPTION
        ,PARAMETERS AS PARAMETERS
        ,RUN_CONFIG AS RUN_CONFIG
        ,ENVIRONMENT AS ENVIRONMENT
        ,UPDATED AS UPDATED
FROM source_data
)
, type_data AS
(
    SELECT
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME
        ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE
        ,CAST(ID AS VARCHAR(16777216))  AS ID
        ,CAST(NAME AS VARCHAR(16777216))  AS NAME
        ,CAST(DESCRIPTION AS VARCHAR(16777216))  AS DESCRIPTION
        ,CAST(PARAMETERS AS VARIANT)  AS PARAMETERS
        ,CAST(RUN_CONFIG AS VARIANT)  AS RUN_CONFIG
        ,CAST(ENVIRONMENT AS VARCHAR(16777216))  AS ENVIRONMENT
        ,CAST(UPDATED AS VARCHAR(16777216))  AS UPDATED
FROM transform_data
)
select * from type_data