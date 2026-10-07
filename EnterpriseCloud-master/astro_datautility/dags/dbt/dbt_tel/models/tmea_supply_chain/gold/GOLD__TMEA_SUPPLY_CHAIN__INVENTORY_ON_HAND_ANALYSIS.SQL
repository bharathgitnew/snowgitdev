{{ config(
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        alias = 'INVENTORY_ON_HAND_ANALYSIS',
        transient = false
) }}


with warehouse_stock as (
    select
        CLIENT,
        Material_Number,
        plant,
        STORAGE_LOCATION,
        Storage_Type,
        Storage_Bin,
        total_quantity,
        available_stock
    from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__QUANTS') }} as LQUA
    where IS_DELETED = 'No'
),

stock as (
    select
        S032.client,
        S032.plant ,
        S032.STORAGE_LOCATION ,
        S032.Material_Number ,
        S032.Material_Type ,
        S032.MATERIAL_GROUP ,
        S032.MRP_Type ,
        sum(s032.QUANTITY_OF_VALUATED_STOCK) over (partition by S032.plant,S032.Material_Number) as Overall_Quantity,
        s032.QUANTITY_OF_VALUATED_STOCK as Quantity_Storage_location ,
        s032.Date_Last_Receipt,
        S032.Date_last_goods_issue,
        S032.Date_last_consumption,
        S032.Date_last_goods_movement,
        S032.Safety_stock,
        case when S032.DATE_LAST_GOODS_MOVEMENT = '00000000' then 0 else   ( CURRENT_DATE - S032.DATE_LAST_GOODS_MOVEMENT) end as Aged_Inventory_in_Days
    from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__STATISTICS_CURRENT_STOCK_AND_GROUPING_TERMS') }} as S032
),

source_data as(
    select
        S032.plant ,
        S032.STORAGE_LOCATION ,
        S032.Material_Number ,
        MAKT.Material_Description ,
        S032.Material_Type ,
        S032.MATERIAL_GROUP ,
        S032.MRP_Type ,
        s032.Overall_Quantity,
        s032.Quantity_Storage_location ,
        LQUA.available_stock as warehouse_stock,
        s032.Date_Last_Receipt,
        S032.Date_last_goods_issue,
        S032.Date_last_consumption,
        S032.Date_last_goods_movement,
        S032.Safety_stock,
        marc.Safety_stock as safety_stock_master,
        MARC.Plant_Specific_Material_Status,
        MARC.Purchasing_Group,
        MARC.MRP_CONTROLLER_MATERIALS_PLANNER,
        T024D.CONTROLLER_NAME as MPR_Controller_name,
        MARC.Profit_Center,
        CEPCT.GENERAL_NAME as Profit_Center_Description,
        LQUA.Storage_Type,
        LQUA.Storage_Bin,
        MBEW.Standard_price as Standard_Cost,
        MBEW.Value_of_Total_Valuated_Stock as Value_USD,
        S032.Aged_Inventory_in_Days,
        case when s032.Overall_Quantity > marc.Safety_stock then 'X' else NULL end as Excess_Inventory_Indicator,
        case when  marc.Safety_stock >= 1 then 'X' else NULL end as Safety_Stock_Planning_Indicator
    from stock as s032
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} as makt
    on makt.Material_Number = s032.Material_Number
    and MAkt.CLIENT = S032.CLIent
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} as MARC
    on MARC.Material_Number = S032.Material_Number
    and MARC.PLANT = S032.PLANT
    and Marc.CLIENT = S032.CLIent
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} as CEPCT
    on CEPCT.Profit_Center = MARC.Profit_Center
    and CEPCT.CLIENT = S032.CLIent
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_CONTROLLERS') }} as T024D
    on T024D.plant = S032.Plant
    and T024D.MRP_CONTROLLER = MARC.MRP_CONTROLLER_MATERIALS_PLANNER
    and T024D.CLIENT = S032.CLIent
    left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} as MBEW
    on MBEW.VALUATION_AREA = S032.Plant
    and MBEW.Material_Number = S032.Material_Number
    and MBEW.CLIENT = S032.CLIent
    left join  warehouse_stock as LQUA
    on LQUA.Material_Number = S032.Material_Number
    and LQUA.CLIENT = S032.CLIent
    and LQUA.STORAGE_LOCATION = S032.STORAGE_LOCATION
    and LQUA.plant = S032.plant
    where S032.Plant = '0010' and MBEW.Valuation_Type = ' '
),

