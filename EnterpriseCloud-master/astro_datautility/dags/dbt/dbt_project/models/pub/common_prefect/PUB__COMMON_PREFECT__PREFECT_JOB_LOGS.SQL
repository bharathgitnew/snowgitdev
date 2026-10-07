{{ config(
    materialized='view',
    alias='Prefect_Job_Logs'
) }}

with source_data as
(
    SELECT
         FLOW_NAME as FLOW_NAME
        ,FLOW_RUN_NAME AS FLOW_RUN_NAME
        ,RUN_ENVIRONMENT AS RUN_ENVIRONMENT
        ,PARAMETERS AS PARAMETERS
        ,START_TIME AS START_TIME
        ,END_TIME AS END_TIME
        ,RUN_STATE AS RUN_STATE
        ,RUN_TIME_IN_SECONDS AS RUN_TIME_IN_SECONDS
    FROM {{ ref('COMMON__PREFECT__DASHBOARD_REPORTING') }}
)
,transform_data as
(
    SELECT
         FLOW_NAME as FLOW_NAME
        ,FLOW_RUN_NAME AS FLOW_RUN_NAME
        ,RUN_ENVIRONMENT AS RUN_ENVIRONMENT
        ,PARAMETERS AS PARAMETERS
        ,START_TIME AS START_TIME
        ,END_TIME AS END_TIME
        ,RUN_STATE AS RUN_STATE
        ,RUN_TIME_IN_SECONDS AS RUN_TIME_IN_SECONDS
    FROM source_data
)
select * from transform_data