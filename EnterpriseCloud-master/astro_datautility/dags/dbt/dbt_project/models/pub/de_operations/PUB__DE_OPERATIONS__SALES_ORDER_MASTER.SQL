{{ config(
      materialized='view',
      alias='SALES_ORDER_MASTER',
      transient=false
) }}


with source_data as (
        SELECT 
            * exclude (_AUDIT_LOG_ID, _ROW_HASH)
        FROM {{ ref('COMMON__SAPH__SALES_ORDER_MASTER') }} 
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data