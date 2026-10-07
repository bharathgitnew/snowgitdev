{{ config(
      materialized='tel_incremental',
      incremental_strategy='insert_overwrite',
      alias='KEY_COMPONENTS_MAIN',
      transient=false
) }}

with eord_cte as(
    select *
    from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_SOURCE_LIST') }}
    where lower(INDICATOR_FIXED_VENDOR) = 'x' and plant = '0010' and client = '300'
    qualify(row_number() over(partition by material_number, plant order by SOURCE_LIST_USAGE_IN_MATERIALS_PLANNING desc, SOURCE_LIST_RECORD_VALID_FROM desc)) = 1
)
,

source_data as (
    select
        MARC.Material_Number,
        MARC.Plant,
        MARC.Planned_Delivery_Time_in_Days,
        MARC.ABC_Indicator,
        MARC.Purchasing_Group,
        MARC.MRP_Type,
        MARC.Procurement_Type,
        MARC.Reorder_Point,
        MARC.Safety_Stock,
        MARC.Minimum_Lot_Size,
        MARC.Maximum_stock_level,
        MARC.Profit_Center,
        cepct.General_Name as GENERAL_NAME,
        MARC.Indicator_Bulk_Material,
        EORD.SOURCE_LIST_RECORD_VALID_TO,
        EORD.VENDORS_ACCOUNT_NUMBER,
        EORD.INDICATOR_FIXED_VENDOR,
        EORD.PURCHASING_ORGANIZATION,
        LFA1.NAME_1,
        MAKT.LANGUAGE_KEY,
        MAKT.MATERIAL_DESCRIPTION,
        MARA.Base_Unit_of_Measure,
        MARA.Material_Group,
        MARA.Cross_Plant_Material_Status,
        T023T.LANGUAGE_KEY as LANGUAGE,
        T023T.MATERIAL_GROUP_DESCRIPTION as MATL_GRP_DESC,
        T024.DESCRIPTION_OF_PURCHASING_GROUP,
        MBEW.Valuation_Area,
        MBEW.Valuation_Type,
        MBEW.Standard_price
    from  {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} marc
    left join eord_cte eord
    on marc.Material_Number = eord.MATERIAL_NUMBER and marc.Plant = eord.PLANT
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__VENDOR_MASTER') }} lfa1
    on eord.VENDORS_ACCOUNT_NUMBER = lfa1.ACCOUNT_NUMBER_OF_VENDOR_OR_CREDITOR
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} makt
    on marc.Material_Number = makt.MATERIAL_NUMBER
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }} mara
    on marc.Material_Number = mara.Material_Number
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_GROUP_DESCRIPTIONS') }} t023t
    on mara.Material_Group = t023t.MATERIAL_GROUP
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} t024
    on marc.Purchasing_Group = t024.PURCHASING_GROUP
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} mbew
    on marc.Material_Number = mbew.Material_Number and marc.plant = mbew.valuation_area
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} cepct
    on marc.Profit_Center = cepct.Profit_Center
    where marc.Material_Number is not null
    and marc.plant = '0010'
    and mbew.valuation_type = ' '
    and marc.client = '300'
    and mbew.client = '300'
    and mara.client = '300'
    and lfa1.client = '300'
    and makt.client = '300'
    and t023t.client = '300'
    and t024.client = '300'
    and cepct.client = '300' 

),

transform_data as
(
    select '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH ,
        * 
        from source_data
)

,type_data as (
    SELECT
         cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
        CAST(PLANT AS VARCHAR(16777216)) AS PLANT,
        CAST(PLANNED_DELIVERY_TIME_IN_DAYS AS NUMBER(38,10)) AS PLANNED_DELIVERY_TIME_IN_DAYS,
        CAST(ABC_INDICATOR AS VARCHAR(16777216)) AS ABC_INDICATOR,
        CAST(PURCHASING_GROUP AS VARCHAR(16777216)) AS PURCHASING_GROUP,
        CAST(MRP_TYPE AS VARCHAR(16777216)) AS MRP_TYPE,
        CAST(PROCUREMENT_TYPE AS VARCHAR(16777216)) AS PROCUREMENT_TYPE,
        CAST(REORDER_POINT AS NUMBER(38,10)) AS REORDER_POINT,
        CAST(SAFETY_STOCK AS NUMBER(38,10)) AS SAFETY_STOCK,
        CAST(MINIMUM_LOT_SIZE AS NUMBER(38,10)) AS MINIMUM_LOT_SIZE,
        CAST(MAXIMUM_STOCK_LEVEL AS NUMBER(38,10)) AS MAXIMUM_STOCK_LEVEL,
        CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
        CAST(GENERAL_NAME AS VARCHAR(16777216)) AS GENERAL_NAME,
        CAST(INDICATOR_BULK_MATERIAL AS VARCHAR(16777216)) AS INDICATOR_BULK_MATERIAL,
        CAST(SOURCE_LIST_RECORD_VALID_TO AS DATE) AS VALID_TO,
        CAST(VENDORS_ACCOUNT_NUMBER AS VARCHAR(16777216)) AS SUPPLIER,
        CAST(INDICATOR_FIXED_VENDOR AS VARCHAR(16777216)) AS FIXED_VENDOR,
        CAST(PURCHASING_ORGANIZATION AS VARCHAR(16777216)) AS PURCHASING_ORG,
        CAST(NAME_1 AS VARCHAR(105)) AS NAME_1,
        CAST(LANGUAGE_KEY AS VARCHAR(16777216)) AS LANGUAGE_KEY,
        CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        CAST(BASE_UNIT_OF_MEASURE AS VARCHAR(9)) AS BASE_UNIT_OF_MEASURE,
        CAST(MATERIAL_GROUP AS VARCHAR(27)) AS MATERIAL_GROUP,
        CAST(CROSS_PLANT_MATERIAL_STATUS AS VARCHAR(6)) AS CROSS_PLANT_MATERIAL_STATUS,
        CAST(LANGUAGE AS VARCHAR(16777216)) AS LANGUAGE,
        CAST(MATL_GRP_DESC AS VARCHAR(16777216)) AS MATL_GRP_DESC,
        CAST(DESCRIPTION_OF_PURCHASING_GROUP AS VARCHAR(54)) AS DESCRIPTION_OF_PURCHASING_GROUP,
        CAST(VALUATION_AREA AS VARCHAR(16777216)) AS VALUATION_AREA,
        CAST(VALUATION_TYPE AS VARCHAR(16777216)) AS VALUATION_TYPE,
        CAST(STANDARD_PRICE AS NUMBER(38,10)) AS STANDARD_PRICE
    FROM transform_data
)

SELECT * from type_data