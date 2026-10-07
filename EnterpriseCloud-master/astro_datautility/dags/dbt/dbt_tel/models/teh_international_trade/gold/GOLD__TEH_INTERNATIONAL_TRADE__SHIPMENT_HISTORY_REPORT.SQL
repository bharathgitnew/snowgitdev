{{ config(
    materialized='tel_incremental',
    incremental_strategy='insert_overwrite',
    alias = 'SHIPMENT_HISTORY_REPORT',
    unique_key = ['SOURCE', 'DELIVERY_NUMBER', 'DELIVERY_ITEM'],
    meta = {
        'owners': [
            'Sarah Hein',
            'Cameron Hilliard',
            'Gavin Emerson'
        ]
    }
) }}

with doc_flow as (
    select
        VBELV,
        POSNV,
        VBELN,
        POSNN,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_FLOW') }}
    where VBTYP_N = 'J' and VBTYP_V = 'C'
    qualify row_number() over(partition by VBELN, POSNN order by VBELV, POSNV) = 1
),

schedule_lines as (
    select
        VBELN,
        POSNR,
        min(EDATU) as FIRST_DATE,
        max(EDATU) as CONF_DATE,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_SCHEDULE_LINE_DATA') }}
    group by VBELN, POSNR
),

konv as (
    select
        vbap.VBELN,
        vbap.POSNR,
        konv.KNUMV,
        konv.KPOSN,
        konv.KBETR,
        konv.WAERS,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_ITEM_DATA') }} as vbap
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_HEADER_DATA') }} as vbak
        on vbap.VBELN = VBAK.VBELN
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_DOCUMENT_CONDITIONS') }} as konv
        on vbak.KNUMV = konv.KNUMV
        and vbap.POSNR = konv.KPOSN
    where konv.KINAK = ''
        and konv.KSCHL = 'ZCIV'
    qualify row_number() over(partition by konv.KNUMV, konv.KPOSN order by konv.STUNR desc, konv.ZAEHK desc) = 1
),

sharepoint_file as (
    select *
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SHAREPOINT_TMEA_EXPORT_SHIPMENT_HISTORY_SNOWFLAKE_UPDATE') }}
    where ltrim(DELIVERY_NUMBER, '0') not ilike '8%'
),

