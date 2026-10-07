{{ config(
        alias = 'UNIVERSAL_ACTUAL_SETTLEMENT_EXTERNAL',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        tags=["finance"],
        transient = false
) }}

with vbap_cte as (
    select * from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU010_VBAP') }}
    where IS_DELETED = 'No'
),

vbak_cte as (
    select * from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU009_VBAK') }}
    where IS_DELETED = 'No'
),

wbs_hard_coded as (
    select
        COLUMN1 as WBS_CAT,
        COLUMN2 as SALES_CAT,
        COLUMN3 as CUSTOMER_NUM
    from values
        ('X-U', 'A3', 'BA0000100'),
        ('X-V', 'A3', 'BA0000100'),
        ('A-D', '80', null)
),

filt_vbap as (
    select distinct
        vbap.VBELN,
        vbap.POSNR,
        vbap.ZZORTY
    from vbap_cte vbap
    inner join vbak_cte vbak on
        vbap.VBELN = vbak.VBELN
),
filt_vbpa as (
    select distinct vbpa.*
    from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU047_VBPA') }} vbpa
    inner join vbak_cte vbak on
        vbpa.VBELN = vbak.VBELN
),

actual_settlement as (
    select
        koao.BELNR,
        koao.DOCLN,
        ifnull(koao.HSL, 0.0) HSL,
        koao.PAUFNR,
        koao.AWREF,
        auaa.PSPNR_NEW,
        date(auak.BUDAT,'yyyymmdd') AS BUDAT
    from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU024_01_ACDOCA') }} koao
    inner join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU196_AUAA') }} auaa on
        try_to_number(koao.AWREF) = try_to_number(auaa.BELNR)
    inner join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU222_AUAK') }} auak on
        try_to_number(auaa.BELNR) = try_to_number(auak.BELNR)
    where
        koao.RLDNR = '0L' and
        koao.RBUKRS = '3200' and
        koao.BTTYPE = 'KOAO' and
        koao.ACCASTY = 'PR' and
        (koao.RACCT ilike 'C%' or koao.RACCT ilike '6%')
),
ps_source_data as (
    select distinct
        koae.BTTYPE,
        koae.AWREF,
        koae.PS_POSID as WBS_ELEMENT,
        substr(koae.PS_POSID, 1, 1) || '-' || substr(koae.PS_POSID, 13, 1) as WBS_CATEGORY,
        koae.RACCT,
        actual_settlement.PAUFNR,
        koae.PRCTR,
        koae.GJAHR,
        koae.POPER,
        koae.RBUKRS,
        koae.BELNR,
        koae.DOCLN,
        koae.RLDNR,
        coalesce(whc.SALES_CAT,vbap.ZZORTY, vbap2.ZZORTY) as SALES_CATEGORY,
        coalesce(vbap.VBELN,vbap2.VBELN) AS SALES_DOCUMENT,
        coalesce(vbap.POSNR,vbap2.POSNR) AS SALES_DOCUMENT_ITEM,
        vbpa.KUNNR,
        koae.HSL AMOUNT

    from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU024_01_ACDOCA') }} koae
    left join actual_settlement on
        try_to_number(koae.PS_PSP_PNR_NEW) = try_to_number(actual_settlement.PSPNR_NEW) and
        try_to_number(koae.AWREF) <> try_to_number(actual_settlement.BELNR)
        and (try_to_date(koae.BUDAT, 'YYYYMMDD')>=try_to_date(actual_settlement.BUDAT))
    left join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU090_AUFK') }} aufk on
        try_to_number(actual_settlement.PAUFNR) = try_to_number(aufk.AUFNR)
    left join filt_vbap vbap on
        try_to_number(aufk.KDAUF) = try_to_number(vbap.VBELN) and
        try_to_number(aufk.KDPOS) = try_to_number(vbap.POSNR)
    left join filt_vbpa vbpa on
        try_to_number(aufk.KDAUF) = try_to_number(vbpa.VBELN) and
        vbpa.PARVW = 'Z6'

    left join wbs_hard_coded whc on
        WBS_CATEGORY = whc.WBS_CAT

    left join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU236_AFIH') }} afih on
        try_to_number(actual_settlement.PAUFNR) = try_to_number(afih.AUFNR)
    left join
    (
        select * from vbap_cte
        qualify (row_number() over (partition by VBELN order by VBELN)) = 1
    ) vbap2 on
        try_to_number(afih.DEVICEID) = try_to_number(vbap2.VBELN)
    left join filt_vbpa vbpa2 on
        try_to_number(afih.DEVICEID) = try_to_number(vbpa2.VBELN) and
        vbpa2.PARVW ='Z6'

    where
        koae.RLDNR = '0L' and
        koae.RBUKRS = '3200' and
        koae.BTTYPE = 'KOAE' and
        koae.RACCT = '5110100004' and
        WBS_CATEGORY in ('P-S',
            'P-Q',
            'A-D',
            'A-C',
            'A-4',
            'A-5',
            'A-6',
            'A-7',
            'A-A',
            'A-B',
            'I-4',
            'I-5',
            'I-6',
            'I-7',
            'I-C',
            'X-U',
            'X-V',
            'Z-4',
            'Z-5',
            'Z-8',
            'Z-9')
    QUALIFY (ROW_NUMBER() OVER (PARTITION BY CONCAT(koae.BELNR,'_',koae.DOCLN),koae.GJAHR,koae.POPER ORDER BY to_date(koae.BUDAT) DESC )) = 1
),

