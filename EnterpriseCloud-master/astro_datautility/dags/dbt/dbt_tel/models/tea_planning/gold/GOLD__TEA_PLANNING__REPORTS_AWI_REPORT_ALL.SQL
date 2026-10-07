{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='REPORTS_AWI_REPORT_ALL',
        transient=false
) }}

with mara as
(
    select distinct
    inv.MATDOC_MATERIAL_NUMBER
    ,mara.MATERIAL_DESCRIPTION
    ,mara.SALES_LEAD_TIME_ZZSLTR as Lead_time
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_GENERAL_MATERIAL') }} inv
    join {{ ref('SILVER__TEA_PLANNING__SAPH_MATERIAL_PLANT_MASTER') }}  mara on mara.mara_material_number = inv.matdoc_material_number
),

marc as
(
    select distinct
    matdoc_material_number
    ,storage_location_lgort_sid
    ,CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID
    ,SPECIFIC_CUSTOMER_ABC
    ,PLANT_SPECIFIC_MATERIAL_STATUS
    ,case when storage_location_lgort_sid = '' then customer_for_special_stock_kunnr_sid else storage_location_lgort_sid end as SLOC
    ,stock_quantity
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_PLANT_MATERIAL') }}  
),

mdma as
(
    select distinct
    matdoc_material_number
    ,storage_location_lgort_sid
    ,CUSTOMER_FOR_SPECIAL_STOCK_KUNNR_SID
    ,mdma_reorder_point
    ,mdma_safety_stock
    ,case when storage_location_lgort_sid = '' then customer_for_special_stock_kunnr_sid else storage_location_lgort_sid end as SLOC
    from {{ ref('SILVER__TEA_PLANNING__SAPH_INVENTORY_MRP_AREA_MATERIAL') }} 
),

mvke as
(
    select distinct
    MARA_MATERIAL_NUMBER
    ,MATERIAL_GROUP_2
    ,DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS
    ,case when MATERIAL_GROUP_2 = '0' then 'N'
          when MATERIAL_GROUP_2 = '1' then 'Y'
          else 'Unknown'
    end as consumable_flag
    from {{ ref('SILVER__TEA_PLANNING__SAPH_MATERIAL_SALES_ORG_MASTER') }} 
),

bp_details as
(
    select
    kna1.business_partner_number
    ,kna1.name_1    
    from {{ ref('SILVER__TEA_PLANNING__SAPH_BUSINESS_PARTNERS_GENERAL_DATA') }}  kna1
    left join {{ ref('BRONZE__TEA_PLANNING__SAPAPI_ZCDV_T_CMTU021_KNVV') }} KNVV on kna1.business_partner_number = knvv.kunnr
    where knvv.kdgrp ='Z1'
),

open_orders as
(
    select distinct
        MATERIAL_NUMBER_MATNR
        ,EKPO_DELIVERY_COMPLETED_INDICATOR
    from {{ ref('SILVER__TEA_PLANNING__SAPH_PURCHASE_ORDER_DELIVERY_LINE') }}  
    where not EKPO_DELIVERY_COMPLETED_INDICATOR
),

prophet_inventory as
(
    select 
        ITEMID
        ,sum(case when regionid like 'TEE%' then  inventoryquantity else 0 end ) as TEE_OH
        ,sum(case when regionid like 'TEA%' then  inventoryquantity else 0 end )  as TEA_OH
        ,sum(case when (warehouseid = '2130' and left(itemid,2)='ES') or (warehouseid = '2120' and left(itemid,2)!='ES') then  inventoryquantity else 0 end )  as TEL_OH
        ,(TEA_OH + TEE_OH + TEL_OH) as GLOBAL_OH
    from {{ ref('SILVER__TEA_PLANNING__PROPHET_INVENTORY_LIVE') }}  
    where 
    REGIONID in ('TEL-GDC','TEL-FLD','TEE-DC','TEE-FLD','TEA-FLD','TEA-DC')
    and warehouseid in ('933','928','724','7C4','711','112','71Q','2120','2130','B230','B330','B430','D830','E130','E230','E330','D930','A530')
    group by 
        ITEMID
),

