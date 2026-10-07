/************
Model file generated from dbtGeneratePubViews: 04.05.2022.12.11.10"
*************/

{{ config(
      materialized='view',
      alias='CONTRACTFLXTRANSITIONHRS',
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
    from {{ ref('COMMON__MDM__CONTRACTFLXTRANSITIONHRS') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data