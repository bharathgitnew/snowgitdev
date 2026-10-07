/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.23"
*************/

{{ config(
      materialized='view',
      alias='BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS',
      transient=false
) }}

with source_data as (
    SELECT
        SERVICEORDER,
        LINENUMBER,
        ITEM,
        SERVICECONTRACTNUMBER,
        ACTUALWAREHOUSE,
        CONFIGURATION,
        SERIALNUMBER
    from {{ ref('ODS__BAAN__BAANSERVICESERVICEORDERCONTROL_SERVICEORDERITEMS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data