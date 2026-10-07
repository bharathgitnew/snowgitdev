/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.28"
*************/

{{ config(
      materialized='view',
      alias='BAANWAREHOUSINGLOTCONTROL_LOTS',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        BUSINESSPARTNERSLOTCODE,
        BUYFROMBUSINESSPARTNER,
        CERTIFICATENUMBER,
        E_ITEMREVISION,
        FIRSTISSUEDATE,
        FIRSTRECEIPTDATE,
        ITEM,
        LOT,
        LOTDATE,
        LOTSELECTIONDESCRIPTION,
        LOTSELECTIONID,
        LOTSIZE,
        LOTTYPEDESCRIPTION,
        LOTTYPEID,
        ORDER_,
        POTENCY,
        TEXT
    from {{ ref('ODS__BAAN__BAANWAREHOUSINGLOTCONTROL_LOTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data