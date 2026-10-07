{{ config(
      materialized='view',
      alias='CRM_MACHINES_US',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__CRM__CRM_MACHINES_US') }}
)

SELECT * FROM source_data