/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.32"
*************/

{{ config(
      materialized='view',
      alias='TEACPPPARTS',
      transient=false
) }}

with source_data as (
    SELECT
        ITEMID,
        DOESEXIST
    from {{ ref('ODS__MDM__TEACPPPARTS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data