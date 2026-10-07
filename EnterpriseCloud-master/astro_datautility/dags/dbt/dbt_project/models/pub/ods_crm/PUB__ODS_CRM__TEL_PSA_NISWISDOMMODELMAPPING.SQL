{{ config(
        alias = 'TEL_PSA_NISWISDOMMODELMAPPING',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_PSA_NISWISDOMMODELMAPPING') }} 
)

select * from source_data