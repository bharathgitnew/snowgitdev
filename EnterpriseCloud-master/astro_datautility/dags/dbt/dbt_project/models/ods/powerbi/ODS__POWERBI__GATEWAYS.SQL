{{ config(
    materialized='incremental',
    incremental_strategy='insert_overwrite',
    alias='GATEWAYS'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename,
        _Filedate as _Filedate,
        jsonfield:"@odata.context"::string as Context,
        r.value:"gatewayAnnotation"::variant as gatewayAnnotation,
        r.value:"gatewayId"::string as gatewayId,
        r.value:"id"::string as id,
        r.value:"name"::string as name,
        r.value:"publicKey"."exponent"::string as exponent,
        r.value:"publicKey"."modulus"::string as modulus,
        r.value:"type"::string as type
    FROM {{ source("POWERBI", "GATEWAYS") }} Dt,
        lateral flatten ( input => dt.jsonfield:"value", outer => true) r
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME,
        _FILEDATE as _FILEDATE,
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        Context,
        gatewayAnnotation as GATEWAY_ANNOTATION,
        gatewayId AS GATEWAY_ID,
        id AS ID,
        name AS NAME,
        exponent AS EXPONENT,
        modulus AS MODULUS,
        type as TYPE
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_Audit_Log_Id AS VARCHAR(128))  AS _Audit_Log_Id,
        CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        Context,
        GATEWAY_ANNOTATION,
        GATEWAY_ID,
        ID,
        NAME,
        EXPONENT,
        MODULUS,
        TYPE
    FROM transform_data
)
select * from type_data