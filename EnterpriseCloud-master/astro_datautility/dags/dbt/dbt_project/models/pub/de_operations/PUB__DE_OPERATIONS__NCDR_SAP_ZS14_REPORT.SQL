{{ config(
      materialized='view',
      schema='DE_OPERATIONS',
      alias='NCDR_SAP_ZS14_REPORT',
      transient=false
) }}

WITH
SOURCE_DATA AS (
    SELECT * exclude(AUDIT_LOG_ID, _ROW_HASH)  
    FROM {{ ref('COMMON__SAPH__NCDR_SAP_ZS14_REPORT') }}
),
TRANSFORM_DATA AS (
    SELECT * FROM SOURCE_DATA
)
SELECT * FROM TRANSFORM_DATA