/************
Model file generated from dbtGeneratePubViews: 10.12.2022.17.09.20"
*************/

{{ config(
      materialized='view',
      alias='BAANV_ALL_ITEM_GROUPS',
      transient=false
) }}

with source_data as (
    SELECT
        COMPANY_NO,
        ITEM_GROUP,
        DESCRIPTION
    from {{ ref('ODS__TEA93TEL_REPORTING__BAANV_ALL_ITEM_GROUPS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data