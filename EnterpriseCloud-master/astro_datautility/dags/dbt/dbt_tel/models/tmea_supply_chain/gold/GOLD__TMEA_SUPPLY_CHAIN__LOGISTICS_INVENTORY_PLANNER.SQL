{{ config(
        materialized='tel_incremental',
        incremental_strategy='insert_overwrite',
        alias = 'LOGISTICS_INVENTORY_PLANNER',
        transient = false
) }}

WITH Main AS (
        SELECT DISTINCT MBEW.material_number,
            MAKT.material_description,
            MARC.profit_center,
            MARC.procurement_type,
            CEPC.general_name,
            MBEW.standard_price,
            MBEW.price_unit,
            MBEW.standard_price / MBEW.price_unit AS NET_price,
            MBEW.valuation_area,
            MARC.mrp_type,
            MARC.abc_indicator,
            MARC.PLANT,
            MARA.MATERIAL_GROUP
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} AS MBEW
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS MARC ON MARC.material_number = MBEW.material_number AND MARC.plant = MBEW.valuation_area
        LEFT JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }} AS MARA ON MARA.material_number = MARC.material_number
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} AS MAKT ON MAKT.material_number = MBEW.material_number
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} AS CEPC ON CEPC.profit_center = MARC.profit_center
        WHERE plant IN ('0010') AND VALUATION_AREA = '0010'
        ),
    -- // extracting last 9 Months comsumption data by material number
    Consumption AS (
        SELECT DISTINCT MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT,
            MSEG.material_number,
            MSEG.NUMBER_OF_MATERIAL_DOCUMENT,
            MSEG.item_in_material_document,
            MSEG.MATERIAL_DOCUMENT_YEAR,
            monthname(MSEG.posting_date_in_the_document) AS Month_Name,
            MSEG.posting_date_in_the_document,
            dateadd(day, - day(CURRENT_DATE), CURRENT_DATE) AS LastMonth,
            dateadd(month, - 9, LastMonth) AS FirstMonth,
            CASE WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN quantity * - 1 ELSE QUANTITY END AS TOTAL_CONSUMPTION
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__DOCUMENT_SEGMENT_MATERIAL') }} AS MSEG
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MSEG.material_number AND pdm.plant = MSEG.plant
        WHERE MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT IN ('601', '201', '261', '991', '992', '202', '262', '641', '993', '994') AND MSEG.posting_date_in_the_document > '2019-12-31' AND MSEG.posting_date_in_the_document BETWEEN FirstMonth AND LastMonth AND MSEG.plant IN ('0010') AND pdm.procurement_type = 'F'
        ),
    // aggregating 9 Months consumption data by material number
    Total_consumption AS (
        SELECT Consumption.MATERIAL_DOCUMENT_YEAR,
            Consumption.material_number AS material_number,
            sum(Consumption.TOTAL_CONSUMPTION) AS total_qty_Issued
        FROM Consumption AS Consumption
        GROUP BY Consumption.material_number,
            Consumption.MATERIAL_DOCUMENT_YEAR,
            Month_Name
        ),
    Final_Consumption AS (
        SELECT material_number,
            sum(total_qty_Issued) AS Total_12_Consumption,
            stddev(total_qty_Issued) AS Total_12_Consumption_STDV,
            Total_12_Consumption / 12 AS AVG_12_month_Consumption
        FROM Total_consumption AS Total_consumption
        GROUP BY material_number
        ),
    -- // extracting last 5 years comsumption data for DEAD Inventory calculation
    DEAD_INV AS (
        SELECT DISTINCT MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT,
            MSEG.material_number,
            MSEG.NUMBER_OF_MATERIAL_DOCUMENT,
            MSEG.item_in_material_document,
            MSEG.MATERIAL_DOCUMENT_YEAR,
            monthname(MSEG.posting_date_in_the_document) AS Month_Name,
            MSEG.posting_date_in_the_document,
            dateadd(day, - day(CURRENT_DATE), CURRENT_DATE) AS LastMonth,
            dateadd(month, - 60, LastMonth) AS FirstMonth,
            CASE WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN QUANTITY * - 1 ELSE MSEG.QUANTITY END AS TOTAL_CONSUMPTION_5Y
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__DOCUMENT_SEGMENT_MATERIAL') }} AS MSEG
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MSEG.material_number AND pdm.plant = MSEG.plant
        WHERE MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT IN ('601', '201', '261', '991', '992', '202', '262', '641', '993', '994') AND MSEG.posting_date_in_the_document > '2019-12-31' AND MSEG.posting_date_in_the_document BETWEEN FirstMonth AND LastMonth AND MSEG.plant IN ('0010') AND pdm.procurement_type = 'F'
        ),
    // aggregating last 5 years comsumption data for DEAD Inventory
    Total_DEAD_INV AS (
        SELECT DEAD_INV.MATERIAL_DOCUMENT_YEAR,
            DEAD_INV.material_number AS material_number,
            sum(DEAD_INV.TOTAL_CONSUMPTION_5Y) AS total_DEAD_INV_qty_Issued
        FROM DEAD_INV AS DEAD_INV
        GROUP BY DEAD_INV.material_number,
            DEAD_INV.MATERIAL_DOCUMENT_YEAR,
            Month_Name
        ),
    Final_DEAD_INV AS (
        SELECT material_number,
            sum(total_DEAD_INV_qty_Issued) AS total_DEAD_INV_qty_Issued
        FROM Total_DEAD_INV AS Total_DEAD_INV
        GROUP BY material_number
        ),
    -- // extracting last 12months non-moving Inventory
    DEAD_12months_INV AS (
        SELECT DISTINCT MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT,
            MSEG.material_number,
            MSEG.NUMBER_OF_MATERIAL_DOCUMENT,
            MSEG.item_in_material_document,
            MSEG.MATERIAL_DOCUMENT_YEAR,
            monthname(MSEG.posting_date_in_the_document) AS Month_Name,
            MSEG.posting_date_in_the_document,
            dateadd(day, - day(CURRENT_DATE), CURRENT_DATE) AS LastMonth,
            dateadd(month, - 12, LastMonth) AS FirstMonth,
            CASE WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN QUANTITY * - 1 ELSE MSEG.QUANTITY END AS TOTAL_CONSUMPTION_12M
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__DOCUMENT_SEGMENT_MATERIAL') }} AS MSEG
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MSEG.material_number AND pdm.plant = MSEG.plant
        WHERE MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT IN ('601', '201', '261', '991', '992', '202', '262', '641', '993', '994') AND MSEG.posting_date_in_the_document > '2019-12-31' AND MSEG.posting_date_in_the_document BETWEEN FirstMonth AND LastMonth AND MSEG.plant IN ('0010') AND pdm.procurement_type = 'F'
        ),
    // aggregating 12months non-moving inventory Inventory
    Total_DEAD_12months_INV AS (
        SELECT DEAD_12months_INV.MATERIAL_DOCUMENT_YEAR,
            DEAD_12months_INV.material_number AS material_number,
            sum(DEAD_12months_INV.TOTAL_CONSUMPTION_12M) AS total_DEAD_12months_INV_qty_Issued
        FROM DEAD_12months_INV AS DEAD_12months_INV
        GROUP BY DEAD_12months_INV.material_number,
            DEAD_12months_INV.MATERIAL_DOCUMENT_YEAR,
            Month_Name
        ),
    Final_DEAD_12months_INV AS (
        SELECT material_number,
            sum(total_DEAD_12months_INV_qty_Issued) AS total_DEAD_12months_INV_qty
        FROM Total_DEAD_12months_INV AS Total_DEAD_12months_INV
        GROUP BY material_number
        ),
    // extracting last 3 Quarters of comsumption data by material number from Inv Turns calculation
    last3_QTR_Consumption AS (
        SELECT DISTINCT MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT,
            MSEG.material_number,
            MSEG.NUMBER_OF_MATERIAL_DOCUMENT,
            MSEG.item_in_material_document,
            MSEG.MATERIAL_DOCUMENT_YEAR,
            monthname(MSEG.posting_date_in_the_document) AS Month_Name,
            MSEG.posting_date_in_the_document,
            dateadd(day, - day(CURRENT_DATE), CURRENT_DATE) AS LastMonth,
            dateadd(month, - 9, LastMonth) AS FirstMonth,
            CASE WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN AMOUNT_IN_LOCAL_CURRENCY * - 1 ELSE MSEG.AMOUNT_IN_LOCAL_CURRENCY END AS last3QRT_ISSUED_AMOUNT,
            CASE WHEN DEBIT_CREDIT_INDICATOR = 'S' THEN MSEG.quantity * - 1 ELSE MSEG.quantity END AS last3QRT_ISSUED_QTY
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__DOCUMENT_SEGMENT_MATERIAL') }} AS MSEG
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = MSEG.material_number AND pdm.plant = MSEG.plant
        WHERE MSEG.MOVEMENT_TYPE_INVENTORY_MANAGEMENT IN ('601', '201', '261', '991', '992', '202', '262', '641', '993', '994') AND MSEG.posting_date_in_the_document > '2019-12-31' AND MSEG.posting_date_in_the_document BETWEEN FirstMonth AND LastMonth AND MSEG.plant IN ('0010') AND pdm.procurement_type = 'F'
        ),
    // aggregating consumption data by material number
    last3_QTR_Total_consumption AS (
        SELECT last3_QTR_Consumption.MATERIAL_DOCUMENT_YEAR,
            last3_QTR_Consumption.LastMonth,
            last3_QTR_Consumption.material_number AS material_number,
            sum(last3_QTR_Consumption.last3QRT_ISSUED_Qty) AS last3QRT_CONS_Qty,
            sum(last3_QTR_Consumption.last3QRT_ISSUED_AMOUNT) AS last3QRT_CONS_AMOUNT
        FROM last3_QTR_Consumption AS last3_QTR_Consumption
        GROUP BY last3_QTR_Consumption.material_number,
            last3_QTR_Consumption.MATERIAL_DOCUMENT_YEAR,
            LastMonth
        ),
    last3_QTR_final_consumption AS (
        SELECT material_number,
            sum(last3_QTR_Total_consumption.last3QRT_CONS_Qty) AS last3QRT_TOTAL_CONSUMPTION_Qty,
            sum(last3_QTR_Total_consumption.last3QRT_CONS_AMOUNT) AS last3QRT_TOTAL_CONSUMPTION_AMOUNT
        FROM last3_QTR_Total_consumption AS last3_QTR_Total_consumption
        GROUP BY material_number
        ),
    // Extracting Open purchase orders
    open_po AS (
        SELECT poa.material_number,
            sum(poa.open_gr) AS OPEN_PO_QTY,
            max(net_price) AS PO_Price,
            max(purchasing_document_number) AS Latest_PO,
            count(DISTINCT POA.PURCHASING_DOCUMENT_NUMBER) AS Total_Open_PO
        FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_ORDER_METRIC_OPEN_AGING') }} AS poa
        GROUP BY poa.material_number
        ),
    -- // Extracting receipt data to calculate on-time delivery and PO calculations
    vendor_perf AS (
        SELECT vp.material,
            vp.RECEIPT_DATE,
            vp.NEED_DATE,
            vp.RECEIPT_DATE,
            monthname(vp.RECEIPT_DATE) AS Month_Name,
            datediff(day, vp.NEED_DATE, vp.RECEIPT_DATE) AS Commit_Days_DIFF,
            datediff(day, vp.PO_CREATE_DATE, vp.RECEIPT_DATE) AS PO_Cycle_Time,
            dateadd(day, - day(getdate()), getdate()) AS LastMonth,
            dateadd(month, - 12, LastMonth) AS FirstMonth
        FROM {{ ref('GOLD__TMEA_SUPPLY_CHAIN__PURCHASING_VENDOR_PERFORMANCE') }} AS vp
        WHERE vp.receipt_date > '2019-12-31' AND vp.receipt_date BETWEEN FirstMonth AND LastMonth
        ),
    totals_vendor_perf AS (
        SELECT vendor_perf.material,
            vendor_perf.month_Name,
            avg(PO_Cycle_Time) AS PO_CYCLE_TIME_AVG
        FROM vendor_perf AS vendor_perf
        GROUP BY vendor_perf.material,
            Month_Name
        ),
    Final_totals_vendor_perf AS (
        SELECT totals_vendor_perf.material,
            stddev(totals_vendor_perf.PO_CYCLE_TIME_AVG) AS lEADTIME_STDV,
            avg(totals_vendor_perf.PO_CYCLE_TIME_AVG) AS PO_CYCLE_TIME_AVG,
            lEADTIME_STDV / 30.5 AS lEADTIME_STDV_month
        FROM totals_vendor_perf AS totals_vendor_perf
        GROUP BY totals_vendor_perf.material
        ),
    // extracting next 90 days of demand by material number for Inv Turns Calculation
    MRP_DATA AS (
        SELECT DISTINCT HDMD.MRP_DATE,
            SMT.RECEIPT_REQUIREMENTS_DATE,
            SMT.MRP_ELEMENT,
            SMT.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED,
            SMT.MRP_ELEMENT_NUMBER,
            SMT.MATERIAL_NUMBER_OF_HIGHER_LEVEL_ASSEMBLY,
            HDMD.MATERIAL_NUMBER,
            HDMD.PLANT,
            cast(HDMD.SAFETY_STOCK * - 1 AS number(32, 10)) AS SAFETY_STOCK,
            HDMD.PLANT_STOCK_ONLY_PLANT_SEGMENT,
            CASE WHEN MATERIAL_REQUIREMENTS_PLANNING_SEGMENT = '02' AND RECEIPT_ISSUE_INDICATOR = '-' THEN QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED * - 1 END AS TOTAL_DEMAND,
            dateadd(DAY, 30.4167, dateadd(day, - day(CURRENT_DATE ()), CURRENT_DATE ())) AS FirstMonth,
            dateadd(DAY, + 91.2501, FirstMonth) AS LastMonth
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }} AS SMT
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }} AS HDMD ON HDMD.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = smt.number_of_material_requirements_planning_table
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} AS pdm ON pdm.material_number = HDMD.material_number AND pdm.plant = HDMD.plant AND SMT.RECEIPT_REQUIREMENTS_DATE BETWEEN FirstMonth AND LastMonth AND pdm.plant IN ('0010') AND pdm.procurement_type = 'F'
        ),
    Final_Demand AS (
        SELECT DISTINCT MRP_DATA.MATERIAL_NUMBER,
            sum(TOTAL_DEMAND) AS TOTAL_Demand
        FROM mrp_DATA AS MRP_DATA
        GROUP BY MRP_DATA.MATERIAL_NUMBER
        ),
    // Extractinf Stock on Hand from Plant 0010
    Stock AS (
        SELECT DISTINCT HDMD.MRP_DATE,
            SMT.RECEIPT_REQUIREMENTS_DATE,
            SMT.MRP_ELEMENT,
            SMT.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED,
            SMT.MRP_ELEMENT_NUMBER,
            SMT.MATERIAL_NUMBER_OF_HIGHER_LEVEL_ASSEMBLY,
            HDMD.MATERIAL_NUMBER,
            HDMD.PLANT,
            CASE WHEN smt.MRP_ELEMENT IN ('WB') THEN QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED ELSE 0 END AS TOTAL_STOCK_OH
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }} AS SMT
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }} AS HDMD ON HDMD.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = smt.number_of_material_requirements_planning_table AND plant IN ('0010')
        ),
    final_Stock AS (
        SELECT stock.MATERIAL_NUMBER,
            max(TOTAL_STOCK_OH) AS TOTAL_STOCK_OH
        FROM stock
        GROUP BY stock.MATERIAL_NUMBER
        ),
    // extracting next 90 days demand to calculate 90 days demand delta
    Forecast AS (
        SELECT DISTINCT HDMD.MRP_DATE,
            SMT.RECEIPT_REQUIREMENTS_DATE,
            SMT.MRP_ELEMENT,
            SMT.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED,
            SMT.MRP_ELEMENT_NUMBER,
            SMT.MATERIAL_NUMBER_OF_HIGHER_LEVEL_ASSEMBLY,
            HDMD.MATERIAL_NUMBER,
            HDMD.PLANT,
            cast(HDMD.SAFETY_STOCK * - 1 AS number(32, 10)) AS SAFETY_STOCK,
            HDMD.PLANT_STOCK_ONLY_PLANT_SEGMENT,
            CASE WHEN MATERIAL_REQUIREMENTS_PLANNING_SEGMENT = '02' AND RECEIPT_ISSUE_INDICATOR = '-' THEN QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED * - 1 END AS TOTAL_forecast,
            dateadd(DAY, 30.4167, dateadd(day, - day(CURRENT_DATE ()), CURRENT_DATE ())) AS FirstMonth,
            dateadd(DAY, + 91.2501, FirstMonth) AS LastMonth
        FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }} AS SMT
        JOIN {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }} AS HDMD ON HDMD.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = smt.number_of_material_requirements_planning_table AND SMT.RECEIPT_REQUIREMENTS_DATE BETWEEN FirstMonth AND LastMonth AND plant IN ('0010')
        ),
    Final_forecast AS (
        SELECT DISTINCT forecast.MATERIAL_NUMBER,
            sum(abs(TOTAL_forecast)) AS TOTAL_forecast
        FROM forecast AS forecast
        GROUP BY forecast.MATERIAL_NUMBER
        ),
