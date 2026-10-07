{{ config(
    alias = 'NCDR_SAPH',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
    transient = false
) }}

WITH DELIV AS (
    SELECT
        LIPS.VGBEL AS REF_DOC,
        LIPS.VGPOS AS REF_DOC_POSNR,
        MAX(LIKP.WADAT) AS GOODS_ISSUE_DATE,
        CASE
            WHEN MIN(LIKP.VBELN) = MAX(LIKP.VBELN) THEN MAX(LIKP.VBELN)
            ELSE 'Multiple DOs for SO line'
        END AS DO_HDR,
        CASE
            WHEN MAX(LIPS.POSNR) = MIN(LIPS.POSNR)
            AND MIN(LIKP.VBELN) = MAX(LIKP.VBELN) THEN MAX(LIPS.POSNR)
            ELSE 'Multiple DO Lines for SO line'
        END AS DO_LINE,
        MIN(NULLIF(LIKP.WADATIST, '00000000')) AS FIRST_GOODS_MOVEMENT_DATE,
        MAX(NULLIF(LIKP.WADATIST, '00000000')) AS LAST_GOODS_MOVEMENT_DATE,
        SUM(LIPS.LFIMG) AS DELIVERED_QTY,
        COUNT(*) AS DELIVERY_LINE_COUNT,
        COUNT(DISTINCT(LIPS.VGBEL)) AS DELIVERY_HDR_COUNT,
        MAX(LIKP.UVWAK) AS PGI_STATUS,
        MIN(LIPS.GBSTA) AS DELIVERY_PROCESSING_STATUS,
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU013_LIPS') }} AS LIPS
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU012_LIKP') }} AS LIKP ON (LIPS.VBELN = LIKP.VBELN)
    GROUP BY
        LIPS.VGBEL,
        LIPS.VGPOS
),
MATERIAL_BATCH_SAP_ZS12_SO_LINE_AGG AS (
    SELECT
        VBAP.MATNR,
        VBAP.CHARG,
        MIN(TRY_TO_DATE(VBAP.ERDAT, 'YYYYMMDD')) AS MIN_ZS12_SO_DATE,
        COUNT(*) AS ZS12_SO_LINE_CNT_IN_BATCH,
        SUM(VBAP.KWMENG) AS TTL_ZS12_SO_QTY_IN_BATCH
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} AS VBAP
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} AS VBAK ON (VBAK.VBELN = VBAP.VBELN)
    WHERE
        VBAK.AUART = 'ZS12'
    GROUP BY
        VBAP.MATNR,
        VBAP.CHARG
),
-- Aggregate total outgoing STOCK_QTY for material / batch combinations
MATERIAL_BATCH_ZS12_OUTFLOWS AS (
    SELECT
        MATDOC.CHARG,
        MATDOC.MATNR,
        -- AUFK.KDAUF is the SO line header tied to the MATDOC record.
        -- Note: We can't get the SO line # tied to a MATDOC record.
        --  Only the SO header
        AUFK.KDAUF,
        MAX(AGG.TTL_ZS12_SO_QTY_IN_BATCH) AS TTL_ZS12_SO_QTY_IN_BATCH,
        MAX(AGG.ZS12_SO_LINE_CNT_IN_BATCH) AS ZS12_SO_LINE_CNT_IN_BATCH,
        SUM(MATDOC.STOCK_QTY) AS TTL_OUTGOING_ZS12_QTY_IN_BATCH,
        MIN(TRY_TO_DATE(MATDOC.BUDAT, 'YYYYMMDD')) AS FIRST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        MAX(TRY_TO_DATE(MATDOC.BUDAT, 'YYYYMMDD')) AS LATEST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU025_MATDOC') }} AS MATDOC
        INNER JOIN MATERIAL_BATCH_SAP_ZS12_SO_LINE_AGG AS AGG ON (
            AGG.CHARG = MATDOC.CHARG
            AND AGG.MATNR = MATDOC.MATNR
            AND -- Only pull in ZS12 records prior to that occur prior to the MATDOC
            -- posting date.
            -- MATDOC rows that post prior to a ZS12 order cannot be an outflow
            -- for that ZS12 order.
            AGG.MIN_ZS12_SO_DATE <= TRY_TO_DATE(MATDOC.BUDAT, 'YYYYMMDD')
        )
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU090_AUFK') }} AS AUFK ON (AUFK.AUFNR = MATDOC.AUFNR)
    WHERE
        -- 261 is an outgoing movement type
        MATDOC.BWART = '261'
        AND -- W flags special stock
        MATDOC.SOBKZ = 'W'
        AND MATDOC.CONSUMPTION_QTY > 0
    GROUP BY
        MATDOC.CHARG,
        MATDOC.MATNR,
        AUFK.KDAUF
),
BILL AS (
    SELECT
        -- AUBEL = SO HEADER
        -- AUPOS = SO LINE
        VBRP.AUBEL,
        VBRP.AUPOS,
        -- SO Line -> Bill Line is one to many.
        -- Only list the BILL HEADER when it's one to one.
        CASE
            WHEN MAX(VBRP.VBELN) = MIN(VBRP.VBELN) THEN MAX(VBRP.VBELN)
            ELSE LISTAGG(VBRP.VBELN, '|')
        END AS BILL_HDR,
        SUM(VBRP.FKIMG) AS QTY,
        SUM(VBRP.WAVWR) AS COST_IN_DOC_CURRENCY,
        SUM(VBRP.KZWI1) AS SUBTOTAL_1,
        SUM(VBRP.KZWI2) AS SUBTOTAL_2
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU014_VBRK') }} AS VBRK
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU015_VBRP') }} AS VBRP ON (VBRP.VBELN = VBRK.VBELN)
    GROUP BY
        VBRP.AUBEL,
        VBRP.AUPOS
),
-- ZSR0 Returns arise from ZS14 SOs
ZSR0_RETURNS AS (
    SELECT
        VBAK.VBELN,
        VBAP.POSNR,
        VBAK.ZZSCWN,
        VBAP.MATNR,
        VBAK.ERDAT,
        VBAP.KWMENG AS ZSR0_QTY
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} AS VBAK
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} AS VBAP ON (VBAP.VBELN = VBAK.VBELN)
    WHERE
        VBAK.AUART = 'ZSR0'
),
-- Some ZSR0 and ZS12 records do not get assigned an NCDR #, but do get assigned
-- a CRM #. When we can link the CRM # to an unambigous NCDR #, use it.
BACKUP_NCDR_LKUP_CRM AS (
    SELECT
        VBAK.ZZSCWN,
        VBAP.MATNR,
        MAX(NULLIF(ZZNNZZ, '')) AS NCDR_NUMBER,
        COUNT(DISTINCT(NULLIF(ZZNNZZ, ''))) AS DISTINCT_NCDR_NUMBERS,
        COUNT(*) AS NROWS,
        SUM(
            CASE
                WHEN NULLIF(ZZNNZZ, '') IS NULL THEN 0
                ELSE 1
            END
        ) AS ROWS_WITH_NCDR_NUM
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} AS VBAP
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} AS VBAK ON (VBAK.VBELN = VBAP.VBELN)
    WHERE
        NULLIF(ZZSCWN, '') IS NOT NULL
    GROUP BY
        VBAK.ZZSCWN,
        VBAP.MATNR
    HAVING
        DISTINCT_NCDR_NUMBERS = 1
        AND NROWS > ROWS_WITH_NCDR_NUM
),
CUSTOMER AS (
    SELECT
        BUSINESS_PARTNER_NUMBER,
        CUSTOMER_GROUP,
        CUSTOMER_GROUP2,
        SEARCH_TERM_2,
        US_STATE
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__SAP_CUSTOMER') }}
),
MATERIALMASTER AS (
    SELECT
        MATERIAL_NUMBER,
        CLASSIFICATION_TEXT AS PART_CLASSIFICATION
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__MASTER_MATERIAL_REPORT') }} QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY MATERIAL_NUMBER
                ORDER BY
                    CLASSIFICATION_TEXT DESC
            ) = 1
        )
),
SHIPTO AS (
    select
        vbpa.VBELN as SALES_DOC,
        vbpa.KUNNR as SHIP_TO_PARTY,
        customer.CORPORATION_NAME as SHIP_TO_CUSTOMER,
        customer.SEARCH_TERM_2 as SHIP_TO_CUSTOMER_LOCATION,
        customer.US_STATE as SHIP_TO_STATE,
    from
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU047_VBPA') }} as vbpa
        left join {{ ref('SILVER__TEA_SALES_REVENUE__SAP_CUSTOMER') }} as customer on vbpa.KUNNR = customer.BUSINESS_PARTNER_NUMBER
    where
        vbpa.POSNR = '000000'
        and vbpa.PARVW = 'SH'
),
BUGROUP AS (
    SELECT
        BU_SOURCE_KEY,
        BU_GROUP,
        BU_GROUP_LEADER
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__FILE_SERVICE_BUSINESS_UNIT_MAPPING') }} QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY BU_SOURCE_KEY
                ORDER BY
                    BU_GROUP DESC
            ) = 1
        )
),
SALESCAT AS (
    SELECT
        SAP_SALES_CATEGORY AS MD_SALES_CAT,
        BAAN_PRODUCT_TYPE AS NOW_PRODUCT_TYPE
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__SAP_SALES_CATEGORY') }} QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY SAP_SALES_CATEGORY
                ORDER BY
                    BAAN_PRODUCT_TYPE DESC
            ) = 1
        )
),
MACHINE AS (
    SELECT
        SERIAL_NUMBER,
        CUSTOMER_TOOL_ID AS CURRENT_TOOL_ID,
        COALESCE(LOCATION_NAME, CUSTOMER_NAME) AS CURRENT_SN_LOCATION,
        TEL_REGION AS CURRENT_SN_REGION,
        MACHINE_HISTORY_REASON AS CURRENT_SN_HISTORY_STATUS,
        PARENT_SN,
        SECONDARY_SERVICE_CONTACT AS CURRENT_SERVICE_CONTACT
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__GLOBAL_MACHINES') }} QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY SERIAL_NUMBER
                ORDER BY
                    BU_GROUP DESC
            ) = 1
        )
),
SOLINE as (
    select
        VBAP_SALES_DOCUMENT || '_' || SALES_DOCUMENT_ITEM_POSNR AS SAP_SALES_ORDER_LINE,
        sol.ncdr_number,
        storage_location AS STORAGE_CODE,
        STORAGE_NAME,
        pc.segment,
        segment_code
    from
        {{ ref('SILVER__TEA_SALES_REVENUE__SALES_ORDER') }} sol
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__FILE_PROFIT_CENTER') }} pc on SOL.VBAP_PROFIT_CENTER = pc.PROFIT_CENTER_CODE
        LEFT OUTER JOIN (
            select
                WERKS as plant,
                LGORT,
                LGOBE as STORAGE_NAME
            from
                {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU080_T001L') }}
        ) ON LGORT = STORAGE_LOCATION
    where
        SALES_DOCUMENT_TYPE = 'ZS14' QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY SAP_SALES_ORDER_LINE
                ORDER BY
                    STORAGE_CODE DESC
            ) = 1
        )
),
EMPLOYEE AS (
    SELECT
        EMPLOYEEID,
        FULLNAME,
        SUPERVISOR_NAME,
        STATUS_CODE,
        SUPERVISORID,
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__EMPLOYEE') }}
),
NOW_SN AS (
    SELECT
        NCDR15 AS FULLNCDR,
        LISTAGG(DISTINCT MAC_SN_WITHOUT_BU, ', ') AS SN_NOW
    FROM
        {{ ref('SILVER__TEA_SALES_REVENUE__NOWDATA') }}
    GROUP BY
        NCDR15
),
-- NCDR "header" level info
NOWNCDR AS (
    SELECT
        NOWDATA.NCDR15,
        CASE
            WHEN LEFT(NOWDATA.ROES_ORDER_NUMBER, 1) = '0' THEN LEFT(RIGHT(NOWDATA.ROES_ORDER_NUMBER, 9), 3)
            ELSE LEFT(NOWDATA.ROES_ORDER_NUMBER, 3)
        END AS NOW_REF_ORDER_SERIES,
        NOWDATA.ROES_ORDER_NUMBER AS NOW_REF_ORDER,
        NOWDATA.ORIGINATOR_EMP_NO,
        EMPLOYEE.FULLNAME AS REQUESTOR_NAME,
        EMPLOYEE.SUPERVISOR_NAME AS REQUESTOR_SUPERVISOR,
        CAST(NOWDATA.WORK_FLOW_STARTED_DATE AS DATE) AS NOW_WORKFLOW_START,
        CALENDAR_DATE.FISCAL_YEAR_SHORT_TEXT AS NOW_WORKFLOW_START_FY,
        CASE
            WHEN EMPLOYEE.STATUS_CODE = 'T' THEN '*Left Company'
            WHEN EMPLOYEE.STATUS_CODE = 'A' THEN 'Active'
            WHEN EMPLOYEE.STATUS_CODE = 'L' THEN 'On Leave'
            ELSE 'Unknown'
        END AS REQUESTOR_STATUS,
        NOWDATA.REGIONAL_APPROVER as REGIONAL_APPROVER_NAME,
        NOWDATA.REGIONALLY_APPROVED_DATE as REGIONALLY_APPROVED_DATE,
        CASE 
            WHEN (trim(NOWDATA.GLOBAL_APPROVER) ='' OR NOWDATA.GLOBAL_APPROVER IS NULL) THEN 'No' 
            ELSE 'Yes' 
        END as GLOBAL_APPROVAL,
        NOWDATA.GLOBAL_APPROVER as GLOBAL_APPROVER,
        NOWDATA.GLOBALLY_APPROVED_DATE,
        NOWDATA.APPROVED as APPROVED,
        NOW_SN.SN_NOW,
        NOWDATA.CANCELLED AS NOW_CANCELLED_FLAG,
        NOWDATA.CUSTOMER AS NOW_CUSTOMER,
        NOWDATA.CUSTOMER_LOCATION AS NOW_CUSTOMER_LOCATION,
        NOWDATA.REASON,
        CASE
            WHEN NOWDATA.DENY_DATE IS NOT NULL THEN 'Yes'
            ELSE 'No'
        END AS NOW_DENY_FLAG,
        NOWDATA.DENY_DATE,
        NOWDATA.DENY_EMP_NO,
        NOWDATA.DENIED_BY,
        EMPLOYEE.SUPERVISORID as SUPERVISOR_ID,
    FROM {{ ref('SILVER__TEA_SALES_REVENUE__NOWDATA') }}
    LEFT OUTER JOIN EMPLOYEE ON EMPLOYEE.EMPLOYEEID = NOWDATA.REQUESTOR_EMP_NO
    LEFT OUTER JOIN {{ source('STATIC_OBJECTS', 'CALENDAR_DATE') }} ON CAST(NOWDATA.WORK_FLOW_STARTED_DATE AS DATE) = CALENDAR_DATE.CALENDAR_DATE
    LEFT OUTER JOIN NOW_SN ON NOW_SN.FULLNCDR = NOWDATA.NCDR15 
    QUALIFY ROW_NUMBER() OVER (PARTITION BY NOWDATA.NCDR15 ORDER BY NOWDATA.LINE_NUMBER DESC) = 1
),
WO_ODS AS (
    SELECT
        LPAD(MSDYN_NAME, 8, '0') AS WORK_ORDER,
        WO_WOTITLE AS WO_TITLE,
        UPPER(MSDYN_WORKORDERID) AS WO_ID,
        UPPER(CREATEDBY) AS WO_CREATEDBY,
        CREATEDBYNAME
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__CRM_FILE_MSDYN_WORKORDER') }}
    WHERE
        1 = 1
        AND WO_REGIONNAME = 'US'
        AND LEFT(MSDYN_NAME, 8) <> 'Template'
),
USER AS (
    SELECT
        UPPER(ID) AS ID,
        FIRSTNAME,
        LASTNAME,
(LASTNAME || ', ' || FIRSTNAME) AS WO_CREATOR,
        LPAD(EMPLOYEEID, 6, '0') AS WO_CREATOR_ID
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__CRM_FILE_SYSTEMUSER') }}
),
WO AS (
    SELECT
        WO_ODS.WORK_ORDER,
        WO_ODS.WO_TITLE,
        COALESCE(USER.WO_CREATOR, WO_ODS.CREATEDBYNAME) AS WO_CREATOR,
        WO_ODS.WO_ID
    FROM
        WO_ODS
        LEFT OUTER JOIN USER ON WO_ODS.WO_CREATEDBY = USER.ID QUALIFY (
            ROW_NUMBER() OVER (
                PARTITION BY WO_ODS.WORK_ORDER
                ORDER BY
                    WO_CREATOR DESC
            ) = 1
        )
),
shipping_address_partner as (
    select
        vbpa.VBELN,
        adrc.STREET || ', ' || adrc.CITY1 || ', ' || adrc.REGION || ' ' || adrc.POSTCODE1 || ', ' || adrc.COUNTRY as SHIPPING_ADDRESS,
    from
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU047_VBPA') }} as vbpa
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU087_ADRC') }} as adrc on vbpa.ADRNR = adrc.ADDRNUMBER
        and adrc.NATION = ''
    where
        vbpa.POSNR = '000000'
        and vbpa.PARVW = 'Z3' qualify row_number() over(
            partition by adrc.ADDRNUMBER
            order by
                adrc.DATEFROM desc
        ) = 1
),
-- 9/3 changes to base returns/consumption on MATDOC (MSEG)
aufk_ncdrs as (
    select
        aufk.AUFNR,
        array_agg(distinct vbap.ZZNNZZ) as NCDR_ARRAY,
    from
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU090_AUFK') }} as aufk
        inner join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} as vbak on vbak.VBELN = aufk.KDAUF
        inner join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} as vbap on vbap.VBELN = aufk.KDAUF
        and vbap.ZZNNZZ > ''
    group by
        all
),
vbfa_dos as (
    select
        distinct VBELV as SO_DOC,
        POSNV as SO_ITEM,
        VBELN as DO_DOC,
    from
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU064_VBFA') }}
    where
        VBTYP_N = 'J'
    group by
        all
),
material_docs as (
    select
        vbap.VBELN,
        vbap.POSNR,
        vbak.AUART,
        vbfa_mats.VBELN as MBLNR_PRIME,
        vbfa_mats.POSNN as MJAHR_PRIME,
        vbfa_mats.MJAHR as ZEILE_PRIME,
        expanded_matdoc.MBLNR,
        expanded_matdoc.MATNR,
        expanded_matdoc.UMCHA,
        expanded_matdoc.CHARG,
        expanded_matdoc.BWART,
        expanded_matdoc.MENGE,
        expanded_matdoc.XBLNR,
        expanded_matdoc.AUFNR,
        ifnull(try_to_number(expanded_matdoc.XBLNR) = try_to_number(vbfa_dos.DO_DOC), FALSE) as ON_LOAN_FLAG, -- BWART = 631 applied in join
        aufk_ncdrs.AUFNR is not null as CONSUMPTION_FLAG, -- BWART = 261 applied in join
        expanded_matdoc.BWART = '632' as RETURN_FLAG,
        expanded_matdoc.BWART = '262' as CONSUMPTION_REVERSAL_FLAG,
    from {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} as vbap
    inner join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} as vbak 
        on try_to_number(vbak.VBELN) = try_to_number(vbap.VBELN)
    left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU064_VBFA') }} as vbfa_mats 
        on try_to_number(vbap.VBELN) = try_to_number(vbfa_mats.VBELV)
        and try_to_number(vbap.POSNR) = try_to_number(vbfa_mats.POSNV)
        and vbfa_mats.VBTYP_N = 'R'
    left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU025_MATDOC') }} as base_matdoc 
        on try_to_number(vbfa_mats.VBELN) = try_to_number(base_matdoc.MBLNR)
        and try_to_number(vbfa_mats.POSNN) = try_to_number(base_matdoc.ZEILE)
        and try_to_number(vbfa_mats.MJAHR) = try_to_number(base_matdoc.MJAHR)
    left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU025_MATDOC') }} as expanded_matdoc 
        on base_matdoc.MATNR = expanded_matdoc.MATNR
        and ltrim(coalesce(nullif(base_matdoc.UMCHA, ''), base_matdoc.CHARG), '0') = ltrim(coalesce(nullif(expanded_matdoc.UMCHA, ''), expanded_matdoc.CHARG), '0')
        and base_matdoc.KUNNR = expanded_matdoc.KUNNR
        and expanded_matdoc.SOBKZ = 'W'
    left join vbfa_dos -- used to check for ON_LOAN_FLAG
        on expanded_matdoc.BWART = '631'
        and try_to_number(vbap.VBELN) = try_to_number(vbfa_dos.SO_DOC)
        and try_to_number(vbap.POSNR) = try_to_number(vbfa_dos.SO_ITEM)
    left join aufk_ncdrs -- used to check for CONSUMPTION_FLAG
        on expanded_matdoc.BWART = '261'
        and expanded_matdoc.AUFNR = aufk_ncdrs.AUFNR
        and array_contains(vbap.ZZNNZZ :: VARIANT, NCDR_ARRAY)
),
goods_quantities as (
    select
        VBELN,
        POSNR,
        sum(
            case
                when ON_LOAN_FLAG then MENGE
                else 0
            end
        ) as GOODS_ON_LOAN_QTY,
        sum(
            case
                when CONSUMPTION_FLAG then MENGE
                else 0
            end
        ) as GOODS_CONSUMED_QTY_temp,
        sum(
            case
                when RETURN_FLAG then MENGE
                else 0
            end
        ) as GOODS_RETURN_QTY,
        sum(
            case
                when CONSUMPTION_REVERSAL_FLAG then MENGE
                else 0
            end
        ) as GOODS_CONSUMED_REVERSE_QTY,
        -- GOODS_CONSUMED_QTY_temp - GOODS_CONSUMED_REVERSE_QTY as GOODS_CONSUMED_QTY,
        GOODS_CONSUMED_QTY_temp - 0 as GOODS_CONSUMED_QTY, -- ignoring GOODS_CONSUMED_REVERSE_QTY until its logic can be better defined
        GOODS_ON_LOAN_QTY - GOODS_RETURN_QTY - GOODS_CONSUMED_QTY as GOODS_REMAINING_QTY,
    from
        material_docs
    group by
        all
),

