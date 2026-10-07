{{ config(
    materialized='tel_incremental',
    incremental_strategy='merge',
    alias='PREFECT_FLOW_RUN'
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
        _Filename AS _Filename
        ,_Filedate AS _Filedate
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
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
FROM source_data
)
, type_data AS
(
    SELECT
        _Filename AS _Filename
        ,_Filedate AS _Filedate
        ,_AUDIT_LOG_ID AS _AUDIT_LOG_ID
        ,_ROW_HASH AS _ROW_HASH
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
FROM transform_data
)
select * from type_data