OUTPUT AS (
    SELECT Main.PLANT,
        Main.material_number,
        Main.material_description,
        Main.profit_center,
        Main.general_name,
        Main.procurement_type,
        Main.mrp_type,
        Main.abc_indicator,
        Main.net_price,
        Main.valuation_area,
        zeroifnull(OPEN_PO_QTY) AS OPEN_PO_QTY,
        zeroifnull(OPEN_PO_QTY * Main.net_price) AS EXTENDED_PRICE,
        zeroifnull(Total_12_Consumption) AS Total_12_Consumption,
        zeroifnull(AVG_12_month_Consumption) AS AVG_12_month_Consumption,
        zeroifnull(total_forecast) AS TOTAL_forecast,
        zeroifnull(Total_12_Consumption_STDV) AS Total_12_Consumption_STDV,
        zeroifnull(PO_CYCLE_TIME_AVG) AS PO_CYCLE_TIME_AVG,
        zeroifnull(PO_CYCLE_TIME_AVG / 30.5) AS PO_LT_TIME_MONTH_AVG,
        zeroifnull(lEADTIME_STDV) AS lEADTIME_STDV,
        zeroifnull(lEADTIME_STDV_month) AS lEADTIME_STDV_month,
        zeroifnull(TOTAL_DEMAND * - 1) AS Next_QTR_DEMAND_UNITS,
        zeroifnull(Next_QTR_DEMAND_UNITS * Main.net_price) AS Next_QTR_DEMAND_VALUE,
        zeroifnull(last3QRT_TOTAL_CONSUMPTION_Qty) AS last3QRT_TOTAL_CONSUMPTION_Qty,
        zeroifnull(last3QRT_TOTAL_CONSUMPTION_AMOUNT) AS last3QRT_TOTAL_CONSUMPTION_AMAOUNT,
        zeroifnull(last3QRT_TOTAL_CONSUMPTION_AMAOUNT + Next_QTR_DEMAND_VALUE) AS COGS,
        zeroifnull(TOTAL_forecast + Total_12_Consumption) AS CONSOLIDATED_DEMAND,
        zeroifnull(TOTAL_STOCK_OH) AS TOTAL_STOCK_OH,
        zeroifnull(TOTAL_STOCK_OH * Main.net_price) AS TOTAL_STOCK_OH_Amount,
        20 AS FIXED_ORDER_COST,
        // Daily_Consumption
        zeroifnull(CAST(CONSOLIDATED_DEMAND / (365) AS DECIMAL(10, 2))) AS Daily_Consumption,
        //HOLDING_COST
        zeroifnull(CAST(Main.net_price * 0.2098 AS DECIMAL(10, 2))) AS HOLDING_COST,
        //SAFETY_STOCK
        zeroifnull(CAST(1.65 * Total_12_Consumption_STDV * SQRT(PO_LT_TIME_MONTH_AVG) AS INTEGER)) AS SAFETY_STOCK,
        //REC_ROP
        zeroifnull(CAST(Safety_Stock + (Daily_Consumption * PO_CYCLE_TIME_AVG) AS INTEGER)) AS REC_ROP,
        //OPTIMAL_ORDER_QTY
        CASE WHEN CONSOLIDATED_DEMAND <= 0 OR HOLDING_COST = 0 THEN 0 ELSE zeroifnull(CAST(SQRT((2 * CONSOLIDATED_DEMAND * FIXED_ORDER_COST) / HOLDING_COST) AS INTEGER)) END AS OPTIMAL_ORDER_QTY,
        //MAX_INV_QTY
        zeroifnull(CAST(REC_ROP + OPTIMAL_ORDER_QTY - (PO_LT_TIME_MONTH_AVG * Daily_Consumption) AS INTEGER)) AS MAX_INV_QTY,
        //HEDGE_75_DAYS
        Daily_Consumption * 75 AS HEDGE_75_DAYS,
        //Max_Inventory_Costs
        zeroifnull((MAX_INV_QTY) * Main.net_price) AS Max_Inventory_Costs,
        //Model_Inventory_Costs
        zeroifnull((MAX_INV_QTY + HEDGE_75_DAYS) * Main.net_price) AS Model_Inventory_Costs,
        //Demand_next90_days_Delta
        zeroifnull(CASE WHEN TOTAL_STOCK_OH - TOTAL_forecast < 0 THEN TOTAL_STOCK_OH - TOTAL_forecast END) AS Demand_next90_days_Delta,
        //Demand_next90_days_Delta_value
        zeroifnull(Demand_next90_days_Delta * Main.net_price) AS Demand_next90_days_Delta_value,
        //Consumption_qty_Issued_5Y
        zeroifnull(total_DEAD_INV_qty_Issued) AS Consumption_qty_Issued_5Y,
        //DEAD_INV_5Y
        zeroifnull(CASE WHEN Consumption_qty_Issued_5Y <= 0 THEN TOTAL_STOCK_OH END) AS DEAD_INV_5Y,
        //DEAD_INV_5Y_VALUE
        zeroifnull(CASE WHEN Consumption_qty_Issued_5Y <= 0 THEN TOTAL_STOCK_OH_Amount END) AS DEAD_INV_5Y_VALUE,
        //DEAD_INV_12M
        zeroifnull(CASE WHEN total_DEAD_12months_INV_qty <= 0 THEN TOTAL_STOCK_OH END) AS DEAD_INV_12M,
        //DEAD_INV_12M_VALUE
        zeroifnull(CASE WHEN total_DEAD_12months_INV_qty <= 0 THEN TOTAL_STOCK_OH_Amount END) AS DEAD_INV_12M_VALUE,
        //Inventory_type
        CASE WHEN Main.profit_center LIKE '00005%' THEN 'GCIB Inv' WHEN Main.profit_center LIKE '00006%' THEN 'FSBU Inv' ELSE 'CCS Inv' END AS Inventory_type
    FROM Main AS Main
    LEFT JOIN open_po AS open_po ON open_po.material_number = Main.material_number
    LEFT JOIN final_consumption AS final_consumption ON final_consumption.material_number = Main.material_number
    LEFT JOIN last3_QTR_final_consumption AS last3_QTR_final_consumption ON last3_QTR_final_consumption.material_number = Main.material_number
    LEFT JOIN Final_totals_vendor_perf AS Final_totals_vendor_perf ON Final_totals_vendor_perf.material = Main.material_number
    LEFT JOIN Final_Demand AS Final_Demand ON Final_Demand.material_number = Main.material_number
    LEFT JOIN Final_Forecast AS Final_Forecast ON Final_Forecast.material_number = Main.material_number
    LEFT JOIN final_DEAD_INV AS final_DEAD_INV ON final_DEAD_INV.material_number = Main.material_number
    LEFT JOIN final_DEAD_12months_INV AS final_DEAD_12months_INV ON final_DEAD_12months_INV.material_number = Main.material_number
    LEFT JOIN final_stock AS final_stock ON final_stock.material_number = Main.material_number
    WHERE MAIN.PROCUREMENT_TYPE = 'F' AND MAIN.PLANT = '0010' AND MATERIAL_GROUP <> '0100'
    ),
