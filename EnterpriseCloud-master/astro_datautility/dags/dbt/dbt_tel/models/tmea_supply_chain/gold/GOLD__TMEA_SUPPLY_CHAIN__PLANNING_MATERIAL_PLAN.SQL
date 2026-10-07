{{ config(
    materialized='tel_incremental',
	incremental_strategy='insert_overwrite',
    alias='PLANNING_MATERIAL_PLAN',
    transient=false
) }}


With main as (
    select
        MARC.material_number,
        MARC.procurement_type,
        MBEW.standard_price,
        MBEW.price_unit,
        MBEW.standard_price / MBEW.price_unit as NET_price,
        MBEW.valuation_area,
        MARC.PLANT,
        MARA.cross_plant_material_status,
        MAKT.material_description,
        MARA.material_group,
        T023T.material_group_description,
        MARA.base_unit_of_measure,
        MARA.purchase_order_unit_of_measure,
        MARC.abc_indicator,
        MARC.purchasing_group,
        T024.description_of_purchasing_group,
        MARC.mrp_type,
        MARC.planned_delivery_time_in_days as lead_Time,
        MARC.goods_receipt_processing_time_in_days,
        MARC.reorder_point,
        MARC.safety_stock,
        MARC.minimum_lot_size,
        MARC.base_quantity,
        MARC.profit_center,
        prof.general_name as profit_center_description,
    from
        {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} as marc
        LEFT join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} as MBEW on MBEW.material_number = marc.material_number
        and marc.plant = MBEW.valuation_area
        LEFT join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }} AS MARA on MARA.material_number = marc.material_number
        left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} as MAKT on MAKT.material_number = marc.material_number
        left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_GROUP_DESCRIPTIONS') }} as T023T on T023T.material_group = MARA.material_group
        left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} as prof on prof.profit_center = MARC.profit_center
        left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} as T024 on T024.purchasing_group = MARC.purchasing_group
    where
        T024.SPOOL_OUTPUT_DEVICE = 'EMAI'
        and MARC.PLANT = '0010'
        and valuation_area = '0010'
        and procurement_type = 'F'
),
--// extracting 12 months comsumption data by material number
Consumption as (
    select
        MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT,
        MSEG.material_number,
        MSEG.NUMBER_OF_MATERIAL_DOCUMENT,
        MSEG.item_in_material_document,
        MSEG.MATERIAL_DOCUMENT_YEAR,
        MONTHNAME(MSEG.posting_date_in_the_document) as Month_Name,
        MSEG.posting_date_in_the_document,
        dateadd(day, - day(getdate()), getdate()) AS LASTmONTH,
        DATEADD(month, -12, LASTmONTH) as firstMonth,
        case
            WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN QUANTITY * -1
            else MSEG.QUANTITY
        end as TOTAL_CONSUMPTION
    from
        {{ ref('SILVER__TMEA_SUPPLY_CHAIN__DOCUMENT_SEGMENT_MATERIAL') }} as MSEG
    where
        MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT in (
            '201',
            '261',
            '601',
            '991',
            '992',
            '202',
            '262',
            '963'
        )
        and MSEG.posting_date_in_the_document > '2019-12-31'
        and MSEG.posting_date_in_the_document between firstMonth
        and LASTmONTH --//and material_number = '316860-050'
),
--// aggregating consumption data by material number
Total_consumption as (
    select
        Consumption.MATERIAL_DOCUMENT_YEAR,
        Consumption.material_number as material_number,
        sum(Consumption.TOTAL_CONSUMPTION) as total_qty_Issued
    from
        Consumption as Consumption
    group by
        Consumption.material_number,
        Consumption.MATERIAL_DOCUMENT_YEAR,
        Month_Name
),
final_consumption as (
    select
        material_number,
        sum(total_qty_Issued) as Total_12_Consumption,
        stddev(total_qty_Issued) as Total_12_Consumption_STDV,
        Total_12_Consumption / 12 AS AVG_12_month_Consumption
    from
        Total_consumption as Total_consumption
    group by
        material_number
),
--//Extracting next 6 Months demand
MRP_DATA AS(
    SELECT
        distinct HDMD.MRP_DATE,
        SMT.RECEIPT_REQUIREMENTS_DATE,
        SMT.MRP_ELEMENT,
        SMT.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED,
        SMT.MRP_ELEMENT_NUMBER,
        SMT.MATERIAL_NUMBER_OF_HIGHER_LEVEL_ASSEMBLY,
        HDMD.MATERIAL_NUMBER,
        HDMD.PLANT,
        cast (HDMD.SAFETY_STOCK * -1 as number(32, 10)) as SAFETY_STOCK,
        HDMD.PLANT_STOCK_ONLY_PLANT_SEGMENT,
        CASE
            WHEN MATERIAL_REQUIREMENTS_PLANNING_SEGMENT = '02'
            AND RECEIPT_ISSUE_INDICATOR = '-' then QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED
        end as DEMAND,
        dateadd(
            DAY,
            30.4167,
            dateadd(day, - day(current_date()), current_date())
        ) AS FirstMonth,
        dateadd(month, + 6, FirstMonth) as LastMonth
    FROM
        {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }} as SMT
        join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }} as HDMD on HDMD.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = smt.number_of_material_requirements_planning_table
        join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} as pdm on pdm.material_number = HDMD.material_number
        and pdm.plant = HDMD.plant
        and SMT.RECEIPT_REQUIREMENTS_DATE between FirstMonth
        and LastMonth
        and pdm.plant in('0010')
        and pdm.procurement_type = 'F'
),
Final_Demand as (
    select
        distinct MRP_DATA.MATERIAL_NUMBER,
        sum(DEMAND) as TOTAL_Demand,
        TOTAL_Demand / 6 as AVG_12_month_Demand,
        stddev(DEMAND) as Total_DEMAND_STDV
    FROM
        mrp_DATA AS MRP_DATA
    GROUP BY
        MRP_DATA.MATERIAL_NUMBER
),
--// Extraction Open purchase orders
open_po as(
    select
        POA.material_number,
        zeroifnull(sum(POA.open_gr)) as OPEN_PO_QTY,
        zeroifnull(COUNT(POA.PURCHASING_DOCUMENT_NUMBER)) AS Total_Open_PO
    FROM
        {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_ORDER_METRIC_OPEN_AGING') }} as POA //where material_number = '318926-005'
    group by
        POA.material_number
),
// Extracting Inventory on hand
Stock as (
    select
        wtm.material_number,
        sum(wtm.unrestricted) as WAREHOUSE_STOCK
    from
        {{ ref('GOLD__TMEA_SUPPLY_CHAIN__DISPLAY_WAREHOUSE_STOCKS_OF_MATERIALS') }} as wtm
    where
        wtm.storage_location = '0010'
    group by
        wtm.material_number
),
--// Extracting inspection rejection history
inspection as (
    select
        MSEG.material_number,
        MSEG.TOTAL_CONSUMPTION,
        dateadd(day, - day(getdate()), getdate()) AS LASTmONTH,
        DATEADD(month, -18, LASTmONTH) as firstMonth,
        case
            when MOVEMENT_TYPE_INVENTORY_MANAGEMENT = '958' then 'Inspection Reject'
            when MOVEMENT_TYPE_INVENTORY_MANAGEMENT = '350' then 'Floor Reject'
            else MOVEMENT_TYPE_INVENTORY_MANAGEMENT
        end as MOVEMENT_TYPE_INVENTORY_MANAGEMENT
    from
        {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DOCUMENT_LIST') }} as MSEG
    where
        MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT in ('350', '958')
        and MSEG.posting_date_in_the_document > '2019-12-31'
        and MSEG.posting_date_in_the_document between firstMonth
        and LASTmONTH
),
Total_Inspection as (
    select
        inspection.material_number,
        sum(inspection.TOTAL_CONSUMPTION) as Total_Reject
    from
        inspection as inspection
    group by
        inspection.material_number
),
--// Extracting price unit by material number
material_valuation as (
    select
        MBEW.material_number,
        MBEW.standard_price,
        MBEW.price_unit
    from
        {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} as MBEW
    where
        valuation_area = '0010'
),
vendor_perf as (
    select
        vp.material,
        vp.RECEIPT_DATE,
        vp.NEED_DATE,
        vp.RECEIPT_DATE,
        MONTHNAME(vp.RECEIPT_DATE) as Month_Name,
        datediff(day, vp.NEED_DATE, vp.RECEIPT_DATE) as Commit_Days_DIFF,
        datediff(day, vp.PO_CREATE_DATE, vp.RECEIPT_DATE) as PO_Cycle_Time,
        dateadd(day, - day(getdate()), getdate()) AS LASTmONTH,
        DATEADD(month, -18, LASTmONTH) as firstMonth
    from
        {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_VENDOR_PERFORMANCE') }} as vp
    where
        vp.receipt_date > '2019-12-31'
        and vp.receipt_date between firstMonth
        and LASTmONTH
),
totals_vendor_perf as (
    select
        vendor_perf.material,
        vendor_perf.month_Name,
        avg(Commit_Days_DIFF) as AVg_Days_Late,
        PO_Cycle_Time
    from
        vendor_perf as vendor_perf
    group by
        vendor_perf.material,
        Month_Name,
        PO_Cycle_Time
),
Final_totals_vendor_perf as (
    select
        totals_vendor_perf.material,
        stddev(totals_vendor_perf.PO_CYCLE_TIME) as lEADTIME_STDV,
        avg(totals_vendor_perf.PO_CYCLE_TIME) as PO_CYCLE_TIME_AVG,
        avg(totals_vendor_perf.AVg_Days_Late) as AVg_Days_Late,
        max(totals_vendor_perf.PO_CYCLE_TIME) as PO_CYCLE_TIME_MAX,
        min(totals_vendor_perf.PO_CYCLE_TIME) as PO_CYCLE_TIME_MIN,
        MODE(totals_vendor_perf.PO_CYCLE_TIME) as PO_CYCLE_TIME_MODE,
        MEDIAN (totals_vendor_perf.PO_CYCLE_TIME) as PO_CYCLE_TIME_MEDIAN,
        lEADTIME_STDV / 30.5 as lEADTIME_STDV_month
    from
        totals_vendor_perf as totals_vendor_perf
    group by
        totals_vendor_perf.material
),
machine_down as (
    select
        slm.material_number,
        count (distinct slm.SALES_DOCUMENT) as Total_machine_Down,
        SUM(slm.ACTUAL_QUANTITY_DELIVERED_IN_SALES_UNITS) as Total_machine_Down_QTY,
        dateadd(day, - day(getdate()), getdate()) AS LASTmONTH,
        DATEADD(month, -18, LASTmONTH) as firstMonth,
    from
        {{ ref('GOLD__TMEA_SUPPLY_CHAIN__SPARES_LINE_ITEM') }} as slm
    where
        slm.SALES_DOCUMENT_TYPE in ('ZHOT', 'ZSPR')
        AND PRIORITY = 'Emergency'
    group by
        slm.material_number
),
final as(
    select
        Main.material_number,
        Main.procurement_type,
        Main.standard_price,
        Main.price_unit,
        Main.standard_price / Main.price_unit as NET_price,
        Main.valuation_area,
        Main.PLANT,
        Main.cross_plant_material_status,
        Main.material_description,
        Main.material_group,
        Main.material_group_description,
        Main.base_unit_of_measure,
        Main.purchase_order_unit_of_measure,
        Main.abc_indicator,
        Main.purchasing_group,
        Main.description_of_purchasing_group,
        Main.mrp_type,
        Main.lead_Time,
        Main.goods_receipt_processing_time_in_days,
        Main.reorder_point,
        Main.safety_stock,
        Main.minimum_lot_size,
        Main.base_quantity,
        Main.profit_center,
        Main.profit_center_description,
        Total_12_Consumption,
        Total_machine_Down_QTY,
        Total_machine_Down,
        zeroifnull (TOTAL_Demand) as TOTAL_Demand,
        zeroifnull(Total_12_Consumption) + zeroifnull(TOTAL_Demand) as Total_Cons_and_demand,
        Total_12_Consumption_STDV,
        Total_DEMAND_STDV,
        zeroifnull (WAREHOUSE_STOCK) as WAREHOUSE_STOCK,
        Zeroifnull(Total_Reject) as Total_Reject,
        AVg_Days_Late,
        Zeroifnull(Total_Open_PO) as Total_Open_PO,
        PO_CYCLE_TIME_MIN,
        PO_CYCLE_TIME_MAX,
        zeroifnull(PO_CYCLE_TIME_AVG) as PO_CYCLE_TIME_AVG,
        PO_CYCLE_TIME_MODE,
        PO_CYCLE_TIME_MEDIAN,
        zeroifnull(lEADTIME_STDV) as lEADTIME_STDV,
        zeroifnull (OPEN_PO_QTY) as Total_OPEN_PO_QTY,
        --//zeroifnull(WAREHOUSE_STOCK+ Total_OPEN_PO_QTY) as Inv_Position,
        ROUND(Total_Cons_and_demand *(1 + 0.05), 2) AS Annual_Usage,
        ROUND (Annual_Usage /(78 * 5), 4) AS Daily_Usage,
        CASE
            WHEN Total_12_Consumption_STDV > 0
            and Total_Cons_and_demand > 0 then ROUND (
                Total_12_Consumption_STDV / Total_Cons_and_demand,
                3
            )
            else.10
        END AS Demand_Variation,
        ROUND(lead_Time * Daily_Usage, 2) AS Cycle_stock,
        ROUND(Demand_Variation * Cycle_stock, 2) AS Buffer_Stock,
        NET_PRICE * 0.21 AS Unit_Holding_Cost,
        CASE
            WHEN Unit_Holding_Cost > 0
            and Annual_Usage > 0 then Sqrt(2 *(Annual_Usage * 20) / Unit_Holding_Cost)
            else 0
        END AS Optimal_Order_Quantity,
        CASE
            WHEN AVg_Days_Late > 7 then div0(AVg_Days_Late, MAIN.Lead_Time)
            else 0
        END AS Supplier_delivery_Risk_Variance,
        CASE
            WHEN Total_Reject > 0
            and Total_Open_PO > 0 then Total_Reject / Total_Open_PO
            else 0
        END AS Supplier_Quality_Risk_Variance,
        (Supplier_Quality_Risk_Variance * 0.40) +(Supplier_delivery_Risk_Variance * 0.60) AS Supplier_Risk_Variation,
        CASE
            WHEN (
                Cycle_stock + Buffer_Stock + Supplier_Risk_Variation * Cycle_stock
            ) <= 0 then 0
            else CEIL(
                Cycle_stock + Buffer_Stock + Supplier_Risk_Variation * Cycle_stock,
                0
            )
        END AS Rec_Safety_Stock,
        zeroifnull(ceil(Daily_Usage * lead_Time) + Rec_Safety_Stock) AS rec_rop,
        CASE
            WHEN MAIN.minimum_lot_size = 0 then 0
            WHEN MAIN.minimum_lot_size > 0
            and Optimal_Order_Quantity > MAIN.minimum_lot_size then Round(
                Optimal_Order_Quantity / MAIN.minimum_lot_size,
                0
            ) * MAIN.minimum_lot_size
            WHEN Optimal_Order_Quantity < MAIN.minimum_lot_size then Round (MAIN.minimum_lot_size)
            WHEN Optimal_Order_Quantity = MAIN.minimum_lot_size then MAIN.minimum_lot_size
            else MAIN.minimum_lot_size
        END AS Actual_Order_Quantity,
        (Rec_ROP + Actual_Order_Quantity) -(pO_CYCLE_TIME_AVG * Daily_Usage) AS Max_Inventory_Qty,
        Net_Price * WAREHOUSE_STOCK AS Current_Cost,
        case
            when Daily_usage > 0 then div0(WAREHOUSE_STOCK, Daily_Usage)
            else 0
        end as Actual_DOH,
        (Actual_order_Quantity / 2) + Rec_Safety_Stock as Avg_Inventory_Qty,
        case
            when Daily_usage > 0 then div0(Avg_Inventory_Qty, Daily_Usage)
            else 0
        end as avg_DOH,
        (Actual_Order_Quantity / 2 + Rec_Safety_Stock) * Net_Price as Avg_Inventory_Amount,
        Current_Cost - Avg_Inventory_amount as Difference,
        Max_Inventory_Qty * Net_Price as Max_Amount,
        WAREHOUSE_STOCK + TOTAL_OPEN_PO_QTY AS INV_POSITION,
        CASE
            WHEN MRP_TYPE = 'V1'
            and reorder_point > 0
            AND REC_ROP > 0 then (
                ((Rec_ROP - reorder_point) / reorder_point) * 100
            ) / 100
        END AS ROP_DELTA,
        CASE
            WHEN MRP_TYPE IN ('V1', 'PD')
            and Main.SAFETY_STOCK > 0 then (
                (
                    (Rec_Safety_Stock - Main.Safety_Stock) / Main.Safety_Stock
                ) * 100
            ) / 100
            else 1
        END AS SAFETY_STOCK_DELTA,
        CASE
            WHEN MRP_TYPE = 'V1'
            and REC_ROP = 0 THEN 'REC ROP = 0'
            WHEN MRP_TYPE = 'V1'
            and ROP_DELTA between -0.05
            and 0.05 then 'Within 5% ROP Delta'
            WHEN MRP_TYPE = 'V1'
            and ROP_DELTA < -0.05
            OR ROP_DELTA > 0.05 then 'REVIEW REC ROP'
            ELSE 'NA'
        END AS ROP_STATUS,
        CASE
            WHEN REC_SAFETY_STOCK = 0 then 'REC SS = 0'
            WHEN SAFETY_STOCK_DELTA between -0.05
            and 0.05 then 'Within 5% SS Delta'
            WHEN SAFETY_STOCK_DELTA < -0.05
            OR SAFETY_STOCK_DELTA > 0.05 then 'REVIEW REC SS'
        END AS SAFETY_STOCK_STATUS,
        CASE
            WHEN MRP_TYPE = 'V1'
            AND INV_POSITION - REC_ROP >= 0 THEN 'INV POSITION AT OR ABOVE REC ROP'
            WHEN MRP_TYPE = 'V1'
            AND INV_POSITION - REC_ROP < 0 THEN 'INV POSITION BELOW REC ROP'
            WHEN MRP_TYPE = 'V1'
            AND INV_POSITION - REC_SAFETY_STOCK >= 0 THEN 'INV POSITION AT OR ABOVE REC SS'
            WHEN MRP_TYPE = 'V1'
            AND INV_POSITION - REC_SAFETY_STOCK < 0 THEN 'INV POSITION BELOW REC SS'
            WHEN MRP_TYPE = 'PD'
            AND INV_POSITION - REC_SAFETY_STOCK >= 0 THEN 'INV POSITION AT OR ABOVE REC SS'
            WHEN MRP_TYPE = 'PD'
            AND INV_POSITION - REC_SAFETY_STOCK < 0 THEN 'INV POSITION BELOW REC SS'
        END AS INV_STATUS
    from
        main as main
        left join open_po as open_po on open_po.material_number = main.material_number
        left join final_consumption as final_consumption on final_consumption.material_number = main.material_number
        left join Stock as Stock on Stock.material_number = main.material_number
        left join Total_Inspection as Total_Inspection on Total_Inspection.material_number = main.material_number
        left join Final_totals_vendor_perf as Final_totals_vendor_perf on Final_totals_vendor_perf.material = main.material_number
        left join material_valuation as material_valuation on material_valuation.material_number = main.material_number
        left join Final_Demand as Final_Demand on Final_Demand.material_number = main.material_number
        left join machine_down as md on md.material_number = main.material_number
),
Type_data1 as (
    select
        CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
        CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
        -- VENDOR_NUMBER,
        -- VENDOR_NAME,
        CAST(PROCUREMENT_TYPE AS VARCHAR(16777216)) AS PROCUREMENT_TYPE,
        CAST(LEAD_TIME AS NUMBER(38, 0)) AS LEAD_TIME,
        CAST(NET_price AS DECIMAL (38, 2)) AS STANDARD_PRICE,
        CAST(valuation_area AS VARCHAR(16777216)) AS VALUATION_AREA,
        CAST(PLANT AS VARCHAR(16777216)) AS PLANT,
        CAST(cross_plant_material_status AS VARCHAR(16777216)) AS cross_plant_material_status,
        CAST(material_group AS VARCHAR(16777216)) AS material_group,
        CAST(material_group_description AS VARCHAR(16777216)) AS material_group_description,
        CAST(abc_indicator AS VARCHAR(16777216)) AS abc_indicator,
        CAST(purchasing_group AS VARCHAR(16777216)) AS purchasing_group,
        CAST(
            description_of_purchasing_group AS VARCHAR(16777216)
        ) AS description_of_purchasing_group,
        CAST(mrp_type AS VARCHAR(16777216)) AS mrp_type,
        Rec_Safety_Stock,
        ZEROIFNULL(CAST(safety_stock AS DECIMAL (38, 2))) AS SAP_safety_stock,
        ZEROIFNULL(CAST(SAFETY_STOCK_DELTA AS NUMBER(32, 2))) AS SAFETY_STOCK_DELTA,
        ZEROIFNULL(CAST(reorder_point AS DECIMAL (38, 2))) AS SAP_reorder_point,
        ZEROIFNULL(CAST(rec_rop AS DECIMAL (38, 2))) AS rec_reorder_point,
        ZEROIFNULL(CAST (ROP_DELTA AS DECIMAL (38, 2))) AS ROP_DELTA,
        ZEROIFNULL(CAST(minimum_lot_size AS DECIMAL (38, 2))) AS minimum_lot_size,
        CAST(profit_center AS NUMBER(38, 0)) AS profit_center,
        CAST(profit_center_description AS VARCHAR(16777216)) AS profit_center_description,
        zeroifnull (cast(Total_12_Consumption as integer)) as Total_12_Consumption,
        zeroifnull (cast(Total_Cons_and_demand as integer)) as Total_Cons_and_demand,
        zeroifnull (cast(TOTAL_Demand as integer)) as TOTAL_Demand,
        zeroifnull (cast(Total_machine_Down_QTY as integer)) as Total_18month_machine_Down_QTY,
        zeroifnull (cast(Total_machine_Down as integer)) as Total_machine_Down,
        ZEROIFNULL(
            CAST(Total_12_Consumption_STDV AS DECIMAL (38, 2))
        ) AS Total_12_Consumption_STDV,
        Total_DEMAND_STDV,
        ZEROIFNULL(CAST(WAREHOUSE_STOCK AS DECIMAL (38, 2))) AS WAREHOUSE_STOCK,
        ZEROIFNULL(CAST(Total_Reject AS DECIMAL (38, 2))) AS Total_Reject,
        ZEROIFNULL(CAST(AVg_Days_Late AS NUMBER(38, 2))) AS AVg_Days_Late,
        ZEROIFNULL (CAST(Total_Open_PO AS NUMBER(38, 2))) AS Total_Open_PO,
        ZEROIFNULL(CAST(PO_CYCLE_TIME_MIN AS NUMBER(38, 0))) AS PO_CYCLE_TIME_MIN,
        ZEROIFNULL(CAST(PO_CYCLE_TIME_MAX AS NUMBER(38, 0))) AS PO_CYCLE_TIME_MAX,
        ZEROIFNULL(CAST(PO_CYCLE_TIME_AVG AS NUMBER(38, 0))) AS PO_CYCLE_TIME_AVG,
        ZEROIFNULL(CAST(PO_CYCLE_TIME_MODE AS NUMBER(38, 0))) AS PO_CYCLE_TIME_MODE,
        ZEROIFNULL(CAST(PO_CYCLE_TIME_MEDIAN AS NUMBER(38, 0))) AS PO_CYCLE_TIME_MEDIAN,
        ZEROIFNULL(CAST(lEADTIME_STDV AS DECIMAL (38, 2))) AS lEADTIME_STDV,
        ZEROIFNULL(CAST(Total_OPEN_PO_QTY AS DECIMAL (38, 2))) AS Total_OPEN_PO_QTY,
        ZEROIFNULL(CAST(Annual_Usage AS DECIMAL (38, 2))) AS Annual_Usage,
        ZEROIFNULL(CAST(Daily_Usage AS DECIMAL (38, 2))) AS Daily_Usage,
        ZEROIFNULL(CAST(Demand_Variation AS DECIMAL (38, 2))) AS Demand_Variation,
        ZEROIFNULL(Cycle_stock) AS Cycle_stock,
        ZEROIFNULL(Buffer_Stock) AS Buffer_Stock,
        ZEROIFNULL(CAST(Unit_Holding_Cost AS DECIMAL (38, 2))) AS Unit_Holding_Cost,
        ZEROIFNULL(CAST(Optimal_Order_Quantity AS DECIMAL (38, 2))) AS Optimal_Order_Quantity,
        ZEROIFNULL(
            CAST(Supplier_delivery_Risk_Variance AS NUMBER(32, 2))
        ) AS Supplier_delivery_Risk_Variance,
        ZEROIFNULL(CAST(Supplier_Risk_Variation AS NUMBER (32, 2))) AS Supplier_Risk_Variation,
        Actual_Order_Quantity,
        ZEROIFNULL(CAST(Max_Inventory_Qty AS NUMBER(32, 2))) AS Max_Inventory_Qty,
        ZEROIFNULL(CAST(Current_Cost AS NUMBER(32, 2))) AS Current_Cost,
        ZEROIFNULL(CAST(Actual_DOH AS NUMBER(32, 2))) AS Actual_DOH,
        Avg_Inventory_Qty,
        ZEROIFNULL(CAST(avg_DOH AS NUMBER(32, 2))) AS avg_DOH,
        Avg_Inventory_Amount,
        STANDARD_PRICE * Rec_Safety_Stock as Extended_component_cost_value,
        Difference,
        ZEROIFNULL(CAST(Max_Amount AS NUMBER(32, 2))) AS Max_Amount,
        ROP_STATUS,
        SAFETY_STOCK_STATUS,
        ZEROIFNULL(CAST(INV_POSITION AS NUMBER(32, 2))) AS INV_POSITION,
        INV_STATUS
    FROM
        final
),
SOURCE_DATA as(
 SELECT distinct *
from
    Type_data1
WHERE
    Total_Cons_and_demand > 0
    and mrp_type in ('PD', 'V1')
    and PROCUREMENT_TYPE = 'F'
    AND CROSS_PLANT_MATERIAL_STATUS IN ('YA', 'YB', 'YC', 'YD', 'YE', 'YF')
    and material_group != '9900'
),
TRANSFORM_DATA AS (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') AS _ROW_HASH,
	MATERIAL_NUMBER,
	MATERIAL_DESCRIPTION,
	PROCUREMENT_TYPE,
	LEAD_TIME,
	STANDARD_PRICE,
	VALUATION_AREA,
	PLANT,
	CROSS_PLANT_MATERIAL_STATUS,
	MATERIAL_GROUP,
	MATERIAL_GROUP_DESCRIPTION,
	ABC_INDICATOR,
	PURCHASING_GROUP,
	DESCRIPTION_OF_PURCHASING_GROUP,
	MRP_TYPE,
	REC_SAFETY_STOCK,
	SAP_SAFETY_STOCK,
	SAFETY_STOCK_DELTA,
	SAP_REORDER_POINT,
	REC_REORDER_POINT,
	ROP_DELTA,
	MINIMUM_LOT_SIZE,
	PROFIT_CENTER,
	PROFIT_CENTER_DESCRIPTION,
	TOTAL_12_CONSUMPTION,
	TOTAL_CONS_AND_DEMAND,
	TOTAL_DEMAND,
	TOTAL_18MONTH_MACHINE_DOWN_QTY,
	TOTAL_MACHINE_DOWN,
	TOTAL_12_CONSUMPTION_STDV,
	TOTAL_DEMAND_STDV,
	WAREHOUSE_STOCK,
	TOTAL_REJECT,
	AVG_DAYS_LATE,
	TOTAL_OPEN_PO,
	PO_CYCLE_TIME_MIN,
	PO_CYCLE_TIME_MAX,
	PO_CYCLE_TIME_AVG,
	PO_CYCLE_TIME_MODE,
	PO_CYCLE_TIME_MEDIAN,
	LEADTIME_STDV,
	TOTAL_OPEN_PO_QTY,
	ANNUAL_USAGE,
	DAILY_USAGE,
	DEMAND_VARIATION,
	CYCLE_STOCK,
	BUFFER_STOCK,
	UNIT_HOLDING_COST,
	OPTIMAL_ORDER_QUANTITY,
	SUPPLIER_DELIVERY_RISK_VARIANCE,
	SUPPLIER_RISK_VARIATION,
	ACTUAL_ORDER_QUANTITY,
	MAX_INVENTORY_QTY,
	CURRENT_COST,
	ACTUAL_DOH,
	AVG_INVENTORY_QTY,
	AVG_DOH,
	AVG_INVENTORY_AMOUNT,
	EXTENDED_COMPONENT_COST_VALUE,
	DIFFERENCE,
	MAX_AMOUNT,
	ROP_STATUS,
	SAFETY_STOCK_STATUS,
	INV_POSITION,
	INV_STATUS

FROM SOURCE_DATA
)

,
TYPE_DATA AS (
select
	CAST(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
	CAST(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
	MATERIAL_NUMBER,
	MATERIAL_DESCRIPTION,
	PROCUREMENT_TYPE,
	CAST(LEAD_TIME as NUMBER(38,0)) as LEAD_TIME,
	CAST(STANDARD_PRICE as NUMBER(38,10)) as STANDARD_PRICE,
	VALUATION_AREA,
	PLANT,
	CROSS_PLANT_MATERIAL_STATUS,
	MATERIAL_GROUP,
	MATERIAL_GROUP_DESCRIPTION,
	ABC_INDICATOR,
	PURCHASING_GROUP,
	DESCRIPTION_OF_PURCHASING_GROUP,
	MRP_TYPE,
	CAST(REC_SAFETY_STOCK as FLOAT) as REC_SAFETY_STOCK,
	CAST(SAP_SAFETY_STOCK as NUMBER(38,10)) as SAP_SAFETY_STOCK,
	CAST(SAFETY_STOCK_DELTA as NUMBER(38,10)) as SAFETY_STOCK_DELTA,
	CAST(SAP_REORDER_POINT as NUMBER(38,10)) as SAP_REORDER_POINT,
	CAST(REC_REORDER_POINT as NUMBER(38,10)) as REC_REORDER_POINT,
	CAST(ROP_DELTA as NUMBER(38,10)) as ROP_DELTA,
	CAST(MINIMUM_LOT_SIZE as NUMBER(38,10)) as MINIMUM_LOT_SIZE,
	CAST(PROFIT_CENTER as NUMBER(38,0)) as PROFIT_CENTER,
	PROFIT_CENTER_DESCRIPTION,
	CAST(TOTAL_12_CONSUMPTION as NUMBER(38,0)) as TOTAL_12_CONSUMPTION,
	CAST(TOTAL_CONS_AND_DEMAND as NUMBER(38,0)) as TOTAL_CONS_AND_DEMAND,
	CAST(TOTAL_DEMAND as NUMBER(38,0)) as TOTAL_DEMAND,
	CAST(TOTAL_18MONTH_MACHINE_DOWN_QTY as NUMBER(38,0)) as TOTAL_18MONTH_MACHINE_DOWN_QTY,
	CAST(TOTAL_MACHINE_DOWN as NUMBER(38,0)) as TOTAL_MACHINE_DOWN,
	CAST(TOTAL_12_CONSUMPTION_STDV as NUMBER(38,10)) as TOTAL_12_CONSUMPTION_STDV,
	CAST(TOTAL_DEMAND_STDV as FLOAT) as TOTAL_DEMAND_STDV,
	CAST(WAREHOUSE_STOCK as NUMBER(38,10)) as WAREHOUSE_STOCK,
	CAST(TOTAL_REJECT as NUMBER(38,10)) as TOTAL_REJECT,
	CAST(AVG_DAYS_LATE as NUMBER(38,10)) as AVG_DAYS_LATE,
	CAST(TOTAL_OPEN_PO as NUMBER(38,10)) as TOTAL_OPEN_PO,
	CAST(PO_CYCLE_TIME_MIN as NUMBER(38,0)) as PO_CYCLE_TIME_MIN,
	CAST(PO_CYCLE_TIME_MAX as NUMBER(38,0)) as PO_CYCLE_TIME_MAX,
	CAST(PO_CYCLE_TIME_AVG as NUMBER(38,0)) as PO_CYCLE_TIME_AVG,
	CAST(PO_CYCLE_TIME_MODE as NUMBER(38,0)) as PO_CYCLE_TIME_MODE,
	CAST(PO_CYCLE_TIME_MEDIAN as NUMBER(38,0)) as PO_CYCLE_TIME_MEDIAN,
	CAST(LEADTIME_STDV as NUMBER(38,10)) as LEADTIME_STDV,
	CAST(TOTAL_OPEN_PO_QTY as NUMBER(38,10)) as TOTAL_OPEN_PO_QTY,
	CAST(ANNUAL_USAGE as NUMBER(38,10)) as ANNUAL_USAGE,
	CAST(DAILY_USAGE as NUMBER(38,10)) as DAILY_USAGE,
	CAST(DEMAND_VARIATION as NUMBER(38,10)) as DEMAND_VARIATION,
	CAST(CYCLE_STOCK as NUMBER(38,10)) as CYCLE_STOCK,
	CAST(BUFFER_STOCK as FLOAT) as BUFFER_STOCK,
	CAST(UNIT_HOLDING_COST as NUMBER(38,10)) as UNIT_HOLDING_COST,
	CAST(OPTIMAL_ORDER_QUANTITY as NUMBER(38,10)) as OPTIMAL_ORDER_QUANTITY,
	CAST(SUPPLIER_DELIVERY_RISK_VARIANCE as NUMBER(38,10)) as SUPPLIER_DELIVERY_RISK_VARIANCE,
	CAST(SUPPLIER_RISK_VARIATION as NUMBER(38,10)) as SUPPLIER_RISK_VARIATION,
	CAST(ACTUAL_ORDER_QUANTITY as FLOAT) as ACTUAL_ORDER_QUANTITY,
	CAST(MAX_INVENTORY_QTY as NUMBER(38,10)) as MAX_INVENTORY_QTY,
	CAST(CURRENT_COST as NUMBER(38,10)) as CURRENT_COST,
	CAST(ACTUAL_DOH as NUMBER(38,10)) as ACTUAL_DOH,
	CAST(AVG_INVENTORY_QTY as FLOAT) as AVG_INVENTORY_QTY,
	CAST(AVG_DOH as NUMBER(38,10)) as AVG_DOH,
	CAST(AVG_INVENTORY_AMOUNT as FLOAT) as AVG_INVENTORY_AMOUNT,
	CAST(EXTENDED_COMPONENT_COST_VALUE as FLOAT) as EXTENDED_COMPONENT_COST_VALUE,
	CAST(DIFFERENCE as FLOAT) as DIFFERENCE,
	CAST(MAX_AMOUNT as NUMBER(38,10)) as MAX_AMOUNT,
	ROP_STATUS,
	SAFETY_STOCK_STATUS,
	CAST(INV_POSITION as NUMBER(38,10)) as INV_POSITION,
	INV_STATUS
from transform_data
)
SELECT * FROM TYPE_DATA