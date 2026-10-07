{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='QVICS_ALL_TROUBLE_NEW',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_FILENAME,_FILEDATE,_AUDIT_LOG_ID,_ROW_HASH,_UPLOADDATE)
    FROM {{ ref('COMMON__QVICS__ALL_TROUBLE_NEW') }}
)

select * from source_data
