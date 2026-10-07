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
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
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
        CAST(_FILENAME AS VARCHAR(16777216)) AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(CompanyID AS VARCHAR(16777216)) AS CompanyID,
        CAST(LocationCode AS VARCHAR(16777216)) AS LocationCode,
        CAST(Description AS VARCHAR(16777216)) AS Description,
        CAST(Address1 AS VARCHAR(16777216)) AS Address1,
        CAST(Address2 AS VARCHAR(16777216)) AS Address2,
        CAST(City AS VARCHAR(16777216)) AS City,
        CAST(StateProv AS VARCHAR(16777216)) AS StateProv,
        CAST(PostalCode AS VARCHAR(16777216)) AS PostalCode,
        CAST(ISRegion AS VARCHAR(16777216)) AS ISRegion,
        CAST(LastUpdated AS VARCHAR(16777216)) AS LastUpdated,
        CAST(LastUpdatedBy AS VARCHAR(16777216)) AS LastUpdatedBy,
        CAST(AddressCode AS VARCHAR(16777216)) AS AddressCode
    FROM transform_data
        )
select * from type_data