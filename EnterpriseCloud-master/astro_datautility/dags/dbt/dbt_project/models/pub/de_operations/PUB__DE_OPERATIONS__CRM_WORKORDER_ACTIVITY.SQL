
{{ config(
    alias = 'CRM_WORKORDER_ACTIVITY',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__CRM__WORKORDER_ACTIVITY') }} 
)

select * from source_data
