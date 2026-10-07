{{ config(
      materialized='view',
      alias='US_MACHINES',
      transient=false
) }}


with source_data as (
    select
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__DE_WISDOM__US_MACHINES') }} 

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data