{{ config(
    materialized='view',
    schema='DE_OPERATIONS',
    alias='DEMAND_BY_SITE_V2',
    meta = {
        "owner": "elena.stefanova@us.tel.com",
    },
) }}


WITH
SOURCE_DATA AS (
    SELECT * exclude(_AUDIT_LOG_ID,_ROW_HASH) FROM {{ ref('COMMON__REPORTS__DEMAND_BY_SITE_V2') }}
),
TRANSFORM_DATA AS (
    SELECT * FROM SOURCE_DATA
)
SELECT * FROM TRANSFORM_DATA