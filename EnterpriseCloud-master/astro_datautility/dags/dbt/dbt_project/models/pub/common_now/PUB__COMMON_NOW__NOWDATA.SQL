{{ config(
      materialized='view',
      alias='NOWDATA',
      transient=false
) }}


with source_data as (
    SELECT
        * exclude(_FILEDATE,_FILENAME,AUDIT_LOG_ID,_ROW_HASH)
    from {{ ref('COMMON__NOW__NOWDATA') }}
),

transform_data AS
(
    select * from source_data
)

    select * from transform_data