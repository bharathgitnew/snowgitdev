{{ config(
      materialized='view',
      alias='PO_SN_TRACKER',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__PO_SN_TRACKER') }}
)

SELECT * FROM source_data