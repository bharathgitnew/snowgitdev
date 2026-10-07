{{ config(
      materialized='view',
      alias='INVENTORY_HISTORY_FULL',
      transient=false,
      enabled=true
) }}


with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH, SECURITY_SEGMENT, SECURITY_DEPARTMENT, SECURITY_OFFICE)
    FROM {{ ref('COMMON__REPORTS__INVENTORY_HISTORY_FULL') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data