prophet_on_order as
(
    select 
        itemid
        ,sum(case when regionid in ('TEE-DC','TEE-FLD') then quantity end) as TEE_OO
        ,sum(case when regionid in ('TEA-DC','TEA-FLD') then quantity end) as TEA_OO
        ,sum(case when regionid in ('TEL-DC','TEL-FLD') then quantity end) as TEL_OO
    from {{ ref('SILVER__TEA_PLANNING__PROPHET_ORDERS_LIVE') }}
    where REGIONID in ('TEL-DC','TEL-FLD','TEE-DC','TEE-FLD','TEA-FLD','TEA-DC')
    group by itemid

),

vendor_data as
(
    select distinct 
        pi.material_number
        ,pi.EINA_VENDOR_S_ACCOUNT_NUMBER
        ,bp.name_1 
    from {{ ref('SILVER__TEA_PLANNING__SAPH_PURCHASE_INFORMATION_PURCHASE_ORDER') }}  pi
    join {{ ref('SILVER__TEA_PLANNING__SAPH_BUSINESS_PARTNERS_GENERAL_DATA') }} bp on bp.business_partner_number = pi.eina_vendor_s_account_number
    where pi.eine_purchasing_organization ='3200'
),

demo_lt_baan as
(
    select 
        item
        ,round(avg(datediff('days',order_date,receipt_date)),0) as demonstrated_leadtime
    
    from {{ ref('SILVER__TEA_PLANNING__BAAN_PURCHASEORDER') }} 
    where 
        item between 'CS' and 'TZ'
        and order_date > trunc(add_months(current_date,-6),'MONTH')
        and receipt_date is not null
    group by 
        item
),

TEA_baan_sales_data as 
(
    select 
        item
        ,period 
        ,sum(qty) as qty
    from {{ ref('SILVER__TEA_PLANNING__BAAN_TEA_BAAN_SALES_SERVICES_ORDERS_BY_MONTH_CUSTOMER') }} 
    where upper(sold_to_bp) like 'INTEL%'
    group by 
        item
        ,period 
    order by item
),

TEA_sap_sales_data as
(
    select 
        MATERIAL_NUMBER_LIPS as item
        , cal.YEAR_MONTH_TEXT as PERIOD
        , sum(case when LIPS_MOVEMENT_TYPE ='Z64' then ACTUAL_QUANTITY_DELIVERED*-1 else ACTUAL_QUANTITY_DELIVERED end ) as Qty        
    from {{ ref('SILVER__TEA_PLANNING__SAPH_SALES_ORDER_DELIVERY_LINE') }} 
    left join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} cal on cal.CALENDAR_DATE_KEY = ACTUAL_GOODS_MOVEMENT_DATE
    where MATERIAL_NUMBER_LIPS is not null
    AND customer_group = 'Z1'
    and LIKP_SOLD_TO_PARTY != 'BA0010100'
    and LIPS_MOVEMENT_TYPE != '631'
    group by 
        material_number_lips        
        ,cal.YEAR_MONTH_TEXT
),

TEA_avg_Sales_data as 
(

    select 
        item        
        ,sum(qty)/91.5 as qty
    from 
        (SELECT
            item
            ,period
            ,to_date(period||'-01','yyyy-mm-dd') as firstdate
            ,qty
        from TEA_baan_sales_data
        Union all
        select 
            item
            ,period
            ,to_date(period||'-01','yyyy-mm-dd') as firstdate
            ,qty
        from TEA_sap_sales_data) sales
        
    where firstdate between trunc(add_months(current_date,-3),'MONTH') and last_day(add_months(current_date,-1))
    group by
        item
        
        
),