SOURCE_DATA AS (
    SELECT
        VBAP.VBELN,
        VBAP.POSNR,
        VBAK.AUART AS SALES_DOC_TYPE,
        VBAK.ERDAT,
        VBAK.AUDAT,
        -- Material Information
        VBAP.MATNR AS MATERIAL_NUMBER,
        MARA.MAKTX AS MATERIAL_DESC,
        MARA.MATKL AS MATERIAL_GROUP,
        MARA.MEINS AS MATERIAL_BASE_UNIT_OF_MEASURE,
        MARA.NTGEW AS MATERIAL_NET_WEIGHT,
        MARA.BRGEW AS MATERIAL_GROSS_WEIGHT,
        MARA.GEWEI AS MATERIAL_WEIGHT_UNIT,
        COALESCE(
            -- Use the NCDR # field if it is not NULL
            NULLIF(VBAP.ZZNNZZ, ''),
            -- If the NCDR # field is NULL, attempt to extract and NCDR #
            -- from the comment field
            REGEXP_SUBSTR(VBAP.ZZCCOME, '(CS|ES|DS|SD)\\-TEA\\d+'),
            -- If all else fails, attempt to extract from CRM
            BACKUP_NCDR_LKUP_CRM.NCDR_NUMBER
        ) AS COALESCED_NCDR_NUMBER,
        COALESCED_NCDR_NUMBER || '_' || VBAP.MATNR AS NCDR_PART_PAIR_KEY,
        CASE
            WHEN NULLIF(VBAP.ZZNNZZ, '') IS NULL
            AND REGEXP_SUBSTR(VBAP.ZZCCOME, '(CS|ES|DS|SD)\\-TEA\\d+') IS NULL
            AND BACKUP_NCDR_LKUP_CRM.NCDR_NUMBER IS NOT NULL THEN 1
            ELSE 0
        END AS NCDR_NUMBER_INFERRED_FROM_CRM_NUMBER,
        VBAP.KWMENG AS QTY,
        VBAP.ZMENG AS TGT_QTY,
        VBAP.ERNAM AS LINE_CREATED_BY,
        VBAK.IHREZ AS BAAN_SO_REFERENCE,
        VBAK.ZZSCWN AS SERVICE_CRM_WO_NUMBER,
        VBAP.ZZTSNZ AS SAP_TOOL_SERIAL,
        VBAK.AUGRU AS ORDER_REASON,
        VBAP.NETWR AS NET_VALUE_OF_LINE_ITEM,
        MBEW.STPRS AS UNIT_STD_PRICE,
        MBEW.STPRS * VBAP.KWMENG AS LINE_ITEM_STD_PRICE,
        MBEW.STPRS * VBAP.KWMENG * 1.09 AS BILL_TO_TEL_AMT,
        VBAP.WAVWR AS COST_IN_DOCUMENT_CURRENCY,
        VBAP.KZWI1 AS SUBTOTAL1,
        VBAK.KUNNR AS SOLD_TO_PARTY_CODE,
        KNA1.NAME1 AS SOLD_TO_PARTY,
        CG.CUSTOMER_GROUP,
        VBAP.PRCTR AS PROFIT_CENTER,
        VBAK.VKBUR AS SALES_OFFICE,
        VBAK.BSTNK AS CUSTOMER_REFERENCE,
        PRPS.POSKI AS WBS_ELEMENT,
        VBAP.ZZORTY AS SALES_CATEGORY,
        SCAT.SAP_SALES_CATEGORY_NAME AS SALES_CATEGORY_NAME,
        VBAP.FAKSP AS BILLING_BLOCK_FOR_ITEM,
        NOWNCDR.REASON as NOW_REASON,
        NOWNCDR.GLOBALLY_APPROVED_DATE,
        NCDR.REQUESTOR,
        NCDR.ORIGINATOR,
        DELIV.PGI_STATUS,
        DELIV.DELIVERED_QTY,
        DELIV.DO_HDR,
        DELIV.DO_LINE,
        DELIV.FIRST_GOODS_MOVEMENT_DATE,
        DELIV.LAST_GOODS_MOVEMENT_DATE,
        DELIV.GOODS_ISSUE_DATE,
        BILL.QTY AS BILLED_QTY,
        BILL.BILL_HDR,
        BILL.AUBEL,
        VBAP.ZZCCOME,
        -- ZS12 line count and quantity only applies to ZS12
        -- lines that can match to a MATDOC record created
        -- after the original ZS12 order
        OUTFLOW.ZS12_SO_LINE_CNT_IN_BATCH,
        OUTFLOW.TTL_ZS12_SO_QTY_IN_BATCH,
        OUTFLOW.TTL_OUTGOING_ZS12_QTY_IN_BATCH,
        OUTFLOW.FIRST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        OUTFLOW.LATEST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        VBAP.CHARG AS SAP_BATCH,
        -- 5/15: new columns coming from COMMON.SAPH.NCDR consolidation
        tvakt.BEZEI as SALES_DOC_TYPE_DESC,
        NCDR.CRM_WORK_ORDER_NO as CRM_WORK_ORDER_NO,
        NCDR.NOW_WORK_ORDER_NO as NOW_WORK_ORDER_NO,
        NCDR.NOW_WORK_ORDER_NO = NCDR.CRM_WORK_ORDER_NO as NOW_CRM_WO_MATCH_FLAG,
        left(MATERIAL_NUMBER, 2) as BU,
        vbap.MVGR2 as MATERIAL_GROUP_2,
        tvm2t.BEZEI as MATERIAL_GROUP_2_DESC,
        NCDR.MSDYN_PRODUCTNAME as PRODUCT_NAME_CRM,
        NCDR.NCDR_NUMBER as NOW_NCDR_NUMBER,
        NOWNCDR.NCDR15 as NOW_NCDR15,
        NCDR.CRM_TOOL_SERIAL as CRM_TOOL_SERIAL_NO,
        NCDR.MACHINE_SYSTEM_TYPE as MACHINE_SYSTEM_TYPE,
        NCDR.CRM_ORDERED_QTY as CRM_ORDERED_QTY,
        NCDR.CRM_INSTALLED_QTY as CRM_INSTALLED_QTY,
        NCDR.CRM_RETURNED_QTY as CRM_RETURNED_QTY,
        NCDR.CRM_SHIPPED_QTY as CRM_SHIPPED_QTY,
        NCDR.REGION as REGION,
        NOWNCDR.REGIONAL_APPROVER_NAME,
        NOWNCDR.REGIONALLY_APPROVED_DATE,
        NOWNCDR.GLOBAL_APPROVAL,
        NOWNCDR.GLOBAL_APPROVER,
        NOWNCDR.APPROVED,
        VBAP.ZZDISP as DISPOSITION,
        coalesce(
            nullif(disposition_labels.DDTEXT, 'Value'),
            'N/A'
        ) as DISPOSITION_TEXT,
        VBAP.ZZTSNZ = NCDR.CRM_TOOL_SERIAL as SAP_CRM_TOOL_SERIAL_NO_MATCH_FLAG,
        COALESCED_NCDR_NUMBER = NCDR.NCDR_NUMBER as SAP_NOW_NCDR_MATCH_FLAG,
        vbak.ZZNFZZ as NCDR_FLAG,
        NCDR.REQUESTOR as NOW_REQUESTOR,
        NCDR.SUPERVISOR_NAME as SUPERVISOR_NAME,
        vbap.ZZNSZZ as SAP_STATUS,
        NCDR.MACHINE_WARR_STATUS as NOW_MACHINE_WARR_STATUS,
        NCDR.MACHINE_STATUS_CODE as NOW_MACHINE_STATUS_CODE,
        prps.PRCTR as PRPS_PROFIT_CENTER,
        prps.FKSTL as COST_CENTER,
        NCDR.QTY_NOW as QTY_NOW,
        CASE
            WHEN NCDR.NOW_REASON = 'FCN/SI' THEN '69'
            WHEN NCDR.NOW_REASON = 'Start Up Trouble' THEN '65'
            WHEN NCDR.NOW_REASON = 'Pre Warranty' THEN '65'
            WHEN NCDR.NOW_REASON = 'Under Warranty' THEN '66'
            WHEN NCDR.NOW_REASON = 'Sales Concession' THEN '6A'
            WHEN NCDR.NOW_REASON = 'Factory Concession' THEN '68'
            WHEN NCDR.NOW_REASON = 'Strategic Sales Concession/Equipment BU and FS Sales' THEN '6A'
            WHEN NCDR.NOW_REASON = 'Evaluation Machine' THEN '67'
            WHEN NCDR.NOW_REASON = 'Under Warranty after Modification' THEN '66'
            WHEN NCDR.NOW_REASON = 'R&D Parts' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Short Ship' THEN 'N/A'
            WHEN NCDR.NOW_REASON = 'FS : Short Ship' THEN 'N/A'
            WHEN NCDR.NOW_REASON = 'FS : Sales' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'FS : Factory' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'FS: FRF/CUE/Mods Genpo Concession' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Prorated Part Warranty' THEN 'N/A'
            WHEN NCDR.NOW_REASON = 'Modification Trouble' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Spare Part Warranty' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Rental Machine Pre Warranty' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'FCN/SI Inventory Arrangement' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Non-Strategic Sales Concession / Genpo' THEN 'TBD'
            WHEN NCDR.NOW_REASON = 'Strategic Sales Concession/Equipment BU and FS Sales' THEN 'TBD'
            ELSE 'N/A'
        END AS NOW_SALES_CATEGORY,
        CASE
            WHEN NCDR.NOW_REASON = 'FCN/SI' THEN 'FCN'
            WHEN NCDR.NOW_REASON = 'Start Up Trouble' THEN 'SUP'
            WHEN NCDR.NOW_REASON = 'Pre Warranty' THEN 'PRW'
            WHEN NCDR.NOW_REASON = 'Under Warranty' THEN 'WTY'
            WHEN NCDR.NOW_REASON = 'Sales Concession' THEN 'TEL'
            WHEN NCDR.NOW_REASON = 'Factory Concession' THEN 'FAC'
            WHEN NCDR.NOW_REASON = 'Strategic Sales Concession/Equipment BU and FS Sales' THEN 'SSP'
            WHEN NCDR.NOW_REASON = 'Evaluation Machine' THEN 'EVL'
            WHEN NCDR.NOW_REASON = 'Under Warranty after Modification' THEN 'WTY'
            WHEN NCDR.NOW_REASON = 'R&D Parts' THEN 'EVL?'
            WHEN NCDR.NOW_REASON = 'Short Ship' THEN 'N/A'
            WHEN NCDR.NOW_REASON = 'FS : Short Ship' THEN 'N/A'
            WHEN NCDR.NOW_REASON = 'FS : Sales' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'FS : Factory' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'FS: FRF/CUE/Mods Genpo Concession' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'Prorated Part Warranty' THEN 'PPW'
            WHEN NCDR.NOW_REASON = 'Modification Trouble' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'Spare Part Warranty' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'Rental Machine Pre Warranty' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'FCN/SI Inventory Arrangement' THEN 'Not Defined'
            WHEN NCDR.NOW_REASON = 'Non-Strategic Sales Concession / Genpo' THEN 'GNP'
            WHEN NCDR.NOW_REASON = 'Strategic Sales Concession/Equipment BU and FS Sales' THEN 'GNS'
            ELSE 'N/A'
        END AS NOW_SALES_CATEGORY_NAME,
        end_users.KUNNR as END_USER,
        kna2.NAME1 as END_USER_NAME,
        vbap.ZZNIZZ as SAP_NCDR_ITEM,
        vbak.ERNAM as DELIVERY_CREATOR,
        CASE
            WHEN ifnull(DELIV.DELIVERY_PROCESSING_STATUS, '') != 'C' THEN null
            ELSE DATEDIFF(
                day,
                TRY_TO_DATE(DELIV.LAST_GOODS_MOVEMENT_DATE, 'YYYYMMDD'),
                CURRENT_DATE()
            )
        END AS AGING_DAYS,
        CASE
            WHEN ifnull(DELIV.DELIVERY_PROCESSING_STATUS, '') != 'C' THEN '*Not Delivered'
            WHEN AGING_DAYS <= 30 THEN '0-30 Days'
            WHEN AGING_DAYS <= 90 THEN '1-3 Months'
            WHEN AGING_DAYS <= 180 THEN '3-6 Months'
            WHEN AGING_DAYS <= 365 THEN '6-12 Months'
            ELSE 'Over 1 Year'
        END AS AGING_GROUP,
        VBAP.ZZNNZZ as SAP_NCDR15,
        CASE
            WHEN LEN(COALESCED_NCDR_NUMBER) = 12 THEN REPLACE(COALESCED_NCDR_NUMBER, 'TEA', 'TEA000')
            ELSE COALESCED_NCDR_NUMBER
        END AS COALESCED_NCDR15,  -- 3/25: this used to be the logic for SAP_NCDR15 but there was a request to match SAP system here even when blank
        (
            CASE
                WHEN LEN(COALESCED_NCDR_NUMBER) = 12 THEN REPLACE(COALESCED_NCDR_NUMBER, 'TEA', 'TEA000')
                ELSE COALESCED_NCDR_NUMBER
            END || '__' || VBAP.MATNR || '__' || VBAP.VBELN || '_' || VBAP.POSNR
        ) AS NCDR_PART_SOLINE_KEY,
        BUGROUP.BU_GROUP,
        BUGROUP.BU_GROUP_LEADER,
        CUSTOMER.SEARCH_TERM_2 AS END_USER_SEARCH_NAME,
        CUSTOMER.US_STATE AS END_USER_STATE,
        CUSTOMER.CUSTOMER_GROUP AS ENDUSER_GROUP,
        CUSTOMER.CUSTOMER_GROUP2 AS ENDUSER_GROUP2,
        MACHINE.CURRENT_SN_HISTORY_STATUS AS CURRENT_SN_HISTORY_STATUS_SAP,
        MACHINE.CURRENT_SN_LOCATION AS CURRENT_SN_LOCATION_SAP,
        MACHINE.CURRENT_SN_REGION AS CURRENT_SN_REGION_SAP,
        MACHINE.CURRENT_TOOL_ID AS CURRENT_TOOL_ID_SAP,
        NOW_MACHINE.CURRENT_SERVICE_CONTACT AS CURRENT_SERVICE_CONTACT_NOW,
        NOW_MACHINE.CURRENT_SN_HISTORY_STATUS AS CURRENT_SN_HISTORY_NOW,
        NOW_MACHINE.CURRENT_SN_LOCATION AS CURRENT_SN_LOCATION_NOW,
        NOW_MACHINE.CURRENT_SN_REGION AS CURRENT_SN_REGION_NOW,
        NOW_MACHINE.CURRENT_TOOL_ID AS CURRENT_TOOL_ID_NOW,
        NOW_MACHINE.PARENT_SN AS PARENT_SN_NOW,
        MATERIALMASTER.PART_CLASSIFICATION,
        NOWNCDR.NOW_CANCELLED_FLAG,
        NOWNCDR.NOW_CUSTOMER,
        NOWNCDR.NOW_CUSTOMER_LOCATION,
        NOWNCDR.NOW_REF_ORDER,
        NOWNCDR.NOW_REF_ORDER_SERIES,
        CAST(NOWNCDR.NOW_WORKFLOW_START AS DATE) AS NOW_WORKFLOW_START,
        NOWNCDR.NOW_WORKFLOW_START_FY,
        COALESCE(NOWNCDR.REQUESTOR_NAME, NCDR.REQUESTOR) AS REQUESTOR_NAME,
        NOWNCDR.REQUESTOR_STATUS,
        COALESCE(
            NOWNCDR.REQUESTOR_SUPERVISOR,
            '*Requestor Not US'
        ) AS REQUESTOR_SUPERVISOR,
        NOWNCDR.SN_NOW,
        CASE
            WHEN VBAP.ZZOPZZ = '1' THEN 'Normal'
            WHEN VBAP.ZZOPZZ = '2' THEN 'Rush'
            WHEN VBAP.ZZOPZZ = '3' THEN 'Urgent'
            WHEN VBAP.ZZOPZZ = '4' THEN 'Emergency'
            ELSE 'N/A'
        END AS SALES_ORDER_PRIORITY,
        SHIPTO.SHIP_TO_CUSTOMER,
        SHIPTO.SHIP_TO_CUSTOMER_LOCATION,
        SHIPTO.SHIP_TO_PARTY,
        SHIPTO.SHIP_TO_STATE,
        SOLINE.SEGMENT,
        SOLINE.SEGMENT_CODE,
        SOLINE.STORAGE_CODE,
        SOLINE.STORAGE_NAME,
        COALESCE(SALESCAT.NOW_PRODUCT_TYPE, '*Other') AS NOW_PRODUCT_TYPE,
        WO.WO_CREATOR,
        WO.WO_ID as MSDYN_WORKORDERID,
        WO.WO_TITLE,
        NCDR.CARMA_CONSUMED_QTY,
        VBAK.AUART in ('ZPR2', 'ZSR0') as RETURN_FLAG,
        CASE
            WHEN LEFT(DELIVERY_CREATOR, 3) = 'TEL' THEN 'Migrated'
            WHEN LEN(COALESCED_NCDR_NUMBER) < 15 THEN 'Migrated'
            WHEN NOWNCDR.NOW_WORKFLOW_START < '2023-05-01' THEN 'Migrated'
            ELSE 'SAP'
        END AS MIGRATED_FLAG,
        ROW_NUMBER() OVER (
            PARTITION BY NCDR_PART_SOLINE_KEY
            ORDER BY
                TO_NUMBER(LINE_ITEM_STD_PRICE, 15, 4) DESC,
                TO_NUMBER(NCDR.QTY_NOW, 10, 1) DESC,
                TO_NUMBER(NCDR.CRM_INSTALLED_QTY, 10, 1) DESC
        ) AS KEY_ROW_NUMBER,
        DELIV.DELIVERY_PROCESSING_STATUS,
        goods_quantities.GOODS_ON_LOAN_QTY,
        goods_quantities.GOODS_CONSUMED_QTY,
        goods_quantities.GOODS_RETURN_QTY,
        goods_quantities.GOODS_REMAINING_QTY,
        shipping_address_partner.SHIPPING_ADDRESS,
        NOWNCDR.NOW_DENY_FLAG,
        NOWNCDR.DENY_DATE,
        NOWNCDR.DENY_EMP_NO,
        NOWNCDR.DENIED_BY,
        NOWNCDR.SUPERVISOR_ID,
    FROM
        {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU010_VBAP') }} AS VBAP
        INNER JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU009_VBAK') }} AS VBAK ON (VBAK.VBELN = VBAP.VBELN)
        LEFT JOIN BACKUP_NCDR_LKUP_CRM ON (
            BACKUP_NCDR_LKUP_CRM.ZZSCWN = VBAK.ZZSCWN
            AND BACKUP_NCDR_LKUP_CRM.MATNR = VBAP.MATNR
        )
        LEFT JOIN DELIV ON (
            VBAK.VBELN = DELIV.REF_DOC
            AND VBAP.POSNR = DELIV.REF_DOC_POSNR
        )
        LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU020_KNA1') }} AS KNA1 ON (VBAK.KUNNR = KNA1.KUNNR)
        LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU017_MARA') }} AS MARA ON (MARA.MATNR = VBAP.MATNR)
        LEFT JOIN {{ ref('GOLD__TEA_SALES_REVENUE__NCDR_PART_SUMMARY') }} AS NCDR ON (
            COALESCED_NCDR15 = NCDR.NCDR_NUMBER
            AND VBAP.MATNR = NCDR.PART_NUMBER
        )
        LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU040_PRPS') }} AS PRPS ON (
            VBAP.PS_PSP_PNR_NEW = PRPS.PSPNR_NEW
        )
        LEFT JOIN {{ ref('SILVER__TEA_SALES_REVENUE__SAP_SALES_CATEGORY') }} AS SCAT ON (SCAT.SAP_SALES_CATEGORY = VBAP.ZZORTY)
        LEFT JOIN {{ ref('SILVER__TEA_SALES_REVENUE__SAP_CUSTOMER_GROUP') }} AS CG ON (CG.CUSTOMER_CODE = KNA1.KUNNR)
        LEFT JOIN BILL ON (
            BILL.AUBEL = VBAK.VBELN
            AND BILL.AUPOS = VBAP.POSNR
        )
        LEFT JOIN MATERIAL_BATCH_ZS12_OUTFLOWS AS OUTFLOW ON (
            OUTFLOW.MATNR = VBAP.MATNR
            AND OUTFLOW.CHARG = VBAP.CHARG
            AND OUTFLOW.KDAUF = VBAP.VBELN
            AND VBAK.AUART = 'ZS12'
        )
        LEFT JOIN {{ ref('BRONZE__TEA_SALES_REVENUE__SAPH_SAP_US_MMT_EV_MBEW') }} AS MBEW ON (
            -- Unique key of the MBEW table is MATNR (Material Number) and
            -- BWKEY (Valuation Key).
            -- If we restrict to Valuation Area 3200, each material has one
            -- row.
            VBAP.MATNR = MBEW.MATNR
            AND MBEW.BWKEY = '3200'
        ) -- 5/15: new joins to satisfy columns coming from COMMON.SAPH.NCDR
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU047_VBPA') }} as end_users on (
            VBAP.VBELN = end_users.VBELN
            and end_users.POSNR = '000000'
            and end_users.PARVW = 'Z6'
            and UPPER(end_users.IS_DELETED) = 'NO'
        )
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU020_KNA1') }} as kna2 on (end_users.KUNNR = kna2.KUNNR)
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU120_DD07T_POSAR') }} as disposition_labels on (
            VBAP.ZZDISP = disposition_labels.DOMVALUEL
            and disposition_labels.DOMNAME = 'ZD_ZZDISP2'
            and disposition_labels.DDLANGUAGE = 'EN'
        )
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU023_TVAKT') }} as tvakt on (
            VBAK.AUART = tvakt.AUART
            and tvakt.SPRAS = 'EN'
        )
        left join {{ ref('BRONZE__TEA_SALES_REVENUE__SAPAPI_ZCDV_T_CMTU173_TVM2T') }} as tvm2t on (
            VBAP.MVGR2 = tvm2t.MVGR2
            and tvm2t.SPRAS = 'EN'
        )
        left join WO on NCDR.CRM_WORK_ORDER_NO = WO.WORK_ORDER
        left join CUSTOMER on end_users.KUNNR = CUSTOMER.BUSINESS_PARTNER_NUMBER
        left join MACHINE on VBAP.ZZTSNZ = MACHINE.SERIAL_NUMBER
        left join MATERIALMASTER on VBAP.MATNR = MATERIALMASTER.MATERIAL_NUMBER
        left join NOWNCDR on COALESCED_NCDR15 = NOWNCDR.NCDR15
        left join MACHINE as NOW_MACHINE on NOWNCDR.SN_NOW = NOW_MACHINE.SERIAL_NUMBER
        left join SHIPTO on VBAP.VBELN = SHIPTO.SALES_DOC
        left join SOLINE on VBAP.VBELN || '_' || VBAP.POSNR = SOLINE.SAP_SALES_ORDER_LINE
        left join BUGROUP on SOLINE.SEGMENT_CODE = BUGROUP.BU_SOURCE_KEY
        left join SALESCAT on NOW_SALES_CATEGORY = SALESCAT.MD_SALES_CAT
        left join goods_quantities on VBAP.VBELN = goods_quantities.VBELN
        and VBAP.POSNR = goods_quantities.POSNR
        left join shipping_address_partner on VBAP.VBELN = shipping_address_partner.VBELN
    WHERE COALESCED_NCDR_NUMBER IS NOT NULL
        and VBAK.AUART IN (
            'ZS12',
            'ZS14',
            'ZSR0',
            'ZPR2',
            'ZF11',
            'ZP12',
            'ZXD0'
        )
),
returned_ncdrs as (
    select
        NCDR_PART_PAIR_KEY,
        listagg(VBELN || '_' || POSNR, '; ') as SO_LINES,
        sum(QTY) as QTY,
    from
        SOURCE_DATA
    where
        RETURN_FLAG
    group by
        all
),
final_data as (
    select
        SOURCE_DATA.*,
        returned_ncdrs.SO_LINES as RETURN_SO_LINES,
        returned_ncdrs.QTY as SAP_RETURN_QTY,
    from
        SOURCE_DATA
        left join returned_ncdrs on SOURCE_DATA.NCDR_PART_PAIR_KEY = returned_ncdrs.NCDR_PART_PAIR_KEY
        and not SOURCE_DATA.RETURN_FLAG
),

