{{ config(
      materialized='view',
      alias='NCDR_REPORT',
      transient=false
) }}

WITH source_data AS 
(
    SELECT
        * exclude (AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__NCDR_REPORT') }} 
)

SELECT * FROM source_data