{{ config(
      materialized='view',
      alias='CRM_WORKORDER_BOOKINGS_US',
      transient=false
) }}

WITH source_data AS
(
    SELECT
        * exclude (_AUDIT_LOG_ID, _ROW_HASH)
    FROM {{ ref('COMMON__CRM__WORKORDER_BOOKINGS_US') }}
)

SELECT * FROM source_data