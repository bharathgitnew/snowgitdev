/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.12"
*************/

{{ config(
      materialized='view',
      alias='SALESACCOUNTREGION',
      transient=false
) }}

with source_data as (
    SELECT
        STATEORPROVINCE,
        REGION
    from {{ ref('COMMON__MDM__SALESACCOUNTREGION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data