{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='EMPLOYEE_TEACOMMON_MONTHLY_SNAPSHOT',
      transient=false
) }}


with source_data as (
    select
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__TEACOMMON__EMPLOYEE_MONTHLY_SNAPSHOT') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data