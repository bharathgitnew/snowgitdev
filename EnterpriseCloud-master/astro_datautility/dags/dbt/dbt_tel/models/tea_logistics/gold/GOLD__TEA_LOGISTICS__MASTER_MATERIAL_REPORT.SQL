{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
        tags=["insert_overwrite_tea_logistics"],
    alias='MASTER_MATERIAL_REPORT',
    transient=false,
    enabled=true
) }}

with material_master as (
    select
        mat_plant.MARA_MATERIAL_NUMBER as MATERIAL_NUMBER,
        mat_plant.MATERIAL_DESCRIPTION as MATERIAL_DESCRIPTION,
        mat_plant.MATERIAL_TYPE as MATERIAL_TYPE,--ITEM_TYPE
        mat_plant.MATERIAL_GROUP as MATERIAL_GROUP,--ITEM_GROUP
        mat_plant.EBIZ_DISCLOSURE_CLASSIFICATION_BY_SUPPLIER, --as EBIZ_DISCLOSURE_FLAG,
        mat_plant.NARITA_ABC as ABC_GLOBAL,
        --EBIZ_DISCLOSURE_CLASSIFICATION as EBIZ_DISCLOSURE_CLASSIFICATION,
        mat_plant.BASE_UNIT_OF_MEASURE as Base_Unit_of_Measure, --INVENTORY_UNIT,
        mat_plant.PURCHASE_ORDER_UNIT_OF_MEASURE as PURCHASE_UNIT,
        mat_plant.AVAILABLE_FOR_SALE,
        case when mat_plant.AVAILABLE_FOR_SALE = '0' then 'Non-sellable'
        when mat_plant.AVAILABLE_FOR_SALE = '1' then 'sellable'
            when mat_plant.AVAILABLE_FOR_SALE = '2' then 'sellable with no stock replenishment'
            when mat_plant.AVAILABLE_FOR_SALE = '4' then 'provisional non-salable'
            end as Available_for_Sale_text,
        mat_plant.SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        case when mat_plant.SPECIFIC_CUSTOMER_SELLABLE_INDICATOR = '0' then 'Non-sellable'
            when mat_plant.SPECIFIC_CUSTOMER_SELLABLE_INDICATOR = '1' then 'sellable'
            end as Specific_customer_sellable_indicator_text,
        --SPECIFIC_CUSTOMER_SELLABLE_INDICATOR as SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        mat_plant.DELETION_CATEGORY as DELETION_CATEGORY,
        mat_plant.PART_SUPPLIER_COMPANY as PART_SUPPLIER_COMPANY,
        mat_plant.PART_CLASSIFICATION as PART_CLASSIFICATION,
        material_file.CLASSIFICATION as CLASSIFICATION,
        mat_plant.DIVISION as DIVISION,
        mat_plant.INSPECTION_ORDER_FLAG as Inspection_Order_Flag,
        mat_plant.MANUFACTURER as MANUFACTURER,
        mat_plant.REPAIRABLE as REPAIR_FLAG,
        case when mat_plant.REPAIRABLE = '0' then 'Unknown'
            when mat_plant.REPAIRABLE = '1' then 'Repairable'
            when mat_plant.REPAIRABLE = '2' then 'Non-Repairable'
            when mat_plant.REPAIRABLE = '3' then 'Repairable on condition'
        end as REPAIR_FLAG_TEXT,
        mat_plant.SPECIFIC_CUSTOMER_CLASSIFICATION as Intel_flag,
        case when mat_plant.SPECIFIC_CUSTOMER_CLASSIFICATION = '1' then 'now Intel'
            when mat_plant.SPECIFIC_CUSTOMER_CLASSIFICATION = '2' then 'in the past Intel'
            when mat_plant.SPECIFIC_CUSTOMER_CLASSIFICATION = '3' then 'future Intel'
        end as Intel_flag_text,
        mat_plant.LOCAL_ABC AS ABC_LOCAL,
        mat_plant.SPECIFIC_CUSTOMER_ABC AS ABC_INTEL,
        mat_plant.MARC_PLANT as PLANT,
        mat_plant.CONSUMPTION_MODE AS CONSUMPTION,
        mat_plant.MARC_COUNTRY_OF_ORIGIN_OF_MATERIAL as COUNTRY_OF_ORIGIN,
        mat_plant.GOODS_RECEIPT_PROCESSING_TIME_IN_DAYS as GR_PROCESSING_TIME,
        mat_plant.LEAP_FLAG,
        case when mat_plant.LEAP_FLAG = '0' then 'Non-Leap Part'
            when mat_plant.LEAP_FLAG = '1' then 'LEAP Part'
            when mat_plant.LEAP_FLAG = '2' then 'LEAP Alternative Part'
        end as LEAP_FLAG_TEXT,
        mat_plant.MARC_PROFIT_CENTER as Profit_Center,
        mbew.PRICE_CONTROL_INDICATOR as price_control,
        mbew.STANDARD_PRICE as  standard_cost,
        'US' as plant_country ,
        mat_plant.ECCN,
        mat_plant.HARMONIZED_TARIFF_CODE,
        mat_plant.EXPORT_REGULATION_FLAG,
        T134T.DESCRIPTION_OF_MATERIAL_TYPE as Material_type_text,
        T023T.MATERIAL_GROUP_DESCRIPTION as MATERIAL_GROUP_text,
        mat_plant.PERIOD_INDICATOR_FOR_SHELF_LIFE_EXPIRATION_DATE,
        mat_plant.TOTAL_SHELF_LIFE,
        mat_plant.MINIMUM_REMAINING_SHELF_LIFE,
        mat_plant.MARC_SERIAL_NUMBER_PROFILE,
        mat_plant.EBIZ_DISCLOSURE_CLASSIFICATION,
        mat_plant.PLANT_SPECIFIC_MATERIAL_STATUS,
        MBEW.VALUATION_AREA
    from {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_PLANT_MASTER') }} as mat_plant
    left join {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_VALUATION_MASTER_CODED') }} as MBEW
    on MBEW.MBEW_MATERIAL_NUMBER = mat_plant.MARA_MATERIAL_NUMBER
    and MBEW.VALUATION_AREA = mat_plant.MARC_PLANT
    left join {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_TYPE_DESCRIPTIONS') }} as T134T
    on mat_plant.MATERIAL_TYPE = T134T.MATERIAL_TYPE
    left join  {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_GROUP_DESCRIPTIONS') }} as T023T
    on mat_plant.MATERIAL_GROUP = T023T.MATERIAL_GROUP
    left join {{ ref('BRONZE__TEA_LOGISTICS__FILE_SAP_MATERIAL_CLASSIFICATIONS') }} as material_file
    on material_file.MATERIAL_NUMBER = mat_plant.MARA_MATERIAL_NUMBER
    where mat_plant.MARC_PLANT in ('3100','3200','3300','3400')
),

purchase_price as (
    select
        MATERIAL_NUMBER as MATERIAL_NUMBER,
        EINA_VENDOR_S_ACCOUNT_NUMBER as vendor,
        EINE_NUMBER_OF_PURCHASING_INFO_RECORD as inforecord,
        EINE_PURCHASING_ORGANIZATION  as purchase_org  ,
        EINE_PLANT as plant,
        NET_PRICE_IN_PURCHASING_INFO_RECORD  as price,
        EINE_CURRENCY_KEY as Purchase_currency,
        EINE_PLANNED_DELIVERY_TIME_IN_DAYS as Planned_Delivery_Time_in_Days,
        EINE_ORDER_PRICE_UNIT as purchase_unit
    from {{ ref('SILVER__TEA_LOGISTICS__PURCHASE_INFORMATION_PURCHASE_ORDER') }}
    where EINE_PURCHASING_ORGANIZATION in ('3200','3300') and
        PURCHASING_INFO_RECORD_CATEGORY = 0
),

Sales_price as(
    select
        MATERIAL_NUMBER,PRICING_COUNTRY as country,
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD as end_date,
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD as start_date,
        CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS as Sales_price,
        CONDITION_UNIT_KONWA as Sales_currency,
        CONDITION_PRICING_UNIT as sales_unit
    from {{ ref('SILVER__TEA_LOGISTICS__PRICE_MATRIX') }}
    where CONDITION_TYPE = 'ZP10'
        and condition = 'A910'
        and DELETION_INDICATOR_FOR_CONDITION_RECORD = 'false'
        and PRICING_COUNTRY = 'US'
        and ( try_to_date(VALIDITY_END_DATE_OF_THE_CONDITION_RECORD,'YYYYMMDD') >= current_date
        and try_to_date(VALIDITY_START_DATE_OF_THE_CONDITION_RECORD,'YYYYMMDD') <= current_date  )
    qualify row_number() over(partition by MATERIAL_NUMBER, COUNTRY order by START_DATE desc) = 1
),

billing as (
    select
        SALES_BILLING_DOCUMENT,
        SALES_COMPANY_CODE as company_code,
        SALES_SALES_ORGANIZATION as SALES_ORGANIZATION,
        SALES_DISTRIBUTION_CHANNEL as DISTRIBUTION_CHANNEL,
        VBRP_BILL_MATERIAL_NUMBER as MATERIAL_NUMBER,
        VBRP_BILL_PLANT as plant,
        SALES_BILLING_DATE as  LAST_SALES_DATE
    from {{ ref('SILVER__TEA_LOGISTICS__SALES_ORDER_BILLING_LINE') }}
    where SALES_BILLING_DOCUMENT is not NULL
    and SALES_SALES_ORGANIZATION in ('3200','3300')
    qualify ROW_NUMBER() OVER ( PARTITION BY VBRP_BILL_MATERIAL_NUMBER,VBRP_BILL_PLANT
        order by VBRP_BILL_MATERIAL_NUMBER,VBRP_BILL_PLANT ,SALES_BILLING_DATE desc ) = 1
),

Purchase as (
    select
        PURCHASING_ORGANIZATION_EKORG as PURHCASE_ORG ,
        EKKO_VENDOR_S_ACCOUNT_NUMBER as vendor,
        MATERIAL_NUMBER_MATNR as MATERIAL_NUMBER,
        EKPO_PLANT as plant ,
        EKKO_DELIVERY_CREATE_DATE as  LAST_PURCHASE_DATE
    from {{ ref('SILVER__TEA_LOGISTICS__PURCHASE_ORDER_DELIVERY_LINE') }}
    where EKKO_COMPANY_CODE in ('3100','3200','3300','3400')
    qualify  ROW_NUMBER() OVER ( PARTITION BY MATERIAL_NUMBER_MATNR,EKPO_PLANT
        order by MATERIAL_NUMBER_MATNR,EKPO_PLANT ,EKKO_DELIVERY_CREATE_DATE desc ) = 1
),

tvms as (
    -- temporary solution as TVMS has not been ingested from SAP
    select
        COLUMN1 as VMSTA,
        COLUMN2 as DESCRIPTION,
    from values
        ('01', 'Discontd w/o Replace'),
        ('02', 'Discontd w Replacemt'),
        ('03', 'Technical Defect'),
        ('04', 'Test Part'),
        ('11', 'Under Development'),
        ('GG', 'Returns Only'),
        ('Z1', 'Sellable'),
        ('Z2', 'Sellable-stock only'),
        ('Z3', 'Internal Sales Only'),
        ('Z4', 'Nonsellable'),
        ('Z5', 'Need Rework to sell'),
        ('Z6', 'Confirm with Vendor'),
        ('Z7', 'Nonsellable (temp)')
),

Mat_sales as (
    select
        MVKE_MATERIAL_NUMBER as MATERIAL_NUMBER,
        SALES_ORGANIZATION as SALES_ORGANIZATION,
        DISTRIBUTION_CHANNEL as DISTRIBUTION_CHANNEL,
        MVKE.MATERIAL_GROUP_2 as MATERIAL_GROUP_2,
        MVKE.MATERIAL_GROUP_1 as MATERIAL_GROUP_1,
        SALES_UNIT as SALES_UNIT,
        RELEVANT_FOR_RETURN as   RETURN_FLAG,
        TVM1T.DESCRIPTION as Material_group_1_text,
        TVM2T.DESCRIPTION as Material_group_2_text,
        MVKE.DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS,
        MVKE.DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS || '-' || tvms.DESCRIPTION as DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS_DESCRIPTION,
        MVKE.ORDER_ITEM_NAME
    from {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_SALES_ORG_MASTER') }} as MVKE
    left join  {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_PRICING_GROUP1') }} as TVM1T
    on MVKE.Material_group_1 = TVM1T.MATERIAL_GROUP_1
    left join  {{ ref('SILVER__TEA_LOGISTICS__MATERIAL_PRICING_GROUP2') }} as TVM2T
    on MVKE.Material_group_2 = TVM2T.MATERIAL_GROUP_2
    left join tvms
    on MVKE.DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS = tvms.VMSTA
    where SALES_ORGANIZATION in ('3200','3300')
),

vendor as (
    select distinct
        BUSINESS_PARTNER_NUMBER as vendor,
        LFA1_NAME_1_NAME1 as vendor_name
    from {{ ref('SILVER__TEA_LOGISTICS__BUSINESS_PARTNERS_GENERAL_DATA') }}
),

source_data as (
    select
        master_data.MATERIAL_NUMBER , --ITEM
        MATERIAL_DESCRIPTION,--ITEM_DESCRIPTION
        MATERIAL_TYPE,--ITEM_TYPE
        master_data.Material_type_text,
        MATERIAL_GROUP,--ITEM_GROUP
        master_data.MATERIAL_GROUP_text,
        Specific_customer_sellable_indicator,
        Specific_customer_sellable_indicator_text,
        Available_for_Sale,
        Available_for_Sale_text,
        mat_sales.Material_group_1, --JAPAN_PRODUCT_LINE ,
        Mat_sales.Material_group_1_text,
        mat_sales. Material_group_2 , --CONSUMABLE
        Mat_sales.Material_group_2_text,
        standard_cost, --as Purchase_price,
        Sales_price.Sales_price,
        Sales_price.Sales_currency,
        purchase_price.price as Purchase_price, --as MAT_COST,
        purchase_price.Purchase_currency,
        purchase_price. Planned_Delivery_Time_in_Days, --LEAD_TIME,
        GR_PROCESSING_TIME,
        Base_Unit_of_Measure,--INVENTORY_UNIT,
        purchase_price.PURCHASE_UNIT,
        purchase_price.vendor, --as SUPPLIER_GROUP,
        vendor.vendor_name,
        try_to_date(LAST_SALES_DATE,'YYYYMMDD') as LAST_SALES_DATE, --as LAST_SP_DATE,
        try_to_date(LAST_PURCHASE_DATE,'YYYYMMDD') as LAST_PURCHASE_DATE, --as LAST_CP_DATE,
        REPAIR_FLAG,
        REPAIR_FLAG_TEXT,
        INTEL_FLAG,
        Intel_flag_text,
        Inspection_Order_Flag,--INSPECTION,
        COUNTRY_OF_ORIGIN,
        master_data.HARMONIZED_TARIFF_CODE ,
        master_data.ECCN ,
        --'' as SCHEDULEB,
        classification,-- as COMMODITY_CODE,
        dd07t.DDTEXT as CLASSIFICATION_TEXT,
        --'' as SELECTION_CODE,
        Mat_sales.SALES_UNIT,
        --'Need mapping' as SALES_PRICE_UNIT,
        RETURN_FLAG ,
        ABC_GLOBAL,
        ABC_LOCAL,
        ABC_INTEL,
        LEAP_FLAG,
        LEAP_FLAG_TEXT,
        -- MANUFACTURER,
        MANUFACTURER as MANUFACTURER_NAME,
        --'not required' as ITEM_SIZE,
        EBIZ_DISCLOSURE_CLASSIFICATION_BY_SUPPLIER,
        --'not required'as SALES_MIN_QTY,
        --'not required' as PHYSICS_MATERIAL,
        master_data.EXPORT_REGULATION_FLAG,
        --''  as EXPORT_REGULATION_DESC,
        Profit_Center,
        master_data.plant,
        PERIOD_INDICATOR_FOR_SHELF_LIFE_EXPIRATION_DATE as Period_for_SLED,
        TOTAL_SHELF_LIFE,
        MINIMUM_REMAINING_SHELF_LIFE as Min_Remaining_Shelf_Life,
        MARC_SERIAL_NUMBER_PROFILE as SN_Profile,
        EBIZ_DISCLOSURE_CLASSIFICATION,
        PLANT_SPECIFIC_MATERIAL_STATUS,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS,
        Mat_sales.ORDER_ITEM_NAME,
        master_data.VALUATION_AREA,
        master_data.PART_CLASSIFICATION,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS_DESCRIPTION,
    from material_master as master_data
    left join Mat_sales as Mat_sales
    on Mat_sales.MATERIAL_NUMBER  = master_data.MATERIAL_NUMBER
    and mat_sales.SALES_ORGANIZATION = master_data.plant
    left join billing as billing
    on master_data.MATERIAL_NUMBER = billing.MATERIAL_NUMBER
    and master_data.plant = billing.plant
    left join purchase as purchase
    on master_data.MATERIAL_NUMBER = purchase.MATERIAL_NUMBER
    and master_data.plant = purchase.plant
    left join Sales_price as Sales_price
    on Sales_price.MATERIAL_NUMBER  = master_data.MATERIAL_NUMBER
    and Sales_price.country = master_data.plant_country
    left join purchase_price as purchase_price
    on purchase_price.MATERIAL_NUMBER  = master_data.MATERIAL_NUMBER
    and purchase_price.plant = master_data.plant
    left join vendor as vendor
    on vendor.vendor = purchase_price.vendor
    left join {{ ref('BRONZE__TEA_LOGISTICS__SAPAPI_ZCDV_T_CMTU120_DD07T_POSAR') }} dd07t 
    on dd07t.DOMNAME = 'ZD_CLASS' and dd07t.DOMVALUEL = CLASSIFICATION
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        MATERIAL_TYPE,
        MATERIAL_TYPE_TEXT,
        MATERIAL_GROUP,
        MATERIAL_GROUP_TEXT,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR_TEXT,
        AVAILABLE_FOR_SALE,
        AVAILABLE_FOR_SALE_TEXT,
        MATERIAL_GROUP_1,
        MATERIAL_GROUP_1_TEXT,
        MATERIAL_GROUP_2,
        MATERIAL_GROUP_2_TEXT,
        STANDARD_COST,
        SALES_PRICE,
        SALES_CURRENCY,
        PURCHASE_PRICE,
        PURCHASE_CURRENCY,
        PLANNED_DELIVERY_TIME_IN_DAYS,
        GR_PROCESSING_TIME,
        BASE_UNIT_OF_MEASURE,
        PURCHASE_UNIT,
        VENDOR,
        VENDOR_NAME,
        LAST_SALES_DATE,
        LAST_PURCHASE_DATE,
        REPAIR_FLAG,
        REPAIR_FLAG_TEXT,
        INTEL_FLAG,
        INTEL_FLAG_TEXT,
        INSPECTION_ORDER_FLAG,
        COUNTRY_OF_ORIGIN,
        HARMONIZED_TARIFF_CODE,
        ECCN,
        CLASSIFICATION,
        CLASSIFICATION_TEXT,
        SALES_UNIT,
        RETURN_FLAG,
        ABC_GLOBAL,
        ABC_LOCAL,
        ABC_INTEL,
        LEAP_FLAG,
        LEAP_FLAG_TEXT,
        MANUFACTURER_NAME,
        EXPORT_REGULATION_FLAG,
        PROFIT_CENTER,
        PLANT,
        PERIOD_FOR_SLED,
        TOTAL_SHELF_LIFE,
        MIN_REMAINING_SHELF_LIFE,
        SN_PROFILE,
        EBIZ_DISCLOSURE_CLASSIFICATION_BY_SUPPLIER,
        EBIZ_DISCLOSURE_CLASSIFICATION,
        PLANT_SPECIFIC_MATERIAL_STATUS,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS,
        ORDER_ITEM_NAME,
        VALUATION_AREA,
        PART_CLASSIFICATION,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS_DESCRIPTION
from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        MATERIAL_TYPE,
        MATERIAL_TYPE_TEXT,
        MATERIAL_GROUP,
        MATERIAL_GROUP_TEXT,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR,
        SPECIFIC_CUSTOMER_SELLABLE_INDICATOR_TEXT,
        AVAILABLE_FOR_SALE,
        AVAILABLE_FOR_SALE_TEXT,
        MATERIAL_GROUP_1,
        MATERIAL_GROUP_1_TEXT,
        MATERIAL_GROUP_2,
        MATERIAL_GROUP_2_TEXT,
        CAST(STANDARD_COST as NUMBER(38,2)) as STANDARD_COST,
        CAST(SALES_PRICE as NUMBER(38,2)) as SALES_PRICE,
        SALES_CURRENCY,
        CAST(PURCHASE_PRICE as NUMBER(38,2)) as PURCHASE_PRICE,
        PURCHASE_CURRENCY,
        PLANNED_DELIVERY_TIME_IN_DAYS,
        GR_PROCESSING_TIME,
        BASE_UNIT_OF_MEASURE,
        PURCHASE_UNIT,
        VENDOR,
        VENDOR_NAME,
        CAST(LAST_SALES_DATE as DATE) as LAST_SALES_DATE,
        CAST(LAST_PURCHASE_DATE as DATE) as LAST_PURCHASE_DATE,
        REPAIR_FLAG,
        REPAIR_FLAG_TEXT,
        INTEL_FLAG,
        INTEL_FLAG_TEXT,
        INSPECTION_ORDER_FLAG,
        COUNTRY_OF_ORIGIN,
        HARMONIZED_TARIFF_CODE,
        ECCN,
        CLASSIFICATION,
        CLASSIFICATION_TEXT,
        SALES_UNIT,
        RETURN_FLAG,
        ABC_GLOBAL,
        ABC_LOCAL,
        ABC_INTEL,
        LEAP_FLAG,
        LEAP_FLAG_TEXT,
        MANUFACTURER_NAME,
        EXPORT_REGULATION_FLAG,
        PROFIT_CENTER,
        PLANT,
        PERIOD_FOR_SLED,
        TOTAL_SHELF_LIFE,
        MIN_REMAINING_SHELF_LIFE,
        SN_PROFILE,
        EBIZ_DISCLOSURE_CLASSIFICATION_BY_SUPPLIER,
        EBIZ_DISCLOSURE_CLASSIFICATION,
        PLANT_SPECIFIC_MATERIAL_STATUS,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS,
        ORDER_ITEM_NAME,
        VALUATION_AREA,
        PART_CLASSIFICATION,
        DISTRIBUTION_CHAIN_SPECIFIC_MATERIAL_STATUS_DESCRIPTION
from transform_data
)

select * from type_data