{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='LOGS'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,ID AS ID
        ,DETAILED_LOGS AS DETAILED_LOGS
    FROM {{ ref('ODS__PREFECT__LOGS') }}
    where _Filedate not in (select _Filedate from {{ this }})
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME
        ,_FILEDATE as _FILEDATE
        ,ID AS ID
        ,DETAILED_LOGS AS DETAILED_LOGS
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME
        ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE
        ,CAST(ID AS VARCHAR(16777216))  AS ID
        ,CAST(DETAILED_LOGS AS VARCHAR(16777216))  AS DETAILED_LOGS
        ,CAST(Audit_Log_Id AS VARCHAR(128))  AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash
    FROM transform_data
)
select * from type_data