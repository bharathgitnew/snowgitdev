/************
Model file generated from dbtGeneratePubViews: 12.19.2022.19.11.44"
*************/

{{ config(
      materialized='view',
      alias='OPPORTUNITY',
      transient=false
) }}

with source_data as (
    SELECT
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__CRM__OPPORTUNITY') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data