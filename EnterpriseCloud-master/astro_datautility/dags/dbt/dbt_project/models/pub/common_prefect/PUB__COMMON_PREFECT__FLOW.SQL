{{ config(
    materialized='view',
    alias='FLOW'
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
    FROM {{ ref('COMMON__PREFECT__FLOW') }}
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
select * from transform_data