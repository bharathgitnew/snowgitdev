{{ config(
        alias = 'TEL_SM_REV_REC_CRITERIA_BEFORE_MOD',
        materialized = 'view',
        transient = false
) }}

with source_data as (
    select
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('ODS__CRM_FILE__TEL_SM_REV_REC_CRITERIA_BEFORE_MOD') }} 
)

select * from source_data