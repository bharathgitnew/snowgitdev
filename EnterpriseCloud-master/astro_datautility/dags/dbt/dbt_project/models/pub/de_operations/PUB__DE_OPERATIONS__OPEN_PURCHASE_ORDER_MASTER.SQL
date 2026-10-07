{{ config(
        materialized='view',
        alias='OPEN_PURCHASE_ORDER_MASTER',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__OPEN_PURCHASE_ORDER_MASTER') }}
)

select * from source_data