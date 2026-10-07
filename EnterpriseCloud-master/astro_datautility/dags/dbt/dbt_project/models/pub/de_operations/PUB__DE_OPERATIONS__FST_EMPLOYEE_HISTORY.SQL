{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='FST_EMPLOYEE_HISTORY',
      transient=false
) }}


with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ source('COMMON__TEACOMMON', 'FST_EMPLOYEE_HISTORY') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data