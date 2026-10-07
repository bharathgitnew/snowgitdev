{{ config(
      materialized='view',
      alias='MATERIAL_MASTER',
      transient=false
) }}

with source_data as (
    SELECT
    	* exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__MASTER_MATERIAL_REPORT') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data