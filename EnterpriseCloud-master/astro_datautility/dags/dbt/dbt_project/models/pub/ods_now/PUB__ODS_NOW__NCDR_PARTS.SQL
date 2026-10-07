/************
Model file generated from dbtGeneratePubViews: 12.14.2022.18.35.47"
*************/

{{ config(
      materialized='view',
      alias='NCDR_PARTS',
      transient=false
) }}

with source_data as (
    SELECT
        NCDR_PART_ID,
        NCDR_NUMBER,
        PART_NUMBER,
        DESCRIPTION,
        CONSUME_FLAG,
        INTEL_FLAG,
        SIGNAL_CODE,
        PRICE_CURRENCY,
        SALE_PRICE,
        STANDARD_COST,
        TRANSFER_PRICE,
        UNIT_OF_MEASURE,
        REMARKS,
        QUANTITY,
        DOCUMENT,
        SHIP_FROM,
        RETURNED_DATE,
        DELIVERY_DATE,
        UPDATED_DELIVERY_DATE,
        DELIVERY_REMARKS,
        APPROVED,
        AICS_WARNING,
        RETURN_TO_STOCK,
        RETURN_REASON,
        LINE_NUMBER,
        LAST_UPDATED_DATE,
        READY_BY_FACTORY,
        EOL_FLG,
        LEAD_TIME,
        NCDR_LINE_ID,
        URL_REFERENCE,
        SHIP_COMPLETE,
        SO_NUMBER,
        SO_LINE_ITEM
    from {{ ref('ODS__NOW__NCDR_PARTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data