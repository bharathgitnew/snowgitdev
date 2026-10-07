{{ config(
        alias = 'OTD_PURCHASE_LT',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false
) }}




WITH vbak_cte AS (
    SELECT * FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }}
    WHERE IS_DELETED = 'No'
),

vbap_cte AS (
    SELECT * FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }}
    WHERE IS_DELETED = 'No'
),

MAX_DELIVERY_DATE AS (
    SELECT DISTINCT
        LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT,
        LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM,
        SUM(LIPS_ACTUAL_QUANTITY_DELIVERED)      AS DELIVERED_QTY,
        MAX(LIKP_DOCUMENT_DATE_IN_DOCUMENT)      AS LIKP_DOCUMENT_DATE,
        MAX(LIKP_ACTUAL_GOODS_MOVEMENT_DATE)     AS LIKP_ACTUAL_GOODS_MOVEMENT_DATE
    FROM {{ ref('SILVER__TEA_SALES_REVENUE__DELIVERY_ORDER_LINE_MASTER') }}
    WHERE LIPS_ACTUAL_QUANTITY_DELIVERED > 0
    GROUP BY
        LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT,
        LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM
),

MAX_VBEP AS (
    SELECT DISTINCT
        VBELN,
        POSNR,
        MAX(CREA_DLVDATE) AS COMMIT_DATE
    FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU011_VBEP') }}
    GROUP BY VBELN, POSNR
),

VBPA_INFO AS (
    SELECT DISTINCT
        SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_THE_SD_DOCUMENT,
        CUSTOMER_NUMBER,
        PARTNER_FUNCTION
    FROM {{ ref('SILVER__TEA_SALES_REVENUE__BUSINESS_PARTNERS') }}
    WHERE PARTNER_FUNCTION = 'SP'
),

BP_INFO AS (
    SELECT DISTINCT
        SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER,
        ITEM_NUMBER_OF_THE_SD_DOCUMENT,
        CUSTOMER_NUMBER,
        PARTNER_FUNCTION
    FROM {{ ref('SILVER__TEA_SALES_REVENUE__BUSINESS_PARTNERS') }}
    WHERE PARTNER_FUNCTION = 'BP'
),

MARC AS (
    SELECT
        MATNR,
        ZZLABC,
        ZZSABC,
        ZZINTF
    FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU026_MARC') }}
    WHERE WERKS = '3200'
),

EINA_CTE AS (
    SELECT DISTINCT
        INFNR,
        MATNR,
        LIFNR  
    FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU074_EINA') }}
    WHERE LOEKZ = 'false'   
),


