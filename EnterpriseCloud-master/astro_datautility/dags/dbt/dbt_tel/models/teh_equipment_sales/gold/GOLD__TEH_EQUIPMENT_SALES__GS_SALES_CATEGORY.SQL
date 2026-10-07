{{ config(
      materialized='tel_incremental',
    incremental_strategy='insert_overwrite'  ,
    alias='GS_SALES_CATEGORY'  
) }}


with source_data as
(
SELECT DISTINCT
    SALESCATEGORYNAME   AS Sales_Category,
    SALESCATEGORYCODE   AS Sales_Category_Code
FROM {{ ref('SILVER__TEH_EQUIPMENT_SALES__FILE_TEL_GS_REVENUE_BUDGET_FORECAST') }}
ORDER BY Sales_Category_Code ASC
)

,transform_data as
(
  SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        SALES_CATEGORY,
        SALES_CATEGORY_CODE
FROM source_data
)

,type_data as 
(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(SALES_CATEGORY as VARCHAR(16777216)) as SALES_CATEGORY,
        cast(SALES_CATEGORY_CODE as VARCHAR(16777216)) as SALES_CATEGORY_CODE
from transform_data
    )
select * from type_data