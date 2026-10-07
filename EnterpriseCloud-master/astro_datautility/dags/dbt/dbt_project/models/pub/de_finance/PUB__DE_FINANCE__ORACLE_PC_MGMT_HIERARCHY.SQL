{{ config(
        materialized='view',
         alias='ORACLE_PC_MGMT_HIERARCHY',
         transient=false
) }}

with SOURCE_DATA AS (
    SELECT 
        *
    FROM {{ ref('COMMON__SAPH__ORACLE_PC_MGMT_HIERARCHY') }}
)

SELECT * FROM SOURCE_DATA