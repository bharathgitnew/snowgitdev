{{ config(
      materialized='view',
      alias='ORACLE_DEPARTMENT',
      transient=false
) }}

with source_data as (
    SELECT * exclude(_FILENAME, _FILEDATE, AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('ODS__SHAREPOINT__ORACLE_DEPARTMENT') }}
),

transform_data AS
(
    SELECT * FROM source_data
)

    SELECT * FROM transform_data