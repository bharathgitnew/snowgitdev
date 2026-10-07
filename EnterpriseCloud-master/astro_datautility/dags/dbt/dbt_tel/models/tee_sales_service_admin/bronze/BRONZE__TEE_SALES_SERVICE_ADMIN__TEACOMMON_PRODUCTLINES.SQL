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
        CompanyID,
        ProdLineCode,
        Description,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH 
    FROM source_data
          )
,type_data as
(
    SELECT 
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        CAST(_Filename AS VARCHAR(16777216)) AS _Filename,
        CAST(CompanyID AS VARCHAR(16777216)) AS CompanyID,
        CAST(ProdLineCode AS VARCHAR(16777216)) AS ProdLineCode,
        CAST(Description AS VARCHAR(16777216)) AS Description
    FROM transform_data
        )
select * from type_data