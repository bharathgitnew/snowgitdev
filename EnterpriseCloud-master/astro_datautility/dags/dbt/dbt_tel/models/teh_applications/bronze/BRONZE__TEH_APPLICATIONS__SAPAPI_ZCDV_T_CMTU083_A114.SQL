/************
	Model file generated from SAPAPIUtility 
	*************/

	-- disabled due to no SAP data
	{{ config(
    	  materialized = 'tel_incremental',
    	  incremental_strategy='merge',
    	  alias='SAPAPI_ZCDV_T_CMTU083_A114',
    	  unique_key = ['KAPPL',
    'KSCHL',
    'VKORG',
    'KUNNR',
    'DATBI'],
    	  transient=false	
) }} 

	with source_data as (
	SELECT
	    _FILEDATE,
		_FILENAME,
		JSONFIELD:KAPPL::STRING AS KAPPL, 
 	 	JSONFIELD:KSCHL::STRING AS KSCHL, 
 	 	JSONFIELD:VKORG::STRING AS VKORG, 
 	 	JSONFIELD:KUNNR::STRING AS KUNNR, 
 	 	JSONFIELD:DATBI::STRING AS DATBI, 
 	 	JSONFIELD:DATAB::STRING AS DATAB, 
 	 	JSONFIELD:KNUMH::STRING AS KNUMH, 
 	 	JSONFIELD:UPDATE_DATE::STRING AS UPDATE_DATE
	from {{ source('SAPAPI', 'ZCDV_T_CMTU083_A114') }}
	WHERE 1=2
/* Adding false filter to the model so that we can enable it for DBT Project Consolidation, related to changes in k-card 34754 */
	--{% if is_tel_incremental() %}WHERE  _FILEDATE > IFNULL((SELECT MAX(_FILEDATE) FROM {{ this }}),'1970-01-01'){% endif %}
        QUALIFY (ROW_NUMBER() OVER (PARTITION BY JSONFIELD:KAPPL::STRING,JSONFIELD:KSCHL::STRING,JSONFIELD:VKORG::STRING,JSONFIELD:KUNNR::STRING,JSONFIELD:DATBI::STRING  ORDER BY _FILENAME DESC, _FILEDATE DESC )) = 1

	),
	
	transform_data as (
	SELECT 
		'{{ invocation_id }}' AS _AUDIT_LOG_ID,
        SHA2('hash_me') AS _ROW_HASH, -- Adds column to table on full refresh.
		_FILEDATE,
		_FILENAME,
		KAPPL, 
 	 	KSCHL, 
 	 	VKORG, 
 	 	KUNNR, 
 	 	DATBI, 
 	 	DATAB, 
 	 	KNUMH, 
 	 	UPDATE_DATE
	from source_data
	),
	
	type_data as (
	SELECT
        CAST(_AUDIT_LOG_ID AS VARCHAR(128)) AS _AUDIT_LOG_ID,
        CAST(_ROW_HASH AS VARCHAR(128)) AS _ROW_HASH,
		cast(_FILEDATE AS TIMESTAMP_NTZ(9)) AS _FILEDATE,
		_FILENAME,
		 KAPPL, 
 	 	 KSCHL, 
 	 	 VKORG, 
 	 	 KUNNR, 
 	 	 DATBI, 
 	 	 DATAB, 
 	 	 KNUMH, 
 	 	 UPDATE_DATE
	from transform_data
	)

	select * from type_data