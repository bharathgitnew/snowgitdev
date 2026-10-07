/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='PAIDSERVICEQUOTE',
      transient=false
) }}

with source_data as (
    SELECT
        QUOTE_NUMBER,
        QUOTE_STATUS,
        QUOTE_DATE,
        CONFIG,
        CONFIG_OLD,
        PRODUCT_LINE,
        FAB_LOCATION,
        PO_NUMBER,
        ESTIMATED_TOTAL,
        CALC_ESTIMATED_TOTAL,
        REQUESTOR_NAME,
        CUSTOMER,
        START_TIME,
        END_TIME,
        WORK_DESCRIPTION,
        DECOMMISSION,
        STATUS,
        CUSTOMER_GROUP,
        SERIAL_NUMBER,
        TOOL_ID,
        PROBABILITY,
        TABLE_REFRESH_DATE
    from {{ ref('COMMON__MDM__PAIDSERVICEQUOTE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data