sap_data as (
    select 
        lips.VBELN as DELIVERY_NUMBER,
        lips.POSNR as DELIVERY_ITEM,
        lips.WERKS as PLANT,
        vbpa_sp.KUNNR as SOLD_TO,
        likp.KUNNR as SHIP_TO,
        vbpa_z1.KUNNR as END_USER,
        vbak.AUART as ORDER_TYPE,
        vbap.VBELN as ORDER_NUMBER,
        vbap.POSNR as ORDER_ITEM,
        vbak.BSTNK as PO_DETAILS,
        likp.LPRIO as PRIORITY,
        lips.MATNR as MATERIAL,
        vbap.ARKTX as MATERIAL_DESCRIPTION,
        iff(lips.NETPR between -0.01 and 0.01, null, lips.NETPR) as DOC_PRICE,
        vbap.WAERK as ORDER_CURRENCY,
        likp.FKDAT as SHIP_DATE,
        likp.BOLNR as BILL_OF_LANDING,
        lips.LFIMG as QTY_SHIPPED,
        lips.VRKME as U_OF_M,
        marc.STAWN as COMMODITY_CODE,
        maex.ALNUM as ECCN,
        likp.ROUTE as ROUTE_CODE,
        tvrot.BEZEI as ROUTE_DESCRIPTION,
        vbap.ERDAT as BOOK_DATE,
        schedule_lines.FIRST_DATE as FIRST_DATE,
        schedule_lines.CONF_DATE as CONF_DATE,
        coalesce(vbkd.INCO1, vbkd_backup.INCO1) as INCO_TERM_1,
        coalesce(vbkd.INCO2, vbkd_backup.INCO2) as INCO_TERM_2,
        round(mbew.STPRS / mbew.PEINH, 2) * lips.LFIMG as EXT_COST_USD,
        marc.HERKL as COUNTRY_OF_ORIGIN,
        coalesce(vbex.GENNR, zvbex.GENNR) as INTERNAL_LICENSE_NUMBER,
        embk.EXGEN as EXTERNAL_LICENSE_NUMBER,
        coalesce(vbkd.PRSDT, vbkd_backup.PRSDT) as PRICE_DATE,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SD_DOCUMENT_DELIVERY_ITEM_DATA') }} as lips
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SD_DOCUMENT_DELIVERY_HEADER_DATA') }} as likp
        on lips.VBELN = likp.VBELN
    left join doc_flow as vbfa
        on lips.VBELN = vbfa.VBELN
        and lips.POSNR = vbfa.POSNN
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_ITEM_DATA') }} as vbap
        on vbfa.VBELV = vbap.VBELN
        and vbfa.POSNV = vbap.POSNR
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_HEADER_DATA') }} as vbak
        on vbap.VBELN = vbak.VBELN
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_PARTNER') }} as vbpa_sp
        on try_to_number(vbap.VBELN) = try_to_number(vbpa_sp.VBELN)
        and vbpa_sp.POSNR = '000000'
        and vbpa_sp.PARVW = 'AG'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_PARTNER') }} as vbpa_z1
        on try_to_number(vbap.VBELN) = try_to_number(vbpa_z1.VBELN)
        and vbpa_z1.POSNR = '000000'
        and vbpa_z1.PARVW = 'Z1'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_PLANT_DATA_FOR_MATERIAL') }} as marc
        on lips.MATNR = marc.MATNR
        and lips.WERKS = marc.WERKS
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_MASTER_LEGAL_CONTROL') }} as maex
        on lips.MATNR = maex.MATNR
        and maex.ALAND = 'US'
        and maex.GEGRU = 'US'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_BUSINESS_DATA') }} as vbkd
        on vbap.VBELN = vbkd.VBELN
        and vbap.POSNR = vbkd.POSNR
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DOCUMENT_BUSINESS_DATA') }} as vbkd_backup
        on vbkd.VBELN is null
        and vbap.VBELN = vbkd_backup.VBELN
        and '000000' = vbkd_backup.POSNR
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_VALUATION') }} as mbew
        on lips.MATNR = mbew.MATNR
        and lips.WERKS = mbew.BWKEY
        and mbew.BWTAR = ' '
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_ROUTES_TEXTS') }} as tvrot
        on likp.ROUTE = tvrot.ROUTE
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DISTRIBUTION_DOCUMENT_EXPORT_CONTROL_ITEM_DATA') }} as vbex
        on vbap.VBELN = vbex.VBELN
        and vbap.POSNR = vbex.POSNR
        and vbex.GEGRU = 'US'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_DOCUMENT_EXPORT_CONTROL_DATA_AT_ITEM_LEVEL') }} as zvbex
        on vbap.VBELN = zvbex.VBELN
        and vbap.POSNR = zvbex.POSNR
        and zvbex.GEGRU = 'US'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_LEGAL_CONTROL_LICENSE_MASTER_HEADER_DATA') }} as embk
        on INTERNAL_LICENSE_NUMBER = embk.GENNR
    left join schedule_lines
        on vbap.VBELN = schedule_lines.VBELN
        and vbap.POSNR = schedule_lines.POSNR
    where lips.IS_DELETED = 'No'
),

