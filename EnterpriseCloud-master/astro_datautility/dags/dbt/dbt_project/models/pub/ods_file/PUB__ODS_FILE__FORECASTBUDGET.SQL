/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.19"
*************/

{{ config(
      materialized='view',
      alias='FORECASTBUDGET',
      transient=false
) }}

with source_data as (
    SELECT
        ACCOUNT,
        ENTITY,
        UD1,
        UD2,
        UD3,
        UD4,
        UD5,
        UD6,
        UD7,
        UD8,
        SCENARIO,
        YEAR,
        PERIOD,
        CURRENCY,
        AMOUNT,
        _FILEDATE
    from {{ ref('ODS__FILE__FORECASTBUDGET') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data