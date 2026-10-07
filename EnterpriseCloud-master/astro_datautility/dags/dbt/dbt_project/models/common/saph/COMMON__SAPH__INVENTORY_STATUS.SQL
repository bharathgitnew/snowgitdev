{{ config(
        materialized='incremental',
        incremental_strategy = 'insert_overwrite',
        alias = 'INVENTORY_STATUS',
        transient = false
) }}

with Z_PARAM as (
select  right(inob.OBJEK,10) as CHARG,
  AUSP.ATINN ,AUSp.ATWRT,split_part(inob.OBJEK,' ',1) as Matnr
from  {{ ref('ODS__SAPAPI__ZCDV_T_CMTU057_INOB') }} as inob
left join {{ ref('ODS__SAPAPI__ZCDV_T_CMTU056_AUSP') }} as ausp on ausp.OBJEK = inob.CUOBJ
where ausp.ATINN in ('0000000012','0000000010', '0000000013', '0000000011')
),
 
Z_PARAM_PV as (
select * from Z_PARAM
  pivot (MAX(ATWRT) for ATINN in ('0000000012'  ,'0000000010'  , '0000000013'   , '0000000011'  ))
  as p ( CHARG,MATNR,Z_STOCK_CHARG,Z_STOCK_SDATE,Z_STOCK_SERIAL,Z_STOCK_STIME)
),
nsdm_e_mchb_agg as ( 
    select 
        matbf     as matnr,
        werks,
        lgortsid as lgort,
        chargsid as charg,
        lbbsasid     as lbbsa,
        sum(stockqtyl1)       as stock_qty,
        max(gjpercurrper)     as gjper_max
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU103_MATDOC_EXTRACT') }}
    where chargsid <> ''
    and (sobkz = ''
        and (lbbsasid = '01' or lbbsasid = '02' or lbbsasid = '03' or
                lbbsasid = '04' or lbbsasid = '07' or lbbsasid = '08'))
    group by matbf, werks, lgortsid, chargsid, lbbsasid
),
nsdm_e_mchb_diff as ( 
    select
        matnr,
        werks,
        lgort,
        charg,
        max(gjper_max) as gjper,
        sum(case lbbsa when '01' then stock_qty else 0 end) as clabs,
        sum(case lbbsa when '04' then stock_qty else 0 end) as cumlm,
        sum(case lbbsa when '02' then stock_qty else 0 end) as cinsm,
        sum(case lbbsa when '08' then stock_qty else 0 end) as ceinm,
        sum(case lbbsa when '07' then stock_qty else 0 end) as cspem,
        sum(case lbbsa when '03' then stock_qty else 0 end) as cretm
    from nsdm_e_mchb_agg
    group by  matnr, werks, lgort, charg
),
stock as (
    select 
        MATNR,
        WERKS,
        LGORT,
        CHARG,
        '' as CUSTOMER_CONSIGNMENT_CODE,
        '' as CUSTOMER_CONSIGNMENT_NAME,
        CLABS as UNRESTRICTEDQUANTITY,
        CUMLM as STOCKINTRANSFER,
        CINSM as STOCKINQUALITY,
        CEINM as STOCKRESTRICTEDBATCHES,
        CSPEM as BLOCKEDSTOCK,
        CRETM as BLOCKEDSTOCKRETURNS
    from nsdm_e_mchb_diff
    union all
    select
        msku.MATNR,
        msku.WERKS,
        '' as LGORT,
        msku.CHARG,
        msku.KUNNR as CUSTOMER_CONSIGNMENT_CODE,
        KNA1.NAME1 as  CUSTOMER_CONSIGNMENT_NAME,
        msku.KULAB as UNRESTRICTEDQUANTITY,
        0 as STOCKINTRANSFER,
        0 as STOCKINQUALITY,
        0 as STOCKRESTRICTEDBATCHES,
        0 as BLOCKEDSTOCK,
        0 as BLOCKEDSTOCKRETURNS 
    from {{ ref('ODS__SAPAPI__ZCDV_T_CMTU110_MSKU') }} as msku
    left join {{ ref('ODS__SAPAPI__ZCDV_T_CMTU020_KNA1') }} as kna1 on MSKU.KUNNR = KNA1.KUNNR
),
source_data as (
select 
    stock.MATNR as MATERIAL_NUMBER,
    stock.WERKS as PLANT,
    stock.LGORT as STORAGE_LOCATION ,
    stock.CHARG as BATCH_NUMBER,
    material.MEINS as BASE_UNIT_OF_MEASURE_MATERIAL_BASE_UNIT,
    material.MEINS as BASE_UNIT_OF_MEASURE_BASE_UNIT,

    case when Z_PARAM.Z_STOCK_CHARG is not null then Z_PARAM.Z_STOCK_CHARG else '' end as WMS_BATCH_NUMBER,
case when Z_PARAM.Z_STOCK_SERIAL is not null then Z_PARAM.Z_STOCK_SERIAL else '' end as SERIAL_NUMBER,
case when Z_PARAM.Z_STOCK_SDATE is not null then Z_PARAM.Z_STOCK_SDATE else '' end as STOCK_DATE,
case when Z_PARAM.Z_STOCK_STIME is not null then Z_PARAM.Z_STOCK_STIME else '' end as STOCK_TIME,
    suM(UNRESTRICTEDQUANTITY) as UNRESTRICTED_QUANTITY,
    sum(STOCKINTRANSFER) as STOCK_IN_TRANSFER,
    sum(STOCKINQUALITY) as STOCK_IN_QUALITY,
    sum(STOCKRESTRICTEDBATCHES) as STOCK_RESTRICTED_BATCHES,
    sum(BLOCKEDSTOCK) as BLOCKED_STOCK,
    sum(BLOCKEDSTOCKRETURNS) as BLOCKED_STOCK_RETURNS,
    storage_location.LGOBE as STORAGE_LOCATION_NAME, 
    material.MAKTX as MATERIAL_DESCRIPTION,
    CUSTOMER_CONSIGNMENT_CODE,
    CUSTOMER_CONSIGNMENT_NAME,
    '' as CUSTOMER_LOAN_CODE,
    '' as CUSTOMER_LOAN_NAME,
    Material.ZZDEVI as device_code,
    case when material.MEINS = 'PC' then 'PCE'
    when material.MEINS = 'MM' then 'MMT'
    when material.MEINS ='M' then 'MTR' 
    else '' end as ISO_CODE_FOR_UNIT_OF_MEASUREMENT,
    case when material.MEINS = 'PC' then 'PCE'
    when material.MEINS = 'MM' then 'MMT'
    when material.MEINS ='M' then 'MTR' 
    else '' end as MATERIAL_BASE_UNIT_ISO,
    material.SPART as DIVISION_CODE,
    substring(stock.MATNR,1,2) as PRODUCT_CODE,
    material_sales.vkorg as SALES_ORGANIZATION,
    material_sales.VTWEG as DISTRIBUTION_CHANNEL_CODE,
    case when stock.werks = '3200' then '3200' when stock.werks = '3300' then '3300' end as COMPANY_CODE
    from stock as stock
left join Z_PARAM_PV AS Z_PARAM ON TRIM(LTRIM(stock.CHARG,0)) = TRIM(LTRIM(Z_PARAM.CHARG,0)) and  stock.Matnr = Z_PARAM.Matnr
left join  {{ ref('ODS__SAPAPI__ZCDV_T_CMTU080_T001L') }} as storage_location on storage_location.LGORT = stock.LGORT and storage_location.werks = stock.werks 
left join  {{ ref('ODS__SAPAPI__ZCDV_T_CMTU017_MARA') }} as material on material.matnr = stock.matnr  
left join {{ ref('ODS__SAPAPI__ZCDV_T_CMTU019_MVKE') }}  as material_sales on material_sales.matnr = stock.matnr
group by 
    stock.MATNR,stock.WERKS,stock.LGORT,stock.CHARG,material.MEINS,Z_PARAM.Z_STOCK_CHARG,Z_PARAM.Z_STOCK_SERIAL, Z_PARAM.Z_STOCK_SDATE,Z_PARAM.Z_STOCK_STIME ,
  storage_location.LGOBE,material.MAKTX ,CUSTOMER_CONSIGNMENT_CODE,CUSTOMER_CONSIGNMENT_NAME,material.SPART,MATERIAL.ZZDEVI,material_sales.vkorg,
  material_sales.VTWEG
),

