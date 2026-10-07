{{ config(
    materialized='view',
    alias='Flow_Run'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,FLOW_ID AS FLOW_ID
        ,ID AS ID
        ,NAME AS NAME
        ,START_TIME AS START_TIME
        ,END_TIME AS END_TIME
        ,STATE AS STATE
        ,STATE_MESSAGE AS STATE_MESSAGE
        ,STATE_RESULT AS STATE_RESULT
        ,STATE_START_TIME AS STATE_START_TIME
        ,STATE_TIMESTAMP AS STATE_TIMESTAMP
        ,TENANT_ID AS TENANT_ID
        ,TIMES_RESURRECTED AS TIMES_RESURRECTED
        ,UPDATED AS UPDATED
        ,VERSION AS VERSION
    FROM {{ ref('ODS__PREFECT__FLOW_RUN') }}
)
,transform_data as
(
    SELECT
        _FILENAME as _FILENAME
        ,_FILEDATE as _FILEDATE
        ,FLOW_ID AS FLOW_ID
        ,ID AS ID
        ,NAME AS NAME
        ,START_TIME AS START_TIME
        ,END_TIME AS END_TIME
        ,STATE AS STATE
        ,STATE_MESSAGE AS STATE_MESSAGE
        ,STATE_RESULT AS STATE_RESULT
        ,STATE_START_TIME AS STATE_START_TIME
        ,STATE_TIMESTAMP AS STATE_TIMESTAMP
        ,TENANT_ID AS TENANT_ID
        ,TIMES_RESURRECTED AS TIMES_RESURRECTED
        ,UPDATED AS UPDATED
        ,VERSION AS VERSION
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
    FROM source_data
)
select * from transform_data