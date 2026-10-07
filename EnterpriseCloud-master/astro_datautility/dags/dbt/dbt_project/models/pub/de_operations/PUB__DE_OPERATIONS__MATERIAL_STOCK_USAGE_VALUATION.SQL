{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='MATERIAL_STOCK_USAGE_VALUATION',
      transient=false
) }}


WITH
SOURCE_DATA AS (
    SELECT* exclude (_AUDIT_LOG_ID,_ROW_HASH) FROM {{ ref('COMMON__REPORTS__MATERIAL_STOCK_USAGE_VALUATION') }}
),
TRANSFORM_DATA AS (
    SELECT * FROM SOURCE_DATA
)
SELECT * FROM TRANSFORM_DATA