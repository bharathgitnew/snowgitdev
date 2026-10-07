{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='TMEA_TOOL_BOM_PROCUREMENT_TYPE_E',
    	transient=false
) }}

WITH 
-- CTE for material level MRP controller lookup filtered by plant
CTE_Material_Data AS (
    SELECT
        MATERIAL_NUMBER,
        MAX(MRP_CONTROLLER_MATERIALS_PLANNER) AS MRP_CONTROLLER_MATERIALS_PLANNER
    FROM
        {{ ref('SILVER__TMEA_MANUFACTURING__PLANT_DATA_FOR_MATERIAL')}}
    WHERE
        PLANT = '0010'
    GROUP BY
        MATERIAL_NUMBER        
),
CTE_PROCUREMENT_E as (
     SELECT 
            MATERIAL_NUMBER,
            PROCUREMENT_TYPE,
            SPECIAL_PROCUREMENT_TYPE,
            MRP_CONTROLLER_MATERIALS_PLANNER
        FROM {{ ref('SILVER__TMEA_MANUFACTURING__PLANT_DATA_FOR_MATERIAL') }}
        WHERE PLANT = '0010'AND PROCUREMENT_TYPE = 'E'
),
CTE_BOM_LINK as (
    SELECT
                    MATERIAL_NUMBER,
                    BILL_OF_MATERIAL
                FROM {{ ref('SILVER__TMEA_MANUFACTURING__MATERIAL_TO_BOM_LINK') }}
                WHERE PLANT = '0010'
),
CTE_BOM_ITEM AS (
    SELECT 
                BILL_OF_MATERIAL,
                DATE_OF_LAST_CHANGE,
                BOM_COMPONENT,
                BOM_ITEM_NUMBER,
                COMPONENT_UNIT_OF_MEASURE,
                COMPONENT_QUANTITY
            FROM {{ ref('SILVER__TMEA_MANUFACTURING__BOM_ITEM') }}
            WHERE DATE_OF_LAST_CHANGE IS NULL
),
-- Level 0 BOM extraction from sales document items categorized as 'ZMRG'
LEVEL0 AS (
    SELECT 
        sdid.SALES_DOCUMENT,
        sdid.SALES_DOCUMENT_ITEM,
        sdid.Sales_Document_MATERIAL_NUMBER,
        sdid.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        sdid.MATERIAL_NUMBER AS Module,
        NULL AS Parent_BILL_OF_MATERIAL,
        NULL AS Parent_BOM_COMPONENT,
        NULL AS Parent_BOM_ITEM_NUMBER,
        NULL AS Parent_COMPONENT_QUANTITY,
        NULL AS Parent_COMPONENT_UNIT_OF_MEASURE,
        NULL AS Parent_PROCUREMENT_TYPE,
        NULL AS Parent_SPECIAL_PROCUREMENT_TYPE,
        0 AS Level,
        NULL AS BILL_OF_MATERIAL,
        sdid.MATERIAL_NUMBER AS BOM_COMPONENT,
        NULL AS BOM_ITEM_NUMBER,
        1 AS COMPONENT_QUANTITY,
        NULL AS COMPONENT_UNIT_OF_MEASURE,
        pdfm.PROCUREMENT_TYPE,
        pdfm.SPECIAL_PROCUREMENT_TYPE,
        pdfm.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            SALES_DOCUMENT,
            SALES_DOCUMENT_ITEM,
            MATERIAL_NUMBER AS Sales_Document_MATERIAL_NUMBER,
            SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            MATERIAL_NUMBER
        FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_ITEM_DATA') }}
        WHERE SALES_DOCUMENT_ITEM_CATEGORY NOT IN ('ZUPG', 'ZSR')
    ) 
        AS sdid
    LEFT JOIN CTE_PROCUREMENT_E AS pdfm 
    ON sdid.MATERIAL_NUMBER = pdfm.MATERIAL_NUMBER
    WHERE sdid.MATERIAL_NUMBER NOT LIKE '%-P%'
    ORDER BY sdid.SALES_DOCUMENT_ITEM
),

