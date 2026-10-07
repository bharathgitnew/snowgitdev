{{ config(
      materialized='view',
      alias='COMPANY',
      transient=false
) }}


with source_data as (
    select
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__SHARED_DATASETS__COMPANY') }}


),

transform_data AS
(
    select * from source_data
)

    select * from transform_data