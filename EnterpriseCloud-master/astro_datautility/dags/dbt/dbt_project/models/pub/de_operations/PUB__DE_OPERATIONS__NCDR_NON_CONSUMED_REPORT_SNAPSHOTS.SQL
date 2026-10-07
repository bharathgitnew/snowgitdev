
{{ config(
    alias = 'NCDR_NON_CONSUMED_REPORT_SNAPSHOTS',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__NCDR_NON_CONSUMED_REPORT_SNAPSHOTS') }} 
)

select * from source_data
