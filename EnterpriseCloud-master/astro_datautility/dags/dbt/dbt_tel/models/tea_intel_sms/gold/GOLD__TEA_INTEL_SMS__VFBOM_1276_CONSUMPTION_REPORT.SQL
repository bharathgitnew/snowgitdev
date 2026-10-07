{{ config(
        alias = 'VFBOM_1276_CONSUMPTION_REPORT',
        materialized='tel_incremental',
        incremental_strategy = 'insert_overwrite',
        transient = false,
    	tags=['MSBI']
) }}

WITH vfbom_org
AS (
	SELECT 
		FILEDATE,
		process,
		CONSOLIDATED_SPN,
		OEM_SPN,
		ALTERNATE_REPAIRED_SPN,
		INTEL_PART_NUMBER,
		ITEM_DESCRIPTION,
		INVENTORYCATEGORY1,
		Machine_Type,
		MSQLOW,
		MSQHIGH
	FROM {{ ref('BRONZE__TEA_INTEL_SMS__FILE_INTEL_VFBOM') }} 
	WHERE process ilike '1276'
	),
vfbom
AS (
	SELECT DISTINCT 
		FILEDATE,
		substr(process, 0, 4) AS process,
		CONSOLIDATED_SPN,
		OEM_SPN,
		ALTERNATE_REPAIRED_SPN,
		INTEL_PART_NUMBER,
		ITEM_DESCRIPTION,
		INVENTORYCATEGORY1,
		MSQLOW,
		MSQHIGH
	FROM vfbom_org
	),
Machine
AS (
	SELECT DISTINCT CONSOLIDATED_SPN,
		Machine_Type
	FROM VFBOM_org
	ORDER BY Machine_Type
	),
header
AS (
	SELECT CONSOLIDATED_SPN,
		listagg(Machine_Type, '|') within
	GROUP (
			ORDER BY Machine_Type
			) AS Machine_Type
	FROM machine
	GROUP BY CONSOLIDATED_SPN
	),
COST_PN
AS (
	SELECT bwkey,
		matnr,
		STPRS
	FROM  {{ ref('BRONZE__TEA_INTEL_SMS__SAPH_SAP_US_MMT_EV_MBEW') }}
	WHERE BWKEY = '3200'
	),
demand
AS (
	SELECT item AS MATDOC_MATERIAL_NUMBER,
		CONCAT (
			year(PERIOD),
			LPAD(month(PERIOD), 2, '0')
			) AS YEARMONTH,
		SOLD_TO_BP AS SOLD_TO_BP_CODE,
		REGION,
		DATEDIFF(month, PERIOD, CURRENT_DATE - 1) AS MOU_month,
		sum(SO_QTY) AS QTY
	FROM {{ ref('SILVER__TEA_INTEL_SMS__DEMAND_BY_SITE_V2') }}
	WHERE PERIOD >= DATEADD(month, - 35, CURRENT_DATE - 1)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		PERIOD,
		SOLD_TO_BP,
		REGION
	/*Adding TEE data */
	
	UNION ALL
	
	select MATERIAL_NUMBER as MATDOC_MATERIAL_NUMBER,concat( SUBSTR(PERIOD, 1, 4),SUBSTR(PERIOD, 6, 2)) as YEARMONTH
  			, SOLD_TO_BP, 'IE' as REGION,
DATEDIFF(month,order_date,current_date - 1 ) as MOU_month,
sum(ORDER_QUANTITY) as QTY
from {{ ref('BRONZE__TEA_INTEL_SMS__FILE_BAAN_TEE_SALES') }}
where SOLD_TO_BP IN ('I73300')
and order_date >= DATEADD(month,-35,current_date - 1)
group by MATERIAL_NUMBER,period,SOLD_TO_BP,ORDER_DATE
	),
M12_sum
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		MOU_month,
		SUM(QTY) AS qty
	FROM demand
	WHERE (
			SOLD_TO_BP_CODE IN (
				'Intel-INTD1C',
				'Intel-INTD1D',
				'Intel-INTD1X'
				)
			OR REGION IN (
				'OR',
				'IE'
				)
			)
		AND YEARMONTH >= CONCAT (
			year(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)),
			LPAD(month(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)), 2, '0')
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		MOU_month
	),
