
{{ config(
    alias = 'TEL_CNT_FIXTYPECONTRACTMONTHLYINFORMATION',
    materialized = 'view',
    transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_CNT_FIXTYPECONTRACTMONTHLYINFORMATION') }} 
)

select * from source_data
