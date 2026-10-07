/************
Model file generated from dbtGeneratePubViews: 03.10.2022.08.14.08"
*************/

{{ config(
      materialized='view',
      alias='BAANDISTRIBUTIONTEACUSTOMIZATIONS_SPLITDELIVERYMAPPINGTABLE',
      transient=false
) }}

with source_data as (
    SELECT
        _CAPTUREDATETIME,
        _COMPANYID,
        SEQUENCENUMBER,
        VALUE
    from {{ ref('ODS__BAAN__BAANDISTRIBUTIONTEACUSTOMIZATIONS_SPLITDELIVERYMAPPINGTABLE') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data