combined_data as (
    select 
        'SAP' as DATA_SOURCE,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        PLANT,
        SOLD_TO,
        SHIP_TO,
        END_USER,
        ORDER_TYPE,
        ORDER_NUMBER,
        ORDER_ITEM,
        PO_DETAILS,
        PRIORITY,
        MATERIAL,
        MATERIAL_DESCRIPTION,
        DOC_PRICE,
        ORDER_CURRENCY,
        SHIP_DATE,
        BILL_OF_LANDING,
        QTY_SHIPPED,
        U_OF_M,
        COMMODITY_CODE,
        ECCN,
        ROUTE_CODE,
        ROUTE_DESCRIPTION,
        BOOK_DATE,
        FIRST_DATE,
        CONF_DATE,
        INCO_TERM_1,
        INCO_TERM_2,
        EXT_COST_USD,
        COUNTRY_OF_ORIGIN,
        INTERNAL_LICENSE_NUMBER,
        EXTERNAL_LICENSE_NUMBER,
        PRICE_DATE,
    from sap_data
    union 
    select 
        'SharePoint' as DATA_SOURCE,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        PLANT,
        SOLD_TO,
        SHIP_TO,
        END_USER,
        ORDER_TYPE,
        ORDER_NUMBER,
        ORDER_ITEM,
        PO_DETAILS,
        PRIORITY,
        MATERIAL,
        MATERIAL_DESCRIPTION,
        iff(PRICE_EACH between -0.01 and 0.01, null, try_to_number(PRICE_EACH)) as DOC_PRICE,
        ORDER_CURRENCY,
        SHIP_DATE,
        BILL_OF_LANDING,
        try_to_number(QTY_SHIPPED) as QTY_SHIPPED,
        U_OF_M,
        COMMODITY_CODE,
        ECCN,
        ROUTE_CODE,
        ROUTE_DESCRIPTION,
        BOOK_DATE,
        FIRST_DATE,
        CONF_DATE,
        INCO_TERM_1,
        INCO_TERM_2,
        try_to_number(EXT_COST_USD) as EXT_COST_USD,
        COUNTRY_OF_ORIGIN,
        INTERNAL_LICENSE_NUMBER,
        EXTERNAL_LICENSE_NUMBER,
        null as PRICE_DATE,
    from sharepoint_file
),

