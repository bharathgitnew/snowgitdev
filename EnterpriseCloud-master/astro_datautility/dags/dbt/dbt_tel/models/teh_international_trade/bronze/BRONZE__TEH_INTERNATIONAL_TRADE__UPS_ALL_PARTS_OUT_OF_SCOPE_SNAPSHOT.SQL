/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
          materialized='tel_incremental',
          incremental_strategy='merge',
          alias='UPS_ALL_PARTS_OUT_OF_SCOPE_SNAPSHOT',
          unique_key=['SNAPSHOT_DATE','_ROW_SURROGATE_KEY'],
          transient=false    
) }} 
	with source_data as ( 
    SELECT
        _FILEDATE
        ,_FILENAME
		,_FILEDATE AS SNAPSHOT_DATE
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
		,{{ dbt_utils.generate_surrogate_key([
							'BU',
							'HS',
							'HS_COD6_DIGI',
							'HS_CODE2_DIGI',
							'JUDGEMENT_FLAG',
							'MATERIAL',
							'MATERIAL_MEMO',
							'P_N',
							'P_N2',
							'US_HS_10_DIGI',
							'COO',
							'US_PRIORITY'
		]) }} as _ROW_SURROGATE_KEY
    FROM {{ ref('BRONZE__TEH_INTERNATIONAL_TRADE__UPS_ALL_PARTS_OUT_OF_SCOPE') }}


	),
	
	transform_data as (
    SELECT
        _FILEDATE AS _FILEDATE
        ,_FILENAME AS _FILENAME
        ,'{{ invocation_id }}' AS _AUDIT_LOG_ID
        ,SHA2('hash_me') AS _ROW_HASH
		,_ROW_SURROGATE_KEY
		,SNAPSHOT_DATE
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
		,_ROW_SURROGATE_KEY
        ,SNAPSHOT_DATE
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