IR_MOU
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month,
		(
			CASE 
				WHEN sum(qty) > 0
					THEN 1
				ELSE 0
				END
			) AS count_Qty
	FROM demand
	WHERE REGION IN ('IE')
		AND YEARMONTH >= CONCAT (
			year(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)),
			LPAD(month(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)), 2, '0')
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month
	),
IR_MOU_total
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(count_Qty) AS count_Qty
	FROM IR_MOU
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
OR_MOU
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month,
		(
			CASE 
				WHEN sum(qty) > 0
					THEN 1
				ELSE 0
				END
			) AS count_Qty
	FROM demand
	WHERE (
			SOLD_TO_BP_CODE IN (
				'Intel-INTD1C',
				'Intel-INTD1D',
				'Intel-INTD1X'
				)
			OR REGION = 'OR'
			)
		AND YEARMONTH >= CONCAT (
			year(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)),
			LPAD(month(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)), 2, '0')
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month
	),
OR_MOU_total
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(count_Qty) AS count_Qty
	FROM OR_MOU
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
C4_MOU
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month,
		(
			CASE 
				WHEN sum(qty) > 0
					THEN 1
				ELSE 0
				END
			) AS count_Qty
	FROM demand
	WHERE SOLD_TO_BP_CODE IN (
			'Intel-INTAFO',
			'Intel - INTAFO'
			)
		AND YEARMONTH >= CONCAT (
			year(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)),
			LPAD(month(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)), 2, '0')
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		MOU_month
	),
C4_MOU_total
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(count_Qty) AS count_Qty
	FROM C4_MOU
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
m36_MOU_YEARMONTH
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		YEARMONTH,
		(
			CASE 
				WHEN sum(qty) > 0
					THEN 1
				ELSE 0
				END
			) AS count_Qty
	FROM demand
	WHERE (
			SOLD_TO_BP_CODE IN (
				'Intel-INTD1C',
				'Intel-INTD1D',
				'Intel-INTD1X'
				)
			OR REGION IN (
				'OR',
				'IE'
				)
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		YEARMONTH
	),
m36_MOU
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(count_Qty) AS count_Qty
	FROM m36_MOU_YEARMONTH
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
M12_mou_sum
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		count_qty,
		'IR' AS site,
		CASE 
			WHEN count_qty > 0
				THEN 1
			ELSE 0
			END AS vf_site_count
	FROM IR_MOU_total
	
	UNION
	
	SELECT MATDOC_MATERIAL_NUMBER,
		count_qty,
		'OR' AS site,
		CASE 
			WHEN count_qty > 0
				THEN 1
			ELSE 0
			END AS vf_site_count
	FROM OR_MOU_total
	
	),
m12_MOU_VFS_SITE
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(vf_site_count) AS count_VF_Site
	FROM M12_mou_sum
	WHERE site IN (
			'IR',
			'OR'
			)
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
monthwise_count
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		CASE 
			WHEN month.MOU_month = '11'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M12,
		CASE 
			WHEN month.MOU_month = '10'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M11,
		CASE 
			WHEN month.MOU_month = '9'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M10,
		CASE 
			WHEN month.MOU_month = '8'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M9,
		CASE 
			WHEN month.MOU_month = '7'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M8,
		CASE 
			WHEN month.MOU_month = '6'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M7,
		CASE 
			WHEN month.MOU_month = '5'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M6,
		CASE 
			WHEN month.MOU_month = '4'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M5,
		CASE 
			WHEN month.MOU_month = '3'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M4,
		CASE 
			WHEN month.MOU_month = '2'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M3,
		CASE 
			WHEN month.MOU_month = '1'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M2,
		CASE 
			WHEN month.MOU_month = '0'
				THEN ZEROIFNULL(month.qTY)
			ELSE 0
			END AS M1
	FROM M12_sum AS month
	),
monthwise_sum
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		sum(m12) AS m12,
		sum(m11) AS m11,
		sum(m10) AS m10,
		sum(m9) AS m9,
		sum(m8) AS m8,
		sum(m7) AS m7,
		sum(m6) AS m6,
		sum(m5) AS m5,
		sum(m4) AS m4,
		sum(m3) AS m3,
		sum(m2) AS m2,
		sum(m1) AS m1
	FROM monthwise_count
	GROUP BY MATDOC_MATERIAL_NUMBER
	),
