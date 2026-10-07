{{ config(
        materialized='view',
        schema='DE_OPERATIONS',
        alias='TIRS_INCIDENT_TYPE_SUMMARY',
        transient=false
) }}

with source_data as (
    SELECT
        * exclude (AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__REPORTS__TIRS_INCIDENT_TYPE_SUMMARY') }}
)

select * from source_data