LEVEL1 AS (
    SELECT
        level0.SALES_DOCUMENT,
        level0.SALES_DOCUMENT_ITEM,
        level0.MATERIAL_NUMBER AS Sales_Document_MATERIAL_NUMBER,
        level0.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        -- Determine MODULE by checking if BOM_COMPONENT contains any of the specified suffixes
        CASE
            WHEN POSITION('-A' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-F' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-G' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-H' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-M' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-S' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-T' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-V' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-L' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-K' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-E' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-R' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-C0' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-U' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-B' IN level0.BOM_COMPONENT) > 0 OR
                 POSITION('-N' IN level0.BOM_COMPONENT) > 0
            THEN level0.BOM_COMPONENT
            ELSE level0.MATERIAL_NUMBER
        END AS MODULE,
        
        NULL AS Parent_BILL_OF_MATERIAL,
        level0.MATERIAL_NUMBER AS Parent_BOM_COMPONENT,
        NULL AS Parent_BOM_ITEM_NUMBER,
        NULL AS Parent_COMPONENT_QUANTITY,
        NULL AS Parent_COMPONENT_UNIT_OF_MEASURE,
        NULL AS Parent_PROCUREMENT_TYPE,
        NULL AS Parent_SPECIAL_PROCUREMENT_TYPE,
        1 AS Level,
        level0.BILL_OF_MATERIAL,
        level0.BOM_COMPONENT,
        level0.BOM_ITEM_NUMBER,
        level0.COMPONENT_QUANTITY,
        level0.COMPONENT_UNIT_OF_MEASURE,
        pdfm1.PROCUREMENT_TYPE,
        pdfm1.SPECIAL_PROCUREMENT_TYPE,
        pdfm1.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT
            sdid1.MATERIAL_NUMBER,
            sdid1.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            sdid1.SALES_DOCUMENT,
            sdid1.SALES_DOCUMENT_ITEM,
            sdid1.BILL_OF_MATERIAL,
            bi1.BOM_COMPONENT,
            bi1.BOM_ITEM_NUMBER,
            bi1.COMPONENT_UNIT_OF_MEASURE,
            bi1.COMPONENT_QUANTITY
        FROM (
            SELECT
                sdid.MATERIAL_NUMBER,
                sdid.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                sdid.SALES_DOCUMENT,
                sdid.SALES_DOCUMENT_ITEM,
                mtbl.BILL_OF_MATERIAL
            FROM (
                SELECT
                    MATERIAL_NUMBER,
                    SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                    SALES_DOCUMENT,
                    SALES_DOCUMENT_ITEM
                FROM (
                    SELECT
                        MATERIAL_NUMBER,
                        SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                        CAST(SALES_DOCUMENT AS INTEGER) AS SALES_DOCUMENT,
                        CAST(SALES_DOCUMENT_ITEM AS INTEGER) AS SALES_DOCUMENT_ITEM,
                        SALES_DOCUMENT_ITEM_CATEGORY
                    FROM {{ ref('SILVER__TMEA_MANUFACTURING__SALES_DOCUMENT_ITEM_DATA') }}
                    WHERE SALES_DOCUMENT_ITEM_CATEGORY NOT IN ('ZUPG', 'ZSR')
                      AND MATERIAL_NUMBER NOT LIKE '%-P%'
                ) AS ITBL
            ) AS sdid
            LEFT JOIN CTE_BOM_LINK AS mtbl ON sdid.MATERIAL_NUMBER = mtbl.MATERIAL_NUMBER
        ) AS sdid1
        LEFT JOIN (
            SELECT
                bi.BILL_OF_MATERIAL,
                bi.BOM_COMPONENT,
                bi.BOM_ITEM_NUMBER,
                bi.COMPONENT_UNIT_OF_MEASURE,
                bi.COMPONENT_QUANTITY,
                pdfm.PROCUREMENT_TYPE,
                pdfm.SPECIAL_PROCUREMENT_TYPE
            FROM CTE_BOM_ITEM AS bi
            LEFT JOIN CTE_PROCUREMENT_E AS pdfm ON bi.BOM_COMPONENT = pdfm.MATERIAL_NUMBER
        ) AS bi1 ON sdid1.BILL_OF_MATERIAL = bi1.BILL_OF_MATERIAL
    ) AS level0
    LEFT JOIN CTE_PROCUREMENT_E AS pdfm1 ON level0.BOM_COMPONENT = pdfm1.MATERIAL_NUMBER
    WHERE pdfm1.PROCUREMENT_TYPE = 'E'
    ORDER BY level0.SALES_DOCUMENT_ITEM,
             level0.BOM_ITEM_NUMBER
),

LEVEL2 AS (
    SELECT
        level1.SALES_DOCUMENT,
        level1.SALES_DOCUMENT_ITEM,
        level1.Sales_Document_MATERIAL_NUMBER,
        level1.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        CASE
            WHEN level1.Module != level1.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level1.BOM_COMPONENT, '-A') OR
                        CONTAINS(level1.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level1.BOM_COMPONENT, '-G') OR
                        CONTAINS(level1.BOM_COMPONENT, '-H') OR
                        CONTAINS(level1.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level1.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level1.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level1.BOM_COMPONENT, '-V') OR
                        CONTAINS(level1.BOM_COMPONENT, '-L') OR
                        CONTAINS(level1.BOM_COMPONENT, '-K') OR
                        CONTAINS(level1.BOM_COMPONENT, '-E') OR
                        CONTAINS(level1.BOM_COMPONENT, '-R') OR
                        CONTAINS(level1.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level1.BOM_COMPONENT, '-U') OR
                        CONTAINS(level1.BOM_COMPONENT, '-B') OR
                        CONTAINS(level1.BOM_COMPONENT, '-N')  
                    THEN level1.BOM_COMPONENT
                    ELSE level1.Module
                END
            ELSE level1.Parent_BOM_COMPONENT
        END AS MODULE,
        
        level1.Parent_BILL_OF_MATERIAL,
        level1.Parent_BOM_COMPONENT,
        level1.Parent_BOM_ITEM_NUMBER,
        level1.Parent_COMPONENT_QUANTITY,
        level1.Parent_COMPONENT_UNIT_OF_MEASURE,
        level1.Parent_PROCUREMENT_TYPE,
        level1.Parent_SPECIAL_PROCUREMENT_TYPE,
        2 AS Level,
        level1.BILL_OF_MATERIAL,
        level1.BOM_COMPONENT,
        level1.BOM_ITEM_NUMBER,
        level1.COMPONENT_QUANTITY,
        level1.COMPONENT_UNIT_OF_MEASURE,
        ITBL.PROCUREMENT_TYPE,
        ITBL.SPECIAL_PROCUREMENT_TYPE,
        ITBL.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT
            level1.SALES_DOCUMENT,
            level1.SALES_DOCUMENT_ITEM,
            level1.Sales_Document_MATERIAL_NUMBER,
            level1.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            level1.Module,
            level1.Parent_BILL_OF_MATERIAL,
            level1.Parent_BOM_COMPONENT,
            level1.Parent_BOM_ITEM_NUMBER,
            level1.Parent_COMPONENT_QUANTITY,
            level1.Parent_COMPONENT_UNIT_OF_MEASURE,
            level1.Parent_PROCUREMENT_TYPE,
            level1.Parent_SPECIAL_PROCUREMENT_TYPE,
            2 AS Level,
            level1.BILL_OF_MATERIAL,
            ITBL.BOM_COMPONENT,
            ITBL.BOM_ITEM_NUMBER,
            ITBL.COMPONENT_QUANTITY,
            ITBL.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT
                level1.SALES_DOCUMENT,
                level1.SALES_DOCUMENT_ITEM,
                level1.Sales_Document_MATERIAL_NUMBER,
                level1.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                level1.Module,
                level1.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                level1.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                level1.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                level1.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                level1.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                level1.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                level1.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                2 AS Level,
                ITBL.BILL_OF_MATERIAL
            FROM LEVEL1 AS level1
            LEFT JOIN CTE_BOM_LINK AS ITBL ON level1.BOM_COMPONENT = ITBL.MATERIAL_NUMBER
        ) AS level1
        LEFT JOIN (
            SELECT
                BILL_OF_MATERIAL,
                DATE_OF_LAST_CHANGE,
                BOM_COMPONENT,
                BOM_ITEM_NUMBER,
                COMPONENT_UNIT_OF_MEASURE,
                COMPONENT_QUANTITY
            FROM SILVER.TMEA_MANUFACTURING.BOM_ITEM
            WHERE DATE_OF_LAST_CHANGE IS NULL
        ) AS ITBL ON level1.BILL_OF_MATERIAL = ITBL.BILL_OF_MATERIAL
    ) AS level1
    LEFT JOIN CTE_PROCUREMENT_E AS ITBL ON level1.BOM_COMPONENT = ITBL.MATERIAL_NUMBER
    WHERE ITBL.PROCUREMENT_TYPE = 'E'
    ORDER BY
        level1.SALES_DOCUMENT_ITEM,
        level1.Parent_BOM_ITEM_NUMBER,
        level1.BOM_ITEM_NUMBER
),


