
     {{ config(
        materialized='view',
        alias='TEA_EXTERNAL_SERVICE_REVENUE_ACTUAL_BU',
        transient=false
    ) }}  

    with source_data as (
        SELECT
            * exclude(_AUDIT_LOG_ID,_ROW_HASH)
        FROM {{ ref('COMMON__REPORTS__TEA_EXTERNAL_SERVICE_REVENUE_ACTUAL_BU') }}
        
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
   