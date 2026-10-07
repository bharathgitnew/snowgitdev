
{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='TPS',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_FILENAME,_FILEDATE,_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__RTISS__TPS') }}
)

select * from source_data