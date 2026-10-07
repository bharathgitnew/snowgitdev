/************
Model file generated from dbtGeneratePubViews: 03.16.2022.12.10.19"
*************/

{{ config(
      materialized='view',
      alias='CONTRACT_FLX_TRANSITIONHRS',
      transient=false
) }}

with source_data as (
    SELECT
        CUSTOMER_NAME,
        CONTRACT_NUMBER,
        FY21_KRONOS_HOURS,
        LOAD_DATE,
        UPDATED_FY21_HOURS,
        UPDATED_COMMENT
    from {{ source('ODS__FILE', 'CONTRACT_FLX_TRANSITIONHRS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data