source_data as (
    select 
        combined_data.DATA_SOURCE,
        combined_data.DELIVERY_NUMBER,
        combined_data.DELIVERY_ITEM,
        combined_data.PLANT,
        combined_data.SOLD_TO,
        kna1_sp.NAME1 as SOLD_TO_NAME,
        kna1_sp.REGIO as SOLD_TO_STATE,
        kna1_sp.LAND1 as SOLD_TO_COUNTRY,
        combined_data.SHIP_TO,
        kna1_sh.NAME1 as SHIP_TO_NAME,
        kna1_sh.REGIO as SHIP_TO_STATE,
        kna1_sh.LAND1 as SHIP_TO_COUNTRY,
        combined_data.END_USER,
        kna1_z1.NAME1 as END_USER_NAME,
        kna1_z1.REGIO as END_USER_STATE,
        kna1_z1.LAND1 as END_USER_COUNTRY,
        combined_data.ORDER_TYPE,
        combined_data.ORDER_NUMBER,
        combined_data.ORDER_ITEM,
        combined_data.PO_DETAILS,
        combined_data.PRIORITY,
        combined_data.MATERIAL,
        combined_data.MATERIAL_DESCRIPTION,
        nullif(manual_prices.PRICE_EACH, '') as MANUAL_PRICE,
        combined_data.DOC_PRICE,
        iff(konv.KBETR between -0.01 and 0.01, null, konv.KBETR) as CONDITION_PRICE,
        case
            when mbew.VPRSV = 'S' then mbew.STPRS 
            when mbew.VPRSV = 'V' then mbew.VERPR 
            else 0
        end as MAT_PRICE,
        coalesce(MANUAL_PRICE, DOC_PRICE, CONDITION_PRICE, MAT_PRICE) as PRICE_EACH,
        PRICE_EACH * combined_data.QTY_SHIPPED as EXT_PRICE,
        coalesce(konv.WAERS, combined_data.ORDER_CURRENCY) as ORDER_CURRENCY,
        combined_data.EXT_COST_USD,
        combined_data.SHIP_DATE,
        combined_data.BILL_OF_LANDING,
        combined_data.QTY_SHIPPED,
        combined_data.U_OF_M,
        combined_data.COMMODITY_CODE,
        combined_data.ECCN,
        combined_data.ROUTE_CODE,
        combined_data.ROUTE_DESCRIPTION,
        combined_data.BOOK_DATE,
        combined_data.FIRST_DATE,
        combined_data.CONF_DATE,
        combined_data.INCO_TERM_1,
        combined_data.INCO_TERM_2,
        combined_data.COUNTRY_OF_ORIGIN,
        combined_data.INTERNAL_LICENSE_NUMBER,
        combined_data.EXTERNAL_LICENSE_NUMBER,
        combined_data.PRICE_DATE,
    from combined_data
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SHAREPOINT_TMEA_MACHINE_EXPORT_PRICING') }} as manual_prices
        on try_to_number(combined_data.DELIVERY_NUMBER) = try_to_number(manual_prices.DELIVERY_NUMBER)
        and try_to_number(combined_data.DELIVERY_ITEM) = try_to_number(manual_prices.DELIVERY_ITEM)
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_GENERAL_DATA_IN_CUSTOMER_MASTER') }} as kna1_sp
        on combined_data.SOLD_TO = kna1_sp.KUNNR
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_GENERAL_DATA_IN_CUSTOMER_MASTER') }} as kna1_sh
        on combined_data.SHIP_TO = kna1_sh.KUNNR
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_GENERAL_DATA_IN_CUSTOMER_MASTER') }} as kna1_z1
        on combined_data.END_USER = kna1_z1.KUNNR
    left join konv
        on try_to_number(combined_data.ORDER_NUMBER) = try_to_number(konv.VBELN)
        and try_to_number(combined_data.ORDER_ITEM) = try_to_number(konv.POSNR)
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_VALUATION') }} as mbew
        on combined_data.MATERIAL = mbew.MATNR
        and combined_data.PLANT = mbew.BWKEY
        and mbew.BWTAR = ' '
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        DATA_SOURCE,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        PLANT,
        SOLD_TO,
        SOLD_TO_NAME,
        SOLD_TO_STATE,
        SOLD_TO_COUNTRY,
        SHIP_TO,
        SHIP_TO_NAME,
        SHIP_TO_STATE,
        SHIP_TO_COUNTRY,
        END_USER,
        END_USER_NAME,
        END_USER_STATE,
        END_USER_COUNTRY,
        ORDER_TYPE,
        ORDER_NUMBER,
        ORDER_ITEM,
        PO_DETAILS,
        PRIORITY,
        MATERIAL,
        MATERIAL_DESCRIPTION,
        PRICE_EACH,
        EXT_PRICE,
        ORDER_CURRENCY,
        EXT_COST_USD,
        to_varchar(try_to_date(SHIP_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as SHIP_DATE,
        BILL_OF_LANDING,
        QTY_SHIPPED,
        U_OF_M,
        COMMODITY_CODE,
        ECCN,
        ROUTE_CODE,
        ROUTE_DESCRIPTION,
        to_varchar(try_to_date(BOOK_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as BOOK_DATE,
        to_varchar(try_to_date(FIRST_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as FIRST_DATE,
        to_varchar(try_to_date(CONF_DATE, 'YYYYMMDD'), 'MM/DD/YYYY') as CONF_DATE,
        INCO_TERM_1,
        INCO_TERM_2,
        COUNTRY_OF_ORIGIN,
        INTERNAL_LICENSE_NUMBER,
        EXTERNAL_LICENSE_NUMBER,
        PRICE_DATE,
    from source_data
),

type_data as (
    select
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _REFRESHDATE,
        DATA_SOURCE,
        DELIVERY_NUMBER,
        DELIVERY_ITEM,
        PLANT,
        SOLD_TO,
        SOLD_TO_NAME,
        SOLD_TO_STATE,
        SOLD_TO_COUNTRY,
        SHIP_TO,
        SHIP_TO_NAME,
        SHIP_TO_STATE,
        SHIP_TO_COUNTRY,
        END_USER,
        END_USER_NAME,
        END_USER_STATE,
        END_USER_COUNTRY,
        ORDER_TYPE,
        ORDER_NUMBER,
        ORDER_ITEM,
        PO_DETAILS,
        PRIORITY,
        MATERIAL,
        MATERIAL_DESCRIPTION,
        PRICE_EACH::number(38, 2) as PRICE_EACH,
        EXT_PRICE::number(38, 2) as EXT_PRICE,
        ORDER_CURRENCY,
        EXT_COST_USD::number(38, 2) as EXT_COST_USD,
        SHIP_DATE,
        BILL_OF_LANDING,
        QTY_SHIPPED::number(38, 4) as QTY_SHIPPED,
        U_OF_M,
        COMMODITY_CODE,
        ECCN,
        ROUTE_CODE,
        ROUTE_DESCRIPTION,
        BOOK_DATE,
        FIRST_DATE,
        CONF_DATE,
        INCO_TERM_1,
        INCO_TERM_2,
        COUNTRY_OF_ORIGIN,
        INTERNAL_LICENSE_NUMBER,
        EXTERNAL_LICENSE_NUMBER,
        PRICE_DATE,
    from transform_data
)

select * from type_data