final as (
SELECT DISTINCT 
    '{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
    PLANT,
    MATERIAL_NUMBER,
    MATERIAL_DESCRIPTION,
    PROFIT_CENTER,
    GENERAL_NAME,
    PROCUREMENT_TYPE,
    MRP_TYPE,
    ABC_INDICATOR,
    NET_PRICE,
    VALUATION_AREA,
    OPEN_PO_QTY,
    EXTENDED_PRICE,
    TOTAL_12_CONSUMPTION,
    AVG_12_MONTH_CONSUMPTION,
    TOTAL_FORECAST,
    TOTAL_12_CONSUMPTION_STDV,
    PO_CYCLE_TIME_AVG,
    PO_LT_TIME_MONTH_AVG,
    LEADTIME_STDV,
    LEADTIME_STDV_MONTH,
    NEXT_QTR_DEMAND_UNITS,
    NEXT_QTR_DEMAND_VALUE,
    LAST3QRT_TOTAL_CONSUMPTION_QTY,
    LAST3QRT_TOTAL_CONSUMPTION_AMAOUNT,
    COGS,
    CONSOLIDATED_DEMAND,
    TOTAL_STOCK_OH,
    TOTAL_STOCK_OH_AMOUNT,
    FIXED_ORDER_COST,
    DAILY_CONSUMPTION,
    HOLDING_COST,
    SAFETY_STOCK,
    REC_ROP,
    OPTIMAL_ORDER_QTY,
    MAX_INV_QTY,
    HEDGE_75_DAYS,
    MAX_INVENTORY_COSTS,
    MODEL_INVENTORY_COSTS,
    DEMAND_NEXT90_DAYS_DELTA,
    DEMAND_NEXT90_DAYS_DELTA_VALUE,
    CONSUMPTION_QTY_ISSUED_5Y,
    DEAD_INV_5Y,
    DEAD_INV_5Y_VALUE,
    DEAD_INV_12M,
    DEAD_INV_12M_VALUE,
    INVENTORY_TYPE
FROM
OUTPUT
)
select * from final