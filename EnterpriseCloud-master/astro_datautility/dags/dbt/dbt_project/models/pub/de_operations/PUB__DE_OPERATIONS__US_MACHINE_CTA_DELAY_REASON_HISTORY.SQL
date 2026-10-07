{{ config(
        alias = 'US_MACHINE_CTA_DELAY_REASON_HISTORY',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__US_MACHINE_CTA_DELAY_REASON_HISTORY') }} 
)

select * from source_data