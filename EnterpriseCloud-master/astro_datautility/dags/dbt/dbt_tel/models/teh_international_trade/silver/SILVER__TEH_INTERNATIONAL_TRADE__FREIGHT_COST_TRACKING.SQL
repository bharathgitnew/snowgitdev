{{ config(
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    alias = 'FREIGHT_COST_TRACKING',
    transient = false
) }}

WITH
vbpa_cte AS (--VBPA_INFO , BUSNESS_PARTNER_INFO
    SELECT
        vbpa.VBELN AS SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER,
        vbpa.POSNR AS ITEM_NUMBER_OF_THE_SD_DOCUMENT,
        vbpa.KUNNR AS CUSTOMER_NUMBER,
        vbpa.PARVW AS PARTNER_FUNCTION
    FROM
        {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__ZCDV_T_CMTU047_VBPA') }} vbpa
         WHERE UPPER(vbpa.IS_DELETED) = 'NO'
         --and partner_function = 'SP'
),

lips_cte AS (
    SELECT
        lips.VBELN,
        lips.POSNR,
        lips.LFIMG,
        lips.VGBEL,
        lips.VGPOS,
        lips.LGORT
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__ZCDV_T_CMTU013_LIPS') }} AS lips
),
likp_cte AS (
    SELECT
        likp.VBELN,
        likp.WBSTK,
        likp.ZZSHDT,
        likp.ZZDScz,
        likp.ZZHAWB,
        likp.ZZMAWB
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU012_LIKP') }} AS likp
),
but000_cte AS (
    SELECT
        DISTINCT
        but000.PARTNER AS BUSINESS_PARTNER_NUMBER,
        but000.BU_SORT1 AS CUSTOMER_NAME,
        but000.BU_SORT2 AS CUSTOMER_NAME_B
    FROM
        {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU053_BUT000') }} but000
),
vbap_cte AS (
    SELECT
        vbap.*,
        vbap.MATNR AS VBAP_MATERIAL_NUMBER
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__ZCDV_T_CMTU010_VBAP') }} AS vbap
),
vbfa_cte as (
    SELECT vbeln,
        posnv,
        vbelv,
        posnn
  FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU064_VBFA') }} WHERE VBTYP_N = 'V'
),
vbak_cte AS (
    SELECT
        vbak.AUART,
        vbak.VBELN,
        vbak.ERDAT,
        vbak.ERZET,
        vbak.ERNAM,
        vbak.ZZOPHZ,
        vbak.ZZSREN,
        vbak.AUGRU,
        vbak.ZZCRNZ,
        vbak.BSTNK,
        vbak.WAERK
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__ZCDV_T_CMTU009_VBAK') }} AS vbak
),
mbew_cte AS (
    SELECT
        mbew.STPRS AS STANDARD_PRICE,
        mbew.MATNR AS MBEW_MATERIAL_NUMBER
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPH_SAP_US_MMT_EV_MBEW') }} AS mbew
),
t001l_cte AS (
    SELECT
        LGORT, MAX(LGOBE) AS LGOBE
    FROM
        {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU080_T001L') }}
        GROUP BY LGORT
),
ekpo_cte as (
    SELECT
        EBELN,
        EBELP,
        MATNR
    FROM
        {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPAPI_ZCDV_T_CMTU028_EKPO') }}
),
enduser_cte as (
    SELECT DISTINCT
    BP.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER as SALES_DOCUMENT,
     BP.ITEM_NUMBER_OF_THE_SD_DOCUMENT AS SALES_DOCUMENT_ITEM,
        BP.CUSTOMER_NUMBER AS END_USER_CODE,
        CUSTOMER.CUSTOMER_NAME AS END_USER_NAME,
        CUSTOMER.BUSINESS_PARTNER_NUMBER

    FROM vbpa_cte AS BP
    LEFT JOIN but000_cte CUSTOMER
    ON BP.CUSTOMER_NUMBER = CUSTOMER.BUSINESS_PARTNER_NUMBER
    WHERE BP.PARTNER_FUNCTION = 'Z6'
),

gi_details AS (
    SELECT
        DISTINCT vbak.auart,
        vbak.vbeln AS sales_order,
        vbap.posnr AS item,
        vbap.matnr AS material,
        vbap.kwmeng AS order_qty,
        COALESCE(SUM(lips.lfimg), 0) AS delivered_qty,-- delivered quantity :all delivery items that REFERENCE THE so item
        COALESCE(
            SUM(CASE WHEN likp.wbstk = 'C' -- goods movement completed
            THEN lips.lfimg
                ELSE 0
                END
                ),0) AS gi_qty,
        /* GI quantity: only delivery items whose header shows PGI complete */
        /* Undelivered (based on 'delivered_qty'); adjust if you want to base on GI */
        vbap.kwmeng - COALESCE(SUM(lips.lfimg), 0) AS undelivered_qty
    FROM
        vbak_cte vbak
        JOIN vbap_cte vbap ON vbak.vbeln = vbap.vbeln
        LEFT JOIN lips_cte lips ON vbap.vbeln = lips.vgbel AND vbap.posnr = lips.vgpos        /* Delivery header for PGI status */
        LEFT JOIN likp_cte likp ON likp.vbeln = lips.vbeln
    GROUP BY
        vbak.auart,
        vbak.vbeln,
        vbap.posnr,
        vbap.matnr,
        vbap.kwmeng
),
source_data AS (
    SELECT DISTINCT
        vbak.auart AS order_type,
        vbak.vbeln AS so_number,
        vbap.posnr AS so_line,-- "Sales Document Item",
        --vbak.erdat AS vbak_delivery_create_date,-- "Document date"
        TO_VARCHAR(TRY_TO_DATE( vbak.erdat, 'YYYYMMDD'), 'MM/DD/YYYY') AS vbak_delivery_create_date,
        --vbak.erzet AS vbak_entry_time,
        TO_VARCHAR(TRY_TO_TIME(vbak.erzet, 'HH24MISS'), 'HH12:MI:SS AM') AS vbak_entry_time,
        vbak.ernam AS vbak_delivery_cerator,
        vbap.ZZOPZZ AS order_priority,
        vbak.zzsren AS sales_rep_employee_no,
        bp_sold.CUSTOMER_NUMBER AS sales_sold_to_party,
        ac_sold.CUSTOMER_NAME AS sales_sold_to_party_name,
        enduser.END_USER_CODE AS enduser,
        enduser.END_USER_NAME AS enduser_name,
        ac_ship.CUSTOMER_NAME AS ship_to_name,
        vbak.augru AS vbak_order_reason,-- "ORDER REASON",
        vbak.zzcrnz AS customer_request_no,
        vbak.BSTNK as CUSTOMER_REFERENCE,
        vbap.POSNR as SALES_DOCUMENT_ITEM_POSNR,
        vbap.vbap_material_number,-- AS "Material",
        vbap.arktx AS vbap_short_text_for_sales_order_item,-- AS "Material Description" ,
        likp.zzdscz AS likp_delivery_service_code,-- AS "Delivery Service Code",
        gi_details.order_qty,-- AS "Cumulative order quantity in sales units",
        CASE WHEN vbap.kwmeng = 0 THEN NULL ELSE vbap.NETWR / vbap.kwmeng END AS UNIT_PRICE,
        vbap.NETWR  AS NET_VALUE,-- net VALUE
        vbak.waerk AS vbak_sd_document_currency, --CURRENCY,
        mbew.STANDARD_PRICE ,-- AS COST
        t001l_cte.LGOBE AS SLOC,
        lips.VBELN as LIPS_DELIVERY,--Delivery Order No
        gi_details.item  as DELIVERY_ITEM_POSNR,-- as "Delivery Item",
        gi_details.delivered_qty,--Delivery Qty
        likp.ZZSHDT as LIKP_SHIP_DATE,-- "Ship Date (DO)",
        gi_details.gi_qty AS "GI QTY",
        gi_details.undelivered_qty AS "Undelivered",
        likp.ZZHAWB as HAWP,
        likp.ZZMAWB as MAWB,
        ekpo.EBELN AS EBELN,--as "Purchase Order No",
        ekpo.EBELP AS EBELP -- as "Item Number of Purchasing Document"

    FROM
        vbak_cte vbak
        LEFT JOIN vbap_cte vbap ON vbak.vbeln = vbap.vbeln
        --LEFT JOIN employee_cte ed ON vbak.zzsren = ed.employee_number

        LEFT JOIN vbpa_cte bp_sold ON bp_sold.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER = vbak.vbeln
           -- AND bp_sold.ITEM_NUMBER_OF_THE_SD_DOCUMENT = vbap.posnr
            AND bp_sold.PARTNER_FUNCTION IN ('SP')
        LEFT JOIN enduser_cte enduser ON enduser.SALES_DOCUMENT = vbak.vbeln
        LEFT JOIN but000_cte ac_sold ON bp_sold.CUSTOMER_NUMBER = ac_sold.BUSINESS_PARTNER_NUMBER
        -- ship-to party (common partner function 'WE')
        LEFT JOIN vbpa_cte bp_ship ON bp_ship.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER = vbak.vbeln
           -- AND bp_ship.ITEM_NUMBER_OF_THE_SD_DOCUMENT = vbap.posnr
            AND bp_ship.PARTNER_FUNCTION IN ('WE','SH')
        LEFT JOIN but000_cte ac_ship ON bp_ship.CUSTOMER_NUMBER = ac_ship.BUSINESS_PARTNER_NUMBER

        LEFT JOIN vbfa_cte ON vbap.vbeln = vbfa_cte.VBELV AND vbap.posnr = TRY_TO_NUMBER(vbfa_cte.POSNV)
        --LEFT JOIN VBFA ON SD.VBAK_SALES_DOCUMENT = VBFA.VBELV AND SD.SALES_DOCUMENT_ITEM_POSNR = TRY_TO_NUMBER(VBFA.POSNV)

        LEFT JOIN ekpo_cte ekpo on vbfa_cte.vbeln = ekpo.ebeln AND TRY_TO_NUMBER(ekpo.EBELP) = vbfa_cte.POSNN
        --LEFT JOIN po_details as po_details  on po_details.EBELN = VBFA.VBELN AND TRY_TO_NUMBER(po_details.EBELP) = VBFA.POSNN
        -- delivery / goods issue
        LEFT JOIN lips_cte lips ON try_to_number(lips.VGBEL) = try_to_number(vbap.VBELN) AND try_to_number(lips.VGPOS) = try_to_number(vbap.POSNR)
        LEFT JOIN t001l_cte ON lips.LGORT = t001l_cte.LGORT
        LEFT JOIN likp_cte likp ON likp.vbeln = lips.vbeln
        -- material valuation / cost
        LEFT JOIN mbew_cte mbew ON mbew.MBEW_MATERIAL_NUMBER = vbap.VBAP_MATERIAL_NUMBER
        LEFT JOIN gi_details ON gi_details.sales_order = vbak.vbeln AND gi_details.item = vbap.posnr

        where
        ORDER_TYPE in ('ZF11','ZP10','ZP11','ZS14','ZS13')
),
transform_data AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        order_type,
        so_number AS SALES_DOCUMENT_NUMBER,
        so_line AS SALES_DOCUMENT_ITEM,
        vbak_delivery_create_date AS DOCUMENT_DATE,
        vbak_entry_time AS CREATION_TIME,
        vbak_delivery_cerator AS CREATED_BY,
        case when order_priority = '1' then '1: Normal'
             when order_priority = '2' then '2: Rush'
             when order_priority = '3' then '3: Urgent'
             when order_priority = '4' then '4: Emergency'
             else 'Unknown' end as ORDER_PRIORITY,
        sales_rep_employee_no AS SALES_REP_EMPLOYEE_NUMBER,

        sales_sold_to_party AS SALES_SOLD_TO_PARTY,
        sales_sold_to_party_name AS SALES_SOLD_TO_PARTY_NAME,
        enduser AS ENDUSER,
        enduser_name AS ENDUSER_NAME,
        ship_to_name AS SHIP_TO_PARTY_NAME,
        vbak_order_reason AS ORDER_REASON,
        customer_request_no AS CUSTOMER_REQUEST_NO,
        CUSTOMER_REFERENCE,
        SALES_DOCUMENT_ITEM_POSNR,
        vbap_material_number AS MATERIAL,
        vbap_short_text_for_sales_order_item AS MATERIAL_DESCRIPTION,
        likp_delivery_service_code AS DELIVERY_SERVICE_CODE,
        order_qty AS CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS,
        UNIT_PRICE,
        NET_VALUE,
        vbak_sd_document_currency AS CURRENCY,
        STANDARD_PRICE AS COST,
        SLOC AS STORAGE_LOCATION,
        LIPS_DELIVERY AS DELIVERY_NUMBER,
        DELIVERY_ITEM_POSNR AS DELIVERY_ITEM,
        delivered_qty AS DELIVERY_QTY,
        TO_VARCHAR(TRY_TO_DATE(NULLIF(LIKP_SHIP_DATE, '00000000'), 'YYYYMMDD'), 'MM/DD/YYYY') AS SHIP_DATE_DO,
        "GI QTY" AS GI_QTY,
        "Undelivered" AS UNDELIVERED,
        HAWP AS HOUSE_AIRWAY_BILL,
        MAWB AS MASTER_AIRWAY_BILL,
        EBELN AS PURCHASE_ORDER_NO,
        EBELP AS ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    FROM source_data
),
type_data as (
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        order_type ,
         SALES_DOCUMENT_NUMBER,
         SALES_DOCUMENT_ITEM,
         DOCUMENT_DATE,
         CREATION_TIME,
         CREATED_BY,
         ORDER_PRIORITY,
         SALES_REP_EMPLOYEE_NUMBER,
         SALES_SOLD_TO_PARTY,
         SALES_SOLD_TO_PARTY_NAME,
         ENDUSER,
         ENDUSER_NAME,
         SHIP_TO_PARTY_NAME,
         ORDER_REASON,
         CUSTOMER_REQUEST_NO,
         CUSTOMER_REFERENCE,
         SALES_DOCUMENT_ITEM_POSNR,
         MATERIAL,
         MATERIAL_DESCRIPTION,
         DELIVERY_SERVICE_CODE,
         CUMULATIVE_ORDER_QUANTITY_IN_SALES_UNITS,
         UNIT_PRICE::FLOAT as UNIT_PRICE,
         NET_VALUE,
         CURRENCY,
         COST,
         STORAGE_LOCATION,
         DELIVERY_NUMBER,
         DELIVERY_ITEM,
         DELIVERY_QTY::FLOAT as DELIVERY_QTY,
         SHIP_DATE_DO,
         GI_QTY::NUMBER(30,5) as GI_QTY,
         UNDELIVERED::FLOAT as UNDELIVERED,
         HOUSE_AIRWAY_BILL,
         MASTER_AIRWAY_BILL,
        PURCHASE_ORDER_NO ,
        ITEM_NUMBER_OF_PURCHASING_DOCUMENT
    FROM transform_data
)

SELECT * FROM type_data
