/************
	Model file generated from SAPAPIUtility 
	*************/

	
	{{ config(
    	  materialized = 'tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU084_A350',
    	  unique_key = ['KAPPL',
    'KSCHL',
    'VKORG',
    'KFRST',
    'DATAB'],
    	  transient=false	
) }} 

	with source_data as ( 
    SELECT
        _FILEDATE,
        _FILENAME,
		JSONFIELD:Mandt::STRING AS MANDT,
		JSONFIELD:Kappl::STRING AS KAPPL,
		JSONFIELD:Kschl::STRING AS KSCHL,
		JSONFIELD:Vkorg::STRING AS VKORG,
		JSONFIELD:Kfrst::STRING AS KFRST,
		JSONFIELD:Datbi::STRING AS DATBI,
		JSONFIELD:Datab::STRING AS DATAB,
		JSONFIELD:Kbstat::STRING AS KBSTAT,
		JSONFIELD:Knumh::STRING AS KNUMH,
		JSONFIELD:update_date::STRING AS UPDATE_DATE
    FROM {{ source('SAPAPI','ZCDV_T_CMTU084_A350') }}
	{% if is_tel_incremental() %}WHERE  _FILEDATE >= IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY KAPPL,KSCHL,VKORG,KFRST,DATAB ORDER BY _FILENAME DESC, _FILEDATE DESC, KNUMH DESC)) = 1

	),
	
	transform_data as (
    SELECT
        '{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH,
        _FILEDATE AS _FILEDATE,
        _FILENAME AS _FILENAME,
		KAPPL as KAPPL,
		KSCHL as KSCHL,
		VKORG as VKORG,
		KFRST as KFRST,
		lead(DATAB) over (partition by KAPPL,KSCHL,VKORG,KFRST order by DATAB) as NEXT_DATAB,
		to_varchar(dateadd('day', -1, try_to_date(NEXT_DATAB, 'YYYYMMDD')), 'YYYYMMDD') as ADJ_DATBI,
		coalesce(ADJ_DATBI, DATBI) as DATBI,
		DATAB as DATAB,
		KBSTAT as KBSTAT,
		KNUMH as KNUMH,
		UPDATE_DATE as UPDATE_DATE
    FROM source_data 
),

type_data as (
    SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
        _FILEDATE,
        _FILENAME,
		KAPPL,
		KSCHL,
		VKORG,
		KFRST,
		DATBI,
		DATAB,
		KBSTAT,
		KNUMH,
		UPDATE_DATE
    FROM transform_data 
)

	select * from type_data