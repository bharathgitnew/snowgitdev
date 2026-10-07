{{ config(
        alias = 'PIR_REPORT',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}

with mat_prices as (
    select 
        VENDORS_ACCOUNT_NUMBER,
        MATERIAL_NUMBER,
        APPLICATION,
        CONDITION_RECORD_NUMBER_KONP,
        CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS,
        CONDITION_UNIT_KONWA,
        VALIDITY_START_DATE_OF_THE_CONDITION_RECORD,
        VALIDITY_END_DATE_OF_THE_CONDITION_RECORD
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__PRICE_MATRIX') }}
    where CONDITION = 'A017'
        and CONDITION_TYPE = 'ZP00'
        and PURCHASING_ORGANIZATION = '3200'
        and PLANT = '3200'
),

mat_details as (
    select distinct 
        MVKE_MATERIAL_NUMBER,
        ORDER_ITEM_NAME
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__MATERIAL_SALES_ORG_MASTER') }}
),
vendor_details as(
    select distinct
        LFA1_ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR,
        LFA1_NAME_1_NAME1
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__BUSINESS_PARTNERS_GENERAL_DATA') }}
),

pir_details as (
    select distinct
        EINE_NUMBER_OF_PURCHASING_INFO_RECORD,
        EINE_PURCHASING_ORGANIZATION,
        EINE_PLANT,
        PURCHASING_INFO_RECORD_CATEGORY,
        EINA_DELIVERY_CREATE_DATE,
        MATERIAL_NUMBER,
        EINA_MATERIAL_NUMBER_USED_BY_SUPPLIER,
        EINA_VENDOR_S_ACCOUNT_NUMBER,
        EINA_PURCHASE_ORDER_UNIT_OF_MEASURE,
        COUNTRY_OF_ISSUE_OF_CERTIFICATE_OF_ORIGIN,
        EINE_PURCHASING_GROUP,
        MINIMUM_PURCHASE_ORDER_QUANTITY,
        EINE_PLANNED_DELIVERY_TIME_IN_DAYS,
        EINE_UNDERDELIVERY_TOLERANCE_LIMIT,
        NET_PRICE_IN_PURCHASING_INFO_RECORD,
        EINE_ORDER_PRICE_UNIT,
        EINE_CONFIRMATION_CONTROL_KEY,
        EINE_MINIMUM_REMAINING_SHELF_LIFE,
        concat_ws('_', EINE_NUMBER_OF_PURCHASING_INFO_RECORD, EINE_PURCHASING_ORGANIZATION, EINE_PLANT, PURCHASING_INFO_RECORD_CATEGORY) as UNIQUE_KEY
    from {{ ref('SILVER__TEA_DIRECT_PURCHASING__PURCHASE_INFORMATION_PURCHASE_ORDER') }}
    where EINE_NUMBER_OF_PURCHASING_INFO_RECORD is not null
),

source_data as (
    select
        pir_details.EINE_NUMBER_OF_PURCHASING_INFO_RECORD as INFO_REC,
        pir_details.EINA_VENDOR_S_ACCOUNT_NUMBER as VENDOR,
        vendor_details.LFA1_NAME_1_NAME1 as VENDOR_NAME,
        pir_details.EINE_PURCHASING_ORGANIZATION as PURCHASING_ORG,
        pir_details.EINE_PURCHASING_GROUP as PURCHASING_GROUP,
        pir_details.EINE_PLANT as PLANT,
        pir_details.EINA_DELIVERY_CREATE_DATE as CREATED_ON,
        pir_details.MATERIAL_NUMBER as MATERIAL,
        mat_details.ORDER_ITEM_NAME as ORDER_ITEM_NAME,
        pir_details.EINA_MATERIAL_NUMBER_USED_BY_SUPPLIER as SUPPLIER_MATERIAL_NUMBER,
        pir_details.EINE_PLANNED_DELIVERY_TIME_IN_DAYS as PLANNED_DELIVERY_TIME,
        pir_details.EINE_UNDERDELIVERY_TOLERANCE_LIMIT as UNDERDELIVERY_TOLERANCE_LIMIT,
        pir_details.NET_PRICE_IN_PURCHASING_INFO_RECORD as NET_PRICE,
        pir_details.EINE_ORDER_PRICE_UNIT as CURRENCY,
        pir_details.COUNTRY_OF_ISSUE_OF_CERTIFICATE_OF_ORIGIN as COUNTRY,
        pir_details.PURCHASING_INFO_RECORD_CATEGORY as CAT,
        pir_details.EINA_PURCHASE_ORDER_UNIT_OF_MEASURE as UNIT_OF_MEASURE,
        pir_details.MINIMUM_PURCHASE_ORDER_QUANTITY as PO_QTY,
        pir_details.EINE_CONFIRMATION_CONTROL_KEY as CONTROL_KEY,
        pir_details.EINE_MINIMUM_REMAINING_SHELF_LIFE as MINIMUM_REMAINING_SHELF_LIFE,
        mat_prices.APPLICATION as APPLICATION,
        mat_prices.CONDITION_RECORD_NUMBER_KONP as CONDITION_RECORD_NUMBER,
        mat_prices.CONDITION_AMOUNT_OR_PERCENTAGE_WHERE_NO_SCALE_EXISTS as CONDITION_AMOUNT,
        mat_prices.CONDITION_UNIT_KONWA as CONDITION_UNIT,
        mat_prices.VALIDITY_START_DATE_OF_THE_CONDITION_RECORD as VALID_FROM,
        mat_prices.VALIDITY_END_DATE_OF_THE_CONDITION_RECORD as VALID_TO,
        pir_details.UNIQUE_KEY as UNIQUE_KEY
    from pir_details
    left join mat_prices on
        pir_details.EINA_VENDOR_S_ACCOUNT_NUMBER = mat_prices.VENDORS_ACCOUNT_NUMBER and
        pir_details.MATERIAL_NUMBER = mat_prices.MATERIAL_NUMBER
    left join mat_details on pir_details.MATERIAL_NUMBER = mat_details.MVKE_MATERIAL_NUMBER
    left join vendor_details on vendor_details.LFA1_ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR = pir_details.EINA_VENDOR_S_ACCOUNT_NUMBER
    qualify row_number() over(partition by UNIQUE_KEY order by VALID_TO desc, VALID_FROM desc, CONDITION_RECORD_NUMBER desc) = 1
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh. 
        INFO_REC,
        VENDOR,
        VENDOR_NAME,
        PURCHASING_ORG,
        PURCHASING_GROUP,
        PLANT,
        CREATED_ON,
        MATERIAL,
        ORDER_ITEM_NAME,
        SUPPLIER_MATERIAL_NUMBER,
        PLANNED_DELIVERY_TIME,
        UNDERDELIVERY_TOLERANCE_LIMIT,
        NET_PRICE,
        CURRENCY,
        COUNTRY,
        CAT,
        UNIT_OF_MEASURE,
        PO_QTY,
        CONTROL_KEY,
        MINIMUM_REMAINING_SHELF_LIFE,
        APPLICATION,
        CONDITION_RECORD_NUMBER,
        CONDITION_AMOUNT,
        CONDITION_UNIT,
        VALID_FROM,
        VALID_TO,
        UNIQUE_KEY
    from source_data
),

type_data as (
    select
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH, 
        INFO_REC,
        VENDOR,
        VENDOR_NAME,
        PURCHASING_ORG,
        PURCHASING_GROUP,
        PLANT,
        CREATED_ON,
        MATERIAL,
        ORDER_ITEM_NAME,
        SUPPLIER_MATERIAL_NUMBER,
        PLANNED_DELIVERY_TIME,
        UNDERDELIVERY_TOLERANCE_LIMIT,
        NET_PRICE,
        CURRENCY,
        COUNTRY,
        CAT,
        UNIT_OF_MEASURE,
        PO_QTY,
        CONTROL_KEY,
        MINIMUM_REMAINING_SHELF_LIFE,
        APPLICATION,
        CONDITION_RECORD_NUMBER,
        CONDITION_AMOUNT,
        CONDITION_UNIT,
        VALID_FROM,
        VALID_TO,
        UNIQUE_KEY      
    from transform_data
)

select * from type_data