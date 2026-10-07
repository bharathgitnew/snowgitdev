/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.30"
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
    from {{ ref('ODS__MDM__SALESACCOUNTREGION') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data