LEVEL3 AS (
    SELECT 
        level2.SALES_DOCUMENT,
        level2.SALES_DOCUMENT_ITEM,
        level2.Sales_Document_MATERIAL_NUMBER,
        level2.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        CASE
            WHEN level2.Module != level2.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level2.BOM_COMPONENT, '-A') OR
                        CONTAINS(level2.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level2.BOM_COMPONENT, '-G') OR
                        CONTAINS(level2.BOM_COMPONENT, '-H') OR
                        CONTAINS(level2.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level2.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level2.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level2.BOM_COMPONENT, '-V') OR
                        CONTAINS(level2.BOM_COMPONENT, '-L') OR
                        CONTAINS(level2.BOM_COMPONENT, '-K') OR
                        CONTAINS(level2.BOM_COMPONENT, '-E') OR
                        CONTAINS(level2.BOM_COMPONENT, '-R') OR
                        CONTAINS(level2.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level2.BOM_COMPONENT, '-U') OR
                        CONTAINS(level2.BOM_COMPONENT, '-B') OR
                        CONTAINS(level2.BOM_COMPONENT, '-N')  
                    THEN level2.BOM_COMPONENT
                    ELSE level2.Module
                END
            ELSE level2.Parent_BOM_COMPONENT
        END AS MODULE,
        
        level2.Parent_BILL_OF_MATERIAL,
        level2.Parent_BOM_COMPONENT,
        level2.Parent_BOM_ITEM_NUMBER,
        level2.Parent_COMPONENT_QUANTITY,
        level2.Parent_COMPONENT_UNIT_OF_MEASURE,
        level2.Parent_PROCUREMENT_TYPE,
        level2.Parent_SPECIAL_PROCUREMENT_TYPE,
        3 AS Level,
        level2.BILL_OF_MATERIAL,
        level2.BOM_COMPONENT,
        level2.BOM_ITEM_NUMBER,
        level2.COMPONENT_QUANTITY,
        level2.COMPONENT_UNIT_OF_MEASURE,
        plant.PROCUREMENT_TYPE,
        plant.SPECIAL_PROCUREMENT_TYPE,
        plant.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            l2.SALES_DOCUMENT,
            l2.SALES_DOCUMENT_ITEM,
            l2.Sales_Document_MATERIAL_NUMBER,
            l2.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            l2.Module,
            l2.Parent_BILL_OF_MATERIAL,
            l2.Parent_BOM_COMPONENT,
            l2.Parent_BOM_ITEM_NUMBER,
            l2.Parent_COMPONENT_QUANTITY,
            l2.Parent_COMPONENT_UNIT_OF_MEASURE,
            l2.Parent_PROCUREMENT_TYPE,
            l2.Parent_SPECIAL_PROCUREMENT_TYPE,
            3 AS Level,
            l2.BILL_OF_MATERIAL,
            link.BOM_COMPONENT,
            link.BOM_ITEM_NUMBER,
            link.COMPONENT_QUANTITY,
            link.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT 
                l1.SALES_DOCUMENT,
                l1.SALES_DOCUMENT_ITEM,
                l1.Sales_Document_MATERIAL_NUMBER,
                l1.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                l1.Module,
                l1.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                l1.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                l1.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                l1.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                l1.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                l1.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                l1.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                3 AS Level,
                link2.BILL_OF_MATERIAL
            FROM LEVEL2 l1
            LEFT JOIN CTE_BOM_LINK link2 ON l1.BOM_COMPONENT = link2.MATERIAL_NUMBER
        ) l2
        LEFT JOIN CTE_BOM_ITEM link ON l2.BILL_OF_MATERIAL = link.BILL_OF_MATERIAL
    ) level2
    LEFT JOIN CTE_PROCUREMENT_E plant ON level2.BOM_COMPONENT = plant.MATERIAL_NUMBER
    WHERE plant.PROCUREMENT_TYPE = 'E'
    ORDER BY 
        level2.SALES_DOCUMENT_ITEM,
        level2.Parent_BOM_ITEM_NUMBER,
        level2.BOM_ITEM_NUMBER
),

