{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias='VENDOR_SPEND_REPORT_PO',
        transient=false,
    
) }}

-- Usage: Get PO spend (and linked invoice amount) sums by vendor
-- and month.

WITH
-- CTE: INVOICE_AGG
-- Sum invoice amount by the linked PO
INVOICE_AGG AS (
    SELECT
        -- PO ID 
        RSEG.EBELN,
        -- PO Header 
        RSEG.EBELP, 
        -- Invoice amount in document currency
        SUM(RSEG.WRBTR) AS INVOICE_AMT,
        -- currency of invoice amount
        RBKP.WAERS as CURRENCY
    -- RSEG is the invoice line item table.
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU197_RSEG') }} AS RSEG
    JOIN {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU237_RBKP') }} AS RBKP ON (RBKP.BELNR = RSEG.BELNR)
    GROUP BY RSEG.EBELN, RSEG.EBELP, RBKP.WAERS
),
-- CTE: POS
-- Get invidual POs and their corresponding linked invoice amount
-- by joining to the INVOICE_AGG CTE
POS AS (
    SELECT
        -- PO ID
        EKKO.EBELN,
        -- PO Header
        EKPO.EBELP,
        EKKO.LIFNR AS VENDOR_ID,
        LFA1.NAME1 AS VENDOR_NAME,
        LEFT(EKKO.AEDAT, 4) AS YR,
        SUBSTRING(EKKO.AEDAT, 5, 2) AS MO,
        CAL.FISCAL_YEAR_number - 1 AS FISCAL_YEAR, --adding fiscal year, period and currency as requested by Mary 5/29/2025
        CAL.MONTH_OF_FISCAL_YEAR_NUMBER AS FISCAL_PERIOD,
        EKPO.NETWR,
        EKPO.BRTWR,
        -- if no currency from the RSEG invoice then check the ekko purchasing doc header currency
        COALESCE(INVOICE_AGG.CURRENCY, EKKO.WAERS) AS CURRENCY,
        COALESCE(INVOICE_AGG.INVOICE_AMT, 0) AS INVOICED_AMT
    FROM {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU027_EKKO') }} AS EKKO
    JOIN {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU028_EKPO') }} AS EKPO ON (EKKO.EBELN = EKPO.EBELN)
    JOIN {{ ref('BRONZE__TEH_PROCUREMENT__SAPAPI_ZCDV_T_CMTU061_LFA1') }} AS LFA1 ON (EKKO.LIFNR = LFA1.LIFNR)
    LEFT JOIN INVOICE_AGG ON (INVOICE_AGG.EBELN = EKPO.EBELN AND INVOICE_AGG.EBELP = EKPO.EBELP)
    JOIN COMMON.DE_SAP_MASTER_DATA.CALENDAR_DATE CAL ON TO_DATE(EKKO.AEDAT,'YYYYMMDD') = CAL.CALENDAR_DATE
),
SOURCE_DATA AS (
    SELECT
        VENDOR_ID, 
        VENDOR_NAME, 
        YR, 
        MO,
        FISCAL_YEAR,
        FISCAL_PERIOD,
        CURRENCY,
        SUM(NETWR) AS TTL_NET_PO_AMT, 
        SUM(BRTWR) AS TTL_GROSS_PO_AMT,
        SUM(INVOICED_AMT) AS TTL_TIED_INVOICED_AMT
    FROM POS
    GROUP BY VENDOR_ID, VENDOR_NAME, YR, MO, FISCAL_YEAR, FISCAL_PERIOD, CURRENCY
),
TRANSFORM_DATA AS (
    SELECT
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        VENDOR_ID,
        VENDOR_NAME,
        YR,
        MO,
        FISCAL_YEAR,
        FISCAL_PERIOD,
        CURRENCY,
        TTL_NET_PO_AMT,
        TTL_GROSS_PO_AMT,
        TTL_TIED_INVOICED_AMT
    FROM SOURCE_DATA
),
TYPE_DATA AS (
    SELECT
        _AUDIT_LOG_ID AS _AUDIT_LOG_ID,
        _ROW_HASH AS _ROW_HASH,
        VENDOR_ID AS VENDOR_ID,
        VENDOR_NAME AS VENDOR_NAME,
        YR AS YR,
        MO AS MO,
        FISCAL_YEAR AS FISCAL_YEAR,
        FISCAL_PERIOD AS FISCAL_PERIOD,
        CURRENCY AS CURRENCY,
        CAST(TTL_NET_PO_AMT AS FLOAT) AS TTL_NET_PO_AMT,
        CAST(TTL_GROSS_PO_AMT AS FLOAT) AS TTL_GROSS_PO_AMT,
        CAST(TTL_TIED_INVOICED_AMT AS FLOAT) AS TTL_TIED_INVOICED_AMT
    FROM TRANSFORM_DATA
)
SELECT * FROM TYPE_DATA