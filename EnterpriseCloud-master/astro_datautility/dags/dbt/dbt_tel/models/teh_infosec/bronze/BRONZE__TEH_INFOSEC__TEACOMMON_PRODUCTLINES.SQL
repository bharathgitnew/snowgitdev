{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEACOMMON_PRODUCTLINES'
) }}


with source_data as
(
    SELECT      
        _Filename as _Filename,
        _Filedate as _Filedate,
        JSonField:CompanyID::STRING AS CompanyID,
        JSonField:ProdLineCode::STRING AS ProdLineCode,
        JSonField:Description::STRING AS Description

    FROM {{ source("TEACOMMON", "PRODUCTLINES") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TEACOMMON", "PRODUCTLINES") }})
            )
,transform_data as
(
    SELECT 
        _Filename,
        _Filedate,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        CompanyID,
        ProdLineCode,
        Description
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(CompanyID AS VARCHAR(16777216)) AS CompanyID,
        CAST(ProdLineCode AS VARCHAR(16777216)) AS ProdLineCode,
        CAST(Description AS VARCHAR(16777216)) AS Description
    FROM transform_data
        )
select * from type_data