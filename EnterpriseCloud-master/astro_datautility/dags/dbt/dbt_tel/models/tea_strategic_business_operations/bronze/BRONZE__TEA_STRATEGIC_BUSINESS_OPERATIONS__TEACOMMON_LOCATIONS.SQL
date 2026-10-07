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
        AddressCode,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH 
    FROM source_data
          )
,type_data as
(
    SELECT 
        CAST(_Filedate AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        _Filename AS _FILENAME,
        _AUDIT_LOG_ID as _AUDIT_LOG_ID,
        _ROW_HASH as _ROW_HASH,
        CompanyID AS CompanyID,
        LocationCode AS LocationCode,
        Description AS Description,
        Address1 AS Address1,
        Address2 AS Address2,
        City AS City,
        StateProv AS StateProv,
        PostalCode AS PostalCode,
        ISRegion AS ISRegion,
        LastUpdated AS LastUpdated,
        LastUpdatedBy AS LastUpdatedBy,
        AddressCode AS AddressCode
    FROM transform_data
        )
select * from type_data