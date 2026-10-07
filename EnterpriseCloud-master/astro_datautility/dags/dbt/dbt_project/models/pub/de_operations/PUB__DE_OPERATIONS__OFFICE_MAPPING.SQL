{{ config(
      materialized='view',
      alias='OFFICE_MAPPING',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__SHARED_DATASETS__OFFICE_MAPPING') }}
)

SELECT * FROM source_data