LEVEL4 AS (
    SELECT 
        level3.SALES_DOCUMENT,
        level3.SALES_DOCUMENT_ITEM,
        level3.Sales_Document_MATERIAL_NUMBER,
        level3.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        CASE
            WHEN level3.Module != level3.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level3.BOM_COMPONENT, '-A') OR
                        CONTAINS(level3.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level3.BOM_COMPONENT, '-G') OR
                        CONTAINS(level3.BOM_COMPONENT, '-H') OR
                        CONTAINS(level3.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level3.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level3.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level3.BOM_COMPONENT, '-V') OR
                        CONTAINS(level3.BOM_COMPONENT, '-L') OR
                        CONTAINS(level3.BOM_COMPONENT, '-K') OR
                        CONTAINS(level3.BOM_COMPONENT, '-E') OR
                        CONTAINS(level3.BOM_COMPONENT, '-R') OR
                        CONTAINS(level3.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level3.BOM_COMPONENT, '-U') OR
                        CONTAINS(level3.BOM_COMPONENT, '-B') OR
                        CONTAINS(level3.BOM_COMPONENT, '-N')  
                    THEN level3.BOM_COMPONENT
                    ELSE level3.Module
                END
            ELSE level3.Parent_BOM_COMPONENT
        END AS MODULE,
        
        level3.Parent_BILL_OF_MATERIAL,
        level3.Parent_BOM_COMPONENT,
        level3.Parent_BOM_ITEM_NUMBER,
        level3.Parent_COMPONENT_QUANTITY,
        level3.Parent_COMPONENT_UNIT_OF_MEASURE,
        level3.Parent_PROCUREMENT_TYPE,
        level3.Parent_SPECIAL_PROCUREMENT_TYPE,
        4 AS Level,
        level3.BILL_OF_MATERIAL,
        level3.BOM_COMPONENT,
        level3.BOM_ITEM_NUMBER,
        level3.COMPONENT_QUANTITY,
        level3.COMPONENT_UNIT_OF_MEASURE,
        plant.PROCUREMENT_TYPE,
        plant.SPECIAL_PROCUREMENT_TYPE,
        plant.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            l3.SALES_DOCUMENT,
            l3.SALES_DOCUMENT_ITEM,
            l3.Sales_Document_MATERIAL_NUMBER,
            l3.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            l3.Module,
            l3.Parent_BILL_OF_MATERIAL,
            l3.Parent_BOM_COMPONENT,
            l3.Parent_BOM_ITEM_NUMBER,
            l3.Parent_COMPONENT_QUANTITY,
            l3.Parent_COMPONENT_UNIT_OF_MEASURE,
            l3.Parent_PROCUREMENT_TYPE,
            l3.Parent_SPECIAL_PROCUREMENT_TYPE,
            4 AS Level,
            l3.BILL_OF_MATERIAL,
            link.BOM_COMPONENT,
            link.BOM_ITEM_NUMBER,
            link.COMPONENT_QUANTITY,
            link.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT 
                l2.SALES_DOCUMENT,
                l2.SALES_DOCUMENT_ITEM,
                l2.Sales_Document_MATERIAL_NUMBER,
                l2.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                l2.Module,
                l2.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                l2.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                l2.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                l2.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                l2.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                l2.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                l2.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                4 AS Level,
                mtbl.BILL_OF_MATERIAL
            FROM LEVEL3 l2
            LEFT JOIN CTE_BOM_LINK mtbl ON l2.BOM_COMPONENT = mtbl.MATERIAL_NUMBER
        ) l3
        LEFT JOIN CTE_BOM_ITEM link ON l3.BILL_OF_MATERIAL = link.BILL_OF_MATERIAL
    ) level3
    LEFT JOIN CTE_PROCUREMENT_E plant ON level3.BOM_COMPONENT = plant.MATERIAL_NUMBER
    WHERE plant.PROCUREMENT_TYPE = 'E'
    ORDER BY 
        level3.SALES_DOCUMENT_ITEM,
        level3.Parent_BOM_ITEM_NUMBER,
        level3.BOM_ITEM_NUMBER
),

