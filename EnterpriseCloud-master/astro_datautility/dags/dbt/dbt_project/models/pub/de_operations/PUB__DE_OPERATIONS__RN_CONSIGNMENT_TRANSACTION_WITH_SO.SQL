{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='RN_CONSIGNMENT_TRANSACTION_WITH_SO',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_FILENAME,_FILEDATE,_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__ROSETTA__RN_CONSIGNMENT_TRANSACTION_WITH_SO') }}
)

select * from source_data