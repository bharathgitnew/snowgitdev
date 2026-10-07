
{{ config(
    materialized='view',
    alias='SAP_BUSINESS_UNIT',
    transient=false
) }}  

with source_data as (
    SELECT
        * exclude(_AUDIT_LOG_ID,_ROW_HASH)
    FROM {{ ref('COMMON__DE_SAP_MASTER_DATA__SAP_BUSINESS_UNIT') }}
    
),
transform_data as (
    SELECT
        *
    FROM source_data
),
type_data as (
    SELECT
        *
    FROM transform_data
)
SELECT * FROM type_data
    