{{ config(
      materialized='view',
      alias='NCDR_NON_CONSUMED_REPORT',
      transient=false
) }}

WITH source_data AS 
(
    SELECT 
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__NCDR_NON_CONSUMED_REPORT') }} 
)

SELECT * FROM source_data