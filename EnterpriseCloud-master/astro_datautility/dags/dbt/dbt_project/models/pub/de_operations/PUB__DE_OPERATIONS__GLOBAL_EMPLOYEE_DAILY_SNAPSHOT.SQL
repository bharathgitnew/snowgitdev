{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='GLOBAL_EMPLOYEE_DAILY_SNAPSHOT',
      transient=false
) }}


with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__SHARED_DATASETS__GLOBAL_EMPLOYEE_DAILY_SNAPSHOT') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data