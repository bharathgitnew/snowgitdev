/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.25"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTIVITY,
        COSTLINE,
        ITEM,
        ORDER_QTY,
        POADVICE,
        POSITION,
        PURCHASEORDER,
        RECEIVEDQUANTITY,
        SEQUENCE,
        SERVICEORDER,
        SERVICEORDERTEXT,
        STATUSDESCRIPTION,
        STATUSID,
        UNIT
    from {{ ref('ODS__BAAN__BAANSERVICESERVICEORDERCONTROL_SERVICEORDER_POLINK') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data