transform_data as (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
	MATERIAL_NUMBER,
	PLANT,
	STORAGE_LOCATION,
	BATCH_NUMBER,
	BASE_UNIT_OF_MEASURE_MATERIAL_BASE_UNIT,
	WMS_BATCH_NUMBER,
	SERIAL_NUMBER,
	STOCK_DATE,
	STOCK_TIME,
	UNRESTRICTED_QUANTITY,
	STOCK_IN_TRANSFER,
	STOCK_IN_QUALITY,
	STOCK_RESTRICTED_BATCHES,
	BLOCKED_STOCK,
	BLOCKED_STOCK_RETURNS,
	MATERIAL_BASE_UNIT_ISO,
	COMPANY_CODE,
	SALES_ORGANIZATION,
	DISTRIBUTION_CHANNEL_CODE,
	DIVISION_CODE,
	MATERIAL_DESCRIPTION,
	STORAGE_LOCATION_NAME,
	DEVICE_CODE,
	PRODUCT_CODE,
	CUSTOMER_CONSIGNMENT_CODE,
	CUSTOMER_CONSIGNMENT_NAME,
	CUSTOMER_LOAN_CODE,
	CUSTOMER_LOAN_NAME,
	BASE_UNIT_OF_MEASURE_BASE_UNIT,
	ISO_CODE_FOR_UNIT_OF_MEASUREMENT
 from source_data
),

