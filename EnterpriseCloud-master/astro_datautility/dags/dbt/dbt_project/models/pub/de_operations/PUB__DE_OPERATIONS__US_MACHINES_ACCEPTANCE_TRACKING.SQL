{{ config(
        alias = 'US_MACHINES_ACCEPTANCE_TRACKING',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__US_MACHINES_ACCEPTANCE_TRACKING') }} 
)

select * from source_data