tee_prophet_sales_data as
(
    select  
        itemid
        ,cal.YEAR_MONTH_TEXT as PERIOD
        ,deliverydate as order_date
        ,max(deliveredquantity) as qty
    from  {{ ref('SILVER__TEA_PLANNING__PROPHET_DEMAND_HISTORY') }} 
    left join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} cal on cal.CALENDAR_DATE_KEY = deliverydate
    where regionid in ('TEE-DC','TEE-FLD')
        and (warehouseid in ('112','711','724','7C4','928','933')
             or (warehouseid = '111' and left(itemid,2) not in ('CT','ES','RE') and deliveryname like '%Intel%'))
        and  last_day(add_months(cal.calendar_date,-1)) >= trunc(add_months(current_date,-36),'Month')
    group by 
        itemid
        ,cal.YEAR_MONTH_TEXT
        ,deliverydate
        ,SOURCESYSTEMTRANSACTIONID
    
    union all
    
    select 
        itemid
        ,period
        ,ordermonthdate
        ,quantity
    from 
        (select 
            itemid
            ,ordermonthdate
            ,cal.YEAR_MONTH_TEXT as PERIOD 
            ,_filedate
            ,quantity
            ,row_number() over (partition by itemid order by _filedate desc) as rn
            from {{ ref('SILVER__TEA_PLANNING__PROPHET_DEMANDRETURN_HISTORY') }}   rh
            left join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}  cal on cal.CALENDAR_DATE_KEY = ordermonthdate
            where warehouseregionid in ('TEE-DC','TEE-FLD')
                    and warehouseid in ('112','711','724','7C4','928','933')
                    and  last_day(add_months(cal.calendar_date,-1)) >= trunc(add_months(current_date,-36),'Month')
        ) where rn = 1

),


TEE_prophet_summarised_sales as
(
    select
        itemid
        ,period
        ,order_date
        ,sum(qty) as qty
    from tee_prophet_sales_data ph
    join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} cal on cal.calendar_date_key = ph.order_date
    group by
        itemid
        ,period
        ,order_date
),

tee_daily_average_sales as
(
    select 
        ph.itemid
        ,round(avg(ph.qty),0) as avg_qty
    from tee_prophet_sales_data ph
    join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} cal on cal.CALENDAR_DATE_KEY = ph.order_date
    where calendar_date >= current_Date-90
    group by
        ph.itemid
),


TEA_TEE_combined_sales_data as
(
    select 
        item
        , PERIOD
        , QTY
    from TEA_sap_sales_data

    union all
    
    select 
        ITEM
        , PERIOD
        , QTY
    from TEA_baan_sales_data

    union all

    select
        itemid
        ,period
        ,sum(qty)
    from TEE_prophet_summarised_sales
    group by 
        itemid
        ,period
        

    
),

TEA_TEE_summarised_sales_data  as 
(
    select 
        item
        ,period
        ,to_date(period||'-01','yyyy-mm-dd') as firstdate
        ,sum(qty) as qty
    from TEA_TEE_combined_sales_data
    group by 
        item
        , period
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
    ,sum(case when firstdate between trunc(add_months(current_date,-13),'MONTH') and last_day(add_months(current_date,-13)) then qty else 0 end ) as mth13
    ,sum(case when firstdate between trunc(add_months(current_date,-14),'MONTH') and last_day(add_months(current_date,-14)) then qty else 0 end ) as mth14
    ,sum(case when firstdate between trunc(add_months(current_date,-15),'MONTH') and last_day(add_months(current_date,-15)) then qty else 0 end ) as mth15
    ,sum(case when firstdate between trunc(add_months(current_date,-16),'MONTH') and last_day(add_months(current_date,-16)) then qty else 0 end ) as mth16
    ,sum(case when firstdate between trunc(add_months(current_date,-17),'MONTH') and last_day(add_months(current_date,-17)) then qty else 0 end ) as mth17
    ,sum(case when firstdate between trunc(add_months(current_date,-18),'MONTH') and last_day(add_months(current_date,-18)) then qty else 0 end ) as mth18
    ,sum(case when firstdate between trunc(add_months(current_date,-19),'MONTH') and last_day(add_months(current_date,-19)) then qty else 0 end ) as mth19
    ,sum(case when firstdate between trunc(add_months(current_date,-20),'MONTH') and last_day(add_months(current_date,-20)) then qty else 0 end ) as mth20
    ,sum(case when firstdate between trunc(add_months(current_date,-21),'MONTH') and last_day(add_months(current_date,-21)) then qty else 0 end ) as mth21
    ,sum(case when firstdate between trunc(add_months(current_date,-22),'MONTH') and last_day(add_months(current_date,-22)) then qty else 0 end ) as mth22
    ,sum(case when firstdate between trunc(add_months(current_date,-23),'MONTH') and last_day(add_months(current_date,-23)) then qty else 0 end ) as mth23
    ,sum(case when firstdate between trunc(add_months(current_date,-24),'MONTH') and last_day(add_months(current_date,-24)) then qty else 0 end ) as mth24
    ,sum(case when firstdate between trunc(add_months(current_date,-25),'MONTH') and last_day(add_months(current_date,-25)) then qty else 0 end ) as mth25
    ,sum(case when firstdate between trunc(add_months(current_date,-26),'MONTH') and last_day(add_months(current_date,-26)) then qty else 0 end ) as mth26
    ,sum(case when firstdate between trunc(add_months(current_date,-27),'MONTH') and last_day(add_months(current_date,-27)) then qty else 0 end ) as mth27
    ,sum(case when firstdate between trunc(add_months(current_date,-28),'MONTH') and last_day(add_months(current_date,-28)) then qty else 0 end ) as mth28
    ,sum(case when firstdate between trunc(add_months(current_date,-29),'MONTH') and last_day(add_months(current_date,-29)) then qty else 0 end ) as mth29
    ,sum(case when firstdate between trunc(add_months(current_date,-30),'MONTH') and last_day(add_months(current_date,-30)) then qty else 0 end ) as mth30
    ,sum(case when firstdate between trunc(add_months(current_date,-31),'MONTH') and last_day(add_months(current_date,-31)) then qty else 0 end ) as mth31
    ,sum(case when firstdate between trunc(add_months(current_date,-32),'MONTH') and last_day(add_months(current_date,-32)) then qty else 0 end ) as mth32
    ,sum(case when firstdate between trunc(add_months(current_date,-33),'MONTH') and last_day(add_months(current_date,-33)) then qty else 0 end ) as mth33
    ,sum(case when firstdate between trunc(add_months(current_date,-34),'MONTH') and last_day(add_months(current_date,-34)) then qty else 0 end ) as mth34
    ,sum(case when firstdate between trunc(add_months(current_date,-35),'MONTH') and last_day(add_months(current_date,-35)) then qty else 0 end ) as mth35
    ,sum(case when firstdate between trunc(add_months(current_date,-36),'MONTH') and last_day(add_months(current_date,-36)) then qty else 0 end ) as mth36


    from TEA_TEE_summarised_sales_data
    group by item
    order by item
),

