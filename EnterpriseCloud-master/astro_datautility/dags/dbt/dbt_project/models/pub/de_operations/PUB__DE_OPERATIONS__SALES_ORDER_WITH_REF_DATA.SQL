{{ config(
      materialized='view',
      alias='SALES_ORDER_WITH_REF_DATA',
      transient=false
) }}

with source_data as (
        SELECT 
            * exclude (_AUDIT_LOG_ID, _ROW_HASH)
        FROM {{ ref('COMMON__REPORTS__SALES_ORDER_WITH_REF_DATA') }} 
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data