{{ config(
        materialized='view',
        alias='GROSS_SALES_BY_COUNTRY_STATE_CITY',
        transient=false
) }}

with source_data as (
    select
        * EXCLUDE (_AUDIT_LOG_ID, _ROW_HASH)
    from {{ ref('COMMON__REPORTS__GROSS_SALES_BY_COUNTRY_STATE_CITY_FIN01') }}
)

select * from source_data