Intel_price as 
(
    select distinct
        material_number
        ,round(condition_amount_or_percentage_where_no_scale_exists,2) as price
  
    from {{ ref('SILVER__TEA_PLANNING__SAPH_PRICE_MATRIX') }}
    where 
        material_number is not null 
        and condition_type = 'ZP21' 
        and CUSTOMER_PRICE_GROUP = '01'
        AND current_date <= to_date(VALIDITY_END_DATE_OF_THE_CONDITION_RECORD,'yyyymmdd')
    

),

mat_cost as
(
    select
    matnr
    ,round(stprs *1.09,2) as trf_cost
    from  {{ ref('BRONZE__TEA_PLANNING__SAPH_SAP_US_MMT_EV_MBEW') }}
    where bwkey = '3200'
),

po_due_date as
(
    select 
        ph.ITEMID
        ,sum(case when cal.calendar_date between current_date-60 and current_date-31 then ph.quantity else 0 end) as PO_previous_60_days
        ,sum(case when cal.calendar_date between current_date-0 and current_date-1 then ph.quantity else 0 end) as PO_previous_30_days
        ,sum(case when cal.calendar_date between current_date and current_date+30 then ph.quantity else 0 end) as PO_next_30_days
        ,sum(case when cal.calendar_date between current_date-31 and current_date+60 then ph.quantity else 0 end) as PO_next_30_to_60_days
        ,sum(case when cal.calendar_date between current_date-61 and current_date+90 then ph.quantity else 0 end) as PO_next_60_to_90_days
    from {{ ref('SILVER__TEA_PLANNING__PROPHET_ORDERS_LIVE') }} ph
    join {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }}  cal on cal.calendar_date_key = ph.duedatekey
    where 
        ph.regionid = 'TEL-GDC'
        and cal.calendar_date between current_date-60 and current_date+90
    group by 
        ph.itemid
    order by 
        ph.itemid
),

