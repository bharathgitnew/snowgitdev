{{ config(
    materialized='view',
    alias='FBR_ACCOUNTS_RECEIVABLE_AGING',
    transient=false
) }}

WITH SOURCE_DATA AS (
    SELECT
        *
        exclude (_AUDIT_LOG_ID, _ROW_HASH )
    FROM {{ ref('COMMON__REPORTS__FBR_ACCOUNTS_RECEIVABLE_AGING') }}
)

SELECT * FROM SOURCE_DATA