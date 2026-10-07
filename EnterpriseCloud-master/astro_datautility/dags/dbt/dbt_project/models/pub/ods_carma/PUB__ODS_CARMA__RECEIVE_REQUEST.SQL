/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.28.52"
*************/

{{ config(
      materialized='view',
      alias='RECEIVE_REQUEST',
      transient=false
) }}

with source_data as (
    SELECT
        RECEIVE_REQUEST_ID,
        RMA_ID,
        QTY_RECEIVED,
        RECEIVED_DT,
        DAMAGED_IN_TRANSIT,
        RMA_OVERAGE_ACCEPTED,
        QTY_OVERAGE,
        DAMAGED_FURTHER_IN_TRANSIT,
        INBOUND_SHIPPING_CARRIER,
        INBOUND_TRACKING_NBR,
        HAS_PART_BEEN_RECEIVED,
        HAS_PART_BEEN_EXPIRED,
        HAS_REFUSED_DELIVERY,
        INACTIVE_DT,
        CREATED_DT,
        ACTIVE,
        RECEIVING_USERS_ACTION,
        REOPEN_DT,
        REOPEN_USER_ID
    from {{ ref('ODS__CARMA__RECEIVE_REQUEST') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data