TRANSFORM_DATA AS (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        VBELN AS SALES_DOC_HDR,
        POSNR AS SALES_DOC_LINE_NUMBER,
        NCDR_PART_PAIR_KEY,
        SALES_DOC_TYPE,
        TRY_TO_DATE(ERDAT, 'YYYYMMDD') AS SO_CREATED_ON,
        TRY_TO_DATE(AUDAT, 'YYYYMMDD') AS SO_DOCUMENT_DATE,
        -- Material Information
        MATERIAL_NUMBER,
        MATERIAL_DESC,
        MATERIAL_GROUP,
        MATERIAL_BASE_UNIT_OF_MEASURE,
        MATERIAL_NET_WEIGHT,
        MATERIAL_GROSS_WEIGHT,
        MATERIAL_WEIGHT_UNIT,
        COALESCED_NCDR_NUMBER as NCDR_NUMBER,
        NCDR_NUMBER_INFERRED_FROM_CRM_NUMBER,
        QTY,
        TGT_QTY,
        LINE_CREATED_BY,
        BAAN_SO_REFERENCE,
        SERVICE_CRM_WO_NUMBER,
        SAP_TOOL_SERIAL,
        ORDER_REASON,
        NET_VALUE_OF_LINE_ITEM,
        UNIT_STD_PRICE,
        LINE_ITEM_STD_PRICE,
        BILL_TO_TEL_AMT,
        COST_IN_DOCUMENT_CURRENCY,
        SUBTOTAL1,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY,
        CUSTOMER_GROUP,
        PROFIT_CENTER,
        SALES_OFFICE,
        CUSTOMER_REFERENCE,
        WBS_ELEMENT,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        BILLING_BLOCK_FOR_ITEM,
        NOW_REASON,
        GLOBALLY_APPROVED_DATE,
        REQUESTOR,
        ORIGINATOR,
        PGI_STATUS,
        COALESCE(DELIVERED_QTY, 0) AS DELIVERED_QTY,
        DO_HDR,
        DO_LINE,
        TRY_TO_DATE(FIRST_GOODS_MOVEMENT_DATE, 'YYYYMMDD') AS FIRST_GOODS_MOVEMENT_DATE,
        TRY_TO_DATE(LAST_GOODS_MOVEMENT_DATE, 'YYYYMMDD') AS LAST_GOODS_MOVEMENT_DATE,
        TRY_TO_DATE(GOODS_ISSUE_DATE, 'YYYYMMDD') AS GOODS_ISSUE_DATE,
        BILLED_QTY,
        BILL_HDR,
        ZZCCOME AS CHANGE_COMMENT,
        regexp_substr(CHANGE_COMMENT, '\\w{2}-TEA\\d+') as COMMENTED_NCDR,
        CASE
            WHEN AUBEL IS NULL THEN FALSE
            ELSE TRUE
        END AS HAS_BILL,
        COALESCE(ZS12_SO_LINE_CNT_IN_BATCH, 0) AS ZS12_SO_LINE_CNT_IN_BATCH,
        COALESCE(TTL_ZS12_SO_QTY_IN_BATCH, 0) AS TTL_ZS12_SO_QTY_IN_BATCH,
        COALESCE(TTL_OUTGOING_ZS12_QTY_IN_BATCH, 0) AS TTL_OUTGOING_ZS12_QTY_IN_BATCH,
        -- The two following columns are converted to dates in a previous CTE
        FIRST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        LATEST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        CASE
            WHEN TTL_OUTGOING_ZS12_QTY_IN_BATCH + TTL_ZS12_SO_QTY_IN_BATCH = 0 THEN 1
            ELSE 0
        END AS ZS12_INVENTORY_MOVEMENT_COMPLETE,
        CASE
            WHEN ABS(TTL_OUTGOING_ZS12_QTY_IN_BATCH) > TTL_ZS12_SO_QTY_IN_BATCH THEN 1
            ELSE 0
        END AS ZS12_INVENTORY_MOVEMENT_OVERAGE_ERROR,
        SAP_BATCH,
        SALES_DOC_TYPE_DESC,
        CRM_WORK_ORDER_NO,
        NOW_WORK_ORDER_NO,
        NOW_CRM_WO_MATCH_FLAG,
        BU,
        MATERIAL_GROUP_2,
        MATERIAL_GROUP_2_DESC,
        PRODUCT_NAME_CRM,
        NOW_NCDR_NUMBER,
        NOW_NCDR15,
        CRM_TOOL_SERIAL_NO,
        MACHINE_SYSTEM_TYPE,
        CRM_ORDERED_QTY,
        CRM_INSTALLED_QTY,
        CRM_RETURNED_QTY,
        CRM_SHIPPED_QTY,
        REGION,
        REGIONAL_APPROVER_NAME,
        REGIONALLY_APPROVED_DATE,
        GLOBAL_APPROVAL,
        GLOBAL_APPROVER,
        APPROVED,
        DISPOSITION,
        DISPOSITION_TEXT,
        SAP_CRM_TOOL_SERIAL_NO_MATCH_FLAG,
        SAP_NOW_NCDR_MATCH_FLAG,
        NCDR_FLAG,
        NOW_REQUESTOR,
        SUPERVISOR_NAME,
        SAP_STATUS,
        NOW_MACHINE_WARR_STATUS,
        NOW_MACHINE_STATUS_CODE,
        PRPS_PROFIT_CENTER,
        COST_CENTER,
        QTY_NOW,
        NOW_SALES_CATEGORY,
        NOW_SALES_CATEGORY_NAME,
        END_USER,
        END_USER_NAME,
        SAP_NCDR_ITEM,
        DELIVERY_CREATOR,
        AGING_DAYS,
        AGING_GROUP,
        SAP_NCDR15,
        NCDR_PART_SOLINE_KEY,
        BU_GROUP,
        BU_GROUP_LEADER,
        END_USER_SEARCH_NAME,
        END_USER_STATE,
        ENDUSER_GROUP,
        ENDUSER_GROUP2,
        CURRENT_SN_HISTORY_STATUS_SAP,
        CURRENT_SN_LOCATION_SAP,
        CURRENT_SN_REGION_SAP,
        CURRENT_TOOL_ID_SAP,
        CURRENT_SERVICE_CONTACT_NOW,
        CURRENT_SN_HISTORY_NOW,
        CURRENT_SN_LOCATION_NOW,
        CURRENT_SN_REGION_NOW,
        CURRENT_TOOL_ID_NOW,
        PARENT_SN_NOW,
        PART_CLASSIFICATION,
        NOW_CANCELLED_FLAG,
        NOW_CUSTOMER,
        NOW_CUSTOMER_LOCATION,
        NOW_REF_ORDER,
        NOW_REF_ORDER_SERIES,
        NOW_WORKFLOW_START,
        NOW_WORKFLOW_START_FY,
        REQUESTOR_NAME,
        REQUESTOR_STATUS,
        REQUESTOR_SUPERVISOR,
        SN_NOW,
        SALES_ORDER_PRIORITY,
        SHIP_TO_CUSTOMER,
        SHIP_TO_CUSTOMER_LOCATION,
        SHIP_TO_PARTY,
        SHIP_TO_STATE,
        SEGMENT,
        SEGMENT_CODE,
        STORAGE_CODE,
        STORAGE_NAME,
        NOW_PRODUCT_TYPE,
        WO_CREATOR,
        MSDYN_WORKORDERID,
        WO_TITLE,
        CARMA_CONSUMED_QTY,
        RETURN_FLAG,
        RETURN_SO_LINES,
        SAP_RETURN_QTY,
        MIGRATED_FLAG,
        KEY_ROW_NUMBER,
        DELIVERY_PROCESSING_STATUS,
        GOODS_ON_LOAN_QTY,
        GOODS_CONSUMED_QTY,
        GOODS_RETURN_QTY,
        GOODS_REMAINING_QTY,
        SHIPPING_ADDRESS,
        NOW_DENY_FLAG,
        DENY_DATE,
        DENY_EMP_NO,
        DENIED_BY,
        SUPERVISOR_ID,
        COALESCED_NCDR15,
    FROM final_data
),

