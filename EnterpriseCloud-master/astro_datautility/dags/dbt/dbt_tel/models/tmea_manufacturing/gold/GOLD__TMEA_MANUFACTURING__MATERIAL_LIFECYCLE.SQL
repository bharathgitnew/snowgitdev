{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'MATERIAL_LIFECYCLE',
    transient = false
) }}

-- ============================================================================
-- Material Lifecycle Model
-- Purpose: Tracks sales order to delivery lifecycle including goods issue and purchase orders
-- ============================================================================

WITH 
-- -----------------------------------------------------------------------------
-- End User (Z1 Partner Function) - Deduplicated to one per sales document
-- -----------------------------------------------------------------------------
endUser_dedup AS (
    SELECT SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER, CUSTOMER_NUMBER
    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_PARTNER') }}
    WHERE PARTNER_FUNCTION = 'Z1'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER ORDER BY CUSTOMER_NUMBER) = 1
),

-- -----------------------------------------------------------------------------
-- Ship To Party (WE Partner Function) - Deduplicated to one per sales document
-- -----------------------------------------------------------------------------
Ship_details_dedup AS (
    SELECT SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER, CUSTOMER_NUMBER
    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_PARTNER') }}
    WHERE PARTNER_FUNCTION = 'WE'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER ORDER BY CUSTOMER_NUMBER) = 1
),

-- -----------------------------------------------------------------------------
-- Goods Issue (GI) - Aggregated by sales document and item
-- Document Category 'R' = Goods Receipt, Movement Type '601' = GI for Delivery
-- -----------------------------------------------------------------------------
gi_cte AS (
    SELECT
        PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT,
        PRECEDING_ITEM_OF_AN_SD_DOCUMENT,
        SUM(REFERENCED_QUANTITY_IN_BASE_UNIT_OF_MEASURE) AS GI_QTY
    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_FLOW') }}
    WHERE DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'R'
      AND MOVEMENT_TYPE_ = '601'
    GROUP BY PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT, PRECEDING_ITEM_OF_AN_SD_DOCUMENT
),

-- -----------------------------------------------------------------------------
-- Delivery - Aggregated by sales document and item
-- Document Category 'J' = Delivery
-- -----------------------------------------------------------------------------
delivery_cte AS (
    SELECT
        PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT,
        PRECEDING_ITEM_OF_AN_SD_DOCUMENT,
        SUM(REFERENCED_QUANTITY_IN_BASE_UNIT_OF_MEASURE) AS TOTAL_DELIVERY_QTY,
        MAX(SUBSEQUENT_SALES_AND_DISTRIBUTION_DOCUMENT) AS DELIVERY_NUMBER,
        MAX(SUBSEQUENT_ITEM_OF_AN_SD_DOCUMENT) AS DELIVERY_ITEM,
        MAX(DATE_ON_WHICH_RECORD_WAS_CREATED) AS SHIP_DATE_DO
    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_FLOW') }}
    WHERE DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'J'
    GROUP BY PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT, PRECEDING_ITEM_OF_AN_SD_DOCUMENT
),

-- -----------------------------------------------------------------------------
-- Purchase Order - One per sales document item
-- Document Category 'V' = Purchase Order
-- -----------------------------------------------------------------------------
po_cte AS (
    SELECT
        PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT,
        PRECEDING_ITEM_OF_AN_SD_DOCUMENT,
        SUBSEQUENT_SALES_AND_DISTRIBUTION_DOCUMENT AS PURCHASE_ORDER_NO,
        SUBSEQUENT_ITEM_OF_AN_SD_DOCUMENT AS ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_FLOW') }}
    WHERE DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'V'
    QUALIFY ROW_NUMBER() OVER (PARTITION BY PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT, PRECEDING_ITEM_OF_AN_SD_DOCUMENT ORDER BY SUBSEQUENT_SALES_AND_DISTRIBUTION_DOCUMENT) = 1
),

