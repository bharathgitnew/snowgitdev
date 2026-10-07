{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='DW_SMBWA',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__CSDPRO__DW_SMBWA') }}
)

select * from source_data