source_data
AS (
	SELECT 
		vfbom.FILEDATE,
		vfbom.process,
		vfbom.CONSOLIDATED_SPN,
		vfbom.OEM_SPN,
		vfbom.ALTERNATE_REPAIRED_SPN,
		vfbom.INTEL_PART_NUMBER,
		vfbom.ITEM_DESCRIPTION,
		CASE 
			WHEN vfbom.INVENTORYCATEGORY1 = 'D' AND ZEROIFNULL(vfbom.MSQHIGH) >= 1
				THEN 'D1'
			WHEN vfbom.INVENTORYCATEGORY1 = 'D' AND ZEROIFNULL(vfbom.MSQHIGH) = 0
				THEN 'D0'
			ELSE vfbom.INVENTORYCATEGORY1
			END AS INVENTORYCATEGORY1,
		ZEROIFNULL(m12_MOU_VFS_SITE.count_vf_site) AS VF_SITE_Count,
		cost_pn.STPRS AS PN_Cost,
		CASE 
			when vfbom.INVENTORYCATEGORY1 in ('J','U') then ''
			WHEN VF_SITE_Count  >= 2  AND (OR_MOU.count_Qty >= 6 OR IR_MOU.count_Qty >= 6 OR c4_MOU.count_Qty >= 6 )  
			and demand.IPN is not null THEN 'Q' 
			WHEN VF_SITE_Count  >= 2  AND 
			   (ZEROIFNULL(IR_MOU.count_Qty) >= 4 and ZEROIFNULL(OR_MOU.count_Qty)  >= 4 )  then 'A'
			  WHEN VF_SITE_Count  >= 2  AND 
			   ( ZEROIFNULL(IR_MOU.count_Qty) >= 2 and ZEROIFNULL(OR_MOU.count_Qty) >= 2 )  then 'B' 
			WHEN VF_SITE_Count  >= 1 AND  ( ( ZEROIFNULL(IR_MOU.count_Qty) >= 2  ) or 
			    ( ZEROIFNULL(OR_MOU.count_Qty)   >= 2 )  ) THEN 'C'
			WHEN VF_SITE_Count  >= 1 AND  ( ( ZEROIFNULL(IR_MOU.count_Qty) >= 1  ) or 
			    ( ZEROIFNULL(OR_MOU.count_Qty)   >= 1 ) ) THEN 'C'
			WHEN VF_SITE_Count = 0 and ZEROIFNULL(M36_MOU.count_Qty)  > 0 then 'D1'
			WHEN ZEROIFNULL(M36_MOU.count_Qty)  = 0  THEN 'D0'
			else ' ' END AS Calculated_Ranking,
		CASE 
			WHEN Calculated_Ranking = 'Q'
				THEN 1
			WHEN Calculated_Ranking = 'A'
				THEN 2
			WHEN Calculated_Ranking = 'B'
				THEN 3
			WHEN Calculated_Ranking = 'C'
				THEN 4
			WHEN Calculated_Ranking = 'D1'
				THEN 5
			WHEN Calculated_Ranking = 'D0'
				THEN 6
			ELSE 0
			END AS cal_rank,
		CASE COALESCE(CASE 
				WHEN vfbom.INVENTORYCATEGORY1 = 'D' AND ZEROIFNULL(vfbom.MSQHIGH) >= 1
					THEN 'D1'
				WHEN vfbom.INVENTORYCATEGORY1 = 'D' AND ZEROIFNULL(vfbom.MSQHIGH) = 0
					THEN 'D0'
				ELSE vfbom.INVENTORYCATEGORY1
				END, '')
			WHEN 'Q'
				THEN 1
			WHEN 'A'
				THEN 2
			WHEN 'B'
				THEN 3
			WHEN 'C'
				THEN 4
			WHEN 'D1'
				THEN 5
			WHEN 'D0'
				THEN 6
			ELSE 0
			END AS org_rank,
		ZEROIFNULL(IR_MOU.count_Qty) AS IR_MOU,
		ZEROIFNULL(OR_MOU.count_Qty) AS or_MOU,
		ZEROIFNULL(C4_MOU.count_Qty) AS C4_MOU,
		ZEROIFNULL(M36_MOU.count_Qty) AS M36_MOU,
		vfbom.MSQLOW,
		vfbom.MSQHIGH,
		header.machine_type,
		ZEROIFNULL(Month.M12) AS M12,
		ZEROIFNULL(Month.M11) AS m11,
		ZEROIFNULL(Month.M10) AS m10,
		ZEROIFNULL(Month.M9) AS m9,
		ZEROIFNULL(Month.M8) AS m8,
		ZEROIFNULL(Month.M7) AS m7,
		ZEROIFNULL(Month.M6) AS m6,
		ZEROIFNULL(Month.M5) AS m5,
		ZEROIFNULL(Month.M4) AS m4,
		ZEROIFNULL(Month.M3) AS m3,
		ZEROIFNULL(Month.M2) AS m2,
		ZEROIFNULL(Month.M1) AS m1
	FROM vfbom AS vfbom
	LEFT JOIN header AS header ON VFBOM.CONSOLIDATED_SPN = header.CONSOLIDATED_SPN
	LEFT JOIN IR_MOU_total AS IR_MOU ON IR_MOU.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN OR_MOU_total AS OR_MOU ON OR_MOU.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN c4_MOU_total AS c4_MOU ON c4_MOU.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN m36_MOU AS m36_MOU ON M36_MOU.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN monthwise_sum AS month ON month.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN cost_pn AS cost_pn ON cost_pn.matnr = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN m12_MOU_VFS_SITE AS m12_MOU_VFS_SITE ON m12_MOU_VFS_SITE.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	LEFT JOIN {{ ref('BRONZE__TEA_INTEL_SMS__FILE_DEMAND_CAPACITY_LIST') }} AS demand ON demand.SPN = VFBOM.CONSOLIDATED_SPN
	),
