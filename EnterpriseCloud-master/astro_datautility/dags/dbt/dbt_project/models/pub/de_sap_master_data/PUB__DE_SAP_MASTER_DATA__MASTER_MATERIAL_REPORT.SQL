{{ config(
    materialized='view',
    alias='MASTER_MATERIAL_REPORT',
    transient=false
) }}

with source_data as (
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__MASTER_MATERIAL_REPORT') }}
)

SELECT * FROM source_data
