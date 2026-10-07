{{ config(
        materialized='view',
        alias='GENERAL_LEDGER_DETAIL_TAX',
        transient=false
) }}

with source_data as (
    select
        * EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS_GMX__GENERAL_LEDGER_DETAIL_TAX') }}
)

select * from source_data