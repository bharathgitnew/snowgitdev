{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='CRM_WORK_ORDER_RECENT_SUMMARY',
      transient=false,
      enabled=true
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__CRM_WORK_ORDER_RECENT_SUMMARY') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data