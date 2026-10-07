{{ config(
    alias = 'BOM_HEIRARCHY',
    materialized = 'tel_incremental',
    incremental_strategy = 'insert_overwrite',
) }}


with recursive stko as (
    -- gets the most recent/active bom headers
    select
        MANDT,
        STLTY,
        STLNR,
        STLAL,
        STKOZ,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_BOM_HEADER') }}
    where STLTY = 'M' 
        and STLAL = '01'
        and trim(LKENZ) = ''
    qualify row_number() over(partition by MANDT, STLTY, STLNR, STLAL order by (ANDAT, STKOZ) desc) = 1
),

stas as (
    -- for each of the active bom headers, filter for the active nodes (STLKN) ie node items that don't have a deletion indicator (LKENZ) flagged
    select 
        stas.*,
    from stko
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_BOMS_ITEM_SELECTION') }} as stas
        on stko.MANDT = stas.MANDT
        and stko.STLNR = stas.STLNR
    where stas.STLTY = 'M'
        and stas.STLAL = '01'
    qualify max(trim(stas.LKENZ)) over(partition by stas.MANDT, stas.STLTY, stas.STLNR, stas.STLAL, stas.STLKN) = ''
),

stpo as (
    -- for each of the active nodes + change numbers, get the most recent/active bom line items
    select 
        stpo.*,
    from stas
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_BOM_ITEM') }} as stpo
        on stas.MANDT = stpo.MANDT
        and stas.STLNR = stpo.STLNR
        and stas.STLKN = stpo.STLKN
        and stas.AENNR = stpo.AENNR
    where stpo.STLTY = 'M'
        and trim(stpo.LKENZ) = ''
    qualify row_number() over(partition by stpo.MANDT, stpo.STLTY, stpo.STLNR, stpo.POSNR order by (stpo.ANDAT, stpo.STLKN, stpo.STPOZ) desc) = 1
),

