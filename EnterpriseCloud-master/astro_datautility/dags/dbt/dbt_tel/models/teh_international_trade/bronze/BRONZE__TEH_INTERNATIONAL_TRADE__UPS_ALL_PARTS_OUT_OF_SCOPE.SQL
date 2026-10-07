/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized='tel_incremental',
    	  incremental_strategy='insert_overwrite',
    	  alias='UPS_ALL_PARTS_OUT_OF_SCOPE',
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE
        ,_FILENAME
		,JSONFIELD:"BU"::STRING AS BU
        ,JSONFIELD:"HS"::STRING AS HS
        ,JSONFIELD:"HS Cod6 Digi"::STRING AS HS_COD6_DIGI
        ,JSONFIELD:"HS Code2 Digi"::STRING AS HS_CODE2_DIGI
        ,JSONFIELD:"Judgement flag"::STRING AS JUDGEMENT_FLAG
        ,JSONFIELD:"Material"::STRING AS MATERIAL
        ,JSONFIELD:"Material Memo"::STRING AS MATERIAL_MEMO
        ,JSONFIELD:"P/N"::STRING AS P_N
        ,JSONFIELD:"P/N2"::STRING AS P_N2
        ,JSONFIELD:"US HS 10 Digi"::STRING AS US_HS_10_DIGI
        ,JSONFIELD:"COO"::STRING AS COO
        ,JSONFIELD:"US Priority"::STRING AS US_PRIORITY
    FROM {{ source('UPS','UPS_ALL_PARTS_OUT_OF_SCOPE') }}
	where _FILEDATE = (select max(_FILEDATE) from {{ source('UPS', 'UPS_ALL_PARTS_OUT_OF_SCOPE') }})


	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE
        ,_FILENAME AS _FILENAME
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
		,BU
        ,HS
        ,HS_COD6_DIGI
        ,HS_CODE2_DIGI
        ,JUDGEMENT_FLAG
        ,MATERIAL
        ,MATERIAL_MEMO
        ,P_N
        ,P_N2
        ,US_HS_10_DIGI
        ,COO
        ,US_PRIORITY
    FROM source_data
),

type_data as (
    SELECT
        _FILEDATE
        ,_FILENAME
        ,_AUDIT_LOG_ID
        ,_ROW_HASH
		,BU
        ,HS
        ,HS_COD6_DIGI
        ,HS_CODE2_DIGI
        ,JUDGEMENT_FLAG
        ,MATERIAL
        ,MATERIAL_MEMO
        ,P_N
        ,P_N2
        ,US_HS_10_DIGI
        ,COO
        ,US_PRIORITY
    FROM transform_data 
)

	select * from type_data