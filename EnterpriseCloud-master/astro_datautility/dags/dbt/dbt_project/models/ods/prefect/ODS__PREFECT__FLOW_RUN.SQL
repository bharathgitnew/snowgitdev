{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    alias='Flow_Run'
) }}

with source_data as
(
    SELECT
         _Filename as _Filename
        ,_Filedate as _Filedate
        ,FlowRunLevel.value:flow_id::STRING AS FLOW_ID
        ,FlowRunLevel.value:id::STRING AS ID
        ,FlowRunLevel.value:name::STRING AS NAME
        ,FlowRunLevel.value:start_time::STRING AS START_TIME
        ,FlowRunLevel.value:end_time::STRING AS END_TIME
        ,FlowRunLevel.value:state::STRING AS STATE
        ,FlowRunLevel.value:state_message::STRING AS STATE_MESSAGE
        ,FlowRunLevel.value:state_result::STRING AS STATE_RESULT
        ,FlowRunLevel.value:state_start_time::STRING AS STATE_START_TIME
        ,FlowRunLevel.value:state_timestamp::STRING AS STATE_TIMESTAMP
        ,FlowRunLevel.value:tenant_id::STRING AS TENANT_ID
        ,FlowRunLevel.value:times_resurrected::STRING AS TIMES_RESURRECTED
        ,FlowRunLevel.value:updated::STRING AS UPDATED
        ,FlowRunLevel.value:version::STRING AS VERSION
        ,FlowRunLevel.value:labels::STRING AS LABELS
        ,FlowRunLevel.value:parameters::STRING AS PARAMETERS
    FROM {{ source("PREFECT", "FLOW_RUN") }}
    ,LATERAL FLATTEN (input => JsonField:data.flow_run) FlowRunLevel
        where _Filedate not in (select _Filedate from {{ this }})
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
        ,LABELS AS LABELS
        ,PARAMETERS AS PARAMETERS
        ,'{{ invocation_id }}' AS Audit_Log_Id
        ,SHA2('hash_me') as _Row_Hash
    FROM source_data
)
, type_data AS
(
    SELECT
        CAST(_FILENAME AS VARCHAR(16777216))  AS _FILENAME
        ,CAST(_FILEDATE AS TIMESTAMP_NTZ(9))  AS _FILEDATE
        ,CAST(FLOW_ID AS VARCHAR(16777216))  AS FLOW_ID
        ,CAST(ID AS VARCHAR(16777216))  AS ID
        ,CAST(NAME AS VARCHAR(16777216))  AS NAME
        ,CAST(START_TIME AS VARCHAR(16777216))  AS START_TIME
        ,CAST(END_TIME AS VARCHAR(16777216))  AS END_TIME
        ,CAST(STATE AS VARCHAR(16777216))  AS STATE
        ,CAST(STATE_MESSAGE AS VARCHAR(16777216))  AS STATE_MESSAGE
        ,CAST(STATE_RESULT AS VARCHAR(16777216))  AS STATE_RESULT
        ,CAST(STATE_START_TIME AS VARCHAR(16777216))  AS STATE_START_TIME
        ,CAST(STATE_TIMESTAMP AS VARCHAR(16777216))  AS STATE_TIMESTAMP
        ,CAST(TENANT_ID AS VARCHAR(16777216))  AS TENANT_ID
        ,CAST(TIMES_RESURRECTED AS VARCHAR(16777216))  AS TIMES_RESURRECTED
        ,CAST(UPDATED AS VARCHAR(16777216))  AS UPDATED
        ,CAST(VERSION AS VARCHAR(16777216))  AS VERSION
        ,CAST(LABELS AS VARCHAR(16777216))  AS LABELS
        ,CAST(PARAMETERS AS VARCHAR(16777216))  AS PARAMETERS
        ,CAST(Audit_Log_Id AS VARCHAR(128))  AS Audit_Log_Id
        ,CAST(_Row_Hash AS VARCHAR(128))  AS _Row_Hash
    FROM transform_data
)
select * from type_data