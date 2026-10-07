/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.18"
*************/

{{ config(
      materialized='view',
      alias='ACTIVEASSETREPORT',
      transient=false
) }}

with source_data as (
    SELECT
        CONTRACT_NUMBER,
        COMMENCEMENT,
        TERM,
        TERMINATION,
        DELL_ORDER_NUMBER,
        ASSET_ID,
        EQUIPMENT_DESCRIPTION,
        SERVICE_TAG,
        PURCHASE_ORDER_NUM,
        _FILEDATE
    from {{ ref('ODS__FILE__ACTIVEASSETREPORT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data