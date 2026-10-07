{{ config(
      materialized = 'view',
      alias = 'CONSIGNMENT_REPLENISHMENT',
      transient = false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__CONSIGNMENT_REPLENISHMENT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data