source_data as 
(
    select distinct
        mara.matdoc_material_number as MATERIAL
        ,mara.MATERIAL_DESCRIPTION
        ,marc.PLANT_SPECIFIC_MATERIAL_STATUS as purchasing_status
        ,mvke.DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS as sales_status
        ,mvke.MATERIAL_GROUP_2 as Consumable
        ,mara.Lead_time
        ,ven.name_1 as Supplier
        ,marc.SPECIFIC_CUSTOMER_ABC
        ,Intel_price.price as Intel_price
        ,MAT_Cost.trf_cost as Mat_cost
        ,demo_lt_baan.demonstrated_leadtime as Demonstrated_lead_time
        ,inv.TEA_OH
        ,inv.TEE_OH
        ,inv.TEL_OH
        ,inv.GLOBAL_OH
        ,TEA_avg_Sales_data.qty as TEA_AVG_DAILY_USE
        ,tee_daily_average_sales.AVG_QTY as TEE_AVG_DAILY_USE
        ,TEA_avg_Sales_data.qty + tee_daily_average_sales.avg_qty as SUM_INTEL_AVG_DAILY_USE --calc in cte
        ,div0null(inv.TEA_OH,TEA_AVG_DAILY_USE) as TEA_DOI
        ,div0null(inv.TEE_OH,tee_daily_average_sales.avg_qty) as TEE_DOI
        ,div0null(inv.TEL_OH,TEA_avg_Sales_data.qty + tee_daily_average_sales.avg_qty) as TEL_DOI
        ,div0null(inv.GLOBAL_OH,SUM_INTEL_AVG_DAILY_USE) as GLOBAL_DOI
        ,(MAT_COST * inv.TEA_OH) as TEA_OH_AMOUNT
        ,(MAT_COST * inv.TEE_OH) as TEE_OH_AMOUNT
        ,(MAT_COST * inv.TEL_OH) as TEL_OH_AMOUNT
        ,(MAT_COST * inv.GLOBAL_OH) as GLOBAL_OH_AMOUNT
        ,poo.TEA_OO
        ,poo.TEE_OO
        ,poo.TEL_OO    
        ,div0null(inv.GLOBAL_OH + poo.TEL_OO,SUM_INTEL_AVG_DAILY_USE) as GLOBAL_OH_AND_OO_DOI
        ,sales.mth1
        ,sales.mth2
        ,sales.mth3
        ,sales.mth4
        ,sales.mth5
        ,sales.mth6
        ,sales.mth7
        ,sales.mth8
        ,sales.mth9
        ,sales.mth10
        ,sales.mth11
        ,sales.mth12
        ,sales.mth13
        ,sales.mth14
        ,sales.mth15
        ,sales.mth16
        ,sales.mth17
        ,sales.mth18
        ,sales.mth19
        ,sales.mth20
        ,sales.mth21
        ,sales.mth22
        ,sales.mth23
        ,sales.mth24
        ,sales.mth25
        ,sales.mth26
        ,sales.mth27
        ,sales.mth28
        ,sales.mth29
        ,sales.mth30
        ,sales.mth31
        ,sales.mth32
        ,sales.mth33
        ,sales.mth34
        ,sales.mth35
        ,sales.mth36
        ,PO_previous_60_days
        ,PO_previous_30_days
        ,PO_next_30_days
        ,PO_next_30_to_60_days
        ,PO_next_60_to_90_days
        ,'{{ invocation_id }}' AS AUDIT_LOG_ID
        ,SHA2('hash_me') as _ROW_HASH 
    
        
    from mara 
    left join marc on marc.matdoc_material_number = mara.matdoc_material_number
    left join mdma on marc.matdoc_material_number = mdma.matdoc_material_number and marc.sloc = mdma.sloc
    left join open_orders oo on oo.MATERIAL_NUMBER_MATNR = mara.matdoc_material_number
    left join prophet_inventory inv on mara.matdoc_material_number = inv.ITEMID
    left join prophet_on_order poo on mara.matdoc_material_number = poo.ITEMID
    left join mvke on mvke.MARA_MATERIAL_NUMBER = mara.matdoc_material_number
    left join sales_pivot as sales on sales.item = mara.matdoc_material_number
    left join intel_price on intel_price.material_number = mara.matdoc_material_number
    left join mat_cost on mat_cost.matnr = mara.matdoc_material_number
    left join po_due_date on po_due_date.ITEMID = mara.matdoc_material_number 
    left join TEA_avg_Sales_data on TEA_avg_Sales_data.item = mara.matdoc_material_number
    left join tee_daily_average_sales on tee_daily_average_sales.itemid = mara.matdoc_material_number
    left join demo_lt_baan on demo_lt_baan.item = mara.matdoc_material_number
    left join vendor_data ven on ven.material_number = mara.matdoc_material_number 
    join bp_details on marc.sloc = bp_details.business_partner_number 

),

