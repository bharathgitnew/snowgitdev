/************
Model file generated from dbtGeneratePubViews: 03.09.2022.11.01.18"
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
    from {{ ref('ODS__MDM__CONTRACT_FLX_TRANSITIONHRS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data