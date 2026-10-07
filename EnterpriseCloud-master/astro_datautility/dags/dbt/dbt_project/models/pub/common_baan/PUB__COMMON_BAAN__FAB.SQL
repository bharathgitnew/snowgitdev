/************
Model file generated from dbtGeneratePubViews: 04.08.2022.10.56.59"
*************/

{{ config(
      materialized='view',
      alias='FAB',
      transient=false
) }}

with source_data as (
    SELECT
        FABID,
        CUSTOMERID,
        SOLDTOCUSTOMERID,
        SERVICECENTEROFFICEID,
        ISEXPIRED
    from {{ ref('COMMON__BAAN__FAB') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data