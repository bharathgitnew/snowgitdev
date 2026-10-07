{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='MATERIAL_DEMAND_LOCATION_REPORT',
      transient=false
) }}


with Mrp_data as (
    SELECT
        MDKP.plant,
        MDKP.MATERIAL_NUMBER,sum(case when MDTB.RECEIPT_ISSUE_INDICATOR = '+' then MDTB.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED else MDTB.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED * -1 end) as Qty
    From {{ ref('SILVER__TMEA_MANUFACTURING__HEADER_DATA_FOR_MRP_DOCUMENT') }} MDKP
    left join {{ ref('SILVER__TMEA_MANUFACTURING__MRP_TABLE') }} as MDTB
    on MDTB.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = MDKP.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE
    where MDTB.RECEIPT_REQUIREMENTS_DATE >= current_date
    and MDTB.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED > 0
    and MDTB.MRP_ELEMENT = 'SB'
    group by MDKP.plant,MDKP.MATERIAL_NUMBER
),

source_data as (
    select
        LQUA.WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX as Warehouse,
        LQUA.STORAGE_TYPE as St_Type,
        LQUA.STORAGE_BIN as St_Bin,
        MARC.plant as plant ,
        MARC.material_number as Material,
        makt.MATERIAL_DESCRIPTION as Material_Desc,
        case when MARC.MRP_Type = 'V1' then 'X' else '' end as Bulk_Flag,
        LQUA.DATE_OF_GOODS_RECEIPT as Bin_Placement_Date,
        case when Mrp_data.Qty != 0 then Mrp_data.Qty else 0 end as Demand_Qty
    from {{ ref('SILVER__TMEA_MANUFACTURING__PLANT_DATA_FOR_MATERIAL') }} as MARC
    left join {{ ref('SILVER__TMEA_MANUFACTURING__QUANTS') }} as LQUA
    on LQUA.plant = MARC.plant
    and LQUA.Material_number = MARC.Material_number
    left join Mrp_data as Mrp_data
    on Mrp_data.plant = marc.plant and Mrp_data.MATERIAL_NUMBER = marc.Material_number
    left join {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_DESCRIPTIONS') }} as MAKT
    on MARC.material_number = MAKt.material_number
    where MARC.plant = '0010'
    and LQUA.WAREHOUSE_NUMBER_WAREHOUSE_COMPLEX = '010'
    and LQUA.IS_DELETED ='No'
),

transform_data as (
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	    SHA2('hash_me') AS _ROW_HASH,
        WAREHOUSE,
        ST_TYPE,
        ST_BIN,
        PLANT ,
        MATERIAL,
        MATERIAL_DESC,
        BULK_FLAG,
        BIN_PLACEMENT_DATE,
        DEMAND_QTY
    from source_data
),

type_date as (
    select
        CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
        CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        cast(WAREHOUSE AS VARCHAR(16777216) ) AS WAREHOUSE,
        cast(ST_TYPE AS VARCHAR(16777216) ) AS ST_TYPE,
        cast(ST_BIN AS VARCHAR(16777216) ) AS ST_BIN,
        cast(PLANT  AS VARCHAR(16777216) ) AS PLANT ,
        cast(MATERIAL AS VARCHAR(16777216) ) AS MATERIAL,
        cast(MATERIAL_DESC AS VARCHAR(16777216) ) AS MATERIAL_DESC,
        cast(BULK_FLAG AS VARCHAR(16777216) ) AS BULK_FLAG,
        cast(BIN_PLACEMENT_DATE AS DATE ) AS BIN_PLACEMENT_DATE,
        cast(DEMAND_QTY AS NUMBER(38,10) ) AS DEMAND_QTY
    from transform_data
)

select * from type_date