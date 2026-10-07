{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='SAPH_INVENTORY_HISTORY_SUMMARY',
      transient=false,
    
) }}

with MATDOC_SUMMARY as (
    select 
        MATDOC.MATERIAL_IN_RESPECT_OF_WHICH_STOCK_IS_MANAGED as MATERIAL
        , MATDOC.PLANT_WERKS as PLANT
        , case when MATDOC.STORAGE_LOCATION_LGORT_SID ='' then MATDOC.CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID else MATDOC.STORAGE_LOCATION_LGORT_SID end as STORAGE_LOCATION
        , case when MATDOC.STORAGE_LOCATION_LGORT_SID ='' then 'CONSIGNMENT' else 'STANDARD WHS' end as SLOC_TYPE
        , CAL.YEAR_MONTH_TEXT
        , SUM(MATDOC.STOCK_QUANTITY) AS STOCK_QTY
        , SUM(MATDOC.AMOUNT_IN_LOCAL_CURRENCY_WITH_SIGN_OF_STOCK_QUANTITY) AS STOCK_VALUE
        , MATDOC.MATERIAL_GROUP_1 as BU
        , case when MATDOC.MATERIAL_GROUP_2 = '0' then 'Non-Consumable' else 'Consumable' end as Consumable
        , case when substr(MATDOC.STORAGE_LOCATION_LGORT_SID,3,1) = '3' or KNVV.kdgrp = 'Z1' then 'Intel' else 'Non-Intel' end as Intel
    from {{ ref('SILVER__TEA_INTEL_SMS__INVENTORY_SALES_MATERIAL') }} MATDOC
    join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} CAL on CAL.CALENDAR_DATE = to_date(MATDOC.DAY_ON_WHICH_ACCOUNTING_DOCUMENT_WAS_ENTERED,'YYYYMMDD') -- replace with ref

    left join {{ ref('SILVER__TEA_INTEL_SMS__BUSINESS_PARTNERS_GENERAL_DATA') }}  KNA1 on KNA1.business_partner_number = MATDOC.CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID
    left join {{ ref('BRONZE__TEA_INTEL_SMS__SAPAPI_ZCDV_T_CMTU021_KNVV') }} KNVV on kna1.business_partner_number = knvv.kunnr
    where MATDOC.PLANT_WERKS in ('3200' ,'3300','3400')
    group by MATDOC.MATERIAL_IN_RESPECT_OF_WHICH_STOCK_IS_MANAGED
    , MATDOC.PLANT_WERKS
    , CAL.YEAR_MONTH_TEXT
    , MATDOC.MATERIAL_GROUP_1
    , case when MATDOC.MATERIAL_GROUP_2 = '0' then 'Non-Consumable' else 'Consumable' end
    , case when substr(MATDOC.STORAGE_LOCATION_LGORT_SID,3,1) = '3' or KNVV.kdgrp = 'Z1' then 'Intel' else 'Non-Intel' end
    , case when MATDOC.STORAGE_LOCATION_LGORT_SID ='' then MATDOC.CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID else MATDOC.STORAGE_LOCATION_LGORT_SID end 
    , case when MATDOC.STORAGE_LOCATION_LGORT_SID ='' then 'CONSIGNMENT' else 'STANDARD WHS' end
    order by MATDOC.PLANT_WERKS,  cal.year_month_text
),

source_data as (
    select distinct
        MATERIAL
        ,PLANT
        ,STORAGE_LOCATION
        ,SLOC_TYPE
        ,YEAR_MONTH_TEXT
        , SUM(STOCK_QTY) OVER (PARTITION BY MATERIAL, PLANT, STORAGE_LOCATION ORDER BY YEAR_MONTH_TEXT  ) AS ON_HAND
        , ROUND(SUM(STOCK_VALUE) OVER (PARTITION BY MATERIAL, PLANT, STORAGE_LOCATION  ORDER BY YEAR_MONTH_TEXT  ),2) AS STOCK_VALUE
        , BU
        , Consumable
        , Intel
    from MATDOC_SUMMARY
    ORDER BY MATERIAL, PLANT, STORAGE_LOCATION, YEAR_MONTH_TEXT


),

transform_data AS
(
    select 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
    SHA2('hash_me') as _ROW_HASH,
    a.* from source_data a
)

    select * from transform_data