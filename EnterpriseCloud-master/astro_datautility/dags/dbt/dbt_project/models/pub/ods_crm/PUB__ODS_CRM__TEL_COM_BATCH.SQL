{{ config(
    alias = 'TEL_COM_BATCH',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_COM_BATCH') }} 
)

select * from source_data