transform_data as(
    select
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') as _ROW_HASH,
        PLANT,
        STORAGE_LOCATION,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        MATERIAL_TYPE,
        MATERIAL_GROUP,
        MRP_TYPE,
        OVERALL_QUANTITY,
        QUANTITY_STORAGE_LOCATION,
        WAREHOUSE_STOCK,
        DATE_LAST_RECEIPT AS DATE_LAST_RECEIPT,
        DATE_LAST_GOODS_ISSUE AS DATE_LAST_GOODS_ISSUE,
        DATE_LAST_CONSUMPTION AS DATE_LAST_CONSUMPTION,
        DATE_LAST_GOODS_MOVEMENT AS DATE_LAST_GOODS_MOVEMENT,
        SAFETY_STOCK,
        SAFETY_STOCK_MASTER,
        PLANT_SPECIFIC_MATERIAL_STATUS,
        PURCHASING_GROUP,
        MRP_CONTROLLER_MATERIALS_PLANNER,
        MPR_CONTROLLER_NAME,
        PROFIT_CENTER,
        PROFIT_CENTER_DESCRIPTION,
        STORAGE_TYPE,
        STORAGE_BIN,
        STANDARD_COST,
        VALUE_USD,
        AGED_INVENTORY_IN_DAYS,
        EXCESS_INVENTORY_INDICATOR,
        SAFETY_STOCK_PLANNING_INDICATOR
    from source_data
),

type_data as(
    select
        cast(_AUDIT_LOG_ID as varchar(128)) as _AUDIT_LOG_ID,
        cast(_ROW_HASH as varchar(128)) as _ROW_HASH,
        cast(PLANT AS VARCHAR(16777216)) AS PLANT,
        cast(STORAGE_LOCATION AS VARCHAR(16777216)) AS STORAGE_LOCATION,
        cast(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
        cast(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        cast(MATERIAL_TYPE AS VARCHAR(16777216)) AS MATERIAL_TYPE,
        cast(MATERIAL_GROUP AS VARCHAR(16777216)) AS MATERIAL_GROUP,
        cast(MRP_TYPE AS VARCHAR(16777216)) AS MRP_TYPE,
        cast(OVERALL_QUANTITY AS NUMBER(38,10)) AS OVERALL_QUANTITY,
        cast(QUANTITY_STORAGE_LOCATION AS NUMBER(38,10)) AS QUANTITY_STORAGE_LOCATION,
        cast(WAREHOUSE_STOCK AS NUMBER(38,10)) AS WAREHOUSE_STOCK,
        cast(DATE_LAST_RECEIPT AS TIMESTAMP_NTZ(9)) AS DATE_LAST_RECEIPT,
        cast(DATE_LAST_GOODS_ISSUE AS TIMESTAMP_NTZ(9)) AS DATE_LAST_GOODS_ISSUE,
        cast(DATE_LAST_CONSUMPTION AS TIMESTAMP_NTZ(9)) AS DATE_LAST_CONSUMPTION,
        cast(DATE_LAST_GOODS_MOVEMENT AS TIMESTAMP_NTZ(9)) AS DATE_LAST_GOODS_MOVEMENT,
        cast(SAFETY_STOCK AS NUMBER(38,10)) AS SAFETY_STOCK,
        cast(SAFETY_STOCK_MASTER AS NUMBER(38,10)) AS SAFETY_STOCK_MASTER,
        cast(PLANT_SPECIFIC_MATERIAL_STATUS AS VARCHAR(16777216)) AS PLANT_SPECIFIC_MATERIAL_STATUS,
        cast(PURCHASING_GROUP AS VARCHAR(16777216)) AS PURCHASING_GROUP,
        cast(MRP_CONTROLLER_MATERIALS_PLANNER AS VARCHAR(16777216)) AS MRP_CONTROLLER_MATERIALS_PLANNER,
        cast(MPR_CONTROLLER_NAME AS VARCHAR(16777216)) AS MPR_CONTROLLER_NAME,
        cast(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
        cast(PROFIT_CENTER_DESCRIPTION AS VARCHAR(16777216)) AS PROFIT_CENTER_DESCRIPTION,
        cast(STORAGE_TYPE AS VARCHAR(16777216)) AS STORAGE_TYPE,
        cast(STORAGE_BIN AS VARCHAR(16777216)) AS STORAGE_BIN,
        cast(STANDARD_COST AS NUMBER(38,10)) AS STANDARD_COST,
        cast(VALUE_USD AS NUMBER(38,10)) AS VALUE_USD,
        cast(AGED_INVENTORY_IN_DAYS AS NUMBER(38,10)) AS AGED_INVENTORY_IN_DAYS,
        cast(EXCESS_INVENTORY_INDICATOR AS VARCHAR(16777216)) AS EXCESS_INVENTORY_INDICATOR,
        cast(SAFETY_STOCK_PLANNING_INDICATOR AS VARCHAR(16777216)) AS SAFETY_STOCK_PLANNING_INDICATOR
    from transform_data
)

SELECT * from type_data