LEVEL5 AS (
    SELECT 
        level4.SALES_DOCUMENT,
        level4.SALES_DOCUMENT_ITEM,
        level4.Sales_Document_MATERIAL_NUMBER,
        level4.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        CASE
            WHEN level4.Module != level4.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level4.BOM_COMPONENT, '-A') OR
                        CONTAINS(level4.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level4.BOM_COMPONENT, '-G') OR
                        CONTAINS(level4.BOM_COMPONENT, '-H') OR
                        CONTAINS(level4.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level4.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level4.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level4.BOM_COMPONENT, '-V') OR
                        CONTAINS(level4.BOM_COMPONENT, '-L') OR
                        CONTAINS(level4.BOM_COMPONENT, '-K') OR
                        CONTAINS(level4.BOM_COMPONENT, '-E') OR
                        CONTAINS(level4.BOM_COMPONENT, '-R') OR
                        CONTAINS(level4.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level4.BOM_COMPONENT, '-U') OR
                        CONTAINS(level4.BOM_COMPONENT, '-B') OR
                        CONTAINS(level4.BOM_COMPONENT, '-N')  
                    THEN level4.BOM_COMPONENT
                    ELSE level4.Module
                END
            ELSE level4.Parent_BOM_COMPONENT
        END AS MODULE,
        
        level4.Parent_BILL_OF_MATERIAL,
        level4.Parent_BOM_COMPONENT,
        level4.Parent_BOM_ITEM_NUMBER,
        level4.Parent_COMPONENT_QUANTITY,
        level4.Parent_COMPONENT_UNIT_OF_MEASURE,
        level4.Parent_PROCUREMENT_TYPE,
        level4.Parent_SPECIAL_PROCUREMENT_TYPE,
        5 AS Level,
        level4.BILL_OF_MATERIAL,
        level4.BOM_COMPONENT,
        level4.BOM_ITEM_NUMBER,
        level4.COMPONENT_QUANTITY,
        level4.COMPONENT_UNIT_OF_MEASURE,
        plant.PROCUREMENT_TYPE,
        plant.SPECIAL_PROCUREMENT_TYPE,
        plant.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            l4.SALES_DOCUMENT,
            l4.SALES_DOCUMENT_ITEM,
            l4.Sales_Document_MATERIAL_NUMBER,
            l4.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            l4.Module,
            l4.Parent_BILL_OF_MATERIAL,
            l4.Parent_BOM_COMPONENT,
            l4.Parent_BOM_ITEM_NUMBER,
            l4.Parent_COMPONENT_QUANTITY,
            l4.Parent_COMPONENT_UNIT_OF_MEASURE,
            l4.Parent_PROCUREMENT_TYPE,
            l4.Parent_SPECIAL_PROCUREMENT_TYPE,
            5 AS Level,
            l4.BILL_OF_MATERIAL,
            link.BOM_COMPONENT,
            link.BOM_ITEM_NUMBER,
            link.COMPONENT_QUANTITY,
            link.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT 
                l3.SALES_DOCUMENT,
                l3.SALES_DOCUMENT_ITEM,
                l3.Sales_Document_MATERIAL_NUMBER,
                l3.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                l3.Module,
                l3.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                l3.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                l3.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                l3.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                l3.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                l3.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                l3.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                5 AS Level,
                mtbl.BILL_OF_MATERIAL
            FROM LEVEL4 l3
            LEFT JOIN CTE_BOM_LINK mtbl ON l3.BOM_COMPONENT = mtbl.MATERIAL_NUMBER
        ) l4
        LEFT JOIN CTE_BOM_ITEM link ON l4.BILL_OF_MATERIAL = link.BILL_OF_MATERIAL
    ) level4
    LEFT JOIN CTE_PROCUREMENT_E plant ON level4.BOM_COMPONENT = plant.MATERIAL_NUMBER
    WHERE plant.PROCUREMENT_TYPE = 'E'
    ORDER BY 
        level4.SALES_DOCUMENT_ITEM,
        level4.Parent_BOM_ITEM_NUMBER,
        level4.BOM_ITEM_NUMBER
),

