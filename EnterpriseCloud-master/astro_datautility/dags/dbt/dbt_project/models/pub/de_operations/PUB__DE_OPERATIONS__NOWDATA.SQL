{{ config(
      alias='NOWDATA',
      materialized='view',
) }}


with source_data as (
    select 
        * exclude(AUDIT_LOG_ID, _ROW_HASH) 
    from {{ ref('COMMON__NOW__NOWDATA') }}
)

select * from source_data