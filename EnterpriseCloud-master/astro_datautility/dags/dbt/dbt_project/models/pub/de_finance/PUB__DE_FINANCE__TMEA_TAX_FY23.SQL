{{ config(
        materialized='view',
    	alias='TMEA_TAX_FY23',
    	transient=false
) }}


with SOURCE_DATA AS (
    SELECT 
        * exclude(_AUDIT_LOG_ID,_ROW_HASH,_REFRESHDATE)
    FROM {{ ref('COMMON__REPORTS__TMEA_TAX_FY23') }}
)

SELECT * FROM SOURCE_DATA