LT_HISTORY AS (
    SELECT
        EINA.MATNR,
        EINE.WERKS,
        EINE.SNAPSHOT_DATE,
        MIN(TRY_CAST(EINE.APLFZ AS NUMBER(38,0)))   AS PURCHASE_LT_DAYS,
        LEAD(EINE.SNAPSHOT_DATE) OVER (
            PARTITION BY EINA.MATNR, EINE.WERKS
            ORDER BY EINE.SNAPSHOT_DATE
        )                                            AS NEXT_SNAPSHOT_DATE,
        -- FIX: earliest snapshot per MATNR/plant, used as fallback anchor
        --      for orders placed before EINE history begins (pre 2023-05-07)
        MIN(EINE.SNAPSHOT_DATE) OVER (
            PARTITION BY EINA.MATNR, EINE.WERKS
        )                                            AS EARLIEST_SNAPSHOT_DATE
    FROM {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU073_EINE_HIST') }} EINE
    JOIN EINA_CTE EINA
        ON EINE.INFNR = EINA.INFNR
    WHERE EINE.WERKS  IN ('3200', '3300')
      AND EINE.EKORG  = '3200'
      AND EINE.LOEKZ  = 'false'
    GROUP BY
        EINA.MATNR,
        EINE.WERKS,
        EINE.SNAPSHOT_DATE
),

SOURCE_DATA AS (
    SELECT
        VBAP.ZZORZZ                                             AS ORDER_REASON,
        CASE
            WHEN VBAP.ZZORZZ = 'GNP' AND VBAK.AUART = 'ZF11'                              THEN 'SLS'
            WHEN LEFT(VBAP.ZZORZZ, 2) = 'R0'
              OR LEFT(VBAK.AUART, 2)  = 'ZE'
              OR LEFT(VBAK.AUART, 3)  = 'ZSQ'                                              THEN 'SLS'
            WHEN LEFT(VBAK.AUART, 2)  = 'ZX'
              OR LEFT(VBAP.ZZORZZ, 2) = 'R0'                                               THEN 'SLS/SRV'
            WHEN LEFT(VBAK.AUART, 2)  = 'ZC'
              OR VBAK.AUART           = 'ZSC1'                                             THEN 'SRV'
            WHEN VBAP.ZZORZZ IN (
                'CU2','CHE','CPR','GNS','IPD','IPR','IPS','MOD','OCR','POR',
                'PWI','PWO','R01','R07','RTC','RPR','SLS','SMI','TRN','WWW',
                'XML','XPT','ZOT','ZSF','ZTR')                                             THEN 'SLS'
            WHEN VBAP.ZZORZZ IN (
                'CNP','CUE','EVL','EVP','FAC','FCN','GNP','LNR','FRI','FRW',
                'PDF','PDS','PPW','PRW','PSO','STO','SUP','SSC','SSM','SWS',
                'TBS','TEL','TWS','WKT','WTY')                                             THEN 'SRV'
            WHEN VBAP.ZZORZZ = 'IPO' OR VBAK.AUART = 'ZT10'                               THEN 'IPO'
            ELSE 'UNDEFINED'
        END                                                     AS ORDER_TYPE,

        VBAK.AUART                                              AS SALES_DOC_TYPE,
        VBAP.ZZOPZZ                                             AS ORDER_PRIORITY_CODE,
        CASE
            WHEN ZZOPZZ = '4' THEN 'EMERGENCY'
            WHEN ZZOPZZ = '3' THEN 'URGENT'
            WHEN ZZOPZZ = '2' THEN 'RUSH'
            WHEN ZZOPZZ = '1' THEN 'NORMAL'
            ELSE 'N/A'
        END                                                     AS ORDER_PRIORITY_NAME,

        CONCAT(VBAP.VBELN, '-', VBAP.POSNR)                    AS SO_LINE,
        VBAP.VBELN,
        VBAP.POSNR,
        VBAP.ZZNNZZ                                             AS NCDR_NUMBER,
        MAX_DELIVERY_DATE.LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT,
        MAX_DELIVERY_DATE.LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM,
        VBAP.LGORT,
        VBAP.MATNR,
        MARC.ZZLABC                                             AS ABC_LOCAL,
        MARC.ZZSABC                                             AS ABC_SPECIAL_CUSTOMER,
        MARA.ZZNARABC                                           AS ABC_NARITA,
        MARC.ZZINTF                                             AS INTEL_FLAG,
        VBPA_INFO.CUSTOMER_NUMBER                               AS SOLD_TO_PARTY,
        KNA1.NAME1                                              AS SOLD_TO_PARTY_NAME,
        BP_INFO.CUSTOMER_NUMBER                                 AS BILL_TO_PARTY,
        KNA2.NAME1                                              AS BILL_TO_PARTY_NAME,
        VBAP.ERDAT                                              AS ORDER_DATE,
        VBAK.VDATU                                              AS REQUESTED_DELIVERY_DATE,
        VBEP.COMMIT_DATE,
        LIKP_ACTUAL_GOODS_MOVEMENT_DATE                         AS DELIVERY_DATE,
        LIKP_DOCUMENT_DATE,
        CASE WHEN (VBAP.ERDAT <= VBAK.VDATU) THEN TRUE ELSE FALSE END  AS ODT_CRDT,
        CASE WHEN (LIKP_ACTUAL_GOODS_MOVEMENT_DATE < VBAK.VDATU) THEN TRUE ELSE FALSE END AS DDT_CRDT,
        VBAP.KLMENG                                             AS CONFIRMED_QTY,
        DELIVERED_QTY,

        CASE
            WHEN VBAP.ZZORZZ IN (
                'BBK','CU2','EXC','IPD','IPR','IPS','OCR','POR',
                'PWI','PWO','RPR','SLS','SMI','TRN','TRQ','WWW',
                'XML','XPT','TBS')                              THEN 'SALES'
            WHEN VBAP.ZZORZZ IN ('CNP','CON','FLX','PDS')      THEN 'SRVC'
            ELSE 'NCDR'
        END                                                     AS CAT,

        CASE WHEN ZZOPZZ = '4' THEN 'EMG' ELSE 'NON-EMG' END   AS EMG,

        CASE
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE IS NULL        THEN NULL
            WHEN VBEP.COMMIT_DATE IS NULL                       THEN 1
            WHEN VBAP.ZZORZZ = 'SMI'                            THEN 1
            WHEN ZZOPZZ = '4'
             AND LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAK.VDATU <= 2 THEN 1
            WHEN ZZOPZZ = '4'
             AND LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAK.VDATU >  2 THEN 0
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAK.VDATU  <  2 THEN 1
            ELSE 0
        END                                                     AS CMT,

        CASE
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE IS NULL        THEN NULL
            WHEN VBAK.VDATU = NULL                              THEN 1
            WHEN ZZORZZ IN ('SMI','SWS','TBS','TWS')            THEN 1
            WHEN ZZOPZZ = '4'
             AND LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAP.ERDAT <= 2 THEN 1
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAP.ERDAT  <  2.5 THEN 1
            ELSE 0
        END                                                     AS CR,

        CASE
            WHEN ZZORZZ IN ('BBK','EVL','FAC','FCN','IPD','IPS','MOD','PWI','TEL','TRN')
                THEN 'INT'
            ELSE 'EXT'
        END                                                     AS EXT,

        CASE WHEN CR IS NULL THEN 0 ELSE 1 END                  AS COUNT,
        CASE WHEN LEFT(KNA1.NAME1, 3) = 'INT' THEN 'INTEL' ELSE 'NON-INTEL' END AS INTEL,

        CASE
            WHEN DELIVERED_QTY < 0                              THEN 2
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE IS NULL        THEN 2
            WHEN LENGTH(VBAP.MATNR) <= 10                       THEN 2
            WHEN ZZORZZ IN ('PWI','FAC','FCN','TEL','EVL','MOD') THEN 2
            WHEN ZZORZZ = 'FCN'
             AND LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBEP.COMMIT_DATE < 2 THEN 1
            WHEN ZZORZZ IN ('SMI','TWS','TBS','SWS')            THEN 1
            WHEN VBAP.STOCKLOC = 'Z100'                         THEN 0
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE - VBAP.ERDAT <= 7 THEN 1
            ELSE 0
        END                                                     AS SAVAIL,

        VBAP.MVGR1                                              AS BU,
        MVKE.MVGR2                                              AS MATERIAL_GROUP_2,
        CASE WHEN MVKE.MVGR2 = '0' THEN 'CONSUMABLE' ELSE 'NON-CONSUMABLE' END AS CONS,
        LEFT(LIKP_ACTUAL_GOODS_MOVEMENT_DATE, 6)                AS ODT_MONTH,
        LT.PURCHASE_LT_DAYS                                     AS STD_LT_DAYS,

        -- FIX: flag whether the LT was matched point-in-time or via fallback
        CASE
            WHEN LT.PURCHASE_LT_DAYS IS NULL                                    THEN NULL
            WHEN TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD') < LT.EARLIEST_SNAPSHOT_DATE THEN 'FALLBACK_EARLIEST'
            ELSE 'POINT_IN_TIME'
        END                                                     AS LT_SOURCE,

        DATEADD(
            DAY,
            LT.PURCHASE_LT_DAYS,
            TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD')
        )                                                       AS LT_TARGET_DATE,

        CASE
            WHEN LIKP_ACTUAL_GOODS_MOVEMENT_DATE IS NULL        THEN NULL  -- not yet delivered
            WHEN LT.PURCHASE_LT_DAYS IS NULL                    THEN NULL  -- no LT data in EINE
            WHEN VBAP.ZZORZZ IN ('SMI','SWS','TBS','TWS')       THEN 1     -- auto-pass

            WHEN VBAP.ZZOPZZ = '4'
             AND DATEDIFF(
                    DAY,
                    TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD'),
                    TRY_TO_DATE(LIKP_ACTUAL_GOODS_MOVEMENT_DATE, 'YYYYMMDD')
                ) <= 2                                          THEN 1
            WHEN VBAP.ZZOPZZ = '4'                             THEN 0
            
            WHEN TRY_TO_DATE(LIKP_ACTUAL_GOODS_MOVEMENT_DATE, 'YYYYMMDD')
                 <= DATEADD(
                        DAY,
                        LT.PURCHASE_LT_DAYS,
                        TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD')
                    )                                           THEN 1
            ELSE 0
        END                                                     AS OTD_VS_STD_LT

    FROM vbak_cte VBAK
    JOIN vbap_cte VBAP
        ON VBAK.VBELN = VBAP.VBELN
    LEFT JOIN MAX_DELIVERY_DATE
        ON  VBAP.VBELN  = MAX_DELIVERY_DATE.LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT
        AND VBAP.POSNR  = MAX_DELIVERY_DATE.LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM
    LEFT JOIN MAX_VBEP VBEP
        ON  VBEP.VBELN  = VBAP.VBELN
        AND VBEP.POSNR  = VBAP.POSNR
    LEFT JOIN VBPA_INFO
        ON  SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER = VBAP.VBELN
    LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU020_KNA1') }} KNA1
        ON  VBPA_INFO.CUSTOMER_NUMBER = KNA1.KUNNR
    LEFT JOIN BP_INFO
        ON  BP_INFO.SALES_AND_DISTRIBUTION_DOCUMENT_NUMBER = VBAP.VBELN
    LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU020_KNA1') }} KNA2
        ON  BP_INFO.CUSTOMER_NUMBER = KNA2.KUNNR
    JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU017_MARA') }} MARA
        ON  MARA.MATNR = VBAP.MATNR
    JOIN MARC
        ON  MARC.MATNR = MARA.MATNR
    JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU019_MVKE') }} MVKE
        ON  MARA.MATNR = MVKE.MATNR

    -- FIX: two-leg join
    --   Leg 1: standard point-in-time match (order date falls in a snapshot window)
    --   Leg 2: fallback — order predates the first snapshot, use the earliest snapshot row
    LEFT JOIN LT_HISTORY LT
        ON  VBAP.MATNR                              = LT.MATNR
        AND LT.WERKS                                = '3200'
        AND (
            (   TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD') >= LT.SNAPSHOT_DATE
            AND TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD') <  COALESCE(LT.NEXT_SNAPSHOT_DATE, CURRENT_DATE)
            )
            OR
            (   TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD') <  LT.EARLIEST_SNAPSHOT_DATE
            AND LT.SNAPSHOT_DATE                    =  LT.EARLIEST_SNAPSHOT_DATE
            )
        )
),

TRANSFORM_DATA AS (
    SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        ORDER_REASON,
        ORDER_TYPE,
        SALES_DOC_TYPE,
        ORDER_PRIORITY_CODE,
        ORDER_PRIORITY_NAME,
        SO_LINE,
        VBELN,
        POSNR,
        NCDR_NUMBER,
        LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT,
        LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM,
        LGORT,
        MATNR,
        ABC_LOCAL,
        ABC_SPECIAL_CUSTOMER,
        ABC_NARITA,
        INTEL_FLAG,
        SOLD_TO_PARTY,
        SOLD_TO_PARTY_NAME,
        BILL_TO_PARTY,
        BILL_TO_PARTY_NAME,
        ORDER_DATE,
        REQUESTED_DELIVERY_DATE,
        COMMIT_DATE,
        DELIVERY_DATE,
        LIKP_DOCUMENT_DATE,
        ODT_CRDT,
        DDT_CRDT,
        CONFIRMED_QTY,
        DELIVERED_QTY,
        CAT,
        EMG,
        CMT,
        CR,
        EXT,
        COUNT,
        INTEL,
        SAVAIL,
        BU,
        MATERIAL_GROUP_2,
        CONS,
        ODT_MONTH,
        STD_LT_DAYS,
        LT_SOURCE,
        LT_TARGET_DATE,
        OTD_VS_STD_LT
    FROM SOURCE_DATA
),

TYPE_DATA AS (
    SELECT
        CAST(_AUDIT_LOG_ID           AS VARCHAR(128))        AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH              AS VARCHAR(128))         AS _ROW_HASH,
        CAST(ORDER_REASON           AS VARCHAR(16777216))   AS ORDER_REASON,
        CAST(ORDER_TYPE             AS VARCHAR(16777216))   AS ORDER_TYPE,
        CAST(SALES_DOC_TYPE         AS VARCHAR(16777216))   AS SALES_DOC_TYPE,
        CAST(ORDER_PRIORITY_CODE    AS VARCHAR(16777216))   AS ORDER_PRIORITY_CODE,
        CAST(ORDER_PRIORITY_NAME    AS VARCHAR(16777216))   AS ORDER_PRIORITY_NAME,
        CAST(SO_LINE                AS VARCHAR(16777216))   AS SO_LINE,
        CAST(VBELN                  AS VARCHAR(16777216))   AS VBELN,
        CAST(POSNR                  AS VARCHAR(16777216))   AS POSNR,
        CAST(NCDR_NUMBER            AS VARCHAR(16777216))   AS NCDR_NUMBER,
        CAST(LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT AS VARCHAR(16777216))
                                                            AS LIPS_DOCUMENT_NUMBER_OF_THE_REFERENCE_DOCUMENT,
        CAST(LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM AS VARCHAR(16777216))
                                                            AS LIPS_ITEM_NUMBER_OF_THE_REFERENCE_ITEM,
        CAST(LGORT                  AS VARCHAR(16777216))   AS LGORT,
        CAST(MATNR                  AS VARCHAR(16777216))   AS MATNR,
        CAST(ABC_LOCAL              AS VARCHAR(16777216))   AS ABC_LOCAL,
        CAST(ABC_SPECIAL_CUSTOMER   AS VARCHAR(16777216))   AS ABC_SPECIAL_CUSTOMER,
        CAST(ABC_NARITA             AS VARCHAR(16777216))   AS ABC_NARITA,
        CAST(INTEL_FLAG             AS VARCHAR(16777216))   AS INTEL_FLAG,
        CAST(SOLD_TO_PARTY          AS VARCHAR(16777216))   AS SOLD_TO_PARTY,
        CAST(SOLD_TO_PARTY_NAME     AS VARCHAR(16777216))   AS SOLD_TO_PARTY_NAME,
        CAST(BILL_TO_PARTY          AS VARCHAR(16777216))   AS BILL_TO_PARTY,
        CAST(BILL_TO_PARTY_NAME     AS VARCHAR(16777216))   AS BILL_TO_PARTY_NAME,
        TRY_TO_DATE(ORDER_DATE,             'YYYYMMDD')     AS ORDER_DATE,
        TRY_TO_DATE(REQUESTED_DELIVERY_DATE,'YYYYMMDD')     AS REQUESTED_DELIVERY_DATE,
        TRY_TO_DATE(COMMIT_DATE,            'YYYYMMDD')     AS COMMIT_DATE,
        TRY_TO_DATE(DELIVERY_DATE,          'YYYYMMDD')     AS DELIVERY_DATE,
        TRY_TO_DATE(LIKP_DOCUMENT_DATE,     'YYYYMMDD')     AS LIKP_DOCUMENT_DATE,
        CAST(ODT_CRDT               AS BOOLEAN)             AS ODT_CRDT,
        CAST(DDT_CRDT               AS BOOLEAN)             AS DDT_CRDT,
        CAST(CONFIRMED_QTY          AS NUMBER(38,0))        AS CONFIRMED_QTY,
        CAST(DELIVERED_QTY          AS NUMBER(38,0))        AS DELIVERED_QTY,
        CAST(CAT                    AS VARCHAR(16777216))   AS CAT,
        CAST(EMG                    AS VARCHAR(16777216))   AS EMG,
        CAST(CMT                    AS NUMBER(38,0))        AS CMT,
        CAST(CR                     AS NUMBER(38,0))        AS CR,
        CAST(EXT                    AS VARCHAR(16777216))   AS EXT,
        CAST(COUNT                  AS NUMBER(38,0))        AS COUNT,
        CAST(INTEL                  AS VARCHAR(16777216))   AS INTEL,
        CAST(SAVAIL                 AS NUMBER(38,0))        AS SAVAIL,
        CAST(BU                     AS VARCHAR(16777216))   AS BU,
        CAST(MATERIAL_GROUP_2       AS VARCHAR(16777216))   AS MATERIAL_GROUP_2,
        CAST(CONS                   AS VARCHAR(16777216))   AS CONS,
        CAST(ODT_MONTH              AS VARCHAR(16777216))   AS ODT_MONTH,
        CAST(STD_LT_DAYS            AS NUMBER(38,0))        AS STD_LT_DAYS,
        CAST(LT_SOURCE              AS VARCHAR(32))         AS LT_SOURCE,
        CAST(LT_TARGET_DATE         AS DATE)                AS LT_TARGET_DATE,
        CAST(OTD_VS_STD_LT          AS NUMBER(38,0))        AS OTD_VS_STD_LT
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA