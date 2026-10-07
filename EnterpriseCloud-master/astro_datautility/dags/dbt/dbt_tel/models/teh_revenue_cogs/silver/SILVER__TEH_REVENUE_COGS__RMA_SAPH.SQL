{{ config(
            materialized='tel_incremental',
            incremental_strategy='insert_overwrite',
            alias='RMA_SAPH',
            transient=false    
) }}

WITH
EKPO AS (
    SELECT
        EKKO.EBELN,
        EKPO.EBELP,
        EKKO.BSART,
        EKKO.LIFNR,
        EKKO.SUBMI,
        EKKO.ANGNR,
        EKKO.ZZPOCZZ,
        EKPO.TXZ01,
        EKPO.MATNR,
        EKPO.WERKS,
        EKPO.MENGE,
        EKPO.NETWR,
        EKPO.MWSKZ,
        EKPO.ZZRMTZ,
        EKPO.ZZRSNZ,
        EKPO.ZZRPSNZ,
        EKPO.ZZVRNZ,
        EKPO.ZZFWRD,
        EKKO.INCO1,
        EKKO.INCO2,
        EKKO.ERNAM,
        EKPO.ZZRNZZ,
        EKPO.KUNNR,
        EKPO.LGORT,
        EKPO.KO_PRCTR,
        EKPO.BANFN 
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU028_EKPO') }} AS EKPO
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU027_EKKO') }} AS EKKO ON EKKO.EBELN = EKPO.EBELN 
    WHERE EKPO.loekz <> 'L'
),
AUFK AS (
    SELECT DISTINCT
        AUFK.AUART,
        EKKN.EBELN,
        EKKN.EBELP,
        AUFK.AUFNR,
        AUFK.KDAUF,
        AUFK.KDPOS
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU090_AUFK') }} AS AUFK
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU049_EKKN') }} AS EKKN ON (EKKN.AUFNR = AUFK.AUFNR)
    WHERE AUFK.AUART IN ('ZS01', 'ZS02', 'ZS03')
),
VBAP AS (
    select 
        VBAK.VBELN,
        VBAK.AUART,
        VBAK.ERNAM,
        VBAK.KUNNR,
        VBAP.POSNR,
        VBAK.NETWR,
        VBAP.KWMENG,
        VBAP.WERKS,
        VBAP.MATNR,
        VBAP.PRCTR,
        VBAP.ARKTX,
        VBAP.LGORT
    FROM {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU009_VBAK') }} AS VBAK
    LEFT JOIN {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU010_VBAP') }} AS VBAP ON (VBAK.VBELN = VBAP.VBELN)
    WHERE VBAP.IS_DELETED ='No' 
),
-- Delivery base CTE
LIPS AS (
    SELECT
        LIPS.VGBEL,
        LIPS.VGPOS,
        LIKP.WADATIST,
        LIPS.VBELN,
        LIPS.POSNR,
        LIPS.VBELV,
        LIPS.POSNV,
        LIPS.LFIMG,
        LIPS.ZZRNZZ,
        LIKP.KOSTK,
        LIPS.BWART
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU013_LIPS') }} as LIPS
    LEFT JOIN {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU012_LIKP') }}  as LIKP on (LIKP.VBELN = LIPS.VBELN)
    WHERE LIPS.LFIMG > 0 AND LIPS.IS_DELETED = 'No'
),
-- Inbound deliveries
IBD as (SELECT * FROM LIPS WHERE BWART IN ('101', '102')),
-- Outbound deliveries
OBD as (SELECT * FROM LIPS WHERE BWART IN ('541', '542')),
IBD_customer as (SELECT * FROM LIPS WHERE BWART IN ('653', '654')),
OBD_customer as (SELECT * FROM LIPS WHERE BWART IN ('601', '602')),
INV AS (SELECT DISTINCT VBELN, VGBEL FROM {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU015_VBRP') }} as VBRP),
RMA_CASE_MAP_RN AS (
    SELECT
        WOI.TEA_RMA_NUMBER,
        WOI.TICKETNUMBER AS CRM_CASE_NO,
        ROW_NUMBER() OVER(PARTITION BY WOI.TEA_RMA_NUMBER ORDER BY WOI.CREATEDON DESC) AS RN,
        COUNT(*) OVER(PARTITION BY WOI.TEA_RMA_NUMBER) AS CASES_MATCHING_RMA
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__CRM_FILE_INCIDENT') }} AS WOI
    WHERE WOI.TEA_RMA_NUMBER IS NOT NULL
),
RMA_CASE_MAP AS (
    SELECT TEA_RMA_NUMBER AS RMA, CRM_CASE_NO AS LATEST_CRM_CASE_NO
    FROM RMA_CASE_MAP_RN WHERE RN = 1
),
EKBE_GR as (
    SELECT 
        EBELN, 
        EBELP, 
        BELNR, 
        BUDAT,
        CASE BWART  
            WHEN '101' THEN TO_NUMBER(EKBE.MENGE) 
            ELSE TO_NUMBER(EKBE.MENGE) * -1 
        END AS GR_QTY,
        SUM(GR_QTY) OVER (
            PARTITION BY EBELN, EBELP 
            ORDER BY EBELN, EBELP, BUDAT 
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RUNNING_GR
    FROM {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU217_EKBE') }} AS EKBE
    WHERE BEWTP = 'E' AND BWART IN ('101', '102')
),
FINAL_GR AS (
    SELECT EBELN, EBELP, max(BUDAT) as BUDAT FROM EKBE_GR 
    WHERE running_gr > 0 GROUP BY EBELN, EBELP
),
SOURCE_DATA as ( 
    SELECT
        CASE WHEN EKPO.EBELN IS NULL THEN FALSE ELSE TRUE END AS HAS_PO,
        CASE WHEN VBAP.VBELN IS NULL THEN FALSE ELSE TRUE END AS HAS_SO,
        EKPO.EBELN AS PO_HDR,
        EKPO.EBELP AS PO_ITM,
        EKPO.BSART AS PO_DOC_TYPE,
        VBAK.VBELN AS SO_HDR,
        VBAP.POSNR AS SO_ITM,
        VBAK.AUART AS SO_DOC_TYPE,
        EKPO.LIFNR AS VENDOR,
        EKPO.SUBMI AS Collective_No,
        ANGNR  AS Quotation,
        ZZPOCZZ AS PO_Classification,
        COALESCE(EKPO.TXZ01, VBAP.ARKTX) AS SHORT_TEXT,
        COALESCE(EKPO.MATNR, VBAP.MATNR) AS MATERIAL,
        COALESCE(EKPO.WERKS, VBAP.WERKS) AS PLANT,
        COALESCE(EKPO.LGORT, VBAP.LGORT) AS STORAGE_LOCATION,
        EKPO.MENGE AS PO_ORDER_QTY,
        EKPO.NETWR AS PO_PRICE,
        EKPO.MWSKZ AS TAX_CODE,
        COALESCE(EKPO.KO_PRCTR, VBAP.PRCTR) AS PROFIT_CENTER,
        EKPO.BANFN AS Purchase_Requisition,
        EKPO.ZZRMTZ AS Repair_Material_Type,
        EKPO.ZZRSNZ AS Request_Serial_Number,
        EKPO.ZZRPSNZ AS Repaired_Serial_Number,
        EKPO.ZZVRNZ AS Vendor_RMA_Number,
        EKPO.ZZFWRD AS Forwarder_No,
        EKPO.INCO1 AS Incoterm,
        EKPO.INCO2 AS Incoterm_1,
        AUFK.AUFNR AS SVO,
        AUFK.KDAUF AS SO,
        EKPO.ERNAM AS PO_Created_by,
        VBAP.ERNAM AS SO_Created_by,
        VBAP.NETWR AS SO_price,
        OBD.VBELN AS OBD_vendor,
        OBD.KOSTK AS OBD_Pick_vendor,
        OBD.WADATIST AS GL_vendor,
        EKES_LA.VBELN  AS IBD_vendor,
        TRY_TO_DATE(EKBE_GR.BUDAT,'YYYYMMDD') AS GR,
        --EKBE_INV.BUDAT AS Invoice_vendor,
        EKES_AB.EINDT AS AB,
        EKES_LA.EINDT AS LA,
        IBD_customer.VBELN AS IBD_Customer,
        IBD_customer.WADATIST AS GR_Customer,
        OBD_customer.VBELN AS OBD_Customer,
        OBD_customer.KOSTK AS OBD_Pick_Customer,
        OBD_customer.WADATIST AS GI_customer,
        INV.VBELN AS Invoice_customer,
        COALESCE(NULLIF(VBAK.KUNNR, ''), NULLIF(EKPO.KUNNR, '')) AS customer,
        KNA1.NAME1 AS Customer_Desc,
        EKPO.ZZRNZZ AS PO_RMA_Number,
        RESB.CHARG AS Batch,
        VBAK.ZZSCWN AS SERVICE_CRM_WO_NUMBER,
        RMA_CASE_MAP.LATEST_CRM_CASE_NO,
        WO.STATUSCODE AS WO_STATUS_CODE, 
        WO.CREATEDBYNAME AS WO_CREATED_BY, 
        WO.CREATEDON AS WO_CREATED_ON, 
        WO.WO_COMPLETIONTIME
    -- AUFK stores information related to production planning and plant maintenence
    FROM AUFK
    -- RESB: Reservation / Dependant requirements table
    -- Reservations are requests for materials on a specific date.
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU235_RESB') }} AS RESB ON (TRY_TO_NUMBER(RESB.AUFNR) = AUFK.AUFNR AND RESB.CHARG IS NOT NULL)
    LEFT JOIN {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU009_VBAK') }} AS VBAK ON (AUFK.KDAUF = VBAK.VBELN)
    LEFT JOIN {{ ref('SILVER__TEH_REVENUE_COGS__ZCDV_T_CMTU010_VBAP') }} AS VBAP ON (AUFK.KDAUF = VBAP.VBELN AND AUFK.KDPOS = VBAP.POSNR)
    --left join VBAP on (AUFK.KDAUF = VBAP.VBELN  and AUFK.KDPOS = VBAP.POSNR)
    LEFT JOIN IBD_customer ON (
        try_to_number(IBD_customer.vbelv) = VBAP.VBELN AND  IBD_customer.POSNV = VBAP.POSNR
    ) --653
    LEFT JOIN OBD_customer ON (
        try_to_number(OBD_customer.vbelv) = VBAP.VBELN AND  OBD_customer.POSNV = VBAP.POSNR
    ) --601
    LEFT JOIN EKPO AS EKPO ON (
        try_to_number(aufk.EBELN) =  try_to_number(EKPO.EBELN) AND 
        try_to_number(aufk.EBELP) = try_to_number(EKPO.EBELP)
    )
    LEFT JOIN OBD AS OBD ON (
        try_to_number(OBD.VGBEL) =  try_to_number(EKPO.EBELN) AND 
        try_to_number(OBD.VGPOS) = try_to_number(AUFk.EBELP)
    )--543
    LEFT JOIN IBD AS IBD ON try_to_number(IBD.VGBEL) = EKPO.EBELN AND  IBD.VGPOS = try_to_number(EKPO.EBELP)--101
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU050_EKES') }} AS EKES_LA ON (
        EKES_LA.EBELN = EKPO.EBELN AND EKES_LA.EBELP = EKPO.EBELP AND
        EKES_LA.EBTYP = 'LA' AND EKES_LA.MENGE > 0
    )
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU050_EKES') }} AS EKES_AB ON (
        EKES_AB.EBELN = EKPO.EBELN AND EKES_LA.EBELP = EKPO.EBELP AND 
        EKES_AB.EBTYP = 'AB' AND EKES_AB.MENGE > 0
    )
    LEFT JOIN FINAL_GR AS EKBE_GR ON (
        TRY_TO_NUMBER(EKBE_GR.EBELN) = EKPO.EBELN AND 
        TRY_TO_NUMBER(EKPO.EBELP) = EKBE_GR.EBELP
    )
    --LEFT JOIN EKBE_INV AS  EKBE_INV ON  (
    --    try_to_number(EKBE_INV.EBELN) = EKPO.EBELN AND EKBE_INV.EBELP = try_to_number(EKPO.EBELP)
    --)
    LEFT JOIN Inv AS INV ON (try_to_number(INV.VGBEL) = VBAP.VBELN)
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__SAPAPI_ZCDV_T_CMTU020_KNA1') }} AS KNA1 ON (
        KNA1.KUNNR = COALESCE(NULLIF(VBAK.KUNNR, ''), NULLIF(EKPO.KUNNR, ''))
    )
    LEFT JOIN RMA_CASE_MAP ON (RMA_CASE_MAP.RMA = EKPO.ZZRNZZ)
    LEFT JOIN {{ ref('BRONZE__TEH_REVENUE_COGS__CRM_FILE_MSDYN_WORKORDER') }} AS WO ON (WO.MSDYN_NAME = VBAK.ZZSCWN)
    WHERE 
       (VBAP.IS_DELETED = 'No' OR VBAP.VBELN IS NULL) 
),
TRANSFORM_DATA AS (
    SELECT 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        HAS_PO,
        HAS_SO,
        PO_HDR,
        PO_ITM,
        PO_DOC_TYPE,
        SO_HDR,
        SO_ITM,
        SO_DOC_TYPE,
        VENDOR,
        Collective_No,
        Quotation,
        PO_Classification,
        SHORT_TEXT,
        MATERIAL,
        PLANT,
        STORAGE_LOCATION,
        PO_ORDER_QTY,
        PO_PRICE,
        TAX_CODE,
        PROFIT_CENTER,
        Purchase_Requisition,
        Repair_Material_Type,
        Request_Serial_Number,
        Repaired_Serial_Number,
        Vendor_RMA_Number,
        Forwarder_No,
        Incoterm,
        Incoterm_1,
        SVO,
        SO,
        PO_Created_by,
        SO_Created_by,
        SO_price,
        OBD_vendor,
        OBD_Pick_vendor,
        GL_vendor,
        IBD_vendor,
        GR,
        --Invoice_vendor,
        AB,
        LA,
        IBD_Customer,
        GR_Customer,
        OBD_Customer,
        OBD_Pick_Customer,
        GI_customer,
        INVOICE_CUSTOMER,
        CUSTOMER,
        Customer_Desc,
        PO_RMA_Number,
        BATCH,
        SERVICE_CRM_WO_NUMBER,
        LATEST_CRM_CASE_NO,
        WO_STATUS_CODE, 
        WO_CREATED_BY, 
        WO_CREATED_ON, 
        WO_COMPLETIONTIME
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        CAST(HAS_PO AS VARCHAR(16777216)) AS HAS_PO,
        CAST(HAS_SO AS VARCHAR(16777216)) AS HAS_SO,
        CAST(PO_HDR AS VARCHAR(16777216)) AS PO_HDR,
        CAST(PO_ITM AS VARCHAR(16777216)) AS PO_ITM,
        CAST(PO_DOC_TYPE AS VARCHAR(16777216)) AS PO_DOC_TYPE,
        CAST(SO_HDR AS VARCHAR(16777216)) AS SO_HDR,
        CAST(SO_ITM AS VARCHAR(16777216)) AS SO_ITM,
        CAST(SO_DOC_TYPE AS VARCHAR(16777216)) AS SO_DOC_TYPE,
        CAST(VENDOR AS VARCHAR(16777216)) AS VENDOR,
        CAST(Collective_No AS VARCHAR(16777216)) AS Collective_No,
        CAST(Quotation AS VARCHAR(16777216)) AS Quotation,
        CAST(PO_Classification AS VARCHAR(16777216)) AS PO_Classification,
        CAST(SHORT_TEXT AS VARCHAR(16777216)) AS SHORT_TEXT,
        CAST(MATERIAL AS VARCHAR(16777216)) AS MATERIAL,
        CAST(PLANT AS VARCHAR(16777216)) AS PLANT,
        CAST(STORAGE_LOCATION AS VARCHAR(16777216)) AS STORAGE_LOCATION,
        CAST(PO_ORDER_QTY AS INT) AS PO_ORDER_QTY, -- Assuming it's related to quantity
        CAST(PO_PRICE AS FLOAT) AS PO_PRICE,    -- Assuming it's related to price
        CAST(TAX_CODE AS VARCHAR(16777216)) AS TAX_CODE,
        CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
        CAST(Purchase_Requisition AS VARCHAR(16777216)) AS Purchase_Requisition,
        CAST(Repair_Material_Type AS VARCHAR(16777216)) AS Repair_Material_Type,
        CAST(Request_Serial_Number AS VARCHAR(16777216)) AS Request_Serial_Number,
        CAST(Repaired_Serial_Number AS VARCHAR(16777216)) AS Repaired_Serial_Number,
        CAST(Vendor_RMA_Number AS VARCHAR(16777216)) AS Vendor_RMA_Number,
        CAST(Forwarder_No AS VARCHAR(16777216)) AS Forwarder_No,
        CAST(Incoterm AS VARCHAR(16777216)) AS Incoterm,
        CAST(Incoterm_1 AS VARCHAR(16777216)) AS Incoterm_1,
        CAST(SVO AS VARCHAR(16777216)) AS SVO,
        CAST(SO AS VARCHAR(16777216)) AS SO,
        CAST(PO_Created_by AS VARCHAR(16777216)) AS PO_Created_by,
        CAST(SO_Created_by AS VARCHAR(16777216)) AS SO_Created_by,
        CAST(SO_price AS FLOAT) AS SO_price,  -- Assuming it's related to price
        CAST(OBD_vendor AS VARCHAR(16777216)) AS OBD_vendor,
        CAST(OBD_Pick_vendor AS VARCHAR(16777216)) AS OBD_Pick_vendor,
        CAST(GL_vendor AS VARCHAR(16777216)) AS GL_vendor,
        CAST(IBD_vendor AS VARCHAR(16777216)) AS IBD_vendor,
        CAST(GR AS VARCHAR(16777216)) AS GR,
        --CAST(Invoice_vendor AS VARCHAR(16777216)) AS Invoice_vendor,
        CAST(AB AS VARCHAR(16777216)) AS AB,
        CAST(LA AS VARCHAR(16777216)) AS LA,
        CAST(IBD_Customer AS VARCHAR(16777216)) AS IBD_Customer,
        CAST(GR_Customer AS VARCHAR(16777216)) AS GR_Customer,
        CAST(OBD_Customer AS VARCHAR(16777216)) AS OBD_Customer,
        CAST(OBD_Pick_Customer AS VARCHAR(16777216)) AS OBD_Pick_Customer,
        CAST(GI_customer AS VARCHAR(16777216)) AS GI_customer,
        CAST(Invoice_customer AS VARCHAR(16777216)) AS Invoice_customer,
        CAST(customer AS VARCHAR(16777216)) AS customer,
        CAST(Customer_Desc AS VARCHAR(16777216)) AS Customer_Desc,
        CAST(PO_RMA_Number AS VARCHAR(16777216)) AS PO_RMA_Number,
        CAST(BATCH AS VARCHAR(16777216)) AS BATCH,
        CAST(SERVICE_CRM_WO_NUMBER AS VARCHAR(16777216)) AS SERVICE_CRM_WO_NUMBER,
        CAST(LATEST_CRM_CASE_NO AS VARCHAR(16777216)) AS LATEST_CRM_CASE_NO,
        CAST(WO_STATUS_CODE AS VARCHAR(16777216)) AS WO_STATUS_CODE,
        CAST(WO_CREATED_BY AS VARCHAR(16777216)) AS WO_CREATED_BY,
        CAST(WO_CREATED_ON AS DATETIME) AS WO_CREATED_ON,
        CAST(WO_COMPLETIONTIME AS DATETIME) AS WO_COMPLETIONTIME
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA