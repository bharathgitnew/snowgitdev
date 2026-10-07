{{ config(
        alias = 'WISDOM_FCN_ANNOUNCEMENT_EVIDENCE_US',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__WISDOM__FCN_ANNOUNCEMENT_EVIDENCE_US') }} 
)

select * from source_data