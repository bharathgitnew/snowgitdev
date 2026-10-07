/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.57.00"
*************/

{{ config(
      materialized='view',
      alias='SERVICEORDEROPENINVOICETOTALS',
      transient=false
) }}

with source_data as (
    SELECT
        SERVICEORDER,
        TOTALAMOUNTINVOICED,
        TOTALINVOICEPARTSANDTRAVEL
    from {{ ref('COMMON__BAAN__SERVICEORDEROPENINVOICETOTALS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data