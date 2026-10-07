{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='TEACOMMON_LOCATIONS'
) }}


with source_data as
(
    SELECT      
        _Filename as _Filename,
        _Filedate as _Filedate,
        JSonField:CompanyID::STRING AS CompanyID,
        JSonField:LocationCode::STRING AS LocationCode,
        JSonField:Description::STRING AS Description,
        JSonField:Address1::STRING AS Address1,
        JSonField:Address2::STRING AS Address2,
        JSonField:City::STRING AS City,
        JSonField:StateProv::STRING AS StateProv,
        JSonField:PostalCode::STRING AS PostalCode,
        JSonField:ISRegion::STRING AS ISRegion,
        JSonField:LastUpdated AS LastUpdated,
        JSonField:LastUpdatedBy::STRING AS LastUpdatedBy,
        JSonField:AddressCode::STRING AS AddressCode
    FROM {{ source("TEACOMMON", "LOCATIONS") }}
    WHERE _Filedate = (SELECT MAX(_FileDate) FROM {{ source("TEACOMMON", "LOCATIONS") }})
            )
,transform_data as
(
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _Filename,
        _Filedate,
        CompanyID,
        LocationCode,
        Description,
        Address1,
        Address2,
        City,
        StateProv,
        PostalCode,
        ISRegion,
        LastUpdated,
        LastUpdatedBy,
        AddressCode
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _Filename,
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _Filedate,
        CompanyID,
        LocationCode,
        Description,
        Address1,
        Address2,
        City,
        StateProv,
        PostalCode,
        ISRegion,
        LastUpdated,
        LastUpdatedBy,
        AddressCode
    FROM transform_data
        )
select * from type_data