/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='UPS_ALL_PARTS_ALL',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE
        ,_FILENAME
		,JSONFIELD:"COO"::STRING AS COO
		,JSONFIELD:"DESC"::STRING AS "DESC"
		,JSONFIELD:"HS"::STRING AS HS
		,JSONFIELD:"HS Cod 6 Digi"::STRING AS HS_COD6_DIGI
		,JSONFIELD:"HS Code 2 Digi"::STRING AS HS_CODE2_DIGI
		,JSONFIELD:"Judgement flag"::STRING AS JUDGEMENT_FLAG
		,JSONFIELD:"Material"::STRING AS MATERIAL
		,JSONFIELD:"Material Memo"::STRING AS MATERIAL_MEMO
		,JSONFIELD:"P/N"::STRING AS P_N
		,JSONFIELD:"P/N2"::STRING AS P_N2
		,JSONFIELD:"Ratio"::STRING AS RATIO
		,JSONFIELD:"US HS 10 Digi"::STRING AS US_HS_10_DIGI
		,JSONFIELD:"US Priority"::STRING AS US_PRIORITY
		,JSONFIELD:"Zoku"::STRING AS ZOKU
		,JSONFIELD:"Model"::STRING AS MODEL
		,JSONFIELD:"Supp"::STRING AS SUPP
		,JSONFIELD:"0"::STRING AS J_0
		,JSONFIELD:"BU"::STRING AS BU
		,JSONFIELD:"Melt/poured"::STRING AS MELT_POURED
		,JSONFIELD:"Smelt"::STRING AS SMELT
		,JSONFIELD:"Cast"::STRING AS CAST
		,JSONFIELD:"DteLoad"::STRING AS DTELOAD
    FROM {{ source('UPS','UPS_ALL_PARTS_ALL') }}
	where _FILEDATE = (select max(_FILEDATE) from {{ source('UPS', 'UPS_ALL_PARTS_ALL') }})


	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
		COO
		,"DESC"
		,HS
		,HS_COD6_DIGI
		,HS_CODE2_DIGI
		,JUDGEMENT_FLAG
		,MATERIAL
		,MATERIAL_MEMO
		,P_N
		,P_N2
		,RATIO
		,US_HS_10_DIGI
		,US_PRIORITY
		,ZOKU
		,MODEL
		,SUPP
		,J_0
		,BU
		,MELT_POURED
		,SMELT
		,"CAST"
		,TRY_TO_TIMESTAMP(DTELOAD, 'MM/DD/YY HH24:MI') AS DTELOAD
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE,
        _FILENAME,
        _AUDIT_LOG_ID,
        _ROW_HASH,
		COO
		,"DESC"
		,HS
		,HS_COD6_DIGI
		,HS_CODE2_DIGI
		,JUDGEMENT_FLAG
		,MATERIAL
		,MATERIAL_MEMO
		,P_N
		,P_N2
		,RATIO
		,US_HS_10_DIGI
		,US_PRIORITY
		,ZOKU
		,MODEL
		,SUPP
		,J_0
		,BU
		,MELT_POURED
		,SMELT
		,"CAST"
		,DTELOAD
    FROM transform_data 
)

	select * from type_data