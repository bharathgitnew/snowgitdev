{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias='POWERBI_DATASOURCES'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename,
        _Filedate as _Filedate,
        jsonfield:"@odata.context"::string as Context,
        r.value:"connectionDetails"::string as connectionDetails,
        r.value:"credentialDetails"::variant as credentialDetails,
        r.value:"credentialType"::string as credentialType,
        r.value:"datasourceName"::string as datasourceName,
        r.value:"datasourceType"::string as datasourceType,
        r.value:"gatewayId"::string as gatewayId,
        r.value:"id"::string as id
    FROM {{ source("POWERBI", "DATASOURCES") }} Dt,
        lateral flatten ( input => dt.jsonfield:"value", outer => true) r
)
,transform_data as
(
    SELECT
        '{{ invocation_id }}' AS _Audit_Log_Id,
        SHA2('hash_me') as _Row_Hash,
        _FILEDATE as _FILEDATE,
        _FILENAME as _FILENAME,
        Context as CONTEXT,
        connectionDetails as CONNECTION_DETAILS,
        credentialDetails as CREDENTIAL_DETAILS,
        credentialType as CREDENTIAL_TYPE,
        datasourceName as DATA_SOURCE_NAME,
        datasourceType as DATA_SOURCE_TYPE,
        gatewayId as GATEWAY_ID,
        id as ID
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_Audit_Log_Id AS VARCHAR(128))  AS _AUDIT_LOG_ID,
        CAST(_Row_Hash AS VARCHAR(128))  AS _ROW_HASH,
        CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE,
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME,
        CONTEXT,
        CONNECTION_DETAILS,
        CREDENTIAL_DETAILS,
        CREDENTIAL_TYPE,
        DATA_SOURCE_NAME,
        DATA_SOURCE_TYPE,
        GATEWAY_ID,
        ID
    FROM transform_data
)
select * from type_data