/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='REQUEST_SERVICE',
      transient=false
) }}

with source_data as (
    SELECT
        REQ_SERVICE_ID,
        RMA_ID,
        RECEIVING_EXPIRED,
        BAAN_FAB_ID,
        CUST_DESCR,
        SCRAP_KEEP_OR_RECLEAN_PART,
        PART_RECLEANED_DT,
        PART_RECLEANED_USER_ID,
        FROM_CONSIGNMENT_PROGRAM,
        PART_NEEDED_BY_TEA,
        IN_TRANSIT_SHIPSTAMP_ID,
        CREDIT_CONSIGNMENT_WHSE_ID,
        INACTIVE_DT,
        CREATED_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__REQUEST_SERVICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data