transform_data as (
    select 
        MATERIAL,
        MATERIAL_DESCRIPTION,
        purchasing_status,
        sales_status,
        Consumable,
        Lead_time,
        Supplier,
        SPECIFIC_CUSTOMER_ABC,
        Intel_price,
        Mat_cost,
        Demonstrated_lead_time,
        TEA_OH,
        TEE_OH,
        TEL_OH,
        GLOBAL_OH,
        TEA_AVG_DAILY_USE,
        TEE_AVG_DAILY_USE,
        SUM_INTEL_AVG_DAILY_USE,
        TEA_DOI,
        TEE_DOI,
        TEL_DOI,
        GLOBAL_DOI,
        TEA_OH_AMOUNT,
        TEE_OH_AMOUNT,
        TEL_OH_AMOUNT,
        GLOBAL_OH_AMOUNT,
        TEA_OO,
        TEE_OO,
        TEL_OO,
        GLOBAL_OH_AND_OO_DOI,
        mth1,
        mth2,
        mth3,
        mth4,
        mth5,
        mth6,
        mth7,
        mth8,
        mth9,
        mth10,
        mth11,
        mth12,
        mth13,
        mth14,
        mth15,
        mth16,
        mth17,
        mth18,
        mth19,
        mth20,
        mth21,
        mth22,
        mth23,
        mth24,
        mth25,
        mth26,
        mth27,
        mth28,
        mth29,
        mth30,
        mth31,
        mth32,
        mth33,
        mth34,
        mth35,
        mth36,
        PO_previous_60_days,
        PO_previous_30_days,
        PO_next_30_days,
        PO_next_30_to_60_days,
        PO_next_60_to_90_days,
        AUDIT_LOG_ID,
        _ROW_HASH

    FROM source_data
),

