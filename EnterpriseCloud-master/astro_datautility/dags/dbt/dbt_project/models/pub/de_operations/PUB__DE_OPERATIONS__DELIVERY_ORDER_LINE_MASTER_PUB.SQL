{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='DELIVERY_ORDER_LINE_MASTER_PUB',
      transient=false,
      enabled=true
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__SAPH__DELIVERY_ORDER_LINE_MASTER_PUB') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data