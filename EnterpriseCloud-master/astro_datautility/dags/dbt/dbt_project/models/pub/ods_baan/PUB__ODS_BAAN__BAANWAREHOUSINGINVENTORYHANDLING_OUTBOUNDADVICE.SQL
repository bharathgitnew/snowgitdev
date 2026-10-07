/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.27"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        ACTIVITY,
        ACTUALSTORAGEUNIT,
        ADVICENUMBER,
        ADVICEQUANTITYININVENTORYUNIT,
        ADVICEQUANTITYINSTORAGEUNIT,
        BOMLINE,
        CONSIGNMENTDESCRIPTION,
        CONSIGNMENTID,
        INVENTORYDATE,
        ITEM,
        LOCATION,
        LOT,
        ORDER_LINE,
        ORDER_NUMBER,
        ORDER_ORIGINDESCRIPTION,
        ORDER_ORIGINID,
        PACKAGEDEFINITION,
        PICKEDDESCRIPTION,
        PICKEDID,
        PICKINGMISSION,
        PICKINGSEQUENCE,
        PROCEDUREMASK,
        RELEASEDDESCRIPTION,
        RELEASEDID,
        SEQUENCENUMBER,
        _SET,
        STAGINGLOCATION,
        TIME,
        TIMEINMILLISECONDS,
        WAREHOUSE,
        WAVENUMBER
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGINVENTORYHANDLING_OUTBOUNDADVICE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data