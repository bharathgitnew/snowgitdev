{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='DIRECT_PURCHASE_ORDER',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__DIRECT_PURCHASE_ORDER') }}
)

select * from source_data