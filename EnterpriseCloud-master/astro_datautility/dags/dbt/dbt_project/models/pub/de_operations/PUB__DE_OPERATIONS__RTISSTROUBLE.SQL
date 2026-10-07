{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='RTISSTROUBLE',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__RTISS__RTISSTROUBLE') }}
)

select * from source_data