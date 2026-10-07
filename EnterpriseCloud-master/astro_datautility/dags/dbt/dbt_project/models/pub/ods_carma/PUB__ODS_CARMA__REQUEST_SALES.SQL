/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='REQUEST_SALES',
      transient=false
) }}

with source_data as (
    SELECT
        REQ_SALE_ID,
        RMA_ID,
        IS_CUS_DIRECT_REQUESTED,
        RECEIVING_EXPIRED,
        BAAN_FAB_ID,
        CUST_DESCR,
        DAMAGE_LIABILITY_DISP_ID,
        BU_MUST_AUTH_RETURN,
        BU_AUTH_RETURN,
        WILL_CUSTOMER_PAY_DAMAGED,
        IN_TRANSIT_SHIPSTAMP_ID,
        EMP_PRIMARY_COMMENTS,
        EMP_SECONDARY_COMMENTS,
        INACTIVE_DT,
        CREATED_DT,
        ACTIVE
    from {{ ref('ODS__CARMA__REQUEST_SALES') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data