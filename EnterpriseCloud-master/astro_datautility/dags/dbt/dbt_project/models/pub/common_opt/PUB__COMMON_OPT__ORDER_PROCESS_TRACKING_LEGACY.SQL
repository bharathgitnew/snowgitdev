{{ config(
    materialized='view',
    alias='ORDER_PROCESS_TRACKING_LEGACY',
    transient=false
) }}


with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH,_FILEDATE,_FILENAME, _UPLOADDATE)
    FROM {{ ref('COMMON__OPT__ORDER_PROCESS_TRACKING_LEGACY') }}

),

transform_data AS
(
    select * from source_data
)

    select * from transform_data