
     {{ config(
        materialized='view',
        alias='TEA_EXTERNAL_SPARES_REVENUE_ACTUAL',
        transient=false
    ) }}  

    with source_data as (
        SELECT
            * exclude(_AUDIT_LOG_ID,_ROW_HASH,SALES_ACCOUNT_BU_NEW)
        FROM {{ ref('COMMON__REPORTS__TEA_EXTERNAL_SPARES_REVENUE_ACTUAL') }}
         order by SALES_ACCOUNT_BU_NEW asc
        
    )
    SELECT * FROM source_data
   
   