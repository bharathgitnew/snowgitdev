{{ config(
        alias='DAYS_OF_INVENTORY_MASTER',
        SCHEMA='SAPH',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite'
) }}

with baan_data as 
(
    select 
        item
        , period
        , sum(qty) as qty
        , upper(sold_to_bp) like 'INTEL%' as INTEL_FLAG
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER') }}
    group by 
        item
        , period 
        , INTEL_FLAG 
),

sap_sales_data as
(
    select 
        MATERIAL_NUMBER_LIPS as item
        , to_char(to_date(vbak_delivery_create_date,'yyyymmdd'),'yyyy-mm') as PERIOD
        , sum(ACTUAL_QUANTITY_DELIVERED) as Qty
        , customer_group = 'Z1' as INTEL_FLAG
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__SALES_ORDER_DELIVERY_LINE') }}
    where MATERIAL_NUMBER_LIPS is not null
    and LIKP_SOLD_TO_PARTY != 'BA0010100'
    group by 
        material_number_lips
        ,to_char(to_date(vbak_delivery_create_date,'yyyymmdd'),'yyyy-mm')
        ,INTEL_FLAG
),

combined_data as
(
    select 
        sap_sales_data.item
        , sap_sales_data.PERIOD
        , sap_sales_data.QTY
        , INTEL_FLAG
    from sap_sales_data

    union all
    
    select 
        baan_data.ITEM
        , baan_data.PERIOD
        , baan_data.QTY
        , INTEL_FLAG
    from baan_data
),

summarised_data  as 
(
    select 
        item
        ,period
        ,to_date(period||'-01','yyyy-mm-dd') as firstdate
        ,sum(qty) as qty
        ,INTEL_FLAG
    from combined_data
    group by 
        item
        , period
        , INTEL_FLAG
    order by 
        item
        , period DESC
),

sales_pivot as
(
    select item
    ,sum(case when firstdate between trunc(add_months(current_date,-1),'MONTH') and last_day(add_months(current_date,-1)) then qty else 0 end ) as mth1
    ,sum(case when firstdate between trunc(add_months(current_date,-2),'MONTH') and last_day(add_months(current_date,-2)) then qty else 0 end ) as mth2
    ,sum(case when firstdate between trunc(add_months(current_date,-3),'MONTH') and last_day(add_months(current_date,-3)) then qty else 0 end ) as mth3
    ,sum(case when firstdate between trunc(add_months(current_date,-4),'MONTH') and last_day(add_months(current_date,-4)) then qty else 0 end ) as mth4
    ,sum(case when firstdate between trunc(add_months(current_date,-5),'MONTH') and last_day(add_months(current_date,-5)) then qty else 0 end ) as mth5
    ,sum(case when firstdate between trunc(add_months(current_date,-6),'MONTH') and last_day(add_months(current_date,-6)) then qty else 0 end ) as mth6
    ,sum(case when firstdate between trunc(add_months(current_date,-7),'MONTH') and last_day(add_months(current_date,-7)) then qty else 0 end ) as mth7
    ,sum(case when firstdate between trunc(add_months(current_date,-8),'MONTH') and last_day(add_months(current_date,-8)) then qty else 0 end ) as mth8
    ,sum(case when firstdate between trunc(add_months(current_date,-9),'MONTH') and last_day(add_months(current_date,-9)) then qty else 0 end ) as mth9
    ,sum(case when firstdate between trunc(add_months(current_date,-10),'MONTH') and last_day(add_months(current_date,-10)) then qty else 0 end ) as mth10
    ,sum(case when firstdate between trunc(add_months(current_date,-11),'MONTH') and last_day(add_months(current_date,-11)) then qty else 0 end ) as mth11
    ,sum(case when firstdate between trunc(add_months(current_date,-12),'MONTH') and last_day(add_months(current_date,-12)) then qty else 0 end ) as mth12
    ,sum(case when firstdate between trunc(add_months(current_date,-3),'MONTH') and last_day(add_months(current_date,-1)) then qty else 0 end ) as total_3month_sales
    ,sum(case when firstdate between trunc(add_months(current_date,-12),'MONTH') and last_day(add_months(current_date,-1)) then qty else 0 end ) as total_12month_sales
    ,INTEL_FLAG
    from summarised_data
    group by item, INTEL_FLAG
    order by item
),

