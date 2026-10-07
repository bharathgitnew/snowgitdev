{{ config(
    	materialized='tel_incremental',
    	incremental_strategy='insert_overwrite',
    	alias='PLANNING_OVERCOMMIT_INVENTORY',
    	transient=false
) }}

WITH MRP_DATA AS( SELECT DISTINCT
        pg.description_of_purchasing_group as Buyer_Name,
        hdmd.material_number,
        HDMD.MRP_DATE,
        mdes.material_description,
        prof.profit_center,
        smt.exception_message_key,
        SMT.STORAGE_LOCATION,
        SMT.PROCUREMENT_TYPE,
        SMT.RECEIPT_REQUIREMENTS_DATE,
        SMT.MRP_ELEMENT,
        SMT.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED,
        SMT.MRP_ELEMENT_NUMBER,
        SMT.MATERIAL_NUMBER_OF_HIGHER_LEVEL_ASSEMBLY,
        HDMD.PLANT

FROM {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MRP_TABLE') }} as SMT
inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__HEADER_DATA_FOR_MRP_DOCUMENT') }} as HDMD
on HDMD.NUMBER_OF_MATERIAL_REQUIREMENTS_PLANNING_TABLE = smt.number_of_material_requirements_planning_table

 inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__GENERAL_MATERIAL_DATA') }} AS gm
 on gm.material_number = HDMD.material_number
 
inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PLANT_DATA_FOR_MATERIAL') }} as pm
on pm.material_number = hdmd.material_number
and HDMD.plant = pm.plant

inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_DESCRIPTIONS') }} as mdes
on mdes.material_number = hdmd.material_number


inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_GROUP_DESCRIPTIONS') }} as mtgdes
on mtgdes.material_group = gm.material_group

left join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PROFIT_CENTER_DESCRIPTION') }} as prof
on prof.profit_center = pm.profit_center

inner join {{ ref('SILVER__TMEA_SUPPLY_CHAIN__PURCHASING_GROUPS') }} as pg
on pg.purchasing_group = pm.purchasing_group
where pg.SPOOL_OUTPUT_DEVICE = 'EMAI'
and HDMD.PLANT = '0010'


),


Qty as (select distinct
MRP_DATA.material_number,

sum (MRP_DATA.QUANTITY_RECEIVED_OR_QUANTITY_REQUIRED) as Total_Qty_Overcommit

from MRP_DATA as MRP_DATA

where exception_message_key = 'U3'
group by MRP_DATA.material_number
),




material_valuation as (select distinct
        mv.material_number,
        mv.standard_price,
        mv.price_unit,
        mv.valuation_area,
        mv.standard_price/ mv.price_unit AS net_price
from {{ ref('SILVER__TMEA_SUPPLY_CHAIN__MATERIAL_VALUATION') }} as mv

),

final AS (SELECT DISTINCT 
        mrp_data.exception_message_key,
        MRP_DATA.MATERIAL_NUMBER,
        MRP_DATA.material_description,
        MRP_DATA.Buyer_Name,
        material_valuation.pRICE_UNIT,
        MRP_DATA.STORAGE_LOCATION,
        MRP_DATA.profit_center,
        material_valuation.standard_price,
        material_valuation.NET_PRICE,
        Total_Qty_Overcommit ,
        Total_Qty_Overcommit *  material_valuation.NET_PRICE as Overcommit_Amount

FROM MRP_DATA as MRP_DATA

inner JOIN material_valuation AS material_valuation
on material_valuation.MATERIAL_NUMBER = MRP_DATA.MATERIAL_NUMBER

inner JOIN Qty AS Qty
on Qty.MATERIAL_NUMBER = MRP_DATA.MATERIAL_NUMBER
),

source_data
AS (
SELECT distinct 
        EXCEPTION_MESSAGE_KEY,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        BUYER_NAME,
        PRICE_UNIT,
        STORAGE_LOCATION,
        PROFIT_CENTER,
        STANDARD_PRICE,
        NET_PRICE,
        TOTAL_QTY_OVERCOMMIT,
        OVERCOMMIT_AMOUNT
         FROM FINAL 
where OVERCOMMIT_AMOUNT >0
and exception_message_key = 'U3'
ORDER BY OVERCOMMIT_AMOUNT DESC
),
transform_data
AS (
	SELECT 
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
        EXCEPTION_MESSAGE_KEY,
        MATERIAL_NUMBER,
        MATERIAL_DESCRIPTION,
        BUYER_NAME,
        PRICE_UNIT,
        STORAGE_LOCATION,
        PROFIT_CENTER,
        STANDARD_PRICE,
        NET_PRICE,
        TOTAL_QTY_OVERCOMMIT,
        OVERCOMMIT_AMOUNT
	FROM source_data
	),
type_data
AS (
	SELECT 
		 CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
		 CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		 CAST(EXCEPTION_MESSAGE_KEY AS VARCHAR(16777216)) AS EXCEPTION_MESSAGE_KEY,
		 CAST(MATERIAL_NUMBER AS VARCHAR(16777216)) AS MATERIAL_NUMBER,
		 CAST(MATERIAL_DESCRIPTION AS VARCHAR(16777216)) AS MATERIAL_DESCRIPTION,
		 CAST(BUYER_NAME AS VARCHAR(16777216)) AS BUYER_NAME,
		 CAST(PRICE_UNIT AS NUMBER(38,10)) AS PRICE_UNIT,
		 CAST(STORAGE_LOCATION AS VARCHAR(16777216)) AS STORAGE_LOCATION,
		 CAST(PROFIT_CENTER AS VARCHAR(16777216)) AS PROFIT_CENTER,
		 CAST(STANDARD_PRICE AS NUMBER(38,10)) AS STANDARD_PRICE,
		 CAST(NET_PRICE AS NUMBER(38,12)) AS NET_PRICE,
		 CAST(TOTAL_QTY_OVERCOMMIT AS NUMBER(38,10)) AS TOTAL_QTY_OVERCOMMIT,
		 CAST(OVERCOMMIT_AMOUNT AS NUMBER(38,12)) AS OVERCOMMIT_AMOUNT
	FROM transform_data
	)
SELECT *
FROM type_data