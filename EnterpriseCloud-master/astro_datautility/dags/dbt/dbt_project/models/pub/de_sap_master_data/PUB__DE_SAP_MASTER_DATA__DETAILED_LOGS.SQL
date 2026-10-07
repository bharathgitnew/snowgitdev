{{ config(
    materialized='view',
    alias='DETAILED_LOGS'
) }}

WITH source_data as (
select
        FLOW_RUN_ID
        ,FLOW_NAME
        ,FLOW_RUN_NAME
        ,RUN_ENVIRONMENT
        ,PARAMETERS
        ,START_TIME
        ,END_TIME
        ,RUN_STATE
        ,RUN_TIME_IN_SECONDS
        ,DETAILED_LOGS
FROM {{ ref('COMMON__SAPH__DETAILED_LOGS') }}
),

transform_data as (
select * from source_data
)

select * from transform_data