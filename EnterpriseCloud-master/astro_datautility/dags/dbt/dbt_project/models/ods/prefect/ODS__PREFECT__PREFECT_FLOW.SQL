{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Prefect_Flow'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,JSonField:Id::STRING AS ID
        ,JSonField:NAME::STRING AS NAME
        ,JSonField:DESCRIPTION::STRING AS DESCRIPTION
        ,JSonField:PARAMETERS::STRING AS PARAMETERS
        ,JSonField:RUN_CONFIG::STRING AS RUN_CONFIG
        ,JSonField:ENVIRONMENT::STRING AS ENVIRONMENT
        ,JSonField:UPDATED::STRING AS UPDATED
    FROM {{ source("PREFECT", "PREFECT_FLOW") }}
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME
        ,_FILEDATE as _FILEDATE
        ,ID AS ID
        ,NAME AS NAME
        ,DESCRIPTION AS DESCRIPTION
        ,PARAMETERS AS PARAMETERS
        ,RUN_CONFIG AS RUN_CONFIG
        ,ENVIRONMENT AS ENVIRONMENT
        ,UPDATED AS UPDATED
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
        ,CAST(NAME AS VARCHAR(16777216))  AS NAME
        ,CAST(DESCRIPTION AS VARCHAR(16777216))  AS DESCRIPTION
        ,CAST(PARAMETERS AS VARCHAR(16777216))  AS PARAMETERS
        ,CAST(RUN_CONFIG AS VARCHAR(16777216))  AS RUN_CONFIG
        ,CAST(ENVIRONMENT AS VARCHAR(16777216))  AS ENVIRONMENT
        ,CAST(UPDATED AS VARCHAR(16777216))  AS UPDATED
        ,CAST(Audit_Log_Id AS VARCHAR(128))  AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash
    FROM transform_data
)
select * from type_data