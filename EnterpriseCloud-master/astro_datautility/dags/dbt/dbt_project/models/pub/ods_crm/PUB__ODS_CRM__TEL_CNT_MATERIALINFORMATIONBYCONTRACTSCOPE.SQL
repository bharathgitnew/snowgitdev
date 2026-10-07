
{{ config(
    alias = 'TEL_CNT_MATERIALINFORMATIONBYCONTRACTSCOPE',
    materialized = 'view',
    transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_CNT_TEL_CNT_MATERIALINFORMATIONBYCONTRACTSCOPE') }} 
)

select * from source_data
