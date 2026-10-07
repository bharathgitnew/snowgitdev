{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='PREFECT_FLOW'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,FlowLevel.value:id::STRING AS ID
        ,FlowLevel.value:name::STRING AS NAME
        ,FlowLevel.value:description::STRING AS DESCRIPTION
        ,FlowLevel.value:parameters::VARIANT AS PARAMETERS
        ,FlowLevel.value:run_config::VARIANT AS RUN_CONFIG
        ,FlowLevel.value:environment::STRING AS ENVIRONMENT
        ,FlowLevel.value:updated::STRING AS UPDATED
    FROM {{ source("PREFECT", "FLOW") }}
    ,LATERAL FLATTEN (input => JsonField:data.flow) FlowLevel
    where _Filedate not in (select _Filedate from {{ this }})
)
,transform_data as
(
    SELECT
        _Filename AS _Filename
        ,_Filedate AS _Filedate
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
        ,ID AS ID
        ,NAME AS NAME
        ,DESCRIPTION AS DESCRIPTION
        ,PARAMETERS AS PARAMETERS
        ,RUN_CONFIG AS RUN_CONFIG
        ,ENVIRONMENT AS ENVIRONMENT
        ,UPDATED AS UPDATED
FROM source_data
)
, type_data AS
(
    SELECT
        _Filename AS _Filename
        ,_Filedate AS _Filedate
        ,_AUDIT_LOG_ID AS _AUDIT_LOG_ID
        ,_ROW_HASH AS _ROW_HASH
        ,CAST(ID AS VARCHAR(16777216))  AS ID
        ,CAST(NAME AS VARCHAR(16777216))  AS NAME
        ,CAST(DESCRIPTION AS VARCHAR(16777216))  AS DESCRIPTION
        ,CAST(PARAMETERS AS VARIANT)  AS PARAMETERS
        ,CAST(RUN_CONFIG AS VARIANT)  AS RUN_CONFIG
        ,CAST(ENVIRONMENT AS VARCHAR(16777216))  AS ENVIRONMENT
        ,CAST(UPDATED AS VARCHAR(16777216))  AS UPDATED
FROM transform_data
)
select * from type_data