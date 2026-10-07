
{{ config(
    alias = 'CAMPAIGN',
    materialized = 'view'
) }}

with source_data as (
    select
        * exclude (_AUDIT_LOG_ID, _ROW_HASH, _FILENAME, _FILEDATE, _UPLOADDATE)
    from {{ ref('ODS__FILE__CAMPAIGN') }} 
)

select * from source_data
