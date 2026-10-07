{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='SUPPLIERS',
    	  transient=false
) }}

with suppliers as 
(
    SELECT
        DISTINCT
        EINA.LIFNR  ,          -- (Info Record)
        FROM {{ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU073_EINE')}} eine
        inner join {{ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU074_EINA')}} eina 
        on eina.INFNR = eine.infnr
    WHERE EKORG = '3200'
),

source_data as (
   SELECT
        ds.vendor_number as Supplier_Number, 
        ds.vendor_name as Supplier_Name,
        ds.diversity_type,
        ds.minority_indicator,
        vm.bu_group,
        vm.partner_function_code,
        sum(ids.total_invoice_price) as supplier_indirect_spend,
        sum(drs.total_invoice_price) as supplier_direct_spend,
        -- COUNT(DISTINCT ds.vendor_number) AS supplier_count,
        case when s.lifnr is not null then 'DIRECT' 
        ELSE 'INDIRECT' END as supplier_type,
        SUM(
            COALESCE(ids.total_invoice_price, 0) + COALESCE(drs.total_invoice_price, 0)
        ) AS total_spend
        
    FROM
    {{ref('GOLD__TEH_PROCUREMENT__DIVERSE_SUPPLIER')}}  ds
    LEFT JOIN {{ref('GOLD__TEH_PROCUREMENT__INDIRECT_SPEND_NON_PO')}} AS ids ON ds.vendor_number = ids.vendor_number
    LEFT JOIN {{ref('GOLD__TEH_PROCUREMENT__DIRECT_SPEND_NON_PO')}} AS drs ON drs.vendor_number = ds.vendor_number
    LEFT JOIN {{ref('GOLD__TEH_PROCUREMENT__VENDOR_MASTER')}} AS vm ON ds.vendor_number = vm.business_partner
    left join suppliers s on s.lifnr = ds.vendor_number
    GROUP BY
    all
    ),	
transform_data as (
	SELECT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID
    ,SHA2('hash_me') AS _ROW_HASH -- Adds column to table on full refresh.
    ,SUPPLIER_NUMBER
    ,SUPPLIER_NAME
    ,DIVERSITY_TYPE
    ,MINORITY_INDICATOR
    ,BU_GROUP
    ,PARTNER_FUNCTION_CODE
    ,SUPPLIER_INDIRECT_SPEND
    ,SUPPLIER_DIRECT_SPEND
    ,SUPPLIER_TYPE
    ,TOTAL_SPEND
from source_data
)

select * from transform_data