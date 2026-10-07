{{ config(
        alias = 'TEL_WO_PJ3CODE_MAPPING',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_WO_PJ3CODE_MAPPING') }} 
)

select * from source_data