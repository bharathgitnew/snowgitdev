{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='ETR_REPORT_VIEW',
      transient=false,
      enabled=true
) }}

with source_data as (
    SELECT
        RECORD_TYPE
        , ORDER_NO
        , ORDER_LINE_NO
        , DO_NO
        , DO_LINE_NO
        , DO_REF_ORDER
        , DO_REF_LINE
        , ORDER_PRIORITY
        , ORDER_TYPE
        , ORDER_STATUS
        , ORDER_QTY
        , DELIVERED_QTY
    FROM {{ ref('COMMON__REPORTS__ETR_REPORT_VIEW') }}

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data