LEVEL6 AS (
    SELECT 
        level5.SALES_DOCUMENT,
        level5.SALES_DOCUMENT_ITEM,
        level5.Sales_Document_MATERIAL_NUMBER,
        level5.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        CASE
            WHEN level5.Module != level5.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level5.BOM_COMPONENT, '-A') OR
                        CONTAINS(level5.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level5.BOM_COMPONENT, '-G') OR
                        CONTAINS(level5.BOM_COMPONENT, '-H') OR
                        CONTAINS(level5.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level5.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level5.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level5.BOM_COMPONENT, '-V') OR
                        CONTAINS(level5.BOM_COMPONENT, '-L') OR
                        CONTAINS(level5.BOM_COMPONENT, '-K') OR
                        CONTAINS(level5.BOM_COMPONENT, '-E') OR
                        CONTAINS(level5.BOM_COMPONENT, '-R') OR
                        CONTAINS(level5.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level5.BOM_COMPONENT, '-U') OR
                        CONTAINS(level5.BOM_COMPONENT, '-B') OR
                        CONTAINS(level5.BOM_COMPONENT, '-N')  
                    THEN level5.BOM_COMPONENT
                    ELSE level5.Module
                END
            ELSE level5.Parent_BOM_COMPONENT
        END AS MODULE,
        level5.Parent_BILL_OF_MATERIAL,
        level5.Parent_BOM_COMPONENT,
        level5.Parent_BOM_ITEM_NUMBER,
        level5.Parent_COMPONENT_QUANTITY,
        level5.Parent_COMPONENT_UNIT_OF_MEASURE,
        level5.Parent_PROCUREMENT_TYPE,
        level5.Parent_SPECIAL_PROCUREMENT_TYPE,
        6 AS Level,
        level5.BILL_OF_MATERIAL,
        level5.BOM_COMPONENT,
        level5.BOM_ITEM_NUMBER,
        level5.COMPONENT_QUANTITY,
        level5.COMPONENT_UNIT_OF_MEASURE,
        plant.PROCUREMENT_TYPE,
        plant.SPECIAL_PROCUREMENT_TYPE,
        plant.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            l5.SALES_DOCUMENT,
            l5.SALES_DOCUMENT_ITEM,
            l5.Sales_Document_MATERIAL_NUMBER,
            l5.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            l5.Module,
            l5.Parent_BILL_OF_MATERIAL,
            l5.Parent_BOM_COMPONENT,
            l5.Parent_BOM_ITEM_NUMBER,
            l5.Parent_COMPONENT_QUANTITY,
            l5.Parent_COMPONENT_UNIT_OF_MEASURE,
            l5.Parent_PROCUREMENT_TYPE,
            l5.Parent_SPECIAL_PROCUREMENT_TYPE,
            6 AS Level,
            l5.BILL_OF_MATERIAL,
            link.BOM_COMPONENT,
            link.BOM_ITEM_NUMBER,
            link.COMPONENT_QUANTITY,
            link.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT 
                l4.SALES_DOCUMENT,
                l4.SALES_DOCUMENT_ITEM,
                l4.Sales_Document_MATERIAL_NUMBER,
                l4.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                l4.Module,
                l4.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                l4.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                l4.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                l4.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                l4.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                l4.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                l4.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                6 AS Level,
                mtbl.BILL_OF_MATERIAL
            FROM LEVEL5 l4
            LEFT JOIN CTE_BOM_LINK mtbl ON l4.BOM_COMPONENT = mtbl.MATERIAL_NUMBER
        ) l5
        LEFT JOIN CTE_BOM_ITEM link ON l5.BILL_OF_MATERIAL = link.BILL_OF_MATERIAL
    ) level5
    LEFT JOIN CTE_PROCUREMENT_E plant ON level5.BOM_COMPONENT = plant.MATERIAL_NUMBER
    WHERE plant.PROCUREMENT_TYPE = 'E'
    ORDER BY 
        level5.SALES_DOCUMENT_ITEM,
        level5.Parent_BOM_ITEM_NUMBER,
        level5.BOM_ITEM_NUMBER
),

 LEVEL7 AS (
    SELECT 
        level6.SALES_DOCUMENT,
        level6.SALES_DOCUMENT_ITEM,
        level6.Sales_Document_MATERIAL_NUMBER,
        level6.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
        
        CASE
            WHEN level6.Module != level6.Parent_BOM_COMPONENT THEN
                CASE
                    WHEN 
                        CONTAINS(level6.BOM_COMPONENT, '-A') OR
                        CONTAINS(level6.BOM_COMPONENT, '-F') OR 
                        CONTAINS(level6.BOM_COMPONENT, '-G') OR
                        CONTAINS(level6.BOM_COMPONENT, '-H') OR
                        CONTAINS(level6.BOM_COMPONENT, '-M') OR 
                        CONTAINS(level6.BOM_COMPONENT, '-S') OR 
                        CONTAINS(level6.BOM_COMPONENT, '-T') OR  
                        CONTAINS(level6.BOM_COMPONENT, '-V') OR
                        CONTAINS(level6.BOM_COMPONENT, '-L') OR
                        CONTAINS(level6.BOM_COMPONENT, '-K') OR
                        CONTAINS(level6.BOM_COMPONENT, '-E') OR
                        CONTAINS(level6.BOM_COMPONENT, '-R') OR
                        CONTAINS(level6.BOM_COMPONENT, '-C0') OR
                        CONTAINS(level6.BOM_COMPONENT, '-U') OR
                        CONTAINS(level6.BOM_COMPONENT, '-B') OR
                        CONTAINS(level6.BOM_COMPONENT, '-N')  
                    THEN level6.BOM_COMPONENT
                    ELSE level6.Module
                END
            ELSE level6.Parent_BOM_COMPONENT
        END AS MODULE,
        
        level6.Parent_BILL_OF_MATERIAL,
        level6.Parent_BOM_COMPONENT,
        level6.Parent_BOM_ITEM_NUMBER,
        level6.Parent_COMPONENT_QUANTITY,
        level6.Parent_COMPONENT_UNIT_OF_MEASURE,
        level6.Parent_PROCUREMENT_TYPE,
        level6.Parent_SPECIAL_PROCUREMENT_TYPE,
        7 AS Level,
        level6.BILL_OF_MATERIAL,
        level6.BOM_COMPONENT,
        level6.BOM_ITEM_NUMBER,
        level6.COMPONENT_QUANTITY,
        level6.COMPONENT_UNIT_OF_MEASURE,
        plant.PROCUREMENT_TYPE,
        plant.SPECIAL_PROCUREMENT_TYPE,
        plant.MRP_CONTROLLER_MATERIALS_PLANNER
    FROM (
        SELECT 
            l6.SALES_DOCUMENT,
            l6.SALES_DOCUMENT_ITEM,
            l6.Sales_Document_MATERIAL_NUMBER,
            l6.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
            l6.Module,
            l6.Parent_BILL_OF_MATERIAL,
            l6.Parent_BOM_COMPONENT,
            l6.Parent_BOM_ITEM_NUMBER,
            l6.Parent_COMPONENT_QUANTITY,
            l6.Parent_COMPONENT_UNIT_OF_MEASURE,
            l6.Parent_PROCUREMENT_TYPE,
            l6.Parent_SPECIAL_PROCUREMENT_TYPE,
            7 AS Level,
            l6.BILL_OF_MATERIAL,
            link.BOM_COMPONENT,
            link.BOM_ITEM_NUMBER,
            link.COMPONENT_QUANTITY,
            link.COMPONENT_UNIT_OF_MEASURE
        FROM (
            SELECT 
                l5.SALES_DOCUMENT,
                l5.SALES_DOCUMENT_ITEM,
                l5.Sales_Document_MATERIAL_NUMBER,
                l5.SHORT_TEXT_FOR_SALES_ORDER_ITEM,
                l5.Module,
                l5.BILL_OF_MATERIAL AS Parent_BILL_OF_MATERIAL,
                l5.BOM_COMPONENT AS Parent_BOM_COMPONENT,
                l5.BOM_ITEM_NUMBER AS Parent_BOM_ITEM_NUMBER,
                l5.COMPONENT_QUANTITY AS Parent_COMPONENT_QUANTITY,
                l5.COMPONENT_UNIT_OF_MEASURE AS Parent_COMPONENT_UNIT_OF_MEASURE,
                l5.PROCUREMENT_TYPE AS Parent_PROCUREMENT_TYPE,
                l5.SPECIAL_PROCUREMENT_TYPE AS Parent_SPECIAL_PROCUREMENT_TYPE,
                7 AS Level,
                mtbl.BILL_OF_MATERIAL
            FROM LEVEL6 l5
            LEFT JOIN (
                -- Map MATERIAL_NUMBER to BILL_OF_MATERIAL for plant '0010'
                SELECT MATERIAL_NUMBER, BILL_OF_MATERIAL
                FROM SILVER.TMEA_MANUFACTURING.MATERIAL_TO_BOM_LINK
                WHERE PLANT = '0010'
            ) mtbl ON l5.BOM_COMPONENT = mtbl.MATERIAL_NUMBER
        ) l6
        LEFT JOIN (
            SELECT 
                BILL_OF_MATERIAL,
                BOM_COMPONENT,
                BOM_ITEM_NUMBER,
                COMPONENT_UNIT_OF_MEASURE,
                COMPONENT_QUANTITY
            FROM SILVER.TMEA_MANUFACTURING.BOM_ITEM
            WHERE DATE_OF_LAST_CHANGE IS NULL
        ) link ON l6.BILL_OF_MATERIAL = link.BILL_OF_MATERIAL
    ) level6
    LEFT JOIN (
        -- Plant-specific procurement data with PROCUREMENT_TYPE='E' and PLANT='0010'
        SELECT MATERIAL_NUMBER,
               PROCUREMENT_TYPE,
               SPECIAL_PROCUREMENT_TYPE,
               MRP_CONTROLLER_MATERIALS_PLANNER
        FROM SILVER.TMEA_MANUFACTURING.PLANT_DATA_FOR_MATERIAL
        WHERE PLANT = '0010' AND PROCUREMENT_TYPE = 'E'
    ) plant ON level6.BOM_COMPONENT = plant.MATERIAL_NUMBER
    WHERE plant.PROCUREMENT_TYPE = 'E'
    ORDER BY 
        level6.SALES_DOCUMENT_ITEM,
        level6.Parent_BOM_ITEM_NUMBER,
        level6.BOM_ITEM_NUMBER
),