inv_data as
(
    select 
        inv.MATERIAL
        ,inv.plant
        ,case when length(inv.storage_location)>4 then KNA1.NAME_1 else inv.storage_location end as STORAGE_LOCATION
        ,inv.year_month_text
        ,inv.ON_HAND
        ,row_number() over (partition by inv.material,inv.plant,inv.storage_location order by inv.year_month_text desc) as rn
        ,(knvv.kdgrp is not null and knvv.kdgrp = 'Z1') INTEL_FLAG
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__INVENTORY_HISTORY_SUMMARY') }} inv   
    left join (SELECT NAME_1,CUSTOMER_NUMBER FROM {{ ref('SILVER__TEA_DIRECT_PURCHASING__BUSINESS_PARTNERS_GENERAL_DATA') }} WHERE CUSTOMER_FLAG='Y')  KNA1 
    on KNA1.CUSTOMER_NUMBER = inv.storage_location
    left join {{ ref('BRONZE__TEA_DIRECT_PURCHASING__SAPAPI_ZCDV_T_CMTU021_KNVV') }} KNVV on kna1.CUSTOMER_NUMBER = knvv.kunnr
    where inv.material != ''
    order by inv.material,inv.storage_location, inv.year_month_text desc
),

source_data as 
(
    select 
        invd.MATERIAL
        ,invd.PLANT
        ,invd.STORAGE_LOCATION
        ,invd.ON_HAND
        ,cp.mth1
        ,cp.mth2
        ,cp.mth3
        ,cp.mth4
        ,cp.mth5
        ,cp.mth6
        ,cp.mth7
        ,cp.mth8
        ,cp.mth9
        ,cp.mth10
        ,cp.mth11
        ,cp.mth12
        ,case when cp.total_12month_sales <= 0 then 0 else round(invd.ON_HAND/(cp.total_12month_sales/365),2) end as DOI_12_months
        ,case when cp.total_3month_sales <= 0 then 0 else round(invd.ON_HAND/(cp.total_3month_sales/91.5),2) end as DOI_3_months
        ,invd.INTEL_FLAG as SALES_INTEL_FLAG
        ,cp.INTEL_FLAG as INV_INTEL_FLAG
    from inv_data invd 
    left join sales_pivot cp on cp.item = invd.Material and cp.INTEL_FLAG = invd.INTEL_FLAG
    where invd.rn =1 
    order by 
        invd.MATERIAL
        , invd.storage_location 
),

	transform_data as
(
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
		MATERIAL,
		PLANT,
		STORAGE_LOCATION,
		ON_HAND,
		MTH1,
		MTH2,
		MTH3,
		MTH4,
		MTH5,
		MTH6,
		MTH7,
		MTH8,
		MTH9,
		MTH10,
		MTH11,
		MTH12,
		DOI_12_MONTHS,
		DOI_3_MONTHS,
		SALES_INTEL_FLAG,
		INV_INTEL_FLAG 
    FROM source_data
),

	type_data as
(
    select 
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
		cast(MATERIAL as VARCHAR(16777216)) as MATERIAL,
		cast(PLANT as VARCHAR(16777216)) as PLANT,
		cast(STORAGE_LOCATION as VARCHAR(16777216)) as STORAGE_LOCATION,
		cast(ON_HAND as NUMBER(38,10)) as ON_HAND,
		cast(MTH1 as NUMBER(38,10)) as MTH1,
		cast(MTH2 as NUMBER(38,10)) as MTH2,
		cast(MTH3 as NUMBER(38,10)) as MTH3,
		cast(MTH4 as NUMBER(38,10)) as MTH4,
		cast(MTH5 as NUMBER(38,10)) as MTH5,
		cast(MTH6 as NUMBER(38,10)) as MTH6,
		cast(MTH7 as NUMBER(38,10)) as MTH7,
		cast(MTH8 as NUMBER(38,10)) as MTH8,
		cast(MTH9 as NUMBER(38,10)) as MTH9,
		cast(MTH10 as NUMBER(38,10)) as MTH10,
		cast(MTH11 as NUMBER(38,10)) as MTH11,
		cast(MTH12 as NUMBER(38,10)) as MTH12,
		cast(DOI_12_MONTHS as NUMBER(38,10)) as DOI_12_MONTHS,
		cast(DOI_3_MONTHS as NUMBER(38,10)) as DOI_3_MONTHS,
		cast(SALES_INTEL_FLAG as BOOLEAN) as SALES_INTEL_FLAG,
		cast(INV_INTEL_FLAG as BOOLEAN) as INV_INTEL_FLAG
    from transform_data
)

select * from type_data