type_data as (

    select 
         cast(AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID
        ,cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH
        ,CAST(MATERIAL AS VARCHAR(16777216)) AS MATERIAL
        ,CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION
        ,CAST(purchasing_status AS VARCHAR(16777216)) AS purchasing_status
        ,CAST(sales_status AS VARCHAR(16777216)) AS sales_status
        ,CAST(Consumable AS VARCHAR(16777216)) AS Consumable
        ,CAST(Lead_time AS NUMBER(38,0)) AS Lead_time
        ,CAST(Supplier AS VARCHAR(16777216)) AS Supplier
        ,CAST(SPECIFIC_CUSTOMER_ABC AS VARCHAR(16777216)) AS SPECIFIC_CUSTOMER_ABC
        ,CAST(Intel_price AS NUMBER(38,10)) AS Intel_price
        ,CAST(Mat_cost AS NUMBER(38,10)) AS Mat_cost
        ,CAST(Demonstrated_lead_time AS NUMBER(38,10)) AS Demonstrated_lead_time
        ,CAST(TEA_OH AS NUMBER(38,0)) AS TEA_OH
        ,CAST(TEE_OH AS NUMBER(38,0)) AS TEE_OH
        ,CAST(TEL_OH AS NUMBER(38,0)) AS TEL_OH
        ,CAST(GLOBAL_OH AS NUMBER(38,0)) AS GLOBAL_OH
        ,CAST(TEA_AVG_DAILY_USE AS NUMBER(38,10)) AS TEA_AVG_DAILY_USE
        ,CAST(TEE_AVG_DAILY_USE AS NUMBER(38,10)) AS TEE_AVG_DAILY_USE
        ,CAST(SUM_INTEL_AVG_DAILY_USE AS NUMBER(38,10)) AS SUM_INTEL_AVG_DAILY_USE
        ,CAST(TEA_DOI AS NUMBER(38,10)) AS TEA_DOI
        ,CAST(TEE_DOI AS NUMBER(38,10)) AS TEE_DOI
        ,CAST(TEL_DOI AS NUMBER(38,10)) AS TEL_DOI
        ,CAST(GLOBAL_DOI AS NUMBER(38,10)) AS GLOBAL_DOI
        ,CAST(TEA_OH_AMOUNT AS NUMBER(38,10)) AS TEA_OH_AMOUNT
        ,CAST(TEE_OH_AMOUNT AS NUMBER(38,10)) AS TEE_OH_AMOUNT
        ,CAST(TEL_OH_AMOUNT AS NUMBER(38,10)) AS TEL_OH_AMOUNT
        ,CAST(GLOBAL_OH_AMOUNT AS NUMBER(38,10)) AS GLOBAL_OH_AMOUNT
        ,CAST(TEA_OO AS NUMBER(38,0)) AS TEA_OO
        ,CAST(TEE_OO AS NUMBER(38,0)) AS TEE_OO
        ,CAST(TEL_OO AS NUMBER(38,0)) AS TEL_OO
        ,CAST(GLOBAL_OH_AND_OO_DOI AS NUMBER(38,10)) AS GLOBAL_OH_AND_OO_DOI
        ,CAST(mth1 AS NUMBER(38,0)) AS mth1
        ,CAST(mth2 AS NUMBER(38,0)) AS mth2
        ,CAST(mth3 AS NUMBER(38,0)) AS mth3
        ,CAST(mth4 AS NUMBER(38,0)) AS mth4
        ,CAST(mth5 AS NUMBER(38,0)) AS mth5
        ,CAST(mth6 AS NUMBER(38,0)) AS mth6
        ,CAST(mth7 AS NUMBER(38,0)) AS mth7
        ,CAST(mth8 AS NUMBER(38,0)) AS mth8
        ,CAST(mth9 AS NUMBER(38,0)) AS mth9
        ,CAST(mth10 AS NUMBER(38,0)) AS mth10
        ,CAST(mth11 AS NUMBER(38,0)) AS mth11
        ,CAST(mth12 AS NUMBER(38,0)) AS mth12
        ,CAST(mth13 AS NUMBER(38,0)) AS mth13
        ,CAST(mth14 AS NUMBER(38,0)) AS mth14
        ,CAST(mth15 AS NUMBER(38,0)) AS mth15
        ,CAST(mth16 AS NUMBER(38,0)) AS mth16
        ,CAST(mth17 AS NUMBER(38,0)) AS mth17
        ,CAST(mth18 AS NUMBER(38,0)) AS mth18
        ,CAST(mth19 AS NUMBER(38,0)) AS mth19
        ,CAST(mth20 AS NUMBER(38,0)) AS mth20
        ,CAST(mth21 AS NUMBER(38,0)) AS mth21
        ,CAST(mth22 AS NUMBER(38,0)) AS mth22
        ,CAST(mth23 AS NUMBER(38,0)) AS mth23
        ,CAST(mth24 AS NUMBER(38,0)) AS mth24
        ,CAST(mth25 AS NUMBER(38,0)) AS mth25
        ,CAST(mth26 AS NUMBER(38,0)) AS mth26
        ,CAST(mth27 AS NUMBER(38,0)) AS mth27
        ,CAST(mth28 AS NUMBER(38,0)) AS mth28
        ,CAST(mth29 AS NUMBER(38,0)) AS mth29
        ,CAST(mth30 AS NUMBER(38,0)) AS mth30
        ,CAST(mth31 AS NUMBER(38,0)) AS mth31
        ,CAST(mth32 AS NUMBER(38,0)) AS mth32
        ,CAST(mth33 AS NUMBER(38,0)) AS mth33
        ,CAST(mth34 AS NUMBER(38,0)) AS mth34
        ,CAST(mth35 AS NUMBER(38,0)) AS mth35
        ,CAST(mth36 AS NUMBER(38,0)) AS mth36
        ,CAST(PO_previous_60_days AS NUMBER(38,0)) AS PO_previous_60_days
        ,CAST(PO_previous_30_days AS NUMBER(38,0)) AS PO_previous_30_days
        ,CAST(PO_next_30_days AS NUMBER(38,0)) AS PO_next_30_days
        ,CAST(PO_next_30_to_60_days AS NUMBER(38,0)) AS PO_next_30_to_60_days
        ,CAST(PO_next_60_to_90_days AS NUMBER(38,0)) AS PO_next_60_to_90_days

    FROM transform_data
)

SELECT * from type_data