TYPE_DATA AS (
    SELECT
        _AUDIT_LOG_ID,
        _ROW_HASH,
        SALES_DOC_HDR,
        SALES_DOC_LINE_NUMBER,
        NCDR_PART_PAIR_KEY,
        SALES_DOC_TYPE,
        SO_CREATED_ON,
        SO_DOCUMENT_DATE,
        MATERIAL_NUMBER,
        MATERIAL_DESC,
        MATERIAL_GROUP,
        MATERIAL_BASE_UNIT_OF_MEASURE,
        MATERIAL_NET_WEIGHT,
        MATERIAL_GROSS_WEIGHT,
        MATERIAL_WEIGHT_UNIT,
        NCDR_NUMBER,
        CAST(NCDR_NUMBER_INFERRED_FROM_CRM_NUMBER AS INT) AS NCDR_NUMBER_INFERRED_FROM_CRM_NUMBER,
        CAST(QTY AS INT) AS QTY,
        CAST(TGT_QTY AS INT) AS TGT_QTY,
        LINE_CREATED_BY,
        BAAN_SO_REFERENCE,
        SERVICE_CRM_WO_NUMBER,
        SAP_TOOL_SERIAL,
        ORDER_REASON,
        CAST(NET_VALUE_OF_LINE_ITEM AS FLOAT) AS NET_VALUE_OF_LINE_ITEM,
        CAST(UNIT_STD_PRICE AS FLOAT) AS UNIT_STD_PRICE,
        LINE_ITEM_STD_PRICE,
        BILL_TO_TEL_AMT,
        CAST(COST_IN_DOCUMENT_CURRENCY AS FLOAT) AS COST_IN_DOCUMENT_CURRENCY,
        SUBTOTAL1,
        SOLD_TO_PARTY_CODE,
        SOLD_TO_PARTY,
        CUSTOMER_GROUP,
        PROFIT_CENTER,
        SALES_OFFICE,
        CUSTOMER_REFERENCE,
        WBS_ELEMENT,
        SALES_CATEGORY,
        SALES_CATEGORY_NAME,
        BILLING_BLOCK_FOR_ITEM,
        NOW_REASON,
        CAST(GLOBALLY_APPROVED_DATE AS VARCHAR(16777216)) AS GLOBALLY_APPROVED_DATE,
        REQUESTOR,
        ORIGINATOR,
        PGI_STATUS,
        CAST(DELIVERED_QTY AS INT) AS DELIVERED_QTY,
        DO_HDR,
        DO_LINE,
        FIRST_GOODS_MOVEMENT_DATE,
        LAST_GOODS_MOVEMENT_DATE,
        GOODS_ISSUE_DATE,
        CAST(BILLED_QTY AS INT) AS BILLED_QTY,
        BILL_HDR,
        CHANGE_COMMENT,
        COMMENTED_NCDR,
        CAST(HAS_BILL AS INT) AS HAS_BILL,
        CAST(ZS12_SO_LINE_CNT_IN_BATCH AS INT) AS ZS12_SO_LINE_CNT_IN_BATCH,
        CAST(TTL_ZS12_SO_QTY_IN_BATCH AS INT) AS TTL_ZS12_SO_QTY_IN_BATCH,
        CAST(TTL_OUTGOING_ZS12_QTY_IN_BATCH AS INT) AS TTL_OUTGOING_ZS12_QTY_IN_BATCH,
        FIRST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        LATEST_POSTING_DATE_FOR_OUTGOING_ZS12_BATCH_QTY,
        CAST(ZS12_INVENTORY_MOVEMENT_COMPLETE AS INT) AS ZS12_INVENTORY_MOVEMENT_COMPLETE,
        CAST(ZS12_INVENTORY_MOVEMENT_OVERAGE_ERROR AS INT) AS ZS12_INVENTORY_MOVEMENT_OVERAGE_ERROR,
        SAP_BATCH,
        SALES_DOC_TYPE_DESC,
        CRM_WORK_ORDER_NO,
        NOW_WORK_ORDER_NO,
        NOW_CRM_WO_MATCH_FLAG,
        BU,
        MATERIAL_GROUP_2,
        MATERIAL_GROUP_2_DESC,
        PRODUCT_NAME_CRM,
        NOW_NCDR_NUMBER,
        NOW_NCDR15,
        CRM_TOOL_SERIAL_NO,
        MACHINE_SYSTEM_TYPE,
        CRM_ORDERED_QTY,
        CRM_INSTALLED_QTY,
        CRM_RETURNED_QTY,
        CRM_SHIPPED_QTY,
        REGION,
        REGIONAL_APPROVER_NAME,
        REGIONALLY_APPROVED_DATE::DATE as REGIONALLY_APPROVED_DATE,
        GLOBAL_APPROVAL,
        GLOBAL_APPROVER,
        APPROVED,
        DISPOSITION,
        DISPOSITION_TEXT,
        SAP_CRM_TOOL_SERIAL_NO_MATCH_FLAG,
        SAP_NOW_NCDR_MATCH_FLAG,
        NCDR_FLAG,
        NOW_REQUESTOR,
        SUPERVISOR_NAME,
        SAP_STATUS,
        NOW_MACHINE_WARR_STATUS,
        NOW_MACHINE_STATUS_CODE,
        PRPS_PROFIT_CENTER,
        COST_CENTER,
        QTY_NOW,
        NOW_SALES_CATEGORY,
        NOW_SALES_CATEGORY_NAME,
        END_USER,
        END_USER_NAME,
        SAP_NCDR_ITEM,
        DELIVERY_CREATOR,
        cast(AGING_DAYS as NUMBER(38, 0)) as AGING_DAYS,
        AGING_GROUP,
        SAP_NCDR15,
        NCDR_PART_SOLINE_KEY,
        BU_GROUP,
        BU_GROUP_LEADER,
        END_USER_SEARCH_NAME,
        END_USER_STATE,
        ENDUSER_GROUP,
        ENDUSER_GROUP2,
        CURRENT_SN_HISTORY_STATUS_SAP,
        CURRENT_SN_LOCATION_SAP,
        CURRENT_SN_REGION_SAP,
        CURRENT_TOOL_ID_SAP,
        CURRENT_SERVICE_CONTACT_NOW,
        CURRENT_SN_HISTORY_NOW,
        CURRENT_SN_LOCATION_NOW,
        CURRENT_SN_REGION_NOW,
        CURRENT_TOOL_ID_NOW,
        PARENT_SN_NOW,
        PART_CLASSIFICATION,
        NOW_CANCELLED_FLAG,
        NOW_CUSTOMER,
        NOW_CUSTOMER_LOCATION,
        NOW_REF_ORDER,
        NOW_REF_ORDER_SERIES,
        NOW_WORKFLOW_START,
        NOW_WORKFLOW_START_FY,
        REQUESTOR_NAME,
        REQUESTOR_STATUS,
        REQUESTOR_SUPERVISOR,
        SN_NOW,
        SALES_ORDER_PRIORITY,
        SHIP_TO_CUSTOMER,
        SHIP_TO_CUSTOMER_LOCATION,
        SHIP_TO_PARTY,
        SHIP_TO_STATE,
        SEGMENT,
        SEGMENT_CODE,
        STORAGE_CODE,
        STORAGE_NAME,
        NOW_PRODUCT_TYPE,
        WO_CREATOR,
        MSDYN_WORKORDERID,
        WO_TITLE,
        CARMA_CONSUMED_QTY,
        RETURN_FLAG,
        RETURN_SO_LINES,
        SAP_RETURN_QTY :: NUMBER(38, 0) as SAP_RETURN_QTY,
        MIGRATED_FLAG,
        cast(KEY_ROW_NUMBER as NUMBER(38, 0)) as KEY_ROW_NUMBER,
        DELIVERY_PROCESSING_STATUS,
        GOODS_ON_LOAN_QTY :: NUMBER(38, 10) GOODS_ON_LOAN_QTY,
        GOODS_CONSUMED_QTY :: NUMBER(38, 10) GOODS_CONSUMED_QTY,
        GOODS_RETURN_QTY :: NUMBER(38, 10) GOODS_RETURN_QTY,
        GOODS_REMAINING_QTY :: NUMBER(38, 10) GOODS_REMAINING_QTY,
        SHIPPING_ADDRESS,
        NOW_DENY_FLAG,
        DENY_DATE,
        DENY_EMP_NO,
        DENIED_BY,
        SUPERVISOR_ID,
        COALESCED_NCDR15,
    FROM TRANSFORM_DATA
)

SELECT * FROM TYPE_DATA