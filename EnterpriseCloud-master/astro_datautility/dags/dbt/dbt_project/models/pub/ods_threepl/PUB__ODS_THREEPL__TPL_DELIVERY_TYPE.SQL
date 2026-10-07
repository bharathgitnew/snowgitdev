{{ config(
      materialized='view',
      alias='TPL_Delivery_Type',
      transient=false
) }}

with source_data as (
    SELECT
        DELIVERY_TYPE,
        DESCRIPTION,
        DIRECTION,
        MAX_LINES_PER_SHIPMENT,
        REQUIRES_CI,
        _FILEDATE,
        AUDIT_LOG_ID,
        _ROW_HASH
    from {{ ref('ODS__THREEPL__TPL_DELIVERY_TYPE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data