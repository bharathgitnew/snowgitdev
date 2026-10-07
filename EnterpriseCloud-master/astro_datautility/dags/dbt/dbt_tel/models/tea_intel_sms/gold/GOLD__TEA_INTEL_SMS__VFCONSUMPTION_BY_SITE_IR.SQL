{{ config(
      alias = 'VFCONSUMPTION_BY_SITE_IR',
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
	SELECT DISTINCT FILEDATE,
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
demand
AS (
	SELECT MATERIAL_NUMBER AS MATDOC_MATERIAL_NUMBER,
		CONCAT (
			SUBSTR(PERIOD, 1, 4),
			SUBSTR(PERIOD, 6, 2)
			) AS YEARMONTH,
		SOLD_TO_BP,
		'IR' AS REGION,
		DATEDIFF(month, order_date, CURRENT_DATE - 1) AS MOU_month,
		sum(ORDER_QUANTITY) AS QTY
	FROM {{ ref('BRONZE__TEA_INTEL_SMS__FILE_BAAN_TEE_SALES') }} 
	WHERE SOLD_TO_BP IN ('I73300')
		AND order_date >= DATEADD(month, - 35, CURRENT_DATE - 1)
	GROUP BY MATERIAL_NUMBER,
		period,
		SOLD_TO_BP,
		ORDER_DATE
	),
M12_sum
AS (
	SELECT MATDOC_MATERIAL_NUMBER,
		MOU_month,
		SUM(QTY) AS qty
	FROM demand
	WHERE YEARMONTH >= CONCAT (
			year(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)),
			LPAD(month(ADD_MONTHS(DATEADD(day, - 1, CURRENT_DATE), - 11)), 2, '0')
			)
	GROUP BY MATDOC_MATERIAL_NUMBER,
		MOU_month
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
	SELECT vfbom.FILEDATE,
		vfbom.process,
		vfbom.CONSOLIDATED_SPN,
		vfbom.OEM_SPN,
		vfbom.ALTERNATE_REPAIRED_SPN,
		vfbom.INTEL_PART_NUMBER,
		vfbom.ITEM_DESCRIPTION,
		vfbom.MSQLOW,
		vfbom.MSQHIGH,
		'IR' AS SITE,
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
	LEFT JOIN monthwise_sum AS month ON month.MATDOC_MATERIAL_NUMBER = VFBOM.CONSOLIDATED_SPN
	),
transform_data as (
SELECT
	'{{ invocation_id }}' AS _AUDIT_LOG_ID,
	SHA2('hash_me') as _ROW_HASH,
	FILEDATE,
	process,
	CONSOLIDATED_SPN,
	OEM_SPN,
	ALTERNATE_REPAIRED_SPN,
	INTEL_PART_NUMBER,
	ITEM_DESCRIPTION,
	MSQLOW,
	MSQHIGH,
	SITE,
    ZEROIFNULL(M12) as M12, 
    ZEROIFNULL(M11) as M11, 
    ZEROIFNULL(M10) as M10, 
    ZEROIFNULL(M9) as M9, 
    ZEROIFNULL(M8) as M8, 
    ZEROIFNULL(M7) as M7, 
    ZEROIFNULL(M6) as M6, 
    ZEROIFNULL(M5) as M5, 
    ZEROIFNULL(M4) as M4, 
    ZEROIFNULL(M3) as M3, 
    ZEROIFNULL(M2) as M2, 
    ZEROIFNULL(M1) as M1
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
	CAST(MSQLOW AS NUMBER(38,0)) AS MSQLOW,
	CAST(MSQHIGH AS NUMBER(38,0)) AS MSQHIGH,
	CAST(SITE AS VARCHAR(2)) AS SITE,
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