transform_data as (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
	FILEDATE,
	PROCESS,
	CONSOLIDATED_SPN,
	OEM_SPN,
	ALTERNATE_REPAIRED_SPN,
	INTEL_PART_NUMBER,
	ITEM_DESCRIPTION,
	VF_SITE_COUNT,
	PN_COST,
	INVENTORYCATEGORY1,
	CALCULATED_RANKING,
		CASE 
			WHEN Cal_rank = org_rank
				THEN 'Unchanged'
			WHEN cal_rank > org_rank
				THEN 'Downgrade'
			WHEN cal_rank < org_rank
				THEN 'Upgrade'
			END AS
	UPGRADE_DOWNGRADE,
	IR_MOU,
	OR_MOU,
	C4_MOU,
	M36_MOU,
	MSQLOW,
	MSQHIGH,
	MACHINE_TYPE,
	M12,
	M11,
	M10,
	M9,
	M8,
	M7,
	M6,
	M5,
	M4,
	M3,
	M2,
	M1
 from source_data
),

type_data as (
SELECT
	CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
	CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
	FILEDATE,
	PROCESS,
	CONSOLIDATED_SPN,
	OEM_SPN,
	ALTERNATE_REPAIRED_SPN,
	INTEL_PART_NUMBER,
	ITEM_DESCRIPTION,
	CAST(VF_SITE_COUNT AS NUMBER(13,0)) AS VF_SITE_COUNT,
	PN_COST,
	INVENTORYCATEGORY1,
	CAST(CALCULATED_RANKING AS VARCHAR(2)) AS CALCULATED_RANKING,
	UPGRADE_DOWNGRADE,
	CAST(IR_MOU AS NUMBER(25,0)) AS IR_MOU,
	CAST(OR_MOU AS NUMBER(25,0)) AS OR_MOU,
	CAST(C4_MOU AS NUMBER(25,0)) AS C4_MOU,
	CAST(M36_MOU AS NUMBER(13,0)) AS M36_MOU,
	CAST(MSQLOW AS NUMBER(38,0)) AS MSQLOW,
	CAST(MSQHIGH AS NUMBER(38,0)) AS MSQHIGH,
	MACHINE_TYPE,
	CAST(M12 AS FLOAT) AS M12,
	CAST(M11 AS FLOAT) AS M11,
	CAST(M10 AS FLOAT) AS M10,
	CAST(M9 AS FLOAT) AS M9,
	CAST(M8 AS FLOAT) AS M8,
	CAST(M7 AS FLOAT) AS M7,
	CAST(M6 AS FLOAT) AS M6,
	CAST(M5 AS FLOAT) AS M5,
	CAST(M4 AS FLOAT) AS M4,
	CAST(M3 AS FLOAT) AS M3,
	CAST(M2 AS FLOAT) AS M2,
	CAST(M1 AS FLOAT) AS M1
 from transform_data
)

Select * from type_data