part_info as (
    select
        mara.MANDT,
        mara.MATNR,
        mara.MSTAE,
        mara.BRGEW,
        mara.GEWEI,
        makt.MAKTX,
        marc.WERKS,
        marc.MMSTA,
        marc.BESKZ,
        marc.SOBSL,
        marc.STAWN,
        marc.HERKL,
        maex.ALNUM,
        mast.STLNR,
        mbew.STPRS,
        mbew.PEINH,
        mvke.MVGR1,
        mara.SPART,
    from {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_GENERAL_MATERIAL_DATA') }} as mara
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_DESCRIPTIONS') }} as makt
        on mara.MATNR = makt.MATNR
        AND makt.SPRAS = 'E'
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_PLANT_DATA_FOR_MATERIAL') }} as marc
        on mara.MANDT = marc.MANDT
        and mara.MATNR = marc.MATNR
    inner join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_VALUATION') }} as mbew
        on mara.MANDT = mbew.MANDT
        and mara.MATNR = mbew.MATNR
        and marc.WERKS = mbew.BWKEY
        and mbew.BWTAR = ' '
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_MASTER_LEGAL_CONTROL') }} as maex
        on mara.MATNR = maex.MATNR
        and maex.ALAND = 'US'
        and maex.GEGRU = 'US'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_MATERIAL_TO_BOM_LINK') }} as mast
        on marc.MANDT = mast.MANDT
        and marc.WERKS = mast.WERKS
        and marc.MATNR = mast.MATNR
        and mast.STLAN = '3'
        and mast.STLAL = '01'
    left join {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__SAPO_SALES_DATA_FOR_MATERIALS') }} as mvke
        on mara.MATNR = mvke.MATNR
        and mvke.VKORG = '0010'
        and mvke.VTWEG = '10'
),

bom_list AS (
    select 
        parent_part.MANDT as CLIENT,
        parent_part.WERKS as PLANT,
        parent_part.MATNR as PARENT_PART_NUMBER,
        parent_part.MAKTX as PARENT_PART_DESC,
        parent_part.STAWN as PARENT_COMMODITY_CODE,
        parent_part.STLNR as BOM_NUMBER,
        stpo.POSNR as BOM_ITEM_NUMBER,
        child_part.MATNR as COMPONENT,
        child_part.MAKTX as COMPONENT_DESC,
        stpo.MENGE as QTY,
        stpo.MEINS as QTY_UNIT,
        child_part.HERKL as ORIGIN,
        stpo.MENGE * child_part.BRGEW as TOTAL_WEIGHT,
        child_part.GEWEI as WEIGHT_UNITS,
        child_part.STAWN as COMMODITY_CODE,
        child_part.ALNUM as ECCN,
        parent_part.STLNR || '_' || stpo.POSNR as BOM_LINEAGE,
        round(child_part.STPRS, 2) as STANDARD_COST,
        child_part.PEINH as COST_UNIT,
        round(child_part.STPRS / child_part.PEINH * stpo.MENGE, 2) as EXT_COST,
        child_part.MVGR1 as MAT_GROUP,
        child_part.SPART as DIVISION,
    from part_info as parent_part
    inner join stpo
        on parent_part.MANDT = stpo.MANDT
        and parent_part.STLNR = stpo.STLNR
    inner join part_info as child_part
        on parent_part.MANDT = child_part.MANDT
        and stpo.IDNRK = child_part.MATNR
        and parent_part.WERKS = child_part.WERKS
),

bom_tree as (
    -- starts with the basic list of parent parts and their immediate children
    select 
        CLIENT,
        PLANT,
        BOM_LINEAGE,
        1 as EXPL_LEVEL,
        PARENT_PART_NUMBER as ROOT_PART_NUMBER,
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
        COMMODITY_CODE,
        ECCN,
        STANDARD_COST,
        COST_UNIT,
        EXT_COST,
        MAT_GROUP,
        DIVISION,
        PARENT_COMMODITY_CODE = 'SEE TARIFF SHEET' as STS_FLAG,
    from bom_list

    union all

    -- recursively joins back to the bom list for each child component
    select 
        parent.CLIENT,
        child.PLANT,
        parent.BOM_LINEAGE || ' > ' || child.BOM_LINEAGE as BOM_LINEAGE,
        zeroifnull(parent.EXPL_LEVEL) + 1 as EXPL_LEVEL,
        parent.ROOT_PART_NUMBER,
        child.PARENT_PART_NUMBER,
        child.PARENT_PART_DESC,
        child.PARENT_COMMODITY_CODE,
        child.BOM_NUMBER,
        child.BOM_ITEM_NUMBER,
        child.COMPONENT,
        child.COMPONENT_DESC,
        child.QTY,
        child.QTY_UNIT,
        child.ORIGIN,
        child.TOTAL_WEIGHT,
        child.WEIGHT_UNITS,
        child.COMMODITY_CODE,
        child.ECCN,
        child.STANDARD_COST,
        child.COST_UNIT,
        child.EXT_COST,
        child.MAT_GROUP,
        child.DIVISION,
        parent.STS_FLAG and child.PARENT_COMMODITY_CODE = 'SEE TARIFF SHEET' as STS_FLAG, -- if parent wasn't a STS commodity code, then we need to flag the children as well
    from bom_tree as parent
    inner join bom_list as child
        on parent.CLIENT = child.CLIENT
        and parent.PLANT = child.PLANT
        and parent.COMPONENT = child.PARENT_PART_NUMBER
        and parent.BOM_LINEAGE != child.BOM_LINEAGE -- prevents infinite relations where the parent and child are the same item
        and parent.EXPL_LEVEL < 50 -- safe guard against unexpected/accidental infinite recursion loops
),

transform_data as (
    select 
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
        current_timestamp()::timestamp_ntz as _REFRESHDATE,
        *,
    from bom_tree
),

type_data as (
    select 
        _AUDIT_LOG_ID,
        _ROW_HASH,
        _REFRESHDATE,
        CLIENT,
        PLANT,
        BOM_LINEAGE,
        EXPL_LEVEL,
        ROOT_PART_NUMBER,
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
        COMMODITY_CODE,
        ECCN,
        STANDARD_COST,
        COST_UNIT::number(38,0) as COST_UNIT,
        EXT_COST,
        MAT_GROUP,
        DIVISION,
        STS_FLAG,
    from transform_data
)

select * from type_data

