{{ config(
        alias = 'SAPAPI_ZCDV_T_CMTU017_MARA',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude(_AUDIT_LOG_ID, _ROW_HASH) 
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU017_MARA') }} 
)

select * from source_data