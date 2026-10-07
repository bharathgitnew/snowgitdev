{{ config(
        alias = 'TEL_PO_CAPACITYHEADER',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_PO_CAPACITYHEADER') }} 
)

select * from source_data