type_data as (
SELECT
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	MATERIAL_NUMBER,
	PLANT,
	STORAGE_LOCATION,
	BATCH_NUMBER,
	BASE_UNIT_OF_MEASURE_MATERIAL_BASE_UNIT,
	WMS_BATCH_NUMBER,
	SERIAL_NUMBER,
	STOCK_DATE,
	STOCK_TIME,
	CAST(UNRESTRICTED_QUANTITY as VARCHAR(16777216)) AS UNRESTRICTED_QUANTITY,
	CAST(STOCK_IN_TRANSFER as VARCHAR(16777216)) AS STOCK_IN_TRANSFER,
	CAST(STOCK_IN_QUALITY as VARCHAR(16777216)) AS STOCK_IN_QUALITY,
	CAST(STOCK_RESTRICTED_BATCHES as VARCHAR(16777216)) AS STOCK_RESTRICTED_BATCHES,
	CAST(BLOCKED_STOCK as VARCHAR(16777216)) AS BLOCKED_STOCK,
	CAST(BLOCKED_STOCK_RETURNS as VARCHAR(16777216)) AS BLOCKED_STOCK_RETURNS,
	MATERIAL_BASE_UNIT_ISO,
	COMPANY_CODE,
	SALES_ORGANIZATION,
	DISTRIBUTION_CHANNEL_CODE,
	DIVISION_CODE,
	MATERIAL_DESCRIPTION,
	STORAGE_LOCATION_NAME,
	DEVICE_CODE,
	PRODUCT_CODE,
	CUSTOMER_CONSIGNMENT_CODE,
	CUSTOMER_CONSIGNMENT_NAME,
	CUSTOMER_LOAN_CODE,
	CUSTOMER_LOAN_NAME,
	BASE_UNIT_OF_MEASURE_BASE_UNIT,
	ISO_CODE_FOR_UNIT_OF_MEASUREMENT
 from transform_data
)

Select * from type_data