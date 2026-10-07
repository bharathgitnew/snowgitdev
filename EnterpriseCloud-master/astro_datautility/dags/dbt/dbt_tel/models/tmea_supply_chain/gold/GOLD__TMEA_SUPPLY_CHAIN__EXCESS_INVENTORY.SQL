{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='EXCESS_INVENTORY',
    	transient=false
) }}

WITH ref_cte_HEADER_DATA_FOR_MRP_DOCUMENT as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }}
),

ref_cte_MATERIAL_DESCRIPTIONS as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }}
),

ref_cte_MATERIAL_VALUATION as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }}
),

ref_cte_MRP_TABLE as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }}
),

ref_cte_PLANT_DATA_FOR_MATERIAL as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }}
),

ref_cte_STORAGE_LOCATION_DATA_FOR_MATERIAL as (
    select * from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__STORAGE_LOCATION_DATA_FOR_MATERIAL') }}
),

source_data as (
    select
        MARD.MATERIAL_NUMBER as MATERIAL_NUMBER,
        MARD.Plant as PLANT,
        makt.material_description,
        MARC.PROCUREMENT_TYPE,
        Sum(
            BLOCKED_STOCK + valuated_unrestricted_use_stock + stock_in_quality_inspection
        ) as WH_Stock,
        sum(VALUATED_UNRESTRICTED_USE_STOCK) as UNRESTRICTED
    From
        ref_cte_STORAGE_LOCATION_DATA_FOR_MATERIAL AS MARD
        left join ref_cte_MATERIAL_DESCRIPTIONS MAKT on MARD.Material_Number = MAKT.MATERIAL_NUMBER
        left join ref_cte_PLANT_DATA_FOR_MATERIAL MARC on marc.material_number = MARD.MATERIAL_NUMBER
        AND MARC.PLANT = MARD.PLANT
    where
        MARD.Plant in ('0010', '0020')
    group BY
        MARD.MATERIAL_NUMBER,
        MARD.PLANT,
        makt.material_description,
        MARC.PROCUREMENT_TYPE
),
mrp as (
    select
        material_number,
        mdkp.plant,
        mdkp.safety_stock,
        CASE
            WHEN MATERIAL_REQUIREMENTS_PLANNING_SEGMENT = '02'
            AND RECEIPT_ISSUE_INDICATOR = '-' then QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED
        end as TOTAL_DEMAND
    From
        ref_cte_HEADER_DATA_FOR_MRP_DOCUMENT MDKP
        left join ref_cte_MRP_TABLE MDTB on MDKP.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = MDTB.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE
    where
        mdkp.plant in ('0010', '0020')
),
Final_Demand as (
    select
        distinct MRP.MATERIAL_NUMBER,
        MRP.PLANT,
        sum(TOTAL_DEMAND) as TOTAL_Demand,
        max(safety_stock) as Safety_Stock
    FROM
        mrp AS MRP
    GROUP BY
        MRP.MATERIAL_NUMBER,
        MRP.PLANT
),
material_valuation as (
    select
        distinct mv.material_number,
        mv.standard_price,
        mv.price_unit,
        mv.valuation_area,
        mv.standard_price / mv.price_unit AS net_price
    from
        ref_cte_MATERIAL_VALUATION as mv
    WHERE
        VALUATION_AREA in ('0010', '0020')
),
output as (
    select
        source_data.material_number,
        source_Data.material_description,
        final_demand.plant,
        source_Data.PROCUREMENT_TYPE,
        zeroifnull (safety_stock) as safety_stock_qty,
        zeroifnull (safety_stock_qty * net_price) as safety_stock_amount,
        zeroifnull (source_data.WH_Stock) AS WH_Stock_qty,
        zeroifnull (WH_Stock_qty * net_price) AS WH_Stock_amount,
        zeroifnull (TOTAL_Demand ) as TOTAL_Demand_QTY,
        zeroifnull (TOTAL_Demand_QTY * net_price) as TOTAL_Demand_amount,
        zeroifnull (TOTAL_Demand_QTY + safety_stock_qty) as Gross_demand_qty,
        zeroifnull (
            case
                when WH_Stock_qty >= TOTAL_Demand_QTY then WH_Stock_qty - TOTAL_Demand_QTY
            end
        ) as Total_Excess,
        zeroifnull (Total_Excess * net_price) as Total_Excess_amount,
        zeroifnull (
            case
                when WH_Stock_qty >= Gross_demand_qty then WH_Stock_qty - Gross_demand_qty 
            end
        ) as Total_Excess_SS,
        zeroifnull (
            Total_Excess_SS * net_price
        ) as Total_Excess_amount_SS
    from
        source_data as source_data
        left join final_demand as final_demand on final_demand.material_number = source_data.material_number
        and final_demand.plant = source_data.plant
        join material_valuation as material_valuation on material_valuation.material_number = source_data.MATERIAL_NUMBER
        AND MATERIAL_VALUATION.VALUATION_AREA = source_data.PLANT
),

output_data as (
SELECT distinct *
from
    output
where
    Total_Excess_AMOUNT > 0),

transform_data as (
select 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
     SHA2('hash_me') as _ROW_HASH,
     MATERIAL_NUMBER,
	MATERIAL_DESCRIPTION,
	PLANT,
	PROCUREMENT_TYPE,
	SAFETY_STOCK_QTY,
	SAFETY_STOCK_AMOUNT,
	WH_STOCK_QTY,
	WH_STOCK_AMOUNT,
	TOTAL_DEMAND_QTY,
	TOTAL_DEMAND_AMOUNT,
	GROSS_DEMAND_QTY,
	TOTAL_EXCESS,
	TOTAL_EXCESS_AMOUNT,
	TOTAL_EXCESS_SS,
	TOTAL_EXCESS_AMOUNT_SS
 
from output_data
),
type_data as (
     SELECT   _AUDIT_LOG_ID,
        _ROW_HASH,
        material_number,
        material_description,
        plant,
        PROCUREMENT_TYPE,
        CAST (safety_stock_qty as number(32, 2)) as safety_stock_qty,
        CAST (safety_stock_amount AS NUMBER(32, 2)) as safety_stock_amount,
        CAST (WH_Stock_qty AS NUMBER(31, 2)) AS WH_Stock_qty,
        CAST (WH_Stock_amount AS NUMBER(32, 2)) AS WH_Stock_amount,
        CAST (TOTAL_Demand_QTY AS NUMBER(32, 2)) as TOTAL_Demand_QTY,
        CAST (TOTAL_Demand_amount AS NUMBER(32, 2)) as TOTAL_Demand_amount,
        CAST (Gross_demand_qty AS NUMBER(32, 2)) as Gross_demand_qty,
        CAST (Total_Excess AS NUMBER(32, 2)) as Total_Excess,
        CAST(Total_Excess_amount AS NUMBER(32, 2)) as Total_Excess_amount,
        CAST(Total_Excess_SS AS NUMBER(32, 2))as Total_Excess_SS,
        CAST(Total_Excess_amount_SS AS NUMBER(32, 2)) as Total_Excess_amount_SS  
        from  transform_data
)

select * from type_data