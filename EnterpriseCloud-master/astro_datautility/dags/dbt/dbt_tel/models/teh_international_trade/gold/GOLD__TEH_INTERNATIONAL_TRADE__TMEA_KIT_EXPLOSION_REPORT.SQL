{{ config(
    alias = 'TMEA_KIT_EXPLOSION_REPORT',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}

with source_data as (
    select 
        report.DATA_SOURCE,
        report.DELIVERY_NUMBER,
        report.DELIVERY_ITEM,
        report.PLANT,
        report.SOLD_TO,
        report.SOLD_TO_NAME,
        report.SOLD_TO_STATE,
        report.SOLD_TO_COUNTRY,
        report.SHIP_TO,
        report.SHIP_TO_NAME,
        report.SHIP_TO_STATE,
        report.SHIP_TO_COUNTRY,
        report.END_USER,
        report.END_USER_NAME,
        report.END_USER_STATE,
        report.END_USER_COUNTRY,
        report.ORDER_TYPE,
        report.ORDER_NUMBER,
        report.ORDER_ITEM,
        report.PO_DETAILS,
        report.PRIORITY,
        report.MATERIAL,
        report.MATERIAL_DESCRIPTION,
        report.PRICE_EACH as ORDER_PRICE_EACH,
        report.EXT_PRICE as EXT_ORDER_PRICE,
        report.ORDER_CURRENCY,
        report.EXT_COST_USD,
        report.SHIP_DATE,
        report.BILL_OF_LANDING,
        report.QTY_SHIPPED,
        report.U_OF_M,
        report.COMMODITY_CODE,
        report.ECCN,
        report.ROUTE_CODE,
        report.ROUTE_DESCRIPTION,
        report.BOOK_DATE,
        report.FIRST_DATE,
        report.CONF_DATE,
        report.INCO_TERM_1,
        report.INCO_TERM_2,
        report.COUNTRY_OF_ORIGIN,
        report.INTERNAL_LICENSE_NUMBER,
        report.EXTERNAL_LICENSE_NUMBER,
        kit.BOM_LINEAGE,
        kit.EXPL_LEVEL,
        kit.PARENT_PART_NUMBER,
        kit.PARENT_PART_DESC,
        kit.PARENT_COMMODITY_CODE,
        kit.BOM_NUMBER,
        kit.BOM_ITEM_NUMBER,
        kit.COMPONENT,
        kit.COMPONENT_DESC,
        kit.QTY,
        kit.QTY_UNIT,
        kit.ORIGIN,
        kit.TOTAL_WEIGHT,
        kit.WEIGHT_UNITS,
        kit.COMMODITY_CODE as COMPONENT_COMMODITY_CODE,
        kit.ECCN as COMPONENT_ECCN,
        kit.STANDARD_COST,
        kit.EXT_COST,
        kit.MAT_GROUP,
        kit.STS_FLAG,
        case
            when kit.COMMODITY_CODE = 'SEE TARIFF SHEET' then 0
            -- when kit.MAT_GROUP = '4' then 0
            when kit.MAT_GROUP = '13' then 
                case
                    when kit.STANDARD_COST between 0 and 599.99 then kit.STANDARD_COST * 1.82
                    when kit.STANDARD_COST between 600 and 5999.99 then kit.STANDARD_COST * 1.68
                    when kit.STANDARD_COST > 6000 then kit.STANDARD_COST * 1.54
                    else kit.STANDARD_COST -- standard price (COST)
                end
            else kit.STANDARD_COST * coalesce(zprice.SALE_PRC_MULT, 1)
        end as MULT_PRICE,
        case
            when konp.KBETR is not null then konp.KBETR
            when MULT_PRICE < 51 then ceil(MULT_PRICE)
            when MULT_PRICE < 251 then ceil(MULT_PRICE / 5) * 5
            else ceil(MULT_PRICE / 10) * 10
        end as PRICE,
        round(PRICE * kit.QTY, 2) as EXT_PRICE,
        round(case
            when kit.MAT_GROUP = '13' then PRICE -- no discount because its customer specific
            else PRICE * coalesce(zprice.TRAN_PRC_PERCENT, 1)
        end, 2) as TRANSFER_PRICE,
        round(TRANSFER_PRICE * kit.QTY, 2) as EXT_TRANSFER_PRICE,
        round(sum(EXT_TRANSFER_PRICE) over (partition by report.DELIVERY_NUMBER, report.DELIVERY_ITEM), 2) as TOTAL_EXT_TRANSFER_PRICE,
        round((EXT_TRANSFER_PRICE / nullifzero(TOTAL_EXT_TRANSFER_PRICE)), 4) as PERCENT_TOTAL_PARTS_VALUE,
        round((report.PRICE_EACH - TOTAL_EXT_TRANSFER_PRICE) * PERCENT_TOTAL_PARTS_VALUE, 2) as PRICE_INCREASE,
        PRICE_INCREASE + EXT_TRANSFER_PRICE as SALES_PRICE,
    from {{ ref('GOLD__TEH_INTERNATIONAL_TRADE__SHIPMENT_HISTORY_REPORT') }} as report
    left join {{ ref('SILVER__TEH_INTERNATIONAL_TRADE__BOM_HEIRARCHY') }} as kit
        on report.MATERIAL = kit.ROOT_PART_NUMBER
        and kit.STS_FLAG = TRUE
        -- and kit.COMMODITY_CODE != 'SEE TARIFF SHEET'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_CONDITIONS_FOR_CUSTOMER_MATERIAL') }} as a005
        on kit.COMPONENT = a005.MATNR
        and report.SOLD_TO = a005.KUNNR
        and a005.MANDT = '300'
        and a005.KAPPL = 'V'
        and a005.KSCHL = 'PR00'
        and try_to_number(a005.VKORG) = '0010'
        and try_to_number(a005.VTWEG) = '10'
        and report.PRICE_DATE between a005.DATAB and a005.DATBI
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_CONDITIONS_FOR_MATERIAL') }} as a004
        on kit.COMPONENT = a004.MATNR
        and a004.MANDT = '300'
        and a004.KAPPL = 'V'
        and a004.KSCHL = 'PR00'
        and try_to_number(a004.VKORG) = '0010'
        and try_to_number(a004.VTWEG) = '10'
        and report.PRICE_DATE between a004.DATAB and a004.DATBI
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_PRICE_CONDITION_ITEMS') }} as konp
        on try_to_number(coalesce(a005.KNUMH, a004.KNUMH) )= konp.KNUMH
        and try_to_number(konp.KOPOS) = '01'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_ZPRICE_CALC') }} as zprice
        on zprice.MANDT = '300'
        and zprice.SALES_CODE = kit.MAT_GROUP
        and zprice.DIVISION = kit.DIVISION
        and zprice.START_DATE <= report.PRICE_DATE
        and kit.STANDARD_COST between zprice.STD_COST_LOW and zprice.STD_COST_HIGH
    -- joining to zprice_calc will get all previous calculations so we need to filter to the most recent
    qualify row_number() over (partition by report.DELIVERY_NUMBER, report.DELIVERY_ITEM, kit.BOM_LINEAGE order by zprice.START_DATE desc) = 1
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
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
        ORDER_PRICE_EACH,
        EXT_ORDER_PRICE,
        ORDER_CURRENCY,
        EXT_COST_USD,
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
        COUNTRY_OF_ORIGIN,
        INTERNAL_LICENSE_NUMBER,
        EXTERNAL_LICENSE_NUMBER,
        BOM_LINEAGE,
        EXPL_LEVEL,
        PARENT_PART_NUMBER,
        PARENT_PART_DESC,
        PARENT_COMMODITY_CODE,
        BOM_NUMBER,
        BOM_ITEM_NUMBER,
        COMPONENT,
        COMPONENT_DESC,
        QTY,
        QTY_UNIT,
        ORIGIN,
        TOTAL_WEIGHT,
        WEIGHT_UNITS,
        COMPONENT_COMMODITY_CODE,
        COMPONENT_ECCN,
        STANDARD_COST,
        EXT_COST,
        MAT_GROUP,
        STS_FLAG,
        PRICE::number(38,2) as PRICE,
        EXT_PRICE,
        TRANSFER_PRICE,
        EXT_TRANSFER_PRICE,
        TOTAL_EXT_TRANSFER_PRICE,
        PERCENT_TOTAL_PARTS_VALUE,
        PRICE_INCREASE,
        SALES_PRICE,
    from transform_data
)

select * from type_data