BOM AS (
    SELECT * FROM LEVEL0
    UNION ALL
    SELECT * FROM LEVEL1
    UNION ALL
    SELECT * FROM LEVEL2
    UNION ALL
    SELECT * FROM LEVEL3
    UNION ALL
    SELECT * FROM LEVEL4
    UNION ALL
    SELECT * FROM LEVEL5
    UNION ALL
    SELECT * FROM LEVEL6
    UNION ALL
    SELECT * FROM LEVEL7
),

ACTUAL_SHIP_DATE AS (
    SELECT DISTINCT 
        PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT AS SALES_ORDER,
        MAX(VBFA.DATE_ON_WHICH_RECORD_WAS_CREATED) AS ACTUAL_SHIP_DATE
    FROM SILVER.TMEA_MANUFACTURING.SALES_DOCUMENT_FLOW VBFA
    WHERE DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'R'
        AND MOVEMENT_TYPE_ = '601'
        AND DOCUMENT_CATEGORY_OF_PRECEDING_SD_DOCUMENT = 'C'
    GROUP BY PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT
), 

BOM AS (
    -- Combine all levels into a unified BOM dataset
    SELECT * FROM LEVEL0
    UNION ALL SELECT * FROM LEVEL1
    UNION ALL SELECT * FROM LEVEL2
    UNION ALL SELECT * FROM LEVEL3
    UNION ALL SELECT * FROM LEVEL4
    UNION ALL SELECT * FROM LEVEL5
    UNION ALL SELECT * FROM LEVEL6
    UNION ALL SELECT * FROM LEVEL7
),

ACTUAL_SHIP_DATE AS (
    SELECT 
        PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT AS SALES_ORDER,
        MAX(VBFA.DATE_ON_WHICH_RECORD_WAS_CREATED) AS ACTUAL_SHIP_DATE
    FROM SILVER.TMEA_MANUFACTURING.SALES_DOCUMENT_FLOW VBFA
    WHERE DOCUMENT_CATEGORY_OF_SUBSEQUENT_DOCUMENT = 'R'
      AND MOVEMENT_TYPE_ = '601'
      AND DOCUMENT_CATEGORY_OF_PRECEDING_SD_DOCUMENT = 'C'
    GROUP BY PRECEDING_SALES_AND_DISTRIBUTION_DOCUMENT
),

