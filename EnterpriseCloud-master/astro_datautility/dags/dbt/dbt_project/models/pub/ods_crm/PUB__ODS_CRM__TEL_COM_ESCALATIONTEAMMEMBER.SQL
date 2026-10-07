{{ config(
        alias = 'TEL_COM_ESCALATIONTEAMMEMBER',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_COM_ESCALATIONTEAMMEMBER') }} 
)

select * from source_data