-- ============================================================================
-- Main SELECT: Sales Document Header + Item + Partner Details + Delivery + GI + PO
-- ============================================================================
source_data as (
SELECT distinct
    -- Header Fields
    h.SALES_DOCUMENT as SALES_DOCUMENT,
    h.SALES_DOCUMENT_TYPE  AS ORDER_TYPE,
    h.DOCUMENT_DATE_DATE_RECEIVEDSENT  AS DOCUMENT_DATE,
    TO_VARCHAR(TRY_TO_TIME( h.ENTRY_TIME, 'HH24MISS'), 'HH12:MI:SS AM') AS CREATION_TIME,
    h.NAME_OF_PERSON_WHO_CREATED_THE_OBJECT as Sales_Rep_Employee_Name,
    h.SOLD_TO_PARTY as SOLD_TO_PARTY,
    h.ORDER_REASON_REASON_FOR_THE_BUSINESS_TRANSACTION AS ORDER_REASON,
    trim(h.YOUR_REFERENCE) AS CUSTOMER_REQUEST_NO,
    h.CUSTOMER_PURCHASE_ORDER_NUMBER AS CUSTOMER_REFERENCE,
    h.SD_DOCUMENT_CURRENCY AS CURRENCY,
    
    -- Item Fields
    i.SALES_DOCUMENT_ITEM as SALES_DOCUMENT_ITEM,
    i.DELIVERY_PRIORITY AS ORDER_PRIORITY,
    i.SALES_DOCUMENT_ITEM_CATEGORY as SALES_DOCUMENT_ITEM_CATEGORY,
    i.MATERIAL_NUMBER as MATERIAL_NUMBER,
    i.SHORT_TEXT_FOR_SALES_ORDER_ITEM AS MATERIAL_DESCRIPTION,
    i.CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS::DECIMAL(10,2) AS CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS,
    TO_VARCHAR((CASE WHEN i.CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS = 0 THEN NULL ELSE i.NET_VALUE_OF_THE_ORDER_ITEM_IN_DOCUMENT_CURRENCY / i.CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS END)::DECIMAL(10,2), '999,999,990.00') AS UNIT_PRICE,
    TO_VARCHAR(i.NET_VALUE_OF_THE_ORDER_ITEM_IN_DOCUMENT_CURRENCY::DECIMAL(10,2), '999,999,990.00') AS NET_VALUE,
    TO_VARCHAR(i.COST_IN_DOCUMENT_CURRENCY::DECIMAL(10,2), '999,999,990.00') AS COST,
    i.STORAGE_LOCATION as STORAGE_LOCATION,
    
    -- Partner Names
    c.NAME_1 AS SALES_SOLD_TO_PARTY_NAME,
    eu.CUSTOMER_NUMBER AS ENDUSER,
    eu_c.NAME_1 AS ENDUSER_NAME,
    sh.CUSTOMER_NUMBER AS SHIP_TO_PARTY,
    sh_c.NAME_1 AS SHIP_TO_PARTY_NAME,
    
    -- Delivery Details
    dlv.DELIVERY_NUMBER as DELIVERY_NUMBER,
    dlv.DELIVERY_ITEM as DELIVERY_ITEM,
    dlv.TOTAL_DELIVERY_QTY::DECIMAL(10,2) AS DELIVERY_QTY,
    dlv.SHIP_DATE_DO as SHIP_DATE_DO,
    
    -- Goods Issue & Undelivered
    gi.GI_QTY::DECIMAL(10,2) AS GI_QTY,
    (i.CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS - COALESCE(dlv.TOTAL_DELIVERY_QTY, 0))::DECIMAL(10,2) AS UNDELIVERED,
    
    -- Purchase Order
    po.PURCHASE_ORDER_NO as PURCHASE_ORDER_NO,
    po.ITEM_NUMBER_OF_PURCHASING_DOCUMENT as ITEM_NUMBER_OF_PURCHASING_DOCUMENT 
-- ============================================================================
-- JOINs: Header + Item + Partners + Delivery + GI + Purchase Order
-- ============================================================================
FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_HEADER_DATA') }}  h

-- Join to Sales Document Item
LEFT JOIN {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_ITEM_DATA') }}    i
  ON h.SALES_DOCUMENT = i.SALES_DOCUMENT

-- Join to Sold To Party (Customer Master)
LEFT JOIN {{ ref('SILVER__TMEA_MANUFACTURING__GENERAL_DATA_IN_CUSTOMER_MASTER') }} c
  ON h.SOLD_TO_PARTY = c.CUSTOMER_NUMBER

-- Join to End User (Z1 Partner)
LEFT JOIN endUser_dedup eu
  ON h.SALES_DOCUMENT = eu.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER
LEFT JOIN {{ ref('SILVER__TMEA_MANUFACTURING__GENERAL_DATA_IN_CUSTOMER_MASTER') }} eu_c
  ON eu.CUSTOMER_NUMBER = eu_c.CUSTOMER_NUMBER

-- Join to Ship To Party (WE Partner)
LEFT JOIN Ship_details_dedup sh
  ON h.SALES_DOCUMENT = sh.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER
LEFT JOIN {{ ref('SILVER__TMEA_MANUFACTURING__GENERAL_DATA_IN_CUSTOMER_MASTER') }} sh_c
  ON sh.CUSTOMER_NUMBER = sh_c.CUSTOMER_NUMBER

-- Join to Delivery (Document Category 'J')
LEFT JOIN delivery_cte dlv
  ON dlv.PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT = i.SALES_DOCUMENT
  AND dlv.PRECEDING_ITEM_OF_AN_SD_DOCUMENT = i.SALES_DOCUMENT_ITEM

-- Join to Goods Issue (Document Category 'R', Movement Type '601')
LEFT JOIN gi_cte gi
  ON gi.PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT = i.SALES_DOCUMENT
  AND gi.PRECEDING_ITEM_OF_AN_SD_DOCUMENT = i.SALES_DOCUMENT_ITEM

-- Join to Purchase Order (Document Category 'V')
LEFT JOIN po_cte po
  ON po.PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT = i.SALES_DOCUMENT
  AND po.PRECEDING_ITEM_OF_AN_SD_DOCUMENT = i.SALES_DOCUMENT_ITEM)

 ,transform_data as (
    select
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        SALES_DOCUMENT,
        ORDER_TYPE,
        DOCUMENT_DATE,
        CREATION_TIME,
        Sales_Rep_Employee_Name,
        SOLD_TO_PARTY,
        ORDER_REASON,
        CUSTOMER_REQUEST_NO,
        CUSTOMER_REFERENCE,
        CURRENCY,
        SALES_DOCUMENT_ITEM,
        ORDER_PRIORITY,
        SALES_DOCUMENT_ITEM_CATEGORY,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS,
        UNIT_PRICE,
        NET_VALUE,
        COST,
        STORAGE_LOCATION,
        SALES_SOLD_TO_PARTY_NAME,
        ENDUSER,
        ENDUSER_NAME,
        SHIP_TO_PARTY,
        SHIP_TO_PARTY_NAME,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        DELIVERY_QTY,
        SHIP_DATE_DO,
        GI_QTY,
        UNDELIVERED,
        PURCHASE_ORDER_NO,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    from source_data
),
type_data as (
    select
		cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
      SALES_DOCUMENT ,
    ORDER_TYPE          ,
    DOCUMENT_DATE::DATE AS DOCUMENT_DATE,
    CREATION_TIME                    ,
    SALES_REP_EMPLOYEE_NAME             ,
    SOLD_TO_PARTY                      ,
    ORDER_REASON                        ,
    CUSTOMER_REQUEST_NO                ,
    CUSTOMER_REFERENCE                ,
    CURRENCY                          ,
    SALES_DOCUMENT_ITEM                ,
    ORDER_PRIORITY                  ,
    SALES_DOCUMENT_ITEM_CATEGORY       ,
    MATERIAL_NUMBER                    ,
    MATERIAL_DESCRIPTION               ,
    CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS::DECIMAL(10,2) AS CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS,
    TRY_TO_DECIMAL(REPLACE(UNIT_PRICE, ',', ''), 10, 2) AS UNIT_PRICE,
    TRY_TO_DECIMAL(REPLACE(NET_VALUE, ',', ''), 10, 2) AS NET_VALUE,
    TRY_TO_DECIMAL(REPLACE(COST, ',', ''), 10, 2) AS COST,
    STORAGE_LOCATION       ,
    SALES_SOLD_TO_PARTY_NAME        ,
    ENDUSER                           ,
    ENDUSER_NAME                      ,
    SHIP_TO_PARTY                     ,
    SHIP_TO_PARTY_NAME               ,
    DELIVERY_NUMBER                   ,
    DELIVERY_ITEM                    ,
    DELIVERY_QTY::DECIMAL(10,2) AS DELIVERY_QTY,
    SHIP_DATE_DO  ,
    GI_QTY::DECIMAL(10,2) AS GI_QTY,
    UNDELIVERED::DECIMAL(10,2) AS UNDELIVERED,
    PURCHASE_ORDER_NO                   ,
    ITEM_NUMBER_OF_PURCHASING_DOCUMENT
FROM transform_data
)
select * from type_data

