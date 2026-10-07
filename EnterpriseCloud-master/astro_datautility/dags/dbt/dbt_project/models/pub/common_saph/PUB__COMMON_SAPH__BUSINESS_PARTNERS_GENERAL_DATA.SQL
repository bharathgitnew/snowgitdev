/************
Model file generated from dbtGeneratePubViews: 12.22.2022.10.52.54"
*************/

{{ config(
      materialized='view',
      alias='BUSINESS_PARTNERS_GENERAL_DATA',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__SAPH__BUSINESS_PARTNERS_GENERAL_DATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data