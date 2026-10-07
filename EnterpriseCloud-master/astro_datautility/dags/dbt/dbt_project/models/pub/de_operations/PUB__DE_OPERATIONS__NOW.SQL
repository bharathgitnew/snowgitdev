{{ config(
      materialized='view',
      alias='NOW',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__NOW') }}
)

SELECT * FROM source_data