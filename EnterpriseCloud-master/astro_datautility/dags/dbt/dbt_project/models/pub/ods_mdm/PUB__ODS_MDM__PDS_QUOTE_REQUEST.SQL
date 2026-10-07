/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.29"
*************/

{{ config(
      materialized='view',
      alias='PDS_QUOTE_REQUEST',
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
    from {{ ref('ODS__MDM__PDS_QUOTE_REQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data