source_data as (
    select
        koae.BTTYPE,
        koae.AWREF,
        koae.PS_POSID as WBS_ELEMENT,
        substr(koae.PS_POSID, 1, 1) || '-' || substr(koae.PS_POSID, 13, 1) as WBS_CATEGORY,
        koae.RACCT,
        actual_settlement.PAUFNR,
        koae.PRCTR,
        koae.GJAHR,
        koae.POPER,
        koae.RBUKRS,
        koae.BELNR,
        koae.DOCLN,
        koae.RLDNR,
        coalesce(whc.SALES_CAT,vbap.ZZORTY, vbap2.ZZORTY) as SALES_CATEGORY,
        coalesce(vbap.VBELN,vbap2.VBELN) AS SALES_DOCUMENT,
        coalesce(vbap.POSNR,vbap2.POSNR) AS SALES_DOCUMENT_ITEM,
        vbpa.KUNNR,
        coalesce(actual_settlement.HSL, koae.HSL) AMOUNT

    from {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU024_01_ACDOCA') }} koae
    left join actual_settlement on
        try_to_number(koae.PS_PSP_PNR_NEW) = try_to_number(actual_settlement.PSPNR_NEW) and
        try_to_number(koae.AWREF) <> try_to_number(actual_settlement.BELNR)
        and (try_to_date(koae.BUDAT, 'YYYYMMDD')=try_to_date(actual_settlement.BUDAT))
    left join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU090_AUFK') }} aufk on
        try_to_number(actual_settlement.PAUFNR) = try_to_number(aufk.AUFNR)
    left join filt_vbap vbap on
        try_to_number(aufk.KDAUF) = try_to_number(vbap.VBELN) and
        try_to_number(aufk.KDPOS) = try_to_number(vbap.POSNR)
    left join filt_vbpa vbpa on
        try_to_number(aufk.KDAUF) = try_to_number(vbpa.VBELN) and
        vbpa.PARVW = 'Z6'

    left join wbs_hard_coded whc on
        WBS_CATEGORY = whc.WBS_CAT

    left join {{ ref('BRONZE__TEH_FINANCE__SAPAPI_ZCDV_T_CMTU236_AFIH') }} afih on
        try_to_number(actual_settlement.PAUFNR) = try_to_number(afih.AUFNR)
    left join
    (
        select * from vbap_cte
        qualify (row_number() over (partition by VBELN order by VBELN)) = 1
    ) vbap2 on
        try_to_number(afih.DEVICEID) = try_to_number(vbap2.VBELN)
    left join filt_vbpa vbpa2 on
        try_to_number(afih.DEVICEID) = try_to_number(vbpa2.VBELN) and
        vbpa2.PARVW ='Z6'

    where
        koae.RLDNR = '0L' and
        koae.RBUKRS = '3200' and
        koae.BTTYPE = 'KOAE' and
        koae.RACCT = '5110100004' and 
        WBS_CATEGORY not in ('P-S',
            'P-Q',
            'A-D',
            'A-C',
            'A-4',
            'A-5',
            'A-6',
            'A-7',
            'A-A',
            'A-B',
            'I-4',
            'I-5',
            'I-6',
            'I-7',
            'I-C',
            'X-U',
            'X-V',
            'Z-4',
            'Z-5',
            'Z-8',
            'Z-9')
)
,combined_data as (
    SELECT * FROM ps_source_data
    UNION ALL
    SELECT * FROM source_data
)
,transform_data as (
    SELECT
        combined_data.RBUKRS AS COMPANY_CODE,
        combined_data.GJAHR AS FISCAL_YEAR,
        combined_data.BELNR AS ACCOUNTING_DOCUMENT_NUMBER,
        combined_data.DOCLN AS SIX_CHARACTER_POSTING_ITEM_FOR_LEDGER,
        NULL AS PARTNER_WORK_BREAKDOWN_STRUCTURE_ELEMENT_PPS_PSP_PNR,
        NULL AS WBS_ELEMENT_SHORT_IDENTIFICATION,
        combined_data.BTTYPE AS ACDOCA_BUSINESS_TRANSACTION_TYPE,
        combined_data.RLDNR AS LEDGER_IN_GENERAL_LEDGER_ACCOUNTING,
        NULL AS NAME_1,
        combined_data.RACCT AS ACCOUNT_NUMBER,
        combined_data.SALES_CATEGORY AS SALES_CATEGORY,
        combined_data.WBS_CATEGORY AS WBS_CATEGORY,
        combined_data.KUNNR as KUNNR,
        combined_data.SALES_DOCUMENT AS SALES_DOCUMENT,
        combined_data.SALES_DOCUMENT_ITEM AS SALES_DOCUMENT_ITEM,
        combined_data.AMOUNT AS AMOUNT,
		'{{ invocation_id }}' AS AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH
    FROM combined_data
),
type_data as
(
    SELECT
        COMPANY_CODE,
        FISCAL_YEAR,
        ACCOUNTING_DOCUMENT_NUMBER,
        SIX_CHARACTER_POSTING_ITEM_FOR_LEDGER,
        PARTNER_WORK_BREAKDOWN_STRUCTURE_ELEMENT_PPS_PSP_PNR,
        WBS_ELEMENT_SHORT_IDENTIFICATION,
        ACDOCA_BUSINESS_TRANSACTION_TYPE,
        LEDGER_IN_GENERAL_LEDGER_ACCOUNTING,
        NAME_1,
        ACCOUNT_NUMBER,
        SALES_CATEGORY,
        WBS_CATEGORY,
        KUNNR,
        SALES_DOCUMENT,
        SALES_DOCUMENT_ITEM,
        CAST(AMOUNT AS NUMBER(38,2)) AS AMOUNT,
        CAST(AUDIT_LOG_ID AS VARCHAR(128)) AS AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH
    FROM transform_data
)

SELECT * from type_data