OUTPUT AS (
    SELECT
        TRIM(CAST(TO_NUMBER(SALES_DOCUMENT) AS TEXT)) AS SALES_NUMBER,
        SALES_DOCUMENT_MATERIAL_NUMBER AS MATERIAL_NUMBER_ON_SO,
        CASE 
            WHEN CONCAT(SUBSTR(SALES_DOCUMENT_MATERIAL_NUMBER, 1, 3), 'A', SUBSTR(SALES_DOCUMENT_MATERIAL_NUMBER, -4)) = 'AV-A0024' 
                THEN 'GB-A0001' 
            ELSE CONCAT(SUBSTR(SALES_DOCUMENT_MATERIAL_NUMBER, 1, 3), 'A', SUBSTR(SALES_DOCUMENT_MATERIAL_NUMBER, -4)) 
        END AS TOOL_NUMBER,
        SHORT_TEXT_FOR_SALES_ORDER_ITEM AS TOOL_DESCRIPTION,
        BOM.MODULE,
        M.MRP_CONTROLLER_MATERIALS_PLANNER AS PARENT_MRP_CONTROLLER,
        BOM.PARENT_BOM_COMPONENT AS PARENT_MATERIAL,
        BOM.PARENT_COMPONENT_QUANTITY AS PARENT_QTY,
        BOM.PARENT_COMPONENT_UNIT_OF_MEASURE AS PARENT_UNITS,
        BOM.PARENT_PROCUREMENT_TYPE AS PARENT_PROC_TYPE,
        BOM.PARENT_SPECIAL_PROCUREMENT_TYPE AS PARENT_SPEC_PROC_TYPE,
        BOM.BOM_COMPONENT AS LOWER_MATERIAL,
        BOM.COMPONENT_QUANTITY AS LOWER_QTY,
        BOM.COMPONENT_UNIT_OF_MEASURE AS LOWER_UNITS,
        BOM.PROCUREMENT_TYPE AS LOWER_PROC_TYPE,
        BOM.SPECIAL_PROCUREMENT_TYPE AS LOWER_SPEC_PROC_TYPE,
        BOM.MRP_CONTROLLER_MATERIALS_PLANNER AS LOWER_MRP_CONTROLLER,
        ASD.ACTUAL_SHIP_DATE
    FROM 
        BOM
    LEFT JOIN ACTUAL_SHIP_DATE ASD ON BOM.SALES_DOCUMENT = ASD.SALES_ORDER
    LEFT JOIN CTE_Material_Data M ON BOM.PARENT_BOM_COMPONENT = M.MATERIAL_NUMBER
),

FILTERED_BOM AS (
    SELECT
        SALES_NUMBER,
        MATERIAL_NUMBER_ON_SO,
        TOOL_NUMBER,  
        TOOL_DESCRIPTION,
        MODULE,
        COALESCE(NULLIF(PARENT_MRP_CONTROLLER, ''), LOWER_MRP_CONTROLLER) AS PARENT_MRP_CONTROLLER,
        COALESCE(NULLIF(PARENT_MATERIAL, ''), LOWER_MATERIAL) AS PARENT_MATERIAL,
        COALESCE(PARENT_QTY, LOWER_QTY) AS PARENT_QTY,
        COALESCE(NULLIF(PARENT_UNITS, ''), LOWER_UNITS) AS PARENT_UNITS,
        COALESCE(NULLIF(PARENT_PROC_TYPE, ''), LOWER_PROC_TYPE) AS PARENT_PROC_TYPE,
        COALESCE(NULLIF(PARENT_SPEC_PROC_TYPE, ''), LOWER_SPEC_PROC_TYPE) AS PARENT_SPEC_PROC_TYPE,
        LOWER_MATERIAL,
        LOWER_QTY, 
        LOWER_UNITS,
        LOWER_PROC_TYPE,
        LOWER_SPEC_PROC_TYPE,
        LOWER_MRP_CONTROLLER,
        ACTUAL_SHIP_DATE
    FROM OUTPUT
    WHERE 
     (
        MATERIAL_NUMBER_ON_SO LIKE 'Z2-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'Z3-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'UT-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'AN-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'AV-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'GB-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'MP-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'B1-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'P2-%'
     OR MATERIAL_NUMBER_ON_SO LIKE 'FN-%'
        )
     AND NOT 
        (
        MATERIAL_NUMBER_ON_SO LIKE '%-Q0%' OR
        MATERIAL_NUMBER_ON_SO LIKE '%-P0%' OR
        MATERIAL_NUMBER_ON_SO LIKE '%RFS'
        )
    AND MATERIAL_NUMBER_ON_SO NOT IN ('GB-A0001', 'GB-C0001') 
    AND LOWER_SPEC_PROC_TYPE <> '50'
),
transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
		SHA2('hash_me') as _ROW_HASH,
        SALES_NUMBER,
        MATERIAL_NUMBER_ON_SO,
        TOOL_NUMBER,
        TOOL_DESCRIPTION,
        MODULE,
        PARENT_MRP_CONTROLLER,
        PARENT_MATERIAL,
        PARENT_QTY,
        PARENT_UNITS,
        PARENT_PROC_TYPE,
        PARENT_SPEC_PROC_TYPE,
        LOWER_MATERIAL,
        LOWER_QTY, 
        LOWER_UNITS,
        LOWER_PROC_TYPE,
        LOWER_SPEC_PROC_TYPE,
        LOWER_MRP_CONTROLLER,
        ACTUAL_SHIP_DATE
    FROM FILTERED_BOM
    ORDER BY 
    SALES_NUMBER,
    MODULE,
    PARENT_MATERIAL,
    LOWER_MATERIAL
),
type_data as (
    SELECT
        cast(_AUDIT_LOG_ID as VARCHAR(128)) as _AUDIT_LOG_ID,
		cast(_ROW_HASH as VARCHAR(128)) as _ROW_HASH,
        SALES_NUMBER,
        MATERIAL_NUMBER_ON_SO,
        TOOL_NUMBER,
        TOOL_DESCRIPTION,
        MODULE,
        PARENT_MRP_CONTROLLER,
        PARENT_MATERIAL,
        PARENT_QTY::NUMBER(38,6) as PARENT_QTY,
        PARENT_UNITS,
        PARENT_PROC_TYPE,
        PARENT_SPEC_PROC_TYPE,
        LOWER_MATERIAL,
        LOWER_QTY::NUMBER(38,6) as LOWER_QTY,
        LOWER_UNITS,
        LOWER_PROC_TYPE,
        LOWER_SPEC_PROC_TYPE,
        LOWER_MRP_CONTROLLER,
        ACTUAL_SHIP_DATE::DATE as ACTUAL_SHIP_DATE
    FROM transform_data
)

SELECT * FROM type_data
