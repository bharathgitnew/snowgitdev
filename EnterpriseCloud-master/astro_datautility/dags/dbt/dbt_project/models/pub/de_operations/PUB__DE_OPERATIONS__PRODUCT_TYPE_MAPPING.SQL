{{ config(
      materialized='view',
      alias='PRODUCT_TYPE_MAPPING',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__SHARED_DATASETS__PRODUCT